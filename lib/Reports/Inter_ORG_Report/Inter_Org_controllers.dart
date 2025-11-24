import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aljeflutterapp/Database/IpAddress.dart';

class Inter_Org_Controller extends ChangeNotifier {
  // State variables
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> filteredData = [];

  List<Map<String, dynamic>> orginalfilteredData = [];

  List<Map<String, dynamic>> receviedtableData = [];
  List<Map<String, dynamic>> receviedfilteredData = [];

  List<Map<String, dynamic>> receviedDetailstableData = [];
  List<Map<String, dynamic>> receviedDetialsfilteredData = [];

  int currentPage = 1;
  int itemsPerPage = 10;
  int totalItems = 0;

  int receviedcurrentPage = 1;
  int recevieditemsPerPage = 10;
  int receviedtotalItems = 0;

  int receviedDetailscurrentPage = 1;
  int receviedDetailsitemsPerPage = 10;
  int receviedDetailstotalItems = 0;

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

  Inter_Org_Controller() {
    _init();
  }
  bool interORGReportisReceived = false;
  bool InterORGReceviedisReceived = false;
  Future<void> _init() async {
    await _loadSalesmanName();
    notifyListeners();
    fetchInterorgDispatch('Not Recevied');
    // fetchReceviedInterorgDispatch('Not Recevied');
    // fetchReceviedDetailsInterorgDispatch();
    fetchAccessControl();
  }

  List<String> accessControl = [];
  Future<List<String>> fetchAccessControl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lableRoleIDList = prefs.getString('departmentid');
    String? salesloginnoStr = prefs.getString('salesloginno');

    final IpAddress = await getActiveIpAddress();

    final String url =
        "$IpAddress/New_Updated_get_submenu_list/$lableRoleIDList/$salesloginnoStr/";
    print("Fetching submenu list from: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
        final Map<String, dynamic> data = json.decode(decodedBody);

        if (data.containsKey('submenu')) {
          // Update accessControl with fetched submenu list
          accessControl = List<String>.from(data['submenu']);
        }

        print("Fetched accessControl: $accessControl"); // Debugging output
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching submenu list: $e");
    }

    return accessControl; // ✅ Added return statement
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

  Future<void> fetchInterorgDispatch(String Status) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? saleslogiOrgid =
          prefs.getString('saleslogiOrgwarehousename') ?? '';
      String? salesloginno = prefs.getString('salesloginno') ?? '';
      String? salesloginrole = prefs.getString('salesloginrole') ?? '';
      String? saleslogiOrgwarehousename =
          prefs.getString('saleslogiOrgwarehousename') ?? '';

      final IpAddress = await getActiveIpAddress();
      String url =
          '$IpAddress/get-shipment-by-warehouse/?warehousename=$saleslogiOrgwarehousename&status=$Status';
      print("urlllllll $url");
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
        final data = jsonDecode(decodedBody);

        // Expecting data as a list of maps
        List<Map<String, dynamic>> allData = [];

        if (data is List) {
          for (var item in data) {
            if (salesloginrole == "WHR SuperUser") {
              allData.add(Map<String, dynamic>.from(item));
            }
          }
        }

        // Process and group data
        tableData = await _processReturnData(allData);

        // Filter for valid shipment return dispatches
        filteredData = tableData.where((data) {
          return data['shipment_id'] != null &&
              data['shipment_id'].toString().isNotEmpty &&
              (data['quantity_progress'] ?? 0) > 0;
        }).toList();

        orginalfilteredData = filteredData;

        print("Filtered data length ${filteredData.length}");
        print("orginalfilteredData data length ${orginalfilteredData.length}");
        totalItems = filteredData.length;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching return dispatch: ');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> fetchReceviedInterorgDispatch(String status) async {
  //   final IpAddress = await getActiveIpAddress();
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   String? saleslogiOrgwarehousename =
  //       prefs.getString('saleslogiOrgwarehousename') ?? '';

  //   final url = Uri.parse(
  //     '$IpAddress/get_shipment_by_shipment_numwise_receviedwarehouse/?warehousename=$saleslogiOrgwarehousename&status=$status',
  //   );

  //   try {
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       final decodedBody = utf8.decode(response.bodyBytes); // handle utf8
  //       List<dynamic> jsonData = json.decode(decodedBody);

  //       // Set the received filtered data as List<Map<String, dynamic>>
  //       receviedfilteredData = List<Map<String, dynamic>>.from(jsonData);

  //       // Update count
  //       receviedtotalItems = receviedfilteredData.length;

  //       print(
  //           "Total items received: $receviedfilteredData $receviedtotalItems");
  //       if (receviedtotalItems > 0) {
  //         print("First item: ${receviedfilteredData[0]}");
  //       }
  //     } else {
  //       print('Failed to load data: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching shipment data: ');
  //   }
  // }

  Future<void> fetchReceviedInterorgDispatch(String status) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? salesloginrole = prefs.getString('salesloginrole') ?? '';
      String? saleslogiOrgwarehousename =
          prefs.getString('saleslogiOrgwarehousename') ?? '';

      final ipAddress = await getActiveIpAddress();
      String url =
          '$ipAddress/get_shipment_by_shipment_numwise_receviedwarehouse/?warehousename=$saleslogiOrgwarehousename&status=$status';

      print("Fetch Recevied URL: $url");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);

        List<Map<String, dynamic>> allData = [];

        if (data is List) {
          for (var item in data) {
            if (salesloginrole == "WHR SuperUser") {
              allData.add(Map<String, dynamic>.from(item));
            }
          }
        }

        receviedtableData = await _receviedprocessReceviedData(allData);

        receviedfilteredData = receviedtableData; // No filtering needed
        receviedtotalItems = receviedfilteredData.length;

        print("Recevied Items Count: $receviedtotalItems");
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching received dispatch: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  searchreqno(String searchText) {
    print("print the search text: $searchText");
    print("original filteredData length: ${orginalfilteredData.length}");

    // Convert both to lowercase for case-insensitive search
    final query = searchText.toLowerCase();

    filteredData = orginalfilteredData.where((item) {
      final shipmentId = (item['shipment_id'] ?? '').toString().toLowerCase();
      return query.isEmpty || shipmentId.contains(query);
    }).toList();

    totalItems = filteredData.length;
    print("filteredData.length: ${filteredData.length}");
    currentPage = 1;
    notifyListeners();
  }

  searchshipmentlineid(String searchText) {
    // print("orginalfilteredDataaaaaaa $orginalfilteredData");
    filteredData = orginalfilteredData.where((item) {
      return (searchText.isEmpty ||
          item['shipment_line_id'].toLowerCase().contains(searchText));
    }).toList();

    totalItems = filteredData.length;
    currentPage = 1;
    notifyListeners();
    // print("filteredData $filteredData");
  }

  searchshipmentnum(String searchText) {
    // print("orginalfilteredDataaaaaaa $orginalfilteredData");
    filteredData = orginalfilteredData.where((item) {
      return (searchText.isEmpty ||
          item['shipment_num'].toLowerCase().contains(searchText));
    }).toList();

    totalItems = filteredData.length;
    currentPage = 1;
    notifyListeners();
    // print("filteredData $filteredData");
  }

  Future<List<Map<String, dynamic>>> _receviedprocessReceviedData(
      List<Map<String, dynamic>> rawData) async {
    List<Map<String, dynamic>> processedData = [];

    for (var item in rawData) {
      try {
        String shippedDate = item['shipped_date']?.toString() ?? '';
        String formattedDate = '';

        try {
          if (shippedDate.isNotEmpty) {
            formattedDate =
                DateFormat('dd.MM.yyyy').format(DateTime.parse(shippedDate));
          }
        } catch (_) {
          formattedDate = '';
        }

        processedData.add({
          'organization_id': item['organization_id']?.toString() ?? '',
          'organization_code': item['organization_code']?.toString() ?? '',
          'organization_name': item['organization_name']?.toString() ?? '',
          'shipment_num': item['shipment_num']?.toString() ?? '',
          'receipt_num': item['receipt_num']?.toString() ?? '',
          'shipped_date': formattedDate,
          'to_orgn_id': item['to_orgn_id']?.toString() ?? '',
          'to_orgn_code': item['to_orgn_code']?.toString() ?? '',
          'to_orgn_name': item['to_orgn_name']?.toString() ?? '',
          'distinct_shipment_id_count_unreceived':
              item['distinct_shipment_id_count_unreceived'] ?? 0,
          'distinct_shipment_id_count_received':
              item['distinct_shipment_id_count_received'] ?? 0,
          'total_quantity_shipped_overall':
              item['total_quantity_shipped_overall'] ?? 0,
        });
      } catch (e) {
        // print('Error processing item: $e');
      }
    }

    return processedData;
  }

  Future<void> fetchReceviedDetailsInterorgDispatch(
      String passes_status, String shipment_id) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? saleslogiOrgid =
          prefs.getString('saleslogiOrgwarehousename') ?? '';
      String? salesloginno = prefs.getString('salesloginno') ?? '';
      String? salesloginrole = prefs.getString('salesloginrole') ?? '';
      String? saleslogiOrgwarehousename =
          prefs.getString('saleslogiOrgwarehousename') ?? '';

      final IpAddress = await getActiveIpAddress();
      String url =
          '$IpAddress/get_shipment_by_receviedwarehouse/?shipment_id=$shipment_id';
      print("urlllllll $url");
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
        final data = jsonDecode(decodedBody);

        // Expecting data as a list of maps
        List<Map<String, dynamic>> allData = [];

        if (data is List) {
          for (var item in data) {
            if (salesloginrole == "WHR SuperUser") {
              allData.add(Map<String, dynamic>.from(item));
            }
          }
        }

        // Process and group data
        receviedDetailstableData =
            await _receviedDetialsprocessReturnData(passes_status, allData);

        // Filter for valid shipment return dispatches
        receviedDetialsfilteredData = receviedDetailstableData.where((data) {
          return data['shipment_id'] != null &&
              data['shipment_id'].toString().isNotEmpty &&
              (data['quantity_progress'] ?? 0) > 0;
        }).toList();

        receviedDetailstotalItems = receviedDetialsfilteredData.length;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching return dispatch: ');
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
        String shipment_id = item['shipment_id']?.toString() ?? '';
        if (shipment_id.isEmpty) continue;

        String salesmanno = item['salesmanno']?.toString() ?? '';
        String salesmanname = item['salesmanname']?.toString() ?? '';

        double quantity_progress =
            double.tryParse(item['quantity_progress']?.toString() ?? '0') ?? 0;

        if (!groupedData.containsKey(shipment_id)) {
          // First time: create the group entry
          groupedData[shipment_id] = {
            'id': item['id']?.toString() ?? '',
            'salesmanno': salesmanno,
            'salesmanname': salesmanname,
            'shipment_id': shipment_id,
            'transporter_name': item['transporter_name']?.toString() ?? '',
            'driver_name': item['driver_name']?.toString() ?? '',
            'shipment_header_id': item['shipment_header_id']?.toString() ?? '',
            'shipment_line_id': item['shipment_line_id']?.toString() ?? '',
            'line_num': item['line_num']?.toString() ?? '',
            'creation_date': item['creation_date']?.toString() ?? '',
            'created_by': item['created_by']?.toString() ?? '',
            'date':
                DateFormat('dd.MM.yyyy').format(DateTime.parse(item['date'])),
            'organization_id': item['organization_id']?.toString() ?? '',
            'organization_code': item['organization_code']?.toString() ?? '',
            'organization_name': item['organization_name']?.toString() ?? '',
            'shipment_num': item['shipment_num']?.toString() ?? '',
            'receipt_num': item['receipt_num']?.toString() ?? '',
            'to_orgn_id': item['to_orgn_id']?.toString() ?? '',
            'to_orgn_code': item['to_orgn_code']?.toString() ?? '',
            'to_orgn_name': item['to_orgn_name']?.toString() ?? '',
            'quantity_progress': quantity_progress,
          };
        } else {
          // Already exists: accumulate the quantity_progress
          groupedData[shipment_id]?['quantity_progress'] += quantity_progress;
        }
        return groupedData.values.map((item) {
          return {
            ...item,
            'date':
                DateFormat('dd.MM.yyyy').format(DateTime.parse(item['date'])),
          };
        }).toList();
      } catch (e) {
        // print('Error processing item ');
      }
    }

    return groupedData.values.toList();
  }

  Future<List<Map<String, dynamic>>> _receviedDetialsprocessReturnData(
      String passes_status, List<Map<String, dynamic>> rawData) async {
    Map<String, Map<String, dynamic>> groupedData = {};

    for (var item in rawData) {
      try {
        String shipment_id = item['shipment_id']?.toString() ?? '';
        if (shipment_id.isEmpty) continue;

        String salesmanno = item['salesmanno']?.toString() ?? '';
        String salesmanname = item['salesmanname']?.toString() ?? '';

        double quantity_progress =
            double.tryParse(item['quantity_progress']?.toString() ?? '0') ?? 0;

        if (!groupedData.containsKey(shipment_id)) {
          // First time: create the group entry
          groupedData[shipment_id] = {
            'id': item['id']?.toString() ?? '',
            'salesmanno': salesmanno,
            'salesmanname': salesmanname,
            'shipment_id': shipment_id,
            'transporter_name': item['transporter_name']?.toString() ?? '',
            'driver_name': item['driver_name']?.toString() ?? '',
            'shipment_header_id': item['shipment_header_id']?.toString() ?? '',
            'shipment_line_id': item['shipment_line_id']?.toString() ?? '',
            'line_num': item['line_num']?.toString() ?? '',
            'creation_date': item['creation_date']?.toString() ?? '',
            'created_by': item['created_by']?.toString() ?? '',
            'date':
                DateFormat('dd.MM.yyyy').format(DateTime.parse(item['date'])),
            'organization_id': item['organization_id']?.toString() ?? '',
            'organization_code': item['organization_code']?.toString() ?? '',
            'organization_name': item['organization_name']?.toString() ?? '',
            'shipment_num': item['shipment_num']?.toString() ?? '',
            'receipt_num': item['receipt_num']?.toString() ?? '',
            'to_orgn_id': item['to_orgn_id']?.toString() ?? '',
            'to_orgn_code': item['to_orgn_code']?.toString() ?? '',
            'to_orgn_name': item['to_orgn_name']?.toString() ?? '',
            'quantity_progress': quantity_progress,
            'passes_status': passes_status,
          };
        } else {
          // Already exists: accumulate the quantity_progress
          groupedData[shipment_id]?['quantity_progress'] += quantity_progress;
        }
        return groupedData.values.map((item) {
          return {
            ...item,
            'date':
                DateFormat('dd.MM.yyyy').format(DateTime.parse(item['date'])),
          };
        }).toList();
      } catch (e) {
        // print('Error processing item ');
      }
    }

    return groupedData.values.toList();
  }

  Future<List<Map<String, dynamic>>> _receviedprocessReturnData(
      List<Map<String, dynamic>> rawData) async {
    Map<String, Map<String, dynamic>> groupedData = {};

    for (var item in rawData) {
      try {
        String shipment_id = item['shipment_num']?.toString() ?? '';
        if (shipment_id.isEmpty) continue;

        if (!groupedData.containsKey(shipment_id)) {
          groupedData[shipment_id] = {
            'organization_id': item['organization_id'] ?? 0,
            'organization_code': item['organization_code'] ?? '',
            'organization_name': item['organization_name'] ?? '',
            'shipment_num': item['shipment_num'] ?? '',
            'receipt_num': item['receipt_num'] ?? '',
            'shipped_date': item['shipped_date'] ?? '',
            'to_orgn_id': item['to_orgn_id'] ?? 0,
            'to_orgn_code': item['to_orgn_code'] ?? '',
            'to_orgn_name': item['to_orgn_name'] ?? '',
            'total_quantity_shipped': item['total_quantity_shipped'] ?? 0,
            'distinct_shipment_id_count':
                item['distinct_shipment_id_count'] ?? 0,
          };
        } else {
          // Optional: add accumulation logic here if needed
        }
      } catch (e) {
        // print('Error processing item ');
      }
    }

    return groupedData.values.toList();
  }

  int get totalPages => (totalItems / itemsPerPage).ceil();

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage = page;
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

  bool _isSecondRowVisible = false;

  bool get isSecondRowVisible => _isSecondRowVisible;

  void toggleSecondRowVisibility() {
    _isSecondRowVisible = !_isSecondRowVisible;
    notifyListeners();
  }

  int get receviedtotalPages =>
      (receviedtotalItems / recevieditemsPerPage).ceil();

  void receviedgoToPage(int page) {
    if (page >= 1 && page <= receviedtotalPages) {
      receviedcurrentPage = page;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get receviedpaginatedData {
    int receviedstartIndex = (receviedcurrentPage - 1) * recevieditemsPerPage;
    int receviedendIndex = receviedstartIndex + recevieditemsPerPage;

    if (receviedendIndex > receviedfilteredData.length) {
      receviedendIndex = receviedfilteredData.length;
    }

    return receviedfilteredData.sublist(receviedstartIndex, receviedendIndex);
  }

  bool _receviedisSecondRowVisible = false;

  bool get receviedisSecondRowVisible => _receviedisSecondRowVisible;

  void receviedtoggleSecondRowVisibility() {
    _receviedisSecondRowVisible = !_receviedisSecondRowVisible;
    notifyListeners();
  }

  int get receviedDetailstotalPages =>
      (receviedDetailstotalItems / receviedDetailsitemsPerPage).ceil();

  void receviedDetailsgoToPage(int page) {
    if (page >= 1 && page <= receviedDetailstotalPages) {
      receviedDetailscurrentPage = page;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get receviedDetailspaginatedData {
    int receviedDetailsstartIndex =
        (receviedDetailscurrentPage - 1) * receviedDetailsitemsPerPage;
    int receviedDetailsendIndex =
        receviedDetailsstartIndex + receviedDetailsitemsPerPage;

    if (receviedDetailsendIndex > receviedDetialsfilteredData.length) {
      receviedDetailsendIndex = receviedDetialsfilteredData.length;
    }

    return receviedDetialsfilteredData.sublist(
        receviedDetailsstartIndex, receviedDetailsendIndex);
  }

  bool _receviedDetialsisSecondRowVisible = false;

  bool get receviedDetailsisSecondRowVisible =>
      _receviedDetialsisSecondRowVisible;

  void recevieddetailstoggleSecondRowVisibility() {
    _receviedDetialsisSecondRowVisible = !_receviedDetialsisSecondRowVisible;
    notifyListeners();
  }
}
