import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_theme.dart';
import '../../../models/recognition.dart';
import 'ui_bits.dart';

class TrackResult extends StatelessWidget {
  const TrackResult({required this.track, super.key});

  final RecognitionTrack track;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Artwork(track.artwork),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('CANCION IDENTIFICADA'),
                  const SizedBox(height: 7),
                  Text(
                    track.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (track.album.isNotEmpty ||
            track.genre.isNotEmpty ||
            track.releaseDate.isNotEmpty) ...[
          const SizedBox(height: 15),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              if (track.album.isNotEmpty) MetadataTag(track.album),
              if (track.genre.isNotEmpty) MetadataTag(track.genre),
              if (track.releaseDate.isNotEmpty) MetadataTag(track.releaseDate),
            ],
          ),
        ],
        if (_links.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 11),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _links
                .map((entry) => _ServiceLink(label: entry.$1, url: entry.$2))
                .toList(),
          ),
        ],
      ],
    ),
  );

  List<(String, String)> get _links => [
    ('Spotify', track.spotifyUrl),
    ('Deezer', track.deezerUrl),
    ('Apple Music', track.appleMusicUrl),
    ('Shazam', track.shazamUrl),
  ].where((entry) => entry.$2.isNotEmpty).toList();
}

class _Artwork extends StatelessWidget {
  const _Artwork(this.url);

  final String url;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFF35231C),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.music_note_rounded, color: AppColors.muted),
    );
    if (url.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        url,
        width: 76,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}

class _ServiceLink extends StatelessWidget {
  const _ServiceLink({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () async {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    },
    icon: Icon(switch (label) {
      'Spotify' => Icons.play_circle_outline_rounded,
      'Deezer' => Icons.graphic_eq_rounded,
      'Apple Music' => Icons.music_note_rounded,
      _ => Icons.open_in_new_rounded,
    }, size: 17),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.text,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
    ),
  );
}
