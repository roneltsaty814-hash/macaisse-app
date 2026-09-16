/// IMPORTANT — à lire avant de coder plus loin :
///
/// Les vraies API d'Airtel Money et de MTN MoMo (Collections API) exigent
/// un compte MARCHAND professionnel avec des clés API, obtenu en faisant
/// une demande directement auprès d'Airtel Congo ou de MTN Congo (dossier
/// entreprise, KYC, etc.). Ce n'est pas quelque chose qu'on peut activer
/// depuis le code : c'est une démarche administrative que tu dois faire
/// toi-même, une fois que tu es prêt à facturer réellement.
///
/// En attendant d'avoir ces accès, ce service utilise un flux MANUEL qui
/// fonctionne dès aujourd'hui et que beaucoup de petites apps utilisent
/// au démarrage : le client paie via le code USSD habituel de son
/// opérateur vers ton propre numéro marchand/personnel, reçoit une
/// référence de transaction par SMS, et la saisit dans l'app pour activer
/// son abonnement. Tu vérifies toi-même manuellement (au début) que le
/// paiement est bien arrivé sur ton compte.
///
/// Quand tu auras un compte marchand officiel, remplace le contenu de
/// `confirmerPaiement()` par un vrai appel HTTP à l'API du fournisseur
/// (voir le bloc commenté en bas du fichier à titre d'exemple).

enum OperateurMobileMoney { airtel, mtn }

class InstructionsPaiement {
  final String operateurNom;
  final String codeUssd;
  final String numeroMarchand;
  final int montant;

  InstructionsPaiement({
    required this.operateurNom,
    required this.codeUssd,
    required this.numeroMarchand,
    required this.montant,
  });
}

class PaiementService {
  // 🔧 À REMPLACER par ton propre numéro marchand/personnel avant utilisation
  static const String numeroAirtelMoney = '+242 06 XXX XX XX';
  static const String numeroMtnMomo = '+242 05 XXX XX XX';
  static const int prixAbonnementFcfa = 1500;

  InstructionsPaiement genererInstructions(OperateurMobileMoney operateur) {
    switch (operateur) {
      case OperateurMobileMoney.airtel:
        return InstructionsPaiement(
          operateurNom: 'Airtel Money',
          codeUssd: '*128#', // à vérifier/ajuster selon le menu Airtel Congo actuel
          numeroMarchand: numeroAirtelMoney,
          montant: prixAbonnementFcfa,
        );
      case OperateurMobileMoney.mtn:
        return InstructionsPaiement(
          operateurNom: 'MTN MoMo',
          codeUssd: '*126#', // à vérifier/ajuster selon le menu MTN Congo actuel
          numeroMarchand: numeroMtnMomo,
          montant: prixAbonnementFcfa,
        );
    }
  }

  /// Validation manuelle : on vérifie juste que la référence n'est pas vide
  /// et a un format plausible. La vraie vérification (le paiement est-il
  /// réellement arrivé ?) se fait par toi, en consultant ton solde mobile
  /// money, tant que tu n'as pas d'API automatique branchée.
  bool referenceValide(String reference) {
    final r = reference.trim();
    return r.length >= 6;
  }
}

/*
=== EXEMPLE — à activer une fois que tu as un compte marchand MTN MoMo ===

class MtnMomoApiService {
  final String subscriptionKey = 'TA_CLE_API_MTN';   // fournie par MTN
  final String apiUserId = 'TON_API_USER_ID';        // généré lors de l'inscription
  final String apiKey = 'TA_CLE_SECRETE';

  Future<bool> demanderPaiement({
    required String numeroClient,
    required int montant,
  }) async {
    // Appel HTTP réel vers l'API "Request to Pay" de MTN MoMo Collections
    // Documentation officielle : https://momodeveloper.mtn.com
    // final response = await http.post(
    //   Uri.parse('https://sandbox.momodeveloper.mtn.com/collection/v1_0/requesttopay'),
    //   headers: { ... },
    //   body: jsonEncode({ ... }),
    // );
    // return response.statusCode == 202;
    throw UnimplementedError('Branche ici l\'appel API une fois tes clés obtenues');
  }
}
*/
