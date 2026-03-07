class MessMonth {
  final int? id;
  final int year;
  final int month;
  final bool isActive;
  final String startDate;
  final String? endDate;

  const MessMonth({
    this.id,
    required this.year,
    required this.month,
    this.isActive = true,
    required this.startDate,
    this.endDate,
  });

  String get label {
    const banglaMonths = [
      'জানুয়ারি',
      'ফেব্রুয়ারি',
      'মার্চ',
      'এপ্রিল',
      'মে',
      'জুন',
      'জুলাই',
      'আগস্ট',
      'সেপ্টেম্বর',
      'অক্টোবর',
      'নভেম্বর',
      'ডিসেম্বর',
    ];
    return '${banglaMonths[month - 1]} $year';
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'year': year,
        'month': month,
        'is_active': isActive ? 1 : 0,
        'start_date': startDate,
        'end_date': endDate,
      };

  factory MessMonth.fromMap(Map<String, dynamic> map) => MessMonth(
        id: map['id'] as int?,
        year: map['year'] as int,
        month: map['month'] as int,
        isActive: (map['is_active'] as int) == 1,
        startDate: map['start_date'] as String,
        endDate: map['end_date'] as String?,
      );

  MessMonth copyWith({
    int? id,
    int? year,
    int? month,
    bool? isActive,
    String? startDate,
    String? endDate,
  }) =>
      MessMonth(
        id: id ?? this.id,
        year: year ?? this.year,
        month: month ?? this.month,
        isActive: isActive ?? this.isActive,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
      );
}
