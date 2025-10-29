import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/npk_data.dart';

class ExportService {
  static Future<void> exportToPDF({
    required NPKData npkData,
    required List<dynamic> recommendations,
    required String sensorName,
    String? champName,
    String? parcelleName,
  }) async {
    final pdf = pw.Document();

    // Load custom font if available
    final font = await PdfGoogleFonts.interRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Rapport d\'Analyse du Sol',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'SmartAgriChange - Analyse Automatisée',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 14,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Date: ${DateTime.now().toString().split('.')[0]}',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Sensor Information
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Informations du Capteur',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Capteur: $sensorName',
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                    if (champName != null) ...[
                      pw.Text(
                        'Champ: $champName',
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                    ],
                    if (parcelleName != null) ...[
                      pw.Text(
                        'Parcelle: $parcelleName',
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Soil Parameters
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Paramètres du Sol',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    _buildParameterRow(
                      'Conductivité Électrique',
                      '${npkData.conductivity ?? 0} μS/cm',
                      font,
                    ),
                    _buildParameterRow(
                      'Température',
                      '${npkData.temperature?.toStringAsFixed(1) ?? '0'} °C',
                      font,
                    ),
                    _buildParameterRow(
                      'Humidité',
                      '${npkData.humidity ?? 0} %',
                      font,
                    ),
                    _buildParameterRow(
                      'pH',
                      npkData.ph?.toStringAsFixed(1) ?? '0',
                      font,
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Nutrients
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Teneur en Nutriments',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    _buildParameterRow(
                      'Azote (N)',
                      '${npkData.nitrogen ?? 0} mg/kg',
                      font,
                    ),
                    _buildParameterRow(
                      'Phosphore (P)',
                      '${npkData.phosphorus ?? 0} mg/kg',
                      font,
                    ),
                    _buildParameterRow(
                      'Potassium (K)',
                      '${npkData.potassium ?? 0} mg/kg',
                      font,
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Recommendations
              if (recommendations.isNotEmpty) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Recommandations de Cultures',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      ...recommendations.map((rec) {
                        final cropName = rec['crop'] ?? 'Culture inconnue';
                        final score = rec['compatibilityScore'] ?? 0.0;
                        return pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 8),
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.green50,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                cropName,
                                style: pw.TextStyle(
                                  font: font,
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                '${score.toStringAsFixed(1)}% compatibilité',
                                style: pw.TextStyle(
                                  font: font,
                                  fontSize: 12,
                                  color: PdfColors.green700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],

              pw.Spacer(),

              // Footer
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text(
                  'Rapport généré automatiquement par SmartAgriChange',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save and share PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/rapport_analyse_sol.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Rapport d\'analyse du sol - SmartAgriChange');
  }

  static pw.Widget _buildParameterRow(
    String label,
    String value,
    pw.Font font,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 12)),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> exportToCSV({
    required NPKData npkData,
    required List<dynamic> recommendations,
    required String sensorName,
    String? champName,
    String? parcelleName,
  }) async {
    final List<List<dynamic>> rows = [];

    // Header
    rows.add(['Rapport d\'Analyse du Sol - SmartAgriChange']);
    rows.add(['Date', DateTime.now().toString()]);
    rows.add(['Capteur', sensorName]);
    if (champName != null) rows.add(['Champ', champName]);
    if (parcelleName != null) rows.add(['Parcelle', parcelleName]);
    rows.add([]);

    // Soil Parameters
    rows.add(['Paramètres du Sol']);
    rows.add(['Conductivité Électrique (μS/cm)', npkData.conductivity ?? 0]);
    rows.add(['Température (°C)', npkData.temperature ?? 0]);
    rows.add(['Humidité (%)', npkData.humidity ?? 0]);
    rows.add(['pH', npkData.ph ?? 0]);
    rows.add([]);

    // Nutrients
    rows.add(['Nutriments (mg/kg)']);
    rows.add(['Azote (N)', npkData.nitrogen ?? 0]);
    rows.add(['Phosphore (P)', npkData.phosphorus ?? 0]);
    rows.add(['Potassium (K)', npkData.potassium ?? 0]);
    rows.add([]);

    // Recommendations
    if (recommendations.isNotEmpty) {
      rows.add(['Recommandations de Cultures']);
      rows.add(['Culture', 'Compatibilité (%)']);
      for (final rec in recommendations) {
        final cropName = rec['crop'] ?? 'Culture inconnue';
        final score = rec['compatibilityScore'] ?? 0.0;
        rows.add([cropName, score]);
      }
    }

    final csvData = const ListToCsvConverter().convert(rows);

    // Save and share CSV
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/analyse_sol.csv');
    await file.writeAsString(csvData);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Données d\'analyse du sol - SmartAgriChange');
  }

  static Future<void> printReport({
    required NPKData npkData,
    required List<dynamic> recommendations,
    required String sensorName,
    String? champName,
    String? parcelleName,
  }) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        final pdf = pw.Document();
        final font = await PdfGoogleFonts.interRegular();

        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Rapport d\'Analyse du Sol',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Capteur: $sensorName${champName != null ? ' | Champ: $champName' : ''}${parcelleName != null ? ' | Parcelle: $parcelleName' : ''}',
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                  pw.SizedBox(height: 20),

                  // Parameters table
                  pw.Table.fromTextArray(
                    headers: ['Paramètre', 'Valeur', 'Unité'],
                    data: [
                      [
                        'Conductivité',
                        (npkData.conductivity ?? 0).toString(),
                        'μS/cm',
                      ],
                      [
                        'Température',
                        (npkData.temperature ?? 0).toStringAsFixed(1),
                        '°C',
                      ],
                      ['Humidité', (npkData.humidity ?? 0).toString(), '%'],
                      ['pH', (npkData.ph ?? 0).toStringAsFixed(1), ''],
                      [
                        'Azote (N)',
                        (npkData.nitrogen ?? 0).toString(),
                        'mg/kg',
                      ],
                      [
                        'Phosphore (P)',
                        (npkData.phosphorus ?? 0).toString(),
                        'mg/kg',
                      ],
                      [
                        'Potassium (K)',
                        (npkData.potassium ?? 0).toString(),
                        'mg/kg',
                      ],
                    ],
                    headerStyle: pw.TextStyle(
                      font: font,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    cellStyle: pw.TextStyle(font: font, fontSize: 10),
                  ),

                  if (recommendations.isNotEmpty) ...[
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Recommandations:',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    ...recommendations.map((rec) {
                      final cropName = rec['crop'] ?? 'Culture inconnue';
                      final score = rec['compatibilityScore'] ?? 0.0;
                      return pw.Text(
                        '$cropName: ${score.toStringAsFixed(1)}% compatibilité',
                        style: pw.TextStyle(font: font, fontSize: 10),
                      );
                    }),
                  ],
                ],
              );
            },
          ),
        );

        return pdf.save();
      },
    );
  }
}
