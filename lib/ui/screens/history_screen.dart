import 'package:bd_ludo/%20game/engine.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eng = context.watch<GameEngine>();
    return Scaffold(
      appBar: AppBar(title: const Text("History"), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(14),
          itemBuilder: (_, i) {
            final h = eng.history[i];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.black.withOpacity(.18),
                border: Border.all(color: Colors.white.withOpacity(.14)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h.mode, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text("Winner: ${h.winner}", style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFF7C62F))),
                  const SizedBox(height: 6),
                  Text(h.players.join(" • "), style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFB8D6FF))),
                  const SizedBox(height: 4),
                  Text(h.dateIso, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFFB8D6FF))),
                ],
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemCount: eng.history.length,
        ),
      ),
    );
  }
}
