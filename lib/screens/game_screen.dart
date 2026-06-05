import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../game/skins.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/game_juice.dart';
import '../services/ads_service.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int kCols = 18;
const int kRows = 24;

enum Dir { up, down, left, right }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<Point<int>> _snake;
  late Point<int> _food;
  Dir _dir = Dir.right;
  Dir _nextDir = Dir.right;
  Timer? _timer;
  int _score = 0;
  int _high = 0;
  int _lastEarned = 0;
  bool _running = false;
  bool _gameOver = false;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _resetState();
    _load();
    // Auto-start when entering from home screen
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() => _high = p.getInt('snakeHigh') ?? 0);
  }

  Future<void> _saveHigh() async {
    if (_score > _high) {
      _high = _score;
      final p = await SharedPreferences.getInstance();
      await p.setInt('snakeHigh', _high);
    }
  }

  void _resetState() {
    _snake = [
      const Point(8, 12),
      const Point(7, 12),
      const Point(6, 12),
    ];
    _food = _placeFood();
    _dir = Dir.right;
    _nextDir = Dir.right;
    _score = 0;
    _gameOver = false;
  }

  Point<int> _placeFood() {
    while (true) {
      final p = Point(_rng.nextInt(kCols), _rng.nextInt(kRows));
      if (!_snake.contains(p)) return p;
    }
  }

  void _start() {
    if (_running) return;
    setState(() {
      _resetState();
      _running = true;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 150), (_) => _tick());
  }

  // Continuare după Game Over cu reclamă recompensată. Păstrează scorul,
  // respawnează șarpele la centru.
  void _continueAfterAd() {
    setState(() {
      _snake = [
        const Point(8, 12),
        const Point(7, 12),
        const Point(6, 12),
      ];
      _food = _placeFood();
      _dir = Dir.right;
      _nextDir = Dir.right;
      _gameOver = false;
      _running = true;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 150), (_) => _tick());
  }

  bool _rewardedBusy = false;

  Future<void> _onRewardedContinue() async {
    if (_rewardedBusy) return;
    setState(() => _rewardedBusy = true);
    final earned = await AdsService.instance.showRewarded();
    if (!mounted) return;
    setState(() => _rewardedBusy = false);
    if (earned) {
      _continueAfterAd();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reclama nu e disponibilă acum.')),
      );
    }
  }

  void _tick() {
    _dir = _nextDir;
    final head = _snake.first;
    Point<int> newHead;
    switch (_dir) {
      case Dir.up: newHead = Point(head.x, head.y - 1); break;
      case Dir.down: newHead = Point(head.x, head.y + 1); break;
      case Dir.left: newHead = Point(head.x - 1, head.y); break;
      case Dir.right: newHead = Point(head.x + 1, head.y); break;
    }
    if (newHead.x < 0 || newHead.x >= kCols || newHead.y < 0 || newHead.y >= kRows ||
        _snake.contains(newHead)) {
      _endGame();
      return;
    }
    setState(() {
      _snake.insert(0, newHead);
      if (newHead == _food) {
        _score += 10;
        _food = _placeFood();
        HapticFeedback.lightImpact();
      } else {
        _snake.removeLast();
      }
    });
  }

  void _endGame() {
    _timer?.cancel();
    _running = false;
    _saveHigh();
    _lastEarned = (_score ~/ 20).clamp(0, 999);
    if (_lastEarned > 0) SkinStore.instance.addCoins(_lastEarned);
    setState(() => _gameOver = true);
    HapticFeedback.heavyImpact();
    AdsService.instance.maybeShowInterstitial();
  }

  void _changeDir(Dir d) {
    // No 180-degree turn
    if ((_dir == Dir.up && d == Dir.down) ||
        (_dir == Dir.down && d == Dir.up) ||
        (_dir == Dir.left && d == Dir.right) ||
        (_dir == Dir.right && d == Dir.left)) return;
    _nextDir = d;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SNAKE', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: skin.accent, letterSpacing: 4)),
                        Text('Top: $_high', style: const TextStyle(color: Colors.white54)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('SCOR', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text('$_score', style: TextStyle(color: skin.accent, fontSize: 28, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (d) {
                    if ((d.primaryVelocity ?? 0).abs() < 100) return;
                    _changeDir(d.primaryVelocity! > 0 ? Dir.right : Dir.left);
                  },
                  onVerticalDragEnd: (d) {
                    if ((d.primaryVelocity ?? 0).abs() < 100) return;
                    _changeDir(d.primaryVelocity! > 0 ? Dir.down : Dir.up);
                  },
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: kCols / kRows,
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: skin.boardBg,
                          border: Border.all(color: skin.border, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: LayoutBuilder(builder: (c, cons) {
                          final cell = cons.maxWidth / kCols;
                          return Stack(
                            children: [
                              // Food
                              Positioned(
                                left: _food.x * cell,
                                top: _food.y * cell,
                                width: cell,
                                height: cell,
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: skin.food,
                                    borderRadius: BorderRadius.circular(cell / 2),
                                    boxShadow: [
                                      BoxShadow(color: skin.food, blurRadius: 8),
                                    ],
                                  ),
                                ),
                              ),
                              // Snake body
                              for (var i = 0; i < _snake.length; i++)
                                Positioned(
                                  left: _snake[i].x * cell,
                                  top: _snake[i].y * cell,
                                  width: cell,
                                  height: cell,
                                  child: Container(
                                    margin: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                      color: i == 0 ? skin.head : skin.body,
                                      borderRadius: BorderRadius.circular(cell / 4),
                                      boxShadow: i == 0
                                          ? [BoxShadow(color: skin.body.withValues(alpha: 0.6), blurRadius: 6)]
                                          : null,
                                    ),
                                  ),
                                ),
                              if (_gameOver || !_running)
                                Container(
                                  color: Colors.black87,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_gameOver) ...[
                                        const Text('GAME OVER',
                                            style: TextStyle(color: Color(0xFFFF5252), fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 4)),
                                        const SizedBox(height: 8),
                                        Text('Scor: $_score',
                                            style: const TextStyle(color: Colors.white, fontSize: 18)),
                                        if (_lastEarned > 0)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text('+$_lastEarned monede 🪙',
                                                style: const TextStyle(color: Color(0xFFFFD740), fontSize: 15, fontWeight: FontWeight.w700)),
                                          ),
                                        const SizedBox(height: 16),
                                      ],
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: skin.accent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                        ),
                                        onPressed: _start,
                                        child: Text(_gameOver ? 'Joc Nou' : 'Start'),
                                      ),
                                      if (_gameOver) ...[
                                        const SizedBox(height: 12),
                                        TextButton.icon(
                                          onPressed: _rewardedBusy ? null : _onRewardedContinue,
                                          icon: _rewardedBusy
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Icon(Icons.favorite, color: Color(0xFFFF5252)),
                                          label: const Text(
                                            '❤️ Continuă (urmărește reclamă)',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Glisează ↑ ↓ ← → pentru a mișca șarpele',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
