import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/sell_model.dart';
import '../../services/auth_service.dart';
import '../../services/database.dart';
import '../../shared/date_range_picker.dart';
import '../../shared/filtererModalSheet.dart';
import 'add_sell_page.dart';

class SellsPageWrapper extends StatelessWidget {
  static const String routeName = '/sellsPage';

  const SellsPageWrapper({super.key});

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
                FontAwesomeIcons.peoplePulling,
              ),
              label: const Text('Logout'))
        ],
        title: const Text('Sells Page'),
      ),
      body: StreamBuilder<List<Sell>>(
        stream: db.getSellsStream,
        builder: (BuildContext context, AsyncSnapshot<List<Sell>> snapshot) {
          if (snapshot.hasData) {
            List<Sell> sells = snapshot.data!;
            return SellsPage(sells: sells);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class SellsPage extends StatefulWidget {
  final List<Sell> sells;
  // final DB db;

  const SellsPage({
    Key? key,
    required this.sells,
    // required this.db,
  }) : super(key: key);

  @override
  State<SellsPage> createState() => _SellsPageState();
}

class _SellsPageState extends State<SellsPage> {
  List<String> selectedBuyerNames = [];
  DateTimeRange? selectedDateRange;
  DateTimeRange? defaultDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  List<Sell> sells = [];

  List<Sell> filterSellsByBuyerNames() {
    if (selectedBuyerNames.isNotEmpty) {
      List<Sell> sls = [];
      for (var name in selectedBuyerNames) {
        for (var sell in widget.sells) {
          if (sell.buyerName == name) {
            sls.add(sell);
          }
        }
      }
      sells = sls;
      return sells;
    } else {
      sells = widget.sells;
      return sells;
    }
  }

  List<Sell> filterByDateRange() {
    if (selectedDateRange != null) {
      List<Sell> sls = sells
          .where(
            (sell) =>
                sell.date.isAfter(
                  selectedDateRange!.start.subtract(
                    const Duration(days: 1),
                  ),
                ) &&
                sell.date.isBefore(
                  selectedDateRange!.end.add(
                    const Duration(days: 1),
                  ),
                ),
          )
          .toList();
      sells = sls;
      return sells;
    } else {
      return sells;
    }
  }

  List<Sell> filteredSells() {
    filterSellsByBuyerNames();
    return filterByDateRange();
  }

  int sellAddAllPrice() {
    int allPrice = 0;
    for (var sell in sells) {
      allPrice += sell.price;
    }
    return allPrice;
  }

  List<Widget> sellListWidgets() {
    final sells = filteredSells()
        .map(
          (sell) => TextButton(
            onPressed: () async {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('${sell.buyerName} Name'),
                Text('${sell.price} Taka'),
                Text('${sell.quantity} kg'),
              ],
            ),
          ),
        )
        .toList();
    return sells;
  }

  List<Widget> sellFiltererWidgets() {
    final filterers = [
      TextButton(
        onPressed: () async {
          var selectedNames = await FiltererModalSheet(
            context: context,
            namesFuture: DB().getBuyerNames,
            selectedNames: selectedBuyerNames,
          ).showFiltererSheet();
          setState(() {
            selectedBuyerNames = selectedNames;
          });
        },
        child: const Text('Filter By Buyer'),
      ),
      TextButton(
        onPressed: () async {
          var dateRange = await serveDateRangePicker(context, defaultDateRange);
          if (dateRange != null) {
            setState(() {
              defaultDateRange = dateRange;
              selectedDateRange = dateRange;
            });
          }
        },
        child: const Text('Filter By DateRange'),
      ),
    ];

    return filterers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 400,
            child: ListView(
              children: [
                Container(
                  color: Colors.greenAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [...sellFiltererWidgets()],
                  ),
                ),
                ...sellListWidgets(),
              ],
            ),
          ),
          Text('All Price ${sellAddAllPrice()} taka')
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.pushNamed(context, AddSellPage.routeName);
        },
        child: const Icon(
          FontAwesomeIcons.circlePlus,
        ),
      ),
    );
  }
}
