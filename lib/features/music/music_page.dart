import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_agent_mobile_app/services/music_service.dart';
import 'package:ai_agent_mobile_app/services/jamendo_music_service.dart';
import 'package:ai_agent_mobile_app/features/music/models/music_file.dart';
import 'package:ai_agent_mobile_app/theme/theme.dart';
import 'package:just_audio/just_audio.dart';

/// 音乐播放器全页面：本地音乐 + Jamendo 在线音乐双标签
class MusicPage extends ConsumerStatefulWidget {
  const MusicPage({super.key});

  @override
  ConsumerState<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends ConsumerState<MusicPage>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late StreamSubscription<PlayerState> _playerStateSubscription;
  late StreamSubscription<Duration?> _durationSubscription;
  late StreamSubscription<Duration> _positionSubscription;

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initAudio();
    // 自动扫描本地音乐
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(musicServiceProvider.notifier).autoScanLocalMusic();
      ref.read(jamendoMusicServiceProvider.notifier).getPopularTracks();
      ref.read(jamendoMusicServiceProvider.notifier).getGenres();
    });
  }

  void _initAudio() {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((s) {
      ref.read(musicServiceProvider.notifier).setPlaying(s.playing);
    });
    _durationSubscription = _audioPlayer.durationStream.listen((d) {
      ref.read(musicServiceProvider.notifier).setDuration(d ?? Duration.zero);
    });
    _positionSubscription = _audioPlayer.positionStream.listen((p) {
      ref.read(musicServiceProvider.notifier).setPosition(p);
    });
    // 加载测试音频作为默认
    _loadTestAudio();
  }

  Future<void> _loadTestAudio() async {
    try {
      await _audioPlayer.setAudioSource(
        AudioSource.asset('assets/audio/test_tone.wav'),
      );
      ref.read(musicServiceProvider.notifier).setCurrentTrack(
        const MusicFile(
          path: 'assets/audio/test_tone.wav',
          title: '测试音调 (440Hz)',
          artist: '系统生成',
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      debugPrint('Failed to load test audio: $e');
    }
  }

  // ─────────── 播放控制 ───────────
  Future<void> _play() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Play error: $e');
    }
  }

  Future<void> _pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint('Pause error: $e');
    }
  }

  Future<void> _seek(Duration p) async {
    try {
      await _audioPlayer.seek(p);
    } catch (e) {
      debugPrint('Seek error: $e');
    }
  }

  Future<void> _setVolume(double v) async {
    try {
      await _audioPlayer.setVolume(v);
      ref.read(musicServiceProvider.notifier).setVolume(v);
    } catch (e) {
      debugPrint('Volume error: $e');
    }
  }

  // ─────────── 播放本地文件 ───────────
  Future<void> _playLocalFile(MusicFile file) async {
    try {
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.file(file.path)));
      ref.read(musicServiceProvider.notifier).setCurrentTrack(file);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Local play error: $e');
    }
  }

  // ─────────── 播放 Jamendo 在线曲目 ───────────
  Future<void> _playJamendoTracks(List<JamendoTrack> tracks, int start) async {
    if (tracks.isEmpty) return;
    final sources = <AudioSource>[];
    for (final t in tracks) {
      final url = t.audioUrl;
      if (url != null && url.isNotEmpty) {
        sources.add(AudioSource.uri(Uri.parse(url)));
      }
    }
    if (sources.isEmpty) return;

    try {
      if (sources.length == 1) {
        await _audioPlayer.setAudioSource(sources.first);
      } else {
        await _audioPlayer.setAudioSource(
          ConcatenatingAudioSource(children: sources),
        );
        if (start > 0 && start < sources.length) {
          await _audioPlayer.seek(Duration.zero, index: start);
        }
      }
      ref.read(musicServiceProvider.notifier).setJamendoPlaylist(tracks,
          startIndex: start);
      ref.read(musicServiceProvider.notifier)
        ..setCurrentTrack(const MusicFile(path: '', title: 'Jamendo'))
        ..setSource(MusicSource.jamendo);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Jamendo play error: $e');
    }
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _durationSubscription.cancel();
    _positionSubscription.cancel();
    _audioPlayer.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final musicState = ref.watch(musicServiceProvider);
    final jamendoState = ref.watch(jamendoMusicServiceProvider);
    final isPlaying = musicState.isPlaying;
    final position = musicState.position;
    final duration = musicState.duration;
    final volume = musicState.volume;
    final currentTrack = musicState.currentTrack;
    final source = musicState.source;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('音乐', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '本地音乐'),
            Tab(text: '在线音乐'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLocalTab(musicState),
                _buildOnlineTab(jamendoState),
              ],
            ),
          ),
          // ─── 底部迷你播放条 ───
          _buildMiniPlayer(currentTrack, isPlaying, position, duration, volume,
              source, jamendoState),
        ],
      ),
    );
  }

  // ─────────── 本地音乐标签页 ───────────
  Widget _buildLocalTab(MusicState state) {
    if (state.isScanningLocal) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state.localError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder_off, size: 64, color: Colors.white38),
              const SizedBox(height: 16),
              const Text('无法读取本地音乐',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 8),
              Text(state.localError!,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(musicServiceProvider.notifier).autoScanLocalMusic(),
                icon: const Icon(Icons.refresh),
                label: const Text('重新扫描'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }
    if (state.localTracks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.library_music_outlined,
                  size: 64, color: Colors.white38),
              const SizedBox(height: 16),
              const Text('未找到本地音乐文件',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 8),
              const Text(
                '请将音乐文件放入 Music 或 Download 目录后重新扫描',
                style: TextStyle(color: Colors.white38, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(musicServiceProvider.notifier).autoScanLocalMusic(),
                icon: const Icon(Icons.search),
                label: const Text('扫描本地音乐'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    final grouped = <String, List<MusicFile>>{};
    for (final t in state.localTracks) {
      final p = t.path;
      // 尝试从路径中提取艺术家/专辑信息
      final parts = p
          .replaceAll('\\', '/')
          .split('/')
          .where((s) => s.isNotEmpty)
          .toList();
      String key = '其他';
      for (int i = 0; i < parts.length - 1; i++) {
        final part = parts[i].toLowerCase();
        if (part == 'music' || part == 'download' || part == 'audiobooks') {
          key = i + 1 < parts.length ? parts[i + 1] : parts[i];
          break;
        }
        if (part.contains('album') || part.contains('专辑')) {
          key = parts[i];
          break;
        }
      }
      if (key == '其他') key = '全部音乐';
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return ListView(
      children: grouped.entries.map((e) {
        return _buildLocalGroup(e.key, e.value);
      }).toList(),
    );
  }

  Widget _buildLocalGroup(String title, List<MusicFile> tracks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...tracks.map((t) => _buildLocalTrackTile(t)),
        ],
      ),
    );
  }

  Widget _buildLocalTrackTile(MusicFile track) {
    final isCurrent = ref.watch(musicServiceProvider).currentTrack?.path ==
        track.path;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.audiotrack, color: AppColors.primary, size: 20),
        ),
        title: Text(track.title,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Text(_formatFileSize(track.fileSize ?? 0),
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
        trailing: IconButton(
          icon: Icon(isCurrent ? Icons.pause : Icons.play_arrow,
              color: AppColors.primary),
          onPressed: () {
            if (isCurrent) {
              ref.watch(musicServiceProvider).isPlaying ? _pause() : _play();
            } else {
              _playLocalFile(track);
            }
          },
        ),
        onTap: () => _playLocalFile(track),
      ),
    );
  }

  // ─────────── 在线音乐标签页 (Jamendo) ───────────
  Widget _buildOnlineTab(JamendoMusicState state) {
    return Column(
      children: [
        // 搜索栏
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '搜索音乐...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon:
                  const Icon(Icons.search, color: Colors.white38),
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white38),
                      onPressed: () {
                        _searchController.clear();
                        ref
                            .read(jamendoMusicServiceProvider.notifier)
                            .clearSearchResults();
                      },
                    )
                  : null,
            ),
            onSubmitted: (q) {
              ref
                  .read(jamendoMusicServiceProvider.notifier)
                  .searchTracks(query: q);
            },
          ),
        ),
        // 搜索结果或热门/流派
        Expanded(
          child: state.searchResults.isNotEmpty
              ? _buildSearchResults(state)
              : _buildPopularAndGenres(state),
        ),
      ],
    );
  }

  Widget _buildSearchResults(JamendoMusicState state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.searchResults.length,
      itemBuilder: (_, i) =>
          _buildJamendoTrackTile(state.searchResults[i], state.searchResults, i),
    );
  }

  Widget _buildPopularAndGenres(JamendoMusicState state) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // 流派标签
        if (state.availableGenres.isNotEmpty) ...[
          const Text('音乐流派',
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.availableGenres.take(12).map((genre) {
              return GestureDetector(
                onTap: () {
                  ref
                      .read(jamendoMusicServiceProvider.notifier)
                      .getPopularTracks(genre: genre);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(genre,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
        // 热门曲目
        if (state.isLoading && state.popularTracks.isEmpty)
          const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary)),
        if (state.error != null && state.popularTracks.isEmpty)
          Center(
              child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(state.error!,
                style: const TextStyle(color: Colors.redAccent)),
          )),
        if (state.popularTracks.isNotEmpty) ...[
          const Text('热门推荐',
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...state.popularTracks.map((t) =>
              _buildJamendoTrackTile(t, state.popularTracks,
                  state.popularTracks.indexOf(t))),
        ],
      ],
    );
  }

  Widget _buildJamendoTrackTile(
      JamendoTrack track, List<JamendoTrack> playlist, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 48,
            height: 48,
            color: AppColors.surface,
            child: track.albumImage != null
                ? Image.network(track.albumImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.album,
                        color: AppColors.primary))
                : const Icon(Icons.album, color: AppColors.primary),
          ),
        ),
        title: Text(track.name,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Text('${track.artistName} · ${track.formattedDuration}',
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow, color: AppColors.primary),
          onPressed: () => _playJamendoTracks(playlist, index),
        ),
        onTap: () => _playJamendoTracks(playlist, index),
      ),
    );
  }

  // ─────────── 底部迷你播放条 ───────────
  Widget _buildMiniPlayer(MusicFile? currentTrack, bool isPlaying,
      Duration position, Duration duration, double volume,
      MusicSource source, JamendoMusicState jamendoState) {
    final musicState = ref.watch(musicServiceProvider);
    // 确定显示的标题
    String title = '未在播放';
    String? subtitle;
    if (source == MusicSource.jamendo && musicState.jamendoPlaylist.isNotEmpty) {
      final idx = musicState.jamendoCurrentIndex;
      if (idx < musicState.jamendoPlaylist.length) {
        final jt = musicState.jamendoPlaylist[idx];
        title = jt.name;
        subtitle = jt.artistName;
      }
    } else if (currentTrack != null && currentTrack.title != 'Jamendo') {
      title = currentTrack.title;
      subtitle = currentTrack.artist;
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 进度条
          Slider(
            value: position.inSeconds.toDouble(),
            min: 0,
            max: duration.inSeconds.toDouble().clamp(1, double.infinity),
            onChanged: (v) => _seek(Duration(seconds: v.toInt())),
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
          ),
          const SizedBox(height: 4),
          // 控制栏
          Row(
            children: [
              // 封面
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.music_note, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              // 标题
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (subtitle != null)
                      Text(subtitle,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              // 播放/暂停
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: isPlaying ? _pause : _play,
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                      minWidth: 40, minHeight: 40),
                ),
              ),
              // 音量
              SizedBox(
                width: 100,
                child: Slider(
                  value: volume,
                  min: 0,
                  max: 1,
                  onChanged: _setVolume,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}