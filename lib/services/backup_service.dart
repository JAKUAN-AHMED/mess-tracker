import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class BackupService {
  static Future<String> _dbPath() async {
    final dbDir = await getDatabasesPath();
    return p.join(dbDir, 'mess_hisab.db');
  }

  /// Export the SQLite database file to the documents directory and share it.
  static Future<void> exportBackup() async {
    final source = File(await _dbPath());
    if (!source.existsSync()) {
      throw Exception('Database not found');
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .substring(0, 19);
    final dest =
        File(p.join(docsDir.path, 'mess_hisab_backup_$timestamp.db'));
    await source.copy(dest.path);

    await Share.shareXFiles(
      [XFile(dest.path)],
      subject: 'Mess Hisab Backup',
    );
  }

  /// Let the user pick a backup .db file and restore it.
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

    // Close the database before overwriting
    await source.copy(dest.path);
  }
}
