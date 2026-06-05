import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A cosmetic theme for Snake: snake body/head colors, the food color, the play
/// board (background + border) and the surrounding premium screen background.
/// Unlockable with the coins earned from daily bonuses and play.
class SkinSnake {
  final String id;
  final String name;
  final int cost; // 0 = free/default
  final Color body;
  final Color head;
  final Color food;
  final Color boardBg;
  final Color border;
  final List<Color> bg; // 3: center → mid → edge of the radial screen background
  final Color bokeh;
  final Color accent;

  const SkinSnake({
    required this.id,
    required this.name,
    required this.cost,
    required this.body,
    required this.head,
    required this.food,
    required this.boardBg,
    required this.border,
    required this.bg,
    required this.bokeh,
    required this.accent,
  });
}

const skinsSnake = <SkinSnake>[
  SkinSnake(
    id: 'default',
    name: 'Clasic',
    cost: 0,
    body: Color(0xFF4CAF50),
    head: Color(0xFF66BB6A),
    food: Color(0xFFFF5252),
    boardBg: Color(0xFF0F1F35),
    border: Color(0xFF4CAF50),
    bg: [Color(0xFF16243C), Color(0xFF0F1B2E), Color(0xFF060D18)],
    bokeh: Color(0xFF4CAF50),
    accent: Color(0xFF4CAF50),
  ),
  SkinSnake(
    id: 'neon',
    name: 'Neon',
    cost: 300,
    body: Color(0xFF00E5FF),
    head: Color(0xFF18FFFF),
    food: Color(0xFFFF1744),
    boardBg: Color(0xFF0B0716),
    border: Color(0xFF00E5FF),
    bg: [Color(0xFF1A0B2E), Color(0xFF120820), Color(0xFF05030F)],
    bokeh: Color(0xFF00E5FF),
    accent: Color(0xFF00E5FF),
  ),
  SkinSnake(
    id: 'ocean',
    name: 'Ocean',
    cost: 400,
    body: Color(0xFF29B6F6),
    head: Color(0xFF4FC3F7),
    food: Color(0xFFFFB300),
    boardBg: Color(0xFF052235),
    border: Color(0xFF29B6F6),
    bg: [Color(0xFF0A3D5C), Color(0xFF062A40), Color(0xFF021622)],
    bokeh: Color(0xFF18FFFF),
    accent: Color(0xFF29B6F6),
  ),
  SkinSnake(
    id: 'sunset',
    name: 'Apus',
    cost: 500,
    body: Color(0xFFFF7043),
    head: Color(0xFFFFA726),
    food: Color(0xFFFFEB3B),
    boardBg: Color(0xFF2A0E1A),
    border: Color(0xFFFF7043),
    bg: [Color(0xFF3A1420), Color(0xFF2A0E18), Color(0xFF16060C)],
    bokeh: Color(0xFFFF8A65),
    accent: Color(0xFFFF7043),
  ),
  SkinSnake(
    id: 'candy',
    name: 'Bomboane',
    cost: 700,
    body: Color(0xFFFF5C8D),
    head: Color(0xFFFF80AB),
    food: Color(0xFF69F0AE),
    boardBg: Color(0xFF2A0E24),
    border: Color(0xFFFF5C8D),
    bg: [Color(0xFF3A1430), Color(0xFF2A0E24), Color(0xFF170614)],
    bokeh: Color(0xFFFF80AB),
    accent: Color(0xFFFF5C8D),
  ),
];

SkinSnake skinSnakeById(String id) =>
    skinsSnake.firstWhere((s) => s.id == id, orElse: () => skinsSnake.first);

/// Persistent skin/coin store. Coins share the existing `snakeCoins` key so the
/// daily bonus (RewardsService) and the shop draw from one wallet.
class SkinStore extends ChangeNotifier {
  SkinStore._();
  static final SkinStore instance = SkinStore._();

  static const _kCoins = 'snakeCoins';
  static const _kEquipped = 'snake_equipped';
  static const _kUnlocked = 'snake_unlocked';

  SharedPreferences? _p;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    _p = await SharedPreferences.getInstance();
    _ready = true;
  }

  int get coins => _p?.getInt(_kCoins) ?? 50;

  void reload() => notifyListeners();

  Future<void> addCoins(int n) async {
    await _p?.setInt(_kCoins, coins + n);
    notifyListeners();
  }

  Future<bool> spend(int n) async {
    if (coins < n) return false;
    await _p?.setInt(_kCoins, coins - n);
    notifyListeners();
    return true;
  }

  Set<String> get unlocked =>
      (_p?.getStringList(_kUnlocked) ?? const <String>[]).toSet()..add('default');

  bool isUnlocked(String id) => id == 'default' || unlocked.contains(id);

  Future<void> unlock(String id) async {
    final s = unlocked..add(id);
    await _p?.setStringList(_kUnlocked, s.toList());
    notifyListeners();
  }

  String get equippedId => _p?.getString(_kEquipped) ?? 'default';

  Future<void> equip(String id) async {
    await _p?.setString(_kEquipped, id);
    notifyListeners();
  }
}

/// The currently equipped Snake theme (synchronous, safe during paint).
SkinSnake activeSkinSnake() => skinSnakeById(SkinStore.instance.equippedId);
