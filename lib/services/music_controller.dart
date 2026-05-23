import 'package:flutter/services.dart';

/// MediaSession 原生桥接控制器
class MusicController {
  static const _channel = MethodChannel('music_controller');

  /// 连接活跃的媒体会话
  static Future<bool> connect() async {
    try {
      return await _channel.invokeMethod<bool>('connect') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// 获取当前播放信息 {title, artist, isPlaying, appName}
  static Future<Map<String, dynamic>?> getNowPlaying() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getNowPlaying');
      if (result == null) return null;
      return {
        'title': result['title'] ?? '',
        'artist': result['artist'] ?? '',
        'isPlaying': result['isPlaying'] ?? false,
        'appName': result['appName'] ?? '',
      };
    } catch (_) {
      return null;
    }
  }

  static Future<bool> play() async =>
      await _channel.invokeMethod<bool>('play') ?? false;

  static Future<bool> pause() async =>
      await _channel.invokeMethod<bool>('pause') ?? false;

  static Future<bool> skipNext() async =>
      await _channel.invokeMethod<bool>('skipNext') ?? false;

  static Future<bool> skipPrevious() async =>
      await _channel.invokeMethod<bool>('skipPrevious') ?? false;

  /// 打开已安装的音乐 App，返回 {"package": "xxx", "opened": bool}
  static Future<Map<String, dynamic>> openMusicApp({String? package}) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'openMusicApp', {'package': package ?? ''});
      return {
        'package': result?['package'] ?? '',
        'opened': result?['opened'] ?? false,
      };
    } catch (_) {
      return {'package': '', 'opened': false};
    }
  }

  /// 搜索歌曲（通过 Intent 打开网页搜索）
  static Future<bool> searchSong(String query) async =>
      await _channel.invokeMethod<bool>('searchSong', {'query': query}) ?? false;
}