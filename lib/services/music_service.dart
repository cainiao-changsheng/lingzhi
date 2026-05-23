import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:ai_agent_mobile_app/features/music/models/music_file.dart';
import 'package:ai_agent_mobile_app/services/jamendo_music_service.dart';

/// 统一音乐服务：管理本地音乐扫描 + 包装 Jamendo 在线音乐
class MusicService extends StateNotifier<MusicState> {
  MusicService() : super(MusicState());

  // ─────────── 本地音乐扫描 ───────────
  /// 自动扫描 Android 常见音乐目录
  Future<void> autoScanLocalMusic() async {
    if (state.isScanningLocal) return;
    state = state.copyWith(isScanningLocal: true, localError: null);

    try {
      final musicDirs = await _getMusicDirectories();
      final allFiles = <MusicFile>[];

      for (final dir in musicDirs) {
        if (!dir.existsSync()) continue;
        try {
          final files = dir
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) {
                final ext = p.extension(f.path).toLowerCase();
                return const [
                  '.mp3', '.m4a', '.aac', '.flac', '.ogg', '.wav', '.wma'
                ].contains(ext);
              })
              .toList();

          for (final file in files) {
            allFiles.add(MusicFile(
              path: file.path,
              title: p.basenameWithoutExtension(file.path),
              fileSize: file.lengthSync(),
            ));
          }
        } catch (_) {
          // 跳过无权访问的目录
        }
      }

      // 去重（按路径）
      final seen = <String>{};
      final unique = allFiles.where((f) => seen.add(f.path)).toList();
      unique.sort((a, b) => a.title.compareTo(b.title));

      state = state.copyWith(
        isScanningLocal: false,
        localTracks: unique,
        localReady: true,
      );
    } catch (e) {
      state = state.copyWith(isScanningLocal: false, localError: e.toString());
    }
  }

  Future<List<Directory>> _getMusicDirectories() async {
    final dirs = <Directory>[];

    // Android 常见音乐路径
    if (!kIsWeb && Platform.isAndroid) {
      dirs.addAll([
        Directory('/storage/emulated/0/Music'),
        Directory('/storage/emulated/0/Download'),
        Directory('/storage/emulated/0/Audiobooks'),
        Directory('/storage/emulated/0/Podcasts'),
        Directory('/storage/emulated/0/Recordings'),
        Directory('/storage/emulated/0/Ringtones'),
        Directory('/storage/emulated/0/Notifications'),
      ]);
    }

    // 应用文档目录（兜底）
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      dirs.add(Directory(appDocDir.path));
    } catch (_) {}

    return dirs;
  }

  // ─────────── 播放控制代理 ───────────
  void setLocalPlaylist(List<MusicFile> tracks) {
    state = state.copyWith(currentPlaylist: tracks, source: MusicSource.local);
  }

  void setJamendoPlaylist(List<JamendoTrack> tracks, {int startIndex = 0}) {
    state = state.copyWith(
      jamendoPlaylist: tracks,
      jamendoCurrentIndex: startIndex,
      source: MusicSource.jamendo,
    );
  }

  void setCurrentTrack(MusicFile? track) {
    state = state.copyWith(currentTrack: track);
  }

  void setPlaying(bool playing) {
    state = state.copyWith(isPlaying: playing);
  }

  void setVolume(double volume) {
    state = state.copyWith(volume: volume);
  }

  void setDuration(Duration duration) {
    state = state.copyWith(duration: duration);
  }

  void setPosition(Duration position) {
    state = state.copyWith(position: position);
  }

  void setSource(MusicSource source) {
    state = state.copyWith(source: source);
  }
}

/// 音乐来源类型
enum MusicSource { local, jamendo, none }

class MusicState {
  // 本地音乐
  final List<MusicFile> currentPlaylist;
  final List<MusicFile> localTracks;
  final bool localReady;
  final bool isScanningLocal;
  final String? localError;

  // Jamendo 在线音乐
  final List<JamendoTrack> jamendoPlaylist;
  final int jamendoCurrentIndex;

  // 通用播放状态
  final MusicSource source;
  final MusicFile? currentTrack;
  final JamendoTrack? currentJamendoTrack;
  final bool isPlaying;
  final double volume;
  final Duration duration;
  final Duration position;

  MusicState({
    this.currentPlaylist = const [],
    this.localTracks = const [],
    this.localReady = false,
    this.isScanningLocal = false,
    this.localError,
    this.jamendoPlaylist = const [],
    this.jamendoCurrentIndex = 0,
    this.source = MusicSource.none,
    this.currentTrack,
    this.currentJamendoTrack,
    this.isPlaying = false,
    this.volume = 0.5,
    this.duration = Duration.zero,
    this.position = Duration.zero,
  });

  MusicState copyWith({
    List<MusicFile>? currentPlaylist,
    List<MusicFile>? localTracks,
    bool? localReady,
    bool? isScanningLocal,
    String? localError,
    List<JamendoTrack>? jamendoPlaylist,
    int? jamendoCurrentIndex,
    MusicSource? source,
    MusicFile? currentTrack,
    JamendoTrack? currentJamendoTrack,
    bool? isPlaying,
    double? volume,
    Duration? duration,
    Duration? position,
  }) {
    return MusicState(
      currentPlaylist: currentPlaylist ?? this.currentPlaylist,
      localTracks: localTracks ?? this.localTracks,
      localReady: localReady ?? this.localReady,
      isScanningLocal: isScanningLocal ?? this.isScanningLocal,
      localError: localError,
      jamendoPlaylist: jamendoPlaylist ?? this.jamendoPlaylist,
      jamendoCurrentIndex: jamendoCurrentIndex ?? this.jamendoCurrentIndex,
      source: source ?? this.source,
      currentTrack: currentTrack ?? this.currentTrack,
      currentJamendoTrack:
          currentJamendoTrack ?? this.currentJamendoTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      duration: duration ?? this.duration,
      position: position ?? this.position,
    );
  }
}

final musicServiceProvider =
    StateNotifierProvider.autoDispose<MusicService, MusicState>((ref) {
  return MusicService();
});