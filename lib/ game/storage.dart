import 'dart:convert';
import 'package:bd_ludo/%20game/%20models.dart';
import 'package:shared_preferences/shared_preferences.dart';


const _kHistory = 'bd_ludo_history_v1';
const _kSettings = 'bd_ludo_settings_v1';

Future<List<MatchHistoryItem>> loadHistory() async {
  final sp = await SharedPreferences.getInstance();
  final raw = sp.getString(_kHistory);
  if (raw == null) return [];
  final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  return list.map(MatchHistoryItem.fromJson).toList();
}

Future<void> saveHistory(List<MatchHistoryItem> items) async {
  final sp = await SharedPreferences.getInstance();
  final out = jsonEncode(items.map((e) => e.toJson()).toList());
  await sp.setString(_kHistory, out);
}

Future<SettingsModel> loadSettings() async {
  final sp = await SharedPreferences.getInstance();
  final raw = sp.getString(_kSettings);
  if (raw == null) return SettingsModel();
  return SettingsModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

Future<void> saveSettings(SettingsModel s) async {
  final sp = await SharedPreferences.getInstance();
  await sp.setString(_kSettings, jsonEncode(s.toJson()));
}
