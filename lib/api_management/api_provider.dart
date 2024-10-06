import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ApiProvider extends ChangeNotifier {
  String? _apiKey;
  final Box<String> _settingsBox = Hive.box<String>('settings');

  String? get apiKey => _apiKey;

  ApiProvider() {
    _loadApiKey();
  }

  void _loadApiKey() {
    _apiKey = _settingsBox.get('api_key');
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    await _settingsBox.put('api_key', key);
    notifyListeners();
  }

  Future<void> clearApiKey() async {
    _apiKey = null;
    await _settingsBox.delete('api_key');
    notifyListeners();
  }
}
