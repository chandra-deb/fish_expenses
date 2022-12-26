// ignore_for_file: public_member_api_docs, sort_constructors_first
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

  @override
  bool operator ==(covariant Buyer other) {
    if (identical(this, other)) return true;

    return other.name == name && other.phone == phone;
  }

  @override
  int get hashCode => name.hashCode ^ phone.hashCode;
}
