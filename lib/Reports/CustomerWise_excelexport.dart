import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/js.dart';

import 'excelexport_stub.dart' if (dart.library.html) 'excelexport_web.dart'
    as web_export;
import 'dart:convert';
import 'dart:io';
import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
// Conditional import for web download support
import 'excelexport_stub.dart' if (dart.library.html) 'excelexport_web.dart'
    as web_export;

String? salesmanName;
String? errorMessage;
Future<String?> fetchSalesmanName(String salesmanNo) async {
  try {
    final IpAddress = await getActiveIpAddress();
    final url =
        Uri.parse("$IpAddress/get-salesman-name/?salesman_no=$salesmanNo");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['salesman_name']; // ✅ Return only the name
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<void> exportGroupedTruckScanDetails(
    BuildContext context,
    String fromDateFormatted,
    String endDateFormatted,
    String Parametertype,
    String parametervalue) async {
  try {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Processing...Getting data..."),
            ],
          ),
        );
      },
    );

    WidgetsFlutterBinding.ensureInitialized();
    String finalparameterevalues = Parametertype == 'Undel id'
        ? '&undel_id=$parametervalue'
        : (Parametertype == 'Customer Number'
            ? '&customer_no=$parametervalue'
            : (Parametertype.isEmpty ? '' : '&salesman_name=$parametervalue'));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String salesmanno = prefs.getString('salesloginno') ?? 'Unknown ID';
    String salesloginrole = prefs.getString('salesloginrole') ?? 'Unknown ID';

    String sendvalues = (await fetchSalesmanName(
          salesmanno.trim(),
        )) ??
        "";
    String salesmanstatus = salesloginrole == 'Salesman'
        ? '&salesman_name=$sendvalues$finalparameterevalues'
        : '$finalparameterevalues';

    final IpAddress = await getActiveOracleIpAddress();
    final response = await http.get(
      Uri.parse(
          '$IpAddress/Report-grouped-truck-scan-details/?from_date=$fromDateFormatted&to_date=$endDateFormatted$salesmanstatus'),
    );

    print(
        ' dispatch details ul $IpAddress/Report-grouped-truck-scan-details/?from_date=$fromDateFormatted&to_date=$endDateFormatted$salesmanstatus');
    if (response.statusCode != 200) {
      throw Exception('Failed to load data: ${response.statusCode}');
    }

    final List<dynamic> data = json.decode(response.body);
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No data Found...'),
          backgroundColor: Colors.red,
        ),
      );
      print('No data received.');
      return;
    }

    final Excel excel = Excel.createExcel();
    const String sheetName = 'Dispatch Report';
    final Sheet sheet = excel[sheetName];
    excel.setDefaultSheet(sheetName);

    // Styles
    final headerStyle = CellStyle(
      bold: true,
      // fontColorHex: '#FFFFFF', // White font
      // backgroundColorHex: '#800080', // Purple background
      fontColorHex: '#000000',
      backgroundColorHex: '#95C7F9',
      fontFamily: getFontFamily(FontFamily.Calibri),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final titleStyle = CellStyle(
      bold: true,
      fontColorHex: '#000000',
      backgroundColorHex: '#D9E1F2',
      fontSize: 12,
      fontFamily: getFontFamily(FontFamily.Calibri),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final textCellStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final numericStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
    );

    final filteredStyle = CellStyle(
      fontColorHex: '#000000',
      backgroundColorHex: '#D9E1F2',
      bold: true,
      fontSize: 10,
    );

    int row = 0;

    // Compute Dispatch From/To dates
    String dispatchFrom = _formatCustomDate(fromDateFormatted);
    String dispatchTo = _formatCustomDate(endDateFormatted);
// Title row
    sheet.merge(
      CellIndex.indexByString("A1"),
      CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: 0),
    );
    final titleCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
    titleCell.value = 'TruckLoad Sales Dispatch Value Details Report';
    titleCell.cellStyle = titleStyle;
    row += 2;

// Runtime row
    final DateTime now = DateTime.now();
    final DateTime today = DateTime.now();
    final String formattedTime = DateFormat('hh:mm:ss a').format(now);
    final String formattedToday = DateFormat('dd-MMM-yyyy').format(today);

    final runtimeCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
    runtimeCell.value = 'Runtime : $formattedToday -- $formattedTime';
    runtimeCell.cellStyle = filteredStyle;

    row++; // ✅ move to next row, otherwise runtime gets overwritten

// Filter row
    final filterCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
    filterCell.value = (Parametertype == "Salesman Number")
        ? "Salesman Name Filtration : $parametervalue"
        : '${Parametertype.isNotEmpty ? "$Parametertype " : ""} Filtration : $parametervalue';

    filterCell.cellStyle = filteredStyle;
    row++;

    row++;
// If you want the grey+bold style to span multiple columns (e.g., A & B)
    for (int col = 0; col <= 1; col++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
          .cellStyle = filteredStyle;
    }

    row++;

    // Row: Dispatch From Date
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = 'Dispatch From Date';
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = dispatchFrom;
    for (int col = 0; col <= 1; col++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
          .cellStyle = headerStyle;
    }
    row++;

    // Row: Dispatch To Date
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = 'Dispatch To Date';
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = dispatchTo;
    for (int col = 0; col <= 1; col++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
          .cellStyle = headerStyle;
    }
    row++;

    // Blank row
    row++;

    // Data section
    for (final group in data) {
      final List<dynamic> dispatches = group['dispatches'];
      double groupTotal = 0.0;

      const headers = [
        'Regions',
        'Customer No',
        'Customer Name',
        'Salesman No',
        'Salesman Name',
        'Driver',
        'Vehicle Number',
        'Dispatcher',
        'Delivery Location',
        'Supplier',
        'Invoice Date',
        'Invoice Number',
        'Item Code',
        'Description',
        'Invoice Quantity',
        'Invoice Amount',
        'Dispatch Number',
        'Dispatch Date',
        'Dispatch Status',
        'Dispatch Qty',
        'Dispatch Amount'
      ];

      for (int col = 0; col < headers.length; col++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
            .value = headers[col];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
            .cellStyle = headerStyle;
      }
      row++;

      for (final d in dispatches) {
        final invoice_qty = _toDouble(d['quantity']);
        final qty = _toDouble(d['truck_send_qty']);
        final itemCost = _toDouble(d['item_cost']);
        final totalCost = _toDouble(d['total_cost']);
        groupTotal += totalCost;

        final values = [
          d['region'] ?? '',
          group['customer_number'] ?? '',
          group['customer_name'] ?? '',
          d['salesman_no'] ?? '',
          d['salesman_name'] ?? '',
          d['driver_name'] ?? '',
          d['vehicle_no'] ?? '',
          d['customer_class_code'] ?? '',
          d['remarks'] ?? '',
          d['transporter_name'] ?? '',
          _formatCustomDate(d['invoice_date']),
          d['invoice_no'] ?? '',
          d['item_code'] ?? '',
          d['item_details'] ?? '',
          invoice_qty,
          invoice_qty * itemCost,
          d['dispatch_id'] ?? '',
          _formatCustomDate(d['dispatch_date']),
          d['status'] ?? '',
          qty,
          totalCost,
        ];

        for (int col = 0; col < values.length; col++) {
          final cell = sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
          cell.value = values[col];
          cell.cellStyle =
              (col >= 12 && col <= 20) ? numericStyle : textCellStyle;
        }
        row++;
      }

// Write "Total Amount:"
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 21, rowIndex: row))
          .value = 'Total Amount:';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 21, rowIndex: row))
          .cellStyle = headerStyle;

// Set column 21 width
      sheet.setColWidth(21, 20); // Adjust width as needed

// Write total value
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 22, rowIndex: row))
          .value = groupTotal;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 22, rowIndex: row))
          .cellStyle = numericStyle;

// Set column 22 width
      sheet.setColWidth(22, 25); // Adjust width as needed

      row++;
    }

    // Auto-fit columns
    for (int col = 0; col < 21; col++) {
      int maxLen = 0;
      for (int r = 0; r < row; r++) {
        final val = sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: r))
            .value
            .toString();
        maxLen = val.length > maxLen ? val.length : maxLen;
      }
      sheet.setColWidth(col, (maxLen + 2).toDouble());
    }

    // Save Excel
    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode Excel');

    String parameter = (Parametertype == "Salesman Number")
        ? "Salesman Name_${parametervalue}_"
        : (parametervalue.isEmpty ? '' : '${Parametertype}_${parametervalue}_');
    final filename =
        'Dispatch_Report_$parameter${dispatchFrom}_to_${dispatchTo}.xlsx'
            .replaceAll(' ', '_')
            .replaceAll('-', '_');

    if (kIsWeb) {
      web_export.saveExcelWeb(bytes, filename);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/$filename';
      final file = File(path);
      await file.writeAsBytes(bytes);
      await OpenFile.open(path);
    }
  } catch (e) {
    print('❌ Excel Export Error: $e');
  } finally {
    // Close the dialog
    Navigator.of(context).pop();
  }
}

String _formatCustomDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return '';
  try {
    final date = DateTime.parse(dateString);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day.toString().padLeft(2, '0')}-${months[date.month - 1]}-${(date.year % 100).toString().padLeft(2, '0')}';
  } catch (_) {
    return dateString;
  }
}

double _toDouble(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0.0;
