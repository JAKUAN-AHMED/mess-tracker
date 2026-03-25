import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../database/isar_service.dart';

class BackupService {
  static Future<String> _dbPath() async {
    final dir = await IsarService.getDatabaseDirectory();
    return p.join(dir, 'default.isar');
  }

  /// Export the Isar database file to documents directory and share it.
  static Future<void> exportBackup() async {
    final source = File(await _dbPath());
    if (!source.existsSync()) {
      throw Exception('Database not found');
    }

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .substring(0, 19);
    final docsDir = await IsarService.getDatabaseDirectory();
    final dest = File(p.join(docsDir, 'mess_hisab_backup_$timestamp.isar'));
    await source.copy(dest.path);

    await Share.shareXFiles(
      [XFile(dest.path)],
      subject: 'Mess Hisab Backup',
    );
  }

  /// Let the user pick a backup .isar file and restore it.
  static Future<void> importBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final pickedPath = result.files.single.path;
    if (pickedPath == null) return;

    final source = File(pickedPath);
    final dest = File(await _dbPath());
    await source.copy(dest.path);
  }
}
