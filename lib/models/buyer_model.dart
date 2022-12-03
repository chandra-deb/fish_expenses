import 'dart:convert';

class Buyer {
  final String name;
  final int phone;
  Buyer({
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'phone': phone,
    };
  }

  factory Buyer.fromMap(Map<String, dynamic> map) {
    return Buyer(
      name: map['name'] as String,
      phone: map['phone'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Buyer.fromJson(String source) =>
      Buyer.fromMap(json.decode(source) as Map<String, dynamic>);
}
