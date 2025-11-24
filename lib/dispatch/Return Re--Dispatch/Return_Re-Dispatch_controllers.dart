import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aljeflutterapp/Database/IpAddress.dart';

class Return_ReDispatchController extends ChangeNotifier {
  final Function togglePage;
  final Function editTogglePage;
  final String ClickMessage;

  // State variables
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> filteredData = [];

  List<Map<String, dynamic>> returnreasontableData = [];
  List<Map<String, dynamic>> returnreasonfilteredData = [];
  int currentPage = 1;
  int itemsPerPage = 10;
  int totalItems = 0;

  int reportcurrentPage = 1;
  int reportitemsPerPage = 10;
  int reporttotalItems = 0;

  // Filter controllers
  TextEditingController searchReqNoController = TextEditingController();
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

  Return_ReDispatchController({
    required this.togglePage,
    required this.editTogglePage,
    required this.ClickMessage,
  }) {
    _init();
  }

  Future<void> _init() async {
    await _loadSalesmanName();
    notifyListeners();
    fetchreturndispatch();
    fetchreturnreasondispatch();
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

  Future<void> fetchreturndispatch() async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? saleslogiOrgid =
          prefs.getString('saleslogiOrgwarehousename') ?? '';
      String? salesloginno = prefs.getString('salesloginno') ?? '';
      String? salesloginrole = prefs.getString('salesloginrole') ?? '';
      final ipAddress = await getActiveIpAddress();

      String url = '$ipAddress/Return_dispatch/';
      List<Map<String, dynamic>> allData = [];

      while (url.isNotEmpty) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
          final data = jsonDecode(decodedBody);
          final results = data['results'] as List?;
          url = data['next'] ?? '';

          if (results != null) {
            for (var item in results) {
              // Debug print to see what data is being received
              // print('Raw item data: $item');

              if (item['ORG_NAME'] == saleslogiOrgid &&
                  (salesloginrole == "WHR SuperUser")) {
                allData.add(item);
              }
            }
          }
        } else {
          throw Exception('Failed to load data: ${response.statusCode}');
        }
      }

      // Debug print to see all collected data before processing
      // print('All collected data before processing: $allData');

      // Process and group data
      tableData = await _processReturnData(allData);

      // Debug print to see processed data before filtering
      // print('Processed data before filtering: $tableData');

      // Apply minimal filtering - just show all valid return dispatches
      filteredData = tableData.where((data) {
        // Basic validation to ensure we have required fields
        return data['returnno'] != null &&
            data['returnno'].toString().isNotEmpty &&
            (data['return_qty'] ?? 0) > 0;
      }).toList();

      // Debug print to see final filtered data
      // print('Final filtered data: $filteredData');

      totalItems = filteredData.length;
    } catch (e) {
      print('Error fetching data: $e');
      // Optionally show error to user
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading returns: $e')));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> _processReturnData(
      List<Map<String, dynamic>> rawData) async {
    Map<String, Map<String, dynamic>> groupedData = {};

    for (var item in rawData) {
      try {
        String returnno = item['RETURN_DIS_ID']?.toString() ?? '';
        if (returnno.isEmpty) continue;

        String deliveryno = item['DISPATCH_ID']?.toString() ?? '';
        String reqno = item['REQ_ID']?.toString() ?? '';
        String salesmanId = item['SALESMAN_NO']?.toString().split('.')[0] ?? '';

        double truckSendQty =
            double.tryParse(item['TRUCK_SEND_QTY']?.toString() ?? '0') ?? 0;
        String reassignStatus = item['RE_ASSIGN_STATUS']?.toString() ?? '';

        // Skip items with 0 or less qty
        if (truckSendQty <= 0) continue;

        bool shouldAddToTotal = reassignStatus != 'Re-Assign-Finished';

        if (!groupedData.containsKey(returnno)) {
          groupedData[returnno] = {
            'id': item['id']?.toString() ?? '',
            'salesman': salesmanId,
            'returnno': returnno,
            'reqdeliverynono': deliveryno,
            'reqno': reqno,
            'managerno': item['MANAGER_NO']?.toString() ?? '',
            'managename': item['MANAGER_NAME']?.toString() ?? '',
            'salesmanName': item['SALESMAN_NAME']?.toString() ?? '',
            'cusno': item['CUSTOMER_NUMBER']?.toString() ?? '',
            'cusname': item['CUSTOMER_NAME']?.toString() ?? '',
            'cussite': item['CUSTOMER_SITE_ID']?.toString() ?? '',
            'date': DateFormat('dd.MM.yyyy')
                .format(DateTime.parse(item['DATE'] ?? '')),
            'transporter': item['TRANSPORTER_NAME']?.toString() ?? '',
            'drivername': item['DRIVER_NAME']?.toString() ?? '',
            'drivermobile': item['DRIVER_MOBILENO']?.toString() ?? '',
            'vehicleno': item['VEHICLE_NO']?.toString() ?? '',
            'remarks': item['REMARKS']?.toString() ?? '',
            'return_reason': item['RETURN_REASON']?.toString() ?? '',
            'dis_qty_total': shouldAddToTotal ? truckSendQty : 0.0,
            'previous_truck_qty': 0,
            'picked_qty': 0,
            'return_qty': shouldAddToTotal ? truckSendQty : 0.0,
            'items': [
              {
                'item_code': item['ITEM_CODE']?.toString() ?? '',
                'item_details': item['ITEM_DETAILS']?.toString() ?? '',
                'product_code': item['PRODUCT_CODE']?.toString() ?? '',
                'serial_no': item['SERIAL_NO']?.toString() ?? '',
                'qty': truckSendQty,
                'invoice_no': item['INVOICE_NO']?.toString() ?? '',
                'return_reason': item['RETURN_REASON']?.toString() ?? '',
                'status': reassignStatus,
              }
            ],
          };
        } else {
          // Update totals only if status is not 'Re-Assign-Finished'
          if (shouldAddToTotal) {
            groupedData[returnno]!['dis_qty_total'] += truckSendQty;
            groupedData[returnno]!['return_qty'] += truckSendQty;
          }

          // Add item details regardless of status
          groupedData[returnno]!['items'].add({
            'item_code': item['ITEM_CODE']?.toString() ?? '',
            'item_details': item['ITEM_DETAILS']?.toString() ?? '',
            'product_code': item['PRODUCT_CODE']?.toString() ?? '',
            'serial_no': item['SERIAL_NO']?.toString() ?? '',
            'qty': truckSendQty,
            'invoice_no': item['INVOICE_NO']?.toString() ?? '',
            'return_reason': item['RETURN_REASON']?.toString() ?? '',
            'status': reassignStatus,
          });
        }
      } catch (e) {
        print('Error processing item $item: $e');
      }
    }

    return groupedData.values.toList();
  }

  Future<void> fetchreturnreasondispatch() async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? saleslogiOrgid =
          prefs.getString('saleslogiOrgwarehousename') ?? '';
      String? salesloginno = prefs.getString('salesloginno') ?? '';
      String? salesloginrole = prefs.getString('salesloginrole') ?? '';
      final ipAddress = await getActiveIpAddress();

      String url = '$ipAddress/Return_dispatch/';
      List<Map<String, dynamic>> allData = [];

      while (url.isNotEmpty) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
          final data = jsonDecode(decodedBody);
          final results = data['results'] as List?;
          url = data['next'] ?? '';

          if (results != null) {
            for (var item in results) {
              // Debug print to see what data is being received
              // print('Raw item data: $item');

              if (item['ORG_NAME'] == saleslogiOrgid &&
                  (salesloginrole == "WHR SuperUser")) {
                allData.add(item);
              }
            }
          }
        } else {
          throw Exception('Failed to load data: ${response.statusCode}');
        }
      }

      // Debug print to see all collected data before processing
      // print('All collected data before processing: $allData');

      // Process and group data
      returnreasontableData = await _returnreasonprocessReturnData(allData);

      // Debug print to see processed data before filtering
      // print('Processed data before filtering: $returnreasontableData');

      // Apply minimal filtering - just show all valid return dispatches
      returnreasonfilteredData = returnreasontableData.where((data) {
        // Basic validation to ensure we have required fields
        return data['returnno'] != null &&
            data['returnno'].toString().isNotEmpty &&
            (data['return_qty'] ?? 0) > 0;
      }).toList();

      print('Processed data after filtering: $returnreasonfilteredData');
      // Debug print to see final filtered data
      // print('Final filtered data: $filteredData');

      reporttotalItems = returnreasonfilteredData.length;
    } catch (e) {
      print('Error fetching data: $e');
      // Optionally show error to user
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading returns: $e')));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> _returnreasonprocessReturnData(
      List<Map<String, dynamic>> rawData) async {
    Map<String, Map<String, dynamic>> groupedData = {};

    for (var item in rawData) {
      try {
        String returnno = item['RETURN_DIS_ID']?.toString() ?? '';
        if (returnno.isEmpty) continue;

        String deliveryno = item['DISPATCH_ID']?.toString() ?? '';
        String reqno = item['REQ_ID']?.toString() ?? '';
        String salesmanId = item['SALESMAN_NO']?.toString().split('.')[0] ?? '';

        double truckSendQty =
            double.tryParse(item['TRUCK_SEND_QTY']?.toString() ?? '0') ?? 0;
        String reassignStatus = item['RE_ASSIGN_STATUS']?.toString() ?? '';

        // Skip items with 0 or less qty
        if (truckSendQty <= 0) continue;

        bool shouldAddToTotal = true;

        if (!groupedData.containsKey(returnno)) {
          groupedData[returnno] = {
            'id': item['id']?.toString() ?? '',
            'salesman': salesmanId,
            'returnno': returnno,
            'reqdeliverynono': deliveryno,
            'reqno': reqno,
            'managerno': item['MANAGER_NO']?.toString() ?? '',
            'managename': item['MANAGER_NAME']?.toString() ?? '',
            'salesmanName': item['SALESMAN_NAME']?.toString() ?? '',
            'cusno': item['CUSTOMER_NUMBER']?.toString() ?? '',
            'cusname': item['CUSTOMER_NAME']?.toString() ?? '',
            'cussite': item['CUSTOMER_SITE_ID']?.toString() ?? '',
            'date':
                DateFormat('dd.MM.yyyy').format(DateTime.parse(item['DATE'])),
            'transporter': item['TRANSPORTER_NAME']?.toString() ?? '',
            'drivername': item['DRIVER_NAME']?.toString() ?? '',
            'drivermobile': item['DRIVER_MOBILENO']?.toString() ?? '',
            'vehicleno': item['VEHICLE_NO']?.toString() ?? '',
            'remarks': item['REMARKS']?.toString() ?? '',
            'return_reason': item['RETURN_REASON']?.toString() ?? '',
            'dis_qty_total': truckSendQty,
            'previous_truck_qty': 0,
            'picked_qty': 0,
            'return_qty': truckSendQty,
            'items': [
              {
                'item_code': item['ITEM_CODE']?.toString() ?? '',
                'item_details': item['ITEM_DETAILS']?.toString() ?? '',
                'product_code': item['PRODUCT_CODE']?.toString() ?? '',
                'serial_no': item['SERIAL_NO']?.toString() ?? '',
                'qty': truckSendQty,
                'invoice_no': item['INVOICE_NO']?.toString() ?? '',
                'return_reason': item['RETURN_REASON']?.toString() ?? '',
                'status': reassignStatus,
              }
            ],
          };
        } else {
          // Update totals only if status is not 'Re-Assign-Finished'
          if (shouldAddToTotal) {
            groupedData[returnno]!['dis_qty_total'] += truckSendQty;
            groupedData[returnno]!['return_qty'] += truckSendQty;
          }

          // Add item details regardless of status
          groupedData[returnno]!['items'].add({
            'item_code': item['ITEM_CODE']?.toString() ?? '',
            'item_details': item['ITEM_DETAILS']?.toString() ?? '',
            'product_code': item['PRODUCT_CODE']?.toString() ?? '',
            'serial_no': item['SERIAL_NO']?.toString() ?? '',
            'qty': truckSendQty,
            'invoice_no': item['INVOICE_NO']?.toString() ?? '',
            'return_reason': item['RETURN_REASON']?.toString() ?? '',
            'status': reassignStatus,
          });
        }
      } catch (e) {
        print('Error processing item $item: $e');
      }
    }

    return groupedData.values.toList();
  }

  int get totalPages => (totalItems / itemsPerPage).ceil();

  int get returnreasontotalPages =>
      (reporttotalItems / reportitemsPerPage).ceil();

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage = page;
      notifyListeners();
    }
  }

  void returnreasongoToPage(int page) {
    if (page >= 1 && page <= returnreasontotalPages) {
      reportcurrentPage = page;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get paginatedData {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;

    if (endIndex > filteredData.length) {
      endIndex = filteredData.length;
    }

    return filteredData.sublist(startIndex, endIndex);
  }

  List<Map<String, dynamic>> get returnreasonpaginatedData {
    int startIndex = (reportcurrentPage - 1) * reportitemsPerPage;
    int endIndex = startIndex + reportitemsPerPage;

    if (endIndex > returnreasonfilteredData.length) {
      endIndex = returnreasonfilteredData.length;
    }

    return returnreasonfilteredData.sublist(startIndex, endIndex);
  }

  bool _isSecondRowVisible = false;

  bool get isSecondRowVisible => _isSecondRowVisible;

  void toggleSecondRowVisibility() {
    _isSecondRowVisible = !_isSecondRowVisible;
    notifyListeners();
  }
}
