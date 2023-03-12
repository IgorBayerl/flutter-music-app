import 'song.dart';

class Playlist {
  final String id;
  final String title;
  final List<Song> songs;

  Playlist({
    required this.id,
    required this.title,
    required this.songs,
  });

  /// Add a song to the playlist
  void addSong(Song song) {
    songs.add(song);
  }

  /// Remove a song from the playlist by ID
  void removeSong(String songId) {
    songs.removeWhere((song) => song.id == songId);
  }

  /// Get the total duration of the playlist
  Duration get totalDuration {
    return songs.fold(
      Duration.zero,
      (acc, song) => acc + song.duration,
    );
  }

  // Get the total size of the playlist in bytes
  int get totalSizeInBytes {
    return songs.fold(
      0,
      (acc, song) => acc + song.sizeInBytes,
    );
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final List<dynamic> songsJson = json['songs'];
    final List<Song> songs =
        songsJson.map((songJson) => Song.fromJson(songJson)).toList();
    return Playlist(
      id: json['id'] as String,
      title: json['title'] as String,
      songs: songs,
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> songsJson =
        songs.map((song) => song.toJson()).toList();
    return {
      'id': id,
      'title': title,
      'songs': songsJson,
    };
  }
}
