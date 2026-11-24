import '../lib/views/session_detail_page.dart';
import '../lib/models/coaching_session_model.dart';
import '../lib/widgets/button.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/core/theme/phase2_theme.dart';

Future<void> prepare(
  WidgetTester tester,
  Widget child, {
  double scale = 1.0,
  double width = 390,
}) async {
  await tester.binding.setSurfaceSize(Size(width, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(fontFamily: 'HelveticaNeue'),
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 844),
          textScaler: TextScaler.linear(scale),
        ),
        child: Phase2Surface(
          child: RepaintBoundary(key: const ValueKey('capture'), child: child),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> screenshot(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('capture')),
  );
  final image = await boundary.toImage(pixelRatio: 2);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final output = Directory('${Directory.systemTemp.path}/7padel-phase2-review');
  output.createSync(recursive: true);
  File(
    '${output.path}/$name.png',
  ).writeAsBytesSync(bytes!.buffer.asUint8List());
  image.dispose();
}

Future<void> loadFont() async {
  final font = FontLoader('HelveticaNeue')
    ..addFont(rootBundle.load('fonts/HelveticaNeueMedium.otf'));
  await font.load();
  final config =
      jsonDecode(File('.dart_tool/package_config.json').readAsStringSync())
          as Map<String, dynamic>;
  final packages = config['packages'] as List;
  final flutter = packages.firstWhere((p) => p['name'] == 'flutter') as Map;
  final sdk =
      Directory.fromUri(Uri.parse(flutter['rootUri'] as String)).parent.parent;
  final file = File(
    '${sdk.path}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  final icons = FontLoader('MaterialIcons')
    ..addFont(file.readAsBytes().then((bytes) => ByteData.sublistView(bytes)));
  await icons.load();
}

void main() {
  setUpAll(loadFont);
  CoachingSessionModel session() => CoachingSessionModel(
    id: 'review',
    coachingId: 'review',
    sessionDate: '2026-11-24',
    startTime: '18:00',
    endTime: '19:00',
    status: 'scheduled',
    registeredCount: 6,
    arenaName: '7Padel · Chennai',
    coaching: CoachingInfo(
      id: 'review',
      title: 'Build your baseline',
      coachingType: 'group',
      maxPlayers: 12,
    ),
    registeredPlayers: [
      SessionPlayer(playerId: '1', name: 'Arjun Kumar'),
      SessionPlayer(playerId: '2', name: 'Priya Raman'),
    ],
  );
  testWidgets('Session details remain readable on narrow displays', (
    tester,
  ) async {
    await prepare(
      tester,
      SessionDetailPage(session: session()),
      width: 320,
      scale: 1.5,
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Build your baseline'), findsOneWidget);
  });
  testWidgets('Coach busy action cannot be submitted twice', (tester) async {
    await prepare(
      tester,
      Scaffold(body: Button(text: 'Save', isLoading: true, onPressed: () {})),
    );
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
  });
  testWidgets('Coach visual review', (tester) async {
    await prepare(tester, SessionDetailPage(session: session()));
    await tester.runAsync(() => screenshot(tester, 'coach'));
  });
}
