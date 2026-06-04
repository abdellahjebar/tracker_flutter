import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker_flutter/domain/models/fuel_entry.dart';

class FuelService {
  final _db = FirebaseFirestore.instance;

  CollectionReference _col(String uid) =>
      _db.collection('users').doc(uid).collection('fuelEntries');

  Future<List<FuelEntry>> fetchAll(String uid) async {
    final snap = await _col(uid).orderBy('date', descending: true).get();
    return snap.docs
        .map((d) => FuelEntry.fromJson(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Future<void> add(String uid, FuelEntry entry) async {
    await _col(uid).add(entry.toJson());
  }

  Future<void> delete(String uid, String entryId) async {
    await _col(uid).doc(entryId).delete();
  }
}
