import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/client.dart';
import '../models/facture.dart';
import '../services/storage_service.dart';
import 'facture_detail_screen.dart';

class NouvelleFactureScreen extends StatefulWidget {
  const NouvelleFactureScreen({super.key});

  @override
  State<NouvelleFactureScreen> createState() => _NouvelleFactureScreenState();
}

class _NouvelleFactureScreenState extends State<NouvelleFactureScreen> {
  final _storage = StorageService();
  final _fmt = NumberFormat.decimalPattern('fr_FR');

  List<Client> _clients = [];
  Client? _clientChoisi;
  final List<LigneFacture> _lignes = [];

  @override
  void initState() {
    super.initState();
    _storage.getClients().then((c) => setState(() => _clients = c));
  }

  double get sousTotal => _lignes.fold(0, (s, l) => s + l.total);
  double get tva => sousTotal * Facture.tauxTva;
  double get total => sousTotal + tva;

  Future<void> _ajouterLigne() async {
    final desigCtrl = TextEditingController();
    final qteCtrl = TextEditingController(text: '1');
    final prixCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter un article'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: desigCtrl, decoration: const InputDecoration(labelText: 'Désignation')),
            TextField(
              controller: qteCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantité'),
            ),
            TextField(
              controller: prixCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Prix unitaire (FCFA)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ajouter')),
        ],
      ),
    );

    if (ok == true && desigCtrl.text.trim().isNotEmpty) {
      final qte = int.tryParse(qteCtrl.text) ?? 1;
      final prix = double.tryParse(prixCtrl.text) ?? 0;
      setState(() {
        _lignes.add(LigneFacture(
          designation: desigCtrl.text.trim(),
          quantite: qte,
          prixUnitaire: prix,
        ));
      });
    }
  }

  Future<void> _enregistrer({required bool payee}) async {
    if (_clientChoisi == null || _lignes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisis un client et ajoute au moins un article')),
      );
      return;
    }
    final numero = await _storage.nextNumeroFacture();
    final facture = Facture(
      id: const Uuid().v4(),
      numero: numero,
      clientId: _clientChoisi!.id,
      clientNom: _clientChoisi!.nom,
      date: DateTime.now(),
      lignes: _lignes,
      statut: payee ? StatutFacture.payee : StatutFacture.enAttente,
    );
    await _storage.saveFacture(facture);
    if (!mounted) return;
    Navigator.pop(context, true);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FactureDetailScreen(facture: facture)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle facture')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<Client>(
            decoration: const InputDecoration(labelText: 'Client', border: OutlineInputBorder()),
            items: _clients
                .map((c) => DropdownMenuItem(value: c, child: Text(c.nom)))
                .toList(),
            onChanged: (c) => setState(() => _clientChoisi = c),
            value: _clientChoisi,
          ),
          if (_clients.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Aucun client enregistré. Ajoute-en un depuis l\'onglet Clients.',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Articles', style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: _ajouterLigne,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
              ),
            ],
          ),
          for (final l in _lignes)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.designation),
              subtitle: Text('${l.quantite} x ${_fmt.format(l.prixUnitaire)} FCFA'),
              trailing: Text('${_fmt.format(l.total)} FCFA'),
            ),
          const Divider(height: 32),
          _ligneTotal('Sous-total', sousTotal),
          _ligneTotal('TVA (18%)', tva),
          const Divider(),
          _ligneTotal('Total TTC', total, gras: true),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _enregistrer(payee: false),
                  child: const Text('Enregistrer en attente'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => _enregistrer(payee: true),
                  child: const Text('Marquer payée'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ligneTotal(String label, double montant, {bool gras = false}) {
    final style = TextStyle(
      fontWeight: gras ? FontWeight.bold : FontWeight.normal,
      fontSize: gras ? 18 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('${_fmt.format(montant)} FCFA', style: style),
        ],
      ),
    );
  }
}
