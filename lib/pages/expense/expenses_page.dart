// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:fish_expenses/pages/expense/add_expense_page.dart';
import 'package:fish_expenses/services/auth_service.dart';
import 'package:fish_expenses/services/database.dart';
import 'package:fish_expenses/shared/date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/expense_model.dart';
import '../../shared/filterer_modal_Sheet.dart';

class ExpensesPageWrapper extends StatelessWidget {
  const ExpensesPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    var db = DB();
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton.icon(
              onPressed: () {
                AuthService().signOut();
              },
              icon: const Icon(
                FontAwesomeIcons.peoplePulling,
              ),
              label: const Text('Logout'))
        ],
        title: const Text('Expenses Page'),
      ),
      body: FutureBuilder<List<Expense>>(
        future: db.getExpenses,
        builder: (BuildContext context, AsyncSnapshot<List<Expense>> snapshot) {
          if (snapshot.hasData) {
            List<Expense> expenses = snapshot.data!;
            return ExpensesPage(expenses: expenses);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class ExpensesPage extends StatefulWidget {
  final List<Expense> expenses;
  // final DB db;

  const ExpensesPage({
    Key? key,
    required this.expenses,
    // required this.db,
  }) : super(key: key);

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  List<String> selectedExpensesName = [];
  DateTimeRange? selectedDateRange;
  DateTimeRange? defaultDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  List<Expense> expenses = [];

  List<Expense> filterExpensesByNames() {
    if (selectedExpensesName.isNotEmpty) {
      List<Expense> exps = [];
      for (var name in selectedExpensesName) {
        for (var expense in widget.expenses) {
          if (expense.name == name) {
            exps.add(expense);
          }
        }
      }
      expenses = exps;
      return expenses;
    } else {
      expenses = widget.expenses;
      return expenses;
    }
  }

  List<Expense> filterByDateRange() {
    if (selectedDateRange != null) {
      List<Expense> exps = expenses
          .where(
            (expense) =>
                expense.dateTime.isAfter(
                  selectedDateRange!.start.subtract(
                    const Duration(days: 1),
                  ),
                ) &&
                expense.dateTime.isBefore(
                  selectedDateRange!.end.add(
                    const Duration(days: 1),
                  ),
                ),
          )
          .toList();
      expenses = exps;
      return expenses;
    } else {
      return expenses;
    }
  }

  List<Expense> filteredExpenses() {
    filterExpensesByNames();
    return filterByDateRange();
  }

  int expenseAddAllPrice() {
    int allPrice = 0;
    for (var expense in expenses) {
      allPrice += expense.price;
    }
    return allPrice;
  }

  List<Widget> expenseListWidgets() {
    final expenses = filteredExpenses()
        .map(
          (expense) => TextButton(
            onPressed: () async {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('${expense.name} Name'),
                Text('${expense.price} Taka'),
                Text('${expense.quantity} kg'),
              ],
            ),
          ),
        )
        .toList();
    return expenses;
  }

  List<Widget> expenseFiltererWidgets() {
    final filterers = [
      TextButton(
        onPressed: () async {
          var selectedNames = await FiltererModalSheet(
            context: context,
            namesFuture: DB().getExpenseNames,
            selectedNames: selectedExpensesName,
          ).showFiltererSheet();
          setState(() {
            selectedExpensesName = selectedNames;
          });
        },
        child: const Text('Filter By Name'),
      ),
      TextButton(
        onPressed: () async {
          var dateRange = await serveDateRangePicker(context, defaultDateRange);
          if (dateRange != null) {
            setState(() {
              defaultDateRange = dateRange;
              selectedDateRange = dateRange;
            });
          }
        },
        child: const Text('Filter By DateRange'),
      ),
    ];

    return filterers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 400,
            child: ListView(
              children: [
                Container(
                  color: Colors.greenAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [...expenseFiltererWidgets()],
                  ),
                ),
                ...expenseListWidgets(),
              ],
            ),
          ),
          Text('All Price ${expenseAddAllPrice()} taka')
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.pushNamed(context, AddExpensePage.routeName);
        },
        child: const Icon(
          FontAwesomeIcons.circlePlus,
        ),
      ),
    );
  }
}
