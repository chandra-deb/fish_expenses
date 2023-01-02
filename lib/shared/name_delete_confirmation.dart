import 'package:flutter/material.dart';

import '../services/database.dart';

void showNameDeleteConfirmationDialog({
  required BuildContext context,
  required String name,
  required Future<void> Function(String name) nameRemoverFunc,
}) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      String enteredPassword = '';
      return Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Enter Master Password to delete!'),
            TextField(
              onChanged: (value) => enteredPassword = value.trim(),
            ),
            TextButton(
              onPressed: () {
                if (enteredPassword == DB().masterPassword) {
                  nameRemoverFunc(name);
                  SnackBar(
                    content: Text('$name deleted'),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    },
  );
}
