import '../../domain/entities/recognition.dart';
import '../../domain/repositories/recognition_settings_repository.dart';
import '../datasources/recognition_settings_local_data_source.dart';
import '../models/recognition_dto.dart';

class RecognitionSettingsRepositoryImpl
    implements RecognitionSettingsRepository {
  const RecognitionSettingsRepositoryImpl(this._localDataSource);

  final RecognitionSettingsLocalDataSource _localDataSource;

  @override
  Future<String> loadApiKey() => _localDataSource.loadApiKey();

  @override
  Future<void> saveApiKey(String apiKey) => _localDataSource.saveApiKey(apiKey);

  @override
  Future<RecognitionTrack?> loadLastTrack() async =>
      (await _localDataSource.loadLastTrack())?.track;

  @override
  Future<void> saveLastTrack(RecognitionTrack track) =>
      _localDataSource.saveLastTrack(RecognitionTrackDto(track));
}
