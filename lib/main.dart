import 'package:bd_ludo/%20game/%20engine.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameEngine()..loadHistoryAndSettings(),
      child: const BdLudoApp(),
    ),
  );
}
