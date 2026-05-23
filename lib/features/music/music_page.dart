import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_agent_mobile_app/services/music_controller.dart';
import 'package:ai_agent_mobile_app/services/music_service.dart';
import 'package:ai_agent_mobile_app/theme/theme.dart';

/// 音乐页面：通过 Android MediaSession 获取正在播放信息，
/// 并通过 Intent 打开外部音乐 App 进行播放控制。
class MusicPage extends ConsumerStatefulWidget {
  const MusicPage({super.key});

  @override
  ConsumerState<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends ConsumerState<MusicPage> {
  Timer? _pollTimer;

  // 支持的音乐 App 列表
  static const _supportedApps = [
    _MusicApp('网易云音乐', 'com.netease.cloudmusic', Icons.cloud),
    _MusicApp('QQ音乐', 'com.tencent.qqmusic', Icons.music_note),
    _MusicApp('酷狗音乐', 'com.kugou.android', Icons.headphones),
    _MusicApp('Apple Music', 'com.apple.android.music', Icons.apple),
    _MusicApp('Spotify', 'com.spotify.music', Icons.album),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initConnection());
  }

  Future<void> _initConnection() async {
    final ok = await MusicController.connect();
    if (mounted) {
      ref.read(musicServiceProvider.notifier).setConnected(ok);
      if (ok) _startPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted) return;
      final np = await MusicController.getNowPlaying();
      if (np != null && mounted) {
        ref.read(musicServiceProvider.notifier).setNowPlaying(NowPlaying(
          title: (np['title'] as String?) ?? '',
          artist: (np['artist'] as String?) ?? '',
          appName: (np['appName'] as String?) ?? '',
          isPlaying: (np['isPlaying'] as bool?) ?? false,
        ));
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    final state = ref.read(musicServiceProvider);
    if (state.nowPlaying.isPlaying) {
      await MusicController.pause();
      ref.read(musicServiceProvider.notifier).setIsPlaying(false);
    } else {
      await MusicController.play();
      ref.read(musicServiceProvider.notifier).setIsPlaying(true);
    }
  }

  Future<void> _openMusicApp(_MusicApp app) async {
    final result = await MusicController.openMusicApp(package: app.package);
    final opened = result['opened'] == true;
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('未安装 ${app.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final musicState = ref.watch(musicServiceProvider);
    final np = musicState.nowPlaying;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('音乐', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ─── 正在播放卡片 ───
          _buildNowPlayingCard(np, musicState.connected),
          const SizedBox(height: 24),
          // ─── 音乐 App 快捷入口 ───
          _buildAppShortcuts(),
        ],
      ),
    );
  }

  Widget _buildNowPlayingCard(NowPlaying np, bool connected) {
    final hasTrack = np.title.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D2D3F), Color(0xFF1A1A2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // 专辑封面占位
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: hasTrack
                          ? [const Color(0xFF6C63FF), const Color(0xFF9B59B6)]
                          : [Colors.white24, Colors.white12],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasTrack ? Icons.music_note : Icons.speaker,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasTrack ? np.title : '当前未播放',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasTrack
                            ? '${np.artist.isNotEmpty ? np.artist + " · " : ""}${np.appName}'
                            : '打开下方音乐 App 开始播放',
                        style: const TextStyle(color: Colors.white60, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasTrack) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _controlButton(Icons.skip_previous, () => MusicController.skipPrevious()),
                  const SizedBox(width: 32),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _togglePlayPause,
                      icon: Icon(
                        np.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(width: 32),
                  _controlButton(Icons.skip_next, () => MusicController.skipNext()),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                connected ? '已连接 · 通过 MediaSession 控制' : '未连接 · 请打开音乐 App 后刷新',
                style: TextStyle(
                  color: connected ? Colors.green : Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white70, size: 32),
    );
  }

  Widget _buildAppShortcuts() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '选择音乐 App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ..._supportedApps.map((app) => _buildAppTile(app)),
        ],
      ),
    );
  }

  Widget _buildAppTile(_MusicApp app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(app.icon, color: AppColors.primary, size: 24),
        ),
        title: Text(app.name,
            style: const TextStyle(color: Colors.white, fontSize: 15)),
        trailing: const Icon(Icons.open_in_new, color: Colors.white38, size: 20),
        onTap: () => _openMusicApp(app),
      ),
    );
  }
}

class _MusicApp {
  final String name;
  final String package;
  final IconData icon;

  const _MusicApp(this.name, this.package, this.icon);
}