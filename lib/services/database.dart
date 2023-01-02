import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/expense_model.dart';
import '../models/sell_model.dart';
import 'auth_service.dart';

const _usersCollectionName = 'users';
const _buyerNamesField = 'buyerNames';
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

// UserData _userData = UserData(fishNames: fishNames, expenseNames: expenseNames)

  List<String> fishNames = [];
  List<String> buyerNames = [];
  List<Expense> expenses = [];
  List<Sell> sells = [];
  List<String> expenseNames = [];

  bool sellsDataChanged = true;
  bool expensesDataChanged = true;
  bool fishNamesDataChanged = true;
  bool buyerNamesDataChanged = true;

  DB._privateConstructor();
  static final DB _db = DB._privateConstructor();

  factory DB() {
    return _db;
  }

  Future<void> addUser(String userUid) async {
    await _collectionRef.doc(userUid).set(
        {_fishNamesField: [], _expenseNamesField: [], _buyerNamesField: []});
  }

// FishNames

  Future<List<String>> get getFishNames async {
    if (fishNamesDataChanged) {
      var rawData = await _userRef.get();
      var rawFishNames = rawData.get(_fishNamesField) as List;
      fishNames = rawFishNames.map((fishName) => fishName.toString()).toList();
      fishNamesDataChanged = false;
    }
    return fishNames;
  }

  Future<void> addFishName(String fishName) async {
    fishNames = await getFishNames;
    if (fishNames.contains(fishName)) return;
    fishNames.add(fishName);
    fishNamesDataChanged = true;
    await _userRef.update({_fishNamesField: fishNames});
  }

  Future<void> removeFishName(String fishName) async {
    if (fishNames.contains(fishName)) {
      fishNames.remove(fishName);
      fishNamesDataChanged = true;
      await _userRef.update({_fishNamesField: fishNames});
    }
  }
// FishNames

// Buyers

  Future<List<String>> get getBuyerNames async {
    if (buyerNamesDataChanged) {
      final rawData = await _userRef.get();
      final rawBuyers = rawData.get(_buyerNamesField) as List;
      buyerNames = rawBuyers.map((buyerName) => buyerName.toString()).toList();
      buyerNamesDataChanged = false;
    }
    return buyerNames;
  }

  Future<void> addBuyerName(String buyerName) async {
    final buyerNames = await getBuyerNames;

    if (buyerNames.contains(buyerName)) return;
    buyerNames.add(buyerName);
    buyerNamesDataChanged = true;
    await _userRef.update({_buyerNamesField: buyerNames});
  }

  Future<void> removeBuyerName(String buyerName) async {
    if (buyerNames.contains(buyerName)) {
      buyerNames.remove(buyerName);
      buyerNamesDataChanged = true;
      await _userRef.update({_buyerNamesField: buyerNames});
    }
  }

// Buyers

// Sells Start
  Future<List<Sell>> get getSells async {
    if (sellsDataChanged) {
      var snap = await _sellsCollectionRef.get();
      sells = snap.docs.map((e) {
        return Sell.fromMap(e.data());
      }).toList();

      sells.sort((a, b) => b.date.compareTo(a.date));
      sellsDataChanged = false;
    }
    return sells;
  }

  Future<void> addSell({
    required String buyerName,
    required String fishName,
    required int quantity,
    required int price,
    required DateTime date,
    required bool isSmallFish,
  }) async {
    final sell = Sell(
      id: const Uuid().v1(),
      buyerName: buyerName,
      fishName: fishName,
      date: date,
      price: price,
      quantity: quantity,
      smallFish: isSmallFish,
    );
    sellsDataChanged = true;
    await _sellsCollectionRef.doc(sell.id).set(sell.toMap());
  }

// Sells End

// Expenses
  Future<List<Expense>> get getExpenses async {
    if (expensesDataChanged) {
      var snap = await _expensesCollectionRef.get();
      expenses = snap.docs.map((e) {
        return Expense.fromMap(e.data());
      }).toList();

      expenses.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      expensesDataChanged = false;
    }
    return expenses;
  }

  Future<void> addExpense(
    String name,
    int price,
    String quantity,
  ) async {
    final expense = Expense(
      id: const Uuid().v1(),
      name: name,
      price: price,
      quantity: quantity,
      dateTime: DateTime.now(),
    );
    expensesDataChanged = true;
    await _expensesCollectionRef.doc(expense.id).set(expense.toMap());
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
