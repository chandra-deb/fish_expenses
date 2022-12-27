// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';

class Sell {
  final String id;
  final String buyerName;
  final String fishName;
  final DateTime date;
  final int price;
  final int quantity;
  final bool smallFish;
  Sell({
    required this.id,
    required this.buyerName,
    required this.fishName,
    required this.date,
    required this.price,
    required this.quantity,
    required this.smallFish,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'buyerName': buyerName,
      'fishName': fishName,
      'date': date,
      'price': price,
      'quantity': quantity,
      'smallFish': smallFish,
    };
  }

  factory Sell.fromMap(Map<String, dynamic> map) {
    var timeStamp = map['date'] as Timestamp;

    return Sell(
      id: map['id'] as String,
      buyerName: map['buyerName'] as String,
      fishName: map['fishName'] as String,
      date: timeStamp.toDate(),
      price: map['price'] as int,
      quantity: map['quantity'] as int,
      smallFish: map['smallFish'] as bool,
    );
  }
}
