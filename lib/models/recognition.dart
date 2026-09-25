class RecognitionTrack {
  const RecognitionTrack({
    required this.title,
    required this.artist,
    this.album = '',
    this.artwork = '',
    this.genre = '',
    this.releaseDate = '',
    this.shazamUrl = '',
    this.appleMusicUrl = '',
    this.spotifyUrl = '',
    this.deezerUrl = '',
  });

  final String title;
  final String artist;
  final String album;
  final String artwork;
  final String genre;
  final String releaseDate;
  final String shazamUrl;
  final String appleMusicUrl;
  final String spotifyUrl;
  final String deezerUrl;

  factory RecognitionTrack.fromJson(Map<String, dynamic> json) {
    final links = _map(json['links']);
    return RecognitionTrack(
      title: _string(json['title']),
      artist: _string(json['artist']),
      album: _string(json['album']),
      artwork: _string(json['artwork']),
      genre: _string(json['genre']),
      releaseDate: _string(json['releaseDate']),
      shazamUrl: _string(links?['shazam']),
      appleMusicUrl: _string(links?['appleMusic']),
      spotifyUrl: _string(links?['spotify']),
      deezerUrl: _string(links?['deezer']),
    );
  }

  static Map<String, dynamic>? _map(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String _string(Object? value) => value?.toString() ?? '';
}

class RecognitionOutcome {
  const RecognitionOutcome({
    required this.status,
    this.tracks = const [],
    this.error = '',
    this.code = '',
  });

  final String status;
  final List<RecognitionTrack> tracks;
  final String error;
  final String code;

  factory RecognitionOutcome.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    final tracks = rawResults is List
        ? rawResults
              .whereType<Map>()
              .map(
                (result) => RecognitionTrack.fromJson(
                  Map<String, dynamic>.from(result),
                ),
              )
              .toList()
        : const <RecognitionTrack>[];
    return RecognitionOutcome(
      status: json['status']?.toString() ?? 'failed',
      tracks: tracks,
      error: json['error']?.toString() ?? json['reason']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
    );
  }
}

class RecognitionJob {
  const RecognitionJob({required this.uuid, required this.resultsUrl});

  final String uuid;
  final String resultsUrl;

  factory RecognitionJob.fromJson(Map<String, dynamic> json) {
    final uuid = json['uuid']?.toString() ?? '';
    if (uuid.isEmpty) {
      throw const RecognitionApiException(
        'La API aceptó la solicitud sin devolver un UUID.',
      );
    }
    return RecognitionJob(
      uuid: uuid,
      resultsUrl: json['resultsUrl']?.toString() ?? '/api/v2/results/$uuid',
    );
  }
}

class RecognitionApiException implements Exception {
  const RecognitionApiException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}
