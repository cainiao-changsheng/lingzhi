import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:ai_agent_mobile_app/database/database.dart';
import 'package:ai_agent_mobile_app/features/chat/models/chat_message.dart'
    as model;

class ChatPersistenceService extends StateNotifier<ChatPersistenceState> {
  final AppDatabase _database;
  late Timer _autoSaveTimer;
  final int _autoSaveInterval = 30; // 30秒自动保存

  ChatPersistenceService(this._database) : super(ChatPersistenceState()) {
    _startAutoSaveTimer();
  }

  @override
  void dispose() {
    _autoSaveTimer.cancel();
    super.dispose();
  }

  // 启动自动保存定时器
  void _startAutoSaveTimer() {
    _autoSaveTimer = Timer.periodic(
      Duration(seconds: _autoSaveInterval),
      (_) => _autoSave(),
    );
  }

  // 自动保存
  Future<void> _autoSave() async {
    if (state.unsavedMessages.isEmpty) return;

    try {
      await _saveMessages(state.unsavedMessages);
      setState(() {
        state = state.copyWith(
          unsavedMessages: [],
          lastAutoSave: DateTime.now(),
        );
      });
    } catch (e) {
      // 静默失败，下次重试
    }
  }

  // 保存消息
  Future<void> saveMessage(model.ChatMessage message) async {
    final companion = ChatMessagesCompanion(
      role: Value(message.role),
      content: Value(message.content),
      timestamp: Value(message.timestamp),
      isRead: Value(true),
      isFavorite: Value(false),
    );

    try {
      await _database.insertChatMessage(companion);
      setState(() {
        state = state.copyWith(
          lastSave: DateTime.now(),
          saveCount: state.saveCount + 1,
        );
      });
    } catch (e) {
      // 添加到待保存队列
      setState(() {
        state = state.copyWith(
          unsavedMessages: [...state.unsavedMessages, message],
          lastError: e.toString(),
        );
      });
    }
  }

  // 批量保存消息
  Future<void> _saveMessages(List<model.ChatMessage> messages) async {
    if (messages.isEmpty) return;

    final companions = messages
        .map((message) => ChatMessagesCompanion(
              role: Value(message.role),
              content: Value(message.content),
              timestamp: Value(message.timestamp),
              isRead: Value(true),
              isFavorite: Value(false),
            ))
        .toList();

    try {
      await _database.insertChatMessagesBatch(companions);
      setState(() {
        state = state.copyWith(
          unsavedMessages: [],
          lastSave: DateTime.now(),
          saveCount: state.saveCount + messages.length,
        );
      });
    } catch (e) {
      setState(() {
        state = state.copyWith(
          lastError: e.toString(),
        );
      });
    }
  }

  // 加载历史消息
  Future<List<model.ChatMessage>> loadHistory({
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final dbMessages = await _database.getChatMessages(
        limit: limit,
        offset: offset,
      );

      return dbMessages
          .map((dbMessage) => model.ChatMessage(
                role: dbMessage.role,
                content: dbMessage.content,
                timestamp: dbMessage.timestamp,
              ))
          .toList();
    } catch (e) {
      setState(() {
        state = state.copyWith(
          lastError: e.toString(),
        );
      });
      return [];
    }
  }

  // 清空聊天历史
  Future<void> clearHistory() async {
    try {
      await _database.clearChatMessages();
      setState(() {
        state = state.copyWith(
          clearCount: state.clearCount + 1,
          lastClear: DateTime.now(),
        );
      });
    } catch (e) {
      setState(() {
        state = state.copyWith(
          lastError: e.toString(),
        );
      });
    }
  }

  // 获取统计信息
  Future<ChatPersistenceStats> getStats() async {
    try {
      final dbStats = await _database.getDatabaseStats();
      final messageCount = await _database.getChatMessageCount();

      return ChatPersistenceStats(
        totalMessages: messageCount,
        savedMessages: state.saveCount,
        unsavedMessages: state.unsavedMessages.length,
        lastSave: state.lastSave,
        lastError: state.lastError,
        databaseSize: dbStats.formattedSize,
      );
    } catch (e) {
      return ChatPersistenceStats(
        totalMessages: 0,
        savedMessages: 0,
        unsavedMessages: state.unsavedMessages.length,
        lastSave: state.lastSave,
        lastError: e.toString(),
        databaseSize: '未知',
      );
    }
  }

  // 强制保存所有待保存消息
  Future<void> forceSaveAll() async {
    if (state.unsavedMessages.isEmpty) return;

    try {
      await _saveMessages(state.unsavedMessages);
    } catch (e) {
      rethrow;
    }
  }

  // 导出聊天记录
  Future<String> exportChatHistory() async {
    try {
      final messages = await _database.getChatMessages(limit: 1000);

      final exportData = {
        'exportTime': DateTime.now().toIso8601String(),
        'messageCount': messages.length,
        'messages': messages
            .map((msg) => {
                  'role': msg.role,
                  'content': msg.content,
                  'timestamp': msg.timestamp.toIso8601String(),
                  'isFavorite': msg.isFavorite,
                })
            .toList(),
      };

      return exportData.toString();
    } catch (e) {
      throw Exception('导出失败: $e');
    }
  }

  // 设置状态辅助方法
  void setState(void Function() fn) {
    fn();
  }
}

class ChatPersistenceState {
  final List<model.ChatMessage> unsavedMessages;
  final DateTime? lastSave;
  final DateTime? lastAutoSave;
  final DateTime? lastClear;
  final String? lastError;
  final int saveCount;
  final int clearCount;

  ChatPersistenceState({
    this.unsavedMessages = const [],
    this.lastSave,
    this.lastAutoSave,
    this.lastClear,
    this.lastError,
    this.saveCount = 0,
    this.clearCount = 0,
  });

  ChatPersistenceState copyWith({
    List<model.ChatMessage>? unsavedMessages,
    DateTime? lastSave,
    DateTime? lastAutoSave,
    DateTime? lastClear,
    String? lastError,
    int? saveCount,
    int? clearCount,
  }) {
    return ChatPersistenceState(
      unsavedMessages: unsavedMessages ?? this.unsavedMessages,
      lastSave: lastSave ?? this.lastSave,
      lastAutoSave: lastAutoSave ?? this.lastAutoSave,
      lastClear: lastClear ?? this.lastClear,
      lastError: lastError ?? this.lastError,
      saveCount: saveCount ?? this.saveCount,
      clearCount: clearCount ?? this.clearCount,
    );
  }
}

class ChatPersistenceStats {
  final int totalMessages;
  final int savedMessages;
  final int unsavedMessages;
  final DateTime? lastSave;
  final String? lastError;
  final String databaseSize;

  ChatPersistenceStats({
    required this.totalMessages,
    required this.savedMessages,
    required this.unsavedMessages,
    this.lastSave,
    this.lastError,
    required this.databaseSize,
  });

  String get status {
    if (lastError != null) return '错误';
    if (unsavedMessages > 0) return '待保存';
    return '正常';
  }

  String get lastSaveFormatted {
    if (lastSave == null) return '从未保存';
    final diff = DateTime.now().difference(lastSave!);
    if (diff.inDays > 0) return '${diff.inDays}天前';
    if (diff.inHours > 0) return '${diff.inHours}小时前';
    if (diff.inMinutes > 0) return '${diff.inMinutes}分钟前';
    return '刚刚';
  }
}

final chatPersistenceServiceProvider = StateNotifierProvider.autoDispose<
    ChatPersistenceService, ChatPersistenceState>((ref) {
  final database = ref.watch(databaseProvider);
  return ChatPersistenceService(database);
});

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
