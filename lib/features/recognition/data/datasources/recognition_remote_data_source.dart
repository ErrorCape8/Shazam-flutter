import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../domain/entities/recognition.dart';
import '../models/recognition_dto.dart';

class RecognitionRemoteDataSource {
  RecognitionRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  static final Uri _baseUri = Uri.https('shazam-api.com');
  final http.Client _client;

  Future<RecognitionJob> submitAudio(
    Uint8List audio, {
    required String apiKey,
    String filename = 'sonara-recording.wav',
  }) async {
    _requireKey(apiKey);
    final request =
        http.MultipartRequest('POST', _baseUri.resolve('/api/v2/recognize'))
          ..headers.addAll(_headers(apiKey))
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
    return RecognitionJobDto.fromJson(_decode(response)).job;
  }

  Future<RecognitionOutcome> getResult(
    String uuid, {
    required String apiKey,
  }) async {
    _requireKey(apiKey);
    final encodedUuid = Uri.encodeComponent(uuid);
    final response = await _client
        .get(
          _baseUri.resolve('/api/v2/results/$encodedUuid'),
          headers: _headers(apiKey),
        )
        .timeout(const Duration(seconds: 30));
    return RecognitionOutcomeDto.fromJson(_decode(response)).outcome;
  }

  Map<String, String> _headers(String apiKey) => {
    'Authorization': 'Bearer ${apiKey.trim()}',
    'Accept': 'application/json',
  };

  void _requireKey(String apiKey) {
    if (apiKey.trim().isEmpty) {
      throw const RecognitionException(
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
      throw RecognitionException(
        error,
        statusCode: response.statusCode,
        code: data['code']?.toString(),
      );
    }
    if (decoded is! Map) {
      throw const RecognitionException(
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
