import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/expense_model.dart';
import '../models/sell_model.dart';
import '../models/user_data_model.dart';
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

  List<Expense> expenses = [];
  List<Sell> sells = [];
  late String _masterPassword;

  bool _sellsDataChanged = true;
  bool _expensesDataChanged = true;
  // bool _fishNamesDataChanged = true;
  // bool buyerNamesDataChanged = true;
  bool _userDataChanged = true;

  UserData _userData = UserData(
    fishNames: [],
    expenseNames: [],
    buyerNames: [],
  );

  DB._privateConstructor();
  static final DB _db = DB._privateConstructor();

  factory DB() {
    return _db;
  }

  String get masterPassword {
    return _masterPassword;
  }

  Future<void> addUser(String userUid) async {
    await _collectionRef.doc(userUid).set({
      _fishNamesField: [],
      _expenseNamesField: [],
      _buyerNamesField: [],
      'masterPassword': ''
    });
  }

  Future<UserData> getUserData() async {
    var rawData = await _userRef.get().then((value) => value.data() as Map);
    _userData = UserData.fromMap(rawData);
    _masterPassword = rawData['masterPassword'] as String;
    return _userData;
    // fishNames = rawData[_fishNamesField];
    // buyerNames = rawData[_fishNamesField];
    // expenseNames = rawData[_expenseNamesField];

    // userData = userData.copyWith(
    //   expenseNames: expenseNames,
    //   fishNames: fishNames,
    // );
  }

// FishNames

  Future<List<String>> get getFishNames async {
    if (_userDataChanged) {
      await getUserData();
      _userDataChanged = false;
    }

    return _userData.fishNames;
  }

  Future<void> addFishName(String fishName) async {
    var fishNames = await getFishNames;
    if (fishNames.contains(fishName)) return;
    fishNames.add(fishName);
    _userData = _userData.copyWith(fishNames: fishNames);
    _userDataChanged = true;
    await _userRef.update({_fishNamesField: _userData.fishNames});
  }

  Future<void> removeFishName(String fishName) async {
    var fishNames = await getFishNames;
    if (fishNames.contains(fishName)) {
      fishNames.remove(fishName);
      _userData = _userData.copyWith(fishNames: fishNames);
      _userDataChanged = true;
      await _userRef.update({_fishNamesField: _userData.fishNames});
    }
  }
// FishNames

// Buyers

  Future<List<String>> get getBuyerNames async {
    if (_userDataChanged) {
      await getUserData();
      _userDataChanged = false;
    }
    return _userData.buyerNames;
  }

  Future<void> addBuyerName(String buyerName) async {
    final buyerNames = await getBuyerNames;

    if (buyerNames.contains(buyerName)) return;
    buyerNames.add(buyerName);
    _userData = _userData.copyWith(buyerNames: buyerNames);
    _userDataChanged = true;
    await _userRef.update({_buyerNamesField: _userData.buyerNames});
  }

  Future<void> removeBuyerName(String buyerName) async {
    final buyerNames = await getBuyerNames;
    if (buyerNames.contains(buyerName)) {
      buyerNames.remove(buyerName);
      _userData = _userData.copyWith(buyerNames: buyerNames);
      _userDataChanged = true;
      await _userRef.update({_buyerNamesField: _userData.buyerNames});
    }
  }

// Buyers

// Sells Start
  Future<List<Sell>> get getSells async {
    if (_userDataChanged) {
      await getUserData();
      _userDataChanged = false;
    }
    if (_sellsDataChanged) {
      var snap = await _sellsCollectionRef.get();
      sells = snap.docs.map((e) {
        return Sell.fromMap(e.data());
      }).toList();

      sells.sort((a, b) => b.date.compareTo(a.date));
      _sellsDataChanged = false;
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
    _sellsDataChanged = true;
    await _sellsCollectionRef.doc(sell.id).set(sell.toMap());
  }

  Future<void> removeSell(String id) async {
    _sellsDataChanged = true;
    await _sellsCollectionRef
        .doc(
          id,
        )
        .delete();
  }

// Sells End

// Expenses
  Future<List<Expense>> get getExpenses async {
    if (_expensesDataChanged) {
      var snap = await _expensesCollectionRef.get();
      expenses = snap.docs.map((e) {
        return Expense.fromMap(e.data());
      }).toList();

      expenses.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      _expensesDataChanged = false;
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
    _expensesDataChanged = true;
    await _expensesCollectionRef.doc(expense.id).set(expense.toMap());
  }

  Future<void> removeExpense(String id) async {
    _expensesDataChanged = true;
    await _expensesCollectionRef
        .doc(
          id,
        )
        .delete();
  }

// ExpenseNames
  Future<List<String>> get getExpenseNames async {
    if (_userDataChanged) {
      await getUserData();
      _userDataChanged = false;
    }

    return _userData.expenseNames;
  }

  Future<void> addExpenseName(String expenseName) async {
    final expenseNames = await getExpenseNames;
    if (expenseNames.contains(expenseName)) return;
    expenseNames.add(expenseName);
    _userData = _userData.copyWith(expenseNames: expenseNames);
    _userDataChanged = true;
    await _userRef.update({_expenseNamesField: _userData.expenseNames});
  }

  Future<void> removeExpenseName(String expenseName) async {
    final expenseNames = await getExpenseNames;
    if (expenseNames.contains(expenseName)) {
      expenseNames.remove(expenseName);
      _userData = _userData.copyWith(expenseNames: expenseNames);
      _userDataChanged = true;
      await _userRef.update({_expenseNamesField: _userData.expenseNames});
    }
  }
// ExpenseNames

}
