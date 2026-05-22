import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_agent_mobile_app/services/image_generation_service.dart';
import 'package:ai_agent_mobile_app/services/stable_diffusion_model_service.dart';
import 'package:ai_agent_mobile_app/theme/theme.dart';
import 'package:ai_agent_mobile_app/widgets/custom_card.dart';

class ImageGenerationPage extends ConsumerStatefulWidget {
  const ImageGenerationPage({super.key});

  @override
  ConsumerState<ImageGenerationPage> createState() =>
      _ImageGenerationPageState();
}

class _ImageGenerationPageState extends ConsumerState<ImageGenerationPage> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _stepsController =
      TextEditingController(text: '20');
  final TextEditingController _guidanceController =
      TextEditingController(text: '7.5');
  final TextEditingController _widthController =
      TextEditingController(text: '512');
  final TextEditingController _heightController =
      TextEditingController(text: '512');

  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _checkModelStatus();
  }

  Future<void> _loadHistory() async {
    await ref.read(imageGenerationServiceProvider.notifier).loadHistory();
  }

  Future<void> _checkModelStatus() async {
    await ref
        .read(stableDiffusionModelServiceProvider.notifier)
        .checkModelStatus();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _stepsController.dispose();
    _guidanceController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _generateImage() async {
    final modelState = ref.read(stableDiffusionModelServiceProvider);

    if (!modelState.isModelInstalled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先下载 Stable Diffusion 模型'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    final steps = int.tryParse(_stepsController.text) ?? 20;
    final guidanceScale = double.tryParse(_guidanceController.text) ?? 7.5;
    final width = int.tryParse(_widthController.text) ?? 512;
    final height = int.tryParse(_heightController.text) ?? 512;

    try {
      final service = ref.read(imageGenerationServiceProvider.notifier);
      final filePath = await service.generateImage(
        prompt: prompt,
        steps: steps,
        guidanceScale: guidanceScale,
        width: width,
        height: height,
      );

      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('图片生成成功'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('生成失败: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _clearHistory() {
    final service = ref.read(imageGenerationServiceProvider.notifier);
    service.clearHistory();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('历史记录已清空'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _downloadModel() async {
    final modelService = ref.read(stableDiffusionModelServiceProvider.notifier);
    await modelService.downloadModel();
  }

  Future<void> _deleteModel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除模型'),
        content: const Text('确定要删除 Stable Diffusion 模型吗？删除后需要重新下载才能生成图片。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final modelService =
          ref.read(stableDiffusionModelServiceProvider.notifier);
      await modelService.deleteModel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(imageGenerationServiceProvider);
    final modelState = ref.watch(stableDiffusionModelServiceProvider);
    final lastGenerated = state.lastGenerated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('图片生成'),
        actions: [
          IconButton(
            onPressed: _checkModelStatus,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新状态',
          ),
          if (state.history.isNotEmpty)
            IconButton(
              onPressed: _clearHistory,
              icon: const Icon(Icons.delete_sweep),
              tooltip: '清空历史',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 模型状态卡片
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        modelState.isModelInstalled
                            ? Icons.check_circle
                            : modelState.isDownloading
                                ? Icons.downloading
                                : Icons.warning,
                        color: modelState.isModelInstalled
                            ? AppColors.success
                            : modelState.isDownloading
                                ? AppColors.primary
                                : AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Stable Diffusion 模型',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (modelState.isDownloading) ...[
                    LinearProgressIndicator(
                      value: modelState.progress,
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '下载中... ${(modelState.progress * 100).toInt()}%',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          '${ref.read(stableDiffusionModelServiceProvider.notifier).formattedDownloadedBytes} / '
                          '${ref.read(stableDiffusionModelServiceProvider.notifier).formattedTotalBytes}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ] else if (modelState.isModelInstalled) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check, color: AppColors.success),
                            const SizedBox(width: 8),
                            const Text('模型已安装'),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: _deleteModel,
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('删除'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '版本: ${modelState.installedVersion ?? '1.5'}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ] else ...[
                    const Text(
                      '需要下载 Stable Diffusion 1.5 模型才能生成图片',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed:
                          modelState.isDownloading ? null : _downloadModel,
                      icon: const Icon(Icons.download),
                      label: const Text('下载模型'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '模型大小约 4GB，下载需要一定时间，请确保网络连接稳定。',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                  if (modelState.error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              modelState.error!,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 生成表单
            if (modelState.isModelInstalled)
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '图片生成',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '基于 Stable Diffusion 1.5 本地生成图片',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // 提示词输入
                    TextFormField(
                      controller: _promptController,
                      decoration: const InputDecoration(
                        labelText: '提示词',
                        hintText: '描述你想要生成的图片内容...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.edit),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                    const SizedBox(height: 12),

                    // 高级设置切换
                    Row(
                      children: [
                        const Text('高级设置'),
                        const Spacer(),
                        Switch(
                          value: _showAdvanced,
                          onChanged: (value) =>
                              setState(() => _showAdvanced = value),
                        ),
                      ],
                    ),

                    if (_showAdvanced) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stepsController,
                              decoration: const InputDecoration(
                                labelText: '步数',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _guidanceController,
                              decoration: const InputDecoration(
                                labelText: '引导系数',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _widthController,
                              decoration: const InputDecoration(
                                labelText: '宽度',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _heightController,
                              decoration: const InputDecoration(
                                labelText: '高度',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // 状态显示
                    if (state.isGenerating)
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: state.progress,
                            backgroundColor: AppColors.border,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '生成中... ${(state.progress * 100).toInt()}%',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),

                    if (state.lastError != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.lastError!,
                                style: const TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // 生成按钮
                    ElevatedButton.icon(
                      onPressed:
                          (state.isGenerating || modelState.isDownloading)
                              ? null
                              : _generateImage,
                      icon: const Icon(Icons.generating_tokens),
                      label: const Text('生成图片'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // 最近生成
            if (lastGenerated != null) ...[
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '最近生成',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildGeneratedImageCard(lastGenerated),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 历史记录
            if (state.history.isNotEmpty)
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '历史记录',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '共 ${state.history.length} 张',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...state.history.take(5).map(_buildHistoryItem).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedImageCard(GeneratedImage image) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片预览
          FutureBuilder<File?>(
            future: File(image.filePath)
                .exists()
                .then((exists) => exists ? File(image.filePath) : null),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.file(
                    snapshot.data!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                );
              }
              return Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 64, color: Colors.grey),
                ),
              );
            },
          ),

          // 信息
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  image.prompt,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoChip('${image.width}×${image.height}'),
                    const SizedBox(width: 8),
                    _buildInfoChip('${image.steps}步'),
                    const SizedBox(width: 8),
                    _buildInfoChip('${image.guidanceScale}引导'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '生成于 ${_formatTime(image.timestamp)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(GeneratedImage image) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // 缩略图
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: FutureBuilder<File?>(
              future: File(image.filePath)
                  .exists()
                  .then((exists) => exists ? File(image.filePath) : null),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      snapshot.data!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                return const Center(
                  child: Icon(Icons.image, size: 24, color: Colors.grey),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  image.prompt,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${image.width}×${image.height}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(image.timestamp),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 操作按钮
          IconButton(
            onPressed: () {
              // 查看大图
            },
            icon: const Icon(Icons.zoom_in, size: 20),
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.primary, fontSize: 12),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}
