import 'package:flutter/material.dart';

import '../../services/database.dart';

class AddSellPage extends StatefulWidget {
  static const String routeName = '/addSellPage';
  const AddSellPage({super.key});

  @override
  State<AddSellPage> createState() => _AddSellPageState();
}

class _AddSellPageState extends State<AddSellPage> {
  final _newFishNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  String _selectedBuyerName = '';
  String _selectedFishName = '';
  DateTime? _selectedDate;
  bool _isSmallFish = false;
  String _buyerNameError = '';
  String _fishNameError = '';
  String _priceError = '';
  String _quantityError = '';

  @override
  void dispose() {
    _newFishNameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<String> showBuyerNamesToSelectOne() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return FutureBuilder<List<String>>(
          future: DB().getBuyerNames,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Text('Something Went Wrong');
              case ConnectionState.done:
                var buyerNames = snapshot.data!;
                return ListView(
                  children: [
                    ...buyerNames
                        .map(
                          (name) => ElevatedButton(
                            onPressed: (() {
                              setState(() {
                                _selectedBuyerName = name;
                                _buyerNameError = '';
                              });
                              Navigator.pop(context);
                            }),
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
    return _selectedBuyerName;
  }

  Future<String> showFishNamesToSelectOne() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return FutureBuilder<List<String>>(
          future: DB().getFishNames,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Text('Something Went Wrong');
              case ConnectionState.done:
                var fishNames = snapshot.data!;
                return ListView(
                  children: [
                    ...fishNames
                        .map(
                          (name) => ElevatedButton(
                            onPressed: (() {
                              setState(() {
                                _selectedFishName = name;
                                _fishNameError = '';
                              });
                              Navigator.pop(context);
                            }),
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
    return _selectedFishName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Sell')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  showBuyerNamesToSelectOne();
                },
                child: _selectedBuyerName.isNotEmpty
                    ? Text(_selectedBuyerName)
                    : Text(
                        _buyerNameError.isEmpty
                            ? 'Select A Buyer'
                            : _buyerNameError,
                      ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showFishNamesToSelectOne();
                    },
                    child: _selectedFishName.isNotEmpty
                        ? Text(_selectedFishName)
                        : Text(
                            _fishNameError.isEmpty
                                ? 'Select A Fish Name'
                                : _fishNameError,
                          ),
                  ),
                  const Text('or'),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.name,
                      controller: _newFishNameController,
                      decoration: InputDecoration(
                          labelText: 'New Name',
                          errorText: _fishNameError.isNotEmpty
                              ? _fishNameError
                              : null),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: (() async {
                        final newFishName = _newFishNameController.text.trim();
                        if (newFishName.isNotEmpty) {
                          setState(() {
                            _selectedFishName = newFishName;
                            _newFishNameController.clear();
                            _fishNameError = '';
                          });
                          await DB().addFishName(newFishName);
                        } else {
                          setState(() {
                            _fishNameError = 'Please Select a Fish';
                          });
                        }
                      }),
                      child: const Text('Add'))
                ],
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
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: () async {
                  var date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 90)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
                child: Text(_selectedDate != null
                    ? _selectedDate.toString().split(' ')[0]
                    : 'Pick a date(Auto)'),
              ),
              Row(
                children: [
                  const Text('Is Small Fish'),
                  Checkbox(
                    value: _isSmallFish,
                    onChanged: (value) {
                      setState(() {
                        _isSmallFish = value!;
                        print(_isSmallFish);
                      });
                    },
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (_selectedBuyerName.isEmpty) {
                    setState(() {
                      _buyerNameError = 'Please Select a buyer';
                    });
                  } else {
                    setState(() {
                      _buyerNameError = '';
                    });
                  }
                  if (_selectedFishName.isEmpty) {
                    setState(() {
                      _fishNameError = 'Please Select a Fish';
                    });
                  } else {
                    setState(() {
                      _fishNameError = '';
                    });
                  }
                  int? price = int.tryParse(_priceController.text.trim());
                  int? quantity = int.tryParse(_quantityController.text.trim());
                  if (price == null) {
                    setState(() {
                      _priceError = 'Only Number Allowed';
                    });
                  } else {
                    setState(() {
                      _priceError = '';
                    });
                  }
                  if (quantity == null) {
                    setState(() {
                      _quantityError = 'Only Number Allowed';
                    });
                  } else {
                    setState(() {
                      _quantityError = '';
                    });
                  }
                  if (_buyerNameError.isEmpty &&
                      _fishNameError.isEmpty &&
                      _priceError.isEmpty &&
                      _quantityError.isEmpty) {
                    print(quantity);
                    _selectedDate ??= DateTime.now();

                    DB().addSell(
                      buyerName: _selectedBuyerName,
                      fishName: _selectedFishName,
                      quantity: quantity!,
                      price: price!,
                      date: _selectedDate!,
                      isSmallFish: _isSmallFish,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Sell'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
