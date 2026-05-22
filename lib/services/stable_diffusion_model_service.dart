import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StableDiffusionModelService extends StateNotifier<ModelState> {
  final Dio _dio;

  // Stable Diffusion 1.5 FP16 ONNX 模型下载链接（HuggingFace mirror）
  static const String _modelUrl =
      'https://huggingface.co/stabilityai/stable-diffusion-onnx/resolve/main/v1-5-pruned-emaonly.onnx';
  static const String _modelName = 'stable-diffusion-1.5-fp16.onnx';
  static const String _modelVersion = 'v1.5';

  StableDiffusionModelService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(minutes: 30),
        )),
        super(ModelState());

  Future<void> checkModelStatus() async {
    state = state.copyWith(status: ModelStatus.checking);

    try {
      final modelDir = await _getModelDirectory();
      final modelFile = File(p.join(modelDir.path, _modelName));
      final versionFile = File(p.join(modelDir.path, 'version.txt'));

      final exists = modelFile.existsSync();
      final versionExists = versionFile.existsSync();
      String? installedVersion;

      if (versionExists) {
        installedVersion = await versionFile.readAsString();
      }

      state = state.copyWith(
        status: ModelStatus.ready,
        isModelInstalled: exists,
        installedVersion: installedVersion,
        modelPath: exists ? modelFile.path : null,
      );

      // 如果模型不存在，提示用户可以下载
      if (!exists) {
        state = state.copyWith(
          status: ModelStatus.notInstalled,
          message: 'Stable Diffusion 1.5 模型未安装',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: ModelStatus.error,
        error: '检查模型状态失败: $e',
      );
    }
  }

  Future<void> downloadModel() async {
    if (state.isDownloading) return;

    state = state.copyWith(
      status: ModelStatus.downloading,
      progress: 0.0,
      error: null,
    );

    try {
      final modelDir = await _getModelDirectory();

      // 确保目录存在
      if (!modelDir.existsSync()) {
        modelDir.createSync(recursive: true);
      }

      final modelFile = File(p.join(modelDir.path, _modelName));

      // 下载模型
      await _dio.download(
        _modelUrl,
        modelFile.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            state = state.copyWith(
              progress: progress,
              downloadedBytes: received,
              totalBytes: total,
            );
          }
        },
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0',
          },
        ),
      );

      // 保存版本信息
      final versionFile = File(p.join(modelDir.path, 'version.txt'));
      await versionFile.writeAsString(_modelVersion);

      state = state.copyWith(
        status: ModelStatus.ready,
        isModelInstalled: true,
        installedVersion: _modelVersion,
        modelPath: modelFile.path,
        progress: 1.0,
        message: '模型下载完成',
      );

      // 保存模型安装状态
      await _saveModelInstalled(true);
    } on DioException catch (e) {
      String errorMessage = '下载失败';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = '连接超时，请检查网络';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = '下载超时，请稍后重试';
      } else if (e.error is SocketException) {
        errorMessage = '网络连接失败，请检查网络设置';
      }

      state = state.copyWith(
        status: ModelStatus.error,
        error: errorMessage,
        progress: 0.0,
      );
    } catch (e) {
      state = state.copyWith(
        status: ModelStatus.error,
        error: '下载失败: $e',
        progress: 0.0,
      );
    }
  }

  Future<void> deleteModel() async {
    state = state.copyWith(status: ModelStatus.deleting);

    try {
      final modelDir = await _getModelDirectory();
      final modelFile = File(p.join(modelDir.path, _modelName));
      final versionFile = File(p.join(modelDir.path, 'version.txt'));

      if (modelFile.existsSync()) {
        await modelFile.delete();
      }

      if (versionFile.existsSync()) {
        await versionFile.delete();
      }

      // 清除安装状态
      await _saveModelInstalled(false);

      state = state.copyWith(
        status: ModelStatus.notInstalled,
        isModelInstalled: false,
        installedVersion: null,
        modelPath: null,
        message: '模型已删除',
      );
    } catch (e) {
      state = state.copyWith(
        status: ModelStatus.error,
        error: '删除模型失败: $e',
      );
    }
  }

  Future<Directory> _getModelDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(p.join(appDir.path, 'models', 'stable-diffusion'));
  }

  Future<void> _saveModelInstalled(bool installed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sd_model_installed', installed);
    if (installed) {
      await prefs.setString('sd_model_version', _modelVersion);
      await prefs.setString('sd_model_path',
          p.join((await _getModelDirectory()).path, _modelName));
    } else {
      await prefs.remove('sd_model_version');
      await prefs.remove('sd_model_path');
    }
  }

  String get formattedDownloadedBytes {
    if (state.downloadedBytes == null) return '0 B';
    return _formatBytes(state.downloadedBytes!);
  }

  String get formattedTotalBytes {
    if (state.totalBytes == null) return '0 B';
    return _formatBytes(state.totalBytes!);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

enum ModelStatus {
  idle,
  checking,
  ready,
  notInstalled,
  downloading,
  deleting,
  error,
}

class ModelState {
  final ModelStatus status;
  final bool isModelInstalled;
  final bool isDownloading;
  final double progress;
  final String? installedVersion;
  final String? modelPath;
  final String? error;
  final String? message;
  final int? downloadedBytes;
  final int? totalBytes;

  const ModelState({
    this.status = ModelStatus.idle,
    this.isModelInstalled = false,
    this.isDownloading = false,
    this.progress = 0.0,
    this.installedVersion,
    this.modelPath,
    this.error,
    this.message,
    this.downloadedBytes,
    this.totalBytes,
  });

  ModelState copyWith({
    ModelStatus? status,
    bool? isModelInstalled,
    bool? isDownloading,
    double? progress,
    String? installedVersion,
    String? modelPath,
    String? error,
    String? message,
    int? downloadedBytes,
    int? totalBytes,
  }) {
    return ModelState(
      status: status ?? this.status,
      isModelInstalled: isModelInstalled ?? this.isModelInstalled,
      isDownloading: isDownloading ?? this.isDownloading,
      progress: progress ?? this.progress,
      installedVersion: installedVersion ?? this.installedVersion,
      modelPath: modelPath ?? this.modelPath,
      error: error,
      message: message,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }

  bool get canDownload =>
      status != ModelStatus.downloading && status != ModelStatus.checking;

  bool get canDelete => isModelInstalled && status != ModelStatus.deleting;
}

final stableDiffusionModelServiceProvider =
    StateNotifierProvider.autoDispose<StableDiffusionModelService, ModelState>(
        (ref) {
  return StableDiffusionModelService();
});
