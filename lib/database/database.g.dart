// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FactoriesTable extends Factories
    with TableInfo<$FactoriesTable, FactoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FactoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _factoryCodeMeta = const VerificationMeta(
    'factoryCode',
  );
  @override
  late final GeneratedColumn<String> factoryCode = GeneratedColumn<String>(
    'factory_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _factoryNameMeta = const VerificationMeta(
    'factoryName',
  );
  @override
  late final GeneratedColumn<String> factoryName = GeneratedColumn<String>(
    'factory_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _driveFolderIdMeta = const VerificationMeta(
    'driveFolderId',
  );
  @override
  late final GeneratedColumn<String> driveFolderId = GeneratedColumn<String>(
    'drive_folder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    factoryCode,
    factoryName,
    driveFolderId,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'factories';
  @override
  VerificationContext validateIntegrity(
    Insertable<FactoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('factory_code')) {
      context.handle(
        _factoryCodeMeta,
        factoryCode.isAcceptableOrUnknown(
          data['factory_code']!,
          _factoryCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_factoryCodeMeta);
    }
    if (data.containsKey('factory_name')) {
      context.handle(
        _factoryNameMeta,
        factoryName.isAcceptableOrUnknown(
          data['factory_name']!,
          _factoryNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_factoryNameMeta);
    }
    if (data.containsKey('drive_folder_id')) {
      context.handle(
        _driveFolderIdMeta,
        driveFolderId.isAcceptableOrUnknown(
          data['drive_folder_id']!,
          _driveFolderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_driveFolderIdMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FactoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FactoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      factoryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}factory_code'],
      )!,
      factoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}factory_name'],
      )!,
      driveFolderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drive_folder_id'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FactoriesTable createAlias(String alias) {
    return $FactoriesTable(attachedDatabase, alias);
  }
}

class FactoryData extends DataClass implements Insertable<FactoryData> {
  final int id;
  final String factoryCode;
  final String factoryName;
  final String driveFolderId;
  final bool isActive;
  final DateTime createdAt;
  const FactoryData({
    required this.id,
    required this.factoryCode,
    required this.factoryName,
    required this.driveFolderId,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['factory_code'] = Variable<String>(factoryCode);
    map['factory_name'] = Variable<String>(factoryName);
    map['drive_folder_id'] = Variable<String>(driveFolderId);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FactoriesCompanion toCompanion(bool nullToAbsent) {
    return FactoriesCompanion(
      id: Value(id),
      factoryCode: Value(factoryCode),
      factoryName: Value(factoryName),
      driveFolderId: Value(driveFolderId),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory FactoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FactoryData(
      id: serializer.fromJson<int>(json['id']),
      factoryCode: serializer.fromJson<String>(json['factoryCode']),
      factoryName: serializer.fromJson<String>(json['factoryName']),
      driveFolderId: serializer.fromJson<String>(json['driveFolderId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'factoryCode': serializer.toJson<String>(factoryCode),
      'factoryName': serializer.toJson<String>(factoryName),
      'driveFolderId': serializer.toJson<String>(driveFolderId),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FactoryData copyWith({
    int? id,
    String? factoryCode,
    String? factoryName,
    String? driveFolderId,
    bool? isActive,
    DateTime? createdAt,
  }) => FactoryData(
    id: id ?? this.id,
    factoryCode: factoryCode ?? this.factoryCode,
    factoryName: factoryName ?? this.factoryName,
    driveFolderId: driveFolderId ?? this.driveFolderId,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  FactoryData copyWithCompanion(FactoriesCompanion data) {
    return FactoryData(
      id: data.id.present ? data.id.value : this.id,
      factoryCode: data.factoryCode.present
          ? data.factoryCode.value
          : this.factoryCode,
      factoryName: data.factoryName.present
          ? data.factoryName.value
          : this.factoryName,
      driveFolderId: data.driveFolderId.present
          ? data.driveFolderId.value
          : this.driveFolderId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FactoryData(')
          ..write('id: $id, ')
          ..write('factoryCode: $factoryCode, ')
          ..write('factoryName: $factoryName, ')
          ..write('driveFolderId: $driveFolderId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    factoryCode,
    factoryName,
    driveFolderId,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FactoryData &&
          other.id == this.id &&
          other.factoryCode == this.factoryCode &&
          other.factoryName == this.factoryName &&
          other.driveFolderId == this.driveFolderId &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class FactoriesCompanion extends UpdateCompanion<FactoryData> {
  final Value<int> id;
  final Value<String> factoryCode;
  final Value<String> factoryName;
  final Value<String> driveFolderId;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const FactoriesCompanion({
    this.id = const Value.absent(),
    this.factoryCode = const Value.absent(),
    this.factoryName = const Value.absent(),
    this.driveFolderId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FactoriesCompanion.insert({
    this.id = const Value.absent(),
    required String factoryCode,
    required String factoryName,
    required String driveFolderId,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : factoryCode = Value(factoryCode),
       factoryName = Value(factoryName),
       driveFolderId = Value(driveFolderId);
  static Insertable<FactoryData> custom({
    Expression<int>? id,
    Expression<String>? factoryCode,
    Expression<String>? factoryName,
    Expression<String>? driveFolderId,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (factoryCode != null) 'factory_code': factoryCode,
      if (factoryName != null) 'factory_name': factoryName,
      if (driveFolderId != null) 'drive_folder_id': driveFolderId,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FactoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? factoryCode,
    Value<String>? factoryName,
    Value<String>? driveFolderId,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return FactoriesCompanion(
      id: id ?? this.id,
      factoryCode: factoryCode ?? this.factoryCode,
      factoryName: factoryName ?? this.factoryName,
      driveFolderId: driveFolderId ?? this.driveFolderId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (factoryCode.present) {
      map['factory_code'] = Variable<String>(factoryCode.value);
    }
    if (factoryName.present) {
      map['factory_name'] = Variable<String>(factoryName.value);
    }
    if (driveFolderId.present) {
      map['drive_folder_id'] = Variable<String>(driveFolderId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FactoriesCompanion(')
          ..write('id: $id, ')
          ..write('factoryCode: $factoryCode, ')
          ..write('factoryName: $factoryName, ')
          ..write('driveFolderId: $driveFolderId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $InputFilesTable extends InputFiles
    with TableInfo<$InputFilesTable, InputFileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InputFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _factoryIdMeta = const VerificationMeta(
    'factoryId',
  );
  @override
  late final GeneratedColumn<int> factoryId = GeneratedColumn<int>(
    'factory_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES factories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _driveFileIdMeta = const VerificationMeta(
    'driveFileId',
  );
  @override
  late final GeneratedColumn<String> driveFileId = GeneratedColumn<String>(
    'drive_file_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileTypeMeta = const VerificationMeta(
    'fileType',
  );
  @override
  late final GeneratedColumn<String> fileType = GeneratedColumn<String>(
    'file_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<BigInt> fileSizeBytes = GeneratedColumn<BigInt>(
    'file_size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _driveModifiedAtMeta = const VerificationMeta(
    'driveModifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> driveModifiedAt =
      GeneratedColumn<DateTime>(
        'drive_modified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fileHashMeta = const VerificationMeta(
    'fileHash',
  );
  @override
  late final GeneratedColumn<String> fileHash = GeneratedColumn<String>(
    'file_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstSeenAtMeta = const VerificationMeta(
    'firstSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstSeenAt = GeneratedColumn<DateTime>(
    'first_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastProcessedAtMeta = const VerificationMeta(
    'lastProcessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastProcessedAt =
      GeneratedColumn<DateTime>(
        'last_processed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    factoryId,
    driveFileId,
    fileName,
    fileType,
    fileSizeBytes,
    driveModifiedAt,
    fileHash,
    status,
    firstSeenAt,
    lastSeenAt,
    lastProcessedAt,
    errorMessage,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'input_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<InputFileData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('factory_id')) {
      context.handle(
        _factoryIdMeta,
        factoryId.isAcceptableOrUnknown(data['factory_id']!, _factoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_factoryIdMeta);
    }
    if (data.containsKey('drive_file_id')) {
      context.handle(
        _driveFileIdMeta,
        driveFileId.isAcceptableOrUnknown(
          data['drive_file_id']!,
          _driveFileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_driveFileIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_type')) {
      context.handle(
        _fileTypeMeta,
        fileType.isAcceptableOrUnknown(data['file_type']!, _fileTypeMeta),
      );
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
        ),
      );
    }
    if (data.containsKey('drive_modified_at')) {
      context.handle(
        _driveModifiedAtMeta,
        driveModifiedAt.isAcceptableOrUnknown(
          data['drive_modified_at']!,
          _driveModifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('file_hash')) {
      context.handle(
        _fileHashMeta,
        fileHash.isAcceptableOrUnknown(data['file_hash']!, _fileHashMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(
        _firstSeenAtMeta,
        firstSeenAt.isAcceptableOrUnknown(
          data['first_seen_at']!,
          _firstSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('last_processed_at')) {
      context.handle(
        _lastProcessedAtMeta,
        lastProcessedAt.isAcceptableOrUnknown(
          data['last_processed_at']!,
          _lastProcessedAtMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {factoryId, driveFileId},
  ];
  @override
  InputFileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InputFileData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      factoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}factory_id'],
      )!,
      driveFileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drive_file_id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      fileType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_type'],
      ),
      fileSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}file_size_bytes'],
      ),
      driveModifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}drive_modified_at'],
      ),
      fileHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_hash'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      firstSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_seen_at'],
      ),
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      ),
      lastProcessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_processed_at'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InputFilesTable createAlias(String alias) {
    return $InputFilesTable(attachedDatabase, alias);
  }
}

class InputFileData extends DataClass implements Insertable<InputFileData> {
  final int id;
  final int factoryId;
  final String driveFileId;
  final String fileName;
  final String? fileType;
  final BigInt? fileSizeBytes;
  final DateTime? driveModifiedAt;
  final String? fileHash;
  final String status;
  final DateTime? firstSeenAt;
  final DateTime? lastSeenAt;
  final DateTime? lastProcessedAt;
  final String? errorMessage;
  final DateTime createdAt;
  const InputFileData({
    required this.id,
    required this.factoryId,
    required this.driveFileId,
    required this.fileName,
    this.fileType,
    this.fileSizeBytes,
    this.driveModifiedAt,
    this.fileHash,
    required this.status,
    this.firstSeenAt,
    this.lastSeenAt,
    this.lastProcessedAt,
    this.errorMessage,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['factory_id'] = Variable<int>(factoryId);
    map['drive_file_id'] = Variable<String>(driveFileId);
    map['file_name'] = Variable<String>(fileName);
    if (!nullToAbsent || fileType != null) {
      map['file_type'] = Variable<String>(fileType);
    }
    if (!nullToAbsent || fileSizeBytes != null) {
      map['file_size_bytes'] = Variable<BigInt>(fileSizeBytes);
    }
    if (!nullToAbsent || driveModifiedAt != null) {
      map['drive_modified_at'] = Variable<DateTime>(driveModifiedAt);
    }
    if (!nullToAbsent || fileHash != null) {
      map['file_hash'] = Variable<String>(fileHash);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || firstSeenAt != null) {
      map['first_seen_at'] = Variable<DateTime>(firstSeenAt);
    }
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    if (!nullToAbsent || lastProcessedAt != null) {
      map['last_processed_at'] = Variable<DateTime>(lastProcessedAt);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InputFilesCompanion toCompanion(bool nullToAbsent) {
    return InputFilesCompanion(
      id: Value(id),
      factoryId: Value(factoryId),
      driveFileId: Value(driveFileId),
      fileName: Value(fileName),
      fileType: fileType == null && nullToAbsent
          ? const Value.absent()
          : Value(fileType),
      fileSizeBytes: fileSizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSizeBytes),
      driveModifiedAt: driveModifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(driveModifiedAt),
      fileHash: fileHash == null && nullToAbsent
          ? const Value.absent()
          : Value(fileHash),
      status: Value(status),
      firstSeenAt: firstSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firstSeenAt),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      lastProcessedAt: lastProcessedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastProcessedAt),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
    );
  }

  factory InputFileData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InputFileData(
      id: serializer.fromJson<int>(json['id']),
      factoryId: serializer.fromJson<int>(json['factoryId']),
      driveFileId: serializer.fromJson<String>(json['driveFileId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      fileType: serializer.fromJson<String?>(json['fileType']),
      fileSizeBytes: serializer.fromJson<BigInt?>(json['fileSizeBytes']),
      driveModifiedAt: serializer.fromJson<DateTime?>(json['driveModifiedAt']),
      fileHash: serializer.fromJson<String?>(json['fileHash']),
      status: serializer.fromJson<String>(json['status']),
      firstSeenAt: serializer.fromJson<DateTime?>(json['firstSeenAt']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
      lastProcessedAt: serializer.fromJson<DateTime?>(json['lastProcessedAt']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'factoryId': serializer.toJson<int>(factoryId),
      'driveFileId': serializer.toJson<String>(driveFileId),
      'fileName': serializer.toJson<String>(fileName),
      'fileType': serializer.toJson<String?>(fileType),
      'fileSizeBytes': serializer.toJson<BigInt?>(fileSizeBytes),
      'driveModifiedAt': serializer.toJson<DateTime?>(driveModifiedAt),
      'fileHash': serializer.toJson<String?>(fileHash),
      'status': serializer.toJson<String>(status),
      'firstSeenAt': serializer.toJson<DateTime?>(firstSeenAt),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
      'lastProcessedAt': serializer.toJson<DateTime?>(lastProcessedAt),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InputFileData copyWith({
    int? id,
    int? factoryId,
    String? driveFileId,
    String? fileName,
    Value<String?> fileType = const Value.absent(),
    Value<BigInt?> fileSizeBytes = const Value.absent(),
    Value<DateTime?> driveModifiedAt = const Value.absent(),
    Value<String?> fileHash = const Value.absent(),
    String? status,
    Value<DateTime?> firstSeenAt = const Value.absent(),
    Value<DateTime?> lastSeenAt = const Value.absent(),
    Value<DateTime?> lastProcessedAt = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    DateTime? createdAt,
  }) => InputFileData(
    id: id ?? this.id,
    factoryId: factoryId ?? this.factoryId,
    driveFileId: driveFileId ?? this.driveFileId,
    fileName: fileName ?? this.fileName,
    fileType: fileType.present ? fileType.value : this.fileType,
    fileSizeBytes: fileSizeBytes.present
        ? fileSizeBytes.value
        : this.fileSizeBytes,
    driveModifiedAt: driveModifiedAt.present
        ? driveModifiedAt.value
        : this.driveModifiedAt,
    fileHash: fileHash.present ? fileHash.value : this.fileHash,
    status: status ?? this.status,
    firstSeenAt: firstSeenAt.present ? firstSeenAt.value : this.firstSeenAt,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
    lastProcessedAt: lastProcessedAt.present
        ? lastProcessedAt.value
        : this.lastProcessedAt,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    createdAt: createdAt ?? this.createdAt,
  );
  InputFileData copyWithCompanion(InputFilesCompanion data) {
    return InputFileData(
      id: data.id.present ? data.id.value : this.id,
      factoryId: data.factoryId.present ? data.factoryId.value : this.factoryId,
      driveFileId: data.driveFileId.present
          ? data.driveFileId.value
          : this.driveFileId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      fileType: data.fileType.present ? data.fileType.value : this.fileType,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      driveModifiedAt: data.driveModifiedAt.present
          ? data.driveModifiedAt.value
          : this.driveModifiedAt,
      fileHash: data.fileHash.present ? data.fileHash.value : this.fileHash,
      status: data.status.present ? data.status.value : this.status,
      firstSeenAt: data.firstSeenAt.present
          ? data.firstSeenAt.value
          : this.firstSeenAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      lastProcessedAt: data.lastProcessedAt.present
          ? data.lastProcessedAt.value
          : this.lastProcessedAt,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InputFileData(')
          ..write('id: $id, ')
          ..write('factoryId: $factoryId, ')
          ..write('driveFileId: $driveFileId, ')
          ..write('fileName: $fileName, ')
          ..write('fileType: $fileType, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('driveModifiedAt: $driveModifiedAt, ')
          ..write('fileHash: $fileHash, ')
          ..write('status: $status, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('lastProcessedAt: $lastProcessedAt, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    factoryId,
    driveFileId,
    fileName,
    fileType,
    fileSizeBytes,
    driveModifiedAt,
    fileHash,
    status,
    firstSeenAt,
    lastSeenAt,
    lastProcessedAt,
    errorMessage,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InputFileData &&
          other.id == this.id &&
          other.factoryId == this.factoryId &&
          other.driveFileId == this.driveFileId &&
          other.fileName == this.fileName &&
          other.fileType == this.fileType &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.driveModifiedAt == this.driveModifiedAt &&
          other.fileHash == this.fileHash &&
          other.status == this.status &&
          other.firstSeenAt == this.firstSeenAt &&
          other.lastSeenAt == this.lastSeenAt &&
          other.lastProcessedAt == this.lastProcessedAt &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt);
}

class InputFilesCompanion extends UpdateCompanion<InputFileData> {
  final Value<int> id;
  final Value<int> factoryId;
  final Value<String> driveFileId;
  final Value<String> fileName;
  final Value<String?> fileType;
  final Value<BigInt?> fileSizeBytes;
  final Value<DateTime?> driveModifiedAt;
  final Value<String?> fileHash;
  final Value<String> status;
  final Value<DateTime?> firstSeenAt;
  final Value<DateTime?> lastSeenAt;
  final Value<DateTime?> lastProcessedAt;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  const InputFilesCompanion({
    this.id = const Value.absent(),
    this.factoryId = const Value.absent(),
    this.driveFileId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileType = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.driveModifiedAt = const Value.absent(),
    this.fileHash = const Value.absent(),
    this.status = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.lastProcessedAt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  InputFilesCompanion.insert({
    this.id = const Value.absent(),
    required int factoryId,
    required String driveFileId,
    required String fileName,
    this.fileType = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.driveModifiedAt = const Value.absent(),
    this.fileHash = const Value.absent(),
    required String status,
    this.firstSeenAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.lastProcessedAt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : factoryId = Value(factoryId),
       driveFileId = Value(driveFileId),
       fileName = Value(fileName),
       status = Value(status);
  static Insertable<InputFileData> custom({
    Expression<int>? id,
    Expression<int>? factoryId,
    Expression<String>? driveFileId,
    Expression<String>? fileName,
    Expression<String>? fileType,
    Expression<BigInt>? fileSizeBytes,
    Expression<DateTime>? driveModifiedAt,
    Expression<String>? fileHash,
    Expression<String>? status,
    Expression<DateTime>? firstSeenAt,
    Expression<DateTime>? lastSeenAt,
    Expression<DateTime>? lastProcessedAt,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (factoryId != null) 'factory_id': factoryId,
      if (driveFileId != null) 'drive_file_id': driveFileId,
      if (fileName != null) 'file_name': fileName,
      if (fileType != null) 'file_type': fileType,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (driveModifiedAt != null) 'drive_modified_at': driveModifiedAt,
      if (fileHash != null) 'file_hash': fileHash,
      if (status != null) 'status': status,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (lastProcessedAt != null) 'last_processed_at': lastProcessedAt,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  InputFilesCompanion copyWith({
    Value<int>? id,
    Value<int>? factoryId,
    Value<String>? driveFileId,
    Value<String>? fileName,
    Value<String?>? fileType,
    Value<BigInt?>? fileSizeBytes,
    Value<DateTime?>? driveModifiedAt,
    Value<String?>? fileHash,
    Value<String>? status,
    Value<DateTime?>? firstSeenAt,
    Value<DateTime?>? lastSeenAt,
    Value<DateTime?>? lastProcessedAt,
    Value<String?>? errorMessage,
    Value<DateTime>? createdAt,
  }) {
    return InputFilesCompanion(
      id: id ?? this.id,
      factoryId: factoryId ?? this.factoryId,
      driveFileId: driveFileId ?? this.driveFileId,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      driveModifiedAt: driveModifiedAt ?? this.driveModifiedAt,
      fileHash: fileHash ?? this.fileHash,
      status: status ?? this.status,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      lastProcessedAt: lastProcessedAt ?? this.lastProcessedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (factoryId.present) {
      map['factory_id'] = Variable<int>(factoryId.value);
    }
    if (driveFileId.present) {
      map['drive_file_id'] = Variable<String>(driveFileId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (fileType.present) {
      map['file_type'] = Variable<String>(fileType.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<BigInt>(fileSizeBytes.value);
    }
    if (driveModifiedAt.present) {
      map['drive_modified_at'] = Variable<DateTime>(driveModifiedAt.value);
    }
    if (fileHash.present) {
      map['file_hash'] = Variable<String>(fileHash.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<DateTime>(firstSeenAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (lastProcessedAt.present) {
      map['last_processed_at'] = Variable<DateTime>(lastProcessedAt.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InputFilesCompanion(')
          ..write('id: $id, ')
          ..write('factoryId: $factoryId, ')
          ..write('driveFileId: $driveFileId, ')
          ..write('fileName: $fileName, ')
          ..write('fileType: $fileType, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('driveModifiedAt: $driveModifiedAt, ')
          ..write('fileHash: $fileHash, ')
          ..write('status: $status, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('lastProcessedAt: $lastProcessedAt, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BatchesTable extends Batches with TableInfo<$BatchesTable, BatchData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _factoryIdMeta = const VerificationMeta(
    'factoryId',
  );
  @override
  late final GeneratedColumn<int> factoryId = GeneratedColumn<int>(
    'factory_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES factories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _inputFileIdMeta = const VerificationMeta(
    'inputFileId',
  );
  @override
  late final GeneratedColumn<int> inputFileId = GeneratedColumn<int>(
    'input_file_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES input_files (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fermenterMeta = const VerificationMeta(
    'fermenter',
  );
  @override
  late final GeneratedColumn<String> fermenter = GeneratedColumn<String>(
    'fermenter',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchStartTimeMeta = const VerificationMeta(
    'batchStartTime',
  );
  @override
  late final GeneratedColumn<DateTime> batchStartTime =
      GeneratedColumn<DateTime>(
        'batch_start_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _batchEndTimeMeta = const VerificationMeta(
    'batchEndTime',
  );
  @override
  late final GeneratedColumn<DateTime> batchEndTime = GeneratedColumn<DateTime>(
    'batch_end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    factoryId,
    inputFileId,
    batchId,
    fermenter,
    state,
    batchStartTime,
    batchEndTime,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<BatchData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('factory_id')) {
      context.handle(
        _factoryIdMeta,
        factoryId.isAcceptableOrUnknown(data['factory_id']!, _factoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_factoryIdMeta);
    }
    if (data.containsKey('input_file_id')) {
      context.handle(
        _inputFileIdMeta,
        inputFileId.isAcceptableOrUnknown(
          data['input_file_id']!,
          _inputFileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inputFileIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('fermenter')) {
      context.handle(
        _fermenterMeta,
        fermenter.isAcceptableOrUnknown(data['fermenter']!, _fermenterMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('batch_start_time')) {
      context.handle(
        _batchStartTimeMeta,
        batchStartTime.isAcceptableOrUnknown(
          data['batch_start_time']!,
          _batchStartTimeMeta,
        ),
      );
    }
    if (data.containsKey('batch_end_time')) {
      context.handle(
        _batchEndTimeMeta,
        batchEndTime.isAcceptableOrUnknown(
          data['batch_end_time']!,
          _batchEndTimeMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BatchData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BatchData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      factoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}factory_id'],
      )!,
      inputFileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}input_file_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      fermenter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fermenter'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      ),
      batchStartTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}batch_start_time'],
      ),
      batchEndTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}batch_end_time'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BatchesTable createAlias(String alias) {
    return $BatchesTable(attachedDatabase, alias);
  }
}

class BatchData extends DataClass implements Insertable<BatchData> {
  final int id;
  final int factoryId;
  final int inputFileId;
  final String batchId;
  final String? fermenter;
  final String? state;
  final DateTime? batchStartTime;
  final DateTime? batchEndTime;
  final DateTime createdAt;
  const BatchData({
    required this.id,
    required this.factoryId,
    required this.inputFileId,
    required this.batchId,
    this.fermenter,
    this.state,
    this.batchStartTime,
    this.batchEndTime,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['factory_id'] = Variable<int>(factoryId);
    map['input_file_id'] = Variable<int>(inputFileId);
    map['batch_id'] = Variable<String>(batchId);
    if (!nullToAbsent || fermenter != null) {
      map['fermenter'] = Variable<String>(fermenter);
    }
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    if (!nullToAbsent || batchStartTime != null) {
      map['batch_start_time'] = Variable<DateTime>(batchStartTime);
    }
    if (!nullToAbsent || batchEndTime != null) {
      map['batch_end_time'] = Variable<DateTime>(batchEndTime);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BatchesCompanion toCompanion(bool nullToAbsent) {
    return BatchesCompanion(
      id: Value(id),
      factoryId: Value(factoryId),
      inputFileId: Value(inputFileId),
      batchId: Value(batchId),
      fermenter: fermenter == null && nullToAbsent
          ? const Value.absent()
          : Value(fermenter),
      state: state == null && nullToAbsent
          ? const Value.absent()
          : Value(state),
      batchStartTime: batchStartTime == null && nullToAbsent
          ? const Value.absent()
          : Value(batchStartTime),
      batchEndTime: batchEndTime == null && nullToAbsent
          ? const Value.absent()
          : Value(batchEndTime),
      createdAt: Value(createdAt),
    );
  }

  factory BatchData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BatchData(
      id: serializer.fromJson<int>(json['id']),
      factoryId: serializer.fromJson<int>(json['factoryId']),
      inputFileId: serializer.fromJson<int>(json['inputFileId']),
      batchId: serializer.fromJson<String>(json['batchId']),
      fermenter: serializer.fromJson<String?>(json['fermenter']),
      state: serializer.fromJson<String?>(json['state']),
      batchStartTime: serializer.fromJson<DateTime?>(json['batchStartTime']),
      batchEndTime: serializer.fromJson<DateTime?>(json['batchEndTime']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'factoryId': serializer.toJson<int>(factoryId),
      'inputFileId': serializer.toJson<int>(inputFileId),
      'batchId': serializer.toJson<String>(batchId),
      'fermenter': serializer.toJson<String?>(fermenter),
      'state': serializer.toJson<String?>(state),
      'batchStartTime': serializer.toJson<DateTime?>(batchStartTime),
      'batchEndTime': serializer.toJson<DateTime?>(batchEndTime),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BatchData copyWith({
    int? id,
    int? factoryId,
    int? inputFileId,
    String? batchId,
    Value<String?> fermenter = const Value.absent(),
    Value<String?> state = const Value.absent(),
    Value<DateTime?> batchStartTime = const Value.absent(),
    Value<DateTime?> batchEndTime = const Value.absent(),
    DateTime? createdAt,
  }) => BatchData(
    id: id ?? this.id,
    factoryId: factoryId ?? this.factoryId,
    inputFileId: inputFileId ?? this.inputFileId,
    batchId: batchId ?? this.batchId,
    fermenter: fermenter.present ? fermenter.value : this.fermenter,
    state: state.present ? state.value : this.state,
    batchStartTime: batchStartTime.present
        ? batchStartTime.value
        : this.batchStartTime,
    batchEndTime: batchEndTime.present ? batchEndTime.value : this.batchEndTime,
    createdAt: createdAt ?? this.createdAt,
  );
  BatchData copyWithCompanion(BatchesCompanion data) {
    return BatchData(
      id: data.id.present ? data.id.value : this.id,
      factoryId: data.factoryId.present ? data.factoryId.value : this.factoryId,
      inputFileId: data.inputFileId.present
          ? data.inputFileId.value
          : this.inputFileId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      fermenter: data.fermenter.present ? data.fermenter.value : this.fermenter,
      state: data.state.present ? data.state.value : this.state,
      batchStartTime: data.batchStartTime.present
          ? data.batchStartTime.value
          : this.batchStartTime,
      batchEndTime: data.batchEndTime.present
          ? data.batchEndTime.value
          : this.batchEndTime,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BatchData(')
          ..write('id: $id, ')
          ..write('factoryId: $factoryId, ')
          ..write('inputFileId: $inputFileId, ')
          ..write('batchId: $batchId, ')
          ..write('fermenter: $fermenter, ')
          ..write('state: $state, ')
          ..write('batchStartTime: $batchStartTime, ')
          ..write('batchEndTime: $batchEndTime, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    factoryId,
    inputFileId,
    batchId,
    fermenter,
    state,
    batchStartTime,
    batchEndTime,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatchData &&
          other.id == this.id &&
          other.factoryId == this.factoryId &&
          other.inputFileId == this.inputFileId &&
          other.batchId == this.batchId &&
          other.fermenter == this.fermenter &&
          other.state == this.state &&
          other.batchStartTime == this.batchStartTime &&
          other.batchEndTime == this.batchEndTime &&
          other.createdAt == this.createdAt);
}

class BatchesCompanion extends UpdateCompanion<BatchData> {
  final Value<int> id;
  final Value<int> factoryId;
  final Value<int> inputFileId;
  final Value<String> batchId;
  final Value<String?> fermenter;
  final Value<String?> state;
  final Value<DateTime?> batchStartTime;
  final Value<DateTime?> batchEndTime;
  final Value<DateTime> createdAt;
  const BatchesCompanion({
    this.id = const Value.absent(),
    this.factoryId = const Value.absent(),
    this.inputFileId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.fermenter = const Value.absent(),
    this.state = const Value.absent(),
    this.batchStartTime = const Value.absent(),
    this.batchEndTime = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BatchesCompanion.insert({
    this.id = const Value.absent(),
    required int factoryId,
    required int inputFileId,
    required String batchId,
    this.fermenter = const Value.absent(),
    this.state = const Value.absent(),
    this.batchStartTime = const Value.absent(),
    this.batchEndTime = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : factoryId = Value(factoryId),
       inputFileId = Value(inputFileId),
       batchId = Value(batchId);
  static Insertable<BatchData> custom({
    Expression<int>? id,
    Expression<int>? factoryId,
    Expression<int>? inputFileId,
    Expression<String>? batchId,
    Expression<String>? fermenter,
    Expression<String>? state,
    Expression<DateTime>? batchStartTime,
    Expression<DateTime>? batchEndTime,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (factoryId != null) 'factory_id': factoryId,
      if (inputFileId != null) 'input_file_id': inputFileId,
      if (batchId != null) 'batch_id': batchId,
      if (fermenter != null) 'fermenter': fermenter,
      if (state != null) 'state': state,
      if (batchStartTime != null) 'batch_start_time': batchStartTime,
      if (batchEndTime != null) 'batch_end_time': batchEndTime,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BatchesCompanion copyWith({
    Value<int>? id,
    Value<int>? factoryId,
    Value<int>? inputFileId,
    Value<String>? batchId,
    Value<String?>? fermenter,
    Value<String?>? state,
    Value<DateTime?>? batchStartTime,
    Value<DateTime?>? batchEndTime,
    Value<DateTime>? createdAt,
  }) {
    return BatchesCompanion(
      id: id ?? this.id,
      factoryId: factoryId ?? this.factoryId,
      inputFileId: inputFileId ?? this.inputFileId,
      batchId: batchId ?? this.batchId,
      fermenter: fermenter ?? this.fermenter,
      state: state ?? this.state,
      batchStartTime: batchStartTime ?? this.batchStartTime,
      batchEndTime: batchEndTime ?? this.batchEndTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (factoryId.present) {
      map['factory_id'] = Variable<int>(factoryId.value);
    }
    if (inputFileId.present) {
      map['input_file_id'] = Variable<int>(inputFileId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (fermenter.present) {
      map['fermenter'] = Variable<String>(fermenter.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (batchStartTime.present) {
      map['batch_start_time'] = Variable<DateTime>(batchStartTime.value);
    }
    if (batchEndTime.present) {
      map['batch_end_time'] = Variable<DateTime>(batchEndTime.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatchesCompanion(')
          ..write('id: $id, ')
          ..write('factoryId: $factoryId, ')
          ..write('inputFileId: $inputFileId, ')
          ..write('batchId: $batchId, ')
          ..write('fermenter: $fermenter, ')
          ..write('state: $state, ')
          ..write('batchStartTime: $batchStartTime, ')
          ..write('batchEndTime: $batchEndTime, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AiModelsTable extends AiModels
    with TableInfo<$AiModelsTable, AiModelData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelTypeMeta = const VerificationMeta(
    'modelType',
  );
  @override
  late final GeneratedColumn<String> modelType = GeneratedColumn<String>(
    'model_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelPathMeta = const VerificationMeta(
    'modelPath',
  );
  @override
  late final GeneratedColumn<String> modelPath = GeneratedColumn<String>(
    'model_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trainedAtMeta = const VerificationMeta(
    'trainedAt',
  );
  @override
  late final GeneratedColumn<DateTime> trainedAt = GeneratedColumn<DateTime>(
    'trained_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    modelName,
    modelVersion,
    modelType,
    modelPath,
    trainedAt,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_models';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiModelData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('model_type')) {
      context.handle(
        _modelTypeMeta,
        modelType.isAcceptableOrUnknown(data['model_type']!, _modelTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_modelTypeMeta);
    }
    if (data.containsKey('model_path')) {
      context.handle(
        _modelPathMeta,
        modelPath.isAcceptableOrUnknown(data['model_path']!, _modelPathMeta),
      );
    }
    if (data.containsKey('trained_at')) {
      context.handle(
        _trainedAtMeta,
        trainedAt.isAcceptableOrUnknown(data['trained_at']!, _trainedAtMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiModelData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiModelData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
      modelType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_type'],
      )!,
      modelPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_path'],
      ),
      trainedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}trained_at'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AiModelsTable createAlias(String alias) {
    return $AiModelsTable(attachedDatabase, alias);
  }
}

class AiModelData extends DataClass implements Insertable<AiModelData> {
  final int id;
  final String modelName;
  final String modelVersion;
  final String modelType;
  final String? modelPath;
  final DateTime? trainedAt;
  final bool isActive;
  final DateTime createdAt;
  const AiModelData({
    required this.id,
    required this.modelName,
    required this.modelVersion,
    required this.modelType,
    this.modelPath,
    this.trainedAt,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['model_name'] = Variable<String>(modelName);
    map['model_version'] = Variable<String>(modelVersion);
    map['model_type'] = Variable<String>(modelType);
    if (!nullToAbsent || modelPath != null) {
      map['model_path'] = Variable<String>(modelPath);
    }
    if (!nullToAbsent || trainedAt != null) {
      map['trained_at'] = Variable<DateTime>(trainedAt);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AiModelsCompanion toCompanion(bool nullToAbsent) {
    return AiModelsCompanion(
      id: Value(id),
      modelName: Value(modelName),
      modelVersion: Value(modelVersion),
      modelType: Value(modelType),
      modelPath: modelPath == null && nullToAbsent
          ? const Value.absent()
          : Value(modelPath),
      trainedAt: trainedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(trainedAt),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory AiModelData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiModelData(
      id: serializer.fromJson<int>(json['id']),
      modelName: serializer.fromJson<String>(json['modelName']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      modelType: serializer.fromJson<String>(json['modelType']),
      modelPath: serializer.fromJson<String?>(json['modelPath']),
      trainedAt: serializer.fromJson<DateTime?>(json['trainedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'modelName': serializer.toJson<String>(modelName),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'modelType': serializer.toJson<String>(modelType),
      'modelPath': serializer.toJson<String?>(modelPath),
      'trainedAt': serializer.toJson<DateTime?>(trainedAt),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AiModelData copyWith({
    int? id,
    String? modelName,
    String? modelVersion,
    String? modelType,
    Value<String?> modelPath = const Value.absent(),
    Value<DateTime?> trainedAt = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
  }) => AiModelData(
    id: id ?? this.id,
    modelName: modelName ?? this.modelName,
    modelVersion: modelVersion ?? this.modelVersion,
    modelType: modelType ?? this.modelType,
    modelPath: modelPath.present ? modelPath.value : this.modelPath,
    trainedAt: trainedAt.present ? trainedAt.value : this.trainedAt,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  AiModelData copyWithCompanion(AiModelsCompanion data) {
    return AiModelData(
      id: data.id.present ? data.id.value : this.id,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      modelType: data.modelType.present ? data.modelType.value : this.modelType,
      modelPath: data.modelPath.present ? data.modelPath.value : this.modelPath,
      trainedAt: data.trainedAt.present ? data.trainedAt.value : this.trainedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiModelData(')
          ..write('id: $id, ')
          ..write('modelName: $modelName, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('modelType: $modelType, ')
          ..write('modelPath: $modelPath, ')
          ..write('trainedAt: $trainedAt, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    modelName,
    modelVersion,
    modelType,
    modelPath,
    trainedAt,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiModelData &&
          other.id == this.id &&
          other.modelName == this.modelName &&
          other.modelVersion == this.modelVersion &&
          other.modelType == this.modelType &&
          other.modelPath == this.modelPath &&
          other.trainedAt == this.trainedAt &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class AiModelsCompanion extends UpdateCompanion<AiModelData> {
  final Value<int> id;
  final Value<String> modelName;
  final Value<String> modelVersion;
  final Value<String> modelType;
  final Value<String?> modelPath;
  final Value<DateTime?> trainedAt;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const AiModelsCompanion({
    this.id = const Value.absent(),
    this.modelName = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.modelType = const Value.absent(),
    this.modelPath = const Value.absent(),
    this.trainedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AiModelsCompanion.insert({
    this.id = const Value.absent(),
    required String modelName,
    required String modelVersion,
    required String modelType,
    this.modelPath = const Value.absent(),
    this.trainedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : modelName = Value(modelName),
       modelVersion = Value(modelVersion),
       modelType = Value(modelType);
  static Insertable<AiModelData> custom({
    Expression<int>? id,
    Expression<String>? modelName,
    Expression<String>? modelVersion,
    Expression<String>? modelType,
    Expression<String>? modelPath,
    Expression<DateTime>? trainedAt,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modelName != null) 'model_name': modelName,
      if (modelVersion != null) 'model_version': modelVersion,
      if (modelType != null) 'model_type': modelType,
      if (modelPath != null) 'model_path': modelPath,
      if (trainedAt != null) 'trained_at': trainedAt,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AiModelsCompanion copyWith({
    Value<int>? id,
    Value<String>? modelName,
    Value<String>? modelVersion,
    Value<String>? modelType,
    Value<String?>? modelPath,
    Value<DateTime?>? trainedAt,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return AiModelsCompanion(
      id: id ?? this.id,
      modelName: modelName ?? this.modelName,
      modelVersion: modelVersion ?? this.modelVersion,
      modelType: modelType ?? this.modelType,
      modelPath: modelPath ?? this.modelPath,
      trainedAt: trainedAt ?? this.trainedAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (modelType.present) {
      map['model_type'] = Variable<String>(modelType.value);
    }
    if (modelPath.present) {
      map['model_path'] = Variable<String>(modelPath.value);
    }
    if (trainedAt.present) {
      map['trained_at'] = Variable<DateTime>(trainedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiModelsCompanion(')
          ..write('id: $id, ')
          ..write('modelName: $modelName, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('modelType: $modelType, ')
          ..write('modelPath: $modelPath, ')
          ..write('trainedAt: $trainedAt, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ProcessingRunsTable extends ProcessingRuns
    with TableInfo<$ProcessingRunsTable, ProcessingRunData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProcessingRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _inputFileIdMeta = const VerificationMeta(
    'inputFileId',
  );
  @override
  late final GeneratedColumn<int> inputFileId = GeneratedColumn<int>(
    'input_file_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES input_files (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES batches (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pipelineVersionMeta = const VerificationMeta(
    'pipelineVersion',
  );
  @override
  late final GeneratedColumn<String> pipelineVersion = GeneratedColumn<String>(
    'pipeline_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<int> modelId = GeneratedColumn<int>(
    'model_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ai_models (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _recordsProcessedMeta = const VerificationMeta(
    'recordsProcessed',
  );
  @override
  late final GeneratedColumn<int> recordsProcessed = GeneratedColumn<int>(
    'records_processed',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    inputFileId,
    batchId,
    startedAt,
    completedAt,
    status,
    pipelineVersion,
    modelId,
    recordsProcessed,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'processing_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProcessingRunData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('input_file_id')) {
      context.handle(
        _inputFileIdMeta,
        inputFileId.isAcceptableOrUnknown(
          data['input_file_id']!,
          _inputFileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inputFileIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('pipeline_version')) {
      context.handle(
        _pipelineVersionMeta,
        pipelineVersion.isAcceptableOrUnknown(
          data['pipeline_version']!,
          _pipelineVersionMeta,
        ),
      );
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    }
    if (data.containsKey('records_processed')) {
      context.handle(
        _recordsProcessedMeta,
        recordsProcessed.isAcceptableOrUnknown(
          data['records_processed']!,
          _recordsProcessedMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProcessingRunData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProcessingRunData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      inputFileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}input_file_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      pipelineVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pipeline_version'],
      ),
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}model_id'],
      ),
      recordsProcessed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}records_processed'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $ProcessingRunsTable createAlias(String alias) {
    return $ProcessingRunsTable(attachedDatabase, alias);
  }
}

class ProcessingRunData extends DataClass
    implements Insertable<ProcessingRunData> {
  final int id;
  final int inputFileId;
  final int? batchId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String status;
  final String? pipelineVersion;
  final int? modelId;
  final int? recordsProcessed;
  final String? errorMessage;
  const ProcessingRunData({
    required this.id,
    required this.inputFileId,
    this.batchId,
    required this.startedAt,
    this.completedAt,
    required this.status,
    this.pipelineVersion,
    this.modelId,
    this.recordsProcessed,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['input_file_id'] = Variable<int>(inputFileId);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<int>(batchId);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || pipelineVersion != null) {
      map['pipeline_version'] = Variable<String>(pipelineVersion);
    }
    if (!nullToAbsent || modelId != null) {
      map['model_id'] = Variable<int>(modelId);
    }
    if (!nullToAbsent || recordsProcessed != null) {
      map['records_processed'] = Variable<int>(recordsProcessed);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  ProcessingRunsCompanion toCompanion(bool nullToAbsent) {
    return ProcessingRunsCompanion(
      id: Value(id),
      inputFileId: Value(inputFileId),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      status: Value(status),
      pipelineVersion: pipelineVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(pipelineVersion),
      modelId: modelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelId),
      recordsProcessed: recordsProcessed == null && nullToAbsent
          ? const Value.absent()
          : Value(recordsProcessed),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory ProcessingRunData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProcessingRunData(
      id: serializer.fromJson<int>(json['id']),
      inputFileId: serializer.fromJson<int>(json['inputFileId']),
      batchId: serializer.fromJson<int?>(json['batchId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      status: serializer.fromJson<String>(json['status']),
      pipelineVersion: serializer.fromJson<String?>(json['pipelineVersion']),
      modelId: serializer.fromJson<int?>(json['modelId']),
      recordsProcessed: serializer.fromJson<int?>(json['recordsProcessed']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'inputFileId': serializer.toJson<int>(inputFileId),
      'batchId': serializer.toJson<int?>(batchId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'status': serializer.toJson<String>(status),
      'pipelineVersion': serializer.toJson<String?>(pipelineVersion),
      'modelId': serializer.toJson<int?>(modelId),
      'recordsProcessed': serializer.toJson<int?>(recordsProcessed),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  ProcessingRunData copyWith({
    int? id,
    int? inputFileId,
    Value<int?> batchId = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    String? status,
    Value<String?> pipelineVersion = const Value.absent(),
    Value<int?> modelId = const Value.absent(),
    Value<int?> recordsProcessed = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
  }) => ProcessingRunData(
    id: id ?? this.id,
    inputFileId: inputFileId ?? this.inputFileId,
    batchId: batchId.present ? batchId.value : this.batchId,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    status: status ?? this.status,
    pipelineVersion: pipelineVersion.present
        ? pipelineVersion.value
        : this.pipelineVersion,
    modelId: modelId.present ? modelId.value : this.modelId,
    recordsProcessed: recordsProcessed.present
        ? recordsProcessed.value
        : this.recordsProcessed,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  ProcessingRunData copyWithCompanion(ProcessingRunsCompanion data) {
    return ProcessingRunData(
      id: data.id.present ? data.id.value : this.id,
      inputFileId: data.inputFileId.present
          ? data.inputFileId.value
          : this.inputFileId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      status: data.status.present ? data.status.value : this.status,
      pipelineVersion: data.pipelineVersion.present
          ? data.pipelineVersion.value
          : this.pipelineVersion,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      recordsProcessed: data.recordsProcessed.present
          ? data.recordsProcessed.value
          : this.recordsProcessed,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProcessingRunData(')
          ..write('id: $id, ')
          ..write('inputFileId: $inputFileId, ')
          ..write('batchId: $batchId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status, ')
          ..write('pipelineVersion: $pipelineVersion, ')
          ..write('modelId: $modelId, ')
          ..write('recordsProcessed: $recordsProcessed, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    inputFileId,
    batchId,
    startedAt,
    completedAt,
    status,
    pipelineVersion,
    modelId,
    recordsProcessed,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProcessingRunData &&
          other.id == this.id &&
          other.inputFileId == this.inputFileId &&
          other.batchId == this.batchId &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.status == this.status &&
          other.pipelineVersion == this.pipelineVersion &&
          other.modelId == this.modelId &&
          other.recordsProcessed == this.recordsProcessed &&
          other.errorMessage == this.errorMessage);
}

class ProcessingRunsCompanion extends UpdateCompanion<ProcessingRunData> {
  final Value<int> id;
  final Value<int> inputFileId;
  final Value<int?> batchId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<String> status;
  final Value<String?> pipelineVersion;
  final Value<int?> modelId;
  final Value<int?> recordsProcessed;
  final Value<String?> errorMessage;
  const ProcessingRunsCompanion({
    this.id = const Value.absent(),
    this.inputFileId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.pipelineVersion = const Value.absent(),
    this.modelId = const Value.absent(),
    this.recordsProcessed = const Value.absent(),
    this.errorMessage = const Value.absent(),
  });
  ProcessingRunsCompanion.insert({
    this.id = const Value.absent(),
    required int inputFileId,
    this.batchId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    required String status,
    this.pipelineVersion = const Value.absent(),
    this.modelId = const Value.absent(),
    this.recordsProcessed = const Value.absent(),
    this.errorMessage = const Value.absent(),
  }) : inputFileId = Value(inputFileId),
       status = Value(status);
  static Insertable<ProcessingRunData> custom({
    Expression<int>? id,
    Expression<int>? inputFileId,
    Expression<int>? batchId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? status,
    Expression<String>? pipelineVersion,
    Expression<int>? modelId,
    Expression<int>? recordsProcessed,
    Expression<String>? errorMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (inputFileId != null) 'input_file_id': inputFileId,
      if (batchId != null) 'batch_id': batchId,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (status != null) 'status': status,
      if (pipelineVersion != null) 'pipeline_version': pipelineVersion,
      if (modelId != null) 'model_id': modelId,
      if (recordsProcessed != null) 'records_processed': recordsProcessed,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  ProcessingRunsCompanion copyWith({
    Value<int>? id,
    Value<int>? inputFileId,
    Value<int?>? batchId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<String>? status,
    Value<String?>? pipelineVersion,
    Value<int?>? modelId,
    Value<int?>? recordsProcessed,
    Value<String?>? errorMessage,
  }) {
    return ProcessingRunsCompanion(
      id: id ?? this.id,
      inputFileId: inputFileId ?? this.inputFileId,
      batchId: batchId ?? this.batchId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      pipelineVersion: pipelineVersion ?? this.pipelineVersion,
      modelId: modelId ?? this.modelId,
      recordsProcessed: recordsProcessed ?? this.recordsProcessed,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (inputFileId.present) {
      map['input_file_id'] = Variable<int>(inputFileId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (pipelineVersion.present) {
      map['pipeline_version'] = Variable<String>(pipelineVersion.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<int>(modelId.value);
    }
    if (recordsProcessed.present) {
      map['records_processed'] = Variable<int>(recordsProcessed.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProcessingRunsCompanion(')
          ..write('id: $id, ')
          ..write('inputFileId: $inputFileId, ')
          ..write('batchId: $batchId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status, ')
          ..write('pipelineVersion: $pipelineVersion, ')
          ..write('modelId: $modelId, ')
          ..write('recordsProcessed: $recordsProcessed, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }
}

class $PreprocessingDataTable extends PreprocessingData
    with TableInfo<$PreprocessingDataTable, PreprocessingDataRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreprocessingDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES batches (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _inputFileIdMeta = const VerificationMeta(
    'inputFileId',
  );
  @override
  late final GeneratedColumn<int> inputFileId = GeneratedColumn<int>(
    'input_file_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES input_files (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _processingRunIdMeta = const VerificationMeta(
    'processingRunId',
  );
  @override
  late final GeneratedColumn<int> processingRunId = GeneratedColumn<int>(
    'processing_run_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES processing_runs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _timestampMinuteMeta = const VerificationMeta(
    'timestampMinute',
  );
  @override
  late final GeneratedColumn<DateTime> timestampMinute =
      GeneratedColumn<DateTime>(
        'timestamp_minute',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _serverTimestampMeta = const VerificationMeta(
    'serverTimestamp',
  );
  @override
  late final GeneratedColumn<DateTime> serverTimestamp =
      GeneratedColumn<DateTime>(
        'server_timestamp',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sugarConsumptionRateMeta =
      const VerificationMeta('sugarConsumptionRate');
  @override
  late final GeneratedColumn<double> sugarConsumptionRate =
      GeneratedColumn<double>(
        'sugar_consumption_rate',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _feedingHoursMeta = const VerificationMeta(
    'feedingHours',
  );
  @override
  late final GeneratedColumn<double> feedingHours = GeneratedColumn<double>(
    'feeding_hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retentionHoursMeta = const VerificationMeta(
    'retentionHours',
  );
  @override
  late final GeneratedColumn<double> retentionHours = GeneratedColumn<double>(
    'retention_hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _setupSgMeta = const VerificationMeta(
    'setupSg',
  );
  @override
  late final GeneratedColumn<double> setupSg = GeneratedColumn<double>(
    'setup_sg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finalSgMeta = const VerificationMeta(
    'finalSg',
  );
  @override
  late final GeneratedColumn<double> finalSg = GeneratedColumn<double>(
    'final_sg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sgDifferenceMeta = const VerificationMeta(
    'sgDifference',
  );
  @override
  late final GeneratedColumn<double> sgDifference = GeneratedColumn<double>(
    'sg_difference',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alcoholSetupMeta = const VerificationMeta(
    'alcoholSetup',
  );
  @override
  late final GeneratedColumn<double> alcoholSetup = GeneratedColumn<double>(
    'alcohol_setup',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alcoholFinalMeta = const VerificationMeta(
    'alcoholFinal',
  );
  @override
  late final GeneratedColumn<double> alcoholFinal = GeneratedColumn<double>(
    'alcohol_final',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phSetupMeta = const VerificationMeta(
    'phSetup',
  );
  @override
  late final GeneratedColumn<double> phSetup = GeneratedColumn<double>(
    'ph_setup',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phFinalMeta = const VerificationMeta(
    'phFinal',
  );
  @override
  late final GeneratedColumn<double> phFinal = GeneratedColumn<double>(
    'ph_final',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawSpentWashBrixMeta = const VerificationMeta(
    'rawSpentWashBrix',
  );
  @override
  late final GeneratedColumn<double> rawSpentWashBrix = GeneratedColumn<double>(
    'raw_spent_wash_brix',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bottomSpentWashBrixMeta =
      const VerificationMeta('bottomSpentWashBrix');
  @override
  late final GeneratedColumn<double> bottomSpentWashBrix =
      GeneratedColumn<double>(
        'bottom_spent_wash_brix',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ffeOutletSpentWashBrixMeta =
      const VerificationMeta('ffeOutletSpentWashBrix');
  @override
  late final GeneratedColumn<double> ffeOutletSpentWashBrix =
      GeneratedColumn<double>(
        'ffe_outlet_spent_wash_brix',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _concentratedSpentWashBrixMeta =
      const VerificationMeta('concentratedSpentWashBrix');
  @override
  late final GeneratedColumn<double> concentratedSpentWashBrix =
      GeneratedColumn<double>(
        'concentrated_spent_wash_brix',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
    'temperature',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brixMeta = const VerificationMeta('brix');
  @override
  late final GeneratedColumn<double> brix = GeneratedColumn<double>(
    'brix',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _residualSugarMeta = const VerificationMeta(
    'residualSugar',
  );
  @override
  late final GeneratedColumn<double> residualSugar = GeneratedColumn<double>(
    'residual_sugar',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yeastActivityMeta = const VerificationMeta(
    'yeastActivity',
  );
  @override
  late final GeneratedColumn<double> yeastActivity = GeneratedColumn<double>(
    'yeast_activity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _volatileAcidityMeta = const VerificationMeta(
    'volatileAcidity',
  );
  @override
  late final GeneratedColumn<double> volatileAcidity = GeneratedColumn<double>(
    'volatile_acidity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coolingValveMeta = const VerificationMeta(
    'coolingValve',
  );
  @override
  late final GeneratedColumn<double> coolingValve = GeneratedColumn<double>(
    'cooling_valve',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _agitatorRpmMeta = const VerificationMeta(
    'agitatorRpm',
  );
  @override
  late final GeneratedColumn<double> agitatorRpm = GeneratedColumn<double>(
    'agitator_rpm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _steamValveMeta = const VerificationMeta(
    'steamValve',
  );
  @override
  late final GeneratedColumn<double> steamValve = GeneratedColumn<double>(
    'steam_valve',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tankLevelPercentMeta = const VerificationMeta(
    'tankLevelPercent',
  );
  @override
  late final GeneratedColumn<double> tankLevelPercent = GeneratedColumn<double>(
    'tank_level_percent',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tankWeightKgMeta = const VerificationMeta(
    'tankWeightKg',
  );
  @override
  late final GeneratedColumn<double> tankWeightKg = GeneratedColumn<double>(
    'tank_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _co2FlowKgphMeta = const VerificationMeta(
    'co2FlowKgph',
  );
  @override
  late final GeneratedColumn<double> co2FlowKgph = GeneratedColumn<double>(
    'co2_flow_kgph',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _headspacePressureBarMeta =
      const VerificationMeta('headspacePressureBar');
  @override
  late final GeneratedColumn<double> headspacePressureBar =
      GeneratedColumn<double>(
        'headspace_pressure_bar',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchId,
    inputFileId,
    processingRunId,
    timestampMinute,
    serverTimestamp,
    sugarConsumptionRate,
    feedingHours,
    retentionHours,
    setupSg,
    finalSg,
    sgDifference,
    alcoholSetup,
    alcoholFinal,
    phSetup,
    phFinal,
    rawSpentWashBrix,
    bottomSpentWashBrix,
    ffeOutletSpentWashBrix,
    concentratedSpentWashBrix,
    temperature,
    brix,
    residualSugar,
    yeastActivity,
    volatileAcidity,
    coolingValve,
    agitatorRpm,
    steamValve,
    tankLevelPercent,
    tankWeightKg,
    co2FlowKgph,
    headspacePressureBar,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preprocessing_data';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreprocessingDataRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('input_file_id')) {
      context.handle(
        _inputFileIdMeta,
        inputFileId.isAcceptableOrUnknown(
          data['input_file_id']!,
          _inputFileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inputFileIdMeta);
    }
    if (data.containsKey('processing_run_id')) {
      context.handle(
        _processingRunIdMeta,
        processingRunId.isAcceptableOrUnknown(
          data['processing_run_id']!,
          _processingRunIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_processingRunIdMeta);
    }
    if (data.containsKey('timestamp_minute')) {
      context.handle(
        _timestampMinuteMeta,
        timestampMinute.isAcceptableOrUnknown(
          data['timestamp_minute']!,
          _timestampMinuteMeta,
        ),
      );
    }
    if (data.containsKey('server_timestamp')) {
      context.handle(
        _serverTimestampMeta,
        serverTimestamp.isAcceptableOrUnknown(
          data['server_timestamp']!,
          _serverTimestampMeta,
        ),
      );
    }
    if (data.containsKey('sugar_consumption_rate')) {
      context.handle(
        _sugarConsumptionRateMeta,
        sugarConsumptionRate.isAcceptableOrUnknown(
          data['sugar_consumption_rate']!,
          _sugarConsumptionRateMeta,
        ),
      );
    }
    if (data.containsKey('feeding_hours')) {
      context.handle(
        _feedingHoursMeta,
        feedingHours.isAcceptableOrUnknown(
          data['feeding_hours']!,
          _feedingHoursMeta,
        ),
      );
    }
    if (data.containsKey('retention_hours')) {
      context.handle(
        _retentionHoursMeta,
        retentionHours.isAcceptableOrUnknown(
          data['retention_hours']!,
          _retentionHoursMeta,
        ),
      );
    }
    if (data.containsKey('setup_sg')) {
      context.handle(
        _setupSgMeta,
        setupSg.isAcceptableOrUnknown(data['setup_sg']!, _setupSgMeta),
      );
    }
    if (data.containsKey('final_sg')) {
      context.handle(
        _finalSgMeta,
        finalSg.isAcceptableOrUnknown(data['final_sg']!, _finalSgMeta),
      );
    }
    if (data.containsKey('sg_difference')) {
      context.handle(
        _sgDifferenceMeta,
        sgDifference.isAcceptableOrUnknown(
          data['sg_difference']!,
          _sgDifferenceMeta,
        ),
      );
    }
    if (data.containsKey('alcohol_setup')) {
      context.handle(
        _alcoholSetupMeta,
        alcoholSetup.isAcceptableOrUnknown(
          data['alcohol_setup']!,
          _alcoholSetupMeta,
        ),
      );
    }
    if (data.containsKey('alcohol_final')) {
      context.handle(
        _alcoholFinalMeta,
        alcoholFinal.isAcceptableOrUnknown(
          data['alcohol_final']!,
          _alcoholFinalMeta,
        ),
      );
    }
    if (data.containsKey('ph_setup')) {
      context.handle(
        _phSetupMeta,
        phSetup.isAcceptableOrUnknown(data['ph_setup']!, _phSetupMeta),
      );
    }
    if (data.containsKey('ph_final')) {
      context.handle(
        _phFinalMeta,
        phFinal.isAcceptableOrUnknown(data['ph_final']!, _phFinalMeta),
      );
    }
    if (data.containsKey('raw_spent_wash_brix')) {
      context.handle(
        _rawSpentWashBrixMeta,
        rawSpentWashBrix.isAcceptableOrUnknown(
          data['raw_spent_wash_brix']!,
          _rawSpentWashBrixMeta,
        ),
      );
    }
    if (data.containsKey('bottom_spent_wash_brix')) {
      context.handle(
        _bottomSpentWashBrixMeta,
        bottomSpentWashBrix.isAcceptableOrUnknown(
          data['bottom_spent_wash_brix']!,
          _bottomSpentWashBrixMeta,
        ),
      );
    }
    if (data.containsKey('ffe_outlet_spent_wash_brix')) {
      context.handle(
        _ffeOutletSpentWashBrixMeta,
        ffeOutletSpentWashBrix.isAcceptableOrUnknown(
          data['ffe_outlet_spent_wash_brix']!,
          _ffeOutletSpentWashBrixMeta,
        ),
      );
    }
    if (data.containsKey('concentrated_spent_wash_brix')) {
      context.handle(
        _concentratedSpentWashBrixMeta,
        concentratedSpentWashBrix.isAcceptableOrUnknown(
          data['concentrated_spent_wash_brix']!,
          _concentratedSpentWashBrixMeta,
        ),
      );
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    }
    if (data.containsKey('brix')) {
      context.handle(
        _brixMeta,
        brix.isAcceptableOrUnknown(data['brix']!, _brixMeta),
      );
    }
    if (data.containsKey('residual_sugar')) {
      context.handle(
        _residualSugarMeta,
        residualSugar.isAcceptableOrUnknown(
          data['residual_sugar']!,
          _residualSugarMeta,
        ),
      );
    }
    if (data.containsKey('yeast_activity')) {
      context.handle(
        _yeastActivityMeta,
        yeastActivity.isAcceptableOrUnknown(
          data['yeast_activity']!,
          _yeastActivityMeta,
        ),
      );
    }
    if (data.containsKey('volatile_acidity')) {
      context.handle(
        _volatileAcidityMeta,
        volatileAcidity.isAcceptableOrUnknown(
          data['volatile_acidity']!,
          _volatileAcidityMeta,
        ),
      );
    }
    if (data.containsKey('cooling_valve')) {
      context.handle(
        _coolingValveMeta,
        coolingValve.isAcceptableOrUnknown(
          data['cooling_valve']!,
          _coolingValveMeta,
        ),
      );
    }
    if (data.containsKey('agitator_rpm')) {
      context.handle(
        _agitatorRpmMeta,
        agitatorRpm.isAcceptableOrUnknown(
          data['agitator_rpm']!,
          _agitatorRpmMeta,
        ),
      );
    }
    if (data.containsKey('steam_valve')) {
      context.handle(
        _steamValveMeta,
        steamValve.isAcceptableOrUnknown(data['steam_valve']!, _steamValveMeta),
      );
    }
    if (data.containsKey('tank_level_percent')) {
      context.handle(
        _tankLevelPercentMeta,
        tankLevelPercent.isAcceptableOrUnknown(
          data['tank_level_percent']!,
          _tankLevelPercentMeta,
        ),
      );
    }
    if (data.containsKey('tank_weight_kg')) {
      context.handle(
        _tankWeightKgMeta,
        tankWeightKg.isAcceptableOrUnknown(
          data['tank_weight_kg']!,
          _tankWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('co2_flow_kgph')) {
      context.handle(
        _co2FlowKgphMeta,
        co2FlowKgph.isAcceptableOrUnknown(
          data['co2_flow_kgph']!,
          _co2FlowKgphMeta,
        ),
      );
    }
    if (data.containsKey('headspace_pressure_bar')) {
      context.handle(
        _headspacePressureBarMeta,
        headspacePressureBar.isAcceptableOrUnknown(
          data['headspace_pressure_bar']!,
          _headspacePressureBarMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreprocessingDataRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreprocessingDataRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      )!,
      inputFileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}input_file_id'],
      )!,
      processingRunId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}processing_run_id'],
      )!,
      timestampMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp_minute'],
      ),
      serverTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_timestamp'],
      ),
      sugarConsumptionRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sugar_consumption_rate'],
      ),
      feedingHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}feeding_hours'],
      ),
      retentionHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}retention_hours'],
      ),
      setupSg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}setup_sg'],
      ),
      finalSg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}final_sg'],
      ),
      sgDifference: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sg_difference'],
      ),
      alcoholSetup: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}alcohol_setup'],
      ),
      alcoholFinal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}alcohol_final'],
      ),
      phSetup: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ph_setup'],
      ),
      phFinal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ph_final'],
      ),
      rawSpentWashBrix: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}raw_spent_wash_brix'],
      ),
      bottomSpentWashBrix: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bottom_spent_wash_brix'],
      ),
      ffeOutletSpentWashBrix: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ffe_outlet_spent_wash_brix'],
      ),
      concentratedSpentWashBrix: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}concentrated_spent_wash_brix'],
      ),
      temperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature'],
      ),
      brix: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}brix'],
      ),
      residualSugar: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}residual_sugar'],
      ),
      yeastActivity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}yeast_activity'],
      ),
      volatileAcidity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}volatile_acidity'],
      ),
      coolingValve: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cooling_valve'],
      ),
      agitatorRpm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}agitator_rpm'],
      ),
      steamValve: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}steam_valve'],
      ),
      tankLevelPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tank_level_percent'],
      ),
      tankWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tank_weight_kg'],
      ),
      co2FlowKgph: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}co2_flow_kgph'],
      ),
      headspacePressureBar: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}headspace_pressure_bar'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PreprocessingDataTable createAlias(String alias) {
    return $PreprocessingDataTable(attachedDatabase, alias);
  }
}

class PreprocessingDataRecord extends DataClass
    implements Insertable<PreprocessingDataRecord> {
  final int id;
  final int batchId;
  final int inputFileId;
  final int processingRunId;
  final DateTime? timestampMinute;
  final DateTime? serverTimestamp;
  final double? sugarConsumptionRate;
  final double? feedingHours;
  final double? retentionHours;
  final double? setupSg;
  final double? finalSg;
  final double? sgDifference;
  final double? alcoholSetup;
  final double? alcoholFinal;
  final double? phSetup;
  final double? phFinal;
  final double? rawSpentWashBrix;
  final double? bottomSpentWashBrix;
  final double? ffeOutletSpentWashBrix;
  final double? concentratedSpentWashBrix;
  final double? temperature;
  final double? brix;
  final double? residualSugar;
  final double? yeastActivity;
  final double? volatileAcidity;
  final double? coolingValve;
  final double? agitatorRpm;
  final double? steamValve;
  final double? tankLevelPercent;
  final double? tankWeightKg;
  final double? co2FlowKgph;
  final double? headspacePressureBar;
  final DateTime createdAt;
  const PreprocessingDataRecord({
    required this.id,
    required this.batchId,
    required this.inputFileId,
    required this.processingRunId,
    this.timestampMinute,
    this.serverTimestamp,
    this.sugarConsumptionRate,
    this.feedingHours,
    this.retentionHours,
    this.setupSg,
    this.finalSg,
    this.sgDifference,
    this.alcoholSetup,
    this.alcoholFinal,
    this.phSetup,
    this.phFinal,
    this.rawSpentWashBrix,
    this.bottomSpentWashBrix,
    this.ffeOutletSpentWashBrix,
    this.concentratedSpentWashBrix,
    this.temperature,
    this.brix,
    this.residualSugar,
    this.yeastActivity,
    this.volatileAcidity,
    this.coolingValve,
    this.agitatorRpm,
    this.steamValve,
    this.tankLevelPercent,
    this.tankWeightKg,
    this.co2FlowKgph,
    this.headspacePressureBar,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['batch_id'] = Variable<int>(batchId);
    map['input_file_id'] = Variable<int>(inputFileId);
    map['processing_run_id'] = Variable<int>(processingRunId);
    if (!nullToAbsent || timestampMinute != null) {
      map['timestamp_minute'] = Variable<DateTime>(timestampMinute);
    }
    if (!nullToAbsent || serverTimestamp != null) {
      map['server_timestamp'] = Variable<DateTime>(serverTimestamp);
    }
    if (!nullToAbsent || sugarConsumptionRate != null) {
      map['sugar_consumption_rate'] = Variable<double>(sugarConsumptionRate);
    }
    if (!nullToAbsent || feedingHours != null) {
      map['feeding_hours'] = Variable<double>(feedingHours);
    }
    if (!nullToAbsent || retentionHours != null) {
      map['retention_hours'] = Variable<double>(retentionHours);
    }
    if (!nullToAbsent || setupSg != null) {
      map['setup_sg'] = Variable<double>(setupSg);
    }
    if (!nullToAbsent || finalSg != null) {
      map['final_sg'] = Variable<double>(finalSg);
    }
    if (!nullToAbsent || sgDifference != null) {
      map['sg_difference'] = Variable<double>(sgDifference);
    }
    if (!nullToAbsent || alcoholSetup != null) {
      map['alcohol_setup'] = Variable<double>(alcoholSetup);
    }
    if (!nullToAbsent || alcoholFinal != null) {
      map['alcohol_final'] = Variable<double>(alcoholFinal);
    }
    if (!nullToAbsent || phSetup != null) {
      map['ph_setup'] = Variable<double>(phSetup);
    }
    if (!nullToAbsent || phFinal != null) {
      map['ph_final'] = Variable<double>(phFinal);
    }
    if (!nullToAbsent || rawSpentWashBrix != null) {
      map['raw_spent_wash_brix'] = Variable<double>(rawSpentWashBrix);
    }
    if (!nullToAbsent || bottomSpentWashBrix != null) {
      map['bottom_spent_wash_brix'] = Variable<double>(bottomSpentWashBrix);
    }
    if (!nullToAbsent || ffeOutletSpentWashBrix != null) {
      map['ffe_outlet_spent_wash_brix'] = Variable<double>(
        ffeOutletSpentWashBrix,
      );
    }
    if (!nullToAbsent || concentratedSpentWashBrix != null) {
      map['concentrated_spent_wash_brix'] = Variable<double>(
        concentratedSpentWashBrix,
      );
    }
    if (!nullToAbsent || temperature != null) {
      map['temperature'] = Variable<double>(temperature);
    }
    if (!nullToAbsent || brix != null) {
      map['brix'] = Variable<double>(brix);
    }
    if (!nullToAbsent || residualSugar != null) {
      map['residual_sugar'] = Variable<double>(residualSugar);
    }
    if (!nullToAbsent || yeastActivity != null) {
      map['yeast_activity'] = Variable<double>(yeastActivity);
    }
    if (!nullToAbsent || volatileAcidity != null) {
      map['volatile_acidity'] = Variable<double>(volatileAcidity);
    }
    if (!nullToAbsent || coolingValve != null) {
      map['cooling_valve'] = Variable<double>(coolingValve);
    }
    if (!nullToAbsent || agitatorRpm != null) {
      map['agitator_rpm'] = Variable<double>(agitatorRpm);
    }
    if (!nullToAbsent || steamValve != null) {
      map['steam_valve'] = Variable<double>(steamValve);
    }
    if (!nullToAbsent || tankLevelPercent != null) {
      map['tank_level_percent'] = Variable<double>(tankLevelPercent);
    }
    if (!nullToAbsent || tankWeightKg != null) {
      map['tank_weight_kg'] = Variable<double>(tankWeightKg);
    }
    if (!nullToAbsent || co2FlowKgph != null) {
      map['co2_flow_kgph'] = Variable<double>(co2FlowKgph);
    }
    if (!nullToAbsent || headspacePressureBar != null) {
      map['headspace_pressure_bar'] = Variable<double>(headspacePressureBar);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PreprocessingDataCompanion toCompanion(bool nullToAbsent) {
    return PreprocessingDataCompanion(
      id: Value(id),
      batchId: Value(batchId),
      inputFileId: Value(inputFileId),
      processingRunId: Value(processingRunId),
      timestampMinute: timestampMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(timestampMinute),
      serverTimestamp: serverTimestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(serverTimestamp),
      sugarConsumptionRate: sugarConsumptionRate == null && nullToAbsent
          ? const Value.absent()
          : Value(sugarConsumptionRate),
      feedingHours: feedingHours == null && nullToAbsent
          ? const Value.absent()
          : Value(feedingHours),
      retentionHours: retentionHours == null && nullToAbsent
          ? const Value.absent()
          : Value(retentionHours),
      setupSg: setupSg == null && nullToAbsent
          ? const Value.absent()
          : Value(setupSg),
      finalSg: finalSg == null && nullToAbsent
          ? const Value.absent()
          : Value(finalSg),
      sgDifference: sgDifference == null && nullToAbsent
          ? const Value.absent()
          : Value(sgDifference),
      alcoholSetup: alcoholSetup == null && nullToAbsent
          ? const Value.absent()
          : Value(alcoholSetup),
      alcoholFinal: alcoholFinal == null && nullToAbsent
          ? const Value.absent()
          : Value(alcoholFinal),
      phSetup: phSetup == null && nullToAbsent
          ? const Value.absent()
          : Value(phSetup),
      phFinal: phFinal == null && nullToAbsent
          ? const Value.absent()
          : Value(phFinal),
      rawSpentWashBrix: rawSpentWashBrix == null && nullToAbsent
          ? const Value.absent()
          : Value(rawSpentWashBrix),
      bottomSpentWashBrix: bottomSpentWashBrix == null && nullToAbsent
          ? const Value.absent()
          : Value(bottomSpentWashBrix),
      ffeOutletSpentWashBrix: ffeOutletSpentWashBrix == null && nullToAbsent
          ? const Value.absent()
          : Value(ffeOutletSpentWashBrix),
      concentratedSpentWashBrix:
          concentratedSpentWashBrix == null && nullToAbsent
          ? const Value.absent()
          : Value(concentratedSpentWashBrix),
      temperature: temperature == null && nullToAbsent
          ? const Value.absent()
          : Value(temperature),
      brix: brix == null && nullToAbsent ? const Value.absent() : Value(brix),
      residualSugar: residualSugar == null && nullToAbsent
          ? const Value.absent()
          : Value(residualSugar),
      yeastActivity: yeastActivity == null && nullToAbsent
          ? const Value.absent()
          : Value(yeastActivity),
      volatileAcidity: volatileAcidity == null && nullToAbsent
          ? const Value.absent()
          : Value(volatileAcidity),
      coolingValve: coolingValve == null && nullToAbsent
          ? const Value.absent()
          : Value(coolingValve),
      agitatorRpm: agitatorRpm == null && nullToAbsent
          ? const Value.absent()
          : Value(agitatorRpm),
      steamValve: steamValve == null && nullToAbsent
          ? const Value.absent()
          : Value(steamValve),
      tankLevelPercent: tankLevelPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(tankLevelPercent),
      tankWeightKg: tankWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(tankWeightKg),
      co2FlowKgph: co2FlowKgph == null && nullToAbsent
          ? const Value.absent()
          : Value(co2FlowKgph),
      headspacePressureBar: headspacePressureBar == null && nullToAbsent
          ? const Value.absent()
          : Value(headspacePressureBar),
      createdAt: Value(createdAt),
    );
  }

  factory PreprocessingDataRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreprocessingDataRecord(
      id: serializer.fromJson<int>(json['id']),
      batchId: serializer.fromJson<int>(json['batchId']),
      inputFileId: serializer.fromJson<int>(json['inputFileId']),
      processingRunId: serializer.fromJson<int>(json['processingRunId']),
      timestampMinute: serializer.fromJson<DateTime?>(json['timestampMinute']),
      serverTimestamp: serializer.fromJson<DateTime?>(json['serverTimestamp']),
      sugarConsumptionRate: serializer.fromJson<double?>(
        json['sugarConsumptionRate'],
      ),
      feedingHours: serializer.fromJson<double?>(json['feedingHours']),
      retentionHours: serializer.fromJson<double?>(json['retentionHours']),
      setupSg: serializer.fromJson<double?>(json['setupSg']),
      finalSg: serializer.fromJson<double?>(json['finalSg']),
      sgDifference: serializer.fromJson<double?>(json['sgDifference']),
      alcoholSetup: serializer.fromJson<double?>(json['alcoholSetup']),
      alcoholFinal: serializer.fromJson<double?>(json['alcoholFinal']),
      phSetup: serializer.fromJson<double?>(json['phSetup']),
      phFinal: serializer.fromJson<double?>(json['phFinal']),
      rawSpentWashBrix: serializer.fromJson<double?>(json['rawSpentWashBrix']),
      bottomSpentWashBrix: serializer.fromJson<double?>(
        json['bottomSpentWashBrix'],
      ),
      ffeOutletSpentWashBrix: serializer.fromJson<double?>(
        json['ffeOutletSpentWashBrix'],
      ),
      concentratedSpentWashBrix: serializer.fromJson<double?>(
        json['concentratedSpentWashBrix'],
      ),
      temperature: serializer.fromJson<double?>(json['temperature']),
      brix: serializer.fromJson<double?>(json['brix']),
      residualSugar: serializer.fromJson<double?>(json['residualSugar']),
      yeastActivity: serializer.fromJson<double?>(json['yeastActivity']),
      volatileAcidity: serializer.fromJson<double?>(json['volatileAcidity']),
      coolingValve: serializer.fromJson<double?>(json['coolingValve']),
      agitatorRpm: serializer.fromJson<double?>(json['agitatorRpm']),
      steamValve: serializer.fromJson<double?>(json['steamValve']),
      tankLevelPercent: serializer.fromJson<double?>(json['tankLevelPercent']),
      tankWeightKg: serializer.fromJson<double?>(json['tankWeightKg']),
      co2FlowKgph: serializer.fromJson<double?>(json['co2FlowKgph']),
      headspacePressureBar: serializer.fromJson<double?>(
        json['headspacePressureBar'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'batchId': serializer.toJson<int>(batchId),
      'inputFileId': serializer.toJson<int>(inputFileId),
      'processingRunId': serializer.toJson<int>(processingRunId),
      'timestampMinute': serializer.toJson<DateTime?>(timestampMinute),
      'serverTimestamp': serializer.toJson<DateTime?>(serverTimestamp),
      'sugarConsumptionRate': serializer.toJson<double?>(sugarConsumptionRate),
      'feedingHours': serializer.toJson<double?>(feedingHours),
      'retentionHours': serializer.toJson<double?>(retentionHours),
      'setupSg': serializer.toJson<double?>(setupSg),
      'finalSg': serializer.toJson<double?>(finalSg),
      'sgDifference': serializer.toJson<double?>(sgDifference),
      'alcoholSetup': serializer.toJson<double?>(alcoholSetup),
      'alcoholFinal': serializer.toJson<double?>(alcoholFinal),
      'phSetup': serializer.toJson<double?>(phSetup),
      'phFinal': serializer.toJson<double?>(phFinal),
      'rawSpentWashBrix': serializer.toJson<double?>(rawSpentWashBrix),
      'bottomSpentWashBrix': serializer.toJson<double?>(bottomSpentWashBrix),
      'ffeOutletSpentWashBrix': serializer.toJson<double?>(
        ffeOutletSpentWashBrix,
      ),
      'concentratedSpentWashBrix': serializer.toJson<double?>(
        concentratedSpentWashBrix,
      ),
      'temperature': serializer.toJson<double?>(temperature),
      'brix': serializer.toJson<double?>(brix),
      'residualSugar': serializer.toJson<double?>(residualSugar),
      'yeastActivity': serializer.toJson<double?>(yeastActivity),
      'volatileAcidity': serializer.toJson<double?>(volatileAcidity),
      'coolingValve': serializer.toJson<double?>(coolingValve),
      'agitatorRpm': serializer.toJson<double?>(agitatorRpm),
      'steamValve': serializer.toJson<double?>(steamValve),
      'tankLevelPercent': serializer.toJson<double?>(tankLevelPercent),
      'tankWeightKg': serializer.toJson<double?>(tankWeightKg),
      'co2FlowKgph': serializer.toJson<double?>(co2FlowKgph),
      'headspacePressureBar': serializer.toJson<double?>(headspacePressureBar),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PreprocessingDataRecord copyWith({
    int? id,
    int? batchId,
    int? inputFileId,
    int? processingRunId,
    Value<DateTime?> timestampMinute = const Value.absent(),
    Value<DateTime?> serverTimestamp = const Value.absent(),
    Value<double?> sugarConsumptionRate = const Value.absent(),
    Value<double?> feedingHours = const Value.absent(),
    Value<double?> retentionHours = const Value.absent(),
    Value<double?> setupSg = const Value.absent(),
    Value<double?> finalSg = const Value.absent(),
    Value<double?> sgDifference = const Value.absent(),
    Value<double?> alcoholSetup = const Value.absent(),
    Value<double?> alcoholFinal = const Value.absent(),
    Value<double?> phSetup = const Value.absent(),
    Value<double?> phFinal = const Value.absent(),
    Value<double?> rawSpentWashBrix = const Value.absent(),
    Value<double?> bottomSpentWashBrix = const Value.absent(),
    Value<double?> ffeOutletSpentWashBrix = const Value.absent(),
    Value<double?> concentratedSpentWashBrix = const Value.absent(),
    Value<double?> temperature = const Value.absent(),
    Value<double?> brix = const Value.absent(),
    Value<double?> residualSugar = const Value.absent(),
    Value<double?> yeastActivity = const Value.absent(),
    Value<double?> volatileAcidity = const Value.absent(),
    Value<double?> coolingValve = const Value.absent(),
    Value<double?> agitatorRpm = const Value.absent(),
    Value<double?> steamValve = const Value.absent(),
    Value<double?> tankLevelPercent = const Value.absent(),
    Value<double?> tankWeightKg = const Value.absent(),
    Value<double?> co2FlowKgph = const Value.absent(),
    Value<double?> headspacePressureBar = const Value.absent(),
    DateTime? createdAt,
  }) => PreprocessingDataRecord(
    id: id ?? this.id,
    batchId: batchId ?? this.batchId,
    inputFileId: inputFileId ?? this.inputFileId,
    processingRunId: processingRunId ?? this.processingRunId,
    timestampMinute: timestampMinute.present
        ? timestampMinute.value
        : this.timestampMinute,
    serverTimestamp: serverTimestamp.present
        ? serverTimestamp.value
        : this.serverTimestamp,
    sugarConsumptionRate: sugarConsumptionRate.present
        ? sugarConsumptionRate.value
        : this.sugarConsumptionRate,
    feedingHours: feedingHours.present ? feedingHours.value : this.feedingHours,
    retentionHours: retentionHours.present
        ? retentionHours.value
        : this.retentionHours,
    setupSg: setupSg.present ? setupSg.value : this.setupSg,
    finalSg: finalSg.present ? finalSg.value : this.finalSg,
    sgDifference: sgDifference.present ? sgDifference.value : this.sgDifference,
    alcoholSetup: alcoholSetup.present ? alcoholSetup.value : this.alcoholSetup,
    alcoholFinal: alcoholFinal.present ? alcoholFinal.value : this.alcoholFinal,
    phSetup: phSetup.present ? phSetup.value : this.phSetup,
    phFinal: phFinal.present ? phFinal.value : this.phFinal,
    rawSpentWashBrix: rawSpentWashBrix.present
        ? rawSpentWashBrix.value
        : this.rawSpentWashBrix,
    bottomSpentWashBrix: bottomSpentWashBrix.present
        ? bottomSpentWashBrix.value
        : this.bottomSpentWashBrix,
    ffeOutletSpentWashBrix: ffeOutletSpentWashBrix.present
        ? ffeOutletSpentWashBrix.value
        : this.ffeOutletSpentWashBrix,
    concentratedSpentWashBrix: concentratedSpentWashBrix.present
        ? concentratedSpentWashBrix.value
        : this.concentratedSpentWashBrix,
    temperature: temperature.present ? temperature.value : this.temperature,
    brix: brix.present ? brix.value : this.brix,
    residualSugar: residualSugar.present
        ? residualSugar.value
        : this.residualSugar,
    yeastActivity: yeastActivity.present
        ? yeastActivity.value
        : this.yeastActivity,
    volatileAcidity: volatileAcidity.present
        ? volatileAcidity.value
        : this.volatileAcidity,
    coolingValve: coolingValve.present ? coolingValve.value : this.coolingValve,
    agitatorRpm: agitatorRpm.present ? agitatorRpm.value : this.agitatorRpm,
    steamValve: steamValve.present ? steamValve.value : this.steamValve,
    tankLevelPercent: tankLevelPercent.present
        ? tankLevelPercent.value
        : this.tankLevelPercent,
    tankWeightKg: tankWeightKg.present ? tankWeightKg.value : this.tankWeightKg,
    co2FlowKgph: co2FlowKgph.present ? co2FlowKgph.value : this.co2FlowKgph,
    headspacePressureBar: headspacePressureBar.present
        ? headspacePressureBar.value
        : this.headspacePressureBar,
    createdAt: createdAt ?? this.createdAt,
  );
  PreprocessingDataRecord copyWithCompanion(PreprocessingDataCompanion data) {
    return PreprocessingDataRecord(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      inputFileId: data.inputFileId.present
          ? data.inputFileId.value
          : this.inputFileId,
      processingRunId: data.processingRunId.present
          ? data.processingRunId.value
          : this.processingRunId,
      timestampMinute: data.timestampMinute.present
          ? data.timestampMinute.value
          : this.timestampMinute,
      serverTimestamp: data.serverTimestamp.present
          ? data.serverTimestamp.value
          : this.serverTimestamp,
      sugarConsumptionRate: data.sugarConsumptionRate.present
          ? data.sugarConsumptionRate.value
          : this.sugarConsumptionRate,
      feedingHours: data.feedingHours.present
          ? data.feedingHours.value
          : this.feedingHours,
      retentionHours: data.retentionHours.present
          ? data.retentionHours.value
          : this.retentionHours,
      setupSg: data.setupSg.present ? data.setupSg.value : this.setupSg,
      finalSg: data.finalSg.present ? data.finalSg.value : this.finalSg,
      sgDifference: data.sgDifference.present
          ? data.sgDifference.value
          : this.sgDifference,
      alcoholSetup: data.alcoholSetup.present
          ? data.alcoholSetup.value
          : this.alcoholSetup,
      alcoholFinal: data.alcoholFinal.present
          ? data.alcoholFinal.value
          : this.alcoholFinal,
      phSetup: data.phSetup.present ? data.phSetup.value : this.phSetup,
      phFinal: data.phFinal.present ? data.phFinal.value : this.phFinal,
      rawSpentWashBrix: data.rawSpentWashBrix.present
          ? data.rawSpentWashBrix.value
          : this.rawSpentWashBrix,
      bottomSpentWashBrix: data.bottomSpentWashBrix.present
          ? data.bottomSpentWashBrix.value
          : this.bottomSpentWashBrix,
      ffeOutletSpentWashBrix: data.ffeOutletSpentWashBrix.present
          ? data.ffeOutletSpentWashBrix.value
          : this.ffeOutletSpentWashBrix,
      concentratedSpentWashBrix: data.concentratedSpentWashBrix.present
          ? data.concentratedSpentWashBrix.value
          : this.concentratedSpentWashBrix,
      temperature: data.temperature.present
          ? data.temperature.value
          : this.temperature,
      brix: data.brix.present ? data.brix.value : this.brix,
      residualSugar: data.residualSugar.present
          ? data.residualSugar.value
          : this.residualSugar,
      yeastActivity: data.yeastActivity.present
          ? data.yeastActivity.value
          : this.yeastActivity,
      volatileAcidity: data.volatileAcidity.present
          ? data.volatileAcidity.value
          : this.volatileAcidity,
      coolingValve: data.coolingValve.present
          ? data.coolingValve.value
          : this.coolingValve,
      agitatorRpm: data.agitatorRpm.present
          ? data.agitatorRpm.value
          : this.agitatorRpm,
      steamValve: data.steamValve.present
          ? data.steamValve.value
          : this.steamValve,
      tankLevelPercent: data.tankLevelPercent.present
          ? data.tankLevelPercent.value
          : this.tankLevelPercent,
      tankWeightKg: data.tankWeightKg.present
          ? data.tankWeightKg.value
          : this.tankWeightKg,
      co2FlowKgph: data.co2FlowKgph.present
          ? data.co2FlowKgph.value
          : this.co2FlowKgph,
      headspacePressureBar: data.headspacePressureBar.present
          ? data.headspacePressureBar.value
          : this.headspacePressureBar,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreprocessingDataRecord(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('inputFileId: $inputFileId, ')
          ..write('processingRunId: $processingRunId, ')
          ..write('timestampMinute: $timestampMinute, ')
          ..write('serverTimestamp: $serverTimestamp, ')
          ..write('sugarConsumptionRate: $sugarConsumptionRate, ')
          ..write('feedingHours: $feedingHours, ')
          ..write('retentionHours: $retentionHours, ')
          ..write('setupSg: $setupSg, ')
          ..write('finalSg: $finalSg, ')
          ..write('sgDifference: $sgDifference, ')
          ..write('alcoholSetup: $alcoholSetup, ')
          ..write('alcoholFinal: $alcoholFinal, ')
          ..write('phSetup: $phSetup, ')
          ..write('phFinal: $phFinal, ')
          ..write('rawSpentWashBrix: $rawSpentWashBrix, ')
          ..write('bottomSpentWashBrix: $bottomSpentWashBrix, ')
          ..write('ffeOutletSpentWashBrix: $ffeOutletSpentWashBrix, ')
          ..write('concentratedSpentWashBrix: $concentratedSpentWashBrix, ')
          ..write('temperature: $temperature, ')
          ..write('brix: $brix, ')
          ..write('residualSugar: $residualSugar, ')
          ..write('yeastActivity: $yeastActivity, ')
          ..write('volatileAcidity: $volatileAcidity, ')
          ..write('coolingValve: $coolingValve, ')
          ..write('agitatorRpm: $agitatorRpm, ')
          ..write('steamValve: $steamValve, ')
          ..write('tankLevelPercent: $tankLevelPercent, ')
          ..write('tankWeightKg: $tankWeightKg, ')
          ..write('co2FlowKgph: $co2FlowKgph, ')
          ..write('headspacePressureBar: $headspacePressureBar, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    batchId,
    inputFileId,
    processingRunId,
    timestampMinute,
    serverTimestamp,
    sugarConsumptionRate,
    feedingHours,
    retentionHours,
    setupSg,
    finalSg,
    sgDifference,
    alcoholSetup,
    alcoholFinal,
    phSetup,
    phFinal,
    rawSpentWashBrix,
    bottomSpentWashBrix,
    ffeOutletSpentWashBrix,
    concentratedSpentWashBrix,
    temperature,
    brix,
    residualSugar,
    yeastActivity,
    volatileAcidity,
    coolingValve,
    agitatorRpm,
    steamValve,
    tankLevelPercent,
    tankWeightKg,
    co2FlowKgph,
    headspacePressureBar,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreprocessingDataRecord &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.inputFileId == this.inputFileId &&
          other.processingRunId == this.processingRunId &&
          other.timestampMinute == this.timestampMinute &&
          other.serverTimestamp == this.serverTimestamp &&
          other.sugarConsumptionRate == this.sugarConsumptionRate &&
          other.feedingHours == this.feedingHours &&
          other.retentionHours == this.retentionHours &&
          other.setupSg == this.setupSg &&
          other.finalSg == this.finalSg &&
          other.sgDifference == this.sgDifference &&
          other.alcoholSetup == this.alcoholSetup &&
          other.alcoholFinal == this.alcoholFinal &&
          other.phSetup == this.phSetup &&
          other.phFinal == this.phFinal &&
          other.rawSpentWashBrix == this.rawSpentWashBrix &&
          other.bottomSpentWashBrix == this.bottomSpentWashBrix &&
          other.ffeOutletSpentWashBrix == this.ffeOutletSpentWashBrix &&
          other.concentratedSpentWashBrix == this.concentratedSpentWashBrix &&
          other.temperature == this.temperature &&
          other.brix == this.brix &&
          other.residualSugar == this.residualSugar &&
          other.yeastActivity == this.yeastActivity &&
          other.volatileAcidity == this.volatileAcidity &&
          other.coolingValve == this.coolingValve &&
          other.agitatorRpm == this.agitatorRpm &&
          other.steamValve == this.steamValve &&
          other.tankLevelPercent == this.tankLevelPercent &&
          other.tankWeightKg == this.tankWeightKg &&
          other.co2FlowKgph == this.co2FlowKgph &&
          other.headspacePressureBar == this.headspacePressureBar &&
          other.createdAt == this.createdAt);
}

class PreprocessingDataCompanion
    extends UpdateCompanion<PreprocessingDataRecord> {
  final Value<int> id;
  final Value<int> batchId;
  final Value<int> inputFileId;
  final Value<int> processingRunId;
  final Value<DateTime?> timestampMinute;
  final Value<DateTime?> serverTimestamp;
  final Value<double?> sugarConsumptionRate;
  final Value<double?> feedingHours;
  final Value<double?> retentionHours;
  final Value<double?> setupSg;
  final Value<double?> finalSg;
  final Value<double?> sgDifference;
  final Value<double?> alcoholSetup;
  final Value<double?> alcoholFinal;
  final Value<double?> phSetup;
  final Value<double?> phFinal;
  final Value<double?> rawSpentWashBrix;
  final Value<double?> bottomSpentWashBrix;
  final Value<double?> ffeOutletSpentWashBrix;
  final Value<double?> concentratedSpentWashBrix;
  final Value<double?> temperature;
  final Value<double?> brix;
  final Value<double?> residualSugar;
  final Value<double?> yeastActivity;
  final Value<double?> volatileAcidity;
  final Value<double?> coolingValve;
  final Value<double?> agitatorRpm;
  final Value<double?> steamValve;
  final Value<double?> tankLevelPercent;
  final Value<double?> tankWeightKg;
  final Value<double?> co2FlowKgph;
  final Value<double?> headspacePressureBar;
  final Value<DateTime> createdAt;
  const PreprocessingDataCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.inputFileId = const Value.absent(),
    this.processingRunId = const Value.absent(),
    this.timestampMinute = const Value.absent(),
    this.serverTimestamp = const Value.absent(),
    this.sugarConsumptionRate = const Value.absent(),
    this.feedingHours = const Value.absent(),
    this.retentionHours = const Value.absent(),
    this.setupSg = const Value.absent(),
    this.finalSg = const Value.absent(),
    this.sgDifference = const Value.absent(),
    this.alcoholSetup = const Value.absent(),
    this.alcoholFinal = const Value.absent(),
    this.phSetup = const Value.absent(),
    this.phFinal = const Value.absent(),
    this.rawSpentWashBrix = const Value.absent(),
    this.bottomSpentWashBrix = const Value.absent(),
    this.ffeOutletSpentWashBrix = const Value.absent(),
    this.concentratedSpentWashBrix = const Value.absent(),
    this.temperature = const Value.absent(),
    this.brix = const Value.absent(),
    this.residualSugar = const Value.absent(),
    this.yeastActivity = const Value.absent(),
    this.volatileAcidity = const Value.absent(),
    this.coolingValve = const Value.absent(),
    this.agitatorRpm = const Value.absent(),
    this.steamValve = const Value.absent(),
    this.tankLevelPercent = const Value.absent(),
    this.tankWeightKg = const Value.absent(),
    this.co2FlowKgph = const Value.absent(),
    this.headspacePressureBar = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PreprocessingDataCompanion.insert({
    this.id = const Value.absent(),
    required int batchId,
    required int inputFileId,
    required int processingRunId,
    this.timestampMinute = const Value.absent(),
    this.serverTimestamp = const Value.absent(),
    this.sugarConsumptionRate = const Value.absent(),
    this.feedingHours = const Value.absent(),
    this.retentionHours = const Value.absent(),
    this.setupSg = const Value.absent(),
    this.finalSg = const Value.absent(),
    this.sgDifference = const Value.absent(),
    this.alcoholSetup = const Value.absent(),
    this.alcoholFinal = const Value.absent(),
    this.phSetup = const Value.absent(),
    this.phFinal = const Value.absent(),
    this.rawSpentWashBrix = const Value.absent(),
    this.bottomSpentWashBrix = const Value.absent(),
    this.ffeOutletSpentWashBrix = const Value.absent(),
    this.concentratedSpentWashBrix = const Value.absent(),
    this.temperature = const Value.absent(),
    this.brix = const Value.absent(),
    this.residualSugar = const Value.absent(),
    this.yeastActivity = const Value.absent(),
    this.volatileAcidity = const Value.absent(),
    this.coolingValve = const Value.absent(),
    this.agitatorRpm = const Value.absent(),
    this.steamValve = const Value.absent(),
    this.tankLevelPercent = const Value.absent(),
    this.tankWeightKg = const Value.absent(),
    this.co2FlowKgph = const Value.absent(),
    this.headspacePressureBar = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : batchId = Value(batchId),
       inputFileId = Value(inputFileId),
       processingRunId = Value(processingRunId);
  static Insertable<PreprocessingDataRecord> custom({
    Expression<int>? id,
    Expression<int>? batchId,
    Expression<int>? inputFileId,
    Expression<int>? processingRunId,
    Expression<DateTime>? timestampMinute,
    Expression<DateTime>? serverTimestamp,
    Expression<double>? sugarConsumptionRate,
    Expression<double>? feedingHours,
    Expression<double>? retentionHours,
    Expression<double>? setupSg,
    Expression<double>? finalSg,
    Expression<double>? sgDifference,
    Expression<double>? alcoholSetup,
    Expression<double>? alcoholFinal,
    Expression<double>? phSetup,
    Expression<double>? phFinal,
    Expression<double>? rawSpentWashBrix,
    Expression<double>? bottomSpentWashBrix,
    Expression<double>? ffeOutletSpentWashBrix,
    Expression<double>? concentratedSpentWashBrix,
    Expression<double>? temperature,
    Expression<double>? brix,
    Expression<double>? residualSugar,
    Expression<double>? yeastActivity,
    Expression<double>? volatileAcidity,
    Expression<double>? coolingValve,
    Expression<double>? agitatorRpm,
    Expression<double>? steamValve,
    Expression<double>? tankLevelPercent,
    Expression<double>? tankWeightKg,
    Expression<double>? co2FlowKgph,
    Expression<double>? headspacePressureBar,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (inputFileId != null) 'input_file_id': inputFileId,
      if (processingRunId != null) 'processing_run_id': processingRunId,
      if (timestampMinute != null) 'timestamp_minute': timestampMinute,
      if (serverTimestamp != null) 'server_timestamp': serverTimestamp,
      if (sugarConsumptionRate != null)
        'sugar_consumption_rate': sugarConsumptionRate,
      if (feedingHours != null) 'feeding_hours': feedingHours,
      if (retentionHours != null) 'retention_hours': retentionHours,
      if (setupSg != null) 'setup_sg': setupSg,
      if (finalSg != null) 'final_sg': finalSg,
      if (sgDifference != null) 'sg_difference': sgDifference,
      if (alcoholSetup != null) 'alcohol_setup': alcoholSetup,
      if (alcoholFinal != null) 'alcohol_final': alcoholFinal,
      if (phSetup != null) 'ph_setup': phSetup,
      if (phFinal != null) 'ph_final': phFinal,
      if (rawSpentWashBrix != null) 'raw_spent_wash_brix': rawSpentWashBrix,
      if (bottomSpentWashBrix != null)
        'bottom_spent_wash_brix': bottomSpentWashBrix,
      if (ffeOutletSpentWashBrix != null)
        'ffe_outlet_spent_wash_brix': ffeOutletSpentWashBrix,
      if (concentratedSpentWashBrix != null)
        'concentrated_spent_wash_brix': concentratedSpentWashBrix,
      if (temperature != null) 'temperature': temperature,
      if (brix != null) 'brix': brix,
      if (residualSugar != null) 'residual_sugar': residualSugar,
      if (yeastActivity != null) 'yeast_activity': yeastActivity,
      if (volatileAcidity != null) 'volatile_acidity': volatileAcidity,
      if (coolingValve != null) 'cooling_valve': coolingValve,
      if (agitatorRpm != null) 'agitator_rpm': agitatorRpm,
      if (steamValve != null) 'steam_valve': steamValve,
      if (tankLevelPercent != null) 'tank_level_percent': tankLevelPercent,
      if (tankWeightKg != null) 'tank_weight_kg': tankWeightKg,
      if (co2FlowKgph != null) 'co2_flow_kgph': co2FlowKgph,
      if (headspacePressureBar != null)
        'headspace_pressure_bar': headspacePressureBar,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PreprocessingDataCompanion copyWith({
    Value<int>? id,
    Value<int>? batchId,
    Value<int>? inputFileId,
    Value<int>? processingRunId,
    Value<DateTime?>? timestampMinute,
    Value<DateTime?>? serverTimestamp,
    Value<double?>? sugarConsumptionRate,
    Value<double?>? feedingHours,
    Value<double?>? retentionHours,
    Value<double?>? setupSg,
    Value<double?>? finalSg,
    Value<double?>? sgDifference,
    Value<double?>? alcoholSetup,
    Value<double?>? alcoholFinal,
    Value<double?>? phSetup,
    Value<double?>? phFinal,
    Value<double?>? rawSpentWashBrix,
    Value<double?>? bottomSpentWashBrix,
    Value<double?>? ffeOutletSpentWashBrix,
    Value<double?>? concentratedSpentWashBrix,
    Value<double?>? temperature,
    Value<double?>? brix,
    Value<double?>? residualSugar,
    Value<double?>? yeastActivity,
    Value<double?>? volatileAcidity,
    Value<double?>? coolingValve,
    Value<double?>? agitatorRpm,
    Value<double?>? steamValve,
    Value<double?>? tankLevelPercent,
    Value<double?>? tankWeightKg,
    Value<double?>? co2FlowKgph,
    Value<double?>? headspacePressureBar,
    Value<DateTime>? createdAt,
  }) {
    return PreprocessingDataCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      inputFileId: inputFileId ?? this.inputFileId,
      processingRunId: processingRunId ?? this.processingRunId,
      timestampMinute: timestampMinute ?? this.timestampMinute,
      serverTimestamp: serverTimestamp ?? this.serverTimestamp,
      sugarConsumptionRate: sugarConsumptionRate ?? this.sugarConsumptionRate,
      feedingHours: feedingHours ?? this.feedingHours,
      retentionHours: retentionHours ?? this.retentionHours,
      setupSg: setupSg ?? this.setupSg,
      finalSg: finalSg ?? this.finalSg,
      sgDifference: sgDifference ?? this.sgDifference,
      alcoholSetup: alcoholSetup ?? this.alcoholSetup,
      alcoholFinal: alcoholFinal ?? this.alcoholFinal,
      phSetup: phSetup ?? this.phSetup,
      phFinal: phFinal ?? this.phFinal,
      rawSpentWashBrix: rawSpentWashBrix ?? this.rawSpentWashBrix,
      bottomSpentWashBrix: bottomSpentWashBrix ?? this.bottomSpentWashBrix,
      ffeOutletSpentWashBrix:
          ffeOutletSpentWashBrix ?? this.ffeOutletSpentWashBrix,
      concentratedSpentWashBrix:
          concentratedSpentWashBrix ?? this.concentratedSpentWashBrix,
      temperature: temperature ?? this.temperature,
      brix: brix ?? this.brix,
      residualSugar: residualSugar ?? this.residualSugar,
      yeastActivity: yeastActivity ?? this.yeastActivity,
      volatileAcidity: volatileAcidity ?? this.volatileAcidity,
      coolingValve: coolingValve ?? this.coolingValve,
      agitatorRpm: agitatorRpm ?? this.agitatorRpm,
      steamValve: steamValve ?? this.steamValve,
      tankLevelPercent: tankLevelPercent ?? this.tankLevelPercent,
      tankWeightKg: tankWeightKg ?? this.tankWeightKg,
      co2FlowKgph: co2FlowKgph ?? this.co2FlowKgph,
      headspacePressureBar: headspacePressureBar ?? this.headspacePressureBar,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    if (inputFileId.present) {
      map['input_file_id'] = Variable<int>(inputFileId.value);
    }
    if (processingRunId.present) {
      map['processing_run_id'] = Variable<int>(processingRunId.value);
    }
    if (timestampMinute.present) {
      map['timestamp_minute'] = Variable<DateTime>(timestampMinute.value);
    }
    if (serverTimestamp.present) {
      map['server_timestamp'] = Variable<DateTime>(serverTimestamp.value);
    }
    if (sugarConsumptionRate.present) {
      map['sugar_consumption_rate'] = Variable<double>(
        sugarConsumptionRate.value,
      );
    }
    if (feedingHours.present) {
      map['feeding_hours'] = Variable<double>(feedingHours.value);
    }
    if (retentionHours.present) {
      map['retention_hours'] = Variable<double>(retentionHours.value);
    }
    if (setupSg.present) {
      map['setup_sg'] = Variable<double>(setupSg.value);
    }
    if (finalSg.present) {
      map['final_sg'] = Variable<double>(finalSg.value);
    }
    if (sgDifference.present) {
      map['sg_difference'] = Variable<double>(sgDifference.value);
    }
    if (alcoholSetup.present) {
      map['alcohol_setup'] = Variable<double>(alcoholSetup.value);
    }
    if (alcoholFinal.present) {
      map['alcohol_final'] = Variable<double>(alcoholFinal.value);
    }
    if (phSetup.present) {
      map['ph_setup'] = Variable<double>(phSetup.value);
    }
    if (phFinal.present) {
      map['ph_final'] = Variable<double>(phFinal.value);
    }
    if (rawSpentWashBrix.present) {
      map['raw_spent_wash_brix'] = Variable<double>(rawSpentWashBrix.value);
    }
    if (bottomSpentWashBrix.present) {
      map['bottom_spent_wash_brix'] = Variable<double>(
        bottomSpentWashBrix.value,
      );
    }
    if (ffeOutletSpentWashBrix.present) {
      map['ffe_outlet_spent_wash_brix'] = Variable<double>(
        ffeOutletSpentWashBrix.value,
      );
    }
    if (concentratedSpentWashBrix.present) {
      map['concentrated_spent_wash_brix'] = Variable<double>(
        concentratedSpentWashBrix.value,
      );
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (brix.present) {
      map['brix'] = Variable<double>(brix.value);
    }
    if (residualSugar.present) {
      map['residual_sugar'] = Variable<double>(residualSugar.value);
    }
    if (yeastActivity.present) {
      map['yeast_activity'] = Variable<double>(yeastActivity.value);
    }
    if (volatileAcidity.present) {
      map['volatile_acidity'] = Variable<double>(volatileAcidity.value);
    }
    if (coolingValve.present) {
      map['cooling_valve'] = Variable<double>(coolingValve.value);
    }
    if (agitatorRpm.present) {
      map['agitator_rpm'] = Variable<double>(agitatorRpm.value);
    }
    if (steamValve.present) {
      map['steam_valve'] = Variable<double>(steamValve.value);
    }
    if (tankLevelPercent.present) {
      map['tank_level_percent'] = Variable<double>(tankLevelPercent.value);
    }
    if (tankWeightKg.present) {
      map['tank_weight_kg'] = Variable<double>(tankWeightKg.value);
    }
    if (co2FlowKgph.present) {
      map['co2_flow_kgph'] = Variable<double>(co2FlowKgph.value);
    }
    if (headspacePressureBar.present) {
      map['headspace_pressure_bar'] = Variable<double>(
        headspacePressureBar.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreprocessingDataCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('inputFileId: $inputFileId, ')
          ..write('processingRunId: $processingRunId, ')
          ..write('timestampMinute: $timestampMinute, ')
          ..write('serverTimestamp: $serverTimestamp, ')
          ..write('sugarConsumptionRate: $sugarConsumptionRate, ')
          ..write('feedingHours: $feedingHours, ')
          ..write('retentionHours: $retentionHours, ')
          ..write('setupSg: $setupSg, ')
          ..write('finalSg: $finalSg, ')
          ..write('sgDifference: $sgDifference, ')
          ..write('alcoholSetup: $alcoholSetup, ')
          ..write('alcoholFinal: $alcoholFinal, ')
          ..write('phSetup: $phSetup, ')
          ..write('phFinal: $phFinal, ')
          ..write('rawSpentWashBrix: $rawSpentWashBrix, ')
          ..write('bottomSpentWashBrix: $bottomSpentWashBrix, ')
          ..write('ffeOutletSpentWashBrix: $ffeOutletSpentWashBrix, ')
          ..write('concentratedSpentWashBrix: $concentratedSpentWashBrix, ')
          ..write('temperature: $temperature, ')
          ..write('brix: $brix, ')
          ..write('residualSugar: $residualSugar, ')
          ..write('yeastActivity: $yeastActivity, ')
          ..write('volatileAcidity: $volatileAcidity, ')
          ..write('coolingValve: $coolingValve, ')
          ..write('agitatorRpm: $agitatorRpm, ')
          ..write('steamValve: $steamValve, ')
          ..write('tankLevelPercent: $tankLevelPercent, ')
          ..write('tankWeightKg: $tankWeightKg, ')
          ..write('co2FlowKgph: $co2FlowKgph, ')
          ..write('headspacePressureBar: $headspacePressureBar, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PredictionsTable extends Predictions
    with TableInfo<$PredictionsTable, PredictionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PredictionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES batches (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _processingRunIdMeta = const VerificationMeta(
    'processingRunId',
  );
  @override
  late final GeneratedColumn<int> processingRunId = GeneratedColumn<int>(
    'processing_run_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES processing_runs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<int> modelId = GeneratedColumn<int>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ai_models (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _predictionLabelMeta = const VerificationMeta(
    'predictionLabel',
  );
  @override
  late final GeneratedColumn<String> predictionLabel = GeneratedColumn<String>(
    'prediction_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _predictionConfidenceMeta =
      const VerificationMeta('predictionConfidence');
  @override
  late final GeneratedColumn<double> predictionConfidence =
      GeneratedColumn<double>(
        'prediction_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _predictedProductionMeta =
      const VerificationMeta('predictedProduction');
  @override
  late final GeneratedColumn<double> predictedProduction =
      GeneratedColumn<double>(
        'predicted_production',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _actualProductionMeta = const VerificationMeta(
    'actualProduction',
  );
  @override
  late final GeneratedColumn<double> actualProduction = GeneratedColumn<double>(
    'actual_production',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _predictedFermenterEfficiencyMeta =
      const VerificationMeta('predictedFermenterEfficiency');
  @override
  late final GeneratedColumn<double> predictedFermenterEfficiency =
      GeneratedColumn<double>(
        'predicted_fermenter_efficiency',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _actualFermenterEfficiencyMeta =
      const VerificationMeta('actualFermenterEfficiency');
  @override
  late final GeneratedColumn<double> actualFermenterEfficiency =
      GeneratedColumn<double>(
        'actual_fermenter_efficiency',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _predictedEthanolPercentageMeta =
      const VerificationMeta('predictedEthanolPercentage');
  @override
  late final GeneratedColumn<double> predictedEthanolPercentage =
      GeneratedColumn<double>(
        'predicted_ethanol_percentage',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _actualEthanolPercentageMeta =
      const VerificationMeta('actualEthanolPercentage');
  @override
  late final GeneratedColumn<double> actualEthanolPercentage =
      GeneratedColumn<double>(
        'actual_ethanol_percentage',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fermenterVesselQcAlertMeta =
      const VerificationMeta('fermenterVesselQcAlert');
  @override
  late final GeneratedColumn<bool> fermenterVesselQcAlert =
      GeneratedColumn<bool>(
        'fermenter_vessel_qc_alert',
        aliasedName,
        true,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("fermenter_vessel_qc_alert" IN (0, 1))',
        ),
      );
  static const VerificationMeta _predictedAtMeta = const VerificationMeta(
    'predictedAt',
  );
  @override
  late final GeneratedColumn<DateTime> predictedAt = GeneratedColumn<DateTime>(
    'predicted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchId,
    processingRunId,
    modelId,
    predictionLabel,
    predictionConfidence,
    predictedProduction,
    actualProduction,
    predictedFermenterEfficiency,
    actualFermenterEfficiency,
    predictedEthanolPercentage,
    actualEthanolPercentage,
    fermenterVesselQcAlert,
    predictedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'predictions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PredictionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('processing_run_id')) {
      context.handle(
        _processingRunIdMeta,
        processingRunId.isAcceptableOrUnknown(
          data['processing_run_id']!,
          _processingRunIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_processingRunIdMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('prediction_label')) {
      context.handle(
        _predictionLabelMeta,
        predictionLabel.isAcceptableOrUnknown(
          data['prediction_label']!,
          _predictionLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_predictionLabelMeta);
    }
    if (data.containsKey('prediction_confidence')) {
      context.handle(
        _predictionConfidenceMeta,
        predictionConfidence.isAcceptableOrUnknown(
          data['prediction_confidence']!,
          _predictionConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('predicted_production')) {
      context.handle(
        _predictedProductionMeta,
        predictedProduction.isAcceptableOrUnknown(
          data['predicted_production']!,
          _predictedProductionMeta,
        ),
      );
    }
    if (data.containsKey('actual_production')) {
      context.handle(
        _actualProductionMeta,
        actualProduction.isAcceptableOrUnknown(
          data['actual_production']!,
          _actualProductionMeta,
        ),
      );
    }
    if (data.containsKey('predicted_fermenter_efficiency')) {
      context.handle(
        _predictedFermenterEfficiencyMeta,
        predictedFermenterEfficiency.isAcceptableOrUnknown(
          data['predicted_fermenter_efficiency']!,
          _predictedFermenterEfficiencyMeta,
        ),
      );
    }
    if (data.containsKey('actual_fermenter_efficiency')) {
      context.handle(
        _actualFermenterEfficiencyMeta,
        actualFermenterEfficiency.isAcceptableOrUnknown(
          data['actual_fermenter_efficiency']!,
          _actualFermenterEfficiencyMeta,
        ),
      );
    }
    if (data.containsKey('predicted_ethanol_percentage')) {
      context.handle(
        _predictedEthanolPercentageMeta,
        predictedEthanolPercentage.isAcceptableOrUnknown(
          data['predicted_ethanol_percentage']!,
          _predictedEthanolPercentageMeta,
        ),
      );
    }
    if (data.containsKey('actual_ethanol_percentage')) {
      context.handle(
        _actualEthanolPercentageMeta,
        actualEthanolPercentage.isAcceptableOrUnknown(
          data['actual_ethanol_percentage']!,
          _actualEthanolPercentageMeta,
        ),
      );
    }
    if (data.containsKey('fermenter_vessel_qc_alert')) {
      context.handle(
        _fermenterVesselQcAlertMeta,
        fermenterVesselQcAlert.isAcceptableOrUnknown(
          data['fermenter_vessel_qc_alert']!,
          _fermenterVesselQcAlertMeta,
        ),
      );
    }
    if (data.containsKey('predicted_at')) {
      context.handle(
        _predictedAtMeta,
        predictedAt.isAcceptableOrUnknown(
          data['predicted_at']!,
          _predictedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PredictionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PredictionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      )!,
      processingRunId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}processing_run_id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}model_id'],
      )!,
      predictionLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prediction_label'],
      )!,
      predictionConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prediction_confidence'],
      ),
      predictedProduction: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}predicted_production'],
      ),
      actualProduction: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_production'],
      ),
      predictedFermenterEfficiency: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}predicted_fermenter_efficiency'],
      ),
      actualFermenterEfficiency: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_fermenter_efficiency'],
      ),
      predictedEthanolPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}predicted_ethanol_percentage'],
      ),
      actualEthanolPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_ethanol_percentage'],
      ),
      fermenterVesselQcAlert: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}fermenter_vessel_qc_alert'],
      ),
      predictedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}predicted_at'],
      )!,
    );
  }

  @override
  $PredictionsTable createAlias(String alias) {
    return $PredictionsTable(attachedDatabase, alias);
  }
}

class PredictionData extends DataClass implements Insertable<PredictionData> {
  final int id;
  final int batchId;
  final int processingRunId;
  final int modelId;
  final String predictionLabel;
  final double? predictionConfidence;
  final double? predictedProduction;
  final double? actualProduction;
  final double? predictedFermenterEfficiency;
  final double? actualFermenterEfficiency;
  final double? predictedEthanolPercentage;
  final double? actualEthanolPercentage;
  final bool? fermenterVesselQcAlert;
  final DateTime predictedAt;
  const PredictionData({
    required this.id,
    required this.batchId,
    required this.processingRunId,
    required this.modelId,
    required this.predictionLabel,
    this.predictionConfidence,
    this.predictedProduction,
    this.actualProduction,
    this.predictedFermenterEfficiency,
    this.actualFermenterEfficiency,
    this.predictedEthanolPercentage,
    this.actualEthanolPercentage,
    this.fermenterVesselQcAlert,
    required this.predictedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['batch_id'] = Variable<int>(batchId);
    map['processing_run_id'] = Variable<int>(processingRunId);
    map['model_id'] = Variable<int>(modelId);
    map['prediction_label'] = Variable<String>(predictionLabel);
    if (!nullToAbsent || predictionConfidence != null) {
      map['prediction_confidence'] = Variable<double>(predictionConfidence);
    }
    if (!nullToAbsent || predictedProduction != null) {
      map['predicted_production'] = Variable<double>(predictedProduction);
    }
    if (!nullToAbsent || actualProduction != null) {
      map['actual_production'] = Variable<double>(actualProduction);
    }
    if (!nullToAbsent || predictedFermenterEfficiency != null) {
      map['predicted_fermenter_efficiency'] = Variable<double>(
        predictedFermenterEfficiency,
      );
    }
    if (!nullToAbsent || actualFermenterEfficiency != null) {
      map['actual_fermenter_efficiency'] = Variable<double>(
        actualFermenterEfficiency,
      );
    }
    if (!nullToAbsent || predictedEthanolPercentage != null) {
      map['predicted_ethanol_percentage'] = Variable<double>(
        predictedEthanolPercentage,
      );
    }
    if (!nullToAbsent || actualEthanolPercentage != null) {
      map['actual_ethanol_percentage'] = Variable<double>(
        actualEthanolPercentage,
      );
    }
    if (!nullToAbsent || fermenterVesselQcAlert != null) {
      map['fermenter_vessel_qc_alert'] = Variable<bool>(fermenterVesselQcAlert);
    }
    map['predicted_at'] = Variable<DateTime>(predictedAt);
    return map;
  }

  PredictionsCompanion toCompanion(bool nullToAbsent) {
    return PredictionsCompanion(
      id: Value(id),
      batchId: Value(batchId),
      processingRunId: Value(processingRunId),
      modelId: Value(modelId),
      predictionLabel: Value(predictionLabel),
      predictionConfidence: predictionConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(predictionConfidence),
      predictedProduction: predictedProduction == null && nullToAbsent
          ? const Value.absent()
          : Value(predictedProduction),
      actualProduction: actualProduction == null && nullToAbsent
          ? const Value.absent()
          : Value(actualProduction),
      predictedFermenterEfficiency:
          predictedFermenterEfficiency == null && nullToAbsent
          ? const Value.absent()
          : Value(predictedFermenterEfficiency),
      actualFermenterEfficiency:
          actualFermenterEfficiency == null && nullToAbsent
          ? const Value.absent()
          : Value(actualFermenterEfficiency),
      predictedEthanolPercentage:
          predictedEthanolPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(predictedEthanolPercentage),
      actualEthanolPercentage: actualEthanolPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(actualEthanolPercentage),
      fermenterVesselQcAlert: fermenterVesselQcAlert == null && nullToAbsent
          ? const Value.absent()
          : Value(fermenterVesselQcAlert),
      predictedAt: Value(predictedAt),
    );
  }

  factory PredictionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PredictionData(
      id: serializer.fromJson<int>(json['id']),
      batchId: serializer.fromJson<int>(json['batchId']),
      processingRunId: serializer.fromJson<int>(json['processingRunId']),
      modelId: serializer.fromJson<int>(json['modelId']),
      predictionLabel: serializer.fromJson<String>(json['predictionLabel']),
      predictionConfidence: serializer.fromJson<double?>(
        json['predictionConfidence'],
      ),
      predictedProduction: serializer.fromJson<double?>(
        json['predictedProduction'],
      ),
      actualProduction: serializer.fromJson<double?>(json['actualProduction']),
      predictedFermenterEfficiency: serializer.fromJson<double?>(
        json['predictedFermenterEfficiency'],
      ),
      actualFermenterEfficiency: serializer.fromJson<double?>(
        json['actualFermenterEfficiency'],
      ),
      predictedEthanolPercentage: serializer.fromJson<double?>(
        json['predictedEthanolPercentage'],
      ),
      actualEthanolPercentage: serializer.fromJson<double?>(
        json['actualEthanolPercentage'],
      ),
      fermenterVesselQcAlert: serializer.fromJson<bool?>(
        json['fermenterVesselQcAlert'],
      ),
      predictedAt: serializer.fromJson<DateTime>(json['predictedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'batchId': serializer.toJson<int>(batchId),
      'processingRunId': serializer.toJson<int>(processingRunId),
      'modelId': serializer.toJson<int>(modelId),
      'predictionLabel': serializer.toJson<String>(predictionLabel),
      'predictionConfidence': serializer.toJson<double?>(predictionConfidence),
      'predictedProduction': serializer.toJson<double?>(predictedProduction),
      'actualProduction': serializer.toJson<double?>(actualProduction),
      'predictedFermenterEfficiency': serializer.toJson<double?>(
        predictedFermenterEfficiency,
      ),
      'actualFermenterEfficiency': serializer.toJson<double?>(
        actualFermenterEfficiency,
      ),
      'predictedEthanolPercentage': serializer.toJson<double?>(
        predictedEthanolPercentage,
      ),
      'actualEthanolPercentage': serializer.toJson<double?>(
        actualEthanolPercentage,
      ),
      'fermenterVesselQcAlert': serializer.toJson<bool?>(
        fermenterVesselQcAlert,
      ),
      'predictedAt': serializer.toJson<DateTime>(predictedAt),
    };
  }

  PredictionData copyWith({
    int? id,
    int? batchId,
    int? processingRunId,
    int? modelId,
    String? predictionLabel,
    Value<double?> predictionConfidence = const Value.absent(),
    Value<double?> predictedProduction = const Value.absent(),
    Value<double?> actualProduction = const Value.absent(),
    Value<double?> predictedFermenterEfficiency = const Value.absent(),
    Value<double?> actualFermenterEfficiency = const Value.absent(),
    Value<double?> predictedEthanolPercentage = const Value.absent(),
    Value<double?> actualEthanolPercentage = const Value.absent(),
    Value<bool?> fermenterVesselQcAlert = const Value.absent(),
    DateTime? predictedAt,
  }) => PredictionData(
    id: id ?? this.id,
    batchId: batchId ?? this.batchId,
    processingRunId: processingRunId ?? this.processingRunId,
    modelId: modelId ?? this.modelId,
    predictionLabel: predictionLabel ?? this.predictionLabel,
    predictionConfidence: predictionConfidence.present
        ? predictionConfidence.value
        : this.predictionConfidence,
    predictedProduction: predictedProduction.present
        ? predictedProduction.value
        : this.predictedProduction,
    actualProduction: actualProduction.present
        ? actualProduction.value
        : this.actualProduction,
    predictedFermenterEfficiency: predictedFermenterEfficiency.present
        ? predictedFermenterEfficiency.value
        : this.predictedFermenterEfficiency,
    actualFermenterEfficiency: actualFermenterEfficiency.present
        ? actualFermenterEfficiency.value
        : this.actualFermenterEfficiency,
    predictedEthanolPercentage: predictedEthanolPercentage.present
        ? predictedEthanolPercentage.value
        : this.predictedEthanolPercentage,
    actualEthanolPercentage: actualEthanolPercentage.present
        ? actualEthanolPercentage.value
        : this.actualEthanolPercentage,
    fermenterVesselQcAlert: fermenterVesselQcAlert.present
        ? fermenterVesselQcAlert.value
        : this.fermenterVesselQcAlert,
    predictedAt: predictedAt ?? this.predictedAt,
  );
  PredictionData copyWithCompanion(PredictionsCompanion data) {
    return PredictionData(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      processingRunId: data.processingRunId.present
          ? data.processingRunId.value
          : this.processingRunId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      predictionLabel: data.predictionLabel.present
          ? data.predictionLabel.value
          : this.predictionLabel,
      predictionConfidence: data.predictionConfidence.present
          ? data.predictionConfidence.value
          : this.predictionConfidence,
      predictedProduction: data.predictedProduction.present
          ? data.predictedProduction.value
          : this.predictedProduction,
      actualProduction: data.actualProduction.present
          ? data.actualProduction.value
          : this.actualProduction,
      predictedFermenterEfficiency: data.predictedFermenterEfficiency.present
          ? data.predictedFermenterEfficiency.value
          : this.predictedFermenterEfficiency,
      actualFermenterEfficiency: data.actualFermenterEfficiency.present
          ? data.actualFermenterEfficiency.value
          : this.actualFermenterEfficiency,
      predictedEthanolPercentage: data.predictedEthanolPercentage.present
          ? data.predictedEthanolPercentage.value
          : this.predictedEthanolPercentage,
      actualEthanolPercentage: data.actualEthanolPercentage.present
          ? data.actualEthanolPercentage.value
          : this.actualEthanolPercentage,
      fermenterVesselQcAlert: data.fermenterVesselQcAlert.present
          ? data.fermenterVesselQcAlert.value
          : this.fermenterVesselQcAlert,
      predictedAt: data.predictedAt.present
          ? data.predictedAt.value
          : this.predictedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PredictionData(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('processingRunId: $processingRunId, ')
          ..write('modelId: $modelId, ')
          ..write('predictionLabel: $predictionLabel, ')
          ..write('predictionConfidence: $predictionConfidence, ')
          ..write('predictedProduction: $predictedProduction, ')
          ..write('actualProduction: $actualProduction, ')
          ..write(
            'predictedFermenterEfficiency: $predictedFermenterEfficiency, ',
          )
          ..write('actualFermenterEfficiency: $actualFermenterEfficiency, ')
          ..write('predictedEthanolPercentage: $predictedEthanolPercentage, ')
          ..write('actualEthanolPercentage: $actualEthanolPercentage, ')
          ..write('fermenterVesselQcAlert: $fermenterVesselQcAlert, ')
          ..write('predictedAt: $predictedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    batchId,
    processingRunId,
    modelId,
    predictionLabel,
    predictionConfidence,
    predictedProduction,
    actualProduction,
    predictedFermenterEfficiency,
    actualFermenterEfficiency,
    predictedEthanolPercentage,
    actualEthanolPercentage,
    fermenterVesselQcAlert,
    predictedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PredictionData &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.processingRunId == this.processingRunId &&
          other.modelId == this.modelId &&
          other.predictionLabel == this.predictionLabel &&
          other.predictionConfidence == this.predictionConfidence &&
          other.predictedProduction == this.predictedProduction &&
          other.actualProduction == this.actualProduction &&
          other.predictedFermenterEfficiency ==
              this.predictedFermenterEfficiency &&
          other.actualFermenterEfficiency == this.actualFermenterEfficiency &&
          other.predictedEthanolPercentage == this.predictedEthanolPercentage &&
          other.actualEthanolPercentage == this.actualEthanolPercentage &&
          other.fermenterVesselQcAlert == this.fermenterVesselQcAlert &&
          other.predictedAt == this.predictedAt);
}

class PredictionsCompanion extends UpdateCompanion<PredictionData> {
  final Value<int> id;
  final Value<int> batchId;
  final Value<int> processingRunId;
  final Value<int> modelId;
  final Value<String> predictionLabel;
  final Value<double?> predictionConfidence;
  final Value<double?> predictedProduction;
  final Value<double?> actualProduction;
  final Value<double?> predictedFermenterEfficiency;
  final Value<double?> actualFermenterEfficiency;
  final Value<double?> predictedEthanolPercentage;
  final Value<double?> actualEthanolPercentage;
  final Value<bool?> fermenterVesselQcAlert;
  final Value<DateTime> predictedAt;
  const PredictionsCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.processingRunId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.predictionLabel = const Value.absent(),
    this.predictionConfidence = const Value.absent(),
    this.predictedProduction = const Value.absent(),
    this.actualProduction = const Value.absent(),
    this.predictedFermenterEfficiency = const Value.absent(),
    this.actualFermenterEfficiency = const Value.absent(),
    this.predictedEthanolPercentage = const Value.absent(),
    this.actualEthanolPercentage = const Value.absent(),
    this.fermenterVesselQcAlert = const Value.absent(),
    this.predictedAt = const Value.absent(),
  });
  PredictionsCompanion.insert({
    this.id = const Value.absent(),
    required int batchId,
    required int processingRunId,
    required int modelId,
    required String predictionLabel,
    this.predictionConfidence = const Value.absent(),
    this.predictedProduction = const Value.absent(),
    this.actualProduction = const Value.absent(),
    this.predictedFermenterEfficiency = const Value.absent(),
    this.actualFermenterEfficiency = const Value.absent(),
    this.predictedEthanolPercentage = const Value.absent(),
    this.actualEthanolPercentage = const Value.absent(),
    this.fermenterVesselQcAlert = const Value.absent(),
    this.predictedAt = const Value.absent(),
  }) : batchId = Value(batchId),
       processingRunId = Value(processingRunId),
       modelId = Value(modelId),
       predictionLabel = Value(predictionLabel);
  static Insertable<PredictionData> custom({
    Expression<int>? id,
    Expression<int>? batchId,
    Expression<int>? processingRunId,
    Expression<int>? modelId,
    Expression<String>? predictionLabel,
    Expression<double>? predictionConfidence,
    Expression<double>? predictedProduction,
    Expression<double>? actualProduction,
    Expression<double>? predictedFermenterEfficiency,
    Expression<double>? actualFermenterEfficiency,
    Expression<double>? predictedEthanolPercentage,
    Expression<double>? actualEthanolPercentage,
    Expression<bool>? fermenterVesselQcAlert,
    Expression<DateTime>? predictedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (processingRunId != null) 'processing_run_id': processingRunId,
      if (modelId != null) 'model_id': modelId,
      if (predictionLabel != null) 'prediction_label': predictionLabel,
      if (predictionConfidence != null)
        'prediction_confidence': predictionConfidence,
      if (predictedProduction != null)
        'predicted_production': predictedProduction,
      if (actualProduction != null) 'actual_production': actualProduction,
      if (predictedFermenterEfficiency != null)
        'predicted_fermenter_efficiency': predictedFermenterEfficiency,
      if (actualFermenterEfficiency != null)
        'actual_fermenter_efficiency': actualFermenterEfficiency,
      if (predictedEthanolPercentage != null)
        'predicted_ethanol_percentage': predictedEthanolPercentage,
      if (actualEthanolPercentage != null)
        'actual_ethanol_percentage': actualEthanolPercentage,
      if (fermenterVesselQcAlert != null)
        'fermenter_vessel_qc_alert': fermenterVesselQcAlert,
      if (predictedAt != null) 'predicted_at': predictedAt,
    });
  }

  PredictionsCompanion copyWith({
    Value<int>? id,
    Value<int>? batchId,
    Value<int>? processingRunId,
    Value<int>? modelId,
    Value<String>? predictionLabel,
    Value<double?>? predictionConfidence,
    Value<double?>? predictedProduction,
    Value<double?>? actualProduction,
    Value<double?>? predictedFermenterEfficiency,
    Value<double?>? actualFermenterEfficiency,
    Value<double?>? predictedEthanolPercentage,
    Value<double?>? actualEthanolPercentage,
    Value<bool?>? fermenterVesselQcAlert,
    Value<DateTime>? predictedAt,
  }) {
    return PredictionsCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      processingRunId: processingRunId ?? this.processingRunId,
      modelId: modelId ?? this.modelId,
      predictionLabel: predictionLabel ?? this.predictionLabel,
      predictionConfidence: predictionConfidence ?? this.predictionConfidence,
      predictedProduction: predictedProduction ?? this.predictedProduction,
      actualProduction: actualProduction ?? this.actualProduction,
      predictedFermenterEfficiency:
          predictedFermenterEfficiency ?? this.predictedFermenterEfficiency,
      actualFermenterEfficiency:
          actualFermenterEfficiency ?? this.actualFermenterEfficiency,
      predictedEthanolPercentage:
          predictedEthanolPercentage ?? this.predictedEthanolPercentage,
      actualEthanolPercentage:
          actualEthanolPercentage ?? this.actualEthanolPercentage,
      fermenterVesselQcAlert:
          fermenterVesselQcAlert ?? this.fermenterVesselQcAlert,
      predictedAt: predictedAt ?? this.predictedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    if (processingRunId.present) {
      map['processing_run_id'] = Variable<int>(processingRunId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<int>(modelId.value);
    }
    if (predictionLabel.present) {
      map['prediction_label'] = Variable<String>(predictionLabel.value);
    }
    if (predictionConfidence.present) {
      map['prediction_confidence'] = Variable<double>(
        predictionConfidence.value,
      );
    }
    if (predictedProduction.present) {
      map['predicted_production'] = Variable<double>(predictedProduction.value);
    }
    if (actualProduction.present) {
      map['actual_production'] = Variable<double>(actualProduction.value);
    }
    if (predictedFermenterEfficiency.present) {
      map['predicted_fermenter_efficiency'] = Variable<double>(
        predictedFermenterEfficiency.value,
      );
    }
    if (actualFermenterEfficiency.present) {
      map['actual_fermenter_efficiency'] = Variable<double>(
        actualFermenterEfficiency.value,
      );
    }
    if (predictedEthanolPercentage.present) {
      map['predicted_ethanol_percentage'] = Variable<double>(
        predictedEthanolPercentage.value,
      );
    }
    if (actualEthanolPercentage.present) {
      map['actual_ethanol_percentage'] = Variable<double>(
        actualEthanolPercentage.value,
      );
    }
    if (fermenterVesselQcAlert.present) {
      map['fermenter_vessel_qc_alert'] = Variable<bool>(
        fermenterVesselQcAlert.value,
      );
    }
    if (predictedAt.present) {
      map['predicted_at'] = Variable<DateTime>(predictedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PredictionsCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('processingRunId: $processingRunId, ')
          ..write('modelId: $modelId, ')
          ..write('predictionLabel: $predictionLabel, ')
          ..write('predictionConfidence: $predictionConfidence, ')
          ..write('predictedProduction: $predictedProduction, ')
          ..write('actualProduction: $actualProduction, ')
          ..write(
            'predictedFermenterEfficiency: $predictedFermenterEfficiency, ',
          )
          ..write('actualFermenterEfficiency: $actualFermenterEfficiency, ')
          ..write('predictedEthanolPercentage: $predictedEthanolPercentage, ')
          ..write('actualEthanolPercentage: $actualEthanolPercentage, ')
          ..write('fermenterVesselQcAlert: $fermenterVesselQcAlert, ')
          ..write('predictedAt: $predictedAt')
          ..write(')'))
        .toString();
  }
}

class $MqttPublishLogTable extends MqttPublishLog
    with TableInfo<$MqttPublishLogTable, MqttPublishLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MqttPublishLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _predictionIdMeta = const VerificationMeta(
    'predictionId',
  );
  @override
  late final GeneratedColumn<int> predictionId = GeneratedColumn<int>(
    'prediction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES predictions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qosMeta = const VerificationMeta('qos');
  @override
  late final GeneratedColumn<int> qos = GeneratedColumn<int>(
    'qos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    predictionId,
    topic,
    payload,
    qos,
    publishedAt,
    status,
    retryCount,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mqtt_publish_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<MqttPublishLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('prediction_id')) {
      context.handle(
        _predictionIdMeta,
        predictionId.isAcceptableOrUnknown(
          data['prediction_id']!,
          _predictionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_predictionIdMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('qos')) {
      context.handle(
        _qosMeta,
        qos.isAcceptableOrUnknown(data['qos']!, _qosMeta),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MqttPublishLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MqttPublishLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      predictionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prediction_id'],
      )!,
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      qos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qos'],
      )!,
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $MqttPublishLogTable createAlias(String alias) {
    return $MqttPublishLogTable(attachedDatabase, alias);
  }
}

class MqttPublishLogData extends DataClass
    implements Insertable<MqttPublishLogData> {
  final int id;
  final int predictionId;
  final String topic;
  final String payload;
  final int qos;
  final DateTime publishedAt;
  final String status;
  final int retryCount;
  final String? errorMessage;
  const MqttPublishLogData({
    required this.id,
    required this.predictionId,
    required this.topic,
    required this.payload,
    required this.qos,
    required this.publishedAt,
    required this.status,
    required this.retryCount,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['prediction_id'] = Variable<int>(predictionId);
    map['topic'] = Variable<String>(topic);
    map['payload'] = Variable<String>(payload);
    map['qos'] = Variable<int>(qos);
    map['published_at'] = Variable<DateTime>(publishedAt);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  MqttPublishLogCompanion toCompanion(bool nullToAbsent) {
    return MqttPublishLogCompanion(
      id: Value(id),
      predictionId: Value(predictionId),
      topic: Value(topic),
      payload: Value(payload),
      qos: Value(qos),
      publishedAt: Value(publishedAt),
      status: Value(status),
      retryCount: Value(retryCount),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory MqttPublishLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MqttPublishLogData(
      id: serializer.fromJson<int>(json['id']),
      predictionId: serializer.fromJson<int>(json['predictionId']),
      topic: serializer.fromJson<String>(json['topic']),
      payload: serializer.fromJson<String>(json['payload']),
      qos: serializer.fromJson<int>(json['qos']),
      publishedAt: serializer.fromJson<DateTime>(json['publishedAt']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'predictionId': serializer.toJson<int>(predictionId),
      'topic': serializer.toJson<String>(topic),
      'payload': serializer.toJson<String>(payload),
      'qos': serializer.toJson<int>(qos),
      'publishedAt': serializer.toJson<DateTime>(publishedAt),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  MqttPublishLogData copyWith({
    int? id,
    int? predictionId,
    String? topic,
    String? payload,
    int? qos,
    DateTime? publishedAt,
    String? status,
    int? retryCount,
    Value<String?> errorMessage = const Value.absent(),
  }) => MqttPublishLogData(
    id: id ?? this.id,
    predictionId: predictionId ?? this.predictionId,
    topic: topic ?? this.topic,
    payload: payload ?? this.payload,
    qos: qos ?? this.qos,
    publishedAt: publishedAt ?? this.publishedAt,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  MqttPublishLogData copyWithCompanion(MqttPublishLogCompanion data) {
    return MqttPublishLogData(
      id: data.id.present ? data.id.value : this.id,
      predictionId: data.predictionId.present
          ? data.predictionId.value
          : this.predictionId,
      topic: data.topic.present ? data.topic.value : this.topic,
      payload: data.payload.present ? data.payload.value : this.payload,
      qos: data.qos.present ? data.qos.value : this.qos,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MqttPublishLogData(')
          ..write('id: $id, ')
          ..write('predictionId: $predictionId, ')
          ..write('topic: $topic, ')
          ..write('payload: $payload, ')
          ..write('qos: $qos, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    predictionId,
    topic,
    payload,
    qos,
    publishedAt,
    status,
    retryCount,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MqttPublishLogData &&
          other.id == this.id &&
          other.predictionId == this.predictionId &&
          other.topic == this.topic &&
          other.payload == this.payload &&
          other.qos == this.qos &&
          other.publishedAt == this.publishedAt &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.errorMessage == this.errorMessage);
}

class MqttPublishLogCompanion extends UpdateCompanion<MqttPublishLogData> {
  final Value<int> id;
  final Value<int> predictionId;
  final Value<String> topic;
  final Value<String> payload;
  final Value<int> qos;
  final Value<DateTime> publishedAt;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String?> errorMessage;
  const MqttPublishLogCompanion({
    this.id = const Value.absent(),
    this.predictionId = const Value.absent(),
    this.topic = const Value.absent(),
    this.payload = const Value.absent(),
    this.qos = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
  });
  MqttPublishLogCompanion.insert({
    this.id = const Value.absent(),
    required int predictionId,
    required String topic,
    required String payload,
    this.qos = const Value.absent(),
    this.publishedAt = const Value.absent(),
    required String status,
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
  }) : predictionId = Value(predictionId),
       topic = Value(topic),
       payload = Value(payload),
       status = Value(status);
  static Insertable<MqttPublishLogData> custom({
    Expression<int>? id,
    Expression<int>? predictionId,
    Expression<String>? topic,
    Expression<String>? payload,
    Expression<int>? qos,
    Expression<DateTime>? publishedAt,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? errorMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (predictionId != null) 'prediction_id': predictionId,
      if (topic != null) 'topic': topic,
      if (payload != null) 'payload': payload,
      if (qos != null) 'qos': qos,
      if (publishedAt != null) 'published_at': publishedAt,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  MqttPublishLogCompanion copyWith({
    Value<int>? id,
    Value<int>? predictionId,
    Value<String>? topic,
    Value<String>? payload,
    Value<int>? qos,
    Value<DateTime>? publishedAt,
    Value<String>? status,
    Value<int>? retryCount,
    Value<String?>? errorMessage,
  }) {
    return MqttPublishLogCompanion(
      id: id ?? this.id,
      predictionId: predictionId ?? this.predictionId,
      topic: topic ?? this.topic,
      payload: payload ?? this.payload,
      qos: qos ?? this.qos,
      publishedAt: publishedAt ?? this.publishedAt,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (predictionId.present) {
      map['prediction_id'] = Variable<int>(predictionId.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (qos.present) {
      map['qos'] = Variable<int>(qos.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MqttPublishLogCompanion(')
          ..write('id: $id, ')
          ..write('predictionId: $predictionId, ')
          ..write('topic: $topic, ')
          ..write('payload: $payload, ')
          ..write('qos: $qos, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }
}

class $BackupHistoryTable extends BackupHistory
    with TableInfo<$BackupHistoryTable, BackupHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _backupStartedAtMeta = const VerificationMeta(
    'backupStartedAt',
  );
  @override
  late final GeneratedColumn<DateTime> backupStartedAt =
      GeneratedColumn<DateTime>(
        'backup_started_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _backupCompletedAtMeta = const VerificationMeta(
    'backupCompletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> backupCompletedAt =
      GeneratedColumn<DateTime>(
        'backup_completed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _backupFileNameMeta = const VerificationMeta(
    'backupFileName',
  );
  @override
  late final GeneratedColumn<String> backupFileName = GeneratedColumn<String>(
    'backup_file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backupLocationMeta = const VerificationMeta(
    'backupLocation',
  );
  @override
  late final GeneratedColumn<String> backupLocation = GeneratedColumn<String>(
    'backup_location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cloudProviderMeta = const VerificationMeta(
    'cloudProvider',
  );
  @override
  late final GeneratedColumn<String> cloudProvider = GeneratedColumn<String>(
    'cloud_provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _databaseSizeBytesMeta = const VerificationMeta(
    'databaseSizeBytes',
  );
  @override
  late final GeneratedColumn<BigInt> databaseSizeBytes =
      GeneratedColumn<BigInt>(
        'database_size_bytes',
        aliasedName,
        true,
        type: DriftSqlType.bigInt,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recordsBackedUpMeta = const VerificationMeta(
    'recordsBackedUp',
  );
  @override
  late final GeneratedColumn<int> recordsBackedUp = GeneratedColumn<int>(
    'records_backed_up',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verifiedAtMeta = const VerificationMeta(
    'verifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> verifiedAt = GeneratedColumn<DateTime>(
    'verified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedLocalRecordsMeta =
      const VerificationMeta('deletedLocalRecords');
  @override
  late final GeneratedColumn<int> deletedLocalRecords = GeneratedColumn<int>(
    'deleted_local_records',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    backupStartedAt,
    backupCompletedAt,
    backupFileName,
    backupLocation,
    cloudProvider,
    databaseSizeBytes,
    recordsBackedUp,
    status,
    verifiedAt,
    deletedLocalRecords,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('backup_started_at')) {
      context.handle(
        _backupStartedAtMeta,
        backupStartedAt.isAcceptableOrUnknown(
          data['backup_started_at']!,
          _backupStartedAtMeta,
        ),
      );
    }
    if (data.containsKey('backup_completed_at')) {
      context.handle(
        _backupCompletedAtMeta,
        backupCompletedAt.isAcceptableOrUnknown(
          data['backup_completed_at']!,
          _backupCompletedAtMeta,
        ),
      );
    }
    if (data.containsKey('backup_file_name')) {
      context.handle(
        _backupFileNameMeta,
        backupFileName.isAcceptableOrUnknown(
          data['backup_file_name']!,
          _backupFileNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_backupFileNameMeta);
    }
    if (data.containsKey('backup_location')) {
      context.handle(
        _backupLocationMeta,
        backupLocation.isAcceptableOrUnknown(
          data['backup_location']!,
          _backupLocationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_backupLocationMeta);
    }
    if (data.containsKey('cloud_provider')) {
      context.handle(
        _cloudProviderMeta,
        cloudProvider.isAcceptableOrUnknown(
          data['cloud_provider']!,
          _cloudProviderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cloudProviderMeta);
    }
    if (data.containsKey('database_size_bytes')) {
      context.handle(
        _databaseSizeBytesMeta,
        databaseSizeBytes.isAcceptableOrUnknown(
          data['database_size_bytes']!,
          _databaseSizeBytesMeta,
        ),
      );
    }
    if (data.containsKey('records_backed_up')) {
      context.handle(
        _recordsBackedUpMeta,
        recordsBackedUp.isAcceptableOrUnknown(
          data['records_backed_up']!,
          _recordsBackedUpMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('verified_at')) {
      context.handle(
        _verifiedAtMeta,
        verifiedAt.isAcceptableOrUnknown(data['verified_at']!, _verifiedAtMeta),
      );
    }
    if (data.containsKey('deleted_local_records')) {
      context.handle(
        _deletedLocalRecordsMeta,
        deletedLocalRecords.isAcceptableOrUnknown(
          data['deleted_local_records']!,
          _deletedLocalRecordsMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      backupStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}backup_started_at'],
      )!,
      backupCompletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}backup_completed_at'],
      ),
      backupFileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backup_file_name'],
      )!,
      backupLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backup_location'],
      )!,
      cloudProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_provider'],
      )!,
      databaseSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}database_size_bytes'],
      ),
      recordsBackedUp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}records_backed_up'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      verifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}verified_at'],
      ),
      deletedLocalRecords: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_local_records'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $BackupHistoryTable createAlias(String alias) {
    return $BackupHistoryTable(attachedDatabase, alias);
  }
}

class BackupHistoryData extends DataClass
    implements Insertable<BackupHistoryData> {
  final int id;
  final DateTime backupStartedAt;
  final DateTime? backupCompletedAt;
  final String backupFileName;
  final String backupLocation;
  final String cloudProvider;
  final BigInt? databaseSizeBytes;
  final int? recordsBackedUp;
  final String status;
  final DateTime? verifiedAt;
  final int? deletedLocalRecords;
  final String? errorMessage;
  const BackupHistoryData({
    required this.id,
    required this.backupStartedAt,
    this.backupCompletedAt,
    required this.backupFileName,
    required this.backupLocation,
    required this.cloudProvider,
    this.databaseSizeBytes,
    this.recordsBackedUp,
    required this.status,
    this.verifiedAt,
    this.deletedLocalRecords,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['backup_started_at'] = Variable<DateTime>(backupStartedAt);
    if (!nullToAbsent || backupCompletedAt != null) {
      map['backup_completed_at'] = Variable<DateTime>(backupCompletedAt);
    }
    map['backup_file_name'] = Variable<String>(backupFileName);
    map['backup_location'] = Variable<String>(backupLocation);
    map['cloud_provider'] = Variable<String>(cloudProvider);
    if (!nullToAbsent || databaseSizeBytes != null) {
      map['database_size_bytes'] = Variable<BigInt>(databaseSizeBytes);
    }
    if (!nullToAbsent || recordsBackedUp != null) {
      map['records_backed_up'] = Variable<int>(recordsBackedUp);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || verifiedAt != null) {
      map['verified_at'] = Variable<DateTime>(verifiedAt);
    }
    if (!nullToAbsent || deletedLocalRecords != null) {
      map['deleted_local_records'] = Variable<int>(deletedLocalRecords);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  BackupHistoryCompanion toCompanion(bool nullToAbsent) {
    return BackupHistoryCompanion(
      id: Value(id),
      backupStartedAt: Value(backupStartedAt),
      backupCompletedAt: backupCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(backupCompletedAt),
      backupFileName: Value(backupFileName),
      backupLocation: Value(backupLocation),
      cloudProvider: Value(cloudProvider),
      databaseSizeBytes: databaseSizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(databaseSizeBytes),
      recordsBackedUp: recordsBackedUp == null && nullToAbsent
          ? const Value.absent()
          : Value(recordsBackedUp),
      status: Value(status),
      verifiedAt: verifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(verifiedAt),
      deletedLocalRecords: deletedLocalRecords == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedLocalRecords),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory BackupHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupHistoryData(
      id: serializer.fromJson<int>(json['id']),
      backupStartedAt: serializer.fromJson<DateTime>(json['backupStartedAt']),
      backupCompletedAt: serializer.fromJson<DateTime?>(
        json['backupCompletedAt'],
      ),
      backupFileName: serializer.fromJson<String>(json['backupFileName']),
      backupLocation: serializer.fromJson<String>(json['backupLocation']),
      cloudProvider: serializer.fromJson<String>(json['cloudProvider']),
      databaseSizeBytes: serializer.fromJson<BigInt?>(
        json['databaseSizeBytes'],
      ),
      recordsBackedUp: serializer.fromJson<int?>(json['recordsBackedUp']),
      status: serializer.fromJson<String>(json['status']),
      verifiedAt: serializer.fromJson<DateTime?>(json['verifiedAt']),
      deletedLocalRecords: serializer.fromJson<int?>(
        json['deletedLocalRecords'],
      ),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'backupStartedAt': serializer.toJson<DateTime>(backupStartedAt),
      'backupCompletedAt': serializer.toJson<DateTime?>(backupCompletedAt),
      'backupFileName': serializer.toJson<String>(backupFileName),
      'backupLocation': serializer.toJson<String>(backupLocation),
      'cloudProvider': serializer.toJson<String>(cloudProvider),
      'databaseSizeBytes': serializer.toJson<BigInt?>(databaseSizeBytes),
      'recordsBackedUp': serializer.toJson<int?>(recordsBackedUp),
      'status': serializer.toJson<String>(status),
      'verifiedAt': serializer.toJson<DateTime?>(verifiedAt),
      'deletedLocalRecords': serializer.toJson<int?>(deletedLocalRecords),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  BackupHistoryData copyWith({
    int? id,
    DateTime? backupStartedAt,
    Value<DateTime?> backupCompletedAt = const Value.absent(),
    String? backupFileName,
    String? backupLocation,
    String? cloudProvider,
    Value<BigInt?> databaseSizeBytes = const Value.absent(),
    Value<int?> recordsBackedUp = const Value.absent(),
    String? status,
    Value<DateTime?> verifiedAt = const Value.absent(),
    Value<int?> deletedLocalRecords = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
  }) => BackupHistoryData(
    id: id ?? this.id,
    backupStartedAt: backupStartedAt ?? this.backupStartedAt,
    backupCompletedAt: backupCompletedAt.present
        ? backupCompletedAt.value
        : this.backupCompletedAt,
    backupFileName: backupFileName ?? this.backupFileName,
    backupLocation: backupLocation ?? this.backupLocation,
    cloudProvider: cloudProvider ?? this.cloudProvider,
    databaseSizeBytes: databaseSizeBytes.present
        ? databaseSizeBytes.value
        : this.databaseSizeBytes,
    recordsBackedUp: recordsBackedUp.present
        ? recordsBackedUp.value
        : this.recordsBackedUp,
    status: status ?? this.status,
    verifiedAt: verifiedAt.present ? verifiedAt.value : this.verifiedAt,
    deletedLocalRecords: deletedLocalRecords.present
        ? deletedLocalRecords.value
        : this.deletedLocalRecords,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  BackupHistoryData copyWithCompanion(BackupHistoryCompanion data) {
    return BackupHistoryData(
      id: data.id.present ? data.id.value : this.id,
      backupStartedAt: data.backupStartedAt.present
          ? data.backupStartedAt.value
          : this.backupStartedAt,
      backupCompletedAt: data.backupCompletedAt.present
          ? data.backupCompletedAt.value
          : this.backupCompletedAt,
      backupFileName: data.backupFileName.present
          ? data.backupFileName.value
          : this.backupFileName,
      backupLocation: data.backupLocation.present
          ? data.backupLocation.value
          : this.backupLocation,
      cloudProvider: data.cloudProvider.present
          ? data.cloudProvider.value
          : this.cloudProvider,
      databaseSizeBytes: data.databaseSizeBytes.present
          ? data.databaseSizeBytes.value
          : this.databaseSizeBytes,
      recordsBackedUp: data.recordsBackedUp.present
          ? data.recordsBackedUp.value
          : this.recordsBackedUp,
      status: data.status.present ? data.status.value : this.status,
      verifiedAt: data.verifiedAt.present
          ? data.verifiedAt.value
          : this.verifiedAt,
      deletedLocalRecords: data.deletedLocalRecords.present
          ? data.deletedLocalRecords.value
          : this.deletedLocalRecords,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupHistoryData(')
          ..write('id: $id, ')
          ..write('backupStartedAt: $backupStartedAt, ')
          ..write('backupCompletedAt: $backupCompletedAt, ')
          ..write('backupFileName: $backupFileName, ')
          ..write('backupLocation: $backupLocation, ')
          ..write('cloudProvider: $cloudProvider, ')
          ..write('databaseSizeBytes: $databaseSizeBytes, ')
          ..write('recordsBackedUp: $recordsBackedUp, ')
          ..write('status: $status, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('deletedLocalRecords: $deletedLocalRecords, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    backupStartedAt,
    backupCompletedAt,
    backupFileName,
    backupLocation,
    cloudProvider,
    databaseSizeBytes,
    recordsBackedUp,
    status,
    verifiedAt,
    deletedLocalRecords,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupHistoryData &&
          other.id == this.id &&
          other.backupStartedAt == this.backupStartedAt &&
          other.backupCompletedAt == this.backupCompletedAt &&
          other.backupFileName == this.backupFileName &&
          other.backupLocation == this.backupLocation &&
          other.cloudProvider == this.cloudProvider &&
          other.databaseSizeBytes == this.databaseSizeBytes &&
          other.recordsBackedUp == this.recordsBackedUp &&
          other.status == this.status &&
          other.verifiedAt == this.verifiedAt &&
          other.deletedLocalRecords == this.deletedLocalRecords &&
          other.errorMessage == this.errorMessage);
}

class BackupHistoryCompanion extends UpdateCompanion<BackupHistoryData> {
  final Value<int> id;
  final Value<DateTime> backupStartedAt;
  final Value<DateTime?> backupCompletedAt;
  final Value<String> backupFileName;
  final Value<String> backupLocation;
  final Value<String> cloudProvider;
  final Value<BigInt?> databaseSizeBytes;
  final Value<int?> recordsBackedUp;
  final Value<String> status;
  final Value<DateTime?> verifiedAt;
  final Value<int?> deletedLocalRecords;
  final Value<String?> errorMessage;
  const BackupHistoryCompanion({
    this.id = const Value.absent(),
    this.backupStartedAt = const Value.absent(),
    this.backupCompletedAt = const Value.absent(),
    this.backupFileName = const Value.absent(),
    this.backupLocation = const Value.absent(),
    this.cloudProvider = const Value.absent(),
    this.databaseSizeBytes = const Value.absent(),
    this.recordsBackedUp = const Value.absent(),
    this.status = const Value.absent(),
    this.verifiedAt = const Value.absent(),
    this.deletedLocalRecords = const Value.absent(),
    this.errorMessage = const Value.absent(),
  });
  BackupHistoryCompanion.insert({
    this.id = const Value.absent(),
    this.backupStartedAt = const Value.absent(),
    this.backupCompletedAt = const Value.absent(),
    required String backupFileName,
    required String backupLocation,
    required String cloudProvider,
    this.databaseSizeBytes = const Value.absent(),
    this.recordsBackedUp = const Value.absent(),
    required String status,
    this.verifiedAt = const Value.absent(),
    this.deletedLocalRecords = const Value.absent(),
    this.errorMessage = const Value.absent(),
  }) : backupFileName = Value(backupFileName),
       backupLocation = Value(backupLocation),
       cloudProvider = Value(cloudProvider),
       status = Value(status);
  static Insertable<BackupHistoryData> custom({
    Expression<int>? id,
    Expression<DateTime>? backupStartedAt,
    Expression<DateTime>? backupCompletedAt,
    Expression<String>? backupFileName,
    Expression<String>? backupLocation,
    Expression<String>? cloudProvider,
    Expression<BigInt>? databaseSizeBytes,
    Expression<int>? recordsBackedUp,
    Expression<String>? status,
    Expression<DateTime>? verifiedAt,
    Expression<int>? deletedLocalRecords,
    Expression<String>? errorMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (backupStartedAt != null) 'backup_started_at': backupStartedAt,
      if (backupCompletedAt != null) 'backup_completed_at': backupCompletedAt,
      if (backupFileName != null) 'backup_file_name': backupFileName,
      if (backupLocation != null) 'backup_location': backupLocation,
      if (cloudProvider != null) 'cloud_provider': cloudProvider,
      if (databaseSizeBytes != null) 'database_size_bytes': databaseSizeBytes,
      if (recordsBackedUp != null) 'records_backed_up': recordsBackedUp,
      if (status != null) 'status': status,
      if (verifiedAt != null) 'verified_at': verifiedAt,
      if (deletedLocalRecords != null)
        'deleted_local_records': deletedLocalRecords,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  BackupHistoryCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? backupStartedAt,
    Value<DateTime?>? backupCompletedAt,
    Value<String>? backupFileName,
    Value<String>? backupLocation,
    Value<String>? cloudProvider,
    Value<BigInt?>? databaseSizeBytes,
    Value<int?>? recordsBackedUp,
    Value<String>? status,
    Value<DateTime?>? verifiedAt,
    Value<int?>? deletedLocalRecords,
    Value<String?>? errorMessage,
  }) {
    return BackupHistoryCompanion(
      id: id ?? this.id,
      backupStartedAt: backupStartedAt ?? this.backupStartedAt,
      backupCompletedAt: backupCompletedAt ?? this.backupCompletedAt,
      backupFileName: backupFileName ?? this.backupFileName,
      backupLocation: backupLocation ?? this.backupLocation,
      cloudProvider: cloudProvider ?? this.cloudProvider,
      databaseSizeBytes: databaseSizeBytes ?? this.databaseSizeBytes,
      recordsBackedUp: recordsBackedUp ?? this.recordsBackedUp,
      status: status ?? this.status,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      deletedLocalRecords: deletedLocalRecords ?? this.deletedLocalRecords,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (backupStartedAt.present) {
      map['backup_started_at'] = Variable<DateTime>(backupStartedAt.value);
    }
    if (backupCompletedAt.present) {
      map['backup_completed_at'] = Variable<DateTime>(backupCompletedAt.value);
    }
    if (backupFileName.present) {
      map['backup_file_name'] = Variable<String>(backupFileName.value);
    }
    if (backupLocation.present) {
      map['backup_location'] = Variable<String>(backupLocation.value);
    }
    if (cloudProvider.present) {
      map['cloud_provider'] = Variable<String>(cloudProvider.value);
    }
    if (databaseSizeBytes.present) {
      map['database_size_bytes'] = Variable<BigInt>(databaseSizeBytes.value);
    }
    if (recordsBackedUp.present) {
      map['records_backed_up'] = Variable<int>(recordsBackedUp.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (verifiedAt.present) {
      map['verified_at'] = Variable<DateTime>(verifiedAt.value);
    }
    if (deletedLocalRecords.present) {
      map['deleted_local_records'] = Variable<int>(deletedLocalRecords.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupHistoryCompanion(')
          ..write('id: $id, ')
          ..write('backupStartedAt: $backupStartedAt, ')
          ..write('backupCompletedAt: $backupCompletedAt, ')
          ..write('backupFileName: $backupFileName, ')
          ..write('backupLocation: $backupLocation, ')
          ..write('cloudProvider: $cloudProvider, ')
          ..write('databaseSizeBytes: $databaseSizeBytes, ')
          ..write('recordsBackedUp: $recordsBackedUp, ')
          ..write('status: $status, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('deletedLocalRecords: $deletedLocalRecords, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FactoriesTable factories = $FactoriesTable(this);
  late final $InputFilesTable inputFiles = $InputFilesTable(this);
  late final $BatchesTable batches = $BatchesTable(this);
  late final $AiModelsTable aiModels = $AiModelsTable(this);
  late final $ProcessingRunsTable processingRuns = $ProcessingRunsTable(this);
  late final $PreprocessingDataTable preprocessingData =
      $PreprocessingDataTable(this);
  late final $PredictionsTable predictions = $PredictionsTable(this);
  late final $MqttPublishLogTable mqttPublishLog = $MqttPublishLogTable(this);
  late final $BackupHistoryTable backupHistory = $BackupHistoryTable(this);
  late final Index inputFilesFactoryStatusIdx = Index(
    'input_files_factory_status_idx',
    'CREATE INDEX input_files_factory_status_idx ON input_files (factory_id, status)',
  );
  late final Index batchesFactoryBatchIdx = Index(
    'batches_factory_batch_idx',
    'CREATE INDEX batches_factory_batch_idx ON batches (factory_id, batch_id)',
  );
  late final Index processingRunsInputFileIdx = Index(
    'processing_runs_input_file_idx',
    'CREATE INDEX processing_runs_input_file_idx ON processing_runs (input_file_id)',
  );
  late final Index processingRunsBatchIdx = Index(
    'processing_runs_batch_idx',
    'CREATE INDEX processing_runs_batch_idx ON processing_runs (batch_id)',
  );
  late final Index processingRunsStatusIdx = Index(
    'processing_runs_status_idx',
    'CREATE INDEX processing_runs_status_idx ON processing_runs (status)',
  );
  late final Index preprocessingDataBatchIdx = Index(
    'preprocessing_data_batch_idx',
    'CREATE INDEX preprocessing_data_batch_idx ON preprocessing_data (batch_id)',
  );
  late final Index preprocessingDataInputFileIdx = Index(
    'preprocessing_data_input_file_idx',
    'CREATE INDEX preprocessing_data_input_file_idx ON preprocessing_data (input_file_id)',
  );
  late final Index preprocessingDataProcessingRunIdx = Index(
    'preprocessing_data_processing_run_idx',
    'CREATE INDEX preprocessing_data_processing_run_idx ON preprocessing_data (processing_run_id)',
  );
  late final Index predictionsBatchIdx = Index(
    'predictions_batch_idx',
    'CREATE INDEX predictions_batch_idx ON predictions (batch_id)',
  );
  late final Index predictionsProcessingRunIdx = Index(
    'predictions_processing_run_idx',
    'CREATE INDEX predictions_processing_run_idx ON predictions (processing_run_id)',
  );
  late final Index predictionsPredictedAtIdx = Index(
    'predictions_predicted_at_idx',
    'CREATE INDEX predictions_predicted_at_idx ON predictions (predicted_at)',
  );
  late final Index mqttPublishLogPredictionIdx = Index(
    'mqtt_publish_log_prediction_idx',
    'CREATE INDEX mqtt_publish_log_prediction_idx ON mqtt_publish_log (prediction_id)',
  );
  late final Index mqttPublishLogStatusIdx = Index(
    'mqtt_publish_log_status_idx',
    'CREATE INDEX mqtt_publish_log_status_idx ON mqtt_publish_log (status)',
  );
  late final Index mqttPublishLogPublishedAtIdx = Index(
    'mqtt_publish_log_published_at_idx',
    'CREATE INDEX mqtt_publish_log_published_at_idx ON mqtt_publish_log (published_at)',
  );
  late final Index backupHistoryStatusIdx = Index(
    'backup_history_status_idx',
    'CREATE INDEX backup_history_status_idx ON backup_history (status)',
  );
  late final Index backupHistoryBackupStartedAtIdx = Index(
    'backup_history_backup_started_at_idx',
    'CREATE INDEX backup_history_backup_started_at_idx ON backup_history (backup_started_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    factories,
    inputFiles,
    batches,
    aiModels,
    processingRuns,
    preprocessingData,
    predictions,
    mqttPublishLog,
    backupHistory,
    inputFilesFactoryStatusIdx,
    batchesFactoryBatchIdx,
    processingRunsInputFileIdx,
    processingRunsBatchIdx,
    processingRunsStatusIdx,
    preprocessingDataBatchIdx,
    preprocessingDataInputFileIdx,
    preprocessingDataProcessingRunIdx,
    predictionsBatchIdx,
    predictionsProcessingRunIdx,
    predictionsPredictedAtIdx,
    mqttPublishLogPredictionIdx,
    mqttPublishLogStatusIdx,
    mqttPublishLogPublishedAtIdx,
    backupHistoryStatusIdx,
    backupHistoryBackupStartedAtIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'factories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('input_files', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'factories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('batches', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'input_files',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('batches', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'input_files',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('processing_runs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'batches',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('processing_runs', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ai_models',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('processing_runs', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'batches',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('preprocessing_data', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'input_files',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('preprocessing_data', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'processing_runs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('preprocessing_data', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'batches',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('predictions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'processing_runs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('predictions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'predictions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('mqtt_publish_log', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$FactoriesTableCreateCompanionBuilder = FactoriesCompanion Function({
  Value<int> id,
  required String factoryCode,
  required String factoryName,
  required String driveFolderId,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});
typedef $$FactoriesTableUpdateCompanionBuilder = FactoriesCompanion Function({
  Value<int> id,
  Value<String> factoryCode,
  Value<String> factoryName,
  Value<String> driveFolderId,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});

final class $$FactoriesTableReferences
    extends BaseReferences<_$AppDatabase, $FactoriesTable, FactoryData> {
  $$FactoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InputFilesTable, List<InputFileData>>
  _inputFilesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.inputFiles,
    aliasName: 'factories__id__input_files__factory_id',
  );

  $$InputFilesTableProcessedTableManager get inputFilesRefs {
    final manager = $$InputFilesTableTableManager(
      $_db,
      $_db.inputFiles,
    ).filter((f) => f.factoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_inputFilesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BatchesTable, List<BatchData>> _batchesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.batches,
    aliasName: 'factories__id__batches__factory_id',
  );

  $$BatchesTableProcessedTableManager get batchesRefs {
    final manager = $$BatchesTableTableManager(
      $_db,
      $_db.batches,
    ).filter((f) => f.factoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_batchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FactoriesTableFilterComposer
    extends Composer<_$AppDatabase, $FactoriesTable> {
  $$FactoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get factoryCode => $composableBuilder(
    column: $table.factoryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get factoryName => $composableBuilder(
    column: $table.factoryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driveFolderId => $composableBuilder(
    column: $table.driveFolderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> inputFilesRefs(
    Expression<bool> Function($$InputFilesTableFilterComposer f) f,
  ) {
    final $$InputFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inputFiles,
      getReferencedColumn: (t) => t.factoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InputFilesTableFilterComposer(
            $db: $db,
            $table: $db.inputFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> batchesRefs(
    Expression<bool> Function($$BatchesTableFilterComposer f) f,
  ) {
    final $$BatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.factoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableFilterComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FactoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FactoriesTable> {
  $$FactoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get factoryCode => $composableBuilder(
    column: $table.factoryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get factoryName => $composableBuilder(
    column: $table.factoryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driveFolderId => $composableBuilder(
    column: $table.driveFolderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FactoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FactoriesTable> {
  $$FactoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get factoryCode => $composableBuilder(
    column: $table.factoryCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get factoryName => $composableBuilder(
    column: $table.factoryName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get driveFolderId => $composableBuilder(
    column: $table.driveFolderId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> inputFilesRefs<T extends Object>(
    Expression<T> Function($$InputFilesTableAnnotationComposer a) f,
  ) {
    final $$InputFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inputFiles,
      getReferencedColumn: (t) => t.factoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InputFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.inputFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> batchesRefs<T extends Object>(
    Expression<T> Function($$BatchesTableAnnotationComposer a) f,
  ) {
    final $$BatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.factoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FactoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FactoriesTable,
          FactoryData,
          $$FactoriesTableFilterComposer,
          $$FactoriesTableOrderingComposer,
          $$FactoriesTableAnnotationComposer,
          $$FactoriesTableCreateCompanionBuilder,
          $$FactoriesTableUpdateCompanionBuilder,
          (FactoryData, $$FactoriesTableReferences),
          FactoryData,
          PrefetchHooks Function({bool inputFilesRefs, bool batchesRefs})
        > {
  $$FactoriesTableTableManager(_$AppDatabase db, $FactoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FactoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FactoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FactoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> factoryCode = const Value.absent(),
                Value<String> factoryName = const Value.absent(),
                Value<String> driveFolderId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FactoriesCompanion(
                id: id,
                factoryCode: factoryCode,
                factoryName: factoryName,
                driveFolderId: driveFolderId,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String factoryCode,
                required String factoryName,
                required String driveFolderId,
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FactoriesCompanion.insert(
                id: id,
                factoryCode: factoryCode,
                factoryName: factoryName,
                driveFolderId: driveFolderId,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FactoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({inputFilesRefs = false, batchesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (inputFilesRefs) db.inputFiles,
                    if (batchesRefs) db.batches,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (inputFilesRefs)
                        await $_getPrefetchedData<
                          FactoryData,
                          $FactoriesTable,
                          InputFileData
                        >(
                          currentTable: table,
                          referencedTable: $$FactoriesTableReferences
                              ._inputFilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FactoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).inputFilesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.factoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (batchesRefs)
                        await $_getPrefetchedData<
                          FactoryData,
                          $FactoriesTable,
                          BatchData
                        >(
                          currentTable: table,
                          referencedTable: $$FactoriesTableReferences
                              ._batchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FactoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).batchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.factoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FactoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FactoriesTable,
      FactoryData,
      $$FactoriesTableFilterComposer,
      $$FactoriesTableOrderingComposer,
      $$FactoriesTableAnnotationComposer,
      $$FactoriesTableCreateCompanionBuilder,
      $$FactoriesTableUpdateCompanionBuilder,
      (FactoryData, $$FactoriesTableReferences),
      FactoryData,
      PrefetchHooks Function({bool inputFilesRefs, bool batchesRefs})
    >;
typedef $$InputFilesTableCreateCompanionBuilder = InputFilesCompanion Function({
  Value<int> id,
  required int factoryId,
  required String driveFileId,
  required String fileName,
  Value<String?> fileType,
  Value<BigInt?> fileSizeBytes,
  Value<DateTime?> driveModifiedAt,
  Value<String?> fileHash,
  required String status,
  Value<DateTime?> firstSeenAt,
  Value<DateTime?> lastSeenAt,
  Value<DateTime?> lastProcessedAt,
  Value<String?> errorMessage,
  Value<DateTime> createdAt,
});
typedef $$InputFilesTableUpdateCompanionBuilder = InputFilesCompanion Function({
  Value<int> id,
  Value<int> factoryId,
  Value<String> driveFileId,
  Value<String> fileName,
  Value<String?> fileType,
  Value<BigInt?> fileSizeBytes,
  Value<DateTime?> driveModifiedAt,
  Value<String?> fileHash,
  Value<String> status,
  Value<DateTime?> firstSeenAt,
  Value<DateTime?> lastSeenAt,
  Value<DateTime?> lastProcessedAt,
  Value<String?> errorMessage,
  Value<DateTime> createdAt,
});

final class $$InputFilesTableReferences
    extends BaseReferences<_$AppDatabase, $InputFilesTable, InputFileData> {
  $$InputFilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FactoriesTable _factoryIdTable(_$AppDatabase db) =>
      db.factories.createAlias('input_files__factory_id__factories__id');

  $$FactoriesTableProcessedTableManager get factoryId {
    final $_column = $_itemColumn<int>('factory_id')!;

    final manager = $$FactoriesTableTableManager(
      $_db,
      $_db.factories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_factoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BatchesTable, List<BatchData>> _batchesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.batches,
    aliasName: 'input_files__id__batches__input_file_id',
  );

  $$BatchesTableProcessedTableManager get batchesRefs {
    final manager = $$BatchesTableTableManager(
      $_db,
      $_db.batches,
    ).filter((f) => f.inputFileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_batchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProcessingRunsTable, List<ProcessingRunData>>
  _processingRunsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.processingRuns,
    aliasName: 'input_files__id__processing_runs__input_file_id',
  );

  $$ProcessingRunsTableProcessedTableManager get processingRunsRefs {
    final manager = $$ProcessingRunsTableTableManager(
      $_db,
      $_db.processingRuns,
    ).filter((f) => f.inputFileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_processingRunsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PreprocessingDataTable,
    List<PreprocessingDataRecord>
  >
  _preprocessingDataRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.preprocessingData,
        aliasName: 'input_files__id__preprocessing_data__input_file_id',
      );

  $$PreprocessingDataTableProcessedTableManager get preprocessingDataRefs {
    final manager = $$PreprocessingDataTableTableManager(
      $_db,
      $_db.preprocessingData,
    ).filter((f) => f.inputFileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _preprocessingDataRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InputFilesTableFilterComposer
    extends Composer<_$AppDatabase, $InputFilesTable> {
  $$InputFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driveFileId => $composableBuilder(
    column: $table.driveFileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get driveModifiedAt => $composableBuilder(
    column: $table.driveModifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileHash => $composableBuilder(
    column: $table.fileHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastProcessedAt => $composableBuilder(
    column: $table.lastProcessedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FactoriesTableFilterComposer get factoryId {
    final $$FactoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.factoryId,
      referencedTable: $db.factories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactoriesTableFilterComposer(
            $db: $db,
            $table: $db.factories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> batchesRefs(
    Expression<bool> Function($$BatchesTableFilterComposer f) f,
  ) {
    final $$BatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.inputFileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableFilterComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> processingRunsRefs(
    Expression<bool> Function($$ProcessingRunsTableFilterComposer f) f,
  ) {
    final $$ProcessingRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.processingRuns,
      getReferencedColumn: (t) => t.inputFileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProcessingRunsTableFilterComposer(
            $db: $db,
            $table: $db.processingRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> preprocessingDataRefs(
    Expression<bool> Function($$PreprocessingDataTableFilterComposer f) f,
  ) {
    final $$PreprocessingDataTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.preprocessingData,
      getReferencedColumn: (t) => t.inputFileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreprocessingDataTableFilterComposer(
            $db: $db,
            $table: $db.preprocessingData,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InputFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $InputFilesTable> {
  $$InputFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driveFileId => $composableBuilder(
    column: $table.driveFileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get driveModifiedAt => $composableBuilder(
    column: $table.driveModifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileHash => $composableBuilder(
    column: $table.fileHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastProcessedAt => $composableBuilder(
    column: $table.lastProcessedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FactoriesTableOrderingComposer get factoryId {
    final $$FactoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.factoryId,
      referencedTable: $db.factories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactoriesTableOrderingComposer(
            $db: $db,
            $table: $db.factories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InputFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InputFilesTable> {
  $$InputFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get driveFileId => $composableBuilder(
    column: $table.driveFileId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get fileType =>
      $composableBuilder(column: $table.fileType, builder: (column) => column);

  GeneratedColumn<BigInt> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get driveModifiedAt => $composableBuilder(
    column: $table.driveModifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileHash =>
      $composableBuilder(column: $table.fileHash, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastProcessedAt => $composableBuilder(
    column: $table.lastProcessedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$FactoriesTableAnnotationComposer get factoryId {
    final $$FactoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.factoryId,
      referencedTable: $db.factories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.factories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> batchesRefs<T extends Object>(
    Expression<T> Function($$BatchesTableAnnotationComposer a) f,
  ) {
    final $$BatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.inputFileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> processingRunsRefs<T extends Object>(
    Expression<T> Function($$ProcessingRunsTableAnnotationComposer a) f,
  ) {
    final $$ProcessingRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.processingRuns,
      getReferencedColumn: (t) => t.inputFileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProcessingRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.processingRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> preprocessingDataRefs<T extends Object>(
    Expression<T> Function($$PreprocessingDataTableAnnotationComposer a) f,
  ) {
    final $$PreprocessingDataTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.preprocessingData,
          getReferencedColumn: (t) => t.inputFileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PreprocessingDataTableAnnotationComposer(
                $db: $db,
                $table: $db.preprocessingData,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$InputFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InputFilesTable,
          InputFileData,
          $$InputFilesTableFilterComposer,
          $$InputFilesTableOrderingComposer,
          $$InputFilesTableAnnotationComposer,
          $$InputFilesTableCreateCompanionBuilder,
          $$InputFilesTableUpdateCompanionBuilder,
          (InputFileData, $$InputFilesTableReferences),
          InputFileData,
          PrefetchHooks Function({
            bool factoryId,
            bool batchesRefs,
            bool processingRunsRefs,
            bool preprocessingDataRefs,
          })
        > {
  $$InputFilesTableTableManager(_$AppDatabase db, $InputFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InputFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InputFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InputFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> factoryId = const Value.absent(),
                Value<String> driveFileId = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String?> fileType = const Value.absent(),
                Value<BigInt?> fileSizeBytes = const Value.absent(),
                Value<DateTime?> driveModifiedAt = const Value.absent(),
                Value<String?> fileHash = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> firstSeenAt = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<DateTime?> lastProcessedAt = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => InputFilesCompanion(
                id: id,
                factoryId: factoryId,
                driveFileId: driveFileId,
                fileName: fileName,
                fileType: fileType,
                fileSizeBytes: fileSizeBytes,
                driveModifiedAt: driveModifiedAt,
                fileHash: fileHash,
                status: status,
                firstSeenAt: firstSeenAt,
                lastSeenAt: lastSeenAt,
                lastProcessedAt: lastProcessedAt,
                errorMessage: errorMessage,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int factoryId,
                required String driveFileId,
                required String fileName,
                Value<String?> fileType = const Value.absent(),
                Value<BigInt?> fileSizeBytes = const Value.absent(),
                Value<DateTime?> driveModifiedAt = const Value.absent(),
                Value<String?> fileHash = const Value.absent(),
                required String status,
                Value<DateTime?> firstSeenAt = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<DateTime?> lastProcessedAt = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => InputFilesCompanion.insert(
                id: id,
                factoryId: factoryId,
                driveFileId: driveFileId,
                fileName: fileName,
                fileType: fileType,
                fileSizeBytes: fileSizeBytes,
                driveModifiedAt: driveModifiedAt,
                fileHash: fileHash,
                status: status,
                firstSeenAt: firstSeenAt,
                lastSeenAt: lastSeenAt,
                lastProcessedAt: lastProcessedAt,
                errorMessage: errorMessage,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InputFilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                factoryId = false,
                batchesRefs = false,
                processingRunsRefs = false,
                preprocessingDataRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (batchesRefs) db.batches,
                    if (processingRunsRefs) db.processingRuns,
                    if (preprocessingDataRefs) db.preprocessingData,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (factoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.factoryId,
                            referencedTable: $$InputFilesTableReferences
                                ._factoryIdTable(db),
                            referencedColumn: $$InputFilesTableReferences
                                ._factoryIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (batchesRefs)
                        await $_getPrefetchedData<
                          InputFileData,
                          $InputFilesTable,
                          BatchData
                        >(
                          currentTable: table,
                          referencedTable: $$InputFilesTableReferences
                              ._batchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InputFilesTableReferences(
                                db,
                                table,
                                p0,
                              ).batchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.inputFileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (processingRunsRefs)
                        await $_getPrefetchedData<
                          InputFileData,
                          $InputFilesTable,
                          ProcessingRunData
                        >(
                          currentTable: table,
                          referencedTable: $$InputFilesTableReferences
                              ._processingRunsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InputFilesTableReferences(
                                db,
                                table,
                                p0,
                              ).processingRunsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.inputFileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (preprocessingDataRefs)
                        await $_getPrefetchedData<
                          InputFileData,
                          $InputFilesTable,
                          PreprocessingDataRecord
                        >(
                          currentTable: table,
                          referencedTable: $$InputFilesTableReferences
                              ._preprocessingDataRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InputFilesTableReferences(
                                db,
                                table,
                                p0,
                              ).preprocessingDataRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.inputFileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$InputFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InputFilesTable,
      InputFileData,
      $$InputFilesTableFilterComposer,
      $$InputFilesTableOrderingComposer,
      $$InputFilesTableAnnotationComposer,
      $$InputFilesTableCreateCompanionBuilder,
      $$InputFilesTableUpdateCompanionBuilder,
      (InputFileData, $$InputFilesTableReferences),
      InputFileData,
      PrefetchHooks Function({
        bool factoryId,
        bool batchesRefs,
        bool processingRunsRefs,
        bool preprocessingDataRefs,
      })
    >;
typedef $$BatchesTableCreateCompanionBuilder = BatchesCompanion Function({
  Value<int> id,
  required int factoryId,
  required int inputFileId,
  required String batchId,
  Value<String?> fermenter,
  Value<String?> state,
  Value<DateTime?> batchStartTime,
  Value<DateTime?> batchEndTime,
  Value<DateTime> createdAt,
});
typedef $$BatchesTableUpdateCompanionBuilder = BatchesCompanion Function({
  Value<int> id,
  Value<int> factoryId,
  Value<int> inputFileId,
  Value<String> batchId,
  Value<String?> fermenter,
  Value<String?> state,
  Value<DateTime?> batchStartTime,
  Value<DateTime?> batchEndTime,
  Value<DateTime> createdAt,
});

final class $$BatchesTableReferences
    extends BaseReferences<_$AppDatabase, $BatchesTable, BatchData> {
  $$BatchesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FactoriesTable _factoryIdTable(_$AppDatabase db) =>
      db.factories.createAlias('batches__factory_id__factories__id');

  $$FactoriesTableProcessedTableManager get factoryId {
    final $_column = $_itemColumn<int>('factory_id')!;

    final manager = $$FactoriesTableTableManager(
      $_db,
      $_db.factories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_factoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InputFilesTable _inputFileIdTable(_$AppDatabase db) =>
      db.inputFiles.createAlias('batches__input_file_id__input_files__id');

  $$InputFilesTableProcessedTableManager get inputFileId {
    final $_column = $_itemColumn<int>('input_file_id')!;

    final manager = $$InputFilesTableTableManager(
      $_db,
      $_db.inputFiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_inputFileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ProcessingRunsTable, List<ProcessingRunData>>
  _processingRunsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.processingRuns,
    aliasName: 'batches__id__processing_runs__batch_id',
  );

  $$ProcessingRunsTableProcessedTableManager get processingRunsRefs {
    final manager = $$ProcessingRunsTableTableManager(
      $_db,
      $_db.processingRuns,
    ).filter((f) => f.batchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_processingRunsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PreprocessingDataTable,
    List<PreprocessingDataRecord>
  >
  _preprocessingDataRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.preprocessingData,
        aliasName: 'batches__id__preprocessing_data__batch_id',
      );

  $$PreprocessingDataTableProcessedTableManager get preprocessingDataRefs {
    final manager = $$PreprocessingDataTableTableManager(
      $_db,
      $_db.preprocessingData,
    ).filter((f) => f.batchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _preprocessingDataRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PredictionsTable, List<PredictionData>>
  _predictionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.predictions,
    aliasName: 'batches__id__predictions__batch_id',
  );

  $$PredictionsTableProcessedTableManager get predictionsRefs {
    final manager = $$PredictionsTableTableManager(
      $_db,
      $_db.predictions,
    ).filter((f) => f.batchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_predictionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BatchesTableFilterComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fermenter => $composableBuilder(
    column: $table.fermenter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get batchStartTime => $composableBuilder(
    column: $table.batchStartTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get batchEndTime => $composableBuilder(
    column: $table.batchEndTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FactoriesTableFilterComposer get factoryId {
    final $$FactoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.factoryId,
      referencedTable: $db.factories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactoriesTableFilterComposer(
            $db: $db,
            $table: $db.factories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InputFilesTableFilterComposer get inputFileId {
    final $$InputFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inputFileId,
      referencedTable: $db.inputFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InputFilesTableFilterComposer(
            $db: $db,
            $table: $db.inputFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> processingRunsRefs(
    Expression<bool> Function($$ProcessingRunsTableFilterComposer f) f,
  ) {
    final $$ProcessingRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.processingRuns,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProcessingRunsTableFilterComposer(
            $db: $db,
            $table: $db.processingRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> preprocessingDataRefs(
    Expression<bool> Function($$PreprocessingDataTableFilterComposer f) f,
  ) {
    final $$PreprocessingDataTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.preprocessingData,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreprocessingDataTableFilterComposer(
            $db: $db,
            $table: $db.preprocessingData,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> predictionsRefs(
    Expression<bool> Function($$PredictionsTableFilterComposer f) f,
  ) {
    final $$PredictionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.predictions,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredictionsTableFilterComposer(
            $db: $db,
            $table: $db.predictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fermenter => $composableBuilder(
    column: $table.fermenter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get batchStartTime => $composableBuilder(
    column: $table.batchStartTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get batchEndTime => $composableBuilder(
    column: $table.batchEndTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FactoriesTableOrderingComposer get factoryId {
    final $$FactoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.factoryId,
      referencedTable: $db.factories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactoriesTableOrderingComposer(
            $db: $db,
            $table: $db.factories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InputFilesTableOrderingComposer get inputFileId {
    final $$InputFilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inputFileId,
      referencedTable: $db.inputFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InputFilesTableOrderingComposer(
            $db: $db,
            $table: $db.inputFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get fermenter =>
      $composableBuilder(column: $table.fermenter, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get batchStartTime => $composableBuilder(
    column: $table.batchStartTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get batchEndTime => $composableBuilder(
    column: $table.batchEndTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$FactoriesTableAnnotationComposer get factoryId {
    final $$FactoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.factoryId,
      referencedTable: $db.factories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.factories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InputFilesTableAnnotationComposer get inputFileId {
    final $$InputFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inputFileId,
      referencedTable: $db.inputFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InputFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.inputFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> processingRunsRefs<T extends Object>(
    Expression<T> Function($$ProcessingRunsTableAnnotationComposer a) f,
  ) {
    final $$ProcessingRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.processingRuns,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProcessingRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.processingRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> preprocessingDataRefs<T extends Object>(
    Expression<T> Function($$PreprocessingDataTableAnnotationComposer a) f,
  ) {
    final $$PreprocessingDataTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.preprocessingData,
          getReferencedColumn: (t) => t.batchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PreprocessingDataTableAnnotationComposer(
                $db: $db,
                $table: $db.preprocessingData,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> predictionsRefs<T extends Object>(
    Expression<T> Function($$PredictionsTableAnnotationComposer a) f,
  ) {
    final $$PredictionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.predictions,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredictionsTableAnnotationComposer(
            $db: $db,
            $table: $db.predictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BatchesTable,
          BatchData,
          $$BatchesTableFilterComposer,
          $$BatchesTableOrderingComposer,
          $$BatchesTableAnnotationComposer,
          $$BatchesTableCreateCompanionBuilder,
          $$BatchesTableUpdateCompanionBuilder,
          (BatchData, $$BatchesTableReferences),
          BatchData,
          PrefetchHooks Function({
            bool factoryId,
            bool inputFileId,
            bool processingRunsRefs,
            bool preprocessingDataRefs,
            bool predictionsRefs,
          })
        > {
  $$BatchesTableTableManager(_$AppDatabase db, $BatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> factoryId = const Value.absent(),
                Value<int> inputFileId = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<String?> fermenter = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<DateTime?> batchStartTime = const Value.absent(),
                Value<DateTime?> batchEndTime = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BatchesCompanion(
                id: id,
                factoryId: factoryId,
                inputFileId: inputFileId,
                batchId: batchId,
                fermenter: fermenter,
                state: state,
                batchStartTime: batchStartTime,
                batchEndTime: batchEndTime,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int factoryId,
                required int inputFileId,
                required String batchId,
                Value<String?> fermenter = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<DateTime?> batchStartTime = const Value.absent(),
                Value<DateTime?> batchEndTime = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BatchesCompanion.insert(
                id: id,
                factoryId: factoryId,
                inputFileId: inputFileId,
                batchId: batchId,
                fermenter: fermenter,
                state: state,
                batchStartTime: batchStartTime,
                batchEndTime: batchEndTime,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BatchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                factoryId = false,
                inputFileId = false,
                processingRunsRefs = false,
                preprocessingDataRefs = false,
                predictionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (processingRunsRefs) db.processingRuns,
                    if (preprocessingDataRefs) db.preprocessingData,
                    if (predictionsRefs) db.predictions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (factoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.factoryId,
                            referencedTable: $$BatchesTableReferences
                                ._factoryIdTable(db),
                            referencedColumn: $$BatchesTableReferences
                                ._factoryIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (inputFileId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.inputFileId,
                            referencedTable: $$BatchesTableReferences
                                ._inputFileIdTable(db),
                            referencedColumn: $$BatchesTableReferences
                                ._inputFileIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (processingRunsRefs)
                        await $_getPrefetchedData<
                          BatchData,
                          $BatchesTable,
                          ProcessingRunData
                        >(
                          currentTable: table,
                          referencedTable: $$BatchesTableReferences
                              ._processingRunsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).processingRunsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.batchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (preprocessingDataRefs)
                        await $_getPrefetchedData<
                          BatchData,
                          $BatchesTable,
                          PreprocessingDataRecord
                        >(
                          currentTable: table,
                          referencedTable: $$BatchesTableReferences
                              ._preprocessingDataRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).preprocessingDataRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.batchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (predictionsRefs)
                        await $_getPrefetchedData<
                          BatchData,
                          $BatchesTable,
                          PredictionData
                        >(
                          currentTable: table,
                          referencedTable: $$BatchesTableReferences
                              ._predictionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).predictionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.batchId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BatchesTable,
      BatchData,
      $$BatchesTableFilterComposer,
      $$BatchesTableOrderingComposer,
      $$BatchesTableAnnotationComposer,
      $$BatchesTableCreateCompanionBuilder,
      $$BatchesTableUpdateCompanionBuilder,
      (BatchData, $$BatchesTableReferences),
      BatchData,
      PrefetchHooks Function({
        bool factoryId,
        bool inputFileId,
        bool processingRunsRefs,
        bool preprocessingDataRefs,
        bool predictionsRefs,
      })
    >;
typedef $$AiModelsTableCreateCompanionBuilder = AiModelsCompanion Function({
  Value<int> id,
  required String modelName,
  required String modelVersion,
  required String modelType,
  Value<String?> modelPath,
  Value<DateTime?> trainedAt,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});
typedef $$AiModelsTableUpdateCompanionBuilder = AiModelsCompanion Function({
  Value<int> id,
  Value<String> modelName,
  Value<String> modelVersion,
  Value<String> modelType,
  Value<String?> modelPath,
  Value<DateTime?> trainedAt,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});

final class $$AiModelsTableReferences
    extends BaseReferences<_$AppDatabase, $AiModelsTable, AiModelData> {
  $$AiModelsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProcessingRunsTable, List<ProcessingRunData>>
  _processingRunsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.processingRuns,
    aliasName: 'ai_models__id__processing_runs__model_id',
  );

  $$ProcessingRunsTableProcessedTableManager get processingRunsRefs {
    final manager = $$ProcessingRunsTableTableManager(
      $_db,
      $_db.processingRuns,
    ).filter((f) => f.modelId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_processingRunsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PredictionsTable, List<PredictionData>>
  _predictionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.predictions,
    aliasName: 'ai_models__id__predictions__model_id',
  );

  $$PredictionsTableProcessedTableManager get predictionsRefs {
    final manager = $$PredictionsTableTableManager(
      $_db,
      $_db.predictions,
    ).filter((f) => f.modelId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_predictionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AiModelsTableFilterComposer
    extends Composer<_$AppDatabase, $AiModelsTable> {
  $$AiModelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelType => $composableBuilder(
    column: $table.modelType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelPath => $composableBuilder(
    column: $table.modelPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get trainedAt => $composableBuilder(
    column: $table.trainedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> processingRunsRefs(
    Expression<bool> Function($$ProcessingRunsTableFilterComposer f) f,
  ) {
    final $$ProcessingRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.processingRuns,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProcessingRunsTableFilterComposer(
            $db: $db,
            $table: $db.processingRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> predictionsRefs(
    Expression<bool> Function($$PredictionsTableFilterComposer f) f,
  ) {
    final $$PredictionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.predictions,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredictionsTableFilterComposer(
            $db: $db,
            $table: $db.predictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AiModelsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiModelsTable> {
  $$AiModelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelType => $composableBuilder(
    column: $table.modelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelPath => $composableBuilder(
    column: $table.modelPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get trainedAt => $composableBuilder(
    column: $table.trainedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiModelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiModelsTable> {
  $$AiModelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelType =>
      $composableBuilder(column: $table.modelType, builder: (column) => column);

  GeneratedColumn<String> get modelPath =>
      $composableBuilder(column: $table.modelPath, builder: (column) => column);

  GeneratedColumn<DateTime> get trainedAt =>
      $composableBuilder(column: $table.trainedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> processingRunsRefs<T extends Object>(
    Expression<T> Function($$ProcessingRunsTableAnnotationComposer a) f,
  ) {
    final $$ProcessingRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.processingRuns,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProcessingRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.processingRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> predictionsRefs<T extends Object>(
    Expression<T> Function($$PredictionsTableAnnotationComposer a) f,
  ) {
    final $$PredictionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.predictions,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredictionsTableAnnotationComposer(
            $db: $db,
            $table: $db.predictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AiModelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiModelsTable,
          AiModelData,
          $$AiModelsTableFilterComposer,
          $$AiModelsTableOrderingComposer,
          $$AiModelsTableAnnotationComposer,
          $$AiModelsTableCreateCompanionBuilder,
          $$AiModelsTableUpdateCompanionBuilder,
          (AiModelData, $$AiModelsTableReferences),
          AiModelData,
          PrefetchHooks Function({
            bool processingRunsRefs,
            bool predictionsRefs,
          })
        > {
  $$AiModelsTableTableManager(_$AppDatabase db, $AiModelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiModelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiModelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiModelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
                Value<String> modelType = const Value.absent(),
                Value<String?> modelPath = const Value.absent(),
                Value<DateTime?> trainedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AiModelsCompanion(
                id: id,
                modelName: modelName,
                modelVersion: modelVersion,
                modelType: modelType,
                modelPath: modelPath,
                trainedAt: trainedAt,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String modelName,
                required String modelVersion,
                required String modelType,
                Value<String?> modelPath = const Value.absent(),
                Value<DateTime?> trainedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AiModelsCompanion.insert(
                id: id,
                modelName: modelName,
                modelVersion: modelVersion,
                modelType: modelType,
                modelPath: modelPath,
                trainedAt: trainedAt,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AiModelsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({processingRunsRefs = false, predictionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (processingRunsRefs) db.processingRuns,
                    if (predictionsRefs) db.predictions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (processingRunsRefs)
                        await $_getPrefetchedData<
                          AiModelData,
                          $AiModelsTable,
                          ProcessingRunData
                        >(
                          currentTable: table,
                          referencedTable: $$AiModelsTableReferences
                              ._processingRunsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AiModelsTableReferences(
                                db,
                                table,
                                p0,
                              ).processingRunsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.modelId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (predictionsRefs)
                        await $_getPrefetchedData<
                          AiModelData,
                          $AiModelsTable,
                          PredictionData
                        >(
                          currentTable: table,
                          referencedTable: $$AiModelsTableReferences
                              ._predictionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AiModelsTableReferences(
                                db,
                                table,
                                p0,
                              ).predictionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.modelId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AiModelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiModelsTable,
      AiModelData,
      $$AiModelsTableFilterComposer,
      $$AiModelsTableOrderingComposer,
      $$AiModelsTableAnnotationComposer,
      $$AiModelsTableCreateCompanionBuilder,
      $$AiModelsTableUpdateCompanionBuilder,
      (AiModelData, $$AiModelsTableReferences),
      AiModelData,
      PrefetchHooks Function({bool processingRunsRefs, bool predictionsRefs})
    >;
typedef $$ProcessingRunsTableCreateCompanionBuilder =
    ProcessingRunsCompanion Function({
      Value<int> id,
      required int inputFileId,
      Value<int?> batchId,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      required String status,
      Value<String?> pipelineVersion,
      Value<int?> modelId,
      Value<int?> recordsProcessed,
      Value<String?> errorMessage,
    });
typedef $$ProcessingRunsTableUpdateCompanionBuilder =
    ProcessingRunsCompanion Function({
      Value<int> id,
      Value<int> inputFileId,
      Value<int?> batchId,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<String> status,
      Value<String?> pipelineVersion,
      Value<int?> modelId,
      Value<int?> recordsProcessed,
      Value<String?> errorMessage,
    });

final class $$ProcessingRunsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ProcessingRunsTable, ProcessingRunData> {
  $$ProcessingRunsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InputFilesTable _inputFileIdTable(_$AppDatabase db) => db.inputFiles
      .createAlias('processing_runs__input_file_id__input_files__id');

  $$InputFilesTableProcessedTableManager get inputFileId {
    final $_column = $_itemColumn<int>('input_file_id')!;

    final manager = $$InputFilesTableTableManager(
      $_db,
      $_db.inputFiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_inputFileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BatchesTable _batchIdTable(_$AppDatabase db) =>
      db.batches.createAlias('processing_runs__batch_id__batches__id');

  $$BatchesTableProcessedTableManager? get batchId {
    final $_column = $_itemColumn<int>('batch_id');
    if ($_column == null) return null;
    final manager = $$BatchesTableTableManager(
      $_db,
      $_db.batches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AiModelsTable _modelIdTable(_$AppDatabase db) =>
      db.aiModels.createAlias('processing_runs__model_id__ai_models__id');

  $$AiModelsTableProcessedTableManager? get modelId {
    final $_column = $_itemColumn<int>('model_id');
    if ($_column == null) return null;
    final manager = $$AiModelsTableTableManager(
      $_db,
      $_db.aiModels,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_modelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $PreprocessingDataTable,
    List<PreprocessingDataRecord>
  >
  _preprocessingDataRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.preprocessingData,
        aliasName: 'processing_runs__id__preprocessing_data__processing_run_id',
      );

  $$PreprocessingDataTableProcessedTableManager get preprocessingDataRefs {
    final manager = $$PreprocessingDataTableTableManager(
      $_db,
      $_db.preprocessingData,
    ).filter((f) => f.processingRunId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _preprocessingDataRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PredictionsTable, List<PredictionData>>
  _predictionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.predictions,
    aliasName: 'processing_runs__id__predictions__processing_run_id',
  );

  $$PredictionsTableProcessedTableManager get predictionsRefs {
    final manager = $$PredictionsTableTableManager(
      $_db,
      $_db.predictions,
    ).filter((f) => f.processingRunId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_predictionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProcessingRunsTableFilterComposer
    extends Composer<_$AppDatabase, $ProcessingRunsTable> {
  $$ProcessingRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pipelineVersion => $composableBuilder(
    column: $table.pipelineVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordsProcessed => $composableBuilder(
    column: $table.recordsProcessed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  $$InputFilesTableFilterComposer get inputFileId {
    final $$InputFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inputFileId,
      referencedTable: $db.inputFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InputFilesTableFilterComposer(
            $db: $db,
            $table: $db.inputFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BatchesTableFilterComposer get batchId {
    final $$BatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableFilterComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AiModelsTableFilterComposer get modelId {
    final $$AiModelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.aiModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiModelsTableFilterComposer(
            $db: $db,
            $table: $db.aiModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> preprocessingDataRefs(
    Expression<bool> Function($$PreprocessingDataTableFilterComposer f) f,
  ) {
    final $$PreprocessingDataTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.preprocessingData,
      getReferencedColumn: (t) => t.processingRunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreprocessingDataTableFilterComposer(
            $db: $db,
            $table: $db.preprocessingData,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> predictionsRefs(
    Expression<bool> Function($$PredictionsTableFilterComposer f) f,
  ) {
    final $$PredictionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.predictions,
      getReferencedColumn: (t) => t.processingRunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredictionsTableFilterComposer(
            $db: $db,
            $table: $db.predictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProcessingRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProcessingRunsTable> {
  $$ProcessingRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pipelineVersion => $composableBuilder(
    column: $table.pipelineVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordsProcessed => $composableBuilder(
    column: $table.recordsProcessed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  $$InputFilesTableOrderingComposer get inputFileId {
    final $$InputFilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inputFileId,
      referencedTable: $db.inputFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InputFilesTableOrderingComposer(
            $db: $db,
            $table: $db.inputFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BatchesTableOrderingComposer get batchId {
    final $$BatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableOrderingComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AiModelsTableOrderingComposer get modelId {
    final $$AiModelsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.aiModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiModelsTableOrderingComposer(
            $db: $db,
            $table: $db.aiModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProcessingRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProcessingRunsTable> {
  $$ProcessingRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get pipelineVersion => $composableBuilder(
    column: $table.pipelineVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recordsProcessed => $composableBuilder(
    column: $table.recordsProcessed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  $$InputFilesTableAnnotationComposer get inputFileId {
    final $$InputFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inputFileId,
      referencedTable: $db.inputFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InputFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.inputFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BatchesTableAnnotationComposer get batchId {
    final $$BatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AiModelsTableAnnotationComposer get modelId {
    final $$AiModelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.aiModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiModelsTableAnnotationComposer(
            $db: $db,
            $table: $db.aiModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> preprocessingDataRefs<T extends Object>(
    Expression<T> Function($$PreprocessingDataTableAnnotationComposer a) f,
  ) {
    final $$PreprocessingDataTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.preprocessingData,
          getReferencedColumn: (t) => t.processingRunId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PreprocessingDataTableAnnotationComposer(
                $db: $db,
                $table: $db.preprocessingData,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> predictionsRefs<T extends Object>(
    Expression<T> Function($$PredictionsTableAnnotationComposer a) f,
  ) {
    final $$PredictionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.predictions,
      getReferencedColumn: (t) => t.processingRunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredictionsTableAnnotationComposer(
            $db: $db,
            $table: $db.predictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProcessingRunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProcessingRunsTable,
          ProcessingRunData,
          $$ProcessingRunsTableFilterComposer,
          $$ProcessingRunsTableOrderingComposer,
          $$ProcessingRunsTableAnnotationComposer,
          $$ProcessingRunsTableCreateCompanionBuilder,
          $$ProcessingRunsTableUpdateCompanionBuilder,
          (ProcessingRunData, $$ProcessingRunsTableReferences),
          ProcessingRunData,
          PrefetchHooks Function({
            bool inputFileId,
            bool batchId,
            bool modelId,
            bool preprocessingDataRefs,
            bool predictionsRefs,
          })
        > {
  $$ProcessingRunsTableTableManager(
    _$AppDatabase db,
    $ProcessingRunsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProcessingRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProcessingRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProcessingRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> inputFileId = const Value.absent(),
                Value<int?> batchId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> pipelineVersion = const Value.absent(),
                Value<int?> modelId = const Value.absent(),
                Value<int?> recordsProcessed = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => ProcessingRunsCompanion(
                id: id,
                inputFileId: inputFileId,
                batchId: batchId,
                startedAt: startedAt,
                completedAt: completedAt,
                status: status,
                pipelineVersion: pipelineVersion,
                modelId: modelId,
                recordsProcessed: recordsProcessed,
                errorMessage: errorMessage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int inputFileId,
                Value<int?> batchId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                required String status,
                Value<String?> pipelineVersion = const Value.absent(),
                Value<int?> modelId = const Value.absent(),
                Value<int?> recordsProcessed = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => ProcessingRunsCompanion.insert(
                id: id,
                inputFileId: inputFileId,
                batchId: batchId,
                startedAt: startedAt,
                completedAt: completedAt,
                status: status,
                pipelineVersion: pipelineVersion,
                modelId: modelId,
                recordsProcessed: recordsProcessed,
                errorMessage: errorMessage,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProcessingRunsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                inputFileId = false,
                batchId = false,
                modelId = false,
                preprocessingDataRefs = false,
                predictionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (preprocessingDataRefs) db.preprocessingData,
                    if (predictionsRefs) db.predictions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (inputFileId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.inputFileId,
                            referencedTable: $$ProcessingRunsTableReferences
                                ._inputFileIdTable(db),
                            referencedColumn: $$ProcessingRunsTableReferences
                                ._inputFileIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (batchId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.batchId,
                            referencedTable: $$ProcessingRunsTableReferences
                                ._batchIdTable(db),
                            referencedColumn: $$ProcessingRunsTableReferences
                                ._batchIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (modelId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.modelId,
                            referencedTable: $$ProcessingRunsTableReferences
                                ._modelIdTable(db),
                            referencedColumn: $$ProcessingRunsTableReferences
                                ._modelIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (preprocessingDataRefs)
                        await $_getPrefetchedData<
                          ProcessingRunData,
                          $ProcessingRunsTable,
                          PreprocessingDataRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProcessingRunsTableReferences
                              ._preprocessingDataRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProcessingRunsTableReferences(
                                db,
                                table,
                                p0,
                              ).preprocessingDataRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.processingRunId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (predictionsRefs)
                        await $_getPrefetchedData<
                          ProcessingRunData,
                          $ProcessingRunsTable,
                          PredictionData
                        >(
                          currentTable: table,
                          referencedTable: $$ProcessingRunsTableReferences
                              ._predictionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProcessingRunsTableReferences(
                                db,
                                table,
                                p0,
                              ).predictionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.processingRunId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProcessingRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProcessingRunsTable,
      ProcessingRunData,
      $$ProcessingRunsTableFilterComposer,
      $$ProcessingRunsTableOrderingComposer,
      $$ProcessingRunsTableAnnotationComposer,
      $$ProcessingRunsTableCreateCompanionBuilder,
      $$ProcessingRunsTableUpdateCompanionBuilder,
      (ProcessingRunData, $$ProcessingRunsTableReferences),
      ProcessingRunData,
      PrefetchHooks Function({
        bool inputFileId,
        bool batchId,
        bool modelId,
        bool preprocessingDataRefs,
        bool predictionsRefs,
      })
    >;
typedef $$PreprocessingDataTableCreateCompanionBuilder =
    PreprocessingDataCompanion Function({
      Value<int> id,
      required int batchId,
      required int inputFileId,
      required int processingRunId,
      Value<DateTime?> timestampMinute,
      Value<DateTime?> serverTimestamp,
      Value<double?> sugarConsumptionRate,
      Value<double?> feedingHours,
      Value<double?> retentionHours,
      Value<double?> setupSg,
      Value<double?> finalSg,
      Value<double?> sgDifference,
      Value<double?> alcoholSetup,
      Value<double?> alcoholFinal,
      Value<double?> phSetup,
      Value<double?> phFinal,
      Value<double?> rawSpentWashBrix,
      Value<double?> bottomSpentWashBrix,
      Value<double?> ffeOutletSpentWashBrix,
      Value<double?> concentratedSpentWashBrix,
      Value<double?> temperature,
      Value<double?> brix,
      Value<double?> residualSugar,
      Value<double?> yeastActivity,
      Value<double?> volatileAcidity,
      Value<double?> coolingValve,
      Value<double?> agitatorRpm,
      Value<double?> steamValve,
      Value<double?> tankLevelPercent,
      Value<double?> tankWeightKg,
      Value<double?> co2FlowKgph,
      Value<double?> headspacePressureBar,
      Value<DateTime> createdAt,
    });
typedef $$PreprocessingDataTableUpdateCompanionBuilder =
    PreprocessingDataCompanion Function({
      Value<int> id,
      Value<int> batchId,
      Value<int> inputFileId,
      Value<int> processingRunId,
      Value<DateTime?> timestampMinute,
      Value<DateTime?> serverTimestamp,
      Value<double?> sugarConsumptionRate,
      Value<double?> feedingHours,
      Value<double?> retentionHours,
      Value<double?> setupSg,
      Value<double?> finalSg,
      Value<double?> sgDifference,
      Value<double?> alcoholSetup,
      Value<double?> alcoholFinal,
      Value<double?> phSetup,
      Value<double?> phFinal,
      Value<double?> rawSpentWashBrix,
      Value<double?> bottomSpentWashBrix,
      Value<double?> ffeOutletSpentWashBrix,
      Value<double?> concentratedSpentWashBrix,
      Value<double?> temperature,
      Value<double?> brix,
      Value<double?> residualSugar,
      Value<double?> yeastActivity,
      Value<double?> volatileAcidity,
      Value<double?> coolingValve,
      Value<double?> agitatorRpm,
      Value<double?> steamValve,
      Value<double?> tankLevelPercent,
      Value<double?> tankWeightKg,
      Value<double?> co2FlowKgph,
      Value<double?> headspacePressureBar,
      Value<DateTime> createdAt,
    });

final class $$PreprocessingDataTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PreprocessingDataTable,
          PreprocessingDataRecord
        > {
  $$PreprocessingDataTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BatchesTable _batchIdTable(_$AppDatabase db) =>
      db.batches.createAlias('preprocessing_data__batch_id__batches__id');

  $$BatchesTableProcessedTableManager get batchId {
    final $_column = $_itemColumn<int>('batch_id')!;

    final manager = $$BatchesTableTableManager(
      $_db,
      $_db.batches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InputFilesTable _inputFileIdTable(_$AppDatabase db) => db.inputFiles
      .createAlias('preprocessing_data__input_file_id__input_files__id');

  $$InputFilesTableProcessedTableManager get inputFileId {
    final $_column = $_itemColumn<int>('input_file_id')!;

    final manager = $$InputFilesTableTableManager(
      $_db,
      $_db.inputFiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_inputFileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProcessingRunsTable _processingRunIdTable(_$AppDatabase db) =>
      db.processingRuns.createAlias(
        'preprocessing_data__processing_run_id__processing_runs__id',
      );

  $$ProcessingRunsTableProcessedTableManager get processingRunId {
    final $_column = $_itemColumn<int>('processing_run_id')!;

    final manager = $$ProcessingRunsTableTableManager(
      $_db,
      $_db.processingRuns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_processingRunIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PreprocessingDataTableFilterComposer
    extends Composer<_$AppDatabase, $PreprocessingDataTable> {
  $$PreprocessingDataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestampMinute => $composableBuilder(
    column: $table.timestampMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverTimestamp => $composableBuilder(
    column: $table.serverTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sugarConsumptionRate => $composableBuilder(
    column: $table.sugarConsumptionRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get feedingHours => $composableBuilder(
    column: $table.feedingHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get retentionHours => $composableBuilder(
    column: $table.retentionHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get setupSg => $composableBuilder(
    column: $table.setupSg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get finalSg => $composableBuilder(
    column: $table.finalSg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sgDifference => $composableBuilder(
    column: $table.sgDifference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get alcoholSetup => $composableBuilder(
    column: $table.alcoholSetup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get alcoholFinal => $composableBuilder(
    column: $table.alcoholFinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get phSetup => $composableBuilder(
    column: $table.phSetup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get phFinal => $composableBuilder(
    column: $table.phFinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rawSpentWashBrix => $composableBuilder(
    column: $table.rawSpentWashBrix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bottomSpentWashBrix => $composableBuilder(
    column: $table.bottomSpentWashBrix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ffeOutletSpentWashBrix => $composableBuilder(
    column: $table.ffeOutletSpentWashBrix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get concentratedSpentWashBrix => $composableBuilder(
    column: $table.concentratedSpentWashBrix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get brix => $composableBuilder(
    column: $table.brix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get residualSugar => $composableBuilder(
    column: $table.residualSugar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get yeastActivity => $composableBuilder(
    column: $table.yeastActivity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get volatileAcidity => $composableBuilder(
    column: $table.volatileAcidity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get coolingValve => $composableBuilder(
    column: $table.coolingValve,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get agitatorRpm => $composableBuilder(
    column: $table.agitatorRpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get steamValve => $composableBuilder(
    column: $table.steamValve,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tankLevelPercent => $composableBuilder(
    column: $table.tankLevelPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tankWeightKg => $composableBuilder(
    column: $table.tankWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get co2FlowKgph => $composableBuilder(
    column: $table.co2FlowKgph,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get headspacePressureBar => $composableBuilder(
    column: $table.headspacePressureBar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BatchesTableFilterComposer get batchId {
    final $$BatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableFilterComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InputFilesTableFilterComposer get inputFileId {
    final $$InputFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inputFileId,
      referencedTable: $db.inputFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InputFilesTableFilterComposer(
            $db: $db,
            $table: $db.inputFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProcessingRunsTableFilterComposer get processingRunId {
    final $$ProcessingRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.processingRunId,
      referencedTable: $db.processingRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProcessingRunsTableFilterComposer(
            $db: $db,
            $table: $db.processingRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreprocessingDataTableOrderingComposer
    extends Composer<_$AppDatabase, $PreprocessingDataTable> {
  $$PreprocessingDataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestampMinute => $composableBuilder(
    column: $table.timestampMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverTimestamp => $composableBuilder(
    column: $table.serverTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sugarConsumptionRate => $composableBuilder(
    column: $table.sugarConsumptionRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get feedingHours => $composableBuilder(
    column: $table.feedingHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get retentionHours => $composableBuilder(
    column: $table.retentionHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get setupSg => $composableBuilder(
    column: $table.setupSg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get finalSg => $composableBuilder(
    column: $table.finalSg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sgDifference => $composableBuilder(
    column: $table.sgDifference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get alcoholSetup => $composableBuilder(
    column: $table.alcoholSetup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get alcoholFinal => $composableBuilder(
    column: $table.alcoholFinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get phSetup => $composableBuilder(
    column: $table.phSetup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get phFinal => $composableBuilder(
    column: $table.phFinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rawSpentWashBrix => $composableBuilder(
    column: $table.rawSpentWashBrix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bottomSpentWashBrix => $composableBuilder(
    column: $table.bottomSpentWashBrix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ffeOutletSpentWashBrix => $composableBuilder(
    column: $table.ffeOutletSpentWashBrix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get concentratedSpentWashBrix => $composableBuilder(
    column: $table.concentratedSpentWashBrix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get brix => $composableBuilder(
    column: $table.brix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get residualSugar => $composableBuilder(
    column: $table.residualSugar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get yeastActivity => $composableBuilder(
    column: $table.yeastActivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get volatileAcidity => $composableBuilder(
    column: $table.volatileAcidity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get coolingValve => $composableBuilder(
    column: $table.coolingValve,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get agitatorRpm => $composableBuilder(
    column: $table.agitatorRpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get steamValve => $composableBuilder(
    column: $table.steamValve,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tankLevelPercent => $composableBuilder(
    column: $table.tankLevelPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tankWeightKg => $composableBuilder(
    column: $table.tankWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get co2FlowKgph => $composableBuilder(
    column: $table.co2FlowKgph,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get headspacePressureBar => $composableBuilder(
    column: $table.headspacePressureBar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BatchesTableOrderingComposer get batchId {
    final $$BatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableOrderingComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InputFilesTableOrderingComposer get inputFileId {
    final $$InputFilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inputFileId,
      referencedTable: $db.inputFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InputFilesTableOrderingComposer(
            $db: $db,
            $table: $db.inputFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProcessingRunsTableOrderingComposer get processingRunId {
    final $$ProcessingRunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.processingRunId,
      referencedTable: $db.processingRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProcessingRunsTableOrderingComposer(
            $db: $db,
            $table: $db.processingRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreprocessingDataTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreprocessingDataTable> {
  $$PreprocessingDataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestampMinute => $composableBuilder(
    column: $table.timestampMinute,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serverTimestamp => $composableBuilder(
    column: $table.serverTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sugarConsumptionRate => $composableBuilder(
    column: $table.sugarConsumptionRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get feedingHours => $composableBuilder(
    column: $table.feedingHours,
    builder: (column) => column,
  );

  GeneratedColumn<double> get retentionHours => $composableBuilder(
    column: $table.retentionHours,
    builder: (column) => column,
  );

  GeneratedColumn<double> get setupSg =>
      $composableBuilder(column: $table.setupSg, builder: (column) => column);

  GeneratedColumn<double> get finalSg =>
      $composableBuilder(column: $table.finalSg, builder: (column) => column);

  GeneratedColumn<double> get sgDifference => $composableBuilder(
    column: $table.sgDifference,
    builder: (column) => column,
  );

  GeneratedColumn<double> get alcoholSetup => $composableBuilder(
    column: $table.alcoholSetup,
    builder: (column) => column,
  );

  GeneratedColumn<double> get alcoholFinal => $composableBuilder(
    column: $table.alcoholFinal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get phSetup =>
      $composableBuilder(column: $table.phSetup, builder: (column) => column);

  GeneratedColumn<double> get phFinal =>
      $composableBuilder(column: $table.phFinal, builder: (column) => column);

  GeneratedColumn<double> get rawSpentWashBrix => $composableBuilder(
    column: $table.rawSpentWashBrix,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bottomSpentWashBrix => $composableBuilder(
    column: $table.bottomSpentWashBrix,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ffeOutletSpentWashBrix => $composableBuilder(
    column: $table.ffeOutletSpentWashBrix,
    builder: (column) => column,
  );

  GeneratedColumn<double> get concentratedSpentWashBrix => $composableBuilder(
    column: $table.concentratedSpentWashBrix,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<double> get brix =>
      $composableBuilder(column: $table.brix, builder: (column) => column);

  GeneratedColumn<double> get residualSugar => $composableBuilder(
    column: $table.residualSugar,
    builder: (column) => column,
  );

  GeneratedColumn<double> get yeastActivity => $composableBuilder(
    column: $table.yeastActivity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get volatileAcidity => $composableBuilder(
    column: $table.volatileAcidity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get coolingValve => $composableBuilder(
    column: $table.coolingValve,
    builder: (column) => column,
  );

  GeneratedColumn<double> get agitatorRpm => $composableBuilder(
    column: $table.agitatorRpm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get steamValve => $composableBuilder(
    column: $table.steamValve,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tankLevelPercent => $composableBuilder(
    column: $table.tankLevelPercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tankWeightKg => $composableBuilder(
    column: $table.tankWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get co2FlowKgph => $composableBuilder(
    column: $table.co2FlowKgph,
    builder: (column) => column,
  );

  GeneratedColumn<double> get headspacePressureBar => $composableBuilder(
    column: $table.headspacePressureBar,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BatchesTableAnnotationComposer get batchId {
    final $$BatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InputFilesTableAnnotationComposer get inputFileId {
    final $$InputFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inputFileId,
      referencedTable: $db.inputFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InputFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.inputFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProcessingRunsTableAnnotationComposer get processingRunId {
    final $$ProcessingRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.processingRunId,
      referencedTable: $db.processingRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProcessingRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.processingRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreprocessingDataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreprocessingDataTable,
          PreprocessingDataRecord,
          $$PreprocessingDataTableFilterComposer,
          $$PreprocessingDataTableOrderingComposer,
          $$PreprocessingDataTableAnnotationComposer,
          $$PreprocessingDataTableCreateCompanionBuilder,
          $$PreprocessingDataTableUpdateCompanionBuilder,
          (PreprocessingDataRecord, $$PreprocessingDataTableReferences),
          PreprocessingDataRecord,
          PrefetchHooks Function({
            bool batchId,
            bool inputFileId,
            bool processingRunId,
          })
        > {
  $$PreprocessingDataTableTableManager(
    _$AppDatabase db,
    $PreprocessingDataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreprocessingDataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreprocessingDataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreprocessingDataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> batchId = const Value.absent(),
                Value<int> inputFileId = const Value.absent(),
                Value<int> processingRunId = const Value.absent(),
                Value<DateTime?> timestampMinute = const Value.absent(),
                Value<DateTime?> serverTimestamp = const Value.absent(),
                Value<double?> sugarConsumptionRate = const Value.absent(),
                Value<double?> feedingHours = const Value.absent(),
                Value<double?> retentionHours = const Value.absent(),
                Value<double?> setupSg = const Value.absent(),
                Value<double?> finalSg = const Value.absent(),
                Value<double?> sgDifference = const Value.absent(),
                Value<double?> alcoholSetup = const Value.absent(),
                Value<double?> alcoholFinal = const Value.absent(),
                Value<double?> phSetup = const Value.absent(),
                Value<double?> phFinal = const Value.absent(),
                Value<double?> rawSpentWashBrix = const Value.absent(),
                Value<double?> bottomSpentWashBrix = const Value.absent(),
                Value<double?> ffeOutletSpentWashBrix = const Value.absent(),
                Value<double?> concentratedSpentWashBrix = const Value.absent(),
                Value<double?> temperature = const Value.absent(),
                Value<double?> brix = const Value.absent(),
                Value<double?> residualSugar = const Value.absent(),
                Value<double?> yeastActivity = const Value.absent(),
                Value<double?> volatileAcidity = const Value.absent(),
                Value<double?> coolingValve = const Value.absent(),
                Value<double?> agitatorRpm = const Value.absent(),
                Value<double?> steamValve = const Value.absent(),
                Value<double?> tankLevelPercent = const Value.absent(),
                Value<double?> tankWeightKg = const Value.absent(),
                Value<double?> co2FlowKgph = const Value.absent(),
                Value<double?> headspacePressureBar = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PreprocessingDataCompanion(
                id: id,
                batchId: batchId,
                inputFileId: inputFileId,
                processingRunId: processingRunId,
                timestampMinute: timestampMinute,
                serverTimestamp: serverTimestamp,
                sugarConsumptionRate: sugarConsumptionRate,
                feedingHours: feedingHours,
                retentionHours: retentionHours,
                setupSg: setupSg,
                finalSg: finalSg,
                sgDifference: sgDifference,
                alcoholSetup: alcoholSetup,
                alcoholFinal: alcoholFinal,
                phSetup: phSetup,
                phFinal: phFinal,
                rawSpentWashBrix: rawSpentWashBrix,
                bottomSpentWashBrix: bottomSpentWashBrix,
                ffeOutletSpentWashBrix: ffeOutletSpentWashBrix,
                concentratedSpentWashBrix: concentratedSpentWashBrix,
                temperature: temperature,
                brix: brix,
                residualSugar: residualSugar,
                yeastActivity: yeastActivity,
                volatileAcidity: volatileAcidity,
                coolingValve: coolingValve,
                agitatorRpm: agitatorRpm,
                steamValve: steamValve,
                tankLevelPercent: tankLevelPercent,
                tankWeightKg: tankWeightKg,
                co2FlowKgph: co2FlowKgph,
                headspacePressureBar: headspacePressureBar,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int batchId,
                required int inputFileId,
                required int processingRunId,
                Value<DateTime?> timestampMinute = const Value.absent(),
                Value<DateTime?> serverTimestamp = const Value.absent(),
                Value<double?> sugarConsumptionRate = const Value.absent(),
                Value<double?> feedingHours = const Value.absent(),
                Value<double?> retentionHours = const Value.absent(),
                Value<double?> setupSg = const Value.absent(),
                Value<double?> finalSg = const Value.absent(),
                Value<double?> sgDifference = const Value.absent(),
                Value<double?> alcoholSetup = const Value.absent(),
                Value<double?> alcoholFinal = const Value.absent(),
                Value<double?> phSetup = const Value.absent(),
                Value<double?> phFinal = const Value.absent(),
                Value<double?> rawSpentWashBrix = const Value.absent(),
                Value<double?> bottomSpentWashBrix = const Value.absent(),
                Value<double?> ffeOutletSpentWashBrix = const Value.absent(),
                Value<double?> concentratedSpentWashBrix = const Value.absent(),
                Value<double?> temperature = const Value.absent(),
                Value<double?> brix = const Value.absent(),
                Value<double?> residualSugar = const Value.absent(),
                Value<double?> yeastActivity = const Value.absent(),
                Value<double?> volatileAcidity = const Value.absent(),
                Value<double?> coolingValve = const Value.absent(),
                Value<double?> agitatorRpm = const Value.absent(),
                Value<double?> steamValve = const Value.absent(),
                Value<double?> tankLevelPercent = const Value.absent(),
                Value<double?> tankWeightKg = const Value.absent(),
                Value<double?> co2FlowKgph = const Value.absent(),
                Value<double?> headspacePressureBar = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PreprocessingDataCompanion.insert(
                id: id,
                batchId: batchId,
                inputFileId: inputFileId,
                processingRunId: processingRunId,
                timestampMinute: timestampMinute,
                serverTimestamp: serverTimestamp,
                sugarConsumptionRate: sugarConsumptionRate,
                feedingHours: feedingHours,
                retentionHours: retentionHours,
                setupSg: setupSg,
                finalSg: finalSg,
                sgDifference: sgDifference,
                alcoholSetup: alcoholSetup,
                alcoholFinal: alcoholFinal,
                phSetup: phSetup,
                phFinal: phFinal,
                rawSpentWashBrix: rawSpentWashBrix,
                bottomSpentWashBrix: bottomSpentWashBrix,
                ffeOutletSpentWashBrix: ffeOutletSpentWashBrix,
                concentratedSpentWashBrix: concentratedSpentWashBrix,
                temperature: temperature,
                brix: brix,
                residualSugar: residualSugar,
                yeastActivity: yeastActivity,
                volatileAcidity: volatileAcidity,
                coolingValve: coolingValve,
                agitatorRpm: agitatorRpm,
                steamValve: steamValve,
                tankLevelPercent: tankLevelPercent,
                tankWeightKg: tankWeightKg,
                co2FlowKgph: co2FlowKgph,
                headspacePressureBar: headspacePressureBar,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PreprocessingDataTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                batchId = false,
                inputFileId = false,
                processingRunId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (batchId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.batchId,
                            referencedTable: $$PreprocessingDataTableReferences
                                ._batchIdTable(db),
                            referencedColumn: $$PreprocessingDataTableReferences
                                ._batchIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (inputFileId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.inputFileId,
                            referencedTable: $$PreprocessingDataTableReferences
                                ._inputFileIdTable(db),
                            referencedColumn: $$PreprocessingDataTableReferences
                                ._inputFileIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (processingRunId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.processingRunId,
                            referencedTable: $$PreprocessingDataTableReferences
                                ._processingRunIdTable(db),
                            referencedColumn: $$PreprocessingDataTableReferences
                                ._processingRunIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$PreprocessingDataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreprocessingDataTable,
      PreprocessingDataRecord,
      $$PreprocessingDataTableFilterComposer,
      $$PreprocessingDataTableOrderingComposer,
      $$PreprocessingDataTableAnnotationComposer,
      $$PreprocessingDataTableCreateCompanionBuilder,
      $$PreprocessingDataTableUpdateCompanionBuilder,
      (PreprocessingDataRecord, $$PreprocessingDataTableReferences),
      PreprocessingDataRecord,
      PrefetchHooks Function({
        bool batchId,
        bool inputFileId,
        bool processingRunId,
      })
    >;
typedef $$PredictionsTableCreateCompanionBuilder =
    PredictionsCompanion Function({
      Value<int> id,
      required int batchId,
      required int processingRunId,
      required int modelId,
      required String predictionLabel,
      Value<double?> predictionConfidence,
      Value<double?> predictedProduction,
      Value<double?> actualProduction,
      Value<double?> predictedFermenterEfficiency,
      Value<double?> actualFermenterEfficiency,
      Value<double?> predictedEthanolPercentage,
      Value<double?> actualEthanolPercentage,
      Value<bool?> fermenterVesselQcAlert,
      Value<DateTime> predictedAt,
    });
typedef $$PredictionsTableUpdateCompanionBuilder =
    PredictionsCompanion Function({
      Value<int> id,
      Value<int> batchId,
      Value<int> processingRunId,
      Value<int> modelId,
      Value<String> predictionLabel,
      Value<double?> predictionConfidence,
      Value<double?> predictedProduction,
      Value<double?> actualProduction,
      Value<double?> predictedFermenterEfficiency,
      Value<double?> actualFermenterEfficiency,
      Value<double?> predictedEthanolPercentage,
      Value<double?> actualEthanolPercentage,
      Value<bool?> fermenterVesselQcAlert,
      Value<DateTime> predictedAt,
    });

final class $$PredictionsTableReferences
    extends BaseReferences<_$AppDatabase, $PredictionsTable, PredictionData> {
  $$PredictionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BatchesTable _batchIdTable(_$AppDatabase db) =>
      db.batches.createAlias('predictions__batch_id__batches__id');

  $$BatchesTableProcessedTableManager get batchId {
    final $_column = $_itemColumn<int>('batch_id')!;

    final manager = $$BatchesTableTableManager(
      $_db,
      $_db.batches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProcessingRunsTable _processingRunIdTable(_$AppDatabase db) => db
      .processingRuns
      .createAlias('predictions__processing_run_id__processing_runs__id');

  $$ProcessingRunsTableProcessedTableManager get processingRunId {
    final $_column = $_itemColumn<int>('processing_run_id')!;

    final manager = $$ProcessingRunsTableTableManager(
      $_db,
      $_db.processingRuns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_processingRunIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AiModelsTable _modelIdTable(_$AppDatabase db) =>
      db.aiModels.createAlias('predictions__model_id__ai_models__id');

  $$AiModelsTableProcessedTableManager get modelId {
    final $_column = $_itemColumn<int>('model_id')!;

    final manager = $$AiModelsTableTableManager(
      $_db,
      $_db.aiModels,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_modelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MqttPublishLogTable, List<MqttPublishLogData>>
  _mqttPublishLogRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mqttPublishLog,
    aliasName: 'predictions__id__mqtt_publish_log__prediction_id',
  );

  $$MqttPublishLogTableProcessedTableManager get mqttPublishLogRefs {
    final manager = $$MqttPublishLogTableTableManager(
      $_db,
      $_db.mqttPublishLog,
    ).filter((f) => f.predictionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mqttPublishLogRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PredictionsTableFilterComposer
    extends Composer<_$AppDatabase, $PredictionsTable> {
  $$PredictionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get predictionLabel => $composableBuilder(
    column: $table.predictionLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get predictionConfidence => $composableBuilder(
    column: $table.predictionConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get predictedProduction => $composableBuilder(
    column: $table.predictedProduction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualProduction => $composableBuilder(
    column: $table.actualProduction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get predictedFermenterEfficiency => $composableBuilder(
    column: $table.predictedFermenterEfficiency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualFermenterEfficiency => $composableBuilder(
    column: $table.actualFermenterEfficiency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get predictedEthanolPercentage => $composableBuilder(
    column: $table.predictedEthanolPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualEthanolPercentage => $composableBuilder(
    column: $table.actualEthanolPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fermenterVesselQcAlert => $composableBuilder(
    column: $table.fermenterVesselQcAlert,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get predictedAt => $composableBuilder(
    column: $table.predictedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BatchesTableFilterComposer get batchId {
    final $$BatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableFilterComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProcessingRunsTableFilterComposer get processingRunId {
    final $$ProcessingRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.processingRunId,
      referencedTable: $db.processingRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProcessingRunsTableFilterComposer(
            $db: $db,
            $table: $db.processingRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AiModelsTableFilterComposer get modelId {
    final $$AiModelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.aiModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiModelsTableFilterComposer(
            $db: $db,
            $table: $db.aiModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> mqttPublishLogRefs(
    Expression<bool> Function($$MqttPublishLogTableFilterComposer f) f,
  ) {
    final $$MqttPublishLogTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mqttPublishLog,
      getReferencedColumn: (t) => t.predictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MqttPublishLogTableFilterComposer(
            $db: $db,
            $table: $db.mqttPublishLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PredictionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PredictionsTable> {
  $$PredictionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get predictionLabel => $composableBuilder(
    column: $table.predictionLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get predictionConfidence => $composableBuilder(
    column: $table.predictionConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get predictedProduction => $composableBuilder(
    column: $table.predictedProduction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualProduction => $composableBuilder(
    column: $table.actualProduction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get predictedFermenterEfficiency =>
      $composableBuilder(
        column: $table.predictedFermenterEfficiency,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<double> get actualFermenterEfficiency => $composableBuilder(
    column: $table.actualFermenterEfficiency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get predictedEthanolPercentage => $composableBuilder(
    column: $table.predictedEthanolPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualEthanolPercentage => $composableBuilder(
    column: $table.actualEthanolPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fermenterVesselQcAlert => $composableBuilder(
    column: $table.fermenterVesselQcAlert,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get predictedAt => $composableBuilder(
    column: $table.predictedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BatchesTableOrderingComposer get batchId {
    final $$BatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableOrderingComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProcessingRunsTableOrderingComposer get processingRunId {
    final $$ProcessingRunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.processingRunId,
      referencedTable: $db.processingRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProcessingRunsTableOrderingComposer(
            $db: $db,
            $table: $db.processingRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AiModelsTableOrderingComposer get modelId {
    final $$AiModelsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.aiModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiModelsTableOrderingComposer(
            $db: $db,
            $table: $db.aiModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PredictionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PredictionsTable> {
  $$PredictionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get predictionLabel => $composableBuilder(
    column: $table.predictionLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get predictionConfidence => $composableBuilder(
    column: $table.predictionConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get predictedProduction => $composableBuilder(
    column: $table.predictedProduction,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualProduction => $composableBuilder(
    column: $table.actualProduction,
    builder: (column) => column,
  );

  GeneratedColumn<double> get predictedFermenterEfficiency =>
      $composableBuilder(
        column: $table.predictedFermenterEfficiency,
        builder: (column) => column,
      );

  GeneratedColumn<double> get actualFermenterEfficiency => $composableBuilder(
    column: $table.actualFermenterEfficiency,
    builder: (column) => column,
  );

  GeneratedColumn<double> get predictedEthanolPercentage => $composableBuilder(
    column: $table.predictedEthanolPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualEthanolPercentage => $composableBuilder(
    column: $table.actualEthanolPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get fermenterVesselQcAlert => $composableBuilder(
    column: $table.fermenterVesselQcAlert,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get predictedAt => $composableBuilder(
    column: $table.predictedAt,
    builder: (column) => column,
  );

  $$BatchesTableAnnotationComposer get batchId {
    final $$BatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProcessingRunsTableAnnotationComposer get processingRunId {
    final $$ProcessingRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.processingRunId,
      referencedTable: $db.processingRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProcessingRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.processingRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AiModelsTableAnnotationComposer get modelId {
    final $$AiModelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.aiModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiModelsTableAnnotationComposer(
            $db: $db,
            $table: $db.aiModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> mqttPublishLogRefs<T extends Object>(
    Expression<T> Function($$MqttPublishLogTableAnnotationComposer a) f,
  ) {
    final $$MqttPublishLogTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mqttPublishLog,
      getReferencedColumn: (t) => t.predictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MqttPublishLogTableAnnotationComposer(
            $db: $db,
            $table: $db.mqttPublishLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PredictionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PredictionsTable,
          PredictionData,
          $$PredictionsTableFilterComposer,
          $$PredictionsTableOrderingComposer,
          $$PredictionsTableAnnotationComposer,
          $$PredictionsTableCreateCompanionBuilder,
          $$PredictionsTableUpdateCompanionBuilder,
          (PredictionData, $$PredictionsTableReferences),
          PredictionData,
          PrefetchHooks Function({
            bool batchId,
            bool processingRunId,
            bool modelId,
            bool mqttPublishLogRefs,
          })
        > {
  $$PredictionsTableTableManager(_$AppDatabase db, $PredictionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PredictionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PredictionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PredictionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> batchId = const Value.absent(),
                Value<int> processingRunId = const Value.absent(),
                Value<int> modelId = const Value.absent(),
                Value<String> predictionLabel = const Value.absent(),
                Value<double?> predictionConfidence = const Value.absent(),
                Value<double?> predictedProduction = const Value.absent(),
                Value<double?> actualProduction = const Value.absent(),
                Value<double?> predictedFermenterEfficiency =
                    const Value.absent(),
                Value<double?> actualFermenterEfficiency = const Value.absent(),
                Value<double?> predictedEthanolPercentage =
                    const Value.absent(),
                Value<double?> actualEthanolPercentage = const Value.absent(),
                Value<bool?> fermenterVesselQcAlert = const Value.absent(),
                Value<DateTime> predictedAt = const Value.absent(),
              }) => PredictionsCompanion(
                id: id,
                batchId: batchId,
                processingRunId: processingRunId,
                modelId: modelId,
                predictionLabel: predictionLabel,
                predictionConfidence: predictionConfidence,
                predictedProduction: predictedProduction,
                actualProduction: actualProduction,
                predictedFermenterEfficiency: predictedFermenterEfficiency,
                actualFermenterEfficiency: actualFermenterEfficiency,
                predictedEthanolPercentage: predictedEthanolPercentage,
                actualEthanolPercentage: actualEthanolPercentage,
                fermenterVesselQcAlert: fermenterVesselQcAlert,
                predictedAt: predictedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int batchId,
                required int processingRunId,
                required int modelId,
                required String predictionLabel,
                Value<double?> predictionConfidence = const Value.absent(),
                Value<double?> predictedProduction = const Value.absent(),
                Value<double?> actualProduction = const Value.absent(),
                Value<double?> predictedFermenterEfficiency =
                    const Value.absent(),
                Value<double?> actualFermenterEfficiency = const Value.absent(),
                Value<double?> predictedEthanolPercentage =
                    const Value.absent(),
                Value<double?> actualEthanolPercentage = const Value.absent(),
                Value<bool?> fermenterVesselQcAlert = const Value.absent(),
                Value<DateTime> predictedAt = const Value.absent(),
              }) => PredictionsCompanion.insert(
                id: id,
                batchId: batchId,
                processingRunId: processingRunId,
                modelId: modelId,
                predictionLabel: predictionLabel,
                predictionConfidence: predictionConfidence,
                predictedProduction: predictedProduction,
                actualProduction: actualProduction,
                predictedFermenterEfficiency: predictedFermenterEfficiency,
                actualFermenterEfficiency: actualFermenterEfficiency,
                predictedEthanolPercentage: predictedEthanolPercentage,
                actualEthanolPercentage: actualEthanolPercentage,
                fermenterVesselQcAlert: fermenterVesselQcAlert,
                predictedAt: predictedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PredictionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                batchId = false,
                processingRunId = false,
                modelId = false,
                mqttPublishLogRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (mqttPublishLogRefs) db.mqttPublishLog,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (batchId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.batchId,
                            referencedTable: $$PredictionsTableReferences
                                ._batchIdTable(db),
                            referencedColumn: $$PredictionsTableReferences
                                ._batchIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (processingRunId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.processingRunId,
                            referencedTable: $$PredictionsTableReferences
                                ._processingRunIdTable(db),
                            referencedColumn: $$PredictionsTableReferences
                                ._processingRunIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (modelId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.modelId,
                            referencedTable: $$PredictionsTableReferences
                                ._modelIdTable(db),
                            referencedColumn: $$PredictionsTableReferences
                                ._modelIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (mqttPublishLogRefs)
                        await $_getPrefetchedData<
                          PredictionData,
                          $PredictionsTable,
                          MqttPublishLogData
                        >(
                          currentTable: table,
                          referencedTable: $$PredictionsTableReferences
                              ._mqttPublishLogRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PredictionsTableReferences(
                                db,
                                table,
                                p0,
                              ).mqttPublishLogRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.predictionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PredictionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PredictionsTable,
      PredictionData,
      $$PredictionsTableFilterComposer,
      $$PredictionsTableOrderingComposer,
      $$PredictionsTableAnnotationComposer,
      $$PredictionsTableCreateCompanionBuilder,
      $$PredictionsTableUpdateCompanionBuilder,
      (PredictionData, $$PredictionsTableReferences),
      PredictionData,
      PrefetchHooks Function({
        bool batchId,
        bool processingRunId,
        bool modelId,
        bool mqttPublishLogRefs,
      })
    >;
typedef $$MqttPublishLogTableCreateCompanionBuilder =
    MqttPublishLogCompanion Function({
      Value<int> id,
      required int predictionId,
      required String topic,
      required String payload,
      Value<int> qos,
      Value<DateTime> publishedAt,
      required String status,
      Value<int> retryCount,
      Value<String?> errorMessage,
    });
typedef $$MqttPublishLogTableUpdateCompanionBuilder =
    MqttPublishLogCompanion Function({
      Value<int> id,
      Value<int> predictionId,
      Value<String> topic,
      Value<String> payload,
      Value<int> qos,
      Value<DateTime> publishedAt,
      Value<String> status,
      Value<int> retryCount,
      Value<String?> errorMessage,
    });

final class $$MqttPublishLogTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MqttPublishLogTable,
          MqttPublishLogData
        > {
  $$MqttPublishLogTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PredictionsTable _predictionIdTable(_$AppDatabase db) => db
      .predictions
      .createAlias('mqtt_publish_log__prediction_id__predictions__id');

  $$PredictionsTableProcessedTableManager get predictionId {
    final $_column = $_itemColumn<int>('prediction_id')!;

    final manager = $$PredictionsTableTableManager(
      $_db,
      $_db.predictions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_predictionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MqttPublishLogTableFilterComposer
    extends Composer<_$AppDatabase, $MqttPublishLogTable> {
  $$MqttPublishLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qos => $composableBuilder(
    column: $table.qos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  $$PredictionsTableFilterComposer get predictionId {
    final $$PredictionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predictionId,
      referencedTable: $db.predictions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredictionsTableFilterComposer(
            $db: $db,
            $table: $db.predictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MqttPublishLogTableOrderingComposer
    extends Composer<_$AppDatabase, $MqttPublishLogTable> {
  $$MqttPublishLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qos => $composableBuilder(
    column: $table.qos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  $$PredictionsTableOrderingComposer get predictionId {
    final $$PredictionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predictionId,
      referencedTable: $db.predictions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredictionsTableOrderingComposer(
            $db: $db,
            $table: $db.predictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MqttPublishLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $MqttPublishLogTable> {
  $$MqttPublishLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get qos =>
      $composableBuilder(column: $table.qos, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  $$PredictionsTableAnnotationComposer get predictionId {
    final $$PredictionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predictionId,
      referencedTable: $db.predictions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredictionsTableAnnotationComposer(
            $db: $db,
            $table: $db.predictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MqttPublishLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MqttPublishLogTable,
          MqttPublishLogData,
          $$MqttPublishLogTableFilterComposer,
          $$MqttPublishLogTableOrderingComposer,
          $$MqttPublishLogTableAnnotationComposer,
          $$MqttPublishLogTableCreateCompanionBuilder,
          $$MqttPublishLogTableUpdateCompanionBuilder,
          (MqttPublishLogData, $$MqttPublishLogTableReferences),
          MqttPublishLogData,
          PrefetchHooks Function({bool predictionId})
        > {
  $$MqttPublishLogTableTableManager(
    _$AppDatabase db,
    $MqttPublishLogTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MqttPublishLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MqttPublishLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MqttPublishLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> predictionId = const Value.absent(),
                Value<String> topic = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> qos = const Value.absent(),
                Value<DateTime> publishedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => MqttPublishLogCompanion(
                id: id,
                predictionId: predictionId,
                topic: topic,
                payload: payload,
                qos: qos,
                publishedAt: publishedAt,
                status: status,
                retryCount: retryCount,
                errorMessage: errorMessage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int predictionId,
                required String topic,
                required String payload,
                Value<int> qos = const Value.absent(),
                Value<DateTime> publishedAt = const Value.absent(),
                required String status,
                Value<int> retryCount = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => MqttPublishLogCompanion.insert(
                id: id,
                predictionId: predictionId,
                topic: topic,
                payload: payload,
                qos: qos,
                publishedAt: publishedAt,
                status: status,
                retryCount: retryCount,
                errorMessage: errorMessage,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MqttPublishLogTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({predictionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (predictionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.predictionId,
                        referencedTable: $$MqttPublishLogTableReferences
                            ._predictionIdTable(db),
                        referencedColumn: $$MqttPublishLogTableReferences
                            ._predictionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MqttPublishLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MqttPublishLogTable,
      MqttPublishLogData,
      $$MqttPublishLogTableFilterComposer,
      $$MqttPublishLogTableOrderingComposer,
      $$MqttPublishLogTableAnnotationComposer,
      $$MqttPublishLogTableCreateCompanionBuilder,
      $$MqttPublishLogTableUpdateCompanionBuilder,
      (MqttPublishLogData, $$MqttPublishLogTableReferences),
      MqttPublishLogData,
      PrefetchHooks Function({bool predictionId})
    >;
typedef $$BackupHistoryTableCreateCompanionBuilder =
    BackupHistoryCompanion Function({
      Value<int> id,
      Value<DateTime> backupStartedAt,
      Value<DateTime?> backupCompletedAt,
      required String backupFileName,
      required String backupLocation,
      required String cloudProvider,
      Value<BigInt?> databaseSizeBytes,
      Value<int?> recordsBackedUp,
      required String status,
      Value<DateTime?> verifiedAt,
      Value<int?> deletedLocalRecords,
      Value<String?> errorMessage,
    });
typedef $$BackupHistoryTableUpdateCompanionBuilder =
    BackupHistoryCompanion Function({
      Value<int> id,
      Value<DateTime> backupStartedAt,
      Value<DateTime?> backupCompletedAt,
      Value<String> backupFileName,
      Value<String> backupLocation,
      Value<String> cloudProvider,
      Value<BigInt?> databaseSizeBytes,
      Value<int?> recordsBackedUp,
      Value<String> status,
      Value<DateTime?> verifiedAt,
      Value<int?> deletedLocalRecords,
      Value<String?> errorMessage,
    });

class $$BackupHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $BackupHistoryTable> {
  $$BackupHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get backupStartedAt => $composableBuilder(
    column: $table.backupStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get backupCompletedAt => $composableBuilder(
    column: $table.backupCompletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backupFileName => $composableBuilder(
    column: $table.backupFileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backupLocation => $composableBuilder(
    column: $table.backupLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudProvider => $composableBuilder(
    column: $table.cloudProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get databaseSizeBytes => $composableBuilder(
    column: $table.databaseSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordsBackedUp => $composableBuilder(
    column: $table.recordsBackedUp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedLocalRecords => $composableBuilder(
    column: $table.deletedLocalRecords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BackupHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupHistoryTable> {
  $$BackupHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get backupStartedAt => $composableBuilder(
    column: $table.backupStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get backupCompletedAt => $composableBuilder(
    column: $table.backupCompletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backupFileName => $composableBuilder(
    column: $table.backupFileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backupLocation => $composableBuilder(
    column: $table.backupLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudProvider => $composableBuilder(
    column: $table.cloudProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get databaseSizeBytes => $composableBuilder(
    column: $table.databaseSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordsBackedUp => $composableBuilder(
    column: $table.recordsBackedUp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedLocalRecords => $composableBuilder(
    column: $table.deletedLocalRecords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupHistoryTable> {
  $$BackupHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get backupStartedAt => $composableBuilder(
    column: $table.backupStartedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get backupCompletedAt => $composableBuilder(
    column: $table.backupCompletedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backupFileName => $composableBuilder(
    column: $table.backupFileName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backupLocation => $composableBuilder(
    column: $table.backupLocation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cloudProvider => $composableBuilder(
    column: $table.cloudProvider,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get databaseSizeBytes => $composableBuilder(
    column: $table.databaseSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recordsBackedUp => $composableBuilder(
    column: $table.recordsBackedUp,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedLocalRecords => $composableBuilder(
    column: $table.deletedLocalRecords,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );
}

class $$BackupHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BackupHistoryTable,
          BackupHistoryData,
          $$BackupHistoryTableFilterComposer,
          $$BackupHistoryTableOrderingComposer,
          $$BackupHistoryTableAnnotationComposer,
          $$BackupHistoryTableCreateCompanionBuilder,
          $$BackupHistoryTableUpdateCompanionBuilder,
          (
            BackupHistoryData,
            BaseReferences<
              _$AppDatabase,
              $BackupHistoryTable,
              BackupHistoryData
            >,
          ),
          BackupHistoryData,
          PrefetchHooks Function()
        > {
  $$BackupHistoryTableTableManager(_$AppDatabase db, $BackupHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> backupStartedAt = const Value.absent(),
                Value<DateTime?> backupCompletedAt = const Value.absent(),
                Value<String> backupFileName = const Value.absent(),
                Value<String> backupLocation = const Value.absent(),
                Value<String> cloudProvider = const Value.absent(),
                Value<BigInt?> databaseSizeBytes = const Value.absent(),
                Value<int?> recordsBackedUp = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
                Value<int?> deletedLocalRecords = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => BackupHistoryCompanion(
                id: id,
                backupStartedAt: backupStartedAt,
                backupCompletedAt: backupCompletedAt,
                backupFileName: backupFileName,
                backupLocation: backupLocation,
                cloudProvider: cloudProvider,
                databaseSizeBytes: databaseSizeBytes,
                recordsBackedUp: recordsBackedUp,
                status: status,
                verifiedAt: verifiedAt,
                deletedLocalRecords: deletedLocalRecords,
                errorMessage: errorMessage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> backupStartedAt = const Value.absent(),
                Value<DateTime?> backupCompletedAt = const Value.absent(),
                required String backupFileName,
                required String backupLocation,
                required String cloudProvider,
                Value<BigInt?> databaseSizeBytes = const Value.absent(),
                Value<int?> recordsBackedUp = const Value.absent(),
                required String status,
                Value<DateTime?> verifiedAt = const Value.absent(),
                Value<int?> deletedLocalRecords = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => BackupHistoryCompanion.insert(
                id: id,
                backupStartedAt: backupStartedAt,
                backupCompletedAt: backupCompletedAt,
                backupFileName: backupFileName,
                backupLocation: backupLocation,
                cloudProvider: cloudProvider,
                databaseSizeBytes: databaseSizeBytes,
                recordsBackedUp: recordsBackedUp,
                status: status,
                verifiedAt: verifiedAt,
                deletedLocalRecords: deletedLocalRecords,
                errorMessage: errorMessage,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BackupHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BackupHistoryTable,
      BackupHistoryData,
      $$BackupHistoryTableFilterComposer,
      $$BackupHistoryTableOrderingComposer,
      $$BackupHistoryTableAnnotationComposer,
      $$BackupHistoryTableCreateCompanionBuilder,
      $$BackupHistoryTableUpdateCompanionBuilder,
      (
        BackupHistoryData,
        BaseReferences<_$AppDatabase, $BackupHistoryTable, BackupHistoryData>,
      ),
      BackupHistoryData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FactoriesTableTableManager get factories =>
      $$FactoriesTableTableManager(_db, _db.factories);
  $$InputFilesTableTableManager get inputFiles =>
      $$InputFilesTableTableManager(_db, _db.inputFiles);
  $$BatchesTableTableManager get batches =>
      $$BatchesTableTableManager(_db, _db.batches);
  $$AiModelsTableTableManager get aiModels =>
      $$AiModelsTableTableManager(_db, _db.aiModels);
  $$ProcessingRunsTableTableManager get processingRuns =>
      $$ProcessingRunsTableTableManager(_db, _db.processingRuns);
  $$PreprocessingDataTableTableManager get preprocessingData =>
      $$PreprocessingDataTableTableManager(_db, _db.preprocessingData);
  $$PredictionsTableTableManager get predictions =>
      $$PredictionsTableTableManager(_db, _db.predictions);
  $$MqttPublishLogTableTableManager get mqttPublishLog =>
      $$MqttPublishLogTableTableManager(_db, _db.mqttPublishLog);
  $$BackupHistoryTableTableManager get backupHistory =>
      $$BackupHistoryTableTableManager(_db, _db.backupHistory);
}
