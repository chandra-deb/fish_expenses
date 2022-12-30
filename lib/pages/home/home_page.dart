import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../services/auth_service.dart';
import '../buyers/buyers_page.dart';
import '../expense/expenses_page.dart';
import '../login/login_page.dart';
import '../sell/sells_page.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    SellsPageWrapper(),
    ExpensesPageWrapper(),
    BuyersPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: AuthService().authStream,
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const Center(
          //     child: Text('Loading'),
          //   );
          // } else
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something wert wrong'),
            );
          } else if (snapshot.data != null) {
            return Scaffold(
              body: _widgetOptions.elementAt(_selectedIndex),
              bottomNavigationBar: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(FontAwesomeIcons.sellsy),
                    label: 'Sells',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(FontAwesomeIcons.moneyCheck),
                    label: 'Expenses',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(FontAwesomeIcons.peopleGroup),
                    label: 'Buyers',
                  ),
                ],
                currentIndex: _selectedIndex,
                // selectedItemColor: Colors.amber[800],
                onTap: _onItemTapped,
              ),
            );
          }
          return const LoginPage();
        },
      ),
    );
  }
}
