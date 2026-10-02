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
}

class RecognitionJob {
  const RecognitionJob({required this.uuid, required this.resultsUrl});

  final String uuid;
  final String resultsUrl;
}

class RecognitionException implements Exception {
  const RecognitionException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}
