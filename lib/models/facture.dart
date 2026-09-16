enum StatutFacture { payee, enAttente }

class LigneFacture {
  String designation;
  int quantite;
  double prixUnitaire;

  LigneFacture({
    required this.designation,
    required this.quantite,
    required this.prixUnitaire,
  });

  double get total => quantite * prixUnitaire;

  Map<String, dynamic> toJson() => {
        'designation': designation,
        'quantite': quantite,
        'prixUnitaire': prixUnitaire,
      };

  factory LigneFacture.fromJson(Map<String, dynamic> json) => LigneFacture(
        designation: json['designation'],
        quantite: json['quantite'],
        prixUnitaire: (json['prixUnitaire'] as num).toDouble(),
      );
}

class Facture {
  final String id;
  final String numero;
  final String clientId;
  final String clientNom;
  final DateTime date;
  final List<LigneFacture> lignes;
  StatutFacture statut;

  // Taux de TVA congolais standard
  static const double tauxTva = 0.18;

  Facture({
    required this.id,
    required this.numero,
    required this.clientId,
    required this.clientNom,
    required this.date,
    required this.lignes,
    this.statut = StatutFacture.enAttente,
  });

  double get sousTotal => lignes.fold(0, (sum, l) => sum + l.total);
  double get montantTva => sousTotal * tauxTva;
  double get totalTtc => sousTotal + montantTva;

  Map<String, dynamic> toJson() => {
        'id': id,
        'numero': numero,
        'clientId': clientId,
        'clientNom': clientNom,
        'date': date.toIso8601String(),
        'lignes': lignes.map((l) => l.toJson()).toList(),
        'statut': statut.name,
      };

  factory Facture.fromJson(Map<String, dynamic> json) => Facture(
        id: json['id'],
        numero: json['numero'],
        clientId: json['clientId'],
        clientNom: json['clientNom'],
        date: DateTime.parse(json['date']),
        lignes: (json['lignes'] as List)
            .map((l) => LigneFacture.fromJson(l))
            .toList(),
        statut: StatutFacture.values.firstWhere(
          (s) => s.name == json['statut'],
          orElse: () => StatutFacture.enAttente,
        ),
      );
}
