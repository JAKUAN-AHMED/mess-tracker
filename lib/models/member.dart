class Member {
  final int? id;
  final String name;
  final String? phone;
  final String joinDate;
  final bool isActive;

  const Member({
    this.id,
    required this.name,
    this.phone,
    required this.joinDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'phone': phone ?? '',
        'join_date': joinDate,
        'is_active': isActive ? 1 : 0,
      };

  factory Member.fromMap(Map<String, dynamic> map) => Member(
        id: map['id'] as int?,
        name: map['name'] as String,
        phone: map['phone'] as String?,
        joinDate: map['join_date'] as String,
        isActive: (map['is_active'] as int) == 1,
      );

  Member copyWith({
    int? id,
    String? name,
    String? phone,
    String? joinDate,
    bool? isActive,
  }) =>
      Member(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        joinDate: joinDate ?? this.joinDate,
        isActive: isActive ?? this.isActive,
      );

  @override
  String toString() => 'Member(id: $id, name: $name)';
}
