import 'package:flutter/material.dart';

import '../../models/buyer_model.dart';
import '../../services/database.dart';

class AddBuyerPage extends StatefulWidget {
  const AddBuyerPage({super.key});
  static const routeName = '/addBuyerPage';

  @override
  State<AddBuyerPage> createState() => _AddBuyerPageState();
}

class _AddBuyerPageState extends State<AddBuyerPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _nameError = '';
  String _phoneError = '';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// ElevatedButton(
  //   onPressed: (() async {
  //     final newBuyerName = _nameController.text.trim();
  //     if (newBuyerName.isNotEmpty) {
  //       setState(() {
  //         _nameController.clear();
  //         _nameError = '';
  //       });
  //       // await DB().addBuyer(newExpenseName);
  //     } else {
  //       setState(() {
  //         _nameError = 'Add a valid name';
  //       });
  //     }
  //   }),
  //   child: const Text('Add'),
  // ),

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Buyer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              keyboardType: TextInputType.name,
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: 'Buyer Name',
                  errorText: _nameError.isNotEmpty ? _nameError : null),
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: 'Phone',
                  errorText: _phoneError.isNotEmpty ? _phoneError : null),
              controller: _phoneController,
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () async {
                String name = _nameController.text.trim();
                print(name);
                int? phone = int.tryParse(_phoneController.text.trim());
                if (name.isEmpty || phone == null) {
                  if (name.isEmpty) {
                    _nameError = 'Enter buyer name first!';
                  } else {
                    _nameError = '';
                  }
                  if (phone == null) {
                    _phoneError = 'Please Enter a valid number';
                  } else {
                    _phoneError = '';
                  }
                  setState(() {});
                }
                if (name.isNotEmpty && phone != null) {
                  final buyer = Buyer(name: name, phone: phone);
                  DB().addBuyer(buyer);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Buyer'),
            ),
          ],
        ),
      ),
    );
  }
}
