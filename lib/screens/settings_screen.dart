import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/backup_service.dart';
import '../services/email_service.dart';
import '../providers/mess_month_provider.dart';
import '../providers/report_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _recipientsCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailCtrl.text = prefs.getString('sender_email') ?? '';
      _recipientsCtrl.text = prefs.getString('recipients') ?? '';
    });
  }

  Future<void> _saveEmailSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sender_email', _emailCtrl.text.trim());
    await prefs.setString('sender_password', _passCtrl.text);
    await prefs.setString('recipients', _recipientsCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ইমেইল সেটিংস সংরক্ষিত হয়েছে')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('সেটিংস')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Backup & Restore ────────────────────────────────────────
          _sectionTitle('ডেটা ব্যাকআপ ও পুনরুদ্ধার'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.backup, color: Colors.teal),
                  title: const Text('ব্যাকআপ রপ্তানি করুন'),
                  subtitle: const Text('ডেটাবেজ ফাইল শেয়ার করুন'),
                  trailing: const Icon(Icons.share),
                  onTap: () async {
                    try {
                      await BackupService.exportBackup();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('ত্রুটি: $e')),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.restore, color: Colors.blue),
                  title: const Text('ব্যাকআপ পুনরুদ্ধার করুন'),
                  subtitle: const Text('.db ফাইল আমদানি করুন'),
                  trailing: const Icon(Icons.folder_open),
                  onTap: () async {
                    final confirmed = await _confirmRestore();
                    if (confirmed == true) {
                      try {
                        await BackupService.importBackup();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'পুনরুদ্ধার সফল। অ্যাপ পুনরায় চালু করুন।')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('ত্রুটি: $e')),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const Gap(20),

          // ── Email Settings ──────────────────────────────────────────
          _sectionTitle('ইমেইল সেটিংস (Gmail SMTP)'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'প্রেরক ইমেইল',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscurePass,
                    decoration: InputDecoration(
                      labelText: 'অ্যাপ পাসওয়ার্ড',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: _recipientsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'প্রাপক ইমেইল (কমা দিয়ে আলাদা করুন)',
                      prefixIcon: Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const Gap(16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.send),
                          label: const Text('টেস্ট ইমেইল'),
                          onPressed: _sendTestEmail,
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('সংরক্ষণ'),
                          onPressed: _saveEmailSettings,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Gap(20),

          // ── Send monthly report ─────────────────────────────────────
          _sectionTitle('মাসিক রিপোর্ট পাঠান'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.mark_email_read, color: Colors.green),
              title: const Text('বর্তমান মাসের রিপোর্ট পাঠান'),
              subtitle:
                  const Text('PDF ও Excel সহ ইমেইলে পাঠানো হবে'),
              trailing: const Icon(Icons.send),
              onTap: _sendMonthlyReport,
            ),
          ),
          const Gap(40),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );

  Future<bool?> _confirmRestore() => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('পুনরুদ্ধার নিশ্চিত করুন'),
          content: const Text(
              'বিদ্যমান সব ডেটা মুছে যাবে এবং ব্যাকআপ দিয়ে প্রতিস্থাপিত হবে। নিশ্চিত?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('না')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('হ্যাঁ'),
            ),
          ],
        ),
      );

  Future<void> _sendTestEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('sender_email') ?? '';
    final pass = prefs.getString('sender_password') ?? '';

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('প্রথমে ইমেইল সেটিংস সংরক্ষণ করুন')),
      );
      return;
    }

    try {
      final service = EmailService(
          senderEmail: email, senderPassword: pass);
      await service.sendReport(
        recipients: [email],
        subject: 'Mess Hisab - Test Email',
        body: 'এটি একটি পরীক্ষামূলক ইমেইল।',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('টেস্ট ইমেইল পাঠানো হয়েছে')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ইমেইল পাঠাতে ব্যর্থ: $e')),
        );
      }
    }
  }

  Future<void> _sendMonthlyReport() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('sender_email') ?? '';
    final pass = prefs.getString('sender_password') ?? '';
    final recipientsStr = prefs.getString('recipients') ?? '';

    if (email.isEmpty || pass.isEmpty || recipientsStr.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ইমেইল সেটিংস পূরণ করুন')),
        );
      }
      return;
    }

    final activeMonth = ref.read(activeMessMonthProvider).value;
    if (activeMonth == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('কোনো সক্রিয় মাস নেই')),
        );
      }
      return;
    }

    try {
      final report =
          await ref.read(monthlyReportProvider(activeMonth.id!).future);
      final pdfFile =
          await ReportService.generatePdf(report, activeMonth);
      final excelFile =
          await ReportService.generateExcel(report, activeMonth);

      final recipients =
          recipientsStr.split(',').map((e) => e.trim()).toList();
      final service =
          EmailService(senderEmail: email, senderPassword: pass);

      await service.sendMonthlyReport(
        recipients: recipients,
        monthLabel: activeMonth.label,
        reportText: _buildReportText(report, activeMonth.label),
        pdfFile: pdfFile,
        excelFile: excelFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('রিপোর্ট পাঠানো হয়েছে')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ত্রুটি: $e')),
        );
      }
    }
  }

  String _buildReportText(dynamic report, String label) {
    final buf = StringBuffer();
    buf.writeln('মেস হিসাব - $label');
    buf.writeln('মিল রেট: ${report.mealRate.toStringAsFixed(2)} টাকা');
    buf.writeln('মোট খরচ: ${report.totalExpenses.toStringAsFixed(2)} টাকা');
    buf.writeln('');
    for (final s in report.summaries) {
      final sign = s.balance >= 0 ? '+' : '';
      buf.writeln(
          '${s.member.name}: মিল ${s.totalMealUnits.toStringAsFixed(1)}, জমা ${s.totalDeposit.toStringAsFixed(2)}, খরচ ${s.mealCost.toStringAsFixed(2)}, ব্যালেন্স $sign${s.balance.toStringAsFixed(2)}');
    }
    return buf.toString();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _recipientsCtrl.dispose();
    super.dispose();
  }
}
