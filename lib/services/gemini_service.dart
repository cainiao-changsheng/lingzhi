import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 错误类型
enum GeminiErrorType {
  network,
  authentication,
  quota,
  request,
  response,
  unknown,
}

// 错误模型
class GeminiError {
  final GeminiErrorType type;
  final String message;
  final int? statusCode;
  final DateTime timestamp;

  GeminiError({
    required this.type,
    required this.message,
    this.statusCode,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'GeminiError(type: $type, message: $message, statusCode: $statusCode)';
  }
}

// Gemini 3.5 Flash 标准配置模板
class GeminiDefaults {
  static const String defaultModel = 'gemini-3.5-flash';
  static const int maxOutputTokens = 8192;
  static const double temperature = 0.9;
  static const double topP = 0.95;
  static const int topK = 40;
  static const double defaultTemperature = 0.7;
  static const double creativeTemperature = 0.9;
  static const double preciseTemperature = 0.3;
}

// 服务配置
class GeminiConfig {
  final String apiKey;
  final String model;
  final int maxOutputTokens;
  final double temperature;
  final double topP;
  final int topK;

  const GeminiConfig({
    required this.apiKey,
    this.model = GeminiDefaults.defaultModel,
    this.maxOutputTokens = GeminiDefaults.maxOutputTokens,
    this.temperature = GeminiDefaults.defaultTemperature,
    this.topP = GeminiDefaults.topP,
    this.topK = GeminiDefaults.topK,
  });

  factory GeminiConfig.standard() {
    return const GeminiConfig(
      apiKey: '',
      model: GeminiDefaults.defaultModel,
      maxOutputTokens: 8192,
      temperature: 0.7,
      topP: 0.95,
      topK: 40,
    );
  }

  factory GeminiConfig.creative() {
    return const GeminiConfig(
      apiKey: '',
      model: GeminiDefaults.defaultModel,
      maxOutputTokens: 8192,
      temperature: 0.9,
      topP: 0.95,
      topK: 40,
    );
  }

  factory GeminiConfig.precise() {
    return const GeminiConfig(
      apiKey: '',
      model: GeminiDefaults.defaultModel,
      maxOutputTokens: 8192,
      temperature: 0.3,
      topP: 0.95,
      topK: 40,
    );
  }

  factory GeminiConfig.fromJson(Map<String, dynamic> json) {
    return GeminiConfig(
      apiKey: json['apiKey'] ?? '',
      model: json['model'] ?? GeminiDefaults.defaultModel,
      maxOutputTokens:
          json['maxOutputTokens'] ?? GeminiDefaults.maxOutputTokens,
      temperature:
          (json['temperature'] ?? GeminiDefaults.defaultTemperature).toDouble(),
      topP: (json['topP'] ?? GeminiDefaults.topP).toDouble(),
      topK: json['topK'] ?? GeminiDefaults.topK,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'model': model,
      'maxOutputTokens': maxOutputTokens,
      'temperature': temperature,
      'topP': topP,
      'topK': topK,
    };
  }
}

// 消息模型
class ChatMessage {
  final String role; // 'user' or 'model'
  final String content;
  final DateTime timestamp;
  final String? id;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.id,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.fromParts({
    required String role,
    required String content,
  }) {
    return ChatMessage(
      role: role,
      content: content,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'id': id,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      id: json['id'],
    );
  }
}

// 服务状态
class GeminiServiceState {
  final bool isInitialized;
  final bool isGenerating;
  final GeminiConfig? config;
  final GeminiError? lastError;
  final int remainingQuota;
  final DateTime? lastRequestTime;

  const GeminiServiceState({
    this.isInitialized = false,
    this.isGenerating = false,
    this.config,
    this.lastError,
    this.remainingQuota = 1500, // 默认免费额度
    this.lastRequestTime,
  });

  GeminiServiceState copyWith({
    bool? isInitialized,
    bool? isGenerating,
    GeminiConfig? config,
    GeminiError? lastError,
    int? remainingQuota,
    DateTime? lastRequestTime,
  }) {
    return GeminiServiceState(
      isInitialized: isInitialized ?? this.isInitialized,
      isGenerating: isGenerating ?? this.isGenerating,
      config: config ?? this.config,
      lastError: lastError ?? this.lastError,
      remainingQuota: remainingQuota ?? this.remainingQuota,
      lastRequestTime: lastRequestTime ?? this.lastRequestTime,
    );
  }
}

// 服务提供者
final geminiServiceProvider =
    StateNotifierProvider<GeminiService, GeminiServiceState>(
  (ref) => GeminiService(),
);

// 主服务类
class GeminiService extends StateNotifier<GeminiServiceState> {
  GenerativeModel? _model;
  ChatSession? _chatSession;
  final List<ChatMessage> _history = [];
  final _responseController = StreamController<String>.broadcast();
  final _errorController = StreamController<GeminiError>.broadcast();

  GeminiService() : super(const GeminiServiceState()) {
    _loadConfig();
  }

  @override
  void dispose() {
    _responseController.close();
    _errorController.close();
    super.dispose();
  }

  // 配置加载
  Future<void> _loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('gemini_config');

      if (configJson != null) {
        final configMap = Map<String, dynamic>.from(
          (configJson as Map<dynamic, dynamic>).cast<String, dynamic>(),
        );
        final config = GeminiConfig.fromJson(configMap);

        state = state.copyWith(
          config: config,
          isInitialized: config.apiKey.isNotEmpty,
        );

        if (config.apiKey.isNotEmpty) {
          await _initializeModel(config);
        }
      }
    } catch (e) {
      _handleError(GeminiError(
        type: GeminiErrorType.unknown,
        message: '配置加载失败: ${e.toString()}',
      ));
    }
  }

  // 保存配置
  Future<void> saveConfig(GeminiConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gemini_config', config.toJson().toString());

      state = state.copyWith(
        config: config,
        isInitialized: config.apiKey.isNotEmpty,
      );

      if (config.apiKey.isNotEmpty) {
        await _initializeModel(config);
      }
    } catch (e) {
      _handleError(GeminiError(
        type: GeminiErrorType.unknown,
        message: '配置保存失败: ${e.toString()}',
      ));
    }
  }

  // 初始化模型
  Future<void> _initializeModel(GeminiConfig config) async {
    try {
      final model = GenerativeModel(
        model: config.model,
        apiKey: config.apiKey,
        generationConfig: GenerationConfig(
          maxOutputTokens: config.maxOutputTokens,
          temperature: config.temperature,
          topP: config.topP,
          topK: config.topK,
        ),
      );

      _model = model;
      _chatSession = model.startChat();

      state = state.copyWith(
        isInitialized: true,
        lastError: null,
      );
    } catch (e) {
      _handleError(GeminiError(
        type: GeminiErrorType.authentication,
        message: '模型初始化失败: ${e.toString()}',
      ));
    }
  }

  // 发送消息
  Future<String> sendMessage(String message) async {
    if (!state.isInitialized) {
      throw GeminiError(
        type: GeminiErrorType.authentication,
        message: 'Gemini API 未配置',
      );
    }

    if (state.isGenerating) {
      throw GeminiError(
        type: GeminiErrorType.request,
        message: '正在生成中，请稍候',
      );
    }

    state = state.copyWith(isGenerating: true);

    try {
      // 添加用户消息到历史
      final userMessage = ChatMessage(
        role: 'user',
        content: message,
      );
      _history.add(userMessage);

      // 发送请求
      final response = await _chatSession!.sendMessage(
        Content.text(message),
      );

      if (response.text == null || response.text!.isEmpty) {
        throw GeminiError(
          type: GeminiErrorType.response,
          message: '收到空响应',
        );
      }

      // 添加模型响应到历史
      final modelMessage = ChatMessage(
        role: 'model',
        content: response.text!,
      );
      _history.add(modelMessage);

      // 更新状态
      state = state.copyWith(
        isGenerating: false,
        lastRequestTime: DateTime.now(),
        remainingQuota: state.remainingQuota - 1,
      );

      return response.text!;
    } catch (e) {
      _handleError(GeminiError(
        type: GeminiErrorType.network,
        message: '请求失败: ${e.toString()}',
      ));
      rethrow;
    } finally {
      state = state.copyWith(isGenerating: false);
    }
  }

  // 流式响应
  Stream<String> sendMessageStream(String message) async* {
    if (!state.isInitialized) {
      throw GeminiError(
        type: GeminiErrorType.authentication,
        message: 'Gemini API 未配置',
      );
    }

    state = state.copyWith(isGenerating: true);

    try {
      // 添加用户消息到历史
      final userMessage = ChatMessage(
        role: 'user',
        content: message,
      );
      _history.add(userMessage);

      // 发送流式请求
      final response = _chatSession!.sendMessageStream(
        Content.text(message),
      );

      final buffer = StringBuffer();

      await for (final chunk in response) {
        if (chunk.text != null) {
          buffer.write(chunk.text);
          yield chunk.text!;
        }
      }

      // 添加完整响应到历史
      final modelMessage = ChatMessage(
        role: 'model',
        content: buffer.toString(),
      );
      _history.add(modelMessage);

      // 更新状态
      state = state.copyWith(
        isGenerating: false,
        lastRequestTime: DateTime.now(),
        remainingQuota: state.remainingQuota - 1,
      );
    } catch (e) {
      _handleError(GeminiError(
        type: GeminiErrorType.network,
        message: '流式请求失败: ${e.toString()}',
      ));
      rethrow;
    } finally {
      state = state.copyWith(isGenerating: false);
    }
  }

  // 错误处理
  void _handleError(GeminiError error) {
    state = state.copyWith(lastError: error);
    _errorController.add(error);
  }

  // 获取历史记录
  List<ChatMessage> getHistory() => List.unmodifiable(_history);

  // 清空历史
  void clearHistory() {
    _history.clear();
    if (_model != null) {
      _chatSession = _model!.startChat();
    }
  }

  // 获取配置
  GeminiConfig? getConfig() => state.config;

  // 获取状态
  GeminiServiceState getServiceState() => state;

  // 错误流
  Stream<GeminiError> get errorStream => _errorController.stream;

  // 响应流
  Stream<String> get responseStream => _responseController.stream;

  // 测试连接
  Future<bool> testConnection() async {
    if (!state.isInitialized) {
      return false;
    }

    try {
      final testResponse = await _chatSession!.sendMessage(
        Content.text('Hello'),
      );

      return testResponse.text != null && testResponse.text!.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // 获取配额信息
  Map<String, dynamic> getQuotaInfo() {
    return {
      'remaining': state.remainingQuota,
      'total': 1500,
      'lastRequest': state.lastRequestTime,
      'percentage': (state.remainingQuota / 1500 * 100).toStringAsFixed(1),
    };
  }

  // 重置错误
  void resetError() {
    state = state.copyWith(lastError: null);
  }
}
