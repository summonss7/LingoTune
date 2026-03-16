class Playlist {
  final String id;
  final String name;
  final String? icon;
  final bool isSystem;
  final DateTime createdAt;
  final int songCount;
  final String? musicFolderPath;
  final String? lyricsFolderPath;
  final String? coverArtPath;
  final int coverArtVersion;

  Playlist({
    required this.id,
    required this.name,
    this.icon,
    this.isSystem = false,
    DateTime? createdAt,
    this.songCount = 0,
    this.musicFolderPath,
    this.lyricsFolderPath,
    this.coverArtPath,
    this.coverArtVersion = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      isSystem: json['isSystem'] as int == 1,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      songCount: json['songCount'] as int? ?? 0,
      musicFolderPath: json['musicFolderPath'] as String?,
      lyricsFolderPath: json['lyricsFolderPath'] as String?,
      coverArtPath: json['coverArtPath'] as String?,
      coverArtVersion: json['coverArtVersion'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'isSystem': isSystem ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'songCount': songCount,
      'musicFolderPath': musicFolderPath,
      'lyricsFolderPath': lyricsFolderPath,
      'coverArtPath': coverArtPath,
      'coverArtVersion': coverArtVersion,
    };
  }

  Playlist copyWith({
    String? id,
    String? name,
    String? icon,
    bool? isSystem,
    DateTime? createdAt,
    int? songCount,
    String? musicFolderPath,
    String? lyricsFolderPath,
    String? coverArtPath,
    int? coverArtVersion,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      songCount: songCount ?? this.songCount,
      musicFolderPath: musicFolderPath ?? this.musicFolderPath,
      lyricsFolderPath: lyricsFolderPath ?? this.lyricsFolderPath,
      coverArtPath: coverArtPath ?? this.coverArtPath,
      coverArtVersion: coverArtVersion ?? this.coverArtVersion,
    );
  }
}
