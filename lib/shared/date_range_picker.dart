import 'package:flutter/material.dart';

Future<DateTimeRange?> serveDateRangePicker(
    BuildContext context, DateTimeRange? defaultRange) async {
  var dateRange = await showDateRangePicker(
    context: context,
    initialDateRange: defaultRange,
    // firstDate: AuthService().currentUser!.metadata.creationTime!,
    firstDate: DateTime.now().subtract(const Duration(days: 365)),
    lastDate: DateTime.now(),
  );
  return dateRange;
}
