import 'package:flutter/material.dart';
import '../models/field.dart';
import '../database/database_helper.dart';

class FieldProvider extends ChangeNotifier {
  List<Field> _fields = [];
  bool _isLoading = false;

  List<Field> get fields => List.unmodifiable(_fields);
  List<Field> get availableFields =>
      _fields.where((f) => f.isAvailable).toList();
  bool get isLoading => _isLoading;

  // Load all fields from database
  Future<void> loadFields() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = DatabaseHelper.instance;
      _fields = await db.getAllFields();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load only available fields
  Future<void> loadAvailableFields() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = DatabaseHelper.instance;
      _fields = await db.getAvailableFields();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get field by ID
  Field? getFieldById(int id) {
    try {
      return _fields.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create new field
  Future<bool> createField(Field field) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = DatabaseHelper.instance;
      final id = await db.createField(field);
      
      if (id > 0) {
        // Reload fields
        await loadFields();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update field
  Future<bool> updateField(Field field) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = DatabaseHelper.instance;
      final result = await db.updateField(field);
      
      if (result > 0) {
        // Reload fields
        await loadFields();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete field
  Future<bool> deleteField(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = DatabaseHelper.instance;
      final result = await db.deleteField(id);
      
      if (result > 0) {
        // Reload fields
        await loadFields();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
