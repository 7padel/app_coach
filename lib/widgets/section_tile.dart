import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// SectionTile(
// title: 'Robert',
// description: '+91 8870714718',
// trailingIcon: const Icon(Icons.person, color: Color(0xFF1D3916)),
// );

class SectionTile extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? trailingIcon;
  final bool showDivider;

  const SectionTile({
    super.key,
    required this.title,
    this.description,
    this.trailingIcon,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User Info (Name and Phone)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D3916),
                      ),
                    ),
                    if (description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          description!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Optional trailing icon
              if (trailingIcon != null)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7E86F),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: trailingIcon,
                ),
            ],
          ),
        ),

        // Optional Divider
        if (showDivider)
          const Divider(
            color: Color(0xFFE0E0E0),
            height: 1,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}
