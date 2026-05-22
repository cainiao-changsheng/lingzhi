import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_agent_mobile_app/services/music_service.dart';
import 'package:ai_agent_mobile_app/features/music/models/music_file.dart';
import 'package:ai_agent_mobile_app/theme/theme.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayer extends ConsumerStatefulWidget {
  const MusicPlayer({super.key});

  @override
  ConsumerState<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends ConsumerState<MusicPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late StreamSubscription<PlayerState> _playerStateSubscription;
  late StreamSubscription<Duration?> _durationSubscription;
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<SequenceState?> _sequenceStateSubscription;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    final musicState = ref.read(musicServiceProvider);

    if (musicState.currentPlaylist.isNotEmpty) {
      _loadPlaylist(musicState.currentPlaylist);
    }

    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        ref.read(musicServiceProvider.notifier).setPlaying(true);
      } else {
        ref.read(musicServiceProvider.notifier).setPlaying(false);
      }
    });

    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      ref.read(musicServiceProvider.notifier).setDuration(duration ?? Duration.zero);
    });

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      ref.read(musicServiceProvider.notifier).setPosition(position);
    });

    _sequenceStateSubscription = _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null) {
        final currentIndex = sequenceState.currentIndex;
        if (currentIndex != null) {
          final currentItem = sequenceState.currentSource?.tag;
          if (currentItem != null) {
            ref.read(musicServiceProvider.notifier).setCurrentTrack(currentItem as MusicFile);
          }
        }
      }
    });
  }

  Future<void> _loadPlaylist(List<MusicFile> playlist) async {
    try {
      final audioSources = playlist.map((musicFile) {
        return AudioSource.uri(
          Uri.file(musicFile.path),
          tag: musicFile,
        );
      }).toList();

      await _audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: audioSources),
      );
    } catch (e) {
      debugPrint('Failed to load playlist: $e');
    }
  }

  Future<void> _play() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Failed to play: $e');
    }
  }

  Future<void> _pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint('Failed to pause: $e');
    }
  }

  Future<void> _stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Failed to stop: $e');
    }
  }

  Future<void> _seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      debugPrint('Failed to seek: $e');
    }
  }

  Future<void> _next() async {
    try {
      await _audioPlayer.seekToNext();
    } catch (e) {
      debugPrint('Failed to next: $e');
    }
  }

  Future<void> _previous() async {
    try {
      await _audioPlayer.seekToPrevious();
    } catch (e) {
      debugPrint('Failed to previous: $e');
    }
  }

  Future<void> _setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
      ref.read(musicServiceProvider.notifier).setVolume(volume);
    } catch (e) {
      debugPrint('Failed to set volume: $e');
    }
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _durationSubscription.cancel();
    _positionSubscription.cancel();
    _sequenceStateSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final musicState = ref.watch(musicServiceProvider);
    final currentTrack = musicState.currentTrack;
    final isPlaying = musicState.isPlaying;
    final position = musicState.position;
    final duration = musicState.duration;
    final volume = musicState.volume;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (currentTrack != null) ...[
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.music_note, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentTrack.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentTrack.artist ?? '未知艺术家',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Slider(
              value: position.inSeconds.toDouble(),
              min: 0,
              max: duration.inSeconds.toDouble(),
              onChanged: (value) {
                _seek(Duration(seconds: value.toInt()));
              },
              activeColor: AppColors.primary,
              inactiveColor: AppColors.border,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _previous,
                icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: isPlaying ? _pause : _play,
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _next,
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.volume_down_rounded, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: volume,
                  min: 0,
                  max: 1,
                  onChanged: _setVolume,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                ),
              ),
              const Icon(Icons.volume_up_rounded, color: Colors.white70, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}