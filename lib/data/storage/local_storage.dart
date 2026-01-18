import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage(this.fileName);

  final String fileName;

  Future<Map<String, dynamic>> readJson() async {
    final prefs = await SharedPreferences.getInstance();
    final content = prefs.getString(fileName);
    if (content == null || content.trim().isEmpty) {
      return <String, dynamic>{};
    }
    return jsonDecode(content) as Map<String, dynamic>;
  }

  Future<void> writeJson(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(fileName, jsonEncode(data));
  }
}
