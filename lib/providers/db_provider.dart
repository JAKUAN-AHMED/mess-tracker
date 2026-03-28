import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_service.dart';

final dbHelperProvider = Provider<DatabaseService>((ref) {
  final db = DatabaseService();
  ref.onDispose(db.dispose);
  return db;
});

// Alias for new code
final dbProvider = dbHelperProvider;
