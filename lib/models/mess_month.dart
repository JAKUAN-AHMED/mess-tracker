import 'package:isar/isar.dart';

part 'mess_month.g.dart';

@collection
class MessMonth {
  Id id = Isar.autoIncrement;
  int year = 0;
  int month = 0;
  bool isActive = true;
  String startDate = '';
  String? endDate;

  MessMonth({
    int year = 0,
    int month = 0,
    bool isActive = true,
    String startDate = '',
    String? endDate,
  })  : year = year,
        month = month,
        isActive = isActive,
        startDate = startDate,
        endDate = endDate;

  @ignore
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
  }) {
    final mm = MessMonth(
      year: year ?? this.year,
      month: month ?? this.month,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
    mm.id = id;
    return mm;
  }
}
