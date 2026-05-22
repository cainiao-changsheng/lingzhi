import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class ImageGenerationService extends StateNotifier<ImageGenerationState> {
  ImageGenerationService() : super(ImageGenerationState());

  // 设备性能检测
  Future<DevicePerformance> _detectDevicePerformance() async {
    // 模拟设备检测逻辑
    // 实际实现应使用 device_info_plus 获取设备信息
    return DevicePerformance.high; // 假设为高端设备
  }

  // 生成图片
  Future<String?> generateImage({
    required String prompt,
    int steps = 20,
    double guidanceScale = 7.5,
    int width = 512,
    int height = 512,
  }) async {
    if (state.isGenerating) return null;

    setState(() {
      state = state.copyWith(
        isGenerating: true,
        lastError: null,
        progress: 0.0,
      );
    });

    try {
      final performance = await _detectDevicePerformance();
      if (performance == DevicePerformance.low) {
        throw Exception('设备性能不足，无法本地生成图片');
      }

      // 模拟生成过程
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() {
          state = state.copyWith(progress: i / 100.0);
        });
      }

      // 创建模拟图片
      final image = _createPlaceholderImage(width, height, prompt);
      final outputPath = await _saveImageToFile(image, prompt);

      setState(() {
        state = state.copyWith(
          isGenerating: false,
          progress: 1.0,
          lastGenerated: GeneratedImage(
            prompt: prompt,
            filePath: outputPath,
            timestamp: DateTime.now(),
            width: width,
            height: height,
            steps: steps,
            guidanceScale: guidanceScale,
          ),
        );
      });

      return outputPath;
    } catch (e) {
      setState(() {
        state = state.copyWith(
          isGenerating: false,
          lastError: e.toString(),
        );
      });
      rethrow;
    }
  }

  // 创建占位图片（实际应调用 ONNX Runtime）
  img.Image _createPlaceholderImage(int width, int height, String prompt) {
    final image = img.Image(width: width, height: height);
    final bgColor = img.ColorRgb8(30, 30, 46); // 深色背景
    final textColor = img.ColorRgb8(108, 99, 255); // 主色

    // 填充背景
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        image.setPixel(x, y, bgColor);
      }
    }

    // 添加提示文字（简化版）
    final words = prompt.split(' ');
    final maxWords = 5;
    for (int i = 0; i < words.length && i < maxWords; i++) {
      final x = 50;
      final y = 100 + i * 40;
      _drawText(image, words[i], x, y, textColor);
    }

    return image;
  }

  void _drawText(img.Image image, String text, int x, int y, img.Color color) {
    // 简化文本绘制
    final textWidth = text.length * 20;
    final textHeight = 30;

    // 绘制文本背景
    for (int dy = 0; dy < textHeight; dy++) {
      for (int dx = 0; dx < textWidth; dx++) {
        if (x + dx < image.width && y + dy < image.height) {
          final pixel = image.getPixel(x + dx, y + dy);
          final r = (pixel.r * 0.7 + color.r * 0.3).toInt();
          final g = (pixel.g * 0.7 + color.g * 0.3).toInt();
          final b = (pixel.b * 0.7 + color.b * 0.3).toInt();
          image.setPixel(x + dx, y + dy, img.ColorRgb8(r, g, b));
        }
      }
    }
  }

  // 保存图片到文件
  Future<String> _saveImageToFile(img.Image image, String prompt) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(directory.path, 'generated_images'));
    if (!imagesDir.existsSync()) {
      imagesDir.createSync(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safePrompt =
        prompt.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
    final fileName = 'generated_${safePrompt}_$timestamp.png';
    final filePath = p.join(imagesDir.path, fileName);

    final pngBytes = img.encodePng(image);
    final file = File(filePath);
    await file.writeAsBytes(pngBytes);

    return filePath;
  }

  // 获取历史记录
  List<GeneratedImage> getHistory() {
    return state.history;
  }

  // 清除历史记录
  void clearHistory() {
    setState(() {
      state = state.copyWith(history: []);
    });
  }

  // 添加图片到历史记录
  void addToHistory(GeneratedImage image) {
    final newHistory = [image, ...state.history];
    if (newHistory.length > 50) {
      newHistory.removeLast();
    }
    setState(() {
      state = state.copyWith(history: newHistory);
    });
  }

  // 设置状态辅助方法
  void setState(void Function() fn) {
    fn();
  }

  // 加载历史记录
  Future<void> loadHistory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(directory.path, 'generated_images'));

      if (imagesDir.existsSync()) {
        final files = imagesDir
            .listSync()
            .where((file) => file.path.endsWith('.png'))
            .toList();
        final history = <GeneratedImage>[];

        for (final file in files) {
          final filePath = file.path;
          final fileName = p.basename(filePath);
          final match = RegExp(r'generated_(.*)_\d+\.png').firstMatch(fileName);
          final prompt = match != null
              ? match.group(1)?.replaceAll('_', ' ') ?? '未知'
              : '未知';

          final fileStat = File(filePath).statSync();
          history.add(GeneratedImage(
            prompt: prompt,
            filePath: filePath,
            timestamp: DateTime.fromMillisecondsSinceEpoch(
                fileStat.modified.millisecondsSinceEpoch),
            width: 512,
            height: 512,
            steps: 20,
            guidanceScale: 7.5,
          ));
        }

        history.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        state = state.copyWith(history: history);
      }
    } catch (e) {
      debugPrint('Failed to load image history: $e');
    }
  }
}

class ImageGenerationState {
  final bool isGenerating;
  final double progress;
  final String? lastError;
  final GeneratedImage? lastGenerated;
  final List<GeneratedImage> history;

  ImageGenerationState({
    this.isGenerating = false,
    this.progress = 0.0,
    this.lastError,
    this.lastGenerated,
    this.history = const [],
  });

  ImageGenerationState copyWith({
    bool? isGenerating,
    double? progress,
    String? lastError,
    GeneratedImage? lastGenerated,
    List<GeneratedImage>? history,
  }) {
    return ImageGenerationState(
      isGenerating: isGenerating ?? this.isGenerating,
      progress: progress ?? this.progress,
      lastError: lastError ?? this.lastError,
      lastGenerated: lastGenerated ?? this.lastGenerated,
      history: history ?? this.history,
    );
  }
}

class GeneratedImage {
  final String prompt;
  final String filePath;
  final DateTime timestamp;
  final int width;
  final int height;
  final int steps;
  final double guidanceScale;

  GeneratedImage({
    required this.prompt,
    required this.filePath,
    required this.timestamp,
    this.width = 512,
    this.height = 512,
    this.steps = 20,
    this.guidanceScale = 7.5,
  });

  Map<String, dynamic> toJson() => {
        'prompt': prompt,
        'filePath': filePath,
        'timestamp': timestamp.toIso8601String(),
        'width': width,
        'height': height,
        'steps': steps,
        'guidanceScale': guidanceScale,
      };

  factory GeneratedImage.fromJson(Map<String, dynamic> json) => GeneratedImage(
        prompt: json['prompt'],
        filePath: json['filePath'],
        timestamp: DateTime.parse(json['timestamp']),
        width: json['width'] ?? 512,
        height: json['height'] ?? 512,
        steps: json['steps'] ?? 20,
        guidanceScale: json['guidanceScale']?.toDouble() ?? 7.5,
      );
}

enum DevicePerformance {
  low, // 无法运行 SD 1.5
  medium, // 可运行但速度慢
  high, // 可流畅运行
}

final imageGenerationServiceProvider = StateNotifierProvider.autoDispose<
    ImageGenerationService, ImageGenerationState>((ref) {
  return ImageGenerationService();
});
