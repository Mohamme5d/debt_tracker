class Renter {
  final String? id;
  final String name;
  final String? phone;
  final String? email;
  final String? notes;
  final String? createdAt;
  final String? status;

  const Renter({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.notes,
    this.createdAt,
    this.status,
  });

  factory Renter.fromJson(Map<String, dynamic> json) => Renter(
        id: json['id'] as String?,
        name: json['name'] as String,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        notes: json['notes'] as String?,
        createdAt: json['createdAt'] as String?,
        status: json['status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (notes != null) 'notes': notes,
      };

  Renter copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? notes,
    String? status,
  }) =>
      Renter(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        status: status ?? this.status,
      );

  @override
  String toString() => name;
}
