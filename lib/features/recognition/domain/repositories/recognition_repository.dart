import 'dart:typed_data';

import '../entities/recognition.dart';

abstract interface class RecognitionRepository {
  Future<RecognitionJob> submitAudio(Uint8List audio, {required String apiKey});

  Future<RecognitionOutcome> getResult(String uuid, {required String apiKey});
}
