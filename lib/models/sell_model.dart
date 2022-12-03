import 'dart:convert';

class Sell {
  final String buyerName;
  final String fishName;
  final DateTime date;
  final int price;
  final int quantity;
  final bool smallFish;
  Sell({
    required this.buyerName,
    required this.fishName,
    required this.date,
    required this.price,
    required this.quantity,
    required this.smallFish,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'buyerName': buyerName,
      'fishName': fishName,
      'date': date.millisecondsSinceEpoch,
      'price': price,
      'quantity': quantity,
      'smallFish': smallFish,
    };
  }

  factory Sell.fromMap(Map<String, dynamic> map) {
    return Sell(
      buyerName: map['buyerName'] as String,
      fishName: map['fishName'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      price: map['price'] as int,
      quantity: map['quantity'] as int,
      smallFish: map['smallFish'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Sell.fromJson(String source) =>
      Sell.fromMap(json.decode(source) as Map<String, dynamic>);
}
