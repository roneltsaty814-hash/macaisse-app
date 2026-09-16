import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client.dart';
import '../models/facture.dart';

/// Tout est stocké localement sur le téléphone (SharedPreferences).
/// Aucune connexion internet n'est nécessaire pour utiliser l'app :
/// c'est le point clé pour le contexte congolais où le réseau est
/// parfois instable.
class StorageService {
  static const _clientsKey = 'clients';
  static const _facturesKey = 'factures';

  Future<List<Client>> getClients() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_clientsKey) ?? [];
    return raw.map((s) => Client.fromJson(jsonDecode(s))).toList();
  }

  Future<void> saveClient(Client client) async {
    final prefs = await SharedPreferences.getInstance();
    final clients = await getClients();
    clients.removeWhere((c) => c.id == client.id);
    clients.add(client);
    await prefs.setStringList(
      _clientsKey,
      clients.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }

  Future<void> deleteClient(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final clients = await getClients();
    clients.removeWhere((c) => c.id == id);
    await prefs.setStringList(
      _clientsKey,
      clients.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }

  Future<List<Facture>> getFactures() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_facturesKey) ?? [];
    final factures = raw.map((s) => Facture.fromJson(jsonDecode(s))).toList();
    factures.sort((a, b) => b.date.compareTo(a.date));
    return factures;
  }

  Future<void> saveFacture(Facture facture) async {
    final prefs = await SharedPreferences.getInstance();
    final factures = await getFactures();
    factures.removeWhere((f) => f.id == facture.id);
    factures.add(facture);
    await prefs.setStringList(
      _facturesKey,
      factures.map((f) => jsonEncode(f.toJson())).toList(),
    );
  }

  Future<String> nextNumeroFacture() async {
    final factures = await getFactures();
    final annee = DateTime.now().year;
    final count = factures
            .where((f) => f.date.year == annee)
            .length +
        1;
    return 'FAC-$annee-${count.toString().padLeft(4, '0')}';
  }
}
