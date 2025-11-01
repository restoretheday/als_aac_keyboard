import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalStorage {
  LocalStorage(this.fileName);

  final String fileName;

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  Future<Map<String, dynamic>> readJson() async {
    final file = await _getFile();
    if (!await file.exists()) return <String, dynamic>{};
    final content = await file.readAsString();
    if (content.trim().isEmpty) return <String, dynamic>{};
    return jsonDecode(content) as Map<String, dynamic>;
  }

  Future<void> writeJson(Map<String, dynamic> data) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(data));
  }
}
