import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sonara/services/recognition_api.dart';

void main() {
  test('uploads audio with Bearer auth and parses the async UUID', () async {
    late http.BaseRequest captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode({
          'apiVersion': 2,
          'status': 'processing',
          'uuid': 'job-123',
          'resultsUrl': '/api/v2/results/job-123',
        }),
        202,
      );
    });
    final api = RecognitionApi('test-token', client: client);

    final job = await api.recognizeAudio(Uint8List.fromList([1, 2, 3]));

    expect(captured.method, 'POST');
    expect(captured.url.toString(), 'https://shazam-api.com/api/v2/recognize');
    expect(captured.headers['authorization'], 'Bearer test-token');
    expect(
      captured.headers['content-type'],
      startsWith('multipart/form-data; boundary='),
    );
    expect((captured as http.Request).body, contains('name="file"'));
    expect((captured as http.Request).body, contains('sonara-recording.wav'));
    expect(job.uuid, 'job-123');
    expect(job.resultsUrl, '/api/v2/results/job-123');
    client.close();
  });

  test(
    'polls until the result includes track metadata and streaming links',
    () async {
      var polls = 0;
      final client = MockClient((request) async {
        expect(request.url.path, '/api/v2/results/job-123');
        expect(request.headers['authorization'], 'Bearer test-token');
        polls++;
        if (polls == 1) {
          return http.Response(jsonEncode({'status': 'processing'}), 200);
        }
        return http.Response(
          jsonEncode({
            'status': 'success',
            'count': 1,
            'results': [
              {
                'title': 'Song title',
                'artist': 'Artist name',
                'album': 'Single',
                'releaseDate': '2025-01-01',
                'artwork': 'https://example.com/art.jpg',
                'links': {
                  'spotify': 'https://open.spotify.com/track/example',
                  'deezer': 'https://www.deezer.com/track/example',
                },
              },
            ],
          }),
          200,
        );
      });
      final api = RecognitionApi('test-token', client: client);

      final result = await api.waitForResult(
        'job-123',
        interval: Duration.zero,
        timeout: const Duration(seconds: 2),
      );

      expect(polls, 2);
      expect(result.status, 'success');
      expect(result.tracks.single.title, 'Song title');
      expect(result.tracks.single.artist, 'Artist name');
      expect(
        result.tracks.single.spotifyUrl,
        'https://open.spotify.com/track/example',
      );
      expect(
        result.tracks.single.deezerUrl,
        'https://www.deezer.com/track/example',
      );
      client.close();
    },
  );
}
