class Meal {
  final int? id;
  final int memberId;
  final String date;
  final bool breakfast;
  final bool lunch;
  final bool dinner;

  const Meal({
    this.id,
    required this.memberId,
    required this.date,
    this.breakfast = false,
    this.lunch = true,
    this.dinner = true,
  });

  /// Total meal units: breakfast = 0.5, lunch = 1.0, dinner = 1.0
  double get totalUnits =>
      (breakfast ? 0.5 : 0.0) + (lunch ? 1.0 : 0.0) + (dinner ? 1.0 : 0.0);

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'member_id': memberId,
        'date': date,
        'breakfast': breakfast ? 1 : 0,
        'lunch': lunch ? 1 : 0,
        'dinner': dinner ? 1 : 0,
      };

  factory Meal.fromMap(Map<String, dynamic> map) => Meal(
        id: map['id'] as int?,
        memberId: map['member_id'] as int,
        date: map['date'] as String,
        breakfast: (map['breakfast'] as int) == 1,
        lunch: (map['lunch'] as int) == 1,
        dinner: (map['dinner'] as int) == 1,
      );

  Meal copyWith({
    int? id,
    int? memberId,
    String? date,
    bool? breakfast,
    bool? lunch,
    bool? dinner,
  }) =>
      Meal(
        id: id ?? this.id,
        memberId: memberId ?? this.memberId,
        date: date ?? this.date,
        breakfast: breakfast ?? this.breakfast,
        lunch: lunch ?? this.lunch,
        dinner: dinner ?? this.dinner,
      );
}
