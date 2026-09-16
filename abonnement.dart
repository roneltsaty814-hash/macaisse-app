enum StatutAbonnement { essaiGratuit, actif, expire }

class Abonnement {
  final DateTime dateInstallation;
  final DateTime? dateActivation;
  final DateTime? dateExpirationAbonnement;

  static const int dureeEssaiJours = 14;
  static const int dureeAbonnementJours = 30;

  Abonnement({
    required this.dateInstallation,
    this.dateActivation,
    this.dateExpirationAbonnement,
  });

  /// Calcule le statut actuel en comparant simplement aux dates enregistrées.
  /// Rien de tout ça ne dépend d'internet : ça fonctionne hors-ligne.
  StatutAbonnement get statut {
    final maintenant = DateTime.now();

    // Un abonnement payé et toujours valide prime sur tout
    if (dateExpirationAbonnement != null &&
        maintenant.isBefore(dateExpirationAbonnement!)) {
      return StatutAbonnement.actif;
    }

    final finEssai = dateInstallation.add(const Duration(days: dureeEssaiJours));
    if (maintenant.isBefore(finEssai)) {
      return StatutAbonnement.essaiGratuit;
    }

    return StatutAbonnement.expire;
  }

  int get joursRestantsEssai {
    final finEssai = dateInstallation.add(const Duration(days: dureeEssaiJours));
    final restants = finEssai.difference(DateTime.now()).inDays;
    return restants < 0 ? 0 : restants;
  }

  bool get accesAutorise =>
      statut == StatutAbonnement.essaiGratuit || statut == StatutAbonnement.actif;

  Map<String, dynamic> toJson() => {
        'dateInstallation': dateInstallation.toIso8601String(),
        'dateActivation': dateActivation?.toIso8601String(),
        'dateExpirationAbonnement': dateExpirationAbonnement?.toIso8601String(),
      };

  factory Abonnement.fromJson(Map<String, dynamic> json) => Abonnement(
        dateInstallation: DateTime.parse(json['dateInstallation']),
        dateActivation: json['dateActivation'] != null
            ? DateTime.parse(json['dateActivation'])
            : null,
        dateExpirationAbonnement: json['dateExpirationAbonnement'] != null
            ? DateTime.parse(json['dateExpirationAbonnement'])
            : null,
      );
}
