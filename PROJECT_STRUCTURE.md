# AI Agent 移动端应用 - 项目结构

## 项目概述
基于 Gemini 3.5 Flash 的 Android 移动端 AI Agent 应用，集聊天、音乐播放、图片生成、定时任务于一体。

## 技术栈
- **Flutter 3.19.6** (稳定版)
- **Riverpod 2.6.1** (状态管理)
- **Drift 2.19.1+1** (SQLite ORM)
- **Google Generative AI 0.4.7** (Gemini API)
- **ONNX Runtime Mobile** (图片生成本地模型)

## 项目结构

```
E:\ai-agent-mobile-app\
├── android/                    # Android 原生代码
├── ios/                       # iOS 原生代码
├── lib/                       # Flutter 主代码
│   ├── main.dart              # 应用入口
│   ├── theme/                 # 主题配置
│   │   └── app_theme.dart     # 星空月亮主题
│   ├── widgets/               # 通用组件
│   │   └── bottom_navigation_bar.dart  # 底部导航栏
│   ├── features/              # 功能模块
│   │   ├── chat/              # 聊天功能
│   │   │   ├── chat_page.dart
│   │   │   └── widgets/       # 聊天相关组件
│   │   ├── music/             # 音乐功能
│   │   ├── podcast/           # 播客功能
│   │   └── tasks/             # 定时任务
│   ├── services/              # 服务层
│   │   ├── gemini_service.dart
│   │   ├── music_service.dart
│   │   ├── image_generation_service.dart
│   │   └── task_service.dart
│   ├── models/                # 数据模型
│   │   ├── conversation.dart
│   │   ├── message.dart
│   │   ├── song.dart
│   │   └── task.dart
│   └── database/              # 数据库
│       ├── app_database.dart
│       └── migrations/
├── test/                      # 测试文件
├── pubspec.yaml              # 依赖配置
└── PROJECT_STRUCTURE.md      # 本文件
```

## 已实现功能

### 1. 项目基础架构 ✅
- Flutter 3.19.6 项目创建
- 依赖配置完成 (pubspec.yaml)
- 星空月亮主题系统 (app_theme.dart)
- 底部导航栏组件 (bottom_navigation_bar.dart)

### 2. 主题系统 ✅
- **主色调**：紫色蓝 (#6366F1)
- **辅助色**：暖金色 (#F59E0B)
- **背景色**：星空深色 (#0F172A)
- **卡片边框**：
  - 音乐卡片：暖金边框
  - 任务卡片：紫色边框
  - 确认卡片：绿色边框
  - 图片展示卡片：蓝色边框
  - 图片生成卡片：橙色边框
  - 图片识别卡片：青色边框

### 3. 底部导航栏 ✅
- **静止态**：4个圆点指示器
- **滑动态**：SVG图标圆圈
- **交互**：滑动切换 + 点击切换
- **动画**：500ms渐隐过渡
- **图标**：聊天/音乐/播客/任务

### 4. 聊天页面 ✅
- 用户/Agent消息气泡
- 打字机效果（模拟）
- 消息时间戳
- 输入框 + 发送按钮
- 滚动自动定位

## 待实现功能

### P0 优先级
1. **Gemini API 集成** (2天)
   - Google AI Studio 密钥管理
   - 流式响应处理
   - 错误处理机制

2. **音乐播放基础** (2天)
   - 本地音频文件扫描
   - just_audio 播放控制
   - 后台播放服务

3. **图片生成基础** (2.5天)
   - ONNX Runtime Mobile 集成
   - Stable Diffusion 模型管理
   - 设备性能检测

### P1 优先级
1. **聊天中控制音乐** (1.5天)
   - Agent 意图解析
   - 音乐服务调用
   - 播放状态同步

2. **版本更新机制** (1天)
   - GitHub Releases API
   - APK下载与安装
   - CI/CD 配置

3. **播客占位UI** (0.5天)
   - 空白列表展示
   - 界面框架搭建

### P2 优先级
1. **图片生成优化** (1.5天)
   - 设备适配策略
   - Redmi K90专项优化
   - 生成进度显示

2. **定时任务系统** (2天)
   - WorkManager 集成
   - 任务CRUD操作
   - 通知提醒

3. **记忆系统** (2.5天)
   - SQLite 持久化
   - 向量检索 (all-MiniLM-L6-v2)
   - 记忆压缩策略

## 技术实现细节

### Redmi K90 图片生成优化
```yaml
设备配置:
  SoC: 骁龙8 Gen 3
  NPU: Hexagon 8th Gen (AI加速)
  GPU: Adreno 750 (Vulkan支持)
  RAM: 12GB LPDDR5X
  存储: UFS 4.0

模型配置:
  SD 1.5 FP16 量化模型 (1.5GB)
  生成速度: 8-12秒/张
  内存峰值: 3-4GB
  质量评级: 7/10
```

### Gemini API 配置
```dart
免费额度:
  1500次/天
  1M tokens/分钟
  15 RPM (请求/分钟)

API Key: Google AI Studio 获取
模型: gemini-3.5-flash
```

### 数据库设计
```sql
conversations (对话表)
  id, title, created_at, updated_at

messages (消息表)
  id, conversation_id, role, content, created_at

songs (歌曲表)
  id, title, artist, file_path, duration, type

memories (记忆表)
  id, content, category, importance, embedding, hit_count
```

## 开发环境

### 系统要求
- **Windows 11** (Build 26200)
- **Flutter 3.19.6** (稳定版)
- **Android SDK** (API 34+)
- **Java 17+**

### 运行命令
```bash
# 安装依赖
flutter pub get

# 运行应用
flutter run

# 构建APK
flutter build apk --release

# 代码分析
flutter analyze

# 格式化代码
dart format .
```

## 下一步计划

1. **立即开始**：Gemini API 服务层实现
2. **并行开发**：音乐服务 + 图片生成服务
3. **集成测试**：各模块联调测试
4. **性能优化**：Redmi K90 专项优化
5. **发布准备**：CI/CD 配置 + 应用签名

## 注意事项

1. **图片生成模型**：需要下载1.5GB模型文件
2. **Gemini API**：国内需要代理访问
3. **后台任务**：需要引导用户关闭电池优化
4. **存储权限**：需要申请文件读写权限
5. **网络权限**：需要互联网访问权限

## 联系方式

项目负责人：Marvis AI 助手
创建时间：2026-05-22
版本状态：v1.2 (开发中)