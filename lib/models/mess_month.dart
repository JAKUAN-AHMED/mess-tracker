class MessMonth {
  final String id;
  final String messId;
  final int year;
  final int month;
  final bool isActive;
  final String startDate;
  final String? endDate;

  const MessMonth({
    required this.id,
    required this.messId,
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

  MessMonth copyWith({
    int? year,
    int? month,
    bool? isActive,
    String? startDate,
    String? endDate,
  }) =>
      MessMonth(
        id: id,
        messId: messId,
        year: year ?? this.year,
        month: month ?? this.month,
        isActive: isActive ?? this.isActive,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
      );

  Map<String, dynamic> toMap() => {
        '_id': id,
        'mess_id': messId,
        'year': year,
        'month': month,
        'is_active': isActive ? 1 : 0,
        'start_date': startDate,
        'end_date': endDate,
      };

  factory MessMonth.fromMap(Map<String, dynamic> m) => MessMonth(
        id: m['_id'] as String,
        messId: m['mess_id'] as String,
        year: m['year'] as int,
        month: m['month'] as int,
        isActive: (m['is_active'] as int?) == 1,
        startDate: m['start_date'] as String,
        endDate: m['end_date'] as String?,
      );
}
