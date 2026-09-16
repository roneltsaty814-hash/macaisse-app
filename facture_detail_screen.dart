import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../models/facture.dart';
import '../services/pdf_service.dart';

class FactureDetailScreen extends StatelessWidget {
  final Facture facture;

  const FactureDetailScreen({super.key, required this.facture});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern('fr_FR');
    final pdfService = PdfService();

    return Scaffold(
      appBar: AppBar(title: Text(facture.numero)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(facture.clientNom, style: Theme.of(context).textTheme.titleLarge),
          Text(DateFormat('dd/MM/yyyy').format(facture.date)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final l in facture.lignes)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('${l.designation} (x${l.quantite})')),
                          Text('${fmt.format(l.total)} FCFA'),
                        ],
                      ),
                    ),
                  const Divider(),
                  _ligne('Sous-total', facture.sousTotal, fmt),
                  _ligne('TVA (18%)', facture.montantTva, fmt),
                  const Divider(),
                  _ligne('Total TTC', facture.totalTtc, fmt, gras: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Imprimer'),
                  onPressed: () async {
                    final bytes = await pdfService.genererFacturePdf(facture);
                    await Printing.layoutPdf(onLayout: (_) async => bytes);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Partager PDF'),
                  onPressed: () async {
                    final bytes = await pdfService.genererFacturePdf(facture);
                    await Printing.sharePdf(
                      bytes: bytes,
                      filename: '${facture.numero}.pdf',
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ligne(String label, double montant, NumberFormat fmt, {bool gras = false}) {
    final style = TextStyle(fontWeight: gras ? FontWeight.bold : FontWeight.normal, fontSize: gras ? 16 : 14);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('${fmt.format(montant)} FCFA', style: style),
        ],
      ),
    );
  }
}
