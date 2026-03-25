import 'package:isar/isar.dart';

part 'meal.g.dart';

@collection
class Meal {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('date')], unique: true, replace: true)
  int memberId = 0;

  String date = '';
  bool breakfast = false;
  bool lunch = true;
  bool dinner = true;

  Meal({
    int memberId = 0,
    String date = '',
    bool breakfast = false,
    bool lunch = true,
    bool dinner = true,
  })  : memberId = memberId,
        date = date,
        breakfast = breakfast,
        lunch = lunch,
        dinner = dinner;

  /// Total meal units: breakfast = 0.5, lunch = 1.0, dinner = 1.0
  @ignore
  double get totalUnits =>
      (breakfast ? 0.5 : 0.0) + (lunch ? 1.0 : 0.0) + (dinner ? 1.0 : 0.0);

  Meal copyWith({
    int? memberId,
    String? date,
    bool? breakfast,
    bool? lunch,
    bool? dinner,
  }) {
    final m = Meal(
      memberId: memberId ?? this.memberId,
      date: date ?? this.date,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
    );
    m.id = id;
    return m;
  }
}
