/// Simple key-value config entry (not a database model; kept for compatibility).
class AppConfig {
  final String key;
  final String value;

  const AppConfig({required this.key, required this.value});
}
