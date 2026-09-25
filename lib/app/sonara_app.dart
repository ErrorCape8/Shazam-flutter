import 'package:flutter/material.dart';

import '../features/recognition/recognition_home.dart';
import 'app_theme.dart';

class SonaraRecognitionApp extends StatelessWidget {
  const SonaraRecognitionApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Feel the Music',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
    home: const RecognitionHome(),
  );
}
