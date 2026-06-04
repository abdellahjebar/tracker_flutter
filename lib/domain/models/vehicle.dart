class Vehicle {
  final String id;
  final String marque;
  final String modele;
  final String immatriculation;
  final int annee;

  Vehicle({
    required this.id,
    required this.marque,
    required this.modele,
    required this.immatriculation,
    required this.annee,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json, String id) => Vehicle(
        id: id,
        marque: json['marque'] as String,
        modele: json['modele'] as String,
        immatriculation: json['immatriculation'] as String,
        annee: json['annee'] as int,
      );

  Map<String, dynamic> toJson() => {
        'marque': marque,
        'modele': modele,
        'immatriculation': immatriculation,
        'annee': annee,
      };
}
