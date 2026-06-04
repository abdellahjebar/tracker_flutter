import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker_flutter/domain/models/category_maintenance.dart';
import 'package:tracker_flutter/domain/models/maintenance.dart';

class MaintenanceService {
  final _db = FirebaseFirestore.instance;

  CollectionReference _maintenanceCol(String uid) =>
      _db.collection('users').doc(uid).collection('maintenance');

  CollectionReference _categoryCol(String uid) =>
      _db.collection('users').doc(uid).collection('categoryMaintenance');

  Future<List<Maintenance>> fetchAll(String uid) async {
    final snap = await _maintenanceCol(uid).orderBy('date', descending: true).get();
    return snap.docs
        .map((d) => Maintenance.fromJson(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Future<void> add(String uid, Maintenance m) async {
    await _maintenanceCol(uid).add(m.toJson());
  }

  Future<void> delete(String uid, String maintenanceId) async {
    await _maintenanceCol(uid).doc(maintenanceId).delete();
  }

  Future<List<CategoryMaintenance>> fetchCategories(String uid) async {
    final snap = await _categoryCol(uid).orderBy('nom').get();
    return snap.docs
        .map((d) => CategoryMaintenance.fromJson(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Future<void> addCategory(String uid, String nom) async {
    await _categoryCol(uid).add({'nom': nom});
  }
}
