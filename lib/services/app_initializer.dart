import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_agent_mobile_app/services/gemini_service.dart';
import 'package:ai_agent_mobile_app/services/stable_diffusion_model_service.dart';
import 'package:ai_agent_mobile_app/services/image_generation_service.dart';

class AppInitializer {
  final WidgetRef ref;

  AppInitializer(this.ref);

  Future<InitializationResult> initialize() async {
    final errors = <String>[];
    var warnings = <String>[];

    // 1. 检查 Gemini API 配置
    try {
      final geminiState = ref.read(geminiServiceProvider);
      if (!geminiState.isInitialized) {
        warnings.add('Gemini API 未配置，请先在设置中配置 API Key');
      }
    } catch (e) {
      errors.add('Gemini 服务初始化失败: $e');
    }

    // 2. 检查 Stable Diffusion 模型
    try {
      final modelService =
          ref.read(stableDiffusionModelServiceProvider.notifier);
      await modelService.checkModelStatus();
      final modelState = ref.read(stableDiffusionModelServiceProvider);

      if (!modelState.isModelInstalled) {
        warnings.add('图片生成模型未安装，首次生成图片时将自动下载');
      }
    } catch (e) {
      errors.add('模型服务初始化失败: $e');
    }

    // 3. 初始化图片生成服务
    try {
      final imageService = ref.read(imageGenerationServiceProvider.notifier);
      await imageService.loadHistory();
    } catch (e) {
      errors.add('图片生成服务初始化失败: $e');
    }

    // 4. 音乐服务延迟初始化（打开页面时连接 MediaSession）
    // MusicController 在 MusicPage 首次打开时自动连接

    return InitializationResult(
      success: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}

class InitializationResult {
  final bool success;
  final List<String> errors;
  final List<String> warnings;

  InitializationResult({
    required this.success,
    required this.errors,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
}

// 初始化检查页面
class InitializationPage extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const InitializationPage({
    super.key,
    required this.onComplete,
  });

  @override
  ConsumerState<InitializationPage> createState() => _InitializationPageState();
}

class _InitializationPageState extends ConsumerState<InitializationPage> {
  bool _isInitializing = true;
  String _statusMessage = '正在初始化...';
  List<String> _warnings = [];
  List<String> _errors = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      setState(() {
        _statusMessage = '检查 Gemini API 配置...';
      });

      // 模拟初始化过程
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _statusMessage = '检查图片生成模型...';
      });
      await Future.delayed(const Duration(milliseconds: 500));

      final modelService =
          ref.read(stableDiffusionModelServiceProvider.notifier);
      await modelService.checkModelStatus();
      final modelState = ref.read(stableDiffusionModelServiceProvider);

      if (!modelState.isModelInstalled) {
        _warnings.add('图片生成模型未安装');
      }

      setState(() {
        _statusMessage = '加载历史记录...';
      });
      await Future.delayed(const Duration(milliseconds: 300));

      final imageService = ref.read(imageGenerationServiceProvider.notifier);
      await imageService.loadHistory();

      setState(() {
        _isInitializing = false;
        _statusMessage = '初始化完成';
      });

      // 延迟一下让用户看到完成状态
      await Future.delayed(const Duration(milliseconds: 500));
      widget.onComplete();
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _errors.add('初始化失败: $e');
        _statusMessage = '初始化失败';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isInitializing) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    _statusMessage,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ] else if (_errors.isNotEmpty) ...[
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    '初始化失败',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._errors.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(e, textAlign: TextAlign.center),
                      )),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isInitializing = true;
                        _errors.clear();
                      });
                      _initialize();
                    },
                    child: const Text('重试'),
                  ),
                ] else ...[
                  const Icon(Icons.check_circle, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  const Text(
                    '初始化完成',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (_warnings.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ..._warnings.map((w) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.warning_amber,
                                  size: 16, color: Colors.orange),
                              const SizedBox(width: 8),
                              Flexible(
                                  child: Text(w, textAlign: TextAlign.center)),
                            ],
                          ),
                        )),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
