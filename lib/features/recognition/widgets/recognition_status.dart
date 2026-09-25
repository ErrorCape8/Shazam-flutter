import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class RecognitionProgress extends StatelessWidget {
  const RecognitionProgress({
    required this.message,
    required this.uuid,
    super.key,
  });

  final String message;
  final String uuid;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.red,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(color: AppColors.text, fontSize: 13),
              ),
              if (uuid.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'ID $uuid',
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class RecognitionStatus extends StatelessWidget {
  const RecognitionStatus({
    required this.message,
    required this.failed,
    super.key,
  });

  final String message;
  final bool failed;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(
          failed ? Icons.error_outline_rounded : Icons.info_outline_rounded,
          color: failed ? const Color(0xFFFF7B6B) : AppColors.gold,
          size: 20,
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ),
      ],
    ),
  );
}

class QuietNote extends StatelessWidget {
  const QuietNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 15),
    child: Text(
      text,
      style: const TextStyle(color: AppColors.muted, fontSize: 12),
    ),
  );
}
