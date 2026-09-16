import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/facture.dart';
import '../models/abonnement.dart';
import '../services/storage_service.dart';
import '../services/abonnement_service.dart';
import 'abonnement_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  final _abonnementService = AbonnementService();
  final _fmt = NumberFormat.decimalPattern('fr_FR');

  List<Facture> _factures = [];
  Abonnement? _abonnement;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final factures = await _storage.getFactures();
    final abonnement = await _abonnementService.getAbonnement();
    setState(() {
      _factures = factures;
      _abonnement = abonnement;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final payees = _factures.where((f) => f.statut == StatutFacture.payee);
    final enAttente = _factures.where((f) => f.statut == StatutFacture.enAttente);
    final totalEncaisse = payees.fold<double>(0, (s, f) => s + f.totalTtc);
    final totalAttente = enAttente.fold<double>(0, (s, f) => s + f.totalTtc);

    return Scaffold(
      appBar: AppBar(title: const Text('Ma Caisse'), centerTitle: false),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_abonnement != null && _abonnement!.statut != StatutAbonnement.actif)
                    Card(
                      color: _abonnement!.statut == StatutAbonnement.expire
                          ? Colors.red.shade50
                          : Colors.orange.shade50,
                      child: ListTile(
                        leading: Icon(
                          _abonnement!.statut == StatutAbonnement.expire
                              ? Icons.lock_outline
                              : Icons.access_time,
                        ),
                        title: Text(
                          _abonnement!.statut == StatutAbonnement.expire
                              ? 'Abonnement expiré'
                              : '${_abonnement!.joursRestantsEssai} jour(s) d\'essai restant(s)',
                        ),
                        trailing: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AbonnementScreen()),
                          ),
                          child: const Text('Gérer'),
                        ),
                      ),
                    ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Solde encaissé', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Text(
                            '${_fmt.format(totalEncaisse)} FCFA',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.hourglass_empty, size: 16, color: Colors.orange.shade700),
                              const SizedBox(width: 6),
                              Text('${_fmt.format(totalAttente)} FCFA en attente'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Factures récentes', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_factures.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('Aucune facture pour le moment')),
                    ),
                  for (final f in _factures.take(5))
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(f.clientNom),
                        subtitle: Text(DateFormat('dd/MM/yyyy').format(f.date)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${_fmt.format(f.totalTtc)} FCFA',
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              f.statut == StatutFacture.payee ? 'Payée' : 'En attente',
                              style: TextStyle(
                                fontSize: 12,
                                color: f.statut == StatutFacture.payee
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
