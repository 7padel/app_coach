import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CachedCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Widget? child;
  final Color? backgroundColor;
  final double iconSize;
  final Color progressIndicatorColor;

  const CachedCircleAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.child,
    this.backgroundColor,
    this.iconSize = 14,
    this.progressIndicatorColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    // If imageUrl is empty or null, show child or default person icon
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: child ?? Icon(Icons.person, size: iconSize),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        backgroundImage: imageProvider,
        child: child,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: CircularProgressIndicator(
          strokeWidth: max(1, radius / 10),
          color: progressIndicatorColor,
        ),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: child ?? Icon(Icons.person, size: iconSize),
      ),
    );
  }
}