import 'package:flutter/material.dart';

import '../services/database.dart';

List<String> _selectedExpensesName = [];
DB _db = DB();

Future<List<String>> modalDialogue({
  required BuildContext context,
  required List<String> names,
}) {
  return showModalBottomSheet(
    backgroundColor: Colors.white70,
    context: context,
    builder: (context) {
      return FutureBuilder<List<String>>(
          future: _db.getExpenseNames,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Text('Something Went Wrong');
              case ConnectionState.done:
                var expensesName = snapshot.data!;
                return StatefulBuilder(
                  builder: (BuildContext context, setState) {
                    return ListView(
                      children: [
                        ...expensesName
                            .map(
                              (name) => TextButton(
                                onPressed: () {
                                  setState(
                                    () {
                                      if (_selectedExpensesName
                                          .contains(name)) {
                                        _selectedExpensesName.remove(name);
                                      } else {
                                        _selectedExpensesName.add(name);
                                      }
                                    },
                                  );
                                },
                                child: _selectedExpensesName.contains(name)
                                    ? Text(
                                        name,
                                        style: const TextStyle(
                                            color: Colors.redAccent),
                                      )
                                    : Text(name),
                              ),
                            )
                            .toList()
                      ],
                    );
                  },
                );
              default:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          });
    },
  ).then((value) => _selectedExpensesName);
}
