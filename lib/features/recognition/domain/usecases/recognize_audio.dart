import 'dart:typed_data';

import '../entities/recognition.dart';
import '../repositories/recognition_repository.dart';

class RecognizeAudio {
  const RecognizeAudio(this._repository);

  final RecognitionRepository _repository;

  Future<RecognitionOutcome> call(
    Uint8List audio, {
    required String apiKey,
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 3),
    void Function(String uuid)? onSubmitted,
    void Function()? onPoll,
  }) async {
    final job = await _repository.submitAudio(audio, apiKey: apiKey);
    onSubmitted?.call(job.uuid);
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < timeout) {
      final result = await _repository.getResult(job.uuid, apiKey: apiKey);
      if (result.status != 'processing') return result;
      onPoll?.call();
      await Future<void>.delayed(interval);
    }
    throw const RecognitionException(
      'La identificación sigue procesándose. Inténtalo de nuevo en un momento.',
    );
  }
}
