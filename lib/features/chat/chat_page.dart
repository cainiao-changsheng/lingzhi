import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_agent_mobile_app/services/gemini_service.dart' as gemini;
import 'package:ai_agent_mobile_app/services/chat_persistence_service.dart';
import 'package:ai_agent_mobile_app/theme/theme.dart';
import 'package:ai_agent_mobile_app/features/chat/models/chat_message.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _streamingText = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _setupAutoSave();
  }

  void _setupAutoSave() {
    // 每30秒自动保存一次
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _saveCurrentMessages();
      }
    });
  }

  Future<void> _loadHistory() async {
    try {
      final persistence = ref.read(chatPersistenceServiceProvider.notifier);
      final history = await persistence.loadHistory(limit: 50);

      if (history.isNotEmpty) {
        setState(() {
          _messages.clear();
          _messages.addAll(history);
        });
      } else {
        // 没有历史记录，显示欢迎消息
        _messages.add(ChatMessage(
          role: 'model',
          content:
              '你好！我是灵智，你的智能助手。\n\n我可以帮你：\n• 聊天和回答问题\n• 播放音乐\n• 生成图片\n• 设定时任务\n\n请先在设置中配置 Gemini API Key。',
        ));
      }
    } catch (e) {
      // 加载失败，显示默认消息
      _messages.add(ChatMessage(
        role: 'model',
        content:
            '你好！我是 Marvis，你的 AI 助手。\n\n我可以帮你：\n• 聊天和回答问题\n• 播放音乐\n• 生成图片\n• 设定时任务\n\n请先在设置中配置 Gemini API Key。',
      ));
    }
  }

  Future<void> _saveCurrentMessages() async {
    if (_messages.isEmpty) return;

    try {
      final persistence = ref.read(chatPersistenceServiceProvider.notifier);
      for (final message in _messages) {
        await persistence.saveMessage(message);
      }
    } catch (e) {
      // 静默失败，下次重试
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    final geminiService = ref.read(gemini.geminiServiceProvider.notifier);
    final geminiState = ref.read(gemini.geminiServiceProvider);

    if (!geminiState.isInitialized) {
      setState(() {
        _messages.add(
            ChatMessage(role: 'model', content: '请先在设置中配置 Gemini API Key。'));
      });
      _scrollToBottom();
      return;
    }

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: message));
      _isLoading = true;
      _streamingText = '';
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final stream = geminiService.sendMessageStream(message);
      final buffer = StringBuffer();

      await for (final chunk in stream) {
        buffer.write(chunk);
        setState(() {
          _streamingText = buffer.toString();
        });
        _scrollToBottom();
      }

      setState(() {
        _messages.add(ChatMessage(role: 'model', content: buffer.toString()));
        _streamingText = '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          role: 'model',
          content: '抱歉，请求失败：${e.toString()}\n\n请检查网络连接和 API 配置后重试。',
        ));
        _streamingText = '';
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length +
                  (_isLoading && _streamingText.isEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length &&
                    _isLoading &&
                    _streamingText.isEmpty) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
        ),
        _buildStreamingBubble(),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildStreamingBubble() {
    if (_streamingText.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  _streamingText,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(width: 4),
              const SizedBox(
                width: 12,
                height: 16,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _BlinkingCursor(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: isUser ? AppColors.surface : AppColors.cardBackground,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isUser ? 12 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 12),
            ),
            border: Border.all(
              color: isUser ? AppColors.primary : AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: const TextStyle(
                    color: Colors.white, fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              return Padding(
                padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
                child: _buildDot(i),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final phase = (value + delay) % 1.0;
        final opacity = 0.3 + (1.0 - (phase - 0.5).abs() * 2.0) * 0.7;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: '输入消息...',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _sendMessage,
              icon:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 16,
        color: AppColors.primary,
      ),
    );
  }
}
