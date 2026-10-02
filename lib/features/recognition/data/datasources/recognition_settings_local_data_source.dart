import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recognition_dto.dart';

class RecognitionSettingsLocalDataSource {
  static const _apiKey = 'shazam_api_key';
  static const _lastTrack = 'last_recognized_track';

  Future<String> loadApiKey() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_apiKey) ?? '';
  }

  Future<void> saveApiKey(String apiKey) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_apiKey, apiKey);
  }

  Future<RecognitionTrackDto?> loadLastTrack() async {
    final preferences = await SharedPreferences.getInstance();
    final savedTrack = preferences.getString(_lastTrack);
    if (savedTrack == null) return null;
    try {
      final decoded = jsonDecode(savedTrack);
      if (decoded is Map) {
        return RecognitionTrackDto.fromJson(Map<String, dynamic>.from(decoded));
      }
    } on FormatException {
      await preferences.remove(_lastTrack);
    }
    return null;
  }

  Future<void> saveLastTrack(RecognitionTrackDto track) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_lastTrack, jsonEncode(track.toJson()));
  }
}
