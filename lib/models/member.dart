import 'package:isar/isar.dart';

part 'member.g.dart';

@collection
class Member {
  Id id = Isar.autoIncrement;
  late String name;
  String? phone;
  String? email;
  late String joinDate;
  bool isActive = true;

  Member({
    required String name,
    String? phone,
    String? email,
    required String joinDate,
    bool isActive = true,
  })  : name = name,
        phone = phone,
        email = email,
        joinDate = joinDate,
        isActive = isActive;

  Member copyWith({
    String? name,
    String? phone,
    String? email,
    String? joinDate,
    bool? isActive,
  }) {
    final m = Member(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      joinDate: joinDate ?? this.joinDate,
      isActive: isActive ?? this.isActive,
    );
    m.id = id;
    return m;
  }

  @override
  String toString() => 'Member(id: $id, name: $name)';
}
