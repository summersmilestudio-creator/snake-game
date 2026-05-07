import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/rewards_service.dart';
import 'daily_reward_screen.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _rewards = RewardsService();
  int _coins = 0;
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
    _load();
  }

  Future<void> _load() async {
    final c = await _rewards.getCoins();
    final p = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _coins = c;
        _highScore = p.getInt('snakeHigh') ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A1628), Color(0xFF1B2C40)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.settings, color: Color(0xFF4CAF50)),
                      onPressed: () async {
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()));
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFD740)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on, color: Color(0xFFFFD740), size: 20),
                          const SizedBox(width: 6),
                          Text('$_coins',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Text('SNAKE',
                    style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8)),
                const Text('CLASSIC',
                    style: TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                        letterSpacing: 8,
                        fontWeight: FontWeight.w300)),
                const SizedBox(height: 32),
                // Snake preview
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
                              color: i == 5 ? const Color(0xFF66BB6A) : const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [BoxShadow(color: Color(0x444CAF50), blurRadius: 6)],
                            ),
                          ),
                        const SizedBox(width: 16),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF5252),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Color(0x66FF5252), blurRadius: 8)],
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
                    border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      const Text('TOP SCORE',
                          style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: 2)),
                      const SizedBox(height: 6),
                      Text('$_highScore',
                          style: const TextStyle(
                              color: Color(0xFF4CAF50),
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
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 12,
                      shadowColor: const Color(0xFF4CAF50),
                    ),
                    onPressed: () async {
                      await Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const GameScreen()));
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
