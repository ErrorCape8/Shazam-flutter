import '../entities/recognition.dart';

abstract interface class RecognitionSettingsRepository {
  Future<String> loadApiKey();

  Future<void> saveApiKey(String apiKey);

  Future<RecognitionTrack?> loadLastTrack();

  Future<void> saveLastTrack(RecognitionTrack track);
}
