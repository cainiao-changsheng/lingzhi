import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 支持的模型提供商
enum ModelProvider {
  gemini,
  deepseek,
  openAI,
  custom,
}

// 模型配置
class ModelConfig {
  final ModelProvider provider;
  final String apiKey;
  final String baseUrl;
  final String modelName;

  ModelConfig({
    required this.provider,
    required this.apiKey,
    required this.baseUrl,
    required this.modelName,
  });

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.index,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'modelName': modelName,
    };
  }

  factory ModelConfig.fromJson(Map<String, dynamic> json) {
    return ModelConfig(
      provider: ModelProvider.values[json['provider'] ?? 0],
      apiKey: json['apiKey'] ?? '',
      baseUrl: json['baseUrl'] ?? '',
      modelName: json['modelName'] ?? '',
    );
  }

  ModelConfig copyWith({
    ModelProvider? provider,
    String? apiKey,
    String? baseUrl,
    String? modelName,
  }) {
    return ModelConfig(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      modelName: modelName ?? this.modelName,
    );
  }
}

// 聊天消息
class ChatMessage {
  final String role; // 'user' or 'model'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

// Gemini 3.5 Flash 标准配置模板
class GeminiDefaults {
  static const String defaultModel = 'gemini-1.5-flash';
  static const String fallbackModel = 'gemini-2.0-flash-exp';
  static const String baseUrl = 'https://generativelanguage.googleapis.com';
}

// 服务状态
class GeminiState {
  final bool isInitialized;
  final bool isLoading;
  final String? lastError;
  final List<ChatMessage> messages;
  final ModelConfig? config;

  GeminiState({
    this.isInitialized = false,
    this.isLoading = false,
    this.lastError,
    this.messages = const [],
    this.config,
  });

  GeminiState copyWith({
    bool? isInitialized,
    bool? isLoading,
    String? lastError,
    List<ChatMessage>? messages,
    ModelConfig? config,
  }) {
    return GeminiState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      lastError: lastError,
      messages: messages ?? this.messages,
      config: config ?? this.config,
    );
  }
}

class GeminiService extends StateNotifier<GeminiState> {
  final Dio _dio;
  SharedPreferences? _prefs;

  GeminiService() : _dio = Dio(), super(GeminiState()) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadConfig();
  }

  Future<void> _loadConfig() async {
    final configJson = _prefs?.getString('model_config');
    if (configJson != null) {
      try {
        final config = ModelConfig.fromJson(json.decode(configJson));
        state = state.copyWith(
          config: config,
          isInitialized: config.apiKey.isNotEmpty,
        );
      } catch (e) {
        debugPrint('加载配置失败: $e');
      }
    }
  }

  Future<void> saveConfig(ModelConfig config) async {
    final configJson = json.encode(config.toJson());
    await _prefs?.setString('model_config', configJson);
    state = state.copyWith(
      config: config,
      isInitialized: config.apiKey.isNotEmpty,
      lastError: null,
    );
  }

  ModelConfig? getConfig() {
    return state.config;
  }

  // 获取默认配置
  static ModelConfig getDefaultConfig() {
    return ModelConfig(
      provider: ModelProvider.gemini,
      apiKey: '',
      baseUrl: GeminiDefaults.baseUrl,
      modelName: GeminiDefaults.defaultModel,
    );
  }

  Stream<String> sendMessageStream(String message) async* {
    if (state.config == null || state.config!.apiKey.isEmpty) {
      throw Exception('请先在设置中配置 API Key');
    }

    final config = state.config!;
    state = state.copyWith(isLoading: true, lastError: null);

    try {
      // 添加用户消息
      final updatedMessages = List<ChatMessage>.from(state.messages)
        ..add(ChatMessage(role: 'user', content: message));
      state = state.copyWith(messages: updatedMessages);

      final response = await _sendRequest(config, updatedMessages);

      final buffer = StringBuffer();
      await for (final chunk in response) {
        buffer.write(chunk);
        yield chunk;
      }

      // 添加模型回复
      final finalMessages = List<ChatMessage>.from(state.messages)
        ..add(ChatMessage(role: 'model', content: buffer.toString()));
      state = state.copyWith(
        messages: finalMessages,
        isLoading: false,
      );
    } catch (e) {
      final errorMessage = _formatError(e);
      state = state.copyWith(
        isLoading: false, lastError: errorMessage);
      yield* Stream.error(errorMessage);
    }
  }

  Future<Stream<String>> _sendRequest(ModelConfig config, List<ChatMessage> messages) async* {
    switch (config.provider) {
      case ModelProvider.gemini:
        yield* _sendGeminiRequest(config, messages);
        break;
      case ModelProvider.deepseek:
        yield* _sendDeepSeekRequest(config, messages);
        break;
      case ModelProvider.openAI:
        yield* _sendOpenAIRequest(config, messages);
        break;
      case ModelProvider.custom:
        yield* _sendCustomRequest(config, messages);
        break;
    }
  }

  Stream<String> _sendGeminiRequest(ModelConfig config, List<ChatMessage> messages) async* {
    try {
      final url =
          '${config.baseUrl}/v1beta/models/${config.modelName}:streamGenerateContent';

      final response = await _dio.post(
        url,
        queryParameters: {'key': config.apiKey},
        data: {
          'contents': messages.map((m) => {
            'role': m.role == 'user' ? 'user' : 'model',
            'parts': [
              {'text': m.content}
            ]
          }).toList(),
          'generationConfig': {
            'temperature': 0.7,
            'topP': 0.95,
            'topK': 40,
            'maxOutputTokens': 8192,
          }
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {
          'Content-Type': 'application/json',
          'Accept': 'text/event-stream',
          'Cache-Control': 'no-cache',
        },
      );

      // 解析流式响应
      final stream = response.data as Stream;
      String currentResponse = '';

      await for (var chunk in response.data) {
        // 处理每一块数据
        if (chunk is String) {
          currentResponse += chunk;

          // 检查是否是一个完整的 JSON 对象
          final text = _extractTextFromGeminiResponse(currentResponse);
          if (text != null && text.isNotEmpty) {
            yield text;
          }
        }
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Stream<String> _sendDeepSeekRequest(ModelConfig config, List<ChatMessage> messages) async* {
    try {
      final response = await _dio.post(
        '${config.baseUrl}/v1/chat/completions',
        data: {
          'model': config.modelName,
          'messages': messages.map((m) => {
            'role': m.role == 'user' ? 'user' : 'assistant',
            'content': m.content,
          }).toList(),
          'stream': true,
          'temperature': 0.7,
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${config.apiKey}',
          },
        ),
      );

      await for (var chunk in response.data) {
        if (chunk is String) {
          final text = _extractTextFromOpenAIResponse(chunk);
          if (text != null && text.isNotEmpty) {
            yield text;
          }
        }
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Stream<String> _sendOpenAIRequest(ModelConfig config, List<ChatMessage> messages) async* {
    try {
      final response = await _dio.post(
        '${config.baseUrl}/v1/chat/completions',
        data: {
          'model': config.modelName,
          'messages': messages.map((m) => {
            'role': m.role == 'user' ? 'user' : 'assistant',
            'content': m.content,
          }).toList(),
          'stream': true,
          'temperature': 0.7,
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${config.apiKey}',
          },
        ),
      );

      await for (var chunk in response.data) {
        if (chunk is String) {
          final text = _extractTextFromOpenAIResponse(chunk);
          if (text != null && text.isNotEmpty) {
            yield text;
          }
        }
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Stream<String> _sendCustomRequest(ModelConfig config, List<ChatMessage> messages) async* {
    yield* _sendOpenAIRequest(config, messages);
  }

  String? _extractTextFromGeminiResponse(String response) {
    try {
      final json = jsonDecode(response);
      if (json is List && json.isNotEmpty) {
        final candidate = json[0]['candidates'];
        if (candidate is List && candidate.isNotEmpty) {
          final parts = candidate[0]['content']?['parts'];
          if (parts is List && parts.isNotEmpty) {
            final text = parts[0]['text'];
            return text as String?;
          }
        }
      }
    } catch (e) {
      // 可能是不完整的 JSON，等待下一块
      return null;
    }
    return null;
  }

  String? _extractTextFromOpenAIResponse(String response) {
    try {
      final lines = response.split('\n');
      for (final line in lines) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data.trim() == '[DONE]') continue;
          
          final json = jsonDecode(data);
          final choices = json['choices'];
          if (choices is List && choices.isNotEmpty) {
            final delta = choices[0]['delta'];
            final content = delta?['content'];
            if (content != null) {
              return content as String;
            }
          }
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络设置或使用代理';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 401:
            return 'API Key 无效，请检查您的 API Key';
          case 403:
            return '访问被拒绝，请检查 API Key 权限';
          case 429:
            return '请求次数过多，请稍后再试';
          case 500:
          case 502:
          case 503:
            return '服务暂时不可用，请稍后再试';
          default:
            return '请求失败 (错误代码: $statusCode)';
        }
      case DioExceptionType.badCertificate:
        return 'SSL 证书验证失败';
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return '无法连接到服务器，请检查网络';
        }
        return '请求失败: ${error.message}';
      default:
        return '请求失败: ${error.message}';
    }
  }

  String _formatError(dynamic error) {
    if (error is String) return error;
    if (error is DioException) {
      return _handleDioError(error);
    }
    return error.toString();
  }

  Future<bool> testConnection() async {
    if (state.config == null || state.config!.apiKey.isEmpty) {
      throw Exception('请先配置 API Key');
    }

    final config = state.config!;

    try {
      // 发送一个简单的测试请求
      final testMessages = [
        ChatMessage(role: 'user', content: 'Hi')
      ];
      final stream = _sendRequest(config, testMessages);
      await stream.first;
      return true;
    } catch (e) {
      rethrow;
    }
  }

  void clearHistory() {
    state = state.copyWith(messages: []);
  }

  void clearError() {
    state = state.copyWith(lastError: null);
  }
}

final geminiServiceProvider =
    StateNotifierProvider<GeminiService, GeminiState>((ref) {
  return GeminiService();
});
