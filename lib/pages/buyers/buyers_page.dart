import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
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
                ...snapshot.data!.map((buyer) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: Colors.lightBlue,
                      child: ListTile(
                        hoverColor: Colors.red,
                        title: Text(buyer.name),
                        subtitle: Text(buyer.phone.toString()),
                        trailing: IconButton(
                            onPressed: () {
                              FlutterPhoneDirectCaller.callNumber(buyer.phone);
                            },
                            icon: const Icon(Icons.phone)),
                      ),
                    )),
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
