import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import 'ui_bits.dart';

class RecognitionHeader extends StatelessWidget {
  const RecognitionHeader({
    required this.wide,
    required this.connected,
    required this.onSettings,
    super.key,
  });

  final bool wide;
  final bool connected;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => Container(
    height: 58,
    padding: EdgeInsets.symmetric(horizontal: wide ? 36 : 20),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: Row(
      children: [
        if (!wide) ...[
          const Icon(Icons.graphic_eq_rounded, color: AppColors.red),
          const SizedBox(width: 9),
          const Text(
            'Feel the Music',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ],
        const Spacer(),
        Text(
          connected ? 'API CONFIGURADA' : 'FALTA CONFIGURAR',
          style: TextStyle(
            color: connected ? AppColors.gold : AppColors.muted,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: onSettings,
          tooltip: 'Ajustes',
          icon: const Icon(Icons.tune_rounded),
          style: IconButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    ),
  );
}

class RecognitionRail extends StatelessWidget {
  const RecognitionRail({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => Container(
    width: 195,
    padding: const EdgeInsets.fromLTRB(20, 28, 16, 20),
    decoration: const BoxDecoration(
      color: Color(0xFF160E0D),
      border: Border(right: BorderSide(color: AppColors.border)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.graphic_eq_rounded),
            ),
            const SizedBox(width: 11),
            const Text(
              'Feel the Music',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 52),
        const Padding(
          padding: EdgeInsets.only(left: 12, bottom: 12),
          child: Eyebrow('MUSICA'),
        ),
        _RailItem(
          icon: Icons.radar_rounded,
          label: 'Reconocer',
          selected: selected == 0,
          onTap: () => onSelect(0),
        ),
        _RailItem(
          icon: Icons.tune_rounded,
          label: 'Ajustes',
          selected: selected == 1,
          onTap: () => onSelect(1),
        ),
        const Spacer(),
        const Divider(color: AppColors.border),
        const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            'Identificacion al instante.',
            style: TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ),
      ],
    ),
  );
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: ListTile(
      onTap: onTap,
      dense: true,
      selected: selected,
      selectedTileColor: const Color(0xFF321317),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      leading: Icon(
        icon,
        size: 19,
        color: selected ? AppColors.gold : AppColors.muted,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.muted,
          fontSize: 13,
        ),
      ),
    ),
  );
}

class RecognitionBottomNavigation extends StatelessWidget {
  const RecognitionBottomNavigation({
    required this.current,
    required this.onSelect,
    super.key,
  });

  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => NavigationBar(
    height: 66,
    selectedIndex: current,
    onDestinationSelected: onSelect,
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.radar_rounded),
        label: 'Reconocer',
      ),
      NavigationDestination(icon: Icon(Icons.tune_rounded), label: 'Ajustes'),
    ],
  );
}
