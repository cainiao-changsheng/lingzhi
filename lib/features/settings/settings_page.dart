import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_agent_mobile_app/services/gemini_service.dart';
import 'package:ai_agent_mobile_app/services/music_service.dart';
import 'package:ai_agent_mobile_app/services/image_generation_service.dart';
import 'package:ai_agent_mobile_app/services/chat_persistence_service.dart';
import 'package:ai_agent_mobile_app/theme/theme.dart';
import 'package:ai_agent_mobile_app/widgets/custom_card.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _modelNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelNameController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final service = ref.read(geminiServiceProvider.notifier);
    final config = await service.getConfig();

    setState(() {
      _apiKeyController.text = config.apiKey;
      _modelNameController.text = config.modelName;
    });
  }

  Future<void> _saveSettings() async {
    final service = ref.read(geminiServiceProvider.notifier);
    await service.updateConfig(
      apiKey: _apiKeyController.text,
      modelName: _modelNameController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('设置已保存'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _testApiConnection() async {
    final service = ref.read(geminiServiceProvider.notifier);
    try {
      await service.testConnection();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API 连接测试成功'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('连接失败: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _clearChatHistory() async {
    final persistence = ref.read(chatPersistenceServiceProvider.notifier);
    await persistence.clearHistory();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('聊天历史已清空'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _clearGeneratedImages() async {
    final service = ref.read(imageGenerationServiceProvider.notifier);
    service.clearHistory();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('生成图片历史已清空'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _clearMusicCache() async {
    final service = ref.read(musicServiceProvider.notifier);
    await service.clearCache();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('音乐缓存已清空'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _exportChatHistory() async {
    final persistence = ref.read(chatPersistenceServiceProvider.notifier);
    try {
      final exportData = await persistence.exportChatHistory();
      // TODO: 实现文件保存逻辑
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('聊天记录导出成功'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('导出失败: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final geminiState = ref.watch(geminiServiceProvider);
    final persistenceState = ref.watch(chatPersistenceServiceProvider);
    final imageGenState = ref.watch(imageGenerationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Gemini API 设置
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gemini API 设置',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // API Key
                  TextFormField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'API Key',
                      hintText: '输入您的 Gemini API Key',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.key),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),

                  // 模型名称
                  TextFormField(
                    controller: _modelNameController,
                    decoration: const InputDecoration(
                      labelText: '模型名称',
                      hintText: '例如: gemini-1.5-flash',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.model_training),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 状态信息
                  if (geminiState.lastError != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              geminiState.lastError!,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // 按钮组
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _testApiConnection,
                          icon: const Icon(Icons.wifi_tethering),
                          label: const Text('测试连接'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveSettings,
                          icon: const Icon(Icons.save),
                          label: const Text('保存设置'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 数据管理
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '数据管理',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 聊天历史统计
                  _buildStatItem(
                    icon: Icons.chat,
                    title: '聊天历史',
                    value: '${persistenceState.saveCount} 条',
                    color: AppColors.primary,
                    onClear: _clearChatHistory,
                  ),

                  // 生成图片统计
                  _buildStatItem(
                    icon: Icons.image,
                    title: '生成图片',
                    value: '${imageGenState.history.length} 张',
                    color: AppColors.secondary,
                    onClear: _clearGeneratedImages,
                  ),

                  // 音乐缓存统计
                  _buildStatItem(
                    icon: Icons.music_note,
                    title: '音乐缓存',
                    value: '待统计',
                    color: AppColors.accent,
                    onClear: _clearMusicCache,
                  ),

                  const SizedBox(height: 16),

                  // 导出按钮
                  ElevatedButton.icon(
                    onPressed: _exportChatHistory,
                    icon: const Icon(Icons.download),
                    label: const Text('导出聊天记录'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 应用信息
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '应用信息',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoItem('应用名称', 'AI Agent Mobile'),
                  _buildInfoItem('版本', '1.0.0'),
                  _buildInfoItem('构建日期', '2026-05-22'),
                  _buildInfoItem('开发者', 'AI Agent Team'),
                  _buildInfoItem('技术支持', 'support@aiagent.com'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 危险操作
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '危险操作',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.error),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '这些操作将永久删除数据且无法恢复',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: () {
                      _showResetConfirmation();
                    },
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('重置所有数据'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onClear,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onClear,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(
              '清空',
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认重置'),
        content: const Text('这将删除所有聊天历史、生成图片和音乐缓存。此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performReset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('确认重置'),
          ),
        ],
      ),
    );
  }

  Future<void> _performReset() async {
    try {
      final persistence = ref.read(chatPersistenceServiceProvider.notifier);
      final imageGen = ref.read(imageGenerationServiceProvider.notifier);
      final music = ref.read(musicServiceProvider.notifier);

      await persistence.clearHistory();
      imageGen.clearHistory();
      await music.clearCache();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('所有数据已重置'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('重置失败: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}