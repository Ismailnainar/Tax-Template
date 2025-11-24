import 'dart:io'; // for File
import 'package:path_provider/path_provider.dart'; // for getApplicationDocumentsDirectory
import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;

class OnProgressDispatchController extends ChangeNotifier {
  final Function togglePage;
  final Function editTogglePage;
  final Function quickBilltogglePage;

  // State variables
  bool searchbuttonnnnnnnnnnnnnnnn = false;
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> filteredData = [];
  int currentPage = 1;
  int itemsPerPage = 10;
  int totalItems = 0;

  // Filter controllers
  TextEditingController searchReqNoController = TextEditingController();
  TextEditingController searchInvoicenooController = TextEditingController();
  TextEditingController salesmanIdController = TextEditingController();
  TextEditingController fromDateController = TextEditingController(
      text: DateFormat('dd-MMM-yyyy').format(DateTime.now()));
  TextEditingController endDateController = TextEditingController(
      text: DateFormat('dd-MMM-yyyy').format(DateTime.now()));

  // User data
  String? saveloginname;
  String? saveloginrole;
  String? salesloginno;
  String? commersialname;
  String? commersialrole;

  OnProgressDispatchController({
    required this.togglePage,
    required this.editTogglePage,
    required this.quickBilltogglePage,
  }) {
    _init();
  }

  Future<void> _init() async {
    searchbuttonnnnnnnnnnnnnnnn = false;
    await _loadSalesmanName();
    await fetchDispatchData();
    notifyListeners();
  }

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    saveloginname = prefs.getString('saveloginname');
    saveloginrole = prefs.getString('salesloginrole');
    salesloginno = prefs.getString('salesloginno');
    commersialrole = prefs.getString('commersialrole');
    commersialname = prefs.getString('commersialname');
    notifyListeners();
  }

  // Future<void> fetchDispatchData() async {
  //   _isLoading = true;
  //   notifyListeners();

  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? saleslogiOrgid =
  //         prefs.getString('saleslogiOrgwarehousename') ?? '';
  //     String? salesloginno = prefs.getString('salesloginno') ?? '';
  //     String? salesloginrole = prefs.getString('salesloginrole') ?? '';
  //     final ipAddress = await getActiveIpAddress();

  //     String url = '$ipAddress/OnProgress_DispatchView/';
  //     List<Map<String, dynamic>> allData = [];

  //     while (url.isNotEmpty) {
  //       final response = await http.get(Uri.parse(url));
  //       if (response.statusCode == 200) {
  //         final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
  //         final data = jsonDecode(decodedBody);
  //         // final data = jsonDecode(response.body);
  //         final results = data['results'] as List?;
  //         url = data['next'] ?? '';

  //         if (results != null) {
  //           for (var item in results) {
  //             if (item['PHYSICAL_WAREHOUSE'] == saleslogiOrgid &&
  //                 item['FLAG'] != "D" &&
  //                 (salesloginrole == "WHR SuperUser"
  //                     ? true
  //                     : item['SALESMAN_NO'] == salesloginno)) {
  //               allData.add(item);
  //             }
  //           }
  //         }
  //       } else {
  //         throw Exception('Failed to load data');
  //       }
  //     }

  //     // Process and group data
  //     tableData = await _processData(allData);
  //     // Apply the initial filter to show only items where dis_qty_total != previous_truck_qty
  //     filteredData = tableData.where((data) {
  //       var dis_qty_total =
  //           double.tryParse(data['dis_qty_total'].toString()) ?? 0;
  //       var previous_truck_qty =
  //           double.tryParse(data['previous_truck_qty'].toString()) ?? 0;
  //       return dis_qty_total != previous_truck_qty;
  //     }).toList();
  //     totalItems = filteredData.length;

  //     // Fetch additional quantities
  //     await fetchPreviousLoadCount();
  //     await fetchreturnCode();
  //     await fetchPickedScanQty();
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> fetchDispatchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? saleslogiOrgid =
          prefs.getString('saleslogiOrgwarehousename') ?? '';
      String? salesloginno = prefs.getString('salesloginno') ?? '';
      String? salesloginrole = prefs.getString('salesloginrole') ?? '';
      final ipAddress = await getActiveIpAddress();

      // ✅ New API URL (raw query)
      String url =
          '$ipAddress/combined_dispatch_raw/?warehouse=$saleslogiOrgid&status=Progressing';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decodedBody);

        // Filter based on warehouse and role
        List<Map<String, dynamic>> allData = [];
        for (var item in data) {
          final itemMap = Map<String, dynamic>.from(item);

          if (salesloginrole == "WHR SuperUser") {
            // Show all data
            allData.add(itemMap);
          } else {
            // Show only data matching salesman_no
            if (itemMap['salesman_no'].toString() == salesloginno) {
              allData.add(itemMap);
            }
          }
        }
        // Process and group data
        tableData = await _processData(allData);

        filteredData = tableData;

        totalItems = filteredData.length;
        // print("filteredDataaaaa $filteredData");
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    print("searchbuttonaaaaaaaaaa $searchbuttonnnnnnnnnnnnnnnn");
  }

  Future<List<Map<String, dynamic>>> _processData(
      List<Map<String, dynamic>> rawData) async {
    return rawData.map((item) {
      return {
        'id': item['id'],
        'salesman': item['salesman_no']?.toString() ?? '',
        'reqno': item['reqno']?.toString() ?? '',
        'commercialNo': item['commercialNo']?.toString() ?? '',
        'commercialName': item['commercialName']?.toString() ?? '',
        'salesmanName': item['salesmanName']?.toString() ?? '',
        'cusno': item['cusno']?.toString() ?? '',
        'cusname': item['cusname']?.toString() ?? '',
        'cussite': item['cussite']?.toString() ?? '',
        'dis_qty_total':
            double.tryParse(item['dis_qty_total']?.toString() ?? '0') ?? 0,
        'dis_mangerQty_total':
            double.tryParse(item['dis_mangerQty_total']?.toString() ?? '0') ??
                0,
        'balance_qty':
            double.tryParse(item['balance_qty']?.toString() ?? '0') ?? 0,
        'previous_truck_qty':
            double.tryParse(item['previous_truck_qty']?.toString() ?? '0') ?? 0,
        'picked_qty':
            double.tryParse(item['picked_qty']?.toString() ?? '0') ?? 0,
        'return_qty':
            double.tryParse(item['return_qty']?.toString() ?? '0') ?? 0,
        'date': _formatDate(item['date']),
        'deliverydate': _formatDate(item['deliverydate']),
        'invoice_no_list': item['invoice_no_list']?.toString() ?? '',
      };
    }).toList();
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final parsedDate = DateTime.parse(date.toString());
      return DateFormat('dd.MMM.yyyy').format(parsedDate);
    } catch (_) {
      return '';
    }
  }

  // Future<List<Map<String, dynamic>>> _processData(
  //     List<Map<String, dynamic>> rawData) async {
  //   Map<String, Map<String, dynamic>> groupedData = {};

  //   for (var item in rawData) {
  //     String reqno = item['REQ_ID'];
  //     String salesmanId = item['SALESMAN_NO'].toString().split('.')[0];

  //     if (!groupedData.containsKey(reqno)) {
  //       groupedData[reqno] = {
  //         'id': item['id'],
  //         'salesman': salesmanId,
  //         'reqno': reqno,
  //         'commercialNo': item['COMMERCIAL_NO'],
  //         'commercialName': item['COMMERCIAL_NAME'],
  //         'salesmanName': item['SALESMAN_NAME'],
  //         'cusno': item['CUSTOMER_NUMBER'],
  //         'cusname': item['CUSTOMER_NAME'],
  //         'cussite': item['CUSTOMER_SITE_ID'],
  //         'dis_qty_total': double.parse(item['DISPATCHED_QTY'].toString()),
  //         'dis_mangerQty_total':
  //             double.parse(item['DISPATCHED_BY_MANAGER'].toString()),
  //         'date': item['INVOICE_DATE'],
  //         'deliverydate': item['DELIVERY_DATE'],
  //         'balance_qty': double.parse(item['DISPATCHED_QTY'].toString()) -
  //             double.parse(item['DISPATCHED_BY_MANAGER'].toString()),
  //         'previous_truck_qty': 0, // Will be updated later
  //         'picked_qty': 0, // Will be updated later
  //         'return_qty': 0, // Will be updated later
  //       };
  //     } else {
  //       groupedData[reqno]!['dis_qty_total'] +=
  //           double.parse(item['DISPATCHED_QTY'].toString());
  //       groupedData[reqno]!['dis_mangerQty_total'] +=
  //           double.parse(item['DISPATCHED_BY_MANAGER'].toString());
  //       groupedData[reqno]!['balance_qty'] =
  //           groupedData[reqno]!['dis_qty_total'] -
  //               groupedData[reqno]!['dis_mangerQty_total'];
  //     }
  //   }
  //   // print(
  //   //     "cusnosssssssssssssssss ${groupedData.values.map((e) => e['cusname']).toList()}");

  //   return groupedData.values.map((item) {
  //     return {
  //       ...item,
  //       'date': DateFormat('dd.MM.yyyy').format(DateTime.parse(item['date'])),
  //       'deliverydate': DateFormat('dd.MM.yyyy')
  //           .format(DateTime.parse(item['deliverydate'])),
  //     };
  //   }).toList();
  // }

  Future<void> fetchPreviousLoadCount() async {
    try {
      final ipAddress = await getActiveIpAddress();

      for (int i = 0; i < tableData.length; i++) {
        String reqno = tableData[i]['reqno'].toString();

        String dis_qty_total = tableData[i]['dis_qty_total'].toString();
        final truckScanUrl = '$ipAddress/Truck_scan/?REQ_ID=$reqno';

        int totalCount = 0;
        bool hasNextPage = true;
        String? nextPageUrl = truckScanUrl;

        while (hasNextPage && nextPageUrl != null) {
          final response = await http.get(Uri.parse(nextPageUrl));

          if (response.statusCode == 200) {
            final Map<String, dynamic> responseData =
                json.decode(response.body);

            if (responseData.containsKey('results')) {
              final List<dynamic> results = responseData['results'];

              // Count only items where FLAG is not 'R'
              int pageCount = results
                  .where(
                      (item) => item['FLAG']?.toString().toUpperCase() != 'R')
                  .length;

              totalCount += pageCount;
            }

            nextPageUrl = responseData['next'];
            hasNextPage = nextPageUrl != null;
          } else {
            throw Exception(
                'Failed to fetch data from $nextPageUrl. Status: ${response.statusCode}');
          }
        }

        tableData[i]['previous_truck_qty'] = totalCount;
        final intDisQtyTotal = int.tryParse(dis_qty_total.toString()) ?? 0;
        final intTotalCount = int.tryParse(totalCount.toString()) ?? 0;

        tableData[i]['Livestatus'] =
            intDisQtyTotal == intTotalCount ? 'Completed' : 'In Progress';
        // print("tableData[i]['Livestatus']  $tableData[i]['Livestatus']");
      }

      // Update filteredData after updating previous_truck_qty
      filteredData = tableData.where((data) {
        var dis_qty_total =
            double.tryParse(data['dis_qty_total'].toString()) ?? 0;
        var previous_truck_qty =
            double.tryParse(data['previous_truck_qty'].toString()) ?? 0;
        return dis_qty_total != previous_truck_qty;
      }).toList();

      totalItems = filteredData.length;
    } catch (e) {
      print('Error fetching previous load count: $e');
      // Consider adding error state handling here
    }
    notifyListeners();
  }

  Future<void> fetchreturnCode() async {
    try {
      final ipAddress = await getActiveIpAddress();

      for (int i = 0; i < tableData.length; i++) {
        String reqno = tableData[i]['reqno'].toString();
        String cusno = tableData[i]['cusno'].toString();
        String cussite = tableData[i]['cussite'].toString();

        final url = '$ipAddress/filteredreturnView/$reqno/$cusno/$cussite/';
        // print("urlll $url");
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData.containsKey('total_count')) {
            tableData[i]['return_qty'] = responseData['total_count'];
          }
        }
      }

      // Update filteredData after updating return_qty
      filteredData = tableData.where((data) {
        var dis_qty_total =
            double.tryParse(data['dis_qty_total'].toString()) ?? 0;
        var previous_truck_qty =
            double.tryParse(data['previous_truck_qty'].toString()) ?? 0;
        return dis_qty_total != previous_truck_qty;
      }).toList();
    } catch (e) {
      print('Error fetching return code: $e');
    }
    notifyListeners();
  }

  Future<void> fetchPickedScanQty() async {
    try {
      final ipAddress = await getActiveIpAddress();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? saleslogiOrgid =
          prefs.getString('saleslogiOrgwarehousename') ?? '';

      for (int i = 0; i < tableData.length; i++) {
        String reqno = tableData[i]['reqno'].toString();
        final String initialUrl =
            '$ipAddress/CompletedDispatchFilteredLivestageView/$reqno/';

        bool hasNextPage = true;
        String? nextPageUrl = initialUrl;
        double totalPickedQty = 0;

        while (hasNextPage && nextPageUrl != null) {
          final response = await http.get(Uri.parse(nextPageUrl));

          if (response.statusCode == 200) {
            final Map<String, dynamic> responseData =
                json.decode(response.body);

            if (responseData.containsKey('results')) {
              final List<dynamic> results = responseData['results'];

              for (var item in results) {
                if (item['REQ_ID'].toString() == reqno &&
                    item['FLAG'].toString() != 'R') {
                  if (item['PHYSICAL_WAREHOUSE']?.toString() ==
                      saleslogiOrgid) {
                    totalPickedQty +=
                        double.tryParse(item['PICKED_QTY'].toString()) ?? 0;
                  }
                }
              }
            }

            nextPageUrl = responseData['next'];
            hasNextPage = nextPageUrl != null;
          }
        }

        tableData[i]['picked_qty'] = totalPickedQty;
      }

      // Update filteredData after updating picked_qty
      filteredData = tableData.where((data) {
        var dis_qty_total =
            double.tryParse(data['dis_qty_total'].toString()) ?? 0;
        var previous_truck_qty =
            double.tryParse(data['previous_truck_qty'].toString()) ?? 0;
        return dis_qty_total != previous_truck_qty;
      }).toList();
    } catch (e) {
      print('Error fetching picked scan quantity: $e');
    }
    notifyListeners();
  }

  void filterData() {
    filteredData = tableData.where((item) {
      bool matchesDate = true;

      if (fromDateController.text.isNotEmpty &&
          endDateController.text.isNotEmpty) {
        try {
          DateTime fromDate =
              DateFormat('dd-MMM-yyyy').parse(fromDateController.text);
          DateTime toDate =
              DateFormat('dd-MMM-yyyy').parse(endDateController.text);
          String itemDateString = item['date']?.toString() ?? '';
          DateTime itemDate = DateFormat('dd.MMM.yyyy').parse(itemDateString);

          matchesDate =
              itemDate.isAfter(fromDate.subtract(const Duration(days: 1))) &&
                  itemDate.isBefore(toDate.add(const Duration(days: 1)));
        } catch (e) {
          print('Error parsing dates: $e');
          return false;
        }
      }

      var dis_qty_total =
          double.tryParse(item['dis_qty_total'].toString()) ?? 0;
      var previous_truck_qty =
          double.tryParse(item['previous_truck_qty'].toString()) ?? 0;

      return matchesDate && dis_qty_total != previous_truck_qty;
    }).toList();

    // ✅ Update totalItems and totalPages here
    totalItems = filteredData.length;

    currentPage = 1;

    notifyListeners();
  }

  Future<void> Createexcel_Onprogress(BuildContext context) async {
    final Workbook workbook = Workbook();

    _showProcessingDialog() {
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing the dialog manually
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: const [
                CircularProgressIndicator(color: Colors.blue),
                SizedBox(width: 20),
                Text(
                  "Processing...",
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          );
        },
      );
    }

    try {
      final Worksheet sheet = workbook.worksheets[0];

      // Get today's date
      final DateTime today = DateTime.now();
      final String formattedToday = DateFormat('dd-MMM-yyyy').format(today);

      // Get warehouse name from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String saleslogiOrgid =
          prefs.getString('saleslogiOrgwarehousename') ?? '';

      // -------------------------
      // 1. Define column mappings (keys only for row fields)
      // -------------------------
      final Map<String, String?> columnMapping = {
        'Salesman No': 'salesman',
        'Salesman Name': 'salesmanName',
        'Customer Number': 'cusno',
        'Customer Name': 'cusname',
        'Warehouse Name': null, // special case → always from prefs
        'Req id': 'reqno',
        'Date': 'date',
        'Delivery Date': 'deliverydate',
        'Requested Qty': 'dis_qty_total',
        'Assigned Qty': 'balance_qty',
        'Picked Qty': 'picked_qty',
        'Delivered Qty': 'previous_truck_qty',
      };

      final List<String> columnNames = columnMapping.keys.toList();

      // -------------------------
      // 2. Title
      // -------------------------
      final Range titleRange = sheet.getRangeByIndex(1, 1);
      titleRange.setText('Onprogress Report (Pending datas)');
      titleRange.cellStyle
        ..fontSize = 16
        ..bold = true
        ..hAlign = HAlignType.left;
      sheet.getRangeByIndex(1, 1, 1, columnNames.length).merge();

      // -------------------------
      // 3. Sub-title
      // -------------------------
      final Range subTitleRange = sheet.getRangeByIndex(2, 1);
      subTitleRange.setText('WMS Onprogress Details As On : $formattedToday');
      subTitleRange.cellStyle
        ..fontSize = 12
        ..italic = true
        ..hAlign = HAlignType.left;
      sheet.getRangeByIndex(2, 1, 2, columnNames.length).merge();

      // -------------------------
      // 4. Column Headers
      // -------------------------
      for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
        final Range range = sheet.getRangeByIndex(5, colIndex + 1);
        range.setText(columnNames[colIndex]);
        range.cellStyle
          ..backColor = '#E7F3FD'
          ..fontColor = '#000000'
          ..bold = true
          ..borders.all.lineStyle = LineStyle.thin
          ..borders.all.color = '#000000'
          ..hAlign = HAlignType.left;
      }

      // -------------------------
      // 5. Table Data
      // -------------------------
      for (int rowIndex = 0; rowIndex < filteredData.length; rowIndex++) {
        final row = filteredData[rowIndex];
        for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
          final String columnName = columnNames[colIndex];
          final String? dataKey = columnMapping[columnName];
          final dynamic cellValue =
              (dataKey == null) ? saleslogiOrgid : row[dataKey];

          final Range range = sheet.getRangeByIndex(rowIndex + 6, colIndex + 1);

          if (cellValue == null) {
            range.setText('');
          } else if (cellValue is num) {
            range.setNumber(cellValue.toDouble());
            range.numberFormat =
                (cellValue % 1 == 0) ? '0' : '#,##0.00'; // int or decimal
          } else if (cellValue is DateTime) {
            range.setDateTime(cellValue);
            range.numberFormat = 'DD-MMM-YYYY';
          } else {
            range.setText(cellValue.toString());
          }

          range.cellStyle
            ..borders.all.lineStyle = LineStyle.thin
            ..borders.all.color = '#000000'
            ..hAlign = HAlignType.left;
        }
      }

      // -------------------------
      // 6. Auto-fit columns
      // -------------------------
      for (int i = 1; i <= columnNames.length; i++) {
        sheet.autoFitColumn(i);
      }

      // -------------------------
      // 7. Save & Export
      // -------------------------
      final List<int> bytes = workbook.saveAsStream();
      String timestamp =
          '$formattedToday Time ${today.hour.toString().padLeft(2, '0')}hh-${today.minute.toString().padLeft(2, '0')}mm-${today.second.toString().padLeft(2, '0')}ss';

      if (kIsWeb) {
        final blob = base64.encode(bytes);
        AnchorElement(
          href: 'data:application/octet-stream;charset=utf-16le;base64,$blob',
        )
          ..setAttribute(
              'download', 'Onprogress Pending Details ($timestamp).xlsx')
          ..click();
      } else {
        final String path = (await getApplicationSupportDirectory()).path;
        final String fileName = Platform.isWindows
            ? '$path\\Excel Onprogress Pending Details ($timestamp).xlsx'
            : '$path/Excel Onprogress Pending Details ($timestamp).xlsx';

        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);
        OpenFile.open(fileName);
      }
    } catch (e) {
      print('Error in createExcel: $e');
      rethrow;
    } finally {
      workbook.dispose();
      Navigator.of(context).pop(); // ✅ Close the processing dialog
    }
  }

  void clearFilters() {
    searchbuttonnnnnnnnnnnnnnnn = false;
    searchReqNoController.clear();
    salesmanIdController.clear();
    fromDateController.text = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    endDateController.text = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    // When clearing filters, still maintain the dis_qty_total != previous_truck_qty condition
    filteredData = tableData.where((data) {
      var dis_qty_total =
          double.tryParse(data['dis_qty_total'].toString()) ?? 0;
      var previous_truck_qty =
          double.tryParse(data['previous_truck_qty'].toString()) ?? 0;
      return dis_qty_total != previous_truck_qty;
    }).toList();
    totalItems = filteredData.length;
    currentPage = 1;
    notifyListeners();
  }

  List<Map<String, dynamic>> get paginatedData {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;

    if (endIndex > filteredData.length) {
      endIndex = filteredData.length;
    }

    return filteredData.sublist(startIndex, endIndex);
  }

  int get totalPages => (totalItems / itemsPerPage).ceil();

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage = page;
      notifyListeners();
    }
  }

  searchreqno() {
    String searchText = searchReqNoController.text.trim().toLowerCase();

    filteredData = tableData.where((item) {
      String reqno = item['reqno']?.toString().toLowerCase() ?? '';
      double dis_qty_total =
          double.tryParse(item['dis_qty_total'].toString()) ?? 0;
      double previous_truck_qty =
          double.tryParse(item['previous_truck_qty'].toString()) ?? 0;

      // Check if the search text is contained anywhere in the reqno string
      bool matchesSearch = searchText.isEmpty || reqno.contains(searchText);

      return matchesSearch && dis_qty_total != previous_truck_qty;
    }).toList();

    totalItems = filteredData.length;
    currentPage = 1;
    notifyListeners();
  }

  searchInvoiceno() {
    String searchText = searchInvoicenooController.text.trim().toLowerCase();

    filteredData = tableData.where((item) {
      String invoice_no_list =
          item['invoice_no_list']?.toString().toLowerCase() ?? '';
      double dis_qty_total =
          double.tryParse(item['dis_qty_total'].toString()) ?? 0;
      double previous_truck_qty =
          double.tryParse(item['previous_truck_qty'].toString()) ?? 0;

      // Check if the search text is contained anywhere in the reqno string
      bool matchesSearch =
          searchText.isEmpty || invoice_no_list.contains(searchText);

      return matchesSearch && dis_qty_total != previous_truck_qty;
    }).toList();

    totalItems = filteredData.length;
    currentPage = 1;
    notifyListeners();
  }

  search() {
    String salesmanText = salesmanIdController.text.trim().toLowerCase();

    filteredData = tableData.where((item) {
      var dis_qty_total =
          double.tryParse(item['dis_qty_total'].toString()) ?? 0;
      var previous_truck_qty =
          double.tryParse(item['previous_truck_qty'].toString()) ?? 0;
      return (salesmanText.isEmpty ||
              item['salesman'].toLowerCase().contains(salesmanText)) &&
          dis_qty_total != previous_truck_qty;
    }).toList();

    totalItems = filteredData.length;
    currentPage = 1;
    notifyListeners();
  }

  bool _isSecondRowVisible = false;

  bool get isSecondRowVisible => _isSecondRowVisible;

  void toggleSecondRowVisibility() {
    _isSecondRowVisible = !_isSecondRowVisible;
    notifyListeners();
  }
}
