import 'package:flutter/material.dart';

import '../../services/database.dart';
import '../../shared/name_delete_confirmation.dart';
import '../home/home_page.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});
  static const routeName = '/addExpensePage';

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _newExpenseNameController = TextEditingController();

  String _selectedName = '';
  String _newNameError = '';
  String _priceError = '';
  String _quantityError = '';

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _newExpenseNameController.dispose();
    super.dispose();
  }

  Future<String> showExpenseNamesToSelectOne() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return FutureBuilder<List<String>>(
          future: DB().getExpenseNames,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Text('Something Went Wrong');
              case ConnectionState.done:
                var expensesName = snapshot.data!;
                expensesName.remove('All');
                return ListView(
                  children: [
                    ...expensesName
                        .map(
                          (name) => ElevatedButton(
                            onPressed: (() {
                              setState(() {
                                _selectedName = name;
                                _newNameError = '';
                              });
                              Navigator.pop(context);
                            }),
                            onLongPress: () async {
                              var isDeleted =
                                  await showNameDeleteConfirmationDialog(
                                context: context,
                                name: name,
                                nameRemoverFunc: DB().removeExpenseName,
                              );
                              if (isDeleted) {
                                if (name == _selectedName) {
                                  setState(() {
                                    _selectedName = '';
                                  });
                                }
                              }
                            },
                            child: Text(name),
                          ),
                        )
                        .toList(),
                  ],
                );

              default:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          },
        );
      },
    );
    return _selectedName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showExpenseNamesToSelectOne();
                      },
                      child: _selectedName.isNotEmpty
                          ? Text(_selectedName)
                          : const Text(
                              'Select Expense ',
                            ),
                    ),
                    const SizedBox(width: 10),
                    const Text('or'),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.name,
                        controller: _newExpenseNameController,
                        decoration: InputDecoration(
                            labelText: 'New Name',
                            errorText: _newNameError.isNotEmpty
                                ? _newNameError
                                : null),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: (() async {
                          final newExpenseName =
                              _newExpenseNameController.text.trim();
                          if (newExpenseName.isNotEmpty) {
                            setState(() {
                              _selectedName = newExpenseName;
                              _newExpenseNameController.clear();
                              _newNameError = '';
                            });
                            await DB().addExpenseName(newExpenseName);
                          } else {
                            setState(() {
                              _newNameError = 'Add a valid name';
                            });
                          }
                        }),
                        child: const Text('Add'))
                  ],
                ),
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: 'Price',
                    errorText: _priceError.isNotEmpty ? _priceError : null),
                controller: _priceController,
                keyboardType: TextInputType.number,
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: 'Quantity',
                    errorText:
                        _quantityError.isNotEmpty ? _quantityError : null),
                controller: _quantityController,
              ),
              ElevatedButton(
                onPressed: () {
                  int? price = int.tryParse(_priceController.text.trim());
                  var quantity = _quantityController.text.trim();
                  if (price == null) {
                    setState(() {
                      _priceError = 'Only Number Allowed';
                    });
                  }
                  if (quantity.isEmpty) {
                    setState(() {
                      _quantityError = 'Field Can not be empty';
                    });
                  }
                  if (_selectedName.isEmpty) {
                    setState(() {
                      _newNameError = 'Please Select a name';
                    });
                  } else {
                    DB().addExpense(_selectedName, price!, quantity);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(selectedIndex: 1),
                      ),
                      (route) => false,
                    );
                  }
                },
                child: const Text('Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
