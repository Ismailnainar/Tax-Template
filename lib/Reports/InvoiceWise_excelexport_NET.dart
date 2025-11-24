import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

// ==========================
// Fetch Salesman Name
// ==========================
Future<String?> fetchSalesmanName(String salesmanNo) async {
  try {
    final IpAddress = await getActiveIpAddress();
    final url =
        Uri.parse("$IpAddress/get-salesman-name/?salesman_no=$salesmanNo");

    print("urllll $IpAddress/get-salesman-name/?salesman_no=$salesmanNo");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['salesman_name']?.toString();
    } else {
      return null;
    }
  } catch (_) {
    return null;
  }
}

// ==========================
// Export Function
// ==========================
Future<void> InvoiceWiseexportGroupedTruckScanDetailsNETAMOUNT(
  BuildContext context,
  String fromDateFormatted,
  String endDateFormatted,
  String Parametertype,
  String parametervalue,
) async {
  try {
    // show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Processing...Getting data..."),
            ],
          ),
        );
      },
    );

    WidgetsFlutterBinding.ensureInitialized();

    // --- Prepare Parameters
    String finalparameterevalues = Parametertype == 'Undel id'
        ? '&undel_id=$parametervalue'
        : (Parametertype == 'Customer Number'
            ? '&customer_no=$parametervalue'
            : (Parametertype.isEmpty ? '' : '&salesman_name=$parametervalue'));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String salesmanno = prefs.getString('salesloginno') ?? 'Unknown ID';
    String salesloginrole = prefs.getString('salesloginrole') ?? 'Unknown ID';

    String sendvalues = (await fetchSalesmanName(salesmanno.trim())) ?? "";
    String salesmanstatus = salesloginrole == 'Salesman'
        ? '&salesman_name=$sendvalues$finalparameterevalues'
        : '$finalparameterevalues';

    final IpAddress = await getActiveOracleIpAddress();
    final response = await http.get(
      Uri.parse(
        '$IpAddress/Report-grouped-truck-scan-details/?from_date=$fromDateFormatted&to_date=$endDateFormatted$salesmanstatus',
      ),
    );
    print(
        "url report  '$IpAddress/Report-grouped-truck-scan-details/?from_date=$fromDateFormatted&to_date=$endDateFormatted$salesmanstatus'");
    if (response.statusCode != 200) {
      throw Exception('Failed to load data: ${response.statusCode}');
    }

    final List<dynamic> data = json.decode(response.body);
    print("length of data ${data.length}");
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No data Found...'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Excel excel = Excel.createExcel();
    const String sheetName = 'Dispatch Report';
    final Sheet sheet = excel[sheetName];
    excel.setDefaultSheet(sheetName);

    // --- Styles
    final headerStyle = CellStyle(
      fontColorHex: '#000000',
      backgroundColorHex: '#95C7F9',
      bold: true,
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
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );

    // Compute Dispatch From/To dates
    String dispatchFrom = _formatCustomDate(fromDateFormatted);
    String dispatchTo = _formatCustomDate(endDateFormatted);
    int row = 0;

    // --- Report Title
    sheet.merge(
      CellIndex.indexByString("A1"),
      CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: 0),
    );
    final titleCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
    titleCell.value = 'TruckLoad Sales Dispatch Value Details Report';
    titleCell.cellStyle = titleStyle;
    row += 2;

    // --- Runtime (merged full width)
    final String formattedTime =
        DateFormat('hh:mm:ss a').format(DateTime.now());
    final String formattedToday =
        DateFormat('dd-MMM-yyyy').format(DateTime.now());

    sheet.merge(CellIndex.indexByString("A${row + 1}"),
        CellIndex.indexByString("D${row + 1}"));
    final runtimeCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
    runtimeCell.value = 'Runtime : $formattedToday -- $formattedTime';
    runtimeCell.cellStyle = filteredStyle;
    row++;

    // --- Filter row
    sheet.merge(CellIndex.indexByString("A${row + 1}"),
        CellIndex.indexByString("D${row + 1}"));
    final filterCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
    filterCell.value = (Parametertype == "Salesman Number")
        ? "Salesman Name Filtration : $parametervalue"
        : '${Parametertype.isNotEmpty ? "$Parametertype Filtration" : ""}: $parametervalue';
    filterCell.cellStyle = filteredStyle;
    row += 2;

    // --- Dispatch From Date (Label in A–C, Value in D)
    sheet.merge(
      CellIndex.indexByString("A${row + 1}"),
      CellIndex.indexByString("C${row + 1}"),
    );
    final fromLabelCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
    );
    fromLabelCell.value = 'Dispatch From Date:';
    fromLabelCell.cellStyle = headerStyle;

// Value goes into column D
    final fromValueCell = sheet.cell(
      CellIndex.indexByColumnRow(
          columnIndex: 3, rowIndex: row), // colIndex 3 = D
    );
    fromValueCell.value = dispatchFrom;
    fromValueCell.cellStyle = headerStyle;

    row++;

    // --- Dispatch To Date
    sheet.merge(
      CellIndex.indexByString("A${row + 1}"),
      CellIndex.indexByString("C${row + 1}"),
    );
    final toLabelCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
    );
    toLabelCell.value = 'Dispatch To Date:';
    toLabelCell.cellStyle = headerStyle;

// Value goes into column D
    final toValueCell = sheet.cell(
      CellIndex.indexByColumnRow(
          columnIndex: 3, rowIndex: row), // colIndex 3 = D
    );
    toValueCell.value = dispatchTo;
    toValueCell.cellStyle = headerStyle;
    row += 2;

    // --- Loop through Customers (same as before)
    for (final group in data) {
      String customerNo = group['customer_number']?.toString() ?? '';
      String customerName = group['customer_name']?.toString() ?? '';
      final List<dynamic> dispatches = (group['dispatches'] is List)
          ? List<dynamic>.from(group['dispatches'])
          : <dynamic>[];

      // Group by invoice
      final Map<String, List<dynamic>> invoiceGroups = {};
      for (final d in dispatches) {
        final invoiceNo = d?['invoice_no']?.toString() ?? 'Unknown Invoice';
        invoiceGroups.putIfAbsent(invoiceNo, () => <dynamic>[]);
        invoiceGroups[invoiceNo]!.add(d);
      }

      for (final entry in invoiceGroups.entries) {
        final invoiceNo = entry.key;
        final List<dynamic> invoiceDispatches = entry.value;
        double invoiceTotal = 0.0;
        double VATTotal = 0.0;
        double NETTotal = 0.0;
        int totalqty = 0;

        // --- Section Header (dynamic merge width)
        final sectionText =
            "Customer: $customerNo - $customerName | Invoice: $invoiceNo";

// Estimate how many columns are needed (adjust factor if needed)
        int neededCols = (sectionText.length / 15).ceil();
        if (neededCols < 4) neededCols = 4; // minimum 4 cols (A–D)

// Merge A to that column
        final endColLetter =
            String.fromCharCode('A'.codeUnitAt(0) + (neededCols - 1));
        sheet.merge(
          CellIndex.indexByString("A${row + 1}"),
          CellIndex.indexByString("$endColLetter${row + 1}"),
        );

// Write into the merged cell
        final secCell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
        );
        secCell.value = sectionText;
        secCell.cellStyle = filteredStyle;

        row++;

        // Headers
        const headers = [
          'Regions',
          'Customer No',
          'Customer Name',
          'Item Code',
          'Description',
          'Invoice Number',
          'Invoice Date',
          'NET Amount',
          'VAT Amount',
          'NET After VAT Amount',
          'Invoice Quantity',
          'Invoice Amount',
          'Dispatch Number',
          'Dispatch NET Amount',
          'Dispatch VAT Amount',
          'Dispatch NET After VAT Amount',
          'Dispatch Date',
          'Dispatch Qty',
          'Dispatch Amount'
        ];
        for (int col = 0; col < headers.length; col++) {
          final cell = sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
          cell.value = headers[col];
          cell.cellStyle = headerStyle;
        }
        row++;

        // Rows
        for (final d in invoiceDispatches) {
          final invoice_qty = _toDouble(d?['quantity']);
          final qty = _toDouble(d?['truck_send_qty']);
          final itemCost = _toDouble(d?['item_cost']);
          final totalCost = _toDouble(d?['total_cost']);
          final NETtotalCost = _toDouble(d?['net_amount']);
          final VATtotalCost = _toDouble(d?['vat_amount']);
          invoiceTotal += totalCost;
          NETTotal += NETtotalCost;
          VATTotal += VATtotalCost;
          totalqty += qty.toInt();

          final values = <dynamic>[
            d?['region']?.toString() ?? '',
            customerNo,
            customerName,
            d?['item_code']?.toString() ?? '',
            d?['item_details']?.toString() ?? '',
            d['invoice_no'] ?? '',
            _formatCustomDate(d['invoice_date']),
            totalCost,
            VATtotalCost,
            NETtotalCost,
            invoice_qty,
            (invoice_qty * itemCost),
            d?['dispatch_id']?.toString() ?? '',
            totalCost,
            VATtotalCost,
            NETtotalCost,
            _formatCustomDate(d['dispatch_date']),
            qty,
            totalCost,
          ];

          for (int col = 0; col < values.length; col++) {
            final cell = sheet.cell(
                CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
            final v = values[col];
            if (v is num) {
              cell.value = v;
              cell.cellStyle = numericStyle;
            } else {
              cell.value = v?.toString() ?? '';
              cell.cellStyle = textCellStyle;
            }
          }
          row++;
        }

// Invoice Total Row
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: row))
            .value = 'Total Amount:';
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: row))
            .cellStyle = headerStyle;

// Set column 21 width
        sheet.setColWidth(11, 18); // Adjust as needed

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: row))
            .value = invoiceTotal;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: row))
            .cellStyle = numericStyle;

// Set column 22 width
        sheet.setColWidth(18, 20); // Adjust as needed

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: row))
            .value = VATTotal;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: row))
            .cellStyle = numericStyle;

// Set column 22 width
        sheet.setColWidth(18, 20); // Adjust as needed

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: row))
            .value = NETTotal;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: row))
            .cellStyle = numericStyle;

// Set column 22 width
        sheet.setColWidth(18, 20); // Adjust as needed

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 17, rowIndex: row))
            .value = totalqty;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 17, rowIndex: row))
            .cellStyle = numericStyle;

// Set column 22 width
        sheet.setColWidth(18, 20); // Adjust as needed

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 18, rowIndex: row))
            .value = invoiceTotal;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 18, rowIndex: row))
            .cellStyle = numericStyle;

// Set column 22 width
        sheet.setColWidth(18, 20); // Adjust as needed
        row++;
      }
    }

    // ✅ Auto-fit ONLY table columns (from 2 onwards, leave 0 & 1 fixed)
    for (int col = 2; col < 21; col++) {
      int maxLen = 0;
      for (int r = 0; r < row; r++) {
        final cellVal = sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: r))
            .value;
        final String strVal = (cellVal == null) ? '' : cellVal.toString();
        if (strVal.length > maxLen) maxLen = strVal.length;
      }
      final double width = (maxLen + 2).toDouble();
      sheet.setColWidth(col, width < 8.0 ? 8.0 : width);
    }

    // Save Excel
    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode Excel');

    String parameter = (Parametertype == "Salesman Number")
        ? "Salesman_Name_${parametervalue}_"
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
  } catch (e, st) {
    print('❌ Excel Export Error: $e');
    print(st);
  } finally {
    try {
      Navigator.of(context).pop();
    } catch (_) {}
  }
}

// ==========================
// Helpers
// ==========================
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
    return dateString ?? '';
  }
}

double _toDouble(dynamic v) =>
    (v == null) ? 0.0 : double.tryParse(v.toString()) ?? 0.0;
