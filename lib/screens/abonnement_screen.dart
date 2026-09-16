import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/abonnement.dart';
import '../services/abonnement_service.dart';
import '../services/paiement_service.dart';

class AbonnementScreen extends StatefulWidget {
  const AbonnementScreen({super.key});

  @override
  State<AbonnementScreen> createState() => _AbonnementScreenState();
}

class _AbonnementScreenState extends State<AbonnementScreen> {
  final _abonnementService = AbonnementService();
  final _paiementService = PaiementService();
  final _refCtrl = TextEditingController();

  Abonnement? _abonnement;
  OperateurMobileMoney? _operateurChoisi;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final a = await _abonnementService.getAbonnement();
    setState(() {
      _abonnement = a;
      _loading = false;
    });
  }

  Future<void> _confirmerPaiement() async {
    if (!_paiementService.referenceValide(_refCtrl.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entre la référence reçue par SMS après ton paiement')),
      );
      return;
    }
    await _abonnementService.activerAbonnement();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abonnement activé pour 30 jours. Merci !')),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _abonnement == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final a = _abonnement!;
    final fmtDate = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Mon abonnement')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: a.statut == StatutAbonnement.expire
                ? Colors.red.shade50
                : a.statut == StatutAbonnement.actif
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    switch (a.statut) {
                      StatutAbonnement.essaiGratuit => 'Essai gratuit en cours',
                      StatutAbonnement.actif => 'Abonnement actif',
                      StatutAbonnement.expire => 'Essai/abonnement expiré',
                    },
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    switch (a.statut) {
                      StatutAbonnement.essaiGratuit =>
                        '${a.joursRestantsEssai} jour(s) restant(s) gratuitement',
                      StatutAbonnement.actif =>
                        'Valide jusqu\'au ${fmtDate.format(a.dateExpirationAbonnement!)}',
                      StatutAbonnement.expire =>
                        'Active ton abonnement pour continuer à créer des factures',
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Activer / renouveler (${PaiementService.prixAbonnementFcfa} FCFA / mois)',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Airtel Money'),
                  selected: _operateurChoisi == OperateurMobileMoney.airtel,
                  onSelected: (_) => setState(() => _operateurChoisi = OperateurMobileMoney.airtel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Text('MTN MoMo'),
                  selected: _operateurChoisi == OperateurMobileMoney.mtn,
                  onSelected: (_) => setState(() => _operateurChoisi = OperateurMobileMoney.mtn),
                ),
              ),
            ],
          ),
          if (_operateurChoisi != null) ...[
            const SizedBox(height: 16),
            Builder(builder: (context) {
              final instr = _paiementService.genererInstructions(_operateurChoisi!);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Comment payer avec ${instr.operateurNom}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('1. Compose ${instr.codeUssd} sur ton téléphone'),
                      Text('2. Envoie ${instr.montant} FCFA au ${instr.numeroMarchand}'),
                      const Text('3. Tu reçois un SMS avec une référence de transaction'),
                      const Text('4. Saisis cette référence ci-dessous et confirme'),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            TextField(
              controller: _refCtrl,
              decoration: const InputDecoration(
                labelText: 'Référence de la transaction (reçue par SMS)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _confirmerPaiement,
              child: const Text('Confirmer le paiement'),
            ),
          ],
        ],
      ),
    );
  }
}
