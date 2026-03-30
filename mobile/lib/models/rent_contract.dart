class RentContract {
  final String? id;
  final String renterId;
  final String renterName;
  final String apartmentId;
  final String apartmentName;
  final double monthlyRent;
  final String startDate;
  final String? endDate;
  final bool isActive;
  final String? notes;
  final String? status;
  final String? createdAt;

  const RentContract({
    this.id,
    required this.renterId,
    required this.renterName,
    required this.apartmentId,
    required this.apartmentName,
    required this.monthlyRent,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.notes,
    this.status,
    this.createdAt,
  });

  factory RentContract.fromJson(Map<String, dynamic> json) => RentContract(
        id: json['id'] as String?,
        renterId: json['renterId'] as String,
        renterName: json['renterName'] as String? ?? '',
        apartmentId: json['apartmentId'] as String,
        apartmentName: json['apartmentName'] as String? ?? '',
        monthlyRent: (json['monthlyRent'] as num).toDouble(),
        startDate: json['startDate'] as String,
        endDate: json['endDate'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        notes: json['notes'] as String?,
        status: json['status'] as String?,
        createdAt: json['createdAt'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'renterId': renterId,
        'apartmentId': apartmentId,
        'monthlyRent': monthlyRent,
        'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        if (notes != null) 'notes': notes,
      };

  RentContract copyWith({
    String? id,
    String? renterId,
    String? renterName,
    String? apartmentId,
    String? apartmentName,
    double? monthlyRent,
    String? startDate,
    String? endDate,
    bool? isActive,
    String? notes,
    String? status,
  }) =>
      RentContract(
        id: id ?? this.id,
        renterId: renterId ?? this.renterId,
        renterName: renterName ?? this.renterName,
        apartmentId: apartmentId ?? this.apartmentId,
        apartmentName: apartmentName ?? this.apartmentName,
        monthlyRent: monthlyRent ?? this.monthlyRent,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        isActive: isActive ?? this.isActive,
        notes: notes ?? this.notes,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  String get displayLabel => '$renterName — $apartmentName';

  @override
  String toString() => displayLabel;
}
