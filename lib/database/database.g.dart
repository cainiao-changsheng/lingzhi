// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, role, content, timestamp, isRead, isFavorite];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(Insertable<ChatMessage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final int id;
  final String role;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool isFavorite;
  const ChatMessage(
      {required this.id,
      required this.role,
      required this.content,
      required this.timestamp,
      required this.isRead,
      required this.isFavorite});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['is_read'] = Variable<bool>(isRead);
    map['is_favorite'] = Variable<bool>(isFavorite);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      role: Value(role),
      content: Value(content),
      timestamp: Value(timestamp),
      isRead: Value(isRead),
      isFavorite: Value(isFavorite),
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<int>(json['id']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'isRead': serializer.toJson<bool>(isRead),
      'isFavorite': serializer.toJson<bool>(isFavorite),
    };
  }

  ChatMessage copyWith(
          {int? id,
          String? role,
          String? content,
          DateTime? timestamp,
          bool? isRead,
          bool? isFavorite}) =>
      ChatMessage(
        id: id ?? this.id,
        role: role ?? this.role,
        content: content ?? this.content,
        timestamp: timestamp ?? this.timestamp,
        isRead: isRead ?? this.isRead,
        isFavorite: isFavorite ?? this.isFavorite,
      );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp, ')
          ..write('isRead: $isRead, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, role, content, timestamp, isRead, isFavorite);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.role == this.role &&
          other.content == this.content &&
          other.timestamp == this.timestamp &&
          other.isRead == this.isRead &&
          other.isFavorite == this.isFavorite);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<int> id;
  final Value<String> role;
  final Value<String> content;
  final Value<DateTime> timestamp;
  final Value<bool> isRead;
  final Value<bool> isFavorite;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isFavorite = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required String role,
    required String content,
    this.timestamp = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isFavorite = const Value.absent(),
  })  : role = Value(role),
        content = Value(content);
  static Insertable<ChatMessage> custom({
    Expression<int>? id,
    Expression<String>? role,
    Expression<String>? content,
    Expression<DateTime>? timestamp,
    Expression<bool>? isRead,
    Expression<bool>? isFavorite,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (timestamp != null) 'timestamp': timestamp,
      if (isRead != null) 'is_read': isRead,
      if (isFavorite != null) 'is_favorite': isFavorite,
    });
  }

  ChatMessagesCompanion copyWith(
      {Value<int>? id,
      Value<String>? role,
      Value<String>? content,
      Value<DateTime>? timestamp,
      Value<bool>? isRead,
      Value<bool>? isFavorite}) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp, ')
          ..write('isRead: $isRead, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }
}

class $GeneratedImagesTable extends GeneratedImages
    with TableInfo<$GeneratedImagesTable, GeneratedImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeneratedImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
      'prompt', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
      'width', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(512));
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
      'height', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(512));
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<int> steps = GeneratedColumn<int>(
      'steps', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(20));
  static const VerificationMeta _guidanceScaleMeta =
      const VerificationMeta('guidanceScale');
  @override
  late final GeneratedColumn<double> guidanceScale = GeneratedColumn<double>(
      'guidance_scale', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(7.5));
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
      'model', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('stable-diffusion-1.5'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        prompt,
        filePath,
        timestamp,
        width,
        height,
        steps,
        guidanceScale,
        isFavorite,
        model
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'generated_images';
  @override
  VerificationContext validateIntegrity(Insertable<GeneratedImage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('prompt')) {
      context.handle(_promptMeta,
          prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta));
    } else if (isInserting) {
      context.missing(_promptMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('width')) {
      context.handle(
          _widthMeta, width.isAcceptableOrUnknown(data['width']!, _widthMeta));
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta,
          height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    }
    if (data.containsKey('steps')) {
      context.handle(
          _stepsMeta, steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta));
    }
    if (data.containsKey('guidance_scale')) {
      context.handle(
          _guidanceScaleMeta,
          guidanceScale.isAcceptableOrUnknown(
              data['guidance_scale']!, _guidanceScaleMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('model')) {
      context.handle(
          _modelMeta, model.isAcceptableOrUnknown(data['model']!, _modelMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeneratedImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeneratedImage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      prompt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prompt'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      width: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}width'])!,
      height: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height'])!,
      steps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}steps'])!,
      guidanceScale: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}guidance_scale'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      model: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model'])!,
    );
  }

  @override
  $GeneratedImagesTable createAlias(String alias) {
    return $GeneratedImagesTable(attachedDatabase, alias);
  }
}

class GeneratedImage extends DataClass implements Insertable<GeneratedImage> {
  final int id;
  final String prompt;
  final String filePath;
  final DateTime timestamp;
  final int width;
  final int height;
  final int steps;
  final double guidanceScale;
  final bool isFavorite;
  final String model;
  const GeneratedImage(
      {required this.id,
      required this.prompt,
      required this.filePath,
      required this.timestamp,
      required this.width,
      required this.height,
      required this.steps,
      required this.guidanceScale,
      required this.isFavorite,
      required this.model});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['prompt'] = Variable<String>(prompt);
    map['file_path'] = Variable<String>(filePath);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    map['steps'] = Variable<int>(steps);
    map['guidance_scale'] = Variable<double>(guidanceScale);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['model'] = Variable<String>(model);
    return map;
  }

  GeneratedImagesCompanion toCompanion(bool nullToAbsent) {
    return GeneratedImagesCompanion(
      id: Value(id),
      prompt: Value(prompt),
      filePath: Value(filePath),
      timestamp: Value(timestamp),
      width: Value(width),
      height: Value(height),
      steps: Value(steps),
      guidanceScale: Value(guidanceScale),
      isFavorite: Value(isFavorite),
      model: Value(model),
    );
  }

  factory GeneratedImage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeneratedImage(
      id: serializer.fromJson<int>(json['id']),
      prompt: serializer.fromJson<String>(json['prompt']),
      filePath: serializer.fromJson<String>(json['filePath']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      steps: serializer.fromJson<int>(json['steps']),
      guidanceScale: serializer.fromJson<double>(json['guidanceScale']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      model: serializer.fromJson<String>(json['model']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'prompt': serializer.toJson<String>(prompt),
      'filePath': serializer.toJson<String>(filePath),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'steps': serializer.toJson<int>(steps),
      'guidanceScale': serializer.toJson<double>(guidanceScale),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'model': serializer.toJson<String>(model),
    };
  }

  GeneratedImage copyWith(
          {int? id,
          String? prompt,
          String? filePath,
          DateTime? timestamp,
          int? width,
          int? height,
          int? steps,
          double? guidanceScale,
          bool? isFavorite,
          String? model}) =>
      GeneratedImage(
        id: id ?? this.id,
        prompt: prompt ?? this.prompt,
        filePath: filePath ?? this.filePath,
        timestamp: timestamp ?? this.timestamp,
        width: width ?? this.width,
        height: height ?? this.height,
        steps: steps ?? this.steps,
        guidanceScale: guidanceScale ?? this.guidanceScale,
        isFavorite: isFavorite ?? this.isFavorite,
        model: model ?? this.model,
      );
  GeneratedImage copyWithCompanion(GeneratedImagesCompanion data) {
    return GeneratedImage(
      id: data.id.present ? data.id.value : this.id,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      steps: data.steps.present ? data.steps.value : this.steps,
      guidanceScale: data.guidanceScale.present
          ? data.guidanceScale.value
          : this.guidanceScale,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      model: data.model.present ? data.model.value : this.model,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeneratedImage(')
          ..write('id: $id, ')
          ..write('prompt: $prompt, ')
          ..write('filePath: $filePath, ')
          ..write('timestamp: $timestamp, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('steps: $steps, ')
          ..write('guidanceScale: $guidanceScale, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('model: $model')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, prompt, filePath, timestamp, width,
      height, steps, guidanceScale, isFavorite, model);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeneratedImage &&
          other.id == this.id &&
          other.prompt == this.prompt &&
          other.filePath == this.filePath &&
          other.timestamp == this.timestamp &&
          other.width == this.width &&
          other.height == this.height &&
          other.steps == this.steps &&
          other.guidanceScale == this.guidanceScale &&
          other.isFavorite == this.isFavorite &&
          other.model == this.model);
}

class GeneratedImagesCompanion extends UpdateCompanion<GeneratedImage> {
  final Value<int> id;
  final Value<String> prompt;
  final Value<String> filePath;
  final Value<DateTime> timestamp;
  final Value<int> width;
  final Value<int> height;
  final Value<int> steps;
  final Value<double> guidanceScale;
  final Value<bool> isFavorite;
  final Value<String> model;
  const GeneratedImagesCompanion({
    this.id = const Value.absent(),
    this.prompt = const Value.absent(),
    this.filePath = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.steps = const Value.absent(),
    this.guidanceScale = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.model = const Value.absent(),
  });
  GeneratedImagesCompanion.insert({
    this.id = const Value.absent(),
    required String prompt,
    required String filePath,
    this.timestamp = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.steps = const Value.absent(),
    this.guidanceScale = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.model = const Value.absent(),
  })  : prompt = Value(prompt),
        filePath = Value(filePath);
  static Insertable<GeneratedImage> custom({
    Expression<int>? id,
    Expression<String>? prompt,
    Expression<String>? filePath,
    Expression<DateTime>? timestamp,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? steps,
    Expression<double>? guidanceScale,
    Expression<bool>? isFavorite,
    Expression<String>? model,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (prompt != null) 'prompt': prompt,
      if (filePath != null) 'file_path': filePath,
      if (timestamp != null) 'timestamp': timestamp,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (steps != null) 'steps': steps,
      if (guidanceScale != null) 'guidance_scale': guidanceScale,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (model != null) 'model': model,
    });
  }

  GeneratedImagesCompanion copyWith(
      {Value<int>? id,
      Value<String>? prompt,
      Value<String>? filePath,
      Value<DateTime>? timestamp,
      Value<int>? width,
      Value<int>? height,
      Value<int>? steps,
      Value<double>? guidanceScale,
      Value<bool>? isFavorite,
      Value<String>? model}) {
    return GeneratedImagesCompanion(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      filePath: filePath ?? this.filePath,
      timestamp: timestamp ?? this.timestamp,
      width: width ?? this.width,
      height: height ?? this.height,
      steps: steps ?? this.steps,
      guidanceScale: guidanceScale ?? this.guidanceScale,
      isFavorite: isFavorite ?? this.isFavorite,
      model: model ?? this.model,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (steps.present) {
      map['steps'] = Variable<int>(steps.value);
    }
    if (guidanceScale.present) {
      map['guidance_scale'] = Variable<double>(guidanceScale.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeneratedImagesCompanion(')
          ..write('id: $id, ')
          ..write('prompt: $prompt, ')
          ..write('filePath: $filePath, ')
          ..write('timestamp: $timestamp, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('steps: $steps, ')
          ..write('guidanceScale: $guidanceScale, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('model: $model')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $GeneratedImagesTable generatedImages =
      $GeneratedImagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [chatMessages, generatedImages];
}

typedef $$ChatMessagesTableCreateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<int> id,
  required String role,
  required String content,
  Value<DateTime> timestamp,
  Value<bool> isRead,
  Value<bool> isFavorite,
});
typedef $$ChatMessagesTableUpdateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<int> id,
  Value<String> role,
  Value<String> content,
  Value<DateTime> timestamp,
  Value<bool> isRead,
  Value<bool> isFavorite,
});

class $$ChatMessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatMessagesTable,
    ChatMessage,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder> {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ChatMessagesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ChatMessagesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
          }) =>
              ChatMessagesCompanion(
            id: id,
            role: role,
            content: content,
            timestamp: timestamp,
            isRead: isRead,
            isFavorite: isFavorite,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String role,
            required String content,
            Value<DateTime> timestamp = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
          }) =>
              ChatMessagesCompanion.insert(
            id: id,
            role: role,
            content: content,
            timestamp: timestamp,
            isRead: isRead,
            isFavorite: isFavorite,
          ),
        ));
}

class $$ChatMessagesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get role => $state.composableBuilder(
      column: $state.table.role,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isRead => $state.composableBuilder(
      column: $state.table.isRead,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isFavorite => $state.composableBuilder(
      column: $state.table.isFavorite,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ChatMessagesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get role => $state.composableBuilder(
      column: $state.table.role,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isRead => $state.composableBuilder(
      column: $state.table.isRead,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isFavorite => $state.composableBuilder(
      column: $state.table.isFavorite,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$GeneratedImagesTableCreateCompanionBuilder = GeneratedImagesCompanion
    Function({
  Value<int> id,
  required String prompt,
  required String filePath,
  Value<DateTime> timestamp,
  Value<int> width,
  Value<int> height,
  Value<int> steps,
  Value<double> guidanceScale,
  Value<bool> isFavorite,
  Value<String> model,
});
typedef $$GeneratedImagesTableUpdateCompanionBuilder = GeneratedImagesCompanion
    Function({
  Value<int> id,
  Value<String> prompt,
  Value<String> filePath,
  Value<DateTime> timestamp,
  Value<int> width,
  Value<int> height,
  Value<int> steps,
  Value<double> guidanceScale,
  Value<bool> isFavorite,
  Value<String> model,
});

class $$GeneratedImagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GeneratedImagesTable,
    GeneratedImage,
    $$GeneratedImagesTableFilterComposer,
    $$GeneratedImagesTableOrderingComposer,
    $$GeneratedImagesTableCreateCompanionBuilder,
    $$GeneratedImagesTableUpdateCompanionBuilder> {
  $$GeneratedImagesTableTableManager(
      _$AppDatabase db, $GeneratedImagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$GeneratedImagesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$GeneratedImagesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> prompt = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> width = const Value.absent(),
            Value<int> height = const Value.absent(),
            Value<int> steps = const Value.absent(),
            Value<double> guidanceScale = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<String> model = const Value.absent(),
          }) =>
              GeneratedImagesCompanion(
            id: id,
            prompt: prompt,
            filePath: filePath,
            timestamp: timestamp,
            width: width,
            height: height,
            steps: steps,
            guidanceScale: guidanceScale,
            isFavorite: isFavorite,
            model: model,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String prompt,
            required String filePath,
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> width = const Value.absent(),
            Value<int> height = const Value.absent(),
            Value<int> steps = const Value.absent(),
            Value<double> guidanceScale = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<String> model = const Value.absent(),
          }) =>
              GeneratedImagesCompanion.insert(
            id: id,
            prompt: prompt,
            filePath: filePath,
            timestamp: timestamp,
            width: width,
            height: height,
            steps: steps,
            guidanceScale: guidanceScale,
            isFavorite: isFavorite,
            model: model,
          ),
        ));
}

class $$GeneratedImagesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $GeneratedImagesTable> {
  $$GeneratedImagesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get prompt => $state.composableBuilder(
      column: $state.table.prompt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get filePath => $state.composableBuilder(
      column: $state.table.filePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get width => $state.composableBuilder(
      column: $state.table.width,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get height => $state.composableBuilder(
      column: $state.table.height,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get steps => $state.composableBuilder(
      column: $state.table.steps,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get guidanceScale => $state.composableBuilder(
      column: $state.table.guidanceScale,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isFavorite => $state.composableBuilder(
      column: $state.table.isFavorite,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get model => $state.composableBuilder(
      column: $state.table.model,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$GeneratedImagesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $GeneratedImagesTable> {
  $$GeneratedImagesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get prompt => $state.composableBuilder(
      column: $state.table.prompt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get filePath => $state.composableBuilder(
      column: $state.table.filePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get width => $state.composableBuilder(
      column: $state.table.width,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get height => $state.composableBuilder(
      column: $state.table.height,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get steps => $state.composableBuilder(
      column: $state.table.steps,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get guidanceScale => $state.composableBuilder(
      column: $state.table.guidanceScale,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isFavorite => $state.composableBuilder(
      column: $state.table.isFavorite,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get model => $state.composableBuilder(
      column: $state.table.model,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$GeneratedImagesTableTableManager get generatedImages =>
      $$GeneratedImagesTableTableManager(_db, _db.generatedImages);
}
