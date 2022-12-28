// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

class FiltererModalSheet {
  final Future<List<String>> namesFuture;
  final BuildContext context;
  final List<String> selectedNames;

  FiltererModalSheet({
    required this.context,
    required this.namesFuture,
    required this.selectedNames,
  }) {
    if (selectedNames.isEmpty) {
      selectedNames.add('All');
    }
  }

  ListView _namesListView(List<String> names, StateSetter setState) {
    return ListView(
      children: [
        ...names
            .map(
              (name) => TextButton(
                onPressed: () {
                  // setState(
                  //   () {
                  if (selectedNames.contains(name)) {
                    if (!(selectedNames.length == 1 &&
                        selectedNames.contains('All'))) {
                      setState(() {
                        selectedNames.remove(name);
                      });
                    }
                  } else {
                    if (name == 'All') {
                      setState(
                        () {
                          selectedNames.clear();
                          selectedNames.add(name);
                        },
                      );
                    } else {
                      if (selectedNames.contains('All')) {
                        setState(() {
                          selectedNames.remove('All');
                        });
                      }
                      setState(() {
                        selectedNames.add(name);
                      });
                    }
                  }
                  //   },
                  // );
                },
                child: selectedNames.contains(name)
                    ? Text(
                        name,
                        style: const TextStyle(color: Colors.redAccent),
                      )
                    : Text(name),
              ),
            )
            .toList()
      ],
    );
  }

  Future<List<String>> showFiltererSheet() {
    return showModalBottomSheet(
      backgroundColor: Colors.white70,
      context: context,
      builder: (context) {
        return FutureBuilder<List<String>>(
            future: namesFuture,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return const Text('Something Went Wrong');
                case ConnectionState.done:
                  var names = snapshot.data!;
                  names.insert(0, 'All');
                  return StatefulBuilder(
                    builder: (BuildContext context, setState) {
                      return _namesListView(names, setState);
                    },
                  );
                default:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
              }
            });
      },
    ).then((_) {
      if (selectedNames.contains('All')) {
        selectedNames.remove('All');
      }
      return selectedNames;
    });
  }
}
