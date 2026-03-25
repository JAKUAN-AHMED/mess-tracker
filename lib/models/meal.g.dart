// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMealCollection on Isar {
  IsarCollection<Meal> get meals => this.collection();
}

const MealSchema = CollectionSchema(
  name: r'Meal',
  id: 2462895270179255875,
  properties: {
    r'breakfast': PropertySchema(
      id: 0,
      name: r'breakfast',
      type: IsarType.bool,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.string,
    ),
    r'dinner': PropertySchema(
      id: 2,
      name: r'dinner',
      type: IsarType.bool,
    ),
    r'lunch': PropertySchema(
      id: 3,
      name: r'lunch',
      type: IsarType.bool,
    ),
    r'memberId': PropertySchema(
      id: 4,
      name: r'memberId',
      type: IsarType.long,
    )
  },
  estimateSize: _mealEstimateSize,
  serialize: _mealSerialize,
  deserialize: _mealDeserialize,
  deserializeProp: _mealDeserializeProp,
  idName: r'id',
  indexes: {
    r'memberId_date': IndexSchema(
      id: 6342100059442828536,
      name: r'memberId_date',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'memberId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'date',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _mealGetId,
  getLinks: _mealGetLinks,
  attach: _mealAttach,
  version: '3.1.0+1',
);

int _mealEstimateSize(
  Meal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.date.length * 3;
  return bytesCount;
}

void _mealSerialize(
  Meal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.breakfast);
  writer.writeString(offsets[1], object.date);
  writer.writeBool(offsets[2], object.dinner);
  writer.writeBool(offsets[3], object.lunch);
  writer.writeLong(offsets[4], object.memberId);
}

Meal _mealDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Meal(
    breakfast: reader.readBoolOrNull(offsets[0]) ?? false,
    date: reader.readStringOrNull(offsets[1]) ?? '',
    dinner: reader.readBoolOrNull(offsets[2]) ?? true,
    lunch: reader.readBoolOrNull(offsets[3]) ?? true,
    memberId: reader.readLongOrNull(offsets[4]) ?? 0,
  );
  object.id = id;
  return object;
}

P _mealDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 1:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 4:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _mealGetId(Meal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mealGetLinks(Meal object) {
  return [];
}

void _mealAttach(IsarCollection<dynamic> col, Id id, Meal object) {
  object.id = id;
}

extension MealByIndex on IsarCollection<Meal> {
  Future<Meal?> getByMemberIdDate(int memberId, String date) {
    return getByIndex(r'memberId_date', [memberId, date]);
  }

  Meal? getByMemberIdDateSync(int memberId, String date) {
    return getByIndexSync(r'memberId_date', [memberId, date]);
  }

  Future<bool> deleteByMemberIdDate(int memberId, String date) {
    return deleteByIndex(r'memberId_date', [memberId, date]);
  }

  bool deleteByMemberIdDateSync(int memberId, String date) {
    return deleteByIndexSync(r'memberId_date', [memberId, date]);
  }

  Future<List<Meal?>> getAllByMemberIdDate(
      List<int> memberIdValues, List<String> dateValues) {
    final len = memberIdValues.length;
    assert(
        dateValues.length == len, 'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([memberIdValues[i], dateValues[i]]);
    }

    return getAllByIndex(r'memberId_date', values);
  }

  List<Meal?> getAllByMemberIdDateSync(
      List<int> memberIdValues, List<String> dateValues) {
    final len = memberIdValues.length;
    assert(
        dateValues.length == len, 'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([memberIdValues[i], dateValues[i]]);
    }

    return getAllByIndexSync(r'memberId_date', values);
  }

  Future<int> deleteAllByMemberIdDate(
      List<int> memberIdValues, List<String> dateValues) {
    final len = memberIdValues.length;
    assert(
        dateValues.length == len, 'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([memberIdValues[i], dateValues[i]]);
    }

    return deleteAllByIndex(r'memberId_date', values);
  }

  int deleteAllByMemberIdDateSync(
      List<int> memberIdValues, List<String> dateValues) {
    final len = memberIdValues.length;
    assert(
        dateValues.length == len, 'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([memberIdValues[i], dateValues[i]]);
    }

    return deleteAllByIndexSync(r'memberId_date', values);
  }

  Future<Id> putByMemberIdDate(Meal object) {
    return putByIndex(r'memberId_date', object);
  }

  Id putByMemberIdDateSync(Meal object, {bool saveLinks = true}) {
    return putByIndexSync(r'memberId_date', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMemberIdDate(List<Meal> objects) {
    return putAllByIndex(r'memberId_date', objects);
  }

  List<Id> putAllByMemberIdDateSync(List<Meal> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'memberId_date', objects, saveLinks: saveLinks);
  }
}

extension MealQueryWhereSort on QueryBuilder<Meal, Meal, QWhere> {
  QueryBuilder<Meal, Meal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MealQueryWhere on QueryBuilder<Meal, Meal, QWhereClause> {
  QueryBuilder<Meal, Meal, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhereClause> memberIdEqualToAnyDate(
      int memberId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'memberId_date',
        value: [memberId],
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhereClause> memberIdNotEqualToAnyDate(
      int memberId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'memberId_date',
              lower: [],
              upper: [memberId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'memberId_date',
              lower: [memberId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'memberId_date',
              lower: [memberId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'memberId_date',
              lower: [],
              upper: [memberId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhereClause> memberIdGreaterThanAnyDate(
    int memberId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'memberId_date',
        lower: [memberId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhereClause> memberIdLessThanAnyDate(
    int memberId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'memberId_date',
        lower: [],
        upper: [memberId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhereClause> memberIdBetweenAnyDate(
    int lowerMemberId,
    int upperMemberId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'memberId_date',
        lower: [lowerMemberId],
        includeLower: includeLower,
        upper: [upperMemberId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhereClause> memberIdDateEqualTo(
      int memberId, String date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'memberId_date',
        value: [memberId, date],
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhereClause> memberIdEqualToDateNotEqualTo(
      int memberId, String date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'memberId_date',
              lower: [memberId],
              upper: [memberId, date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'memberId_date',
              lower: [memberId, date],
              includeLower: false,
              upper: [memberId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'memberId_date',
              lower: [memberId, date],
              includeLower: false,
              upper: [memberId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'memberId_date',
              lower: [memberId],
              upper: [memberId, date],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MealQueryFilter on QueryBuilder<Meal, Meal, QFilterCondition> {
  QueryBuilder<Meal, Meal, QAfterFilterCondition> breakfastEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'breakfast',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> dateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> dateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> dateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> dateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> dateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> dateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> dateContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> dateMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'date',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> dateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> dateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> dinnerEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dinner',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> lunchEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lunch',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> memberIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'memberId',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> memberIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'memberId',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> memberIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'memberId',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> memberIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'memberId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MealQueryObject on QueryBuilder<Meal, Meal, QFilterCondition> {}

extension MealQueryLinks on QueryBuilder<Meal, Meal, QFilterCondition> {}

extension MealQuerySortBy on QueryBuilder<Meal, Meal, QSortBy> {
  QueryBuilder<Meal, Meal, QAfterSortBy> sortByBreakfast() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakfast', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByBreakfastDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakfast', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByDinner() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dinner', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByDinnerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dinner', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByLunch() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lunch', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByLunchDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lunch', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberId', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByMemberIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberId', Sort.desc);
    });
  }
}

extension MealQuerySortThenBy on QueryBuilder<Meal, Meal, QSortThenBy> {
  QueryBuilder<Meal, Meal, QAfterSortBy> thenByBreakfast() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakfast', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByBreakfastDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakfast', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByDinner() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dinner', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByDinnerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dinner', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByLunch() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lunch', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByLunchDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lunch', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberId', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByMemberIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberId', Sort.desc);
    });
  }
}

extension MealQueryWhereDistinct on QueryBuilder<Meal, Meal, QDistinct> {
  QueryBuilder<Meal, Meal, QDistinct> distinctByBreakfast() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'breakfast');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByDate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByDinner() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dinner');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByLunch() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lunch');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'memberId');
    });
  }
}

extension MealQueryProperty on QueryBuilder<Meal, Meal, QQueryProperty> {
  QueryBuilder<Meal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Meal, bool, QQueryOperations> breakfastProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'breakfast');
    });
  }

  QueryBuilder<Meal, String, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<Meal, bool, QQueryOperations> dinnerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dinner');
    });
  }

  QueryBuilder<Meal, bool, QQueryOperations> lunchProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lunch');
    });
  }

  QueryBuilder<Meal, int, QQueryOperations> memberIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'memberId');
    });
  }
}
