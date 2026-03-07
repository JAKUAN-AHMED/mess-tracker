import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import '../providers/report_provider.dart';
import '../models/mess_month.dart';

class ReportService {
  static Future<File> generatePdf(
      MonthlyReport report, MessMonth month) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Mess Hisab - ${month.label}',
              style: pw.TextStyle(
                  fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                  'Meal Rate: ${report.mealRate.toStringAsFixed(2)} Tk/unit'),
              pw.Text(
                  'Total Expenses: ${report.totalExpenses.toStringAsFixed(2)} Tk'),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: [
              'Member',
              'Meals',
              'Deposit (Tk)',
              'Cost (Tk)',
              'Balance (Tk)'
            ],
            data: report.summaries.map((s) {
              final balColor = s.balance >= 0 ? '+' : '';
              return [
                s.member.name,
                s.totalMealUnits.toStringAsFixed(1),
                s.totalDeposit.toStringAsFixed(2),
                s.mealCost.toStringAsFixed(2),
                '$balColor${s.balance.toStringAsFixed(2)}',
              ];
            }).toList(),
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration:
                const pw.BoxDecoration(color: PdfColors.teal700),
            rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300))),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
            },
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/mess_report_${month.year}_${month.month}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<File> generateExcel(
      MonthlyReport report, MessMonth month) async {
    final excel = Excel.createExcel();
    final sheet = excel['হিসাব'];

    // Header
    sheet.appendRow([
      TextCellValue('সদস্য'),
      TextCellValue('মিল সংখ্যা'),
      TextCellValue('জমা (টাকা)'),
      TextCellValue('মিল খরচ (টাকা)'),
      TextCellValue('ব্যালেন্স (টাকা)'),
    ]);

    for (final s in report.summaries) {
      sheet.appendRow([
        TextCellValue(s.member.name),
        DoubleCellValue(s.totalMealUnits),
        DoubleCellValue(s.totalDeposit),
        DoubleCellValue(s.mealCost),
        DoubleCellValue(s.balance),
      ]);
    }

    // Summary rows
    sheet.appendRow([TextCellValue('')]);
    sheet.appendRow([
      TextCellValue('মোট খরচ'),
      TextCellValue(''),
      TextCellValue(''),
      DoubleCellValue(report.totalExpenses),
    ]);
    sheet.appendRow([
      TextCellValue('মিল রেট'),
      TextCellValue(''),
      TextCellValue(''),
      DoubleCellValue(report.mealRate),
    ]);

    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/mess_report_${month.year}_${month.month}.xlsx';
    final bytes = excel.save();
    final file = File(path);
    await file.writeAsBytes(bytes!);
    return file;
  }
}
