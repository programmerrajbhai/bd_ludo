import 'package:bd_ludo/%20game/engine.dart';
import 'package:bd_ludo/%20game/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final eng = context.watch<GameEngine>();
    final s = eng.settings;

    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFF083F7A),
        border: Border.all(color: Colors.white.withOpacity(.16)),
        boxShadow: const [BoxShadow(blurRadius: 55, offset: Offset(0, 18), color: Color(0x66000000))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            const Expanded(child: Text("Settings", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: .4))),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.white)),
          ]),
          SwitchListTile(
            value: s.soundOn,
            onChanged: (v) => _save(context, s..soundOn = v),
            title: const Text("Sound"),
            subtitle: const Text("Dice, move, capture, win"),
          ),
          SwitchListTile(
            value: s.exactRoll,
            onChanged: (v) => _save(context, s..exactRoll = v),
            title: const Text("Exact roll required"),
            subtitle: const Text("Finish home with exact dice"),
          ),
          SwitchListTile(
            value: s.autoMove,
            onChanged: (v) => _save(context, s..autoMove = v),
            title: const Text("Auto-move"),
            subtitle: const Text("If only one valid move exists"),
          ),
          SwitchListTile(
            value: s.showHints,
            onChanged: (v) => _save(context, s..showHints = v),
            title: const Text("Show hints"),
            subtitle: const Text("Highlight + tooltip"),
          ),
          DropdownButtonFormField<String>(
            value: s.diceSpeed,
            items: const [
              DropdownMenuItem(value: 'slow', child: Text('Dice speed: Slow')),
              DropdownMenuItem(value: 'normal', child: Text('Dice speed: Normal')),
              DropdownMenuItem(value: 'fast', child: Text('Dice speed: Fast')),
            ],
            onChanged: (v) {
              if (v == null) return;
              _save(context, s..diceSpeed = v);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _save(BuildContext context, SettingsModel s) {
    context.read<GameEngine>().updateSettings(s);
  }
}
