import 'package:flutter/material.dart';
import '../services/rewards_service.dart';
import '../services/purchase_service.dart';

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

  Future<void> _showRemoveAdsDialog() async {
    final price =
        PurchaseService.instance.productFor(PurchaseService.noAdsId)?.price ??
            '15 lei';
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF15233A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Fără reclame',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900)),
        content: const Text(
          'Joacă fără bannere și fără reclame care te întrerup. O singură dată, pentru totdeauna.',
          style: TextStyle(color: Colors.white70, height: 1.3),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              PurchaseService.instance.restore();
            },
            child: const Text('Restaurează',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              PurchaseService.instance.buy(PurchaseService.noAdsId);
            },
            child: Text('Cumpără • $price',
                style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
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
          ValueListenableBuilder<bool>(
            valueListenable: PurchaseService.instance.noAdsNotifier,
            builder: (context, noAds, _) => ListTile(
              leading: const Icon(Icons.block, color: Color(0xFF4CAF50)),
              title: const Text('Fără reclame',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text(
                  noAds ? 'Activat — mulțumim!' : 'Elimină toate reclamele',
                  style: const TextStyle(color: Colors.white60)),
              trailing: noAds
                  ? const Icon(Icons.check_circle, color: Color(0xFF4CAF50))
                  : const Icon(Icons.chevron_right, color: Colors.white60),
              onTap: noAds ? null : _showRemoveAdsDialog,
            ),
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
