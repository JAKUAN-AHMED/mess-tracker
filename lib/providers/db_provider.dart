import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/db_helper.dart';

final dbHelperProvider = Provider<DBHelper>((ref) => DBHelper());
