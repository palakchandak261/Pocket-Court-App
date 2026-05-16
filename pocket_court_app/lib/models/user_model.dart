class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String city;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.city = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? json['_id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        city: json['city'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'city': city,
      };
}
