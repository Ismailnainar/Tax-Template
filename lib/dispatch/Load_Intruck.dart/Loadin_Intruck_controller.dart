import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aljeflutterapp/Database/IpAddress.dart';

class LiveStagingController with ChangeNotifier {
  // Original controllers and variables
  final TextEditingController ProductCodeController = TextEditingController();
  TextEditingController scannedqtyController = TextEditingController(text: '0');
  final TextEditingController salesserialnoController = TextEditingController();

  List<Map<String, dynamic>> filteredData = [];

  List<Map<String, dynamic>> QuickBill_filteredData = [];
  List<Map<String, dynamic>> tableData = [];

  List<bool> accessControl = [];
  bool _isLoadingData = true;

  String? saveloginname = '';
  String? saveloginrole = '';

  TextEditingController searchReqNoController = TextEditingController();
  TextEditingController SearchPickidController = TextEditingController();
  List<Map<String, dynamic>> allData = [];
  List<Map<String, dynamic>> quickbillallData = [];

  bool _isLoading = true;

  // Getters for UI access
  bool get isLoadingData => _isLoadingData;
  bool get isLoading => _isLoading;

  // Original methods
  Future<void> fetchAccessControl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginnoStr = prefs.getString('salesloginno');
    final String uniqueId = salesloginnoStr.toString();

    final IpAddress = await getActiveIpAddress();

    String apiUrl = '$IpAddress/User_member_details/';
    bool userFound = false;

    try {
      while (apiUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          var user = (data['results'] as List<dynamic>).firstWhere(
            (u) => u['EMPLOYEE_ID'] == uniqueId,
            orElse: () => null,
          );

          if (user != null) {
            userFound = true;

            var accessControlMap = user['acess_control'];
            if (accessControlMap != null && accessControlMap is Map) {
              List<bool> accessControlList = [];

              for (var value in accessControlMap.values) {
                accessControlList
                    .add(value is bool ? value : value.toString() == 'true');
              }

              accessControl = accessControlList;
              notifyListeners();

              print('Access Control List: $accessControl');
            } else {
              print('Access control data is not available for user $uniqueId.');
            }
            return;
          }

          apiUrl = data['next'] ?? '';
        } else {
          print('Failed to load user details: ${response.statusCode}');
          return;
        }
      }

      if (!userFound) {
        print('User with unique_id $uniqueId not found in any page.');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  // Future<void> _loadSalesmanName() async {

  Future<void> loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
    saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
    notifyListeners();
  }

  Future<void> fetchlivestagingreports() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
    saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
    String? saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename') ?? '';
    final IpAddress = await getActiveIpAddress();
    final String url =
        '$IpAddress/NewCombined_livestage_report/?warehousename=$saleslogiOrgwarehousename&status=on_livestage';

    // Use class-level allData instead of local variable
    allData.clear(); // Clear previous data
    bool hasNextPage = true;
    String? nextPageUrl = url;

    print("Fetching live staging data from: $url");

    _isLoadingData = true;
    notifyListeners();

    try {
      while (hasNextPage && nextPageUrl != null) {
        final response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes);
          final Map<String, dynamic> responseData = json.decode(decodedBody);

          if (responseData.containsKey('results')) {
            final List<Map<String, dynamic>> currentPageData =
                List<Map<String, dynamic>>.from(responseData['results']);

            for (var item in currentPageData) {
              // Convert truckstatus to bool if it's not already
              bool truckStatus;
              if (item['truckstatus'] is bool) {
                truckStatus = item['truckstatus'];
              } else if (item['truckstatus'] is String) {
                truckStatus =
                    item['truckstatus'].toString().toLowerCase() == 'true';
              } else {
                truckStatus = false;
              }

              if (item['PHYSICAL_WAREHOUSE']?.toString() ==
                      saleslogiOrgwarehousename &&
                  item['FLAG']?.toString() != "R" &&
                  truckStatus) {
                allData.add(item);
              }
            }

            nextPageUrl = responseData['next'];
            hasNextPage = nextPageUrl != null;
          } else {
            throw Exception('No results key found in the response');
          }
        } else {
          throw Exception('Failed to load data from server');
        }
      }

      // Map filtered data to UI model

      filteredData = allData.where((item) {
        // Safely parse numeric values with proper type handling
        final scannedQty = item['PICKED_QTY'] is int
            ? item['PICKED_QTY']
            : int.tryParse(item['PICKED_QTY']?.toString() ?? '0') ?? 0;

        final previousTruckQty = item['previous_truck_qty'] is int
            ? item['previous_truck_qty']
            : int.tryParse(item['previous_truck_qty']?.toString() ?? '0') ?? 0;

        final loadScanQty = item['total_filtered_rows'] is int
            ? item['total_filtered_rows']
            : int.tryParse(item['total_filtered_rows']?.toString() ?? '0') ?? 0;

        // Include only if loadScanQty != 0
        return loadScanQty != 0;
      }).map((item) {
        // Convert all values to strings for UI display
        return {
          'cusno': item['CUSTOMER_NUMBER']?.toString() ?? '',
          'cusname': item['CUSTOMER_NAME']?.toString() ?? '',
          'cussite': item['CUSTOMER_SITE_ID']?.toString() ?? '',
          'reqno': item['REQ_ID']?.toString() ?? '',
          'pickid': item['PICK_ID']?.toString() ?? '',
          'scannedqty': (item['PICKED_QTY'] is int
              ? item['PICKED_QTY'].toString()
              : item['PICKED_QTY']?.toString() ?? '0'),
          'status': item['status']?.toString() ?? 'Unknown',
          'total_scan_count': (item['total_filtered_rows'] is int
              ? item['total_filtered_rows'].toString()
              : item['total_filtered_rows']?.toString() ?? '0'),
          'previous_truck_qty': (item['previous_truck_qty'] is int
              ? item['previous_truck_qty'].toString()
              : item['previous_truck_qty']?.toString() ?? '0'),
        };
      }).toList();
      allData = filteredData;
      _isLoadingData = false; // This should now correctly set to false
      notifyListeners();

      // print("filteredData. ${filteredData} items");
      print("Data fetching completed. isLoadingData: $_isLoadingData");
      print("Total items fetched: ${allData.length}");
      print("Filtered items: ${filteredData.length}");
    } catch (e) {
      _isLoadingData = false;
      notifyListeners();
      print('Error fetching data: $e');
    }
  }

  // Future<void> fetchlivestagingreports(BuildContext context) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String saveloginname =
  //       prefs.getString('saveloginname') ?? 'Unknown Salesman';
  //   String saveloginrole =
  //       prefs.getString('salesloginrole') ?? 'Unknown Salesman';
  //   String saleslogiOrgwarehousename =
  //       prefs.getString('saleslogiOrgwarehousename') ?? '';

  //   final IpAddress = await getActiveIpAddress();
  //   final String url =
  //       '$IpAddress/NewCombined_livestage_report/?warehousename=$saleslogiOrgwarehousename&status=on_livestage';

  //   allData.clear();
  //   bool hasNextPage = true;
  //   String? nextPageUrl = url;

  //   print("Fetching live staging data from: $url");

  //   _isLoadingData = true;
  //   notifyListeners();

  //   try {
  //     while (hasNextPage && nextPageUrl != null) {
  //       final response = await http.get(Uri.parse(nextPageUrl));

  //       // ✅ Check if response body is too small (less than 2KB)
  //       if (response.bodyBytes.length < 2048) {
  //         _isLoadingData = false;
  //         notifyListeners();

  //         // Show message box / snackbar
  //         if (context.mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text("Network Error: Response too small"),
  //               backgroundColor: Colors.red,
  //             ),
  //           );
  //         }
  //         return; // stop further execution
  //       }

  //       if (response.statusCode == 200) {
  //         final decodedBody = utf8.decode(response.bodyBytes);
  //         final Map<String, dynamic> responseData = json.decode(decodedBody);

  //         if (responseData.containsKey('results')) {
  //           final List<Map<String, dynamic>> currentPageData =
  //               List<Map<String, dynamic>>.from(responseData['results']);

  //           for (var item in currentPageData) {
  //             bool truckStatus;
  //             if (item['truckstatus'] is bool) {
  //               truckStatus = item['truckstatus'];
  //             } else if (item['truckstatus'] is String) {
  //               truckStatus =
  //                   item['truckstatus'].toString().toLowerCase() == 'true';
  //             } else {
  //               truckStatus = false;
  //             }

  //             if (item['PHYSICAL_WAREHOUSE']?.toString() ==
  //                     saleslogiOrgwarehousename &&
  //                 item['FLAG']?.toString() != "R" &&
  //                 truckStatus) {
  //               allData.add(item);
  //             }
  //           }

  //           nextPageUrl = responseData['next'];
  //           hasNextPage = nextPageUrl != null;
  //         } else {
  //           throw Exception('No results key found in the response');
  //         }
  //       } else {
  //         throw Exception('Failed to load data from server');
  //       }
  //     }

  //     // ✅ Map filtered data
  //     filteredData = allData.where((item) {
  //       final scannedQty = item['PICKED_QTY'] is int
  //           ? item['PICKED_QTY']
  //           : int.tryParse(item['PICKED_QTY']?.toString() ?? '0') ?? 0;

  //       final previousTruckQty = item['previous_truck_qty'] is int
  //           ? item['previous_truck_qty']
  //           : int.tryParse(item['previous_truck_qty']?.toString() ?? '0') ?? 0;

  //       final loadScanQty = item['total_filtered_rows'] is int
  //           ? item['total_filtered_rows']
  //           : int.tryParse(item['total_filtered_rows']?.toString() ?? '0') ?? 0;

  //       return loadScanQty != 0;
  //     }).map((item) {
  //       return {
  //         'cusno': item['CUSTOMER_NUMBER']?.toString() ?? '',
  //         'cusname': item['CUSTOMER_NAME']?.toString() ?? '',
  //         'cussite': item['CUSTOMER_SITE_ID']?.toString() ?? '',
  //         'reqno': item['REQ_ID']?.toString() ?? '',
  //         'pickid': item['PICK_ID']?.toString() ?? '',
  //         'scannedqty': (item['PICKED_QTY'] is int
  //             ? item['PICKED_QTY'].toString()
  //             : item['PICKED_QTY']?.toString() ?? '0'),
  //         'status': item['status']?.toString() ?? 'Unknown',
  //         'total_scan_count': (item['total_filtered_rows'] is int
  //             ? item['total_filtered_rows'].toString()
  //             : item['total_filtered_rows']?.toString() ?? '0'),
  //         'previous_truck_qty': (item['previous_truck_qty'] is int
  //             ? item['previous_truck_qty'].toString()
  //             : item['previous_truck_qty']?.toString() ?? '0'),
  //       };
  //     }).toList();

  //     allData = filteredData;
  //     _isLoadingData = false;
  //     notifyListeners();

  //     print("Data fetching completed. isLoadingData: $_isLoadingData");
  //     print("Total items fetched: ${allData.length}");
  //     print("Filtered items: ${filteredData.length}");
  //   } catch (e) {
  //     _isLoadingData = false;
  //     notifyListeners();
  //     print('Error fetching data: $e');

  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text("Error fetching data: $e"),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  Future<void> fetchQuickBilllivestagingreports() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
    saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
    String? saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename') ?? '';
    final IpAddress = await getActiveIpAddress();
    final String url =
        '$IpAddress/Quick_Bill_Combined_livestage_report/?warehousename=$saleslogiOrgwarehousename';

    quickbillallData.clear(); // Clear previous data

    print("Fetching live staging data from: $url");

    _isLoadingData = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> responseData = json.decode(decodedBody);

        for (var item in responseData) {
          final Map<String, dynamic> record =
              Map<String, dynamic>.from(item as Map);

          // Convert truckstatus safely

          if (record['PHYSICAL_WAREHOUSE']?.toString() ==
              saleslogiOrgwarehousename) {
            quickbillallData.add(record);
          }
        }

        // Filter data for UI
        QuickBill_filteredData = quickbillallData.where((item) {
          final loadScanQty = item['truck_scan_count'] is int
              ? item['truck_scan_count']
              : int.tryParse(item['truck_scan_count']?.toString() ?? '0') ?? 0;

          return loadScanQty != 0;
        }).map((item) {
          return {
            'cusno': item['CUSTOMER_NUMBER']?.toString() ?? '',
            'cusname': item['CUSTOMER_NAME']?.toString() ?? '',
            'cussite': item['CUSTOMER_SITE_ID']?.toString() ?? '',
            'reqno': item['REQ_ID']?.toString() ?? '',
            'pickid': item['PICK_ID']?.toString() ?? '',
            'status': item['status']?.toString() ?? 'Unknown',
            'truck_scan_count': (item['truck_scan_count'] is int
                ? item['truck_scan_count'].toString()
                : item['truck_scan_count']?.toString() ?? '0'),
          };
        }).toList();

        _isLoadingData = false;
        notifyListeners();

        print("QuickBill_filteredData: ${QuickBill_filteredData} items");
        print("QuickBill_filteredData: ${QuickBill_filteredData.length} items");
        print(
            "quickbillallData Total items fetched: ${quickbillallData.length}");
      } else {
        throw Exception('Failed to load data from server');
      }
    } catch (e) {
      _isLoadingData = false;
      notifyListeners();
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchStatusForItems() async {
    List<Map<String, dynamic>> updatedFilteredData = [];

    for (int i = 0; i < filteredData.length; i++) {
      String reqno = filteredData[i]['reqno']?.toString() ?? '';
      String cusno = filteredData[i]['cusno']?.toString() ?? '';
      String cussite = filteredData[i]['cussite']?.toString() ?? '';
      String pickid = filteredData[i]['pickid']?.toString() ?? '';
      String qty = filteredData[i]['scannedqty']?.toString() ?? '0';

      int finalqty =
          int.tryParse(double.tryParse(qty)?.toStringAsFixed(0) ?? '0') ?? 0;

      print(
          "Fetching status for item ${i + 1}: reqno=$reqno, cusno=$cusno, qty=$finalqty, cussite=$cussite");

      final IpAddress = await getActiveIpAddress();

      try {
        final url =
            '$IpAddress/Livestagebuttonstaus/$reqno/$pickid/$cusno/$finalqty/$cussite/';
        print("Request URL: $url");

        final statusResponse = await http.get(Uri.parse(url));

        if (statusResponse.statusCode == 200) {
          final statusData = json.decode(statusResponse.body);

          String updatedStatus = statusData['status']?.toString() ?? 'Unknown';
          String updatedLoadScanQty =
              statusData['total_filtered_rows']?.toString() ?? '0';

          filteredData[i]['status'] = updatedStatus;
          filteredData[i]['loadscanqty'] = updatedLoadScanQty;

          print('Updated filteredData[$i]: ${filteredData[i]}');

          int scannedQty = int.tryParse(finalqty.toString()) ?? 0;
          int loadScanQty = int.tryParse(updatedLoadScanQty) ?? 0;

          if (scannedQty != loadScanQty) {
            updatedFilteredData.add(filteredData[i]);
          }
        } else {
          print('Failed to fetch status for reqno: $reqno, cusno: $cusno');
        }
      } catch (e) {
        print('Error fetching status for reqno: $reqno, cusno: $cusno: $e');
      }
    }

    filteredData = updatedFilteredData;
    notifyListeners();
    print('Filtered table data updated! Total rows: ${filteredData.length}');
  }

  Future<void> fetchPreviousLoadCount() async {
    _isLoading = true;
    notifyListeners();

    for (int i = 0; i < filteredData.length; i++) {
      String reqno = filteredData[i]['reqno'].toString();
      String pickid = filteredData[i]['pickid'].toString();
      String cusno = filteredData[i]['cusno'].toString();

      try {
        final ipAddress = await getActiveIpAddress();
        final initialUrl =
            '$ipAddress/Truck_scan/?REQ_NO=$reqno&PICK_ID=$pickid';
        print("Fetching from: $initialUrl");

        int countFlagA = 0;
        String? nextPageUrl = initialUrl;

        while (nextPageUrl != null) {
          final response = await http.get(Uri.parse(nextPageUrl));

          if (response.statusCode == 200) {
            final responseData =
                json.decode(response.body) as Map<String, dynamic>;
            final results = responseData['results'] as List<dynamic>;

            countFlagA += results.where((item) => item['FLAG'] == 'A').length;

            nextPageUrl = responseData['next'];
          } else {
            throw Exception('Failed to fetch page: $nextPageUrl');
          }
        }

        filteredData[i]['previous_truck_qty'] = countFlagA;
        notifyListeners();
        print('Updated previous_truck_qty for reqno $reqno: $countFlagA');
      } catch (e) {
        print('Error fetching data for reqno $reqno, cusno $cusno: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  searchreqno() {
    String searchText = searchReqNoController.text.trim().toLowerCase();
    String searchPickIdText = SearchPickidController.text.trim().toLowerCase();

    print("Before filtering: $filteredData");

    // If both search fields are empty, reset to full list
    if (searchText.isEmpty && searchPickIdText.isEmpty) {
      filteredData = List<Map<String, dynamic>>.from(allData); // Reset

      return;
    }

    filteredData = allData.where((item) {
      final reqno = (item['reqno'] ?? '').toString().toLowerCase();
      final pickid = (item['pickid'] ?? '').toString().toLowerCase();

      // Match based on entered search text
      final matchReq = searchText.isEmpty || reqno.contains(searchText);
      final matchPick =
          searchPickIdText.isEmpty || pickid.contains(searchPickIdText);

      return matchReq && matchPick;
    }).toList();

    notifyListeners();
    print("After filtering: $filteredData");
  }

  Future<bool> checkDataExists(
      String reqno, String pickid, String pickedQty) async {
    final IpAddress = await getActiveIpAddress();

    final url =
        Uri.parse('$IpAddress/Truck_scan/?REQ_NO=$reqno&PICK_ID=$pickid');

    print("Fetching URL: $pickedQty: $url");

    try {
      double parsedPickedQty = 0.0;
      try {
        parsedPickedQty = double.parse(pickedQty);
      } catch (e) {
        print('Error parsing pickedQty: $e');
        return false;
      }

      int intPickedQty = parsedPickedQty.floor();

      print("parsedPickedQty (as int): $intPickedQty: $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        List results = (data['results'] as List).where((item) {
          return item['FLAG'] != 'R';
        }).toList();

        int filteredResultsCount = results.length;
        print(
            "$filteredResultsCount < $intPickedQty || $filteredResultsCount == 0");

        return filteredResultsCount == 0 || filteredResultsCount < intPickedQty;
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking data: $e');
      return false;
    }
  }

  void WarningMessage(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.yellow),
              SizedBox(width: 10),
              Text(
                'Kindly Enter All fields?...',
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  void showValidationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Kindly fill all the fields.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Dispose method to clean up resources
  @override
  void dispose() {
    ProductCodeController.dispose();
    scannedqtyController.dispose();
    salesserialnoController.dispose();
    searchReqNoController.dispose();
    SearchPickidController.dispose();
    super.dispose();
  }
}
