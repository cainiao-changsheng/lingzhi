import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_agent_mobile_app/services/image_generation_service.dart';
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
  void dispose() {
    _promptController.dispose();
    _stepsController.dispose();
    _guidanceController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _generateImage() async {
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
          SnackBar(
            content: const Text('图片生成成功'),
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(imageGenerationServiceProvider);
    final lastGenerated = state.lastGenerated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('图片生成'),
        actions: [
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
            // 生成表单
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '图片生成',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    onPressed: state.isGenerating ? null : _generateImage,
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
