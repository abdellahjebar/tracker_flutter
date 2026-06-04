class CategoryMaintenance {
  final String id;
  final String nom;

  CategoryMaintenance({required this.id, required this.nom});

  factory CategoryMaintenance.fromJson(Map<String, dynamic> json, String id) =>
      CategoryMaintenance(id: id, nom: json['nom'] as String);

  Map<String, dynamic> toJson() => {'nom': nom};
}
