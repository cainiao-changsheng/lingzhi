import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@DriftDatabase(tables: [ChatMessages, GeneratedImages, MusicFiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // 聊天消息操作
  Future<int> insertChatMessage(ChatMessagesCompanion message) {
    return into(chatMessages).insert(message);
  }

  Future<List<ChatMessage>> getChatMessages({int limit = 100, int offset = 0}) {
    return (select(chatMessages)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<void> clearChatMessages() {
    return delete(chatMessages).go();
  }

  Future<int> getChatMessageCount() {
    return select(chatMessages).get().then((messages) => messages.length);
  }

  // 生成图片操作
  Future<int> insertGeneratedImage(GeneratedImagesCompanion image) {
    return into(generatedImages).insert(image);
  }

  Future<List<GeneratedImage>> getGeneratedImages(
      {int limit = 50, int offset = 0}) {
    return (select(generatedImages)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<void> clearGeneratedImages() {
    return delete(generatedImages).go();
  }

  // 音乐文件操作
  Future<int> insertMusicFile(MusicFilesCompanion file) {
    return into(musicFiles).insert(file);
  }

  Future<List<MusicFile>> getMusicFiles({String? directory, int limit = 100}) {
    final query = select(musicFiles);
    if (directory != null) {
      query.where((t) => t.directory.equals(directory));
    }
    query
      ..orderBy([(t) => OrderingTerm(expression: t.title)])
      ..limit(limit);
    return query.get();
  }

  Future<void> clearMusicFiles() {
    return delete(musicFiles).go();
  }

  Future<void> updateMusicFilePlayCount(int id) {
    return (update(musicFiles)..where((t) => t.id.equals(id))).write(
      MusicFilesCompanion(playCount: const Value(0)),
    );
  }

  // 批量操作
  Future<void> insertChatMessagesBatch(List<ChatMessagesCompanion> messages) {
    return batch((batch) {
      batch.insertAll(chatMessages, messages);
    });
  }

  Future<void> insertGeneratedImagesBatch(
      List<GeneratedImagesCompanion> images) {
    return batch((batch) {
      batch.insertAll(generatedImages, images);
    });
  }

  Future<void> insertMusicFilesBatch(List<MusicFilesCompanion> files) {
    return batch((batch) {
      batch.insertAll(musicFiles, files);
    });
  }

  // 统计信息
  Future<DatabaseStats> getDatabaseStats() async {
    final messageCount = await getChatMessageCount();
    final imageCount =
        await select(generatedImages).get().then((images) => images.length);
    final musicCount =
        await select(musicFiles).get().then((files) => files.length);

    return DatabaseStats(
      messageCount: messageCount,
      imageCount: imageCount,
      musicCount: musicCount,
      totalSize: await _getDatabaseSize(),
    );
  }

  Future<int> _getDatabaseSize() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(directory.path, 'app.db');
    final file = File(dbPath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'app.db'));
    return NativeDatabase(file);
  });
}

class DatabaseStats {
  final int messageCount;
  final int imageCount;
  final int musicCount;
  final int totalSize;

  DatabaseStats({
    required this.messageCount,
    required this.imageCount,
    required this.musicCount,
    required this.totalSize,
  });

  String get formattedSize {
    if (totalSize < 1024) return '${totalSize}B';
    if (totalSize < 1024 * 1024)
      return '${(totalSize / 1024).toStringAsFixed(1)}KB';
    return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

// 聊天消息表
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get role => text()(); // 'user' or 'model'
  TextColumn get content => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}

// 生成图片表
class GeneratedImages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get prompt => text()();
  TextColumn get filePath => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  IntColumn get width => integer().withDefault(const Constant(512))();
  IntColumn get height => integer().withDefault(const Constant(512))();
  IntColumn get steps => integer().withDefault(const Constant(20))();
  RealColumn get guidanceScale => real().withDefault(const Constant(7.5))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get model =>
      text().withDefault(const Constant('stable-diffusion-1.5'))();
}

// 音乐文件表
class MusicFiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text().unique()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get album => text().nullable()();
  TextColumn get directory => text()();
  IntColumn get duration => integer().nullable()(); // 秒
  IntColumn get fileSize => integer().nullable()(); // 字节
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayed => dateTime().nullable()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}
