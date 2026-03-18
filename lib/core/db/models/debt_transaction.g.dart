// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run build_runner build --delete-conflicting-outputs

part of 'debt_transaction.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDebtTransactionCollection on Isar {
  IsarCollection<DebtTransaction> get debtTransactions => this.collection();
}

const DebtTransactionSchema = CollectionSchema(
  name: r'DebtTransaction',
  id: 3271296265498498197,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'amountPaid': PropertySchema(
      id: 1,
      name: r'amountPaid',
      type: IsarType.double,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'dueDate': PropertySchema(
      id: 3,
      name: r'dueDate',
      type: IsarType.dateTime,
    ),
    r'isSettled': PropertySchema(
      id: 4,
      name: r'isSettled',
      type: IsarType.bool,
    ),
    r'note': PropertySchema(
      id: 5,
      name: r'note',
      type: IsarType.string,
    ),
    r'remaining': PropertySchema(
      id: 6,
      name: r'remaining',
      type: IsarType.double,
    ),
    r'status': PropertySchema(
      id: 7,
      name: r'status',
      type: IsarType.byte,
    ),
    r'type': PropertySchema(
      id: 8,
      name: r'type',
      type: IsarType.byte,
    )
  },
  estimateSize: _debtTransactionEstimateSize,
  serialize: _debtTransactionSerialize,
  deserialize: _debtTransactionDeserialize,
  deserializeProp: _debtTransactionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'person': LinkSchema(
      id: -5765036756576079499,
      name: r'person',
      target: r'Person',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _debtTransactionGetId,
  getLinks: _debtTransactionGetLinks,
  attach: _debtTransactionAttach,
  version: '3.1.0+1',
);

int _debtTransactionEstimateSize(
  DebtTransaction object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _debtTransactionSerialize(
  DebtTransaction object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeDouble(offsets[1], object.amountPaid);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeDateTime(offsets[3], object.dueDate);
  writer.writeBool(offsets[4], object.isSettled);
  writer.writeString(offsets[5], object.note);
  writer.writeDouble(offsets[6], object.remaining);
  writer.writeByte(offsets[7], object.status.index);
  writer.writeByte(offsets[8], object.type.index);
}

DebtTransaction _debtTransactionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DebtTransaction();
  object.amount = reader.readDouble(offsets[0]);
  object.amountPaid = reader.readDouble(offsets[1]);
  object.date = reader.readDateTime(offsets[2]);
  object.dueDate = reader.readDateTimeOrNull(offsets[3]);
  object.id = id;
  object.note = reader.readStringOrNull(offsets[5]);
  object.status =
      _DebtTransactionstatusValueEnumMap[reader.readByteOrNull(offsets[7])] ??
          TransactionStatus.active;
  object.type =
      _DebtTransactiontypeValueEnumMap[reader.readByteOrNull(offsets[8])] ??
          TransactionType.debt;
  return object;
}

P _debtTransactionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (_DebtTransactionstatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          TransactionStatus.active) as P;
    case 8:
      return (_DebtTransactiontypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          TransactionType.debt) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DebtTransactionstatusValueEnumMap = {
  0: TransactionStatus.active,
  1: TransactionStatus.settled,
  2: TransactionStatus.overdue,
};

const _DebtTransactiontypeValueEnumMap = {
  0: TransactionType.debt,
  1: TransactionType.loan,
};

Id _debtTransactionGetId(DebtTransaction object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _debtTransactionGetLinks(DebtTransaction object) {
  return [object.person];
}

void _debtTransactionAttach(
    IsarCollection<dynamic> col, Id id, DebtTransaction object) {
  object.id = id;
  object.person.attach(col, col.isar.collection<Person>(), r'person', id);
}

extension DebtTransactionQueryWhereSort
    on QueryBuilder<DebtTransaction, DebtTransaction, QWhere> {
  QueryBuilder<DebtTransaction, DebtTransaction, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DebtTransactionQueryWhere
    on QueryBuilder<DebtTransaction, DebtTransaction, QWhereClause> {
  QueryBuilder<DebtTransaction, DebtTransaction, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }
}

extension DebtTransactionQueryFilter
    on QueryBuilder<DebtTransaction, DebtTransaction, QFilterCondition> {
  QueryBuilder<DebtTransaction, DebtTransaction, QAfterFilterCondition>
      amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DebtTransaction, DebtTransaction, QAfterFilterCondition>
      amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DebtTransaction, DebtTransaction, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DebtTransaction, DebtTransaction, QAfterFilterCondition>
      statusEqualTo(TransactionStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value.index,
      ));
    });
  }

  QueryBuilder<DebtTransaction, DebtTransaction, QAfterFilterCondition>
      typeEqualTo(TransactionType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value.index,
      ));
    });
  }

  QueryBuilder<DebtTransaction, DebtTransaction, QAfterFilterCondition>
      noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<DebtTransaction, DebtTransaction, QAfterFilterCondition>
      dueDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dueDate',
      ));
    });
  }

  QueryBuilder<DebtTransaction, DebtTransaction, QAfterFilterCondition>
      dueDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dueDate',
      ));
    });
  }
}

extension DebtTransactionQueryObject
    on QueryBuilder<DebtTransaction, DebtTransaction, QFilterCondition> {}

extension DebtTransactionQueryLinks
    on QueryBuilder<DebtTransaction, DebtTransaction, QFilterCondition> {
  QueryBuilder<DebtTransaction, DebtTransaction, QAfterFilterCondition> person(
      FilterQuery<Person> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'person');
    });
  }

  QueryBuilder<DebtTransaction, DebtTransaction, QAfterFilterCondition>
      personIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'person', 0, true, 0, true);
    });
  }
}

extension DebtTransactionQuerySortBy
    on QueryBuilder<DebtTransaction, DebtTransaction, QSortBy> {
  QueryBuilder<DebtTransaction, DebtTransaction, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DebtTransaction, DebtTransaction, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DebtTransaction, DebtTransaction, QAfterSortBy>
      sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }
}

extension DebtTransactionQuerySortThenBy
    on QueryBuilder<DebtTransaction, DebtTransaction, QSortThenBy> {
  QueryBuilder<DebtTransaction, DebtTransaction, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DebtTransaction, DebtTransaction, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }
}

extension DebtTransactionQueryWhereDistinct
    on QueryBuilder<DebtTransaction, DebtTransaction, QDistinct> {}

extension DebtTransactionQueryProperty
    on QueryBuilder<DebtTransaction, DebtTransaction, QQueryProperty> {
  QueryBuilder<DebtTransaction, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DebtTransaction, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<DebtTransaction, double, QQueryOperations>
      amountPaidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amountPaid');
    });
  }

  QueryBuilder<DebtTransaction, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<DebtTransaction, TransactionStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<DebtTransaction, TransactionType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
