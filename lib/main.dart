import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'services/notification_service.dart';
import 'services/review_service.dart';
import 'screens/home_screen.dart';
import 'services/ads_service.dart';
import 'services/purchase_service.dart';
import 'game/skins.dart';
import 'widgets/remove_ads_offer.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PurchaseService.instance.initialize();
  await SkinStore.instance.init();
  await AdsService.instance.initialize();
  ReviewService.instance.registerLaunch();
  NotificationService.instance.scheduleEvery6Hours(title: 'Worm Run Classic', body: 'Mâncă mere și crește! 🐍');
  runApp(const SnakeApp());
}

class SnakeApp extends StatefulWidget {
  const SnakeApp({super.key});

  @override
  State<SnakeApp> createState() => _SnakeAppState();
}

class _SnakeAppState extends State<SnakeApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Show the upsell right after a full-screen ad (App Open / interstitial) closes.
    AdsService.instance.adClosedTick.addListener(_onAdClosed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AdsService.instance.adClosedTick.removeListener(_onAdClosed);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AdsService.instance.showAppOpenIfReady();
    }
  }

  void _onAdClosed() {
    RemoveAdsOffer.maybeShow(navigatorKey.currentContext);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worm Run Classic',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A1628),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.dark,
        ),
      ),
      home: UpgradeAlert(child: const HomeScreen()),
    );
  }
}
