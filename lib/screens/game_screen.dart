import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
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
  bool _running = false;
  bool _gameOver = false;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _resetState();
    _load();
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
    setState(() => _gameOver = true);
    HapticFeedback.heavyImpact();
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
    return Scaffold(
      body: SafeArea(
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
                      const Text('SNAKE', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF4CAF50), letterSpacing: 4)),
                      Text('Top: $_high', style: const TextStyle(color: Colors.white54)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('SCOR', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      Text('$_score', style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 28, fontWeight: FontWeight.w900)),
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
                        color: const Color(0xFF0F1F35),
                        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                      ),
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
                                  color: const Color(0xFFFF5252),
                                  borderRadius: BorderRadius.circular(cell / 2),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0xFFFF5252), blurRadius: 8),
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
                                    color: i == 0 ? const Color(0xFF66BB6A) : const Color(0xFF4CAF50),
                                    borderRadius: BorderRadius.circular(cell / 4),
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
                                      const SizedBox(height: 16),
                                    ],
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4CAF50),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                      ),
                                      onPressed: _start,
                                      child: Text(_gameOver ? 'Joc Nou' : 'Start'),
                                    ),
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
    );
  }
}
