import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLauncher {
  static Future<void> openMap({
    required double latitude,
    required double longitude,
  }) async {
    final googleMapsUri = Platform.isIOS
        ? Uri.parse('comgooglemaps://?q=$latitude,$longitude')
        : Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude');

    final appleMapsUri = Uri.parse('http://maps.apple.com/?q=$latitude,$longitude');

    final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    try {
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri);
      } else if (Platform.isIOS && await canLaunchUrl(appleMapsUri)) {
        await launchUrl(appleMapsUri);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('⚠️ Could not launch any map provider.');
      }
    } catch (e) {
      debugPrint('❌ Map launch error: $e');
      // Always fallback to web
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    }
  }
}
