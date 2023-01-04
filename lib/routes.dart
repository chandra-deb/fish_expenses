import 'pages/expense/add_expense_page.dart';
import 'pages/home/home_page.dart';
import 'pages/login/login_page.dart';
import 'pages/sell/add_sell_page.dart';
import 'pages/sell/sells_page.dart';

final routes = {
  '/': (context) => const HomePage(
        selectedIndex: 0,
      ),
  LoginPage.routeName: (context) => const LoginPage(),
  SellsPageWrapper.routeName: (context) => const SellsPageWrapper(),
  AddSellPage.routeName: (context) => const AddSellPage(),
  AddExpensePage.routeName: (context) => const AddExpensePage(),
};
