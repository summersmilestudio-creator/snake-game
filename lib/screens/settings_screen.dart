import 'package:flutter/material.dart';
import '../services/rewards_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = SettingsService();
  bool _sound = true;
  bool _haptic = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _settings.soundOn();
    final h = await _settings.hapticOn();
    if (mounted) setState(() { _sound = s; _haptic = h; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        title: const Text('Setări'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            activeColor: const Color(0xFF4CAF50),
            title: const Text('Sunet', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Efecte sonore', style: TextStyle(color: Colors.white60)),
            value: _sound,
            onChanged: (v) async { await _settings.setSound(v); setState(() => _sound = v); },
            secondary: const Icon(Icons.volume_up, color: Color(0xFF4CAF50)),
          ),
          SwitchListTile(
            activeColor: const Color(0xFF4CAF50),
            title: const Text('Vibrații', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Haptic feedback', style: TextStyle(color: Colors.white60)),
            value: _haptic,
            onChanged: (v) async { await _settings.setHaptic(v); setState(() => _haptic = v); },
            secondary: const Icon(Icons.vibration, color: Color(0xFF4CAF50)),
          ),
          const Divider(color: Colors.white24),
          const ListTile(
            leading: Icon(Icons.info_outline, color: Colors.white60),
            title: Text('Versiune', style: TextStyle(color: Colors.white)),
            subtitle: Text('1.1.0', style: TextStyle(color: Colors.white60)),
          ),
          const ListTile(
            leading: Icon(Icons.business, color: Colors.white60),
            title: Text('Publisher', style: TextStyle(color: Colors.white)),
            subtitle: Text('Summer Smile SRL', style: TextStyle(color: Colors.white60)),
          ),
        ],
      ),
    );
  }
}
