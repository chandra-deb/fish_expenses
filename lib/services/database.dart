import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/buyer_model.dart';
import '../models/expense_model.dart';
import 'auth_service.dart';

const _usersCollectionName = 'users';
const _expensesCollectionName = 'expenses';
const _buyerNamesField = 'buyers';
const _fishNamesField = 'fishNames';
const _expenseNamesField = 'expenseNames';

class DB {
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection(_usersCollectionName);
  final DocumentReference _userRef = FirebaseFirestore.instance
      .collection(_usersCollectionName)
      .doc(AuthService().currentUser!.uid);
  late final _expensesCollectionRef =
      _userRef.collection(_expensesCollectionName);

  List<String> fishNames = [];
  List<Buyer> buyers = [];
  List<Expense> expenses = [];
  List<String> expenseNames = [];

  DB._privateConstructor();
  static final DB _db = DB._privateConstructor();

  factory DB() {
    return _db;
  }

  Future<void> addUser(String userUid) async {
    await _collectionRef
        .doc(userUid)
        .set({_fishNamesField: [], _expenseNamesField: []});
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

  Future<void> addFishName(String fishName) async {
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
        var rawData = event.get(_buyerNamesField) as List;
        buyers = rawData.map((e) => Buyer.fromMap(e)).toList();
        return buyers;
      },
    );
  }

  Future<List<Buyer>> get getBuyers async {
    var rd = await _userRef.get();
    var rc = rd.get(_buyerNamesField) as List;
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
// This Method needs to be reimagined
  // Future<void> addBuyer(Buyer buyer) async {
  //   if (buyers.contains(buyer)) return;
  //   buyers.add(buyer.toMap());
  //   await _userRef.update({'buyers': buyers});
  // }

// This Method needs to be reimagined
  Future<void> removeBuyer(Buyer buyer) async {
    buyers = buyers.takeWhile(
      (value) {
        var p = value as Map;
        if (p.containsValue(buyer.name)) return false;
        return true;
      },
    ).toList();
    // print(buyers);
    await _userRef.update({_buyerNamesField: buyers});

    // if (buyers.contains(buyer.toMap())) {
    //   buyers.remove(buyer);
    //   await _userRef.update({'buyers': buyers});
    // }
  }
  // Buyers

// Expenses
  Stream<List<Expense>> get getExpensesStream {
    return _userRef.collection(_expensesCollectionName).snapshots().map(
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
    var expense = Expense(
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
