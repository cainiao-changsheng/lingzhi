import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JamendoMusicService extends StateNotifier<JamendoMusicState> {
  final Dio _dio;
  static const String _baseUrl = 'https://api.jamendo.com/v3.0';
  static const String _clientId = 'demo_app'; // 公共应用ID

  JamendoMusicService()
      : _dio = Dio(),
        super(JamendoMusicState());

  Future<void> searchTracks({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    if (query.isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _dio.get(
        '$_baseUrl/tracks/',
        queryParameters: {
          'client_id': _clientId,
          'format': 'json',
          'limit': limit,
          'offset': offset,
          'search': query,
          'fuzzytags': true,
          'audioformat': 'mp32',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List? ?? [];

        final tracks =
            results.map((track) => JamendoTrack.fromJson(track)).toList();

        state = state.copyWith(
          isLoading: false,
          searchResults: tracks,
          currentQuery: query,
        );
      } else {
        throw Exception('API 请求失败: ${response.statusCode}');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _handleDioError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> getPopularTracks({
    int limit = 20,
    int offset = 0,
    String? genre,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _dio.get(
        '$_baseUrl/tracks/',
        queryParameters: {
          'client_id': _clientId,
          'format': 'json',
          'limit': limit,
          'offset': offset,
          'order': 'popularity_total',
          'audioformat': 'mp32',
          if (genre != null && genre.isNotEmpty) 'tag': genre,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List? ?? [];

        final tracks =
            results.map((track) => JamendoTrack.fromJson(track)).toList();

        state = state.copyWith(
          isLoading: false,
          popularTracks: tracks,
        );
      } else {
        throw Exception('API 请求失败: ${response.statusCode}');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _handleDioError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> getAlbums({int limit = 20, int offset = 0}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _dio.get(
        '$_baseUrl/albums/',
        queryParameters: {
          'client_id': _clientId,
          'format': 'json',
          'limit': limit,
          'offset': offset,
          'order': 'popularity_total',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List? ?? [];

        final albums =
            results.map((album) => JamendoAlbum.fromJson(album)).toList();

        state = state.copyWith(
          isLoading: false,
          albums: albums,
        );
      } else {
        throw Exception('API 请求失败: ${response.statusCode}');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _handleDioError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> getAlbumTracks(String albumId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _dio.get(
        '$_baseUrl/albums/musictracks/',
        queryParameters: {
          'client_id': _clientId,
          'format': 'json',
          'id': albumId,
          'audioformat': 'mp32',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List? ?? [];

        final tracks =
            results.map((track) => JamendoTrack.fromJson(track)).toList();

        state = state.copyWith(
          isLoading: false,
          currentAlbumTracks: tracks,
        );
      } else {
        throw Exception('API 请求失败: ${response.statusCode}');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _handleDioError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> getGenres() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/tags/',
        queryParameters: {
          'client_id': _clientId,
          'format': 'json',
          'order': 'popularity_total',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List? ?? [];

        final genres = results.map((g) => g['name'] as String).toList();

        state = state.copyWith(availableGenres: genres);
      }
    } catch (e) {
      // 静默失败，使用默认流派
      state = state.copyWith(
        availableGenres: [
          'pop',
          'rock',
          'electronic',
          'jazz',
          'classical',
          'hiphop',
          'ambient',
          'folk'
        ],
      );
    }
  }

  void clearSearchResults() {
    state = state.copyWith(searchResults: []);
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查网络';
      case DioExceptionType.receiveTimeout:
        return '响应超时，请稍后重试';
      case DioExceptionType.badResponse:
        return '服务器响应错误';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络设置';
      default:
        return '请求失败: ${e.message}';
    }
  }
}

class JamendoTrack {
  final String id;
  final String name;
  final String artistName;
  final String artistId;
  final String albumName;
  final String albumId;
  final String? albumImage;
  final int duration;
  final String? audioUrl;
  final String? audioDownloadUrl;
  final String? link;

  JamendoTrack({
    required this.id,
    required this.name,
    required this.artistName,
    required this.artistId,
    required this.albumName,
    required this.albumId,
    this.albumImage,
    required this.duration,
    this.audioUrl,
    this.audioDownloadUrl,
    this.link,
  });

  factory JamendoTrack.fromJson(Map<String, dynamic> json) {
    return JamendoTrack(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '未知歌曲',
      artistName: json['artist_name'] ?? '未知艺术家',
      artistId: json['artist_id']?.toString() ?? '',
      albumName: json['album_name'] ?? '未知专辑',
      albumId: json['album_id']?.toString() ?? '',
      albumImage: json['album_image'],
      duration: int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      audioUrl: json['audio'],
      audioDownloadUrl: json['audio_download'],
      link: json['shareurl'],
    );
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class JamendoAlbum {
  final String id;
  final String name;
  final String artistName;
  final String artistId;
  final String? coverImage;
  final int? releaseDate;
  final String? link;

  JamendoAlbum({
    required this.id,
    required this.name,
    required this.artistName,
    required this.artistId,
    this.coverImage,
    this.releaseDate,
    this.link,
  });

  factory JamendoAlbum.fromJson(Map<String, dynamic> json) {
    return JamendoAlbum(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '未知专辑',
      artistName: json['artist_name'] ?? '未知艺术家',
      artistId: json['artist_id']?.toString() ?? '',
      coverImage: json['image'],
      releaseDate: json['release_date'] != null
          ? int.tryParse(json['release_date'].toString())
          : null,
      link: json['shareurl'],
    );
  }
}

class JamendoMusicState {
  final bool isLoading;
  final String? error;
  final List<JamendoTrack> searchResults;
  final List<JamendoTrack> popularTracks;
  final List<JamendoTrack> currentAlbumTracks;
  final List<JamendoAlbum> albums;
  final List<String> availableGenres;
  final String? currentQuery;

  JamendoMusicState({
    this.isLoading = false,
    this.error,
    this.searchResults = const [],
    this.popularTracks = const [],
    this.currentAlbumTracks = const [],
    this.albums = const [],
    this.availableGenres = const [
      'pop',
      'rock',
      'electronic',
      'jazz',
      'classical',
      'hiphop',
      'ambient',
      'folk',
      'metal',
      'indie'
    ],
    this.currentQuery,
  });

  JamendoMusicState copyWith({
    bool? isLoading,
    String? error,
    List<JamendoTrack>? searchResults,
    List<JamendoTrack>? popularTracks,
    List<JamendoTrack>? currentAlbumTracks,
    List<JamendoAlbum>? albums,
    List<String>? availableGenres,
    String? currentQuery,
  }) {
    return JamendoMusicState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchResults: searchResults ?? this.searchResults,
      popularTracks: popularTracks ?? this.popularTracks,
      currentAlbumTracks: currentAlbumTracks ?? this.currentAlbumTracks,
      albums: albums ?? this.albums,
      availableGenres: availableGenres ?? this.availableGenres,
      currentQuery: currentQuery ?? this.currentQuery,
    );
  }
}

final jamendoMusicServiceProvider =
    StateNotifierProvider.autoDispose<JamendoMusicService, JamendoMusicState>(
        (ref) {
  return JamendoMusicService();
});
