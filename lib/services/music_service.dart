import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:ai_agent_mobile_app/features/music/models/music_file.dart';

class MusicService extends StateNotifier<MusicState> {
  MusicService() : super(MusicState());

  Future<void> scanMusicDirectory(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!directory.existsSync()) {
        throw Exception('目录不存在: $directoryPath');
      }

      final files = directory.listSync(recursive: true).where((entity) {
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          return const ['.mp3', '.m4a', '.aac', '.flac', '.ogg', '.wav', '.wma'].contains(ext);
        }
        return false;
      }).cast<File>().toList();

      final musicFiles = files.map((file) {
        final fileName = p.basenameWithoutExtension(file.path);
        return MusicFile(
          path: file.path,
          title: fileName,
          fileSize: file.lengthSync(),
        );
      }).toList();

      musicFiles.sort((a, b) => a.title.compareTo(b.title));

      state = state.copyWith(
        currentPlaylist: musicFiles,
        isReady: true,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void setCurrentTrack(MusicFile track) {
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

  void clearPlaylist() {
    state = MusicState(isReady: false);
  }
}

class MusicState {
  final List<MusicFile> currentPlaylist;
  final MusicFile? currentTrack;
  final bool isPlaying;
  final double volume;
  final Duration duration;
  final Duration position;
  final bool isReady;
  final String? error;

  MusicState({
    this.currentPlaylist = const [],
    this.currentTrack,
    this.isPlaying = false,
    this.volume = 0.5,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.isReady = false,
    this.error,
  });

  MusicState copyWith({
    List<MusicFile>? currentPlaylist,
    MusicFile? currentTrack,
    bool? isPlaying,
    double? volume,
    Duration? duration,
    Duration? position,
    bool? isReady,
    String? error,
  }) {
    return MusicState(
      currentPlaylist: currentPlaylist ?? this.currentPlaylist,
      currentTrack: currentTrack ?? this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      isReady: isReady ?? this.isReady,
      error: error,
    );
  }
}

final musicServiceProvider =
    StateNotifierProvider.autoDispose<MusicService, MusicState>((ref) {
  return MusicService();
});