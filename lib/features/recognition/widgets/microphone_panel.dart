import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class MicrophonePanel extends StatelessWidget {
  const MicrophonePanel({
    required this.recording,
    required this.busy,
    required this.seconds,
    required this.onTap,
    super.key,
  });

  final bool recording;
  final bool busy;
  final int seconds;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final time = '00:${seconds.toString().padLeft(2, '0')}';
    return Container(
      constraints: const BoxConstraints(minHeight: 220),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  recording ? 'GRABANDO' : 'IDENTIFICACION POR MICROFONO',
                  style: const TextStyle(
                    color: Color(0xFFFFE6A0),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.25,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  recording ? time : 'Que esta sonando?',
                  style: const TextStyle(
                    fontSize: 25,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  busy && !recording
                      ? 'Procesando el resultado...'
                      : 'Graba un fragmento y envialo para reconocerlo.',
                  style: const TextStyle(
                    color: Color(0xFFFFE6A0),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: busy ? null : onTap,
                  icon: Icon(
                    recording
                        ? Icons.graphic_eq_rounded
                        : Icons.mic_none_rounded,
                    size: 18,
                  ),
                  label: Text(
                    recording ? 'Grabando $time' : 'Grabar 8 segundos',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: const Color(0xFF17120A),
                    disabledBackgroundColor: const Color(0xFFD8CF00),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 94,
            height: 94,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold),
            ),
            child: const Icon(
              Icons.graphic_eq_rounded,
              size: 42,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
