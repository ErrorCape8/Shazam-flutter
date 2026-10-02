import 'package:flutter/material.dart';

import '../features/recognition/data/datasources/recognition_remote_data_source.dart';
import '../features/recognition/data/datasources/recognition_settings_local_data_source.dart';
import '../features/recognition/data/repositories/recognition_repository_impl.dart';
import '../features/recognition/data/repositories/recognition_settings_repository_impl.dart';
import '../features/recognition/domain/usecases/recognize_audio.dart';
import '../features/recognition/presentation/recognition_home.dart';
import 'app_theme.dart';

class SonaraRecognitionApp extends StatelessWidget {
  const SonaraRecognitionApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Feel the Music',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
    home: RecognitionHome(
      recognizeAudio: RecognizeAudio(
        RecognitionRepositoryImpl(RecognitionRemoteDataSource()),
      ),
      settingsRepository: RecognitionSettingsRepositoryImpl(
        RecognitionSettingsLocalDataSource(),
      ),
    ),
  );
}
