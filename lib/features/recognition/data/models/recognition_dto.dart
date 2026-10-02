import '../../domain/entities/recognition.dart';

class RecognitionTrackDto {
  const RecognitionTrackDto(this.track);

  final RecognitionTrack track;

  factory RecognitionTrackDto.fromJson(Map<String, dynamic> json) {
    final links = _map(json['links']);
    return RecognitionTrackDto(
      RecognitionTrack(
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
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': track.title,
    'artist': track.artist,
    'album': track.album,
    'artwork': track.artwork,
    'genre': track.genre,
    'releaseDate': track.releaseDate,
    'links': {
      'shazam': track.shazamUrl,
      'appleMusic': track.appleMusicUrl,
      'spotify': track.spotifyUrl,
      'deezer': track.deezerUrl,
    },
  };

  static Map<String, dynamic>? _map(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String _string(Object? value) => value?.toString() ?? '';
}

class RecognitionOutcomeDto {
  const RecognitionOutcomeDto(this.outcome);

  final RecognitionOutcome outcome;

  factory RecognitionOutcomeDto.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    final tracks = rawResults is List
        ? rawResults
              .whereType<Map>()
              .map(
                (result) => RecognitionTrackDto.fromJson(
                  Map<String, dynamic>.from(result),
                ).track,
              )
              .toList()
        : const <RecognitionTrack>[];
    return RecognitionOutcomeDto(
      RecognitionOutcome(
        status: json['status']?.toString() ?? 'failed',
        tracks: tracks,
        error: json['error']?.toString() ?? json['reason']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
      ),
    );
  }
}

class RecognitionJobDto {
  const RecognitionJobDto(this.job);

  final RecognitionJob job;

  factory RecognitionJobDto.fromJson(Map<String, dynamic> json) {
    final uuid = json['uuid']?.toString() ?? '';
    if (uuid.isEmpty) {
      throw const RecognitionException(
        'La API aceptó la solicitud sin devolver un UUID.',
      );
    }
    return RecognitionJobDto(
      RecognitionJob(
        uuid: uuid,
        resultsUrl: json['resultsUrl']?.toString() ?? '/api/v2/results/$uuid',
      ),
    );
  }
}
