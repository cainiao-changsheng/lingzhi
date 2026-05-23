import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 当前播放信息
class NowPlaying {
  final String title;
  final String artist;
  final String appName;
  final bool isPlaying;

  const NowPlaying({
    required this.title,
    required this.artist,
    this.appName = '',
    this.isPlaying = false,
  });

  static const empty = NowPlaying(title: '', artist: '');
}

/// 音乐控制服务 — 仅维护 MediaSession 连接状态
class MusicService extends StateNotifier<MusicState> {
  MusicService() : super(MusicState());

  void setConnected(bool connected) {
    state = state.copyWith(connected: connected);
  }

  void setNowPlaying(NowPlaying? np) {
    if (np != null && np.title.isNotEmpty) {
      state = state.copyWith(nowPlaying: np);
    }
  }

  void setIsPlaying(bool isPlaying) {
    state = state.copyWith(
      isPlaying: isPlaying,
      nowPlaying: NowPlaying(
        title: state.nowPlaying.title,
        artist: state.nowPlaying.artist,
        appName: state.nowPlaying.appName,
        isPlaying: isPlaying,
      ),
    );
  }
}

class MusicState {
  final bool connected;
  final NowPlaying nowPlaying;
  final bool isPlaying;

  MusicState({
    this.connected = false,
    this.nowPlaying = NowPlaying.empty,
    this.isPlaying = false,
  });

  MusicState copyWith({
    bool? connected,
    NowPlaying? nowPlaying,
    bool? isPlaying,
  }) {
    return MusicState(
      connected: connected ?? this.connected,
      nowPlaying: nowPlaying ?? this.nowPlaying,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

final musicServiceProvider =
    StateNotifierProvider.autoDispose<MusicService, MusicState>((ref) {
  return MusicService();
});