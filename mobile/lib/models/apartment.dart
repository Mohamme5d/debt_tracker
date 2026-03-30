class Apartment {
  final String? id;
  final String name;
  final String? address;
  final String? description;
  final String? notes;
  final String? createdAt;

  const Apartment({
    this.id,
    required this.name,
    this.address,
    this.description,
    this.notes,
    this.createdAt,
  });

  factory Apartment.fromJson(Map<String, dynamic> json) => Apartment(
        id: json['id'] as String?,
        name: json['name'] as String,
        address: json['address'] as String?,
        description: json['description'] as String?,
        notes: json['notes'] as String?,
        createdAt: json['createdAt'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        if (address != null) 'address': address,
        if (description != null) 'description': description,
        if (notes != null) 'notes': notes,
      };

  Apartment copyWith({
    String? id,
    String? name,
    String? address,
    String? description,
    String? notes,
  }) =>
      Apartment(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address ?? this.address,
        description: description ?? this.description,
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );

  @override
  String toString() => name;
}
