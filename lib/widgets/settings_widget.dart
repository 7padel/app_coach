import 'package:flutter/material.dart';

class SettingsTile {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  SettingsTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
  });
}

class SettingsSection extends StatelessWidget {
  final String? sectionTitle;
  final List<SettingsTile> tiles;
  final bool showSectionTitle;

  const SettingsSection({
    super.key,
    this.sectionTitle,
    required this.tiles,
    this.showSectionTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSectionTitle && sectionTitle != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              sectionTitle!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D3916),
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: tiles.map((tile) {
              final hasSubtitle = tile.subtitle != null;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4), // 🔹 Consistent spacing
                child: ListTile(
                  onTap: tile.onTap,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFDCEAC8),
                    radius: 24,
                    child: Icon(
                      tile.icon,
                      color: const Color(0xFF1D3916),
                      size: 24,
                    ),
                  ),
                  title: Text(
                    tile.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: hasSubtitle
                      ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      tile.subtitle!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  )
                      : null,
                  trailing: const Icon(Icons.chevron_right, size: 24),
                  horizontalTitleGap: 12,
                  dense: false,
                  minVerticalPadding: 0, // to ensure consistent vertical alignment
                ),
              );
            }).toList(),
          ),

        ),
      ],
    );
  }
}
