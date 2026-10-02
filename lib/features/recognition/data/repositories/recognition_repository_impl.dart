import 'dart:typed_data';

import '../../domain/entities/recognition.dart';
import '../../domain/repositories/recognition_repository.dart';
import '../datasources/recognition_remote_data_source.dart';

class RecognitionRepositoryImpl implements RecognitionRepository {
  const RecognitionRepositoryImpl(this._remoteDataSource);

  final RecognitionRemoteDataSource _remoteDataSource;

  @override
  Future<RecognitionJob> submitAudio(
    Uint8List audio, {
    required String apiKey,
  }) => _remoteDataSource.submitAudio(audio, apiKey: apiKey);

  @override
  Future<RecognitionOutcome> getResult(String uuid, {required String apiKey}) =>
      _remoteDataSource.getResult(uuid, apiKey: apiKey);
}
