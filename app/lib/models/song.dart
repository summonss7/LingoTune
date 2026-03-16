import 'translation.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String audioPath;
  final String? lrcPath;
  final String? translationsPath;
  final List<Translation> translations;
  final String originalLanguage;
  final String? language;
  final String? selectedLanguage;
  final String? coverArtPath;
  final int coverArtVersion;
  final bool hasLyrics;
  final bool isInLibrary;
  final DateTime createdAt;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioPath,
    this.lrcPath,
    this.translationsPath,
    List<Translation>? translations,
    this.originalLanguage = 'unknown',
    this.language,
    this.selectedLanguage,
    this.coverArtPath,
    this.coverArtVersion = 0,
    this.hasLyrics = true,
    this.isInLibrary = true,
    DateTime? createdAt,
  }) : translations = translations ?? [],
        createdAt = createdAt ?? DateTime.now();

  factory Song.fromJson(Map<String, dynamic> json) {
    final hasLyricsValue = json['hasLyrics'];
    final hasLyrics = hasLyricsValue == 1 || hasLyricsValue == true;

    final isInLibraryValue = json['isInLibrary'];
    final isInLibrary = isInLibraryValue == null || isInLibraryValue == 1 || isInLibraryValue == true;

    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      audioPath: json['audioPath'] as String,
      lrcPath: json['lrcPath'] as String?,
      translationsPath: json['translationsPath'] as String?,
      translations: (json['translations'] as List?)
              ?.map((t) => Translation.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      originalLanguage: json['originalLanguage'] as String? ?? 'unknown',
      language: json['language'] as String?,
      selectedLanguage: json['selectedLanguage'] as String?,
      coverArtPath: json['coverArtPath'] as String?,
      coverArtVersion: json['coverArtVersion'] as int? ?? 0,
      hasLyrics: hasLyrics,
      isInLibrary: isInLibrary,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'audioPath': audioPath,
      'lrcPath': lrcPath,
      'translationsPath': translationsPath,
      'originalLanguage': originalLanguage,
      'language': language,
      'selectedLanguage': selectedLanguage,
      'coverArtPath': coverArtPath,
      'coverArtVersion': coverArtVersion,
      'hasLyrics': hasLyrics ? 1 : 0,
      'isInLibrary': isInLibrary ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? audioPath,
    String? lrcPath,
    String? translationsPath,
    List<Translation>? translations,
    String? originalLanguage,
    String? language,
    String? selectedLanguage,
    String? coverArtPath,
    int? coverArtVersion,
    bool? hasLyrics,
    bool? isInLibrary,
    DateTime? createdAt,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      audioPath: audioPath ?? this.audioPath,
      lrcPath: lrcPath ?? this.lrcPath,
      translationsPath: translationsPath ?? this.translationsPath,
      translations: translations ?? this.translations,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      language: language ?? this.language,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      coverArtPath: coverArtPath ?? this.coverArtPath,
      coverArtVersion: coverArtVersion ?? this.coverArtVersion,
      hasLyrics: hasLyrics ?? this.hasLyrics,
      isInLibrary: isInLibrary ?? this.isInLibrary,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
