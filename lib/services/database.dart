import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/buyer_model.dart';
import '../models/expense_model.dart';
import '../models/sell_model.dart';
import 'auth_service.dart';

const _usersCollectionName = 'users';
const _buyersField = 'buyers';
const _fishNamesField = 'fishNames';
const _sellsCollectionName = 'sells';
const _expensesCollectionName = 'expenses';
const _expenseNamesField = 'expenseNames';

class DB {
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection(_usersCollectionName);
  final DocumentReference _userRef = FirebaseFirestore.instance
      .collection(_usersCollectionName)
      .doc(AuthService().currentUser!.uid);
  late final _expensesCollectionRef =
      _userRef.collection(_expensesCollectionName);
  late final _sellsCollectionRef = _userRef.collection(_sellsCollectionName);

  List<String> fishNames = [];
  List<Buyer> buyers = [];
  List<String> buyerNames = [];
  List<Expense> expenses = [];
  List<Sell> sells = [];
  List<String> expenseNames = [];

  DB._privateConstructor();
  static final DB _db = DB._privateConstructor();

  factory DB() {
    return _db;
  }

  Future<void> addUser(String userUid) async {
    await _collectionRef
        .doc(userUid)
        .set({_fishNamesField: [], _expenseNamesField: [], _buyersField: []});
  }

// FishNames
  Stream<List<String>> get getFishNamesStream {
    return _userRef.snapshots().map(
      (event) {
        var rawData = event.get(_fishNamesField) as List;
        fishNames = rawData.map((e) => e.toString()).toList();
        return fishNames;
      },
    );
  }

  Future<List<String>> get getFishNames async {
    var rawData = await _userRef.get();
    var rawFishNames = rawData.get(_fishNamesField) as List;
    fishNames = rawFishNames.map((fishName) => fishName.toString()).toList();
    return fishNames;
  }

  Future<void> addFishName(String fishName) async {
    fishNames = await getFishNames;
    if (fishNames.contains(fishName)) return;
    fishNames.add(fishName);
    await _userRef.update({_fishNamesField: fishNames});
  }

  Future<void> removeFishName(String fishName) async {
    if (fishNames.contains(fishName)) {
      fishNames.remove(fishName);
      await _userRef.update({_fishNamesField: fishNames});
    }
  }
// FishNames

// Buyers
  Stream<List<Buyer>> get getBuyersStream {
    return _userRef.snapshots().map(
      (event) {
        var rawBuyers = event.get(_buyersField) as List;
        buyers = rawBuyers.map((e) => Buyer.fromMap(e)).toList();
        return buyers;
      },
    );
  }

  Future<List<String>> get getBuyerNames async {
    final rawData = await _userRef.get();
    final rawBuyers = rawData.get(_buyersField) as List;
    buyerNames = rawBuyers.map((buyer) => Buyer.fromMap(buyer).name).toList();
    return buyerNames;

    // return buyers.map((buyer) => buyer.name).toList();
  }

  Future<List<Buyer>> get getBuyers async {
    var rd = await _userRef.get();
    var rc = rd.get(_buyersField) as List;
    var kc = rc.map((e) => Buyer.fromMap(e)).toList();
    return kc;

    // userRef.snapshots().map(
    //   (event) {
    //     var rawData = event.get('buyers') as List;
    //     buyers = rawData.map((e) => Buyer.fromMap(e)).toList();
    //     return buyers;
    //   },
    // );
  }

  Future<void> addBuyer(Buyer buyer) async {
    if (buyers.contains(buyer)) return;
    buyers.add(buyer);
    final updatedBuyers = buyers.map((buyer) => buyer.toMap()).toList();
    await _userRef.update({_buyersField: updatedBuyers});
  }

  Future<void> removeBuyer(Buyer buyer) async {
    buyers = buyers.where(
      (byr) {
        if (byr.name != buyer.name) return true;
        return false;
      },
    ).toList();
    final updatedBuyers = buyers.map((buyer) => buyer.toMap()).toList();
    await _userRef.update({_buyersField: updatedBuyers});
  }
  // Buyers

// Sells Start
  Stream<List<Sell>> get getSellsStream {
    return _sellsCollectionRef.snapshots().map(
      (element) {
        sells = element.docs.map((e) {
          return Sell.fromMap(e.data());
        }).toList();
        sells.sort((a, b) => b.date.compareTo(a.date));
        return sells;
      },
    );
  }

  void addSell({
    required String buyerName,
    required String fishName,
    required int quantity,
    required int price,
    required DateTime date,
    required bool isSmallFish,
  }) {
    final sell = Sell(
      id: const Uuid().v1(),
      buyerName: buyerName,
      fishName: fishName,
      date: date,
      price: price,
      quantity: quantity,
      smallFish: isSmallFish,
    );
    _sellsCollectionRef.doc(sell.id).set(sell.toMap());
  }

// Sells End

// Expenses
  Stream<List<Expense>> get getExpensesStream {
    return _expensesCollectionRef.snapshots().map(
      (element) {
        expenses = element.docs.map((e) {
          return Expense.fromMap(e.data());
        }).toList();
        expenses.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        return expenses;
      },
    );
  }

  Future<void> addExpense(
    String name,
    int price,
    int quantity,
  ) async {
    final expense = Expense(
      id: const Uuid().v1(),
      name: name,
      price: price,
      quantity: quantity,
      dateTime: DateTime.now(),
    );
    await _expensesCollectionRef
        .doc(
          expense.id,
        )
        .set(
          expense.toMap(),
        );
  }

  Future<void> removeExpense(Expense expense) async {
    await _expensesCollectionRef
        .doc(
          expense.id,
        )
        .delete()
        .whenComplete(
          () => print('Delete ${expense.id}'),
        );
  }

// ExpenseNames
  Future<List<String>> get getExpenseNames async {
    var data = await _userRef.get();
    var names = data.get(_expenseNamesField) as List;
    var expenseNames = names.map((e) => e as String).toList();
    return expenseNames;
  }

  Future<void> addExpenseName(String expenseName) async {
    expenseNames = await getExpenseNames;
    if (expenseNames.contains(expenseName)) return;
    expenseNames.add(expenseName);
    await _userRef.update({_expenseNamesField: expenseNames});
  }

  Future<void> removeExpenseName(String expenseName) async {
    if (expenseNames.contains(expenseName)) {
      expenseNames.remove(expenseName);
      await _userRef.update({_expenseNamesField: expenseNames});
    }
  }
// ExpenseNames

}
