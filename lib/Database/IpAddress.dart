import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global variable for IP address

// Function to get the active IP address from shared preferences
const String Version = 'Version 1.2.11.22';

const String parameterdivided = '‡';

Future<String?> getActiveIpAddress() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonStr = prefs.getString('database_connections');

  if (jsonStr != null) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      final connections = jsonList.cast<Map<String, dynamic>>();

      for (var conn in connections) {
        if (conn['status'] == 'Active') {
          final endpoint = conn['endpoint']?.toString() ?? '';
          return endpoint.replaceAll(
              RegExp(r'/+$'), ''); // remove trailing slashes
        }
      }
    } catch (e) {
      print("Error parsing JSON: $e");
    }
  }

  return null;
}

Future<String?> getActiveOracleIpAddress() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonStr = prefs.getString('database_connections');

  if (jsonStr != null) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      final connections = jsonList.cast<Map<String, dynamic>>();

      for (var conn in connections) {
        if (conn['status'] == 'Active') {
          final endpoint = conn['oracleEndpoint']?.toString() ?? '';
          return endpoint.replaceAll(
              RegExp(r'/+$'), ''); // remove trailing slashes
        }
      }
    } catch (e) {
      print("Error parsing JSON: $e");
    }
  }

  return null;
}

class SharedPrefs {
  static Future<SharedPreferences> getInstance() async {
    return SharedPreferences.getInstance();
  }

  static Future<void> departmentname(String departmentname) async {
    SharedPreferences prefs = await getInstance();
    await prefs.setString('departmentname', departmentname);
  }

  static Future<void> departmentid(String departmentid) async {
    SharedPreferences prefs = await getInstance();
    await prefs.setString('departmentid', departmentid);
  }

  static Future<void> commersialname(String commersialname) async {
    SharedPreferences prefs = await getInstance();
    await prefs.setString('commersialname', commersialname);
  }

  static Future<void> commersialno(String commersialno) async {
    SharedPreferences prefs = await getInstance();
    await prefs.setString('commersialno', commersialno);
  }

  static Future<void> commersialrole(String commersialrole) async {
    SharedPreferences prefs = await getInstance();
    await prefs.setString('commersialrole', commersialrole);
  }

  static Future<void> saveloginname(String saveloginname) async {
    SharedPreferences prefs = await getInstance();
    await prefs.setString('saveloginname', saveloginname);
  }

  static Future<void> salesloginno(String salesloginno) async {
    SharedPreferences prefs = await getInstance();
    await prefs.setString('salesloginno', salesloginno);
  }

  static Future<void> salesloginrole(String salesloginrole) async {
    SharedPreferences prefs = await getInstance();
    await prefs.setString('salesloginrole', salesloginrole);
  }

  static Future<void> saleslogiOrgid(String saleslogiOrgid) async {
    SharedPreferences prefs = await getInstance();
    await prefs.setString('saleslogiOrgid', saleslogiOrgid);
  }

  static Future<void> saleslogiOrgwarehousename(
      String saleslogiOrgwarehousename) async {
    SharedPreferences prefs = await getInstance();
    await prefs.setString(
        'saleslogiOrgwarehousename', saleslogiOrgwarehousename);
  }

  static Future<void> dispaatch_requestno(String reqno) async {
    SharedPreferences prefs = await getInstance();
    await prefs.setString('reqno', reqno);
  }

  static Future<void> Return_rerequestno(String returnredispatch) async {
    SharedPreferences prefs = await getInstance();
    await prefs.setString('returnredispatch', returnredispatch);
  }

  static Future<void> pickman_Pickno(String pickno) async {
    SharedPreferences prefs = await getInstance();
    await prefs.setString('pickno', pickno);
  }

  static Future<void> SaveShipmentid(String SaveShipmentid) async {
    SharedPreferences prefs = await getInstance();
    await prefs.setString('SaveShipmentid', SaveShipmentid);
  }

  static Future<void> SaveTransfertype(String SaveTransfertype) async {
    SharedPreferences prefs = await getInstance();
    await prefs.setString('SaveTransfertype', SaveTransfertype);
  }

  static Future<void> clearreqnoAll() async {
    SharedPreferences prefs = await getInstance();
    await prefs.remove('reqno');
  }

  static Future<void> clearpicknoAll() async {
    SharedPreferences prefs = await getInstance();
    await prefs.remove('pickno');
  }

  static Future<void> clearaLLlogins() async {
    SharedPreferences prefs = await getInstance();

    await prefs.remove('commersialno');
    await prefs.remove('commersialrole');
    await prefs.remove('commersialname');
    await prefs.remove('saveloginname');
    await prefs.remove('salesloginno');
    await prefs.remove('salesloginrole');
    await prefs.remove('saleslogiOrgid');
  }

  static Future<void> cleardatadepartmentexchangeforother() async {
    SharedPreferences prefs = await getInstance();

    await prefs.remove('departmentname');
    await prefs.remove('departmentid');
    await prefs.remove('commersialrole');
    await prefs.remove('salesloginrole');
  }

  static Future<void> cleardatadepartmentexchange() async {
    SharedPreferences prefs = await getInstance();

    await prefs.remove('departmentname');
    await prefs.remove('departmentid');
    await prefs.remove('commersialrole');
    await prefs.remove('saveloginname');
    await prefs.remove('salesloginno');
    await prefs.remove('saleslogiOrgid');
  }

  static Future<void> clearAll() async {
    SharedPreferences prefs = await getInstance();
    await prefs.remove('saveloginname');
    await prefs.remove('salesloginno');
    await prefs.remove('salesloginrole');
    await prefs.remove('saleslogiOrgid');
  }

  static Future<void> clearAllComercialData() async {
    SharedPreferences prefs = await getInstance();
    await prefs.remove('saveloginname');
    await prefs.remove('salesloginno');
    await prefs.remove('salesloginrole');
    await prefs.remove('saleslogiOrgid');
    await prefs.remove('commersialno');
    await prefs.remove('commersialrole');
    await prefs.remove('commersialname');
  }

  static Future<void> clearComercialData() async {
    SharedPreferences prefs = await getInstance();
    await prefs.remove('commersialno');
    await prefs.remove('commersialrole');
    await prefs.remove('commersialname');
  }

  static Future<void> cleartockandreqno() async {
    SharedPreferences prefs = await getInstance();
    await prefs.remove('uniqulastreqno');
    await prefs.remove('csrf_token');
  }
}

String? saveloginname = '';
String? saveloginno = '';
String? saveloginrole = '';
String? saleslogiOrgid = '';
String? saleslogiOrgwarehousename = '';

Future<void> _loadSalesmanName() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
  saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
  saveloginno = prefs.getString('salesloginno') ?? 'Unknown Salesman';
  saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? 'Unknown Salesman';
  saleslogiOrgwarehousename =
      prefs.getString('saleslogiOrgwarehousename') ?? 'Unknown Salesman';
}

// Future<String> getDynamicLocalTime() async {
//   try {
//     // Auto-detect timezone from IP
//     final response =
//         await http.get(Uri.parse("http://worldtimeapi.org/api/ip"));

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);

//       // Example response: {"timezone":"Asia/Kolkata","datetime":"2025-09-12T12:55:00.123456+05:30", ...}
//       String datetimeStr = data["datetime"];

//       // Parse to DateTime
//       DateTime localDateTime = DateTime.parse(datetimeStr);

//       // Format to ISO8601
//       return DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(localDateTime);
//     } else {
//       throw Exception("Failed to fetch time: ${response.statusCode}");
//     }
//   } catch (e) {
//     print("Error fetching internet time: $e");
//     // fallback → device time
//     return DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now());
//   }
// }

// Future<void> postLogData(String formName, String action) async {
//   await _loadSalesmanName();
//   final IpAddress = await getActiveIpAddress();

//   // URL of the API
//   final url = '$IpAddress/LogReports/';

//   try {
//     // ✅ Get accurate local time dynamically based on IP location
//     String date = await getDynamicLocalTime();

//     // Prepare the data for the POST request
//     Map<String, dynamic> createDispatchData = {
//       "datetime": date,
//       "EmployeeId": int.tryParse(saveloginno ?? "0") ?? 0,
//       "EmployeeName": saveloginname ?? "Unknown",
//       "EmployeeRole": saveloginrole ?? "Unknown",
//       "Org_id": int.tryParse(saveloginOrgid ?? "0") ?? 0,
//       "WarehouseName": "JEDDAH WHSE",
//       "FormName": formName,
//       "Action": action,
//     };

//     // Send the POST request
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(createDispatchData),
//     );

//     if (response.statusCode == 201) {
//       print('Log report posted successfully.');
//     } else {
//       print('Failed with status code: ${response.statusCode}');
//       print('Response body: ${response.body}');
//     }
//   } catch (e) {
//     print('Error occurred while posting log data: $e');
//   }
// }

Future<String> getDynamicLocalTime() async {
  try {
    // ✅ Use device time (keeps timezone offset intact)
    DateTime now = DateTime.now();
    return now.toIso8601String(); // Example: 2025-09-30T15:22:10.123+05:30
  } catch (e) {
    print("Error getting local time: $e");
    // fallback → still return ISO8601 device time
    return DateTime.now().toIso8601String();
  }
}

Future<void> postLogData(String formName, String action) async {
  try {
    // ✅ Load saved preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno');
    saveloginname = prefs.getString('saveloginname');
    saveloginrole = prefs.getString('salesloginrole');
    saleslogiOrgid = prefs.getString('saleslogiOrgid');
    saleslogiOrgwarehousename = prefs.getString('saleslogiOrgwarehousename');

    // ✅ Get IP
    final ipAddress = await getActiveIpAddress();

    // ✅ API endpoint
    final url = '$ipAddress/LogReports/';

    // ✅ Get local time
    String date = await getDynamicLocalTime();
    // print("saleslogiOrgid $saleslogiOrgid");
    // ✅ Data to send
    Map<String, dynamic> createDispatchData = {
      "datetime": date,
      "EmployeeId": int.tryParse(salesloginno ?? "0") ?? 0,
      "EmployeeName": saveloginname ?? "Unknown",
      "EmployeeRole": saveloginrole ?? "Unknown",
      "Org_id": int.tryParse(saleslogiOrgid ?? "0") ?? 0,
      "WarehouseName": saleslogiOrgwarehousename ?? "Unknown",
      "FormName": formName,
      "Action": action,
    };

    // ✅ Send POST request
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(createDispatchData),
    );

    if (response.statusCode == 201) {
      print('✅ Log report posted successfully.');
    } else {
      print('❌ Failed with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('⚠️ Error occurred while posting log data: $e');
  }
}
