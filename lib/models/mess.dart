class Mess {
  final String id;
  final String name;
  final String code;
  final String managerName;
  final String managerPassword;
  final String createdAt;

  const Mess({
    required this.id,
    required this.name,
    required this.code,
    required this.managerName,
    required this.managerPassword,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        '_id': id,
        'name': name,
        'code': code,
        'manager_name': managerName,
        'manager_password': managerPassword,
        'created_at': createdAt,
      };

  factory Mess.fromMap(Map<String, dynamic> m) => Mess(
        id: m['_id'] as String,
        name: m['name'] as String,
        code: m['code'] as String,
        managerName: m['manager_name'] as String,
        managerPassword: m['manager_password'] as String,
        createdAt: m['created_at'] as String,
      );
}
