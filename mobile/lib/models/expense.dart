class Expense {
  final String? id;
  final String description;
  final double amount;
  final String expenseDate;
  final String? category;
  final int month;
  final int year;
  final String? notes;
  final String? createdAt;
  final String? status;

  const Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.expenseDate,
    this.category,
    required this.month,
    required this.year,
    this.notes,
    this.createdAt,
    this.status,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String?,
        description: json['description'] as String,
        amount: (json['amount'] as num).toDouble(),
        expenseDate: json['expenseDate'] as String,
        category: json['category'] as String?,
        month: json['month'] as int,
        year: json['year'] as int,
        notes: json['notes'] as String?,
        createdAt: json['createdAt'] as String?,
        status: json['status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'amount': amount,
        'expenseDate': expenseDate,
        if (category != null) 'category': category,
        'month': month,
        'year': year,
        if (notes != null) 'notes': notes,
      };

  Expense copyWith({
    String? id,
    String? description,
    double? amount,
    String? expenseDate,
    String? category,
    int? month,
    int? year,
    String? notes,
    String? status,
  }) =>
      Expense(
        id: id ?? this.id,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        expenseDate: expenseDate ?? this.expenseDate,
        category: category ?? this.category,
        month: month ?? this.month,
        year: year ?? this.year,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        status: status ?? this.status,
      );
}
