class MusicFile {
  final String path;
  final String title;
  final String? artist;
  final String? album;
  final Duration? duration;
  final int? fileSize;

  MusicFile({
    required this.path,
    required this.title,
    this.artist,
    this.album,
    this.duration,
    this.fileSize,
  });

  Map<String, dynamic> toJson() => {
        'path': path,
        'title': title,
        'artist': artist,
        'album': album,
        'duration': duration?.inSeconds,
        'fileSize': fileSize,
      };

  factory MusicFile.fromJson(Map<String, dynamic> json) => MusicFile(
        path: json['path'],
        title: json['title'],
        artist: json['artist'],
        album: json['album'],
        duration: json['duration'] != null ? Duration(seconds: json['duration']) : null,
        fileSize: json['fileSize'],
      );
}