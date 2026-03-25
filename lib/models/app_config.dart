import 'package:isar/isar.dart';

part 'app_config.g.dart';

@collection
class AppConfig {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String key = '';

  String value = '';

  AppConfig({String key = '', String value = ''})
      : key = key,
        value = value;
}
