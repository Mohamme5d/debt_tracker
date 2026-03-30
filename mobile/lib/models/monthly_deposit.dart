class MonthlyDeposit {
  final String? id;
  final int depositMonth;
  final int depositYear;
  final double amount;
  final String? notes;
  final String? createdAt;
  final String? status;

  const MonthlyDeposit({
    this.id,
    required this.depositMonth,
    required this.depositYear,
    required this.amount,
    this.notes,
    this.createdAt,
    this.status,
  });

  factory MonthlyDeposit.fromJson(Map<String, dynamic> json) => MonthlyDeposit(
        id: json['id'] as String?,
        depositMonth: json['depositMonth'] as int,
        depositYear: json['depositYear'] as int,
        amount: (json['amount'] as num).toDouble(),
        notes: json['notes'] as String?,
        createdAt: json['createdAt'] as String?,
        status: json['status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'depositMonth': depositMonth,
        'depositYear': depositYear,
        'amount': amount,
        if (notes != null) 'notes': notes,
      };

  MonthlyDeposit copyWith({
    String? id,
    int? depositMonth,
    int? depositYear,
    double? amount,
    String? notes,
    String? status,
  }) =>
      MonthlyDeposit(
        id: id ?? this.id,
        depositMonth: depositMonth ?? this.depositMonth,
        depositYear: depositYear ?? this.depositYear,
        amount: amount ?? this.amount,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        status: status ?? this.status,
      );
}
