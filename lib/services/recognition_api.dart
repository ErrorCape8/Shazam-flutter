import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/recognition.dart';

class RecognitionApi {
  RecognitionApi(this.apiKey, {http.Client? client})
    : _client = client ?? http.Client();

  static final Uri _baseUri = Uri.https('shazam-api.com');
  final String apiKey;
  final http.Client _client;

  Future<RecognitionJob> recognizeAudio(
    Uint8List audio, {
    String filename = 'sonara-recording.wav',
  }) async {
    _requireKey();
    final request =
        http.MultipartRequest('POST', _baseUri.resolve('/api/v2/recognize'))
          ..headers.addAll(_headers)
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              audio,
              filename: filename,
              contentType: _mediaType(filename),
            ),
          );
    final response = await http.Response.fromStream(
      await _client.send(request).timeout(const Duration(seconds: 60)),
    );
    return RecognitionJob.fromJson(_decode(response));
  }

  Future<RecognitionOutcome> getResult(String uuid) async {
    _requireKey();
    final encodedUuid = Uri.encodeComponent(uuid);
    final response = await _client
        .get(
          _baseUri.resolve('/api/v2/results/$encodedUuid'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 30));
    return RecognitionOutcome.fromJson(_decode(response));
  }

  Future<RecognitionOutcome> waitForResult(
    String uuid, {
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 3),
    void Function()? onPoll,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < timeout) {
      final result = await getResult(uuid);
      if (result.status != 'processing') return result;
      onPoll?.call();
      await Future<void>.delayed(interval);
    }
    throw const RecognitionApiException(
      'La identificación sigue procesándose. Inténtalo de nuevo en un momento.',
    );
  }

  Map<String, String> get _headers => {
    'Authorization': 'Bearer ${apiKey.trim()}',
    'Accept': 'application/json',
  };

  void _requireKey() {
    if (apiKey.trim().isEmpty) {
      throw const RecognitionApiException(
        'Agrega tu clave de shazam-api.com en Ajustes.',
      );
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      decoded = null;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final data = decoded is Map ? decoded : const <String, dynamic>{};
      final error =
          data['error']?.toString() ??
          data['message']?.toString() ??
          'Error HTTP ${response.statusCode}.';
      throw RecognitionApiException(
        error,
        statusCode: response.statusCode,
        code: data['code']?.toString(),
      );
    }
    if (decoded is! Map) {
      throw const RecognitionApiException(
        'La API devolvió una respuesta inválida.',
      );
    }
    return Map<String, dynamic>.from(decoded);
  }

  MediaType _mediaType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    return switch (extension) {
      'wav' => MediaType('audio', 'wav'),
      'mp3' => MediaType('audio', 'mpeg'),
      'm4a' => MediaType('audio', 'mp4'),
      'aac' => MediaType('audio', 'aac'),
      'ogg' => MediaType('audio', 'ogg'),
      'flac' => MediaType('audio', 'flac'),
      'webm' => MediaType('audio', 'webm'),
      _ => MediaType('application', 'octet-stream'),
    };
  }
}
