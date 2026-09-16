import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/facture.dart';
import '../models/abonnement.dart';
import '../services/storage_service.dart';
import '../services/abonnement_service.dart';
import 'nouvelle_facture_screen.dart';
import 'facture_detail_screen.dart';
import 'abonnement_screen.dart';

class FacturesScreen extends StatefulWidget {
  const FacturesScreen({super.key});

  @override
  State<FacturesScreen> createState() => _FacturesScreenState();
}

class _FacturesScreenState extends State<FacturesScreen> {
  final _storage = StorageService();
  final _fmt = NumberFormat.decimalPattern('fr_FR');
  List<Facture> _factures = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final factures = await _storage.getFactures();
    setState(() {
      _factures = factures;
      _loading = false;
    });
  }

  Future<void> _nouvelleFacture() async {
    final abonnement = await AbonnementService().getAbonnement();
    if (!abonnement.accesAutorise) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ton essai gratuit est terminé — active ton abonnement pour continuer')),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AbonnementScreen()));
      return;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NouvelleFactureScreen()),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Factures')),
      floatingActionButton: FloatingActionButton(
        onPressed: _nouvelleFacture,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _factures.isEmpty
              ? const Center(child: Text('Aucune facture. Crée ta première facture.'))
              : ListView.builder(
                  itemCount: _factures.length,
                  itemBuilder: (ctx, i) {
                    final f = _factures[i];
                    return ListTile(
                      title: Text('${f.clientNom} · ${f.numero}'),
                      subtitle: Text(DateFormat('dd/MM/yyyy').format(f.date)),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FactureDetailScreen(facture: f)),
                      ),
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
                    );
                  },
                ),
    );
  }
}
