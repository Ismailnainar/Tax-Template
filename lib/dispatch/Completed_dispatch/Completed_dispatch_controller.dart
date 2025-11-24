import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aljeflutterapp/Database/IpAddress.dart';

class CompletedDispatchController extends ChangeNotifier {
  final Function togglePage;

  // State variables
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> filteredData = [];

  List<Map<String, dynamic>> Oracle_CanceltableData = [];
  List<Map<String, dynamic>> Oracle_CancelfilteredData = [];

  int currentPageOracle_Cancel = 1;
  int itemsPerPageOracle_Cancel = 10;
  int totalItemsOracle_Cancel = 0;
  int currentPage = 1;
  int itemsPerPage = 10;
  int totalItems = 0;

  // Filter controllers
  TextEditingController searchReqNoController = TextEditingController();

  TextEditingController searchInvoicenooController = TextEditingController();
  TextEditingController OracleCancelsearchReqNoController =
      TextEditingController();
  TextEditingController salesmanIdController = TextEditingController();

  TextEditingController Oracle_CancelsalesmanIdController =
      TextEditingController();
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

  CompletedDispatchController({
    required this.togglePage,
  }) {
    _init();
  }

  Future<void> _init() async {
    await _loadSalesmanName();
    await fetchDispatchData();
    notifyListeners();
    fetchDispatchOracle_cancelData();
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
  //         // final responseData = json.decode(decodedBody);
  //         final data = jsonDecode(decodedBody);
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
  //       return dis_qty_total == previous_truck_qty;
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

  //   return groupedData.values.map((item) {
  //     return {
  //       ...item,
  //       'date': DateFormat('dd.MM.yyyy').format(DateTime.parse(item['date'])),
  //       'deliverydate': DateFormat('dd.MM.yyyy')
  //           .format(DateTime.parse(item['deliverydate'])),
  //     };
  //   }).toList();
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
          '$ipAddress/combined_dispatch_raw/?warehouse=$saleslogiOrgid&status=Fullfilled';

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
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  Future<void> fetchDispatchOracle_cancelData() async {
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
          '$ipAddress/combined_dispatch_Oracle_Cancel_raw/?warehouse=$saleslogiOrgid&status=Progressing';
      print("oracle update url $url");
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
        Oracle_CanceltableData = await _Oracle_CancelprocessData(allData);

        Oracle_CancelfilteredData = Oracle_CanceltableData;

        totalItemsOracle_Cancel = Oracle_CancelfilteredData.length;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> _Oracle_CancelprocessData(
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

  Future<void> fetchPreviousLoadCount() async {
    try {
      final ipAddress = await getActiveIpAddress();

      for (int i = 0; i < tableData.length; i++) {
        String reqno = tableData[i]['reqno'].toString();
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
      }

      // Update filteredData after updating previous_truck_qty
      filteredData = tableData.where((data) {
        var dis_qty_total =
            double.tryParse(data['dis_qty_total'].toString()) ?? 0;
        var previous_truck_qty =
            double.tryParse(data['previous_truck_qty'].toString()) ?? 0;
        return dis_qty_total == previous_truck_qty;
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
        final response = await http.get(Uri.parse(url));

        // print("urlll $url");
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
        return dis_qty_total == previous_truck_qty;
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
        return dis_qty_total == previous_truck_qty;
      }).toList();
    } catch (e) {
      print('Error fetching picked scan quantity: $e');
    }
    notifyListeners();
  }

  void setData(List<Map<String, dynamic>> data) {
    tableData = data;
    filteredData = List.from(data);
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
              itemDate.isAfter(fromDate.subtract(Duration(days: 1))) &&
                  itemDate.isBefore(toDate.add(Duration(days: 1)));
        } catch (e) {
          print('Error parsing dates: $e');
          return false;
        }
      }

      double disQty = double.tryParse(item['dis_qty_total'].toString()) ?? 0;
      double prevQty =
          double.tryParse(item['previous_truck_qty'].toString()) ?? 0;
      return matchesDate && disQty == prevQty;
    }).toList();

    // ✅ Update totalItems and totalPages here
    totalItems = filteredData.length;

    currentPage = 1;

    notifyListeners();
  }

  void clearFilters() {
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
      return dis_qty_total == previous_truck_qty;
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
      var dis_qty_total =
          double.tryParse(item['dis_qty_total'].toString()) ?? 0;
      var previous_truck_qty =
          double.tryParse(item['previous_truck_qty'].toString()) ?? 0;
      return (searchText.isEmpty ||
              item['reqno'].toLowerCase().contains(searchText)) &&
          dis_qty_total == previous_truck_qty;
    }).toList();

    totalItems = filteredData.length;
    currentPage = 1;
    notifyListeners();
  }

  searchInvoiceno() {
    String searchText = searchInvoicenooController.text.trim().toLowerCase();

    filteredData = tableData.where((item) {
      var dis_qty_total =
          double.tryParse(item['dis_qty_total'].toString()) ?? 0;
      var previous_truck_qty =
          double.tryParse(item['previous_truck_qty'].toString()) ?? 0;
      return (searchText.isEmpty ||
              item['invoice_no_list'].toLowerCase().contains(searchText)) &&
          dis_qty_total == previous_truck_qty;
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

  search() {
    String salesmanText = salesmanIdController.text.trim().toLowerCase();

    filteredData = tableData.where((item) {
      var dis_qty_total =
          double.tryParse(item['dis_qty_total'].toString()) ?? 0;
      var previous_truck_qty =
          double.tryParse(item['previous_truck_qty'].toString()) ?? 0;
      return (salesmanText.isEmpty ||
              item['salesman'].toLowerCase().contains(salesmanText)) &&
          dis_qty_total == previous_truck_qty;
    }).toList();

    totalItems = filteredData.length;
    currentPage = 1;
    notifyListeners();
  }

  void Oracle_CancelfilterData() {
    String searchText =
        OracleCancelsearchReqNoController.text.trim().toLowerCase();
    String salesmanText =
        Oracle_CancelsalesmanIdController.text.trim().toLowerCase();
    print('Oracle_CancelfilteredData  $Oracle_CancelfilteredData');

    Oracle_CancelfilteredData = Oracle_CanceltableData.where((item) {
      bool matchesSearch = searchText.isEmpty ||
          item['reqno'].toString().toLowerCase().contains(searchText);

      bool matchesSalesman = salesmanText.isEmpty ||
          item['salesman'].toString().toLowerCase().contains(salesmanText);

      bool matchesDate = true;
      if (fromDateController.text.isNotEmpty &&
          endDateController.text.isNotEmpty) {
        try {
          DateTime fromDate =
              DateFormat('dd-MMM-yyyy').parse(fromDateController.text);
          DateTime toDate =
              DateFormat('dd-MMM-yyyy').parse(endDateController.text);
          DateTime itemDate = DateFormat('dd.MMM.yyyy').parse(item['date']);

          matchesDate =
              itemDate.isAfter(fromDate.subtract(const Duration(days: 1))) &&
                  itemDate.isBefore(toDate.add(const Duration(days: 1)));
        } catch (e) {
          print('Error parsing dates: $e');
          matchesDate = false;
        }
      }

      double dis_qty_total =
          double.tryParse(item['dis_qty_total'].toString()) ?? 0;
      double previous_truck_qty =
          double.tryParse(item['previous_truck_qty'].toString()) ?? 0;

      bool matchesQuantityCondition = dis_qty_total == previous_truck_qty;

      return matchesSearch &&
          matchesSalesman &&
          matchesDate &&
          matchesQuantityCondition;
    }).toList();

    totalItemsOracle_Cancel = Oracle_CancelfilteredData.length;
    currentPageOracle_Cancel = 1;
    notifyListeners();
  }

  void Oracle_CancelclearFilters() {
    OracleCancelsearchReqNoController.clear();
    Oracle_CancelsalesmanIdController.clear();
    fromDateController.text = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    endDateController.text = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    // When clearing filters, still maintain the dis_qty_total != previous_truck_qty condition
    filteredData = Oracle_CancelfilteredData.where((data) {
      var dis_qty_total =
          double.tryParse(data['dis_qty_total'].toString()) ?? 0;
      var previous_truck_qty =
          double.tryParse(data['previous_truck_qty'].toString()) ?? 0;

      return dis_qty_total == previous_truck_qty;
    }).toList();
    totalItems = filteredData.length;
    currentPage = 1;
    notifyListeners();
  }

  List<Map<String, dynamic>> get Oracle_CancelpaginatedData {
    int startIndex = (currentPageOracle_Cancel - 1) * itemsPerPageOracle_Cancel;
    int endIndex = startIndex + itemsPerPageOracle_Cancel;

    if (endIndex > Oracle_CancelfilteredData.length) {
      endIndex = Oracle_CancelfilteredData.length;
    }

    return Oracle_CancelfilteredData.sublist(startIndex, endIndex);
  }

  int get Oracle_CanceltotalPages =>
      (totalItemsOracle_Cancel / itemsPerPageOracle_Cancel).ceil();

  void Oracle_CancelgoToPage(int page) {
    if (page >= 1 && page <= Oracle_CanceltotalPages) {
      currentPageOracle_Cancel = page;
      notifyListeners();
    }
  }

  Oracle_Cancelsearchreqno() {
    String searchText =
        OracleCancelsearchReqNoController.text.trim().toLowerCase();

    Oracle_CancelfilteredData = Oracle_CanceltableData.where((item) {
      var dis_qty_total =
          double.tryParse(item['dis_qty_total'].toString()) ?? 0;
      var previous_truck_qty =
          double.tryParse(item['previous_truck_qty'].toString()) ?? 0;
      return (searchText.isEmpty ||
          item['reqno'].toLowerCase().contains(searchText));
    }).toList();
    totalItemsOracle_Cancel = Oracle_CancelfilteredData.length;
    currentPageOracle_Cancel = 1;
    notifyListeners();
  }

  bool _Oracle_CancelisSecondRowVisible = false;

  bool get Oracle_CancelisSecondRowVisible => _Oracle_CancelisSecondRowVisible;

  void Oracle_CanceltoggleSecondRowVisibility() {
    _Oracle_CancelisSecondRowVisible = !_Oracle_CancelisSecondRowVisible;
    notifyListeners();
  }

  Oracle_Cancelsearch() {
    String salesmanText =
        Oracle_CancelsalesmanIdController.text.trim().toLowerCase();

    Oracle_CancelfilteredData = Oracle_CanceltableData.where((item) {
      var dis_qty_total =
          double.tryParse(item['dis_qty_total'].toString()) ?? 0;
      var previous_truck_qty =
          double.tryParse(item['previous_truck_qty'].toString()) ?? 0;
      return (salesmanText.isEmpty ||
          item['salesman'].toLowerCase().contains(salesmanText));
    }).toList();

    totalItemsOracle_Cancel = Oracle_CancelfilteredData.length;
    currentPageOracle_Cancel = 1;

    notifyListeners();
  }
}
