// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $VideosTableTable extends VideosTable
    with TableInfo<$VideosTableTable, VideosTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<double> width = GeneratedColumn<double>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visibilityMeta = const VerificationMeta(
    'visibility',
  );
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
    'visibility',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant("public"),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant("direct"),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(""),
  );
  static const VerificationMeta _thumbnailURLMeta = const VerificationMeta(
    'thumbnailURL',
  );
  @override
  late final GeneratedColumn<String> thumbnailURL = GeneratedColumn<String>(
    'thumbnail_u_r_l',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _videoURLMeta = const VerificationMeta(
    'videoURL',
  );
  @override
  late final GeneratedColumn<String> videoURL = GeneratedColumn<String>(
    'video_u_r_l',
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
    localPath,
    userId,
    id,
    duration,
    size,
    height,
    width,
    visibility,
    deleted,
    type,
    title,
    thumbnailURL,
    videoURL,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'videos_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<VideosTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('visibility')) {
      context.handle(
        _visibilityMeta,
        visibility.isAcceptableOrUnknown(data['visibility']!, _visibilityMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('thumbnail_u_r_l')) {
      context.handle(
        _thumbnailURLMeta,
        thumbnailURL.isAcceptableOrUnknown(
          data['thumbnail_u_r_l']!,
          _thumbnailURLMeta,
        ),
      );
    }
    if (data.containsKey('video_u_r_l')) {
      context.handle(
        _videoURLMeta,
        videoURL.isAcceptableOrUnknown(data['video_u_r_l']!, _videoURLMeta),
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
  VideosTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VideosTableData(
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width'],
      )!,
      visibility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visibility'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      thumbnailURL: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_u_r_l'],
      ),
      videoURL: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_u_r_l'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VideosTableTable createAlias(String alias) {
    return $VideosTableTable(attachedDatabase, alias);
  }
}

class VideosTableData extends DataClass implements Insertable<VideosTableData> {
  final String localPath;
  final String userId;
  final String id;
  final int duration;
  final int size;
  final double height;
  final double width;
  final String visibility;
  final bool deleted;
  final String type;
  final String title;
  final String? thumbnailURL;
  final String? videoURL;
  final DateTime createdAt;
  const VideosTableData({
    required this.localPath,
    required this.userId,
    required this.id,
    required this.duration,
    required this.size,
    required this.height,
    required this.width,
    required this.visibility,
    required this.deleted,
    required this.type,
    required this.title,
    this.thumbnailURL,
    this.videoURL,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_path'] = Variable<String>(localPath);
    map['user_id'] = Variable<String>(userId);
    map['id'] = Variable<String>(id);
    map['duration'] = Variable<int>(duration);
    map['size'] = Variable<int>(size);
    map['height'] = Variable<double>(height);
    map['width'] = Variable<double>(width);
    map['visibility'] = Variable<String>(visibility);
    map['deleted'] = Variable<bool>(deleted);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || thumbnailURL != null) {
      map['thumbnail_u_r_l'] = Variable<String>(thumbnailURL);
    }
    if (!nullToAbsent || videoURL != null) {
      map['video_u_r_l'] = Variable<String>(videoURL);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VideosTableCompanion toCompanion(bool nullToAbsent) {
    return VideosTableCompanion(
      localPath: Value(localPath),
      userId: Value(userId),
      id: Value(id),
      duration: Value(duration),
      size: Value(size),
      height: Value(height),
      width: Value(width),
      visibility: Value(visibility),
      deleted: Value(deleted),
      type: Value(type),
      title: Value(title),
      thumbnailURL: thumbnailURL == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailURL),
      videoURL: videoURL == null && nullToAbsent
          ? const Value.absent()
          : Value(videoURL),
      createdAt: Value(createdAt),
    );
  }

  factory VideosTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VideosTableData(
      localPath: serializer.fromJson<String>(json['localPath']),
      userId: serializer.fromJson<String>(json['userId']),
      id: serializer.fromJson<String>(json['id']),
      duration: serializer.fromJson<int>(json['duration']),
      size: serializer.fromJson<int>(json['size']),
      height: serializer.fromJson<double>(json['height']),
      width: serializer.fromJson<double>(json['width']),
      visibility: serializer.fromJson<String>(json['visibility']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      thumbnailURL: serializer.fromJson<String?>(json['thumbnailURL']),
      videoURL: serializer.fromJson<String?>(json['videoURL']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localPath': serializer.toJson<String>(localPath),
      'userId': serializer.toJson<String>(userId),
      'id': serializer.toJson<String>(id),
      'duration': serializer.toJson<int>(duration),
      'size': serializer.toJson<int>(size),
      'height': serializer.toJson<double>(height),
      'width': serializer.toJson<double>(width),
      'visibility': serializer.toJson<String>(visibility),
      'deleted': serializer.toJson<bool>(deleted),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'thumbnailURL': serializer.toJson<String?>(thumbnailURL),
      'videoURL': serializer.toJson<String?>(videoURL),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VideosTableData copyWith({
    String? localPath,
    String? userId,
    String? id,
    int? duration,
    int? size,
    double? height,
    double? width,
    String? visibility,
    bool? deleted,
    String? type,
    String? title,
    Value<String?> thumbnailURL = const Value.absent(),
    Value<String?> videoURL = const Value.absent(),
    DateTime? createdAt,
  }) => VideosTableData(
    localPath: localPath ?? this.localPath,
    userId: userId ?? this.userId,
    id: id ?? this.id,
    duration: duration ?? this.duration,
    size: size ?? this.size,
    height: height ?? this.height,
    width: width ?? this.width,
    visibility: visibility ?? this.visibility,
    deleted: deleted ?? this.deleted,
    type: type ?? this.type,
    title: title ?? this.title,
    thumbnailURL: thumbnailURL.present ? thumbnailURL.value : this.thumbnailURL,
    videoURL: videoURL.present ? videoURL.value : this.videoURL,
    createdAt: createdAt ?? this.createdAt,
  );
  VideosTableData copyWithCompanion(VideosTableCompanion data) {
    return VideosTableData(
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      userId: data.userId.present ? data.userId.value : this.userId,
      id: data.id.present ? data.id.value : this.id,
      duration: data.duration.present ? data.duration.value : this.duration,
      size: data.size.present ? data.size.value : this.size,
      height: data.height.present ? data.height.value : this.height,
      width: data.width.present ? data.width.value : this.width,
      visibility: data.visibility.present
          ? data.visibility.value
          : this.visibility,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      thumbnailURL: data.thumbnailURL.present
          ? data.thumbnailURL.value
          : this.thumbnailURL,
      videoURL: data.videoURL.present ? data.videoURL.value : this.videoURL,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VideosTableData(')
          ..write('localPath: $localPath, ')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('duration: $duration, ')
          ..write('size: $size, ')
          ..write('height: $height, ')
          ..write('width: $width, ')
          ..write('visibility: $visibility, ')
          ..write('deleted: $deleted, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('thumbnailURL: $thumbnailURL, ')
          ..write('videoURL: $videoURL, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localPath,
    userId,
    id,
    duration,
    size,
    height,
    width,
    visibility,
    deleted,
    type,
    title,
    thumbnailURL,
    videoURL,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VideosTableData &&
          other.localPath == this.localPath &&
          other.userId == this.userId &&
          other.id == this.id &&
          other.duration == this.duration &&
          other.size == this.size &&
          other.height == this.height &&
          other.width == this.width &&
          other.visibility == this.visibility &&
          other.deleted == this.deleted &&
          other.type == this.type &&
          other.title == this.title &&
          other.thumbnailURL == this.thumbnailURL &&
          other.videoURL == this.videoURL &&
          other.createdAt == this.createdAt);
}

class VideosTableCompanion extends UpdateCompanion<VideosTableData> {
  final Value<String> localPath;
  final Value<String> userId;
  final Value<String> id;
  final Value<int> duration;
  final Value<int> size;
  final Value<double> height;
  final Value<double> width;
  final Value<String> visibility;
  final Value<bool> deleted;
  final Value<String> type;
  final Value<String> title;
  final Value<String?> thumbnailURL;
  final Value<String?> videoURL;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VideosTableCompanion({
    this.localPath = const Value.absent(),
    this.userId = const Value.absent(),
    this.id = const Value.absent(),
    this.duration = const Value.absent(),
    this.size = const Value.absent(),
    this.height = const Value.absent(),
    this.width = const Value.absent(),
    this.visibility = const Value.absent(),
    this.deleted = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.thumbnailURL = const Value.absent(),
    this.videoURL = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VideosTableCompanion.insert({
    required String localPath,
    required String userId,
    required String id,
    this.duration = const Value.absent(),
    required int size,
    required double height,
    required double width,
    this.visibility = const Value.absent(),
    this.deleted = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.thumbnailURL = const Value.absent(),
    this.videoURL = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localPath = Value(localPath),
       userId = Value(userId),
       id = Value(id),
       size = Value(size),
       height = Value(height),
       width = Value(width);
  static Insertable<VideosTableData> custom({
    Expression<String>? localPath,
    Expression<String>? userId,
    Expression<String>? id,
    Expression<int>? duration,
    Expression<int>? size,
    Expression<double>? height,
    Expression<double>? width,
    Expression<String>? visibility,
    Expression<bool>? deleted,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? thumbnailURL,
    Expression<String>? videoURL,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localPath != null) 'local_path': localPath,
      if (userId != null) 'user_id': userId,
      if (id != null) 'id': id,
      if (duration != null) 'duration': duration,
      if (size != null) 'size': size,
      if (height != null) 'height': height,
      if (width != null) 'width': width,
      if (visibility != null) 'visibility': visibility,
      if (deleted != null) 'deleted': deleted,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (thumbnailURL != null) 'thumbnail_u_r_l': thumbnailURL,
      if (videoURL != null) 'video_u_r_l': videoURL,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VideosTableCompanion copyWith({
    Value<String>? localPath,
    Value<String>? userId,
    Value<String>? id,
    Value<int>? duration,
    Value<int>? size,
    Value<double>? height,
    Value<double>? width,
    Value<String>? visibility,
    Value<bool>? deleted,
    Value<String>? type,
    Value<String>? title,
    Value<String?>? thumbnailURL,
    Value<String?>? videoURL,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return VideosTableCompanion(
      localPath: localPath ?? this.localPath,
      userId: userId ?? this.userId,
      id: id ?? this.id,
      duration: duration ?? this.duration,
      size: size ?? this.size,
      height: height ?? this.height,
      width: width ?? this.width,
      visibility: visibility ?? this.visibility,
      deleted: deleted ?? this.deleted,
      type: type ?? this.type,
      title: title ?? this.title,
      thumbnailURL: thumbnailURL ?? this.thumbnailURL,
      videoURL: videoURL ?? this.videoURL,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (width.present) {
      map['width'] = Variable<double>(width.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (thumbnailURL.present) {
      map['thumbnail_u_r_l'] = Variable<String>(thumbnailURL.value);
    }
    if (videoURL.present) {
      map['video_u_r_l'] = Variable<String>(videoURL.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideosTableCompanion(')
          ..write('localPath: $localPath, ')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('duration: $duration, ')
          ..write('size: $size, ')
          ..write('height: $height, ')
          ..write('width: $width, ')
          ..write('visibility: $visibility, ')
          ..write('deleted: $deleted, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('thumbnailURL: $thumbnailURL, ')
          ..write('videoURL: $videoURL, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VideosTableTable videosTable = $VideosTableTable(this);
  late final Index userIdCreatedAt = Index(
    'userId_createdAt',
    'CREATE INDEX userId_createdAt ON videos_table (user_id, created_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    videosTable,
    userIdCreatedAt,
  ];
}

typedef $$VideosTableTableCreateCompanionBuilder =
    VideosTableCompanion Function({
      required String localPath,
      required String userId,
      required String id,
      Value<int> duration,
      required int size,
      required double height,
      required double width,
      Value<String> visibility,
      Value<bool> deleted,
      Value<String> type,
      Value<String> title,
      Value<String?> thumbnailURL,
      Value<String?> videoURL,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$VideosTableTableUpdateCompanionBuilder =
    VideosTableCompanion Function({
      Value<String> localPath,
      Value<String> userId,
      Value<String> id,
      Value<int> duration,
      Value<int> size,
      Value<double> height,
      Value<double> width,
      Value<String> visibility,
      Value<bool> deleted,
      Value<String> type,
      Value<String> title,
      Value<String?> thumbnailURL,
      Value<String?> videoURL,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$VideosTableTableFilterComposer
    extends Composer<_$AppDatabase, $VideosTableTable> {
  $$VideosTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailURL => $composableBuilder(
    column: $table.thumbnailURL,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoURL => $composableBuilder(
    column: $table.videoURL,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VideosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VideosTableTable> {
  $$VideosTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailURL => $composableBuilder(
    column: $table.thumbnailURL,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoURL => $composableBuilder(
    column: $table.videoURL,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VideosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideosTableTable> {
  $$VideosTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<double> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get thumbnailURL => $composableBuilder(
    column: $table.thumbnailURL,
    builder: (column) => column,
  );

  GeneratedColumn<String> get videoURL =>
      $composableBuilder(column: $table.videoURL, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VideosTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VideosTableTable,
          VideosTableData,
          $$VideosTableTableFilterComposer,
          $$VideosTableTableOrderingComposer,
          $$VideosTableTableAnnotationComposer,
          $$VideosTableTableCreateCompanionBuilder,
          $$VideosTableTableUpdateCompanionBuilder,
          (
            VideosTableData,
            BaseReferences<_$AppDatabase, $VideosTableTable, VideosTableData>,
          ),
          VideosTableData,
          PrefetchHooks Function()
        > {
  $$VideosTableTableTableManager(_$AppDatabase db, $VideosTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideosTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideosTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localPath = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<double> height = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> thumbnailURL = const Value.absent(),
                Value<String?> videoURL = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VideosTableCompanion(
                localPath: localPath,
                userId: userId,
                id: id,
                duration: duration,
                size: size,
                height: height,
                width: width,
                visibility: visibility,
                deleted: deleted,
                type: type,
                title: title,
                thumbnailURL: thumbnailURL,
                videoURL: videoURL,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localPath,
                required String userId,
                required String id,
                Value<int> duration = const Value.absent(),
                required int size,
                required double height,
                required double width,
                Value<String> visibility = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> thumbnailURL = const Value.absent(),
                Value<String?> videoURL = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VideosTableCompanion.insert(
                localPath: localPath,
                userId: userId,
                id: id,
                duration: duration,
                size: size,
                height: height,
                width: width,
                visibility: visibility,
                deleted: deleted,
                type: type,
                title: title,
                thumbnailURL: thumbnailURL,
                videoURL: videoURL,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VideosTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VideosTableTable,
      VideosTableData,
      $$VideosTableTableFilterComposer,
      $$VideosTableTableOrderingComposer,
      $$VideosTableTableAnnotationComposer,
      $$VideosTableTableCreateCompanionBuilder,
      $$VideosTableTableUpdateCompanionBuilder,
      (
        VideosTableData,
        BaseReferences<_$AppDatabase, $VideosTableTable, VideosTableData>,
      ),
      VideosTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VideosTableTableTableManager get videosTable =>
      $$VideosTableTableTableManager(_db, _db.videosTable);
}
