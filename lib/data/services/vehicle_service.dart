import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker_flutter/domain/models/vehicle.dart';

class VehicleService {
  final _db = FirebaseFirestore.instance;

  CollectionReference _col(String uid) =>
      _db.collection('users').doc(uid).collection('vehicles');

  Future<List<Vehicle>> fetchAll(String uid) async {
    final snap = await _col(uid).get();
    return snap.docs
        .map((d) => Vehicle.fromJson(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Future<void> add(String uid, Vehicle vehicle) async {
    await _col(uid).add(vehicle.toJson());
  }

  Future<void> delete(String uid, String vehicleId) async {
    await _col(uid).doc(vehicleId).delete();
  }
}
