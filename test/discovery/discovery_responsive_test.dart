import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/discovery/presentation/components/discovery_tab_bar.dart';
import 'package:local_markerplace/discovery/presentation/discovery_home_view.dart';
import 'package:local_markerplace/discovery/presentation/explore_zones_view.dart';
import 'package:local_markerplace/discovery/presentation/location_page.dart';
import 'package:local_markerplace/discovery/presentation/locality_page.dart';
import 'package:local_markerplace/discovery/presentation/search_page.dart';
import 'package:local_markerplace/discovery/presentation/zone_detail_page.dart';
import 'package:local_markerplace/discovery/repository/discovery_repository.dart';

/// One handset the flow has to fit.
class Device {
  const Device(this.name, this.size);

  final String name;
  final Size size;

  @override
  String toString() => '$name (${size.width.toInt()}x${size.height.toInt()})';
}

/// The span of phones worth caring about: the narrowest screen still in the
/// wild through to the widest current handset. The design is drawn at 390,
/// which sits in the middle.
const devices = <Device>[
  Device('iPhone SE 1st gen', Size(320, 568)),
  Device('Android baseline', Size(360, 640)),
  Device('iPhone SE 3rd gen', Size(375, 667)),
  Device('iPhone 14', Size(390, 844)),
  Device('Pixel 7', Size(412, 915)),
  Device('iPhone 14 Plus', Size(428, 926)),
];

Future<void> loadFonts() async {
  for (final path in const [
    'assets/fonts/PlusJakartaSans-Medium.ttf',
    'assets/fonts/PlusJakartaSans-Bold.ttf',
    'assets/fonts/PlusJakartaSans-ExtraBold.ttf',
  ]) {
    final loader = FontLoader('Plus Jakarta Sans')
      ..addFont(File(path).readAsBytes().then((b) => ByteData.view(b.buffer)));
    await loader.load();
  }
}

void main() {
  const repository = DiscoveryRepository();
  final zone = repository.zones().firstWhere((zone) => zone.isLive);

  setUpAll(loadFonts);

  /// Every screen in the flow, built fresh so a test can pump one per size.
  final screens = <String, Widget Function()>{
    '01 location': () => const LocationPage(),
    '02 home': () => Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: DiscoveryHomeView(
          localityName: 'Panchsheel Wellington',
          onChangeLocality: () {},
          onSearch: () {},
          onSeeAllCategories: () {},
          onSeeAllProviders: () {},
        ),
      ),
      bottomNavigationBar: DiscoveryTabBar(
        current: DiscoveryTab.home,
        onSelect: (_) {},
      ),
    ),
    '03 explore': () => Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(bottom: false, child: ExploreZonesView(onZoneTap: (_) {})),
      bottomNavigationBar: DiscoveryTabBar(
        current: DiscoveryTab.explore,
        onSelect: (_) {},
      ),
    ),
    '04 zone detail': () => ZoneDetailPage(zone: zone, onLocalityTap: (_) {}),
    '05 locality': () => const LocalityPage(localityName: 'Ajnara Gen X'),
    '06 search': () => const SearchPage(
      localityName: 'Panchsheel Wellington',
      initialQuery: 'electrician',
    ),
  };

  Future<void> pumpAt(
    WidgetTester tester,
    Device device,
    Widget screen, {
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = device.size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: screen,
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final device in devices) {
    group('$device', () {
      for (final entry in screens.entries) {
        testWidgets('${entry.key} lays out without overflowing', (
          tester,
        ) async {
          await pumpAt(tester, device, entry.value());
          expect(
            tester.takeException(),
            isNull,
            reason: '${entry.key} on $device',
          );
        });
      }
    });
  }

  group('large text', () {
    // The accessibility step most users actually reach for.
    const scale = 1.3;
    for (final entry in screens.entries) {
      testWidgets('${entry.key} survives $scale text on the narrowest phone', (
        tester,
      ) async {
        await pumpAt(tester, devices.first, entry.value(), textScale: scale);
        expect(tester.takeException(), isNull, reason: entry.key);
      });
    }
  });

  testWidgets('the whole flow can be walked on the narrowest phone', (
    tester,
  ) async {
    await pumpAt(tester, devices.first, const LocationPage());
    expect(find.text('Where do you need help?'), findsOneWidget);
    expect(find.text('Ajnara Gen X'), findsOneWidget);
  });
}
