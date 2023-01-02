import 'dart:convert';

import 'package:flutter/foundation.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserData {
  final List<String> fishNames;
  final List<String> expenseNames;
  final List<String> buyerNames;

  UserData({
    required this.fishNames,
    required this.expenseNames,
    required this.buyerNames,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fishNames': fishNames,
      'expenseNames': expenseNames,
      'buyerNames': buyerNames,
    };
  }

  factory UserData.fromMap(Map<dynamic, dynamic> map) {
    var rawFishNames = map['fishNames'] as List<dynamic>;
    var rawExpenseNames = map['expenseNames'] as List<dynamic>;
    var rawBuyerNames = map['buyerNames'] as List<dynamic>;
    var fishNames = rawFishNames.map((e) => e.toString()).toList();
    var expenseNames = rawExpenseNames.map((e) => e.toString()).toList();
    var buyerNames = rawBuyerNames.map((e) => e.toString()).toList();

    return UserData(
      fishNames: fishNames,
      expenseNames: expenseNames,
      buyerNames: buyerNames,
    );
  }

  UserData copyWith({
    List<String>? fishNames,
    List<String>? expenseNames,
    List<String>? buyerNames,
  }) {
    return UserData(
      fishNames: fishNames ?? this.fishNames,
      expenseNames: expenseNames ?? this.expenseNames,
      buyerNames: buyerNames ?? this.buyerNames,
    );
  }

  @override
  bool operator ==(covariant UserData other) {
    if (identical(this, other)) return true;

    return listEquals(other.fishNames, fishNames) &&
        listEquals(other.expenseNames, expenseNames);
  }

  @override
  int get hashCode => fishNames.hashCode ^ expenseNames.hashCode;

  String toJson() => json.encode(toMap());

  factory UserData.fromJson(String source) =>
      UserData.fromMap(json.decode(source) as Map<String, dynamic>);
}
