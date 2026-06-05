import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/skins.dart';
import '../services/rewards_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/game_juice.dart';
import 'daily_reward_screen.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _rewards = RewardsService();
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _checkDaily();
  }

  Future<void> _checkDaily() async {
    final r = await _rewards.claimDailyIfAvailable();
    if (r.reward > 0 && mounted) {
      await Navigator.push(context, MaterialPageRoute(
          builder: (_) => DailyRewardScreen(day: r.day, reward: r.reward)));
    }
    SkinStore.instance.reload();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _highScore = p.getInt('snakeHigh') ?? 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skin = activeSkinSnake();
    return Scaffold(
      bottomNavigationBar: const BannerAdWidget(),
      body: PremiumBackground(
        colors: skin.bg,
        bokeh: skin.bokeh,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.settings, color: skin.accent),
                      onPressed: () async {
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()));
                      },
                    ),
                    Row(
                      children: [
                        PressableScale(
                          onTap: () async {
                            await Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const ShopScreen()));
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: skin.accent),
                            ),
                            child: Icon(Icons.palette_rounded,
                                color: skin.accent, size: 22),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ListenableBuilder(
                          listenable: SkinStore.instance,
                          builder: (context, _) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFFD740)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.monetization_on,
                                    color: Color(0xFFFFD740), size: 20),
                                const SizedBox(width: 6),
                                Text('${SkinStore.instance.coins}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('WORM RUN',
                      style: TextStyle(
                          color: skin.accent,
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 5,
                          shadows: [Shadow(color: skin.accent.withValues(alpha: 0.6), blurRadius: 22)])),
                ),
                const Text('CLASSIC',
                    style: TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                        letterSpacing: 8,
                        fontWeight: FontWeight.w300)),
                const SizedBox(height: 32),
                SizedBox(
                  height: 60,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < 6; i++)
                          Container(
                            width: 30,
                            height: 30,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: i == 5 ? skin.head : skin.body,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [BoxShadow(color: skin.body.withValues(alpha: 0.4), blurRadius: 6)],
                            ),
                          ),
                        const SizedBox(width: 16),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: skin.food,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: skin.food.withValues(alpha: 0.5), blurRadius: 8)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: skin.accent.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      const Text('TOP SCORE',
                          style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: 2)),
                      const SizedBox(height: 6),
                      Text('$_highScore',
                          style: TextStyle(
                              color: skin.accent,
                              fontSize: 40,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: skin.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 12,
                      shadowColor: skin.accent,
                    ),
                    onPressed: () async {
                      await Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const GameScreen()));
                      SkinStore.instance.reload();
                      _load();
                    },
                    child: const Text('JOC NOU'),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
