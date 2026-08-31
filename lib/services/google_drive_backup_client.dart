import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

/// Result of an upload operation to Google Drive.
class GoogleDriveUploadResult {
  final String driveFileId;
  final String fileName;
  final int fileSizeBytes;
  final String folderId;
  final DateTime uploadedAt;

  const GoogleDriveUploadResult({
    required this.driveFileId,
    required this.fileName,
    required this.fileSizeBytes,
    required this.folderId,
    required this.uploadedAt,
  });
}

/// Result of validating an uploaded SQLite database on Google Drive.
class GoogleDriveBackupVerificationResult {
  final bool isVerified;
  final bool integrityCheckPassed;
  final bool foreignKeyCheckPassed;
  final List<String> tablesFound;
  final String? errorMessage;

  const GoogleDriveBackupVerificationResult({
    required this.isVerified,
    required this.integrityCheckPassed,
    required this.foreignKeyCheckPassed,
    required this.tablesFound,
    this.errorMessage,
  });

  factory GoogleDriveBackupVerificationResult.failure(String error) {
    return GoogleDriveBackupVerificationResult(
      isVerified: false,
      integrityCheckPassed: false,
      foreignKeyCheckPassed: false,
      tablesFound: const [],
      errorMessage: error,
    );
  }
}

/// Client interface for uploading and independently verifying database backups on Google Drive.
abstract class GoogleDriveBackupClient {
  /// Checks whether the user is currently authenticated with Google Drive.
  Future<bool> isAuthenticated();

  /// Verifies that the designated Google Drive backup folder exists and is accessible to the account.
  Future<bool> verifyFolderAccess({required String folderId});

  /// Resolves an existing subfolder inside a parent folder, or creates it if it doesn't exist.
  Future<String> resolveSubfolderId({
    required String parentFolderId,
    required String subfolderName,
  });

  /// Uploads a local SQLite `.db` snapshot file to the designated Google Drive folder.
  Future<GoogleDriveUploadResult> uploadBackupFile({
    required File localFile,
    required String folderId,
    required String fileName,
  });

  /// Downloads/inspects the uploaded backup from Google Drive and verifies it as a valid SQLite database.
  /// Verification asserts:
  /// 1. File exists and size matches
  /// 2. Database can be opened as SQLite
  /// 3. All 9 required tables exist
  /// 4. PRAGMA integrity_check returns 'ok'
  /// 5. PRAGMA foreign_key_check returns 0 violations
  Future<GoogleDriveBackupVerificationResult> downloadAndVerifyBackup({
    required String driveFileId,
    required int expectedSizeBytes,
  });
}

/// Mock implementation used for deterministic unit and integration testing of
/// network failures, verification corruptions, folder access errors, and successful SQLite validations.
class MockGoogleDriveBackupClient implements GoogleDriveBackupClient {
  bool isUserAuthenticated;
  bool folderAccessGranted;
  bool shouldFailUpload;
  bool shouldFailVerification;
  bool corruptUploadedDb;

  final Directory mockCloudStorageDir;
  final Map<String, File> _storedDriveFiles = {};

  MockGoogleDriveBackupClient({
    required this.mockCloudStorageDir,
    this.isUserAuthenticated = true,
    this.folderAccessGranted = true,
    this.shouldFailUpload = false,
    this.shouldFailVerification = false,
    this.corruptUploadedDb = false,
  });

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

  @override
  Future<bool> isAuthenticated() async {
    return isUserAuthenticated;
  }

  @override
  Future<bool> verifyFolderAccess({required String folderId}) async {
    if (!isUserAuthenticated) return false;
    return folderAccessGranted;
  }

  @override
  Future<String> resolveSubfolderId({
    required String parentFolderId,
    required String subfolderName,
  }) async {
    if (!isUserAuthenticated) {
      throw const SocketException('Google Drive authentication required');
    }
    if (!folderAccessGranted) {
      throw StateError('Cannot access parent folder $parentFolderId');
    }
    final subfolderDir = Directory('${mockCloudStorageDir.path}${Platform.pathSeparator}$subfolderName');
    if (!await subfolderDir.exists()) {
      await subfolderDir.create(recursive: true);
    }
    return 'mock_subfolder_${parentFolderId}_$subfolderName';
  }

  @override
  Future<GoogleDriveUploadResult> uploadBackupFile({
    required File localFile,
    required String folderId,
    required String fileName,
  }) async {
    if (!isUserAuthenticated) {
      throw const SocketException('Google Drive authentication required');
    }

    if (!folderAccessGranted) {
      throw StateError('Cannot upload: Backup folder $folderId is inaccessible');
    }

    if (shouldFailUpload) {
      throw const SocketException('Mock Google Drive network error: Upload connection refused');
    }

    if (!await localFile.exists()) {
      throw StateError('Local backup file does not exist: ${localFile.path}');
    }

    if (!await mockCloudStorageDir.exists()) {
      await mockCloudStorageDir.create(recursive: true);
    }

    final driveFileId = 'gdrive_file_${DateTime.now().millisecondsSinceEpoch}_${localFile.uri.pathSegments.last}';
    final targetPath = '${mockCloudStorageDir.path}${Platform.pathSeparator}$driveFileId.db';
    final uploadedCopy = await localFile.copy(targetPath);

    if (corruptUploadedDb) {
      final raf = await uploadedCopy.open(mode: FileMode.write);
      await raf.writeString('CORRUPTED_SQLITE_HEADER_DATA_12345');
      await raf.close();
    }

    _storedDriveFiles[driveFileId] = uploadedCopy;

    return GoogleDriveUploadResult(
      driveFileId: driveFileId,
      fileName: fileName,
      fileSizeBytes: await uploadedCopy.length(),
      folderId: folderId,
      uploadedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<GoogleDriveBackupVerificationResult> downloadAndVerifyBackup({
    required String driveFileId,
    required int expectedSizeBytes,
  }) async {
    if (shouldFailVerification) {
      return GoogleDriveBackupVerificationResult.failure('Simulated Google Drive verification failure: Checksum mismatch');
    }

    final uploadedFile = _storedDriveFiles[driveFileId];
    if (uploadedFile == null || !await uploadedFile.exists()) {
      return GoogleDriveBackupVerificationResult.failure('Uploaded file $driveFileId was not found in Google Drive');
    }

    // Full SQLite Database Inspection
    Database? rawDb;
    try {
      rawDb = sqlite3.open(uploadedFile.path);

      // 1. Verify PRAGMA integrity_check
      final integrityResult = rawDb.select('PRAGMA integrity_check;');
      final integrityStatus = integrityResult.first['integrity_check'] as String? ?? '';
      if (integrityStatus.toLowerCase() != 'ok') {
        rawDb.dispose();
        return GoogleDriveBackupVerificationResult.failure('SQLite integrity check failed: $integrityStatus');
      }

      // 2. Verify all 9 expected tables exist
      final tablesResult = rawDb.select("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';");
      final tablesFound = tablesResult.map((r) => r['name'] as String).toList();

      for (final req in requiredTables) {
        if (!tablesFound.contains(req)) {
          rawDb.dispose();
          return GoogleDriveBackupVerificationResult.failure('Missing required table: $req in uploaded database');
        }
      }

      // 3. Verify PRAGMA foreign_key_check
      final fkResult = rawDb.select('PRAGMA foreign_key_check;');
      if (fkResult.isNotEmpty) {
        rawDb.dispose();
        return GoogleDriveBackupVerificationResult.failure('Foreign-key check failed with ${fkResult.length} violation(s)');
      }

      rawDb.dispose();

      return GoogleDriveBackupVerificationResult(
        isVerified: true,
        integrityCheckPassed: true,
        foreignKeyCheckPassed: true,
        tablesFound: tablesFound,
      );
    } catch (e) {
      rawDb?.dispose();
      return GoogleDriveBackupVerificationResult.failure('SQLite verification exception: $e');
    }
  }
}
