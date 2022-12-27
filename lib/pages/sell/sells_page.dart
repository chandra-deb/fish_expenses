import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/sell_model.dart';
import '../../services/auth_service.dart';
import '../../services/database.dart';
import 'add_sell_page.dart';

class SellsPage extends StatelessWidget {
  static const String routeName = '/sellPage';

  const SellsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton.icon(
              onPressed: () {
                AuthService().signOut();
              },
              icon: const Icon(
                FontAwesomeIcons.outdent,
              ),
              label: const Text('Logout'))
        ],
        title: const Text('Sell Page'),
      ),
      body: StreamBuilder<List<Sell>>(
        stream: DB().getSellsStream,
        // initialData: InitialData,
        builder: (BuildContext context, AsyncSnapshot<List<Sell>> snapshot) {
          // print(snapshot.data);
          if (snapshot.hasData) {
            return ListView(
              children: [
                ...snapshot.data!.map((e) => Text(e.fishName.toString()))
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddSellPage.routeName);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
