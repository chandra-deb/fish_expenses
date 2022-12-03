// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:fish_expenses/models/buyer_model.dart';
import 'package:fish_expenses/models/expense_model.dart';
import 'package:fish_expenses/models/sell_model.dart';

class Farmer {
  final List<Expense> expenses;
  final List<Sell> sells;
  final List<Buyer> buyers;
  final List<String> fishNames;
  Farmer({
    required this.expenses,
    required this.sells,
    required this.buyers,
    required this.fishNames,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'expenses': expenses.map((x) => x.toMap()).toList(),
      'sells': sells.map((x) => x.toMap()).toList(),
      'buyers': buyers.map((x) => x.toMap()).toList(),
      'fishNames': fishNames,
    };
  }

  factory Farmer.fromMap(Map<String, dynamic> map) {
    return Farmer(
      expenses: List<Expense>.from(
        (map['expenses'] as List<int>).map<Expense>(
          (x) => Expense.fromMap(x as Map<String, dynamic>),
        ),
      ),
      sells: List<Sell>.from(
        (map['sells'] as List<int>).map<Sell>(
          (x) => Sell.fromMap(x as Map<String, dynamic>),
        ),
      ),
      buyers: List<Buyer>.from(
        (map['buyers'] as List<int>).map<Buyer>(
          (x) => Buyer.fromMap(x as Map<String, dynamic>),
        ),
      ),
      fishNames: List<String>.from(
        (map['fishNames'] as List<String>),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Farmer.fromJson(String source) =>
      Farmer.fromMap(json.decode(source) as Map<String, dynamic>);
}
