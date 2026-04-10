
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class PlayersCard extends StatelessWidget {
  final List<String?> imageUrls;
  final String courtNumber;
  final String playerTitle;
  final String courtLabel;
  final VoidCallback? onCourtTap;
  final void Function(int index)? onInviteTap;
  final bool hideEmptySlots;

  const PlayersCard({
    super.key,
    required this.imageUrls,
    this.courtNumber = '1',
    this.playerTitle = 'Players',
    this.courtLabel = 'Court No',
    this.onCourtTap,
    this.onInviteTap,
    this.hideEmptySlots = false,
  });

  int get _extraCount => imageUrls.length > 4 ? imageUrls.length - 3 : 0;

  List<String?> _getFixedImageList() {
    if (imageUrls.length > 4) {
      // Show first 3 + count badge
      return imageUrls.take(3).cast<String?>().toList();
    }
    // Ensure exactly 4 slots
    return List<String?>.generate(
      4,
          (index) => index < imageUrls.length ? imageUrls[index] : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fixedImageUrls = _getFixedImageList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: CachedNetworkImageProvider(
            'https://7padel.s3.ap-south-1.amazonaws.com/documents/75af7a5e-c2a8-40b6-931d-d03a84085a49.png',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Overlay gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.3),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Player section
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  playerTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(fixedImageUrls.length, (index) {
                      final url = fixedImageUrls[index];
                      final hasImage = url != null && url.isNotEmpty;
                      if (url == null && hideEmptySlots) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: hasImage
                            ? CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          backgroundImage: CachedNetworkImageProvider(url),
                        )
                            : CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.person, size: 28, color: Color(0xFF1D3916)),
                        ),
                    );
                  }),
                    // Show "+N" badge when more than 4 players
                    if (_extraCount > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Text('+$_extraCount', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1D3916))),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // Bottom court section
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: onCourtTap,
              child: Container(
                height: 60,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF3E6B2B),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Text(
                      courtNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



