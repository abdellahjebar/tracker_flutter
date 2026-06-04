import 'package:cloud_firestore/cloud_firestore.dart';

class Maintenance {
  final String id;
  final String vehicleId;
  final String categoryId;
  final DateTime date;
  final String description;
  final double montant;

  Maintenance({
    required this.id,
    required this.vehicleId,
    required this.categoryId,
    required this.date,
    required this.description,
    required this.montant,
  });

  factory Maintenance.fromJson(Map<String, dynamic> json, String id) => Maintenance(
        id: id,
        vehicleId: json['vehicleId'] as String,
        categoryId: json['categoryId'] as String,
        date: (json['date'] as Timestamp).toDate(),
        description: json['description'] as String,
        montant: (json['montant'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'vehicleId': vehicleId,
        'categoryId': categoryId,
        'date': Timestamp.fromDate(date),
        'description': description,
        'montant': montant,
      };
}
