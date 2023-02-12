class Song {
  final String id;
  final String title;
  final String album;
  final String url;
  final bool isLocalPath;

  Song({
    required this.id,
    required this.title,
    required this.album,
    required this.url,
    this.isLocalPath = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'album': album,
      'url': url,
      'isLocalPath': isLocalPath,
    };
  }

  static Song fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      album: json['album'] as String,
      url: json['url'] as String,
      isLocalPath: json['isLocalPath'] as bool,
    );
  }
}
