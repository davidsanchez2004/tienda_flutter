class Address {
  final String id;
  final String? userId;
  final String name;
  final String email;
  final String phone;
  final String street;
  final String number;
  final String? apartment;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;
  final String? createdAt;

  const Address({
    required this.id,
    this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.street,
    required this.number,
    this.apartment,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'ES',
    this.isDefault = false,
    this.createdAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? '',
      userId: json['user_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      street: json['street'] ?? '',
      number: json['number'] ?? '',
      apartment: json['apartment'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postal_code'] ?? '',
      country: json['country'] ?? 'ES',
      isDefault: json['is_default'] ?? false,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'street': street,
    'number': number,
    'apartment': apartment,
    'city': city,
    'state': state,
    'postal_code': postalCode,
    'country': country,
    'is_default': isDefault,
  };

  String get fullAddress => '$street $number${apartment != null ? ', $apartment' : ''}, $postalCode $city, $state';
}
