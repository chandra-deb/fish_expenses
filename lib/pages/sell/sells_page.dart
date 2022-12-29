import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../extensions/string_capitalize.dart';
import '../../models/sell_model.dart';
import '../../services/auth_service.dart';
import '../../services/database.dart';
import '../../shared/date_range_picker.dart';
import '../../shared/filtererModalSheet.dart';
import 'add_sell_page.dart';

enum NameOf {
  buyer,
  fish;
}

enum FishSize {
  all,
  small,
  large;
}

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
  List<String> _selectedBuyerNames = [];
  List<String> _selectedFishNames = [];

  DateTimeRange? selectedDateRange;
  DateTimeRange? defaultDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  List<Sell> sells = [];

  List<Sell> filterSellsByNames({
    required List<String> selectedNames,
    required NameOf filterer,
    bool reloadIfEmpty = true,
  }) {
    if (selectedNames.isNotEmpty) {
      List<Sell> sls = [];
      for (var name in selectedNames) {
        for (var sell in widget.sells) {
          if (filterer == NameOf.buyer) {
            if (sell.buyerName == name) {
              sls.add(sell);
            }
          } else if (filterer == NameOf.fish) {
            if (sell.fishName == name) {
              sls.add(sell);
            }
          }
        }
      }
      sells = sls;
    } else if (reloadIfEmpty == true) {
      sells = widget.sells;
    }
    return sells;
  }

  // List<Sell> filterSellsByBuyerNames() {
  //   if (_selectedBuyerNames.isNotEmpty) {
  //     List<Sell> sls = [];
  //     for (var name in _selectedBuyerNames) {
  //       for (var sell in widget.sells) {
  //         if (sell.buyerName == name) {
  //           sls.add(sell);
  //         }
  //       }
  //     }
  //     sells = sls;
  //     return sells;
  //   } else {
  //     sells = widget.sells;
  //     return sells;
  //   }
  // }

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

  FishSize _selectedFishSize = FishSize.all;
  List<bool> _selectedFishSizeInBoolList = <bool>[true, false, false];
  final List<Widget> fishSizes = <Widget>[
    Text(FishSize.all.name.toCapitalize()),
    Text(FishSize.large.name.toCapitalize()),
    Text(FishSize.small.name.toCapitalize()),
  ];

  List<Sell> filterSellsByFishSize() {
    if (_selectedFishSize == FishSize.large) {
      sells = sells.where((sell) => sell.smallFish == false).toList();
      return sells;
    } else if (_selectedFishSize == FishSize.small) {
      sells = sells.where((sell) => sell.smallFish == true).toList();
      return sells;
    }
    return sells;
  }

  List<Sell> filteredSells() {
    // filterSellsByBuyerNames();
    filterSellsByNames(
        selectedNames: _selectedBuyerNames, filterer: NameOf.buyer);
    filterSellsByNames(
        selectedNames: _selectedFishNames,
        filterer: NameOf.fish,
        reloadIfEmpty: false);
    filterSellsByFishSize();
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
                Text(sell.buyerName),
                Text(sell.fishName),
                // Text('${sell.quantity} kg'),
                Text(sell.date.toString().split(' ')[0]),
                Text(sell.smallFish == true ? 'Small' : 'Large'),
              ],
            ),
          ),
        )
        .toList();
    return sells;
  }

  List<Widget> sellFiltererWidgets() {
    final filterers = [
      const Text('Filter By'),
      TextButton(
        onPressed: () async {
          var selectedNames = await FiltererModalSheet(
            context: context,
            namesFuture: DB().getBuyerNames,
            selectedNames: _selectedBuyerNames,
          ).showFiltererSheet();
          setState(() {
            _selectedBuyerNames = selectedNames;
          });
        },
        child: const Text('Buyer'),
      ),
      TextButton(
        onPressed: () async {
          var selectedNames = await FiltererModalSheet(
            context: context,
            namesFuture: DB().getFishNames,
            selectedNames: _selectedFishNames,
          ).showFiltererSheet();
          setState(() {
            _selectedFishNames = selectedNames;
          });
        },
        child: const Text('Fish'),
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
        child: const Text('DateRange'),
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
                ToggleButtons(
                  direction: Axis.horizontal,
                  onPressed: (int index) {
                    setState(() {
                      if (index == 0) {
                        _selectedFishSize = FishSize.all;
                        _selectedFishSizeInBoolList = [true, false, false];
                      } else if (index == 1) {
                        _selectedFishSize = FishSize.large;

                        _selectedFishSizeInBoolList = [false, true, false];
                      } else {
                        _selectedFishSize = FishSize.small;

                        _selectedFishSizeInBoolList = [false, false, true];
                      }
                    });
                  },
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  selectedBorderColor: Colors.red[700],
                  selectedColor: Colors.white,
                  fillColor: Colors.red[200],
                  color: Colors.red[400],
                  constraints: const BoxConstraints(
                    minHeight: 40.0,
                    minWidth: 80.0,
                  ),
                  isSelected: _selectedFishSizeInBoolList,
                  children: fishSizes,
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
