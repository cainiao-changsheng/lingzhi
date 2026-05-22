import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_agent_mobile_app/services/gemini_service.dart';
import 'package:ai_agent_mobile_app/theme/theme.dart';
import 'package:ai_agent_mobile_app/widgets/custom_card.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _modelNameController = TextEditingController();

  ModelProvider _selectedProvider = ModelProvider.gemini;
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final service = ref.read(geminiServiceProvider.notifier);
    final config = service.getConfig();

    if (config != null) {
      setState(() {
        _selectedProvider = config.provider;
        _apiKeyController.text = config.apiKey;
        _baseUrlController.text = config.baseUrl;
        _modelNameController.text = config.modelName;
      });
    } else {
      // 使用默认配置
      final defaultConfig = GeminiService.getDefaultConfig();
      setState(() {
        _selectedProvider = defaultConfig.provider;
        _apiKeyController.text = defaultConfig.apiKey;
        _baseUrlController.text = defaultConfig.baseUrl;
        _modelNameController.text = defaultConfig.modelName;
      });
    }
  }

  Future<void> _saveSettings() async {
    final service = ref.read(geminiServiceProvider.notifier);
    await service.saveConfig(ModelConfig(
      provider: _selectedProvider,
      apiKey: _apiKeyController.text,
      baseUrl: _baseUrlController.text,
      modelName: _modelNameController.text,
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('设置已保存'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _testApiConnection() async {
    if (_apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先填写 API Key'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // 先保存当前配置
    await _saveSettings();

    final service = ref.read(geminiServiceProvider.notifier);
    try {
      await service.testConnection();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API 连接测试成功'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('连接失败: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showResetConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置设置'),
        content: const Text('确定要重置为默认设置吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final defaultConfig = GeminiService.getDefaultConfig();
      setState(() {
        _selectedProvider = defaultConfig.provider;
        _apiKeyController.text = defaultConfig.apiKey;
        _baseUrlController.text = defaultConfig.baseUrl;
        _modelNameController.text = defaultConfig.modelName;
      });
    }
  }

  void _setDefaultConfig(String type) {
    setState(() {
      switch (type) {
        case 'gemini':
          _selectedProvider = ModelProvider.gemini;
          _baseUrlController.text = GeminiDefaults.baseUrl;
          _modelNameController.text = GeminiDefaults.defaultModel;
          break;
        case 'deepseek':
          _selectedProvider = ModelProvider.deepseek;
          _baseUrlController.text = 'https://api.deepseek.com';
          _modelNameController.text = 'deepseek-chat';
          break;
        case 'openai':
          _selectedProvider = ModelProvider.openAI;
          _baseUrlController.text = 'https://api.openai.com';
          _modelNameController.text = 'gpt-3.5-turbo';
          break;
      }
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final geminiState = ref.watch(geminiServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '大模型配置',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 模型提供商选择
                  const Text('模型提供商', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildProviderButton(
                            ModelProvider.gemini, 'Gemini'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildProviderButton(
                            ModelProvider.deepseek, 'DeepSeek'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildProviderButton(
                            ModelProvider.openAI, 'OpenAI'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child:
                            _buildProviderButton(ModelProvider.custom, '自定义'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // API Key
                  TextFormField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'API Key',
                      hintText: '输入您的 API Key',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.key),
                    ),
                    obscureText: true,
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

                    // Base URL
                    TextFormField(
                      controller: _baseUrlController,
                      decoration: const InputDecoration(
                        labelText: 'API Base URL',
                        hintText: '输入 API 基础地址',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 模型名称
                    TextFormField(
                      controller: _modelNameController,
                      decoration: const InputDecoration(
                        labelText: '模型名称',
                        hintText: '输入模型名称',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.model_training),
                      ),
                    ),
                  ],

                  // 快速设置按钮
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: () => _setDefaultConfig('gemini'),
                        icon: const Icon(Icons.settings, size: 18),
                        label: const Text('Gemini 默认'),
                      ),
                      TextButton.icon(
                        onPressed: () => _setDefaultConfig('deepseek'),
                        icon: const Icon(Icons.settings, size: 18),
                        label: const Text('DeepSeek 默认'),
                      ),
                      TextButton.icon(
                        onPressed: () => _setDefaultConfig('openai'),
                        icon: const Icon(Icons.settings, size: 18),
                        label: const Text('OpenAI 默认'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

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
                          const Icon(Icons.error_outline,
                              color: AppColors.error),
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

                  // 网络提示
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.warning),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '如果无法连接，请检查网络设置或使用代理服务。',
                            style: TextStyle(color: AppColors.warning),
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
                            side: const BorderSide(color: AppColors.primary),
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

            // 其他设置
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '其他设置',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _showResetConfirmation,
                    icon: const Icon(Icons.restore),
                    label: const Text('重置为默认设置'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderButton(ModelProvider provider, String label) {
    final isSelected = _selectedProvider == provider;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedProvider = provider;
          // 更新默认值
          if (provider == ModelProvider.gemini) {
            _baseUrlController.text = GeminiDefaults.baseUrl;
            _modelNameController.text = GeminiDefaults.defaultModel;
          } else if (provider == ModelProvider.deepseek) {
            _baseUrlController.text = 'https://api.deepseek.com';
            _modelNameController.text = 'deepseek-chat';
          } else if (provider == ModelProvider.openAI) {
            _baseUrlController.text = 'https://api.openai.com';
            _modelNameController.text = 'gpt-3.5-turbo';
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? AppColors.primary : AppColors.cardBackground,
        foregroundColor: isSelected ? Colors.white : Colors.grey,
      ),
      child: Text(label),
    );
  }
}
