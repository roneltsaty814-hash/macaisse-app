class Client {
  final String id;
  String nom;
  String telephone;
  String? adresse;

  Client({
    required this.id,
    required this.nom,
    required this.telephone,
    this.adresse,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'telephone': telephone,
        'adresse': adresse,
      };

  factory Client.fromJson(Map<String, dynamic> json) => Client(
        id: json['id'],
        nom: json['nom'],
        telephone: json['telephone'],
        adresse: json['adresse'],
      );
}
