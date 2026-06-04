import 'package:cloud_firestore/cloud_firestore.dart';

class FuelEntry {
  final String id;
  final String vehicleId;
  final DateTime date;
  final double litres;
  final double montant;
  final int kilometrage;

  FuelEntry({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.litres,
    required this.montant,
    required this.kilometrage,
  });

  factory FuelEntry.fromJson(Map<String, dynamic> json, String id) => FuelEntry(
        id: id,
        vehicleId: json['vehicleId'] as String,
        date: (json['date'] as Timestamp).toDate(),
        litres: (json['litres'] as num).toDouble(),
        montant: (json['montant'] as num).toDouble(),
        kilometrage: json['kilometrage'] as int,
      );

  Map<String, dynamic> toJson() => {
        'vehicleId': vehicleId,
        'date': Timestamp.fromDate(date),
        'litres': litres,
        'montant': montant,
        'kilometrage': kilometrage,
      };
}
