import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LocalFileData {
  final String id;
  String name;
  final String type;
  final DateTime createdAt;
  String payload;

  LocalFileData({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    this.payload = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'payload': payload,
      };

  factory LocalFileData.fromJson(Map<String, dynamic> json) => LocalFileData(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
        payload: json['payload'] as String? ?? '',
      );
}

class LocalStorageService {
  static const String _storageKey = 'nextoffice_documents_v1';
  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  Future<List<LocalFileData>> getAllFiles() async {
    await init();
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => LocalFileData.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveFile(LocalFileData file) async {
    final files = await getAllFiles();
    final index = files.indexWhere((f) => f.id == file.id);
    if (index >= 0) {
      files[index] = file;
    } else {
      files.add(file);
    }
    await _saveAll(files);
  }

  Future<void> deleteFile(String id) async {
    final files = await getAllFiles();
    files.removeWhere((f) => f.id == id);
    await _saveAll(files);
  }

  Future<void> renameFile(String id, String newName) async {
    final files = await getAllFiles();
    final index = files.indexWhere((f) => f.id == id);
    if (index >= 0) {
      files[index].name = newName;
      await _saveAll(files);
    }
  }

  Future<LocalFileData?> getFile(String id) async {
    final files = await getAllFiles();
    try {
      return files.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveAll(List<LocalFileData> files) async {
    await init();
    final jsonList = files.map((f) => f.toJson()).toList();
    await _prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  String generateId() {
    return const Uuid().v4();
  }
}
