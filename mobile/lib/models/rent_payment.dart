class RentPayment {
  final String? id;
  final String? contractId;
  final String? renterId;
  final String apartmentId;
  final int paymentMonth;
  final int paymentYear;
  final double rentAmount;
  final double outstandingBefore;
  final double amountPaid;
  final double outstandingAfter;
  final bool isVacant;
  final String? notes;
  final String? createdAt;
  final String? renterName;
  final String? apartmentName;
  final String? status;

  const RentPayment({
    this.id,
    this.contractId,
    this.renterId,
    required this.apartmentId,
    required this.paymentMonth,
    required this.paymentYear,
    required this.rentAmount,
    this.outstandingBefore = 0.0,
    this.amountPaid = 0.0,
    this.outstandingAfter = 0.0,
    this.isVacant = false,
    this.notes,
    this.createdAt,
    this.renterName,
    this.apartmentName,
    this.status,
  });

  factory RentPayment.fromJson(Map<String, dynamic> json) => RentPayment(
        id: json['id'] as String?,
        contractId: json['contractId'] as String?,
        renterId: json['renterId'] as String?,
        apartmentId: json['apartmentId'] as String,
        paymentMonth: json['paymentMonth'] as int,
        paymentYear: json['paymentYear'] as int,
        rentAmount: (json['rentAmount'] as num).toDouble(),
        outstandingBefore: (json['outstandingBefore'] as num).toDouble(),
        amountPaid: (json['amountPaid'] as num).toDouble(),
        outstandingAfter: (json['outstandingAfter'] as num).toDouble(),
        isVacant: json['isVacant'] as bool? ?? false,
        notes: json['notes'] as String?,
        createdAt: json['createdAt'] as String?,
        renterName: json['renterName'] as String?,
        apartmentName: json['apartmentName'] as String?,
        status: json['status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (contractId != null) 'contractId': contractId,
        if (renterId != null) 'renterId': renterId,
        'apartmentId': apartmentId,
        'paymentMonth': paymentMonth,
        'paymentYear': paymentYear,
        'rentAmount': rentAmount,
        'outstandingBefore': outstandingBefore,
        'amountPaid': amountPaid,
        'isVacant': isVacant,
        if (notes != null) 'notes': notes,
      };

  RentPayment copyWith({
    String? id,
    String? contractId,
    String? renterId,
    String? apartmentId,
    int? paymentMonth,
    int? paymentYear,
    double? rentAmount,
    double? outstandingBefore,
    double? amountPaid,
    double? outstandingAfter,
    bool? isVacant,
    String? notes,
    String? status,
  }) =>
      RentPayment(
        id: id ?? this.id,
        contractId: contractId ?? this.contractId,
        renterId: renterId ?? this.renterId,
        apartmentId: apartmentId ?? this.apartmentId,
        paymentMonth: paymentMonth ?? this.paymentMonth,
        paymentYear: paymentYear ?? this.paymentYear,
        rentAmount: rentAmount ?? this.rentAmount,
        outstandingBefore: outstandingBefore ?? this.outstandingBefore,
        amountPaid: amountPaid ?? this.amountPaid,
        outstandingAfter: outstandingAfter ?? this.outstandingAfter,
        isVacant: isVacant ?? this.isVacant,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        renterName: renterName,
        apartmentName: apartmentName,
        status: status ?? this.status,
      );
}
