import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/facture.dart';

class PdfService {
  final _fmt = NumberFormat.decimalPattern('fr_FR');

  Future<Uint8List> genererFacturePdf(Facture facture) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'FACTURE',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(facture.numero, style: const pw.TextStyle(fontSize: 12)),
                      pw.Text(
                        DateFormat('dd/MM/yyyy').format(facture.date),
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Client
              pw.Text('Facturé à :', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              pw.Text(facture.clientNom, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 24),

              // Tableau des articles
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: const {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(1.5),
                  3: pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _cell('Désignation', bold: true),
                      _cell('Qté', bold: true),
                      _cell('Prix unit.', bold: true),
                      _cell('Total', bold: true),
                    ],
                  ),
                  for (final l in facture.lignes)
                    pw.TableRow(
                      children: [
                        _cell(l.designation),
                        _cell('${l.quantite}'),
                        _cell('${_fmt.format(l.prixUnitaire)} FCFA'),
                        _cell('${_fmt.format(l.total)} FCFA'),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Totaux
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _ligneTotal('Sous-total', facture.sousTotal),
                    _ligneTotal('TVA (18%)', facture.montantTva),
                    pw.Divider(),
                    _ligneTotal('Total TTC', facture.totalTtc, bold: true, big: true),
                  ],
                ),
              ),

              pw.SizedBox(height: 32),
              pw.Text(
                facture.statut == StatutFacture.payee ? 'Statut : Payée' : 'Statut : En attente',
                style: pw.TextStyle(
                  fontSize: 11,
                  color: facture.statut == StatutFacture.payee ? PdfColors.green700 : PdfColors.orange700,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 10, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
      ),
    );
  }

  pw.Widget _ligneTotal(String label, double montant, {bool bold = false, bool big = false}) {
    final style = pw.TextStyle(
      fontSize: big ? 14 : 11,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.SizedBox(width: 100, child: pw.Text(label, style: style)),
          pw.SizedBox(width: 110, child: pw.Text('${_fmt.format(montant)} FCFA', style: style, textAlign: pw.TextAlign.right)),
        ],
      ),
    );
  }
}
