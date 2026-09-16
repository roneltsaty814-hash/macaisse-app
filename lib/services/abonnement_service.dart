import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/abonnement.dart';

class AbonnementService {
  static const _key = 'abonnement';

  /// Récupère l'abonnement en cours, ou en crée un nouveau (essai gratuit)
  /// si c'est la toute première ouverture de l'app.
  Future<Abonnement> getAbonnement() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null) {
      final nouveau = Abonnement(dateInstallation: DateTime.now());
      await prefs.setString(_key, jsonEncode(nouveau.toJson()));
      return nouveau;
    }

    return Abonnement.fromJson(jsonDecode(raw));
  }

  /// Active l'abonnement pour 30 jours à partir d'aujourd'hui (ou prolonge
  /// à partir de la date d'expiration actuelle si l'utilisateur paie en avance).
  Future<Abonnement> activerAbonnement() async {
    final prefs = await SharedPreferences.getInstance();
    final actuel = await getAbonnement();

    final base = (actuel.dateExpirationAbonnement != null &&
            actuel.dateExpirationAbonnement!.isAfter(DateTime.now()))
        ? actuel.dateExpirationAbonnement!
        : DateTime.now();

    final nouveau = Abonnement(
      dateInstallation: actuel.dateInstallation,
      dateActivation: DateTime.now(),
      dateExpirationAbonnement:
          base.add(const Duration(days: Abonnement.dureeAbonnementJours)),
    );

    await prefs.setString(_key, jsonEncode(nouveau.toJson()));
    return nouveau;
  }
}
