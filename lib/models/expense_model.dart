import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Expense {
  final String id;
  final String name;
  final int price;
  final String quantity;
  final DateTime dateTime;
  const Expense({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'dateTime': dateTime,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    var timeStamp = map['dateTime'] as Timestamp;
    return Expense(
      id: map['id'] as String,
      name: map['name'] as String,
      price: map['price'] as int,
      quantity: map['quantity'] as String,
      dateTime: timeStamp.toDate(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Expense.fromJson(String source) =>
      Expense.fromMap(json.decode(source) as Map<String, dynamic>);
}
