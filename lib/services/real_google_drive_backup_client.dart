// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'google_drive_backup_client.dart';

/// Real Google Drive integration for database backups on Flutter Android.
/// Authenticates via Google Sign-In and uses the official Google Drive API v3.
class RealGoogleDriveBackupClient implements GoogleDriveBackupClient {
  GoogleSignIn _googleSignIn;
  final String defaultBackupFolderName;
  String? lastAuthError;

  RealGoogleDriveBackupClient({
    GoogleSignIn? customGoogleSignIn,
    String? serverClientId,
    String? clientId,
    this.defaultBackupFolderName = 'BACKUP_FOLDER',
  }) : _googleSignIn =
           customGoogleSignIn ??
           GoogleSignIn(
             serverClientId: serverClientId,
             clientId: clientId,
             scopes: <String>[
               drive.DriveApi.driveReadonlyScope,
               drive.DriveApi.driveFileScope,
             ],
           );

  static const List<String> requiredTables = [
    'factories',
    'input_files',
    'batches',
    'processing_runs',
    'preprocessing_data',
    'ai_models',
    'predictions',
    'mqtt_publish_log',
    'backup_history',
  ];

  GoogleSignIn get googleSignIn => _googleSignIn;
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
  String? get currentUserEmail => _googleSignIn.currentUser?.email;

  /// Updates GoogleSignIn configuration if serverClientId or clientId is provided.
  void updateClientConfig({String? serverClientId, String? clientId}) {
    _googleSignIn = GoogleSignIn(
      serverClientId: serverClientId,
      clientId: clientId,
      scopes: <String>[
        drive.DriveApi.driveReadonlyScope,
        drive.DriveApi.driveFileScope,
      ],
    );
  }

  /// Forces fresh re-authentication to ensure new OAuth scopes are granted.
  Future<GoogleSignInAccount?> reAuthenticate() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    return await signIn();
  }

  /// Obtains the OAuth2 access token for Python Chaquopy MethodChannel bridge.
  Future<String?> getAccessToken() async {
    try {
      final account =
          _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
      if (account == null) return null;
      final auth = await account.authentication;
      return auth.accessToken;
    } catch (e) {
      print('! getAccessToken error: $e');
      return null;
    }
  }

  /// Initiates Google Sign-In on Android.
  Future<GoogleSignInAccount?> signIn() async {
    lastAuthError = null;
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        lastAuthError = 'Sign-in cancelled by user.';
      }
      return account;
    } on PlatformException catch (pe) {
      lastAuthError =
          'Google Sign-In Platform Error: ${pe.code} - ${pe.message}\n(Details: ${pe.details})';
      print('! Google Sign-In PlatformException: $lastAuthError');
      return null;
    } catch (e) {
      lastAuthError = 'Google Sign-In Error: $e';
      print('! Google Sign-In Exception: $lastAuthError');
      return null;
    }
  }

  /// Signs out of Google.
  Future<void> signOut() async {
    lastAuthError = null;
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('! Google Sign-Out error: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final account =
          _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
      return account != null;
    } catch (_) {
      return false;
    }
  }

  /// Obtains an authenticated Drive API client.
  Future<drive.DriveApi> _getDriveApi() async {
    final account =
        _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
    if (account == null) {
      throw const SocketException('User is not authenticated with Google.');
    }

    final authenticatedHttpClient = await _googleSignIn.authenticatedClient();
    if (authenticatedHttpClient == null) {
      throw const SocketException(
        'Failed to obtain authenticated HTTP client from Google Sign-In.',
      );
    }

    return drive.DriveApi(authenticatedHttpClient);
  }

  /// Resolves or creates the dedicated `DISTILLERY_DATABASE_BACKUPS` folder.
  Future<String> resolveBackupFolderId(
    drive.DriveApi driveApi, {
    String? customFolderId,
  }) async {
    if (customFolderId != null &&
        customFolderId.isNotEmpty &&
        customFolderId != 'DISTILLERY_DATABASE_BACKUPS_FOLDER_ID') {
      try {
        final folder = await driveApi.files.get(
          customFolderId,
          $fields: 'id, name, mimeType, trashed',
        ) as drive.File;

        if (folder.trashed != true) {
          return folder.id!;
        }
      } catch (_) {
        // If specific ID lookup fails, fallback to named search/create
      }
    }

    // Search for existing DISTILLERY_DATABASE_BACKUPS folder
    final search = await driveApi.files.list(
      q: "name = '$defaultBackupFolderName' and mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      spaces: 'drive',
      $fields: 'files(id, name)',
    );

    if (search.files != null && search.files!.isNotEmpty) {
      return search.files!.first.id!;
    }

    // Create the dedicated DISTILLERY_DATABASE_BACKUPS folder
    final newFolder = drive.File()
      ..name = defaultBackupFolderName
      ..mimeType = 'application/vnd.google-apps.folder';

    final created = await driveApi.files.create(newFolder, $fields: 'id');
    if (created.id == null) {
      throw StateError(
        'Failed to create Google Drive backup folder: $defaultBackupFolderName',
      );
    }

    return created.id!;
  }

  @override
  Future<bool> verifyFolderAccess({required String folderId}) async {
    try {
      final driveApi = await _getDriveApi();
      final folder = await driveApi.files.get(
        folderId,
        $fields: 'id, name, mimeType, trashed',
      ) as drive.File;
      return folder.trashed != true;
    } catch (e) {
      print('! Google Drive verifyFolderAccess error: $e');
      return false;
    }
  }

  @override
  Future<String> resolveSubfolderId({
    required String parentFolderId,
    required String subfolderName,
  }) async {
    final driveApi = await _getDriveApi();

    // 1. List all existing subfolders inside parentFolderId
    final query =
        "'$parentFolderId' in parents and mimeType = 'application/vnd.google-apps.folder' and trashed = false";
    final search = await driveApi.files.list(
      q: query,
      spaces: 'drive',
      $fields: 'files(id, name)',
    );

    final files = search.files ?? [];

    // Match 1: Exact name match (e.g., 'Haliyal', 'Sankili', 'Nellikuppam', 'Sivagangai', 'Bagalkot')
    for (final f in files) {
      if (f.name == subfolderName && f.id != null) {
        return f.id!;
      }
    }

    // Match 2: Case-insensitive match
    final targetLower = subfolderName.toLowerCase().trim();
    for (final f in files) {
      final nameLower = (f.name ?? '').toLowerCase().trim();
      if (nameLower == targetLower && f.id != null) {
        return f.id!;
      }
    }

    // Match 3: Spelling variations (e.g. 'Nelikuppam' vs 'Nellikuppam')
    final targetNormalized = targetLower
        .replaceAll('l', '')
        .replaceAll('_', '')
        .replaceAll(RegExp(r'^f0\d'), '');
    for (final f in files) {
      final nameLower = (f.name ?? '').toLowerCase().trim();
      final nameNormalized = nameLower
          .replaceAll('l', '')
          .replaceAll('_', '')
          .replaceAll(RegExp(r'^f0\d'), '');
      if (nameNormalized.isNotEmpty &&
          nameNormalized == targetNormalized &&
          f.id != null) {
        return f.id!;
      }
    }

    // Match 4: Substring contains (e.g. 'F01_Haliyal' vs 'Haliyal')
    for (final f in files) {
      final nameLower = (f.name ?? '').toLowerCase().trim();
      if ((nameLower.contains(targetLower) ||
              targetLower.contains(nameLower)) &&
          f.id != null) {
        return f.id!;
      }
    }

    // 2. Create subfolder inside parentFolderId if not found
    final newFolder = drive.File()
      ..name = subfolderName
      ..parents = [parentFolderId]
      ..mimeType = 'application/vnd.google-apps.folder';

    final created = await driveApi.files.create(newFolder, $fields: 'id, name');
    if (created.id == null) {
      throw StateError(
        'Failed to create subfolder $subfolderName in parent $parentFolderId',
      );
    }

    return created.id!;
  }

  @override
  Future<GoogleDriveUploadResult> uploadBackupFile({
    required File localFile,
    required String folderId,
    required String fileName,
  }) async {
    if (!await localFile.exists()) {
      throw StateError('Local snapshot file not found: ${localFile.path}');
    }

    final driveApi = await _getDriveApi();
    final targetFolderId = folderId;

    final fileSize = await localFile.length();
    final mediaStream = localFile.openRead();
    final media = drive.Media(mediaStream, fileSize);

    final driveFileMeta = drive.File()
      ..name = fileName
      ..parents = [targetFolderId]
      ..mimeType = 'application/x-sqlite3';

    final uploadedFile = await driveApi.files.create(
      driveFileMeta,
      uploadMedia: media,
      $fields: 'id, name, size, createdTime, parents',
    );

    if (uploadedFile.id == null) {
      throw StateError(
        'Google Drive API did not return a valid file ID for uploaded backup.',
      );
    }

    return GoogleDriveUploadResult(
      driveFileId: uploadedFile.id!,
      fileName: uploadedFile.name ?? fileName,
      fileSizeBytes: int.tryParse(uploadedFile.size ?? '') ?? fileSize,
      folderId: targetFolderId,
      uploadedAt: uploadedFile.createdTime ?? DateTime.now().toUtc(),
    );
  }

  @override
  Future<GoogleDriveBackupVerificationResult> downloadAndVerifyBackup({
    required String driveFileId,
    required int expectedSizeBytes,
  }) async {
    File? tempVerificationFile;
    Database? rawDb;

    try {
      final driveApi = await _getDriveApi();

      // 1. Confirm remote file metadata
      final remoteMeta = await driveApi.files.get(
        driveFileId,
        $fields: 'id, name, size, trashed',
      ) as drive.File;

      if (remoteMeta.trashed == true) {
        return GoogleDriveBackupVerificationResult.failure(
          'Uploaded Google Drive file $driveFileId is trashed.',
        );
      }

      // 2. Download remote file content to temporary Android private storage
      final tempDir = await getTemporaryDirectory();
      final verifyPath = p.join(tempDir.path, 'verify_$driveFileId.db');
      tempVerificationFile = File(verifyPath);

      if (await tempVerificationFile.exists()) {
        await tempVerificationFile.delete();
      }

      final media = await driveApi.files.get(
        driveFileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final sink = tempVerificationFile.openWrite();
      await media.stream.pipe(sink);
      await sink.flush();
      await sink.close();

      if (!await tempVerificationFile.exists() ||
          await tempVerificationFile.length() == 0) {
        return GoogleDriveBackupVerificationResult.failure(
          'Downloaded verification file is empty or missing.',
        );
      }

      // 3. Full SQLite Database Inspection
      rawDb = sqlite3.open(tempVerificationFile.path);

      // A. Verify PRAGMA integrity_check
      final integrityResult = rawDb.select('PRAGMA integrity_check;');
      final integrityStatus =
          integrityResult.first['integrity_check'] as String? ?? '';
      if (integrityStatus.toLowerCase() != 'ok') {
        rawDb.dispose();
        return GoogleDriveBackupVerificationResult.failure(
          'PRAGMA integrity_check failed on remote backup: $integrityStatus',
        );
      }

      // B. Verify all 9 expected tables exist
      final tablesResult = rawDb.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
      );
      final tablesFound = tablesResult.map((r) => r['name'] as String).toList();

      for (final req in requiredTables) {
        if (!tablesFound.contains(req)) {
          rawDb.dispose();
          return GoogleDriveBackupVerificationResult.failure(
            'Missing required table $req in remote backup database.',
          );
        }
      }

      // C. Verify PRAGMA foreign_key_check
      final fkResult = rawDb.select('PRAGMA foreign_key_check;');
      if (fkResult.isNotEmpty) {
        rawDb.dispose();
        return GoogleDriveBackupVerificationResult.failure(
          'Foreign-key check failed on remote backup with ${fkResult.length} violation(s)',
        );
      }

      rawDb.dispose();
      rawDb = null;

      // 4. Safely clean up temporary downloaded verification file
      if (await tempVerificationFile.exists()) {
        await tempVerificationFile.delete();
      }

      return GoogleDriveBackupVerificationResult(
        isVerified: true,
        integrityCheckPassed: true,
        foreignKeyCheckPassed: true,
        tablesFound: tablesFound,
      );
    } catch (e) {
      rawDb?.dispose();
      if (tempVerificationFile != null && await tempVerificationFile.exists()) {
        await tempVerificationFile.delete();
      }
      return GoogleDriveBackupVerificationResult.failure(
        'Remote backup SQLite verification error: $e',
      );
    }
  }
}
