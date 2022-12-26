import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/buyer_model.dart';
import '../../services/auth_service.dart';
import '../../services/database.dart';
import 'add_buyer_page.dart';

class BuyersPage extends StatelessWidget {
  const BuyersPage({super.key});

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
                FontAwesomeIcons.outdent,
              ),
              label: const Text('Logout'))
        ],
        title: const Text('Buyers Page'),
      ),
      body: StreamBuilder<List<Buyer>>(
        stream: db.getBuyersStream,
        builder: (BuildContext context, AsyncSnapshot<List<Buyer>> snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView(
              children: [
                ...snapshot.data!.map((buyer) => TextButton(
                    onPressed: () {
                      db.removeBuyer(buyer);
                    },
                    child: Text(buyer.name))),
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
          Navigator.pushNamed(context, AddBuyerPage.routeName);
        },
        child: const Icon(
          FontAwesomeIcons.plus,
        ),
      ),
    );
  }
}
