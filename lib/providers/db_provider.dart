import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/isar_service.dart';

// Provides the IsarService singleton - same interface as the old DBHelper
final dbHelperProvider = Provider<IsarService>((ref) => IsarService());
