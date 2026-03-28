class Meal {
  final String id;
  final String messId;
  final String memberId;
  final String date;
  final bool breakfast;
  final bool lunch;
  final bool dinner;

  const Meal({
    required this.id,
    required this.messId,
    required this.memberId,
    required this.date,
    this.breakfast = false,
    this.lunch = true,
    this.dinner = true,
  });

  /// Total meal units: breakfast = 0.5, lunch = 1.0, dinner = 1.0
  double get totalUnits =>
      (breakfast ? 0.5 : 0.0) + (lunch ? 1.0 : 0.0) + (dinner ? 1.0 : 0.0);

  Meal copyWith({
    String? memberId,
    String? date,
    bool? breakfast,
    bool? lunch,
    bool? dinner,
  }) =>
      Meal(
        id: id,
        messId: messId,
        memberId: memberId ?? this.memberId,
        date: date ?? this.date,
        breakfast: breakfast ?? this.breakfast,
        lunch: lunch ?? this.lunch,
        dinner: dinner ?? this.dinner,
      );

  Map<String, dynamic> toMap() => {
        '_id': id,
        'mess_id': messId,
        'member_id': memberId,
        'date': date,
        'breakfast': breakfast ? 1 : 0,
        'lunch': lunch ? 1 : 0,
        'dinner': dinner ? 1 : 0,
      };

  factory Meal.fromMap(Map<String, dynamic> m) => Meal(
        id: m['_id'] as String,
        messId: m['mess_id'] as String,
        memberId: m['member_id'] as String,
        date: m['date'] as String,
        breakfast: (m['breakfast'] as int?) == 1,
        lunch: (m['lunch'] as int?) == 1,
        dinner: (m['dinner'] as int?) == 1,
      );
}
