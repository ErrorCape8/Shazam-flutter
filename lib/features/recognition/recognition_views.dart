import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../models/recognition.dart';
import 'widgets/microphone_panel.dart';
import 'widgets/recognition_status.dart';
import 'widgets/track_result.dart';
import 'widgets/ui_bits.dart';

class DiscoverView extends StatelessWidget {
  const DiscoverView({
    required this.wide,
    required this.busy,
    required this.recording,
    required this.secondsLeft,
    required this.statusMessage,
    required this.jobId,
    required this.outcome,
    required this.onRecord,
    super.key,
  });

  final bool wide;
  final bool busy;
  final bool recording;
  final int secondsLeft;
  final String statusMessage;
  final String jobId;
  final RecognitionOutcome? outcome;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) => ContentFrame(
    wide: wide,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(0, 32, 0, 40),
      children: [
        const Eyebrow('IDENTIFICACION DE AUDIO - API V2'),
        const SizedBox(height: 10),
        Text(
          'Encuentra el sonido.',
          style: TextStyle(
            fontSize: wide ? 36 : 30,
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Escucha lo que suena cerca y deja que la musica lo encuentre.',
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 25),
        MicrophonePanel(
          recording: recording,
          busy: busy,
          seconds: secondsLeft,
          onTap: onRecord,
        ),
        const SizedBox(height: 24),
        if (busy)
          RecognitionProgress(message: statusMessage, uuid: jobId)
        else if (outcome != null &&
            outcome!.status == 'success' &&
            outcome!.tracks.isNotEmpty)
          for (final track in outcome!.tracks) TrackResult(track: track)
        else if (statusMessage.isNotEmpty)
          RecognitionStatus(
            message: statusMessage,
            failed: outcome?.status == 'failed',
          )
        else
          const QuietNote('Las canciones identificadas apareceran aqui.'),
      ],
    ),
  );
}

class SettingsView extends StatelessWidget {
  const SettingsView({
    required this.wide,
    required this.controller,
    required this.hasKey,
    required this.onSave,
    super.key,
  });

  final bool wide;
  final TextEditingController controller;
  final bool hasKey;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => ContentFrame(
    wide: wide,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(0, 32, 0, 40),
      children: [
        const Eyebrow('CUENTA API'),
        const SizedBox(height: 10),
        const Text(
          'Ajustes',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Configura la clave de shazam-api.com.',
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 26),
        const SectionLabel('API KEY', 'BEARER TOKEN'),
        const SizedBox(height: 11),
        TextField(
          controller: controller,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: const InputDecoration(
            hintText: 'Pega tu clave de API',
            prefixIcon: Icon(Icons.key_rounded),
          ),
        ),
        const SizedBox(height: 13),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save_outlined, size: 17),
            label: Text(hasKey ? 'Actualizar clave' : 'Guardar clave'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ),
        const SizedBox(height: 23),
        const InfoBlock(
          icon: Icons.shield_outlined,
          text: 'La clave se almacena localmente en este dispositivo. Para una app publicada, ponla en un backend para no exponerla en el cliente.',
        ),
        const SizedBox(height: 25),
        const SectionLabel('FLUJO DE RECONOCIMIENTO', 'V2'),
        const SizedBox(height: 10),
        const EndpointInfo(
          '/api/v2/recognize',
          'Envia el archivo de audio y recibe un UUID.',
        ),
        const EndpointInfo(
          '/api/v2/results/{uuid}',
          'Consulta hasta que termine el analisis.',
        ),
        const EndpointInfo(
          'Authorization: Bearer',
          'Autenticacion de esta API.',
        ),
      ],
    ),
  );
}
