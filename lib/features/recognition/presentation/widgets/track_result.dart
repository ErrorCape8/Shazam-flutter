import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/app_theme.dart';
import '../../domain/entities/recognition.dart';
import 'ui_bits.dart';

class TrackResult extends StatelessWidget {
  const TrackResult({required this.track, super.key});

  final RecognitionTrack track;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    elevation: 0,
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: AppColors.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Artwork(track.artwork),
              const SizedBox(width: 19),
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
                        fontSize: 20,
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
            const SizedBox(height: 14),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                if (track.album.isNotEmpty) MetadataTag(track.album),
                if (track.genre.isNotEmpty) MetadataTag(track.genre),
                if (track.releaseDate.isNotEmpty)
                  MetadataTag(track.releaseDate),
              ],
            ),
          ],
          if (_links.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 13),
            const Center(
              child: Text(
                'Escuchar en plataformas',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ),
            const SizedBox(height: 11),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final link in _links)
                  _ServiceLink(label: link.$1, url: link.$2),
              ],
            ),
          ],
        ],
      ),
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
      width: 84,
      height: 84,
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
        width: 84,
        height: 84,
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
      minimumSize: const Size(140, 40),
      foregroundColor: AppColors.text,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
