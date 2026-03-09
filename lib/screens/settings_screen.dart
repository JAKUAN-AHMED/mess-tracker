import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/backup_service.dart';
import '../services/email_service.dart';
import '../services/report_service.dart';
import '../providers/mess_month_provider.dart';
import '../providers/report_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'welcome_screen.dart';

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
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    gradient: AppColors.gradientPurplePink),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.settings_rounded,
                              color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'সেটিংস',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'অ্যাপ কনফিগারেশন',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // User info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPurplePink,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            auth.status == AuthStatus.manager ? '👑' : '🙋',
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.userName ?? 'ব্যবহারকারী',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              auth.status == AuthStatus.manager
                                  ? 'ম্যানেজার'
                                  : 'সদস্য',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                              ),
                            ),
                            if (auth.messName?.isNotEmpty == true)
                              Text(
                                auth.messName!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Backup section
                _sectionLabel('💾 ডেটা ব্যাকআপ'),
                const SizedBox(height: 10),
                _settingsCard([
                  _settingsTile(
                    icon: Icons.backup_rounded,
                    gradient: AppColors.gradientTealBlue,
                    title: 'ব্যাকআপ রপ্তানি',
                    subtitle: 'ডেটাবেজ ফাইল শেয়ার করুন',
                    trailing: const Icon(Icons.share_rounded,
                        color: AppColors.teal),
                    onTap: () async {
                      try {
                        await BackupService.exportBackup();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('ত্রুটি: $e')));
                        }
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 68),
                  _settingsTile(
                    icon: Icons.restore_rounded,
                    gradient: AppColors.gradientOrangeYellow,
                    title: 'ব্যাকআপ পুনরুদ্ধার',
                    subtitle: '.db ফাইল আমদানি করুন',
                    trailing: const Icon(Icons.folder_open_rounded,
                        color: AppColors.accent),
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
                                SnackBar(content: Text('ত্রুটি: $e')));
                          }
                        }
                      }
                    },
                  ),
                ]),
                const SizedBox(height: 20),

                // Email section
                _sectionLabel('📧 ইমেইল সেটিংস'),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _emailField(
                          ctrl: _emailCtrl,
                          label: 'প্রেরক ইমেইল',
                          icon: Icons.email_rounded,
                          gradient: AppColors.gradientPurplePink,
                          keyboard: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _emailField(
                          ctrl: _passCtrl,
                          label: 'অ্যাপ পাসওয়ার্ড',
                          icon: Icons.lock_rounded,
                          gradient: AppColors.gradientPinkOrange,
                          obscure: _obscurePass,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePass
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _emailField(
                          ctrl: _recipientsCtrl,
                          label: 'প্রাপক ইমেইল (কমা দিয়ে আলাদা)',
                          icon: Icons.people_rounded,
                          gradient: AppColors.gradientGreenTeal,
                          keyboard: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _sendTestEmail,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  side: const BorderSide(
                                      color: AppColors.primary),
                                ),
                                icon: const Icon(Icons.send_rounded,
                                    size: 18),
                                label: const Text('টেস্ট'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: AppColors.gradientPurplePink,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _saveEmailSettings,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.save_rounded,
                                      size: 18),
                                  label: const Text('সংরক্ষণ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Send report
                _sectionLabel('📊 রিপোর্ট পাঠান'),
                const SizedBox(height: 10),
                _settingsCard([
                  _settingsTile(
                    icon: Icons.mark_email_read_rounded,
                    gradient: AppColors.gradientGreenTeal,
                    title: 'মাসিক রিপোর্ট পাঠান',
                    subtitle: 'PDF ও Excel সহ ইমেইলে পাঠানো হবে',
                    trailing:
                        const Icon(Icons.send_rounded, color: AppColors.green),
                    onTap: _sendMonthlyReport,
                  ),
                ]),
                const SizedBox(height: 24),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.red.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const WelcomeScreen()),
                            (_) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.red,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        'লগআউট',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 15,
          color: Color(0xFF1A1A2E),
        ),
      );

  Widget _settingsCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(children: children),
      );

  Widget _settingsTile({
    required IconData icon,
    required LinearGradient gradient,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _emailField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required LinearGradient gradient,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Future<bool?> _confirmRestore() => showDialog<bool>(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.warning_rounded,
                      color: AppColors.red, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('পুনরুদ্ধার করবেন?',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  'বিদ্যমান সব ডেটা মুছে যাবে।',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('না'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('হ্যাঁ',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> _sendTestEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('sender_email') ?? '';
    final pass = prefs.getString('sender_password') ?? '';
    if (email.isEmpty || pass.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('প্রথমে ইমেইল সেটিংস সংরক্ষণ করুন')),
        );
      }
      return;
    }
    try {
      final service =
          EmailService(senderEmail: email, senderPassword: pass);
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('ব্যর্থ: $e')));
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
      final pdfFile = await ReportService.generatePdf(report, activeMonth);
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('ত্রুটি: $e')));
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
