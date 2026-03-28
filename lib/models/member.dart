class Member {
  final String id;
  final String messId;
  final String name;
  final String? phone;
  final String? email;
  final String joinDate;
  final bool isActive;

  const Member({
    required this.id,
    required this.messId,
    required this.name,
    this.phone,
    this.email,
    required this.joinDate,
    this.isActive = true,
  });

  Member copyWith({
    String? name,
    String? phone,
    String? email,
    String? joinDate,
    bool? isActive,
  }) =>
      Member(
        id: id,
        messId: messId,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        joinDate: joinDate ?? this.joinDate,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toMap() => {
        '_id': id,
        'mess_id': messId,
        'name': name,
        'phone': phone,
        'email': email,
        'join_date': joinDate,
        'is_active': isActive ? 1 : 0,
      };

  factory Member.fromMap(Map<String, dynamic> m) => Member(
        id: m['_id'] as String,
        messId: m['mess_id'] as String,
        name: m['name'] as String,
        phone: m['phone'] as String?,
        email: m['email'] as String?,
        joinDate: m['join_date'] as String,
        isActive: (m['is_active'] as int?) == 1,
      );

  @override
  String toString() => 'Member(id: $id, name: $name)';
}
