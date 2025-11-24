import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:http/http.dart' as http;
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Live_StagingPage extends StatefulWidget {
  final Function togglePage;

  Live_StagingPage(this.togglePage);

  @override
  State<Live_StagingPage> createState() => _Live_StagingPageState();
}

class _Live_StagingPageState extends State<Live_StagingPage> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  final TextEditingController ProductCodeController = TextEditingController();

  TextEditingController scannedqtyController = TextEditingController(text: '0');
  final TextEditingController salesserialnoController = TextEditingController();

  List<Map<String, dynamic>> filteredData = [];
  // List<Map<String, dynamic>> tableData = [];
  @override
  void initState() {
    super.initState();
    filteredData = List.from(tableData);
    fetchAccessControl();
    _loadSalesmanName();
    fetchlivestagingreports();
    postLogData("Live Stage", "Opened");

    // checkStatus();

    scannedqtyController.text = filteredData.length.toString();
    print("Scanned Qty ${scannedqtyController.text}");
  }

  List<bool> accessControl = [];
  bool _isLoadingData = true;

  Future<void> fetchAccessControl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginnoStr = prefs.getString('salesloginno');
    final String uniqueId = salesloginnoStr.toString();

    final IpAddress = await getActiveIpAddress();

    String apiUrl = '$IpAddress/User_member_details/';
    bool userFound = false;

    try {
      // Loop through each page until the user with uniqueId is found or no more pages are left
      while (apiUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          // Decode the JSON response
          final data = json.decode(response.body);

          // Find the user with the matching unique_id on the current page
          var user = (data['results'] as List<dynamic>).firstWhere(
            (u) => u['EMPLOYEE_ID'] == uniqueId,
            orElse: () => null,
          );

          if (user != null) {
            userFound = true;

            // Check if access_control is not null and is a Map
            var accessControlMap = user['acess_control'];
            if (accessControlMap != null && accessControlMap is Map) {
              // Convert access_control Map to a list of bools
              List<bool> accessControlList = [];

              // Iterate through the values of the access control map
              for (var value in accessControlMap.values) {
                // Ensure that we only process boolean values
                accessControlList
                    .add(value is bool ? value : value.toString() == 'true');
              }

              // Set the access control list to a state variable if needed
              setState(() {
                accessControl =
                    accessControlList; // Assuming accessControl is defined as List<bool>
              });

              print('Access Control List: $accessControl');
            } else {
              print('Access control data is not available for user $uniqueId.');
            }
            return; // Exit once the user is found and processed
          }

          // Update apiUrl to the next page, or set to empty if no more pages
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

  @override
  void dispose() {
    ProductCodeController.dispose();
    salesserialnoController.dispose();

    postLogData("Live Stage", "Closed");
    super.dispose();
  }

  String? saveloginname = '';

  String? saveloginrole = '';

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
      saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
    });
  }

  Future<void> fetchlivestagingreports() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename') ?? '';
    final IpAddress = await getActiveIpAddress();
    final String url =
        '$IpAddress/Combined_livestage_report/?warehousename=$saleslogiOrgwarehousename&status=on_livestage_stage';
    List<Map<String, dynamic>> allData = [];
    bool hasNextPage = true;
    String? nextPageUrl = url;

    print("Fetching live staging data from: $url");

    setState(() {
      _isLoadingData = true;
    });

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
              if (item['PHYSICAL_WAREHOUSE']?.toString() ==
                      saleslogiOrgwarehousename &&
                  item['FLAG']?.toString() != "R" &&
                  item['truckstatus'] == true) {
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

      // print("Filtered truckstatus=true data: $allData");

      // Map filtered data to UI model
      setState(() {
        // filteredData = allData.map((item) {
        //   return {
        //     'cusno': item['CUSTOMER_NUMBER'],
        //     'cusname': item['CUSTOMER_NAME'],
        //     'cussite': item['CUSTOMER_SITE_ID'],
        //     'reqno': item['REQ_ID'],
        //     'pickid': item['PICK_ID'],
        //     'scannedqty': item['PICKED_QTY'],
        //     'status': item['status']?.toString() ?? 'Unknown',
        //     'loadscanqty': item['total_filtered_rows']?.toString() ?? '0',
        //     'previous_truck_qty': item['previous_truck_qty']?.toString() ?? '0',
        //   };
        // }).toList();

        filteredData = allData.where((item) {
          // Safely parse numeric values
          final scannedQty =
              int.tryParse(item['PICKED_QTY']?.toString() ?? '0') ?? 0;
          final previousTruckQty =
              int.tryParse(item['previous_truck_qty']?.toString() ?? '0') ?? 0;
          final loadScanQty =
              int.tryParse(item['total_filtered_rows']?.toString() ?? '0') ?? 0;

          // Include only if scannedQty == previousTruckQty + loadScanQty
          return scannedQty != (previousTruckQty + loadScanQty);
        }).map((item) {
          return {
            'cusno': item['CUSTOMER_NUMBER'],
            'cusname': item['CUSTOMER_NAME'],
            'cussite': item['CUSTOMER_SITE_ID'],
            'reqno': item['REQ_ID'],
            'pickid': item['PICK_ID'],
            'scannedqty': item['PICKED_QTY'],
            'status': item['status']?.toString() ?? 'Unknown',
            'loadscanqty': item['total_filtered_rows']?.toString() ?? '0',
            'previous_truck_qty': item['previous_truck_qty']?.toString() ?? '0',
          };
        }).toList();

        _isLoadingData = false;
      });

      // print("Final filteredData for display: $filteredData");
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      print('Error fetching data: $e');
    }
  }

  // Future<void> fetchlivestagingreports() async {
  //   final IpAddress = await getActiveIpAddress();

  //   final String url = '$IpAddress/Filtered_livestagereports/';
  //   List<Map<String, dynamic>> allData = [];
  //   bool hasNextPage = true;
  //   String? nextPageUrl = url;
  //   print("print the live staging url :$url  ");

  //   setState(() {
  //     _isLoadingData = true;
  //   });

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? saleslogiOrgwarehousename =
  //       prefs.getString('saleslogiOrgwarehousename') ?? '';
  //   try {
  //     while (hasNextPage && nextPageUrl != null) {
  //       final response = await http.get(Uri.parse(nextPageUrl));

  //       if (response.statusCode == 200) {
  //         final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
  //         final Map<String, dynamic> responseData = json.decode(decodedBody);

  //         print("responseData the live staging responseData :$responseData  ");
  //         if (responseData.containsKey('results')) {
  //           // Append current page data
  //           final List<Map<String, dynamic>> currentPageData =
  //               List<Map<String, dynamic>>.from(responseData['results']);

  //           // Filter rows using checkDataExists before adding
  //           // for (var item in currentPageData) {
  //           //   String reqno = item['REQ_ID'] ?? '';
  //           //   String pickid = item['PICK_ID'] ?? '';
  //           //   String pickedQty = item['PICKED_QTY'];

  //           //   // Add row only if checkDataExists returns true
  //           //   if (await checkDataExists(reqno, pickid, pickedQty)) {
  //           //     allData.add(item);
  //           //   }
  //           // }

  //           for (var item in currentPageData) {
  //             if (item['PHYSICAL_WAREHOUSE']?.toString() ==
  //                 saleslogiOrgwarehousename) {
  //               if (item['FLAG']?.toString() != "R") {
  //                 String reqNo = item['REQ_ID'] ?? '';
  //                 String pickId = item['PICK_ID'] ?? '';
  //                 String pickedQty = item['PICKED_QTY'] ?? '';

  //                 // Add data to the list if it meets the ORG_ID condition
  //                 if (await checkDataExists(reqNo, pickId, pickedQty)) {
  //                   allData.add(item);
  //                 }
  //               }
  //             }
  //           }
  //           // Check for the next page
  //           nextPageUrl = responseData['next'];
  //           hasNextPage = nextPageUrl != null;
  //         } else {
  //           throw Exception('No results key found in the response');
  //         }
  //       } else {
  //         throw Exception('Failed to load data');
  //       }
  //     }
  //     print("Filtered data after PHYSICAL_WAREHOUSE check: $allData");

  //     // Process the filtered data
  //     setState(() {
  //       filteredData = allData.map((item) {
  //         return {
  //           'cusno': item['CUSTOMER_NUMBER'],
  //           'cusname': item['CUSTOMER_NAME'],
  //           'cussite': item['CUSTOMER_SITE_ID'],
  //           'reqno': item['REQ_ID'],
  //           'pickid': item['PICK_ID'],
  //           'scannedqty': item['PICKED_QTY'],
  //           'status': 'Loading...', // Default status while fetching
  //         };
  //       }).toList();

  //       _isLoadingData = false;
  //     });

  //     // Fetch the status for each item
  //     await fetchStatusForItems();
  //     await fetchStatusForItems();
  //     await fetchPreviousLoadCount();
  //     await fetchPreviousLoadCount();
  //     print("filteredDataaaaaaaaaaaaaa the live staging url :$filteredData  ");
  //   } catch (e) {
  //     setState(() {
  //       _isLoadingData = false;
  //     });
  //     print('Error fetching data: $e');
  //   }
  // }

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

          // Update the current item
          filteredData[i]['status'] = updatedStatus;
          filteredData[i]['loadscanqty'] = updatedLoadScanQty;

          print('Updated filteredData[$i]: ${filteredData[i]}');

          // Compare scannedqty and loadscanqty
          int scannedQty = int.tryParse(finalqty.toString()) ?? 0;
          int loadScanQty = int.tryParse(updatedLoadScanQty) ?? 0;

          // Only keep the row if they are not equal
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

    // Update the UI with only the rows where scannedqty != loadscanqty
    setState(() {
      filteredData = updatedFilteredData;
      print('Filtered table data updated! Total rows: ${filteredData.length}');
    });
  }

  bool _isLoading = true;

  Future<void> fetchPreviousLoadCount() async {
    setState(() {
      _isLoading = true;
    });

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

            // Count records where FLAG == 'A'
            countFlagA += results.where((item) => item['FLAG'] == 'A').length;

            // Move to next page if available
            nextPageUrl = responseData['next'];
          } else {
            throw Exception('Failed to fetch page: $nextPageUrl');
          }
        }

        setState(() {
          filteredData[i]['previous_truck_qty'] = countFlagA;
          print('Updated previous_truck_qty for reqno $reqno: $countFlagA');
        });
      } catch (e) {
        print('Error fetching data for reqno $reqno, cusno $cusno: $e');
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Future<void> fetchPreviousLoadCount() async {
  //   for (int i = 0; i < filteredData.length; i++) {
  //     // Extract required fields and ensure they are strings
  //     String reqno = filteredData[i]['reqno'].toString();
  //     String cusno = filteredData[i]['cusno'].toString();
  //     String cussite = filteredData[i]['cussite'].toString();
  //     String pickid = filteredData[i]['pickid'].toString();

  //     // Parse qty as a double and cast it to an int
  //     // int count = (double.parse(qty)).round(); // Rounding ensures no type error

  //     // Log values for debugging

  //     try {
  //       final IpAddress = await getActiveIpAddress();

  //       // API URL for the truck scan
  //       final truckScanUrl =
  //           '$IpAddress/Truck_scan/?REQ_NO=$reqno&PICK_ID=$pickid';
  //       print("truckScanUrlllll $truckScanUrl");
  //       int totalCount = 0;
  //       bool hasNextPage = true;
  //       String? nextPageUrl = truckScanUrl;

  //       setState(() {
  //         _isLoading = true;
  //       });

  //       // Paginated API request logic
  //       while (hasNextPage && nextPageUrl != null) {
  //         final response = await http.get(Uri.parse(nextPageUrl));

  //         if (response.statusCode == 200) {
  //           final Map<String, dynamic> responseData =
  //               json.decode(response.body);

  //           // Increment the total count
  //           if (responseData.containsKey('count')) {
  //             totalCount += (responseData['count'] as num).toInt();
  //           }

  //           // Determine if there's a next page
  //           nextPageUrl = responseData['next'];
  //           hasNextPage = nextPageUrl != null;
  //         } else {
  //           throw Exception('Failed to fetch data from $nextPageUrl');
  //         }
  //       }

  //       // Update `previous_truck_qty` in the filtered data
  //       setState(() {
  //         filteredData[i]['previous_truck_qty'] = totalCount ?? '0';
  //         print('Updated previous_truck_qty for reqno $reqno: $totalCount');
  //       });
  //     } catch (e) {
  //       // Handle exceptions and log errors
  //       print('Error fetching data for reqno: $reqno, cusno: $cusno: $e');
  //     } finally {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  TextEditingController searchReqNoController =
      TextEditingController(); // Controller for search field
  TextEditingController SearchPickidController =
      TextEditingController(); // Controller for search field

  List<Map<String, dynamic>> allData = [];
  void searchreqno() {
    String searchText = searchReqNoController.text.trim().toLowerCase();

    setState(() {
      filteredData = filteredData.where((item) {
        String reqno = item['reqno']?.toString().toLowerCase() ?? '';
        return searchText.isEmpty || reqno.contains(searchText);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    String scanneditems = scannedqtyController.text;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      // appBar: AppBar(
      //   title: const Text("Dispatch Creation"),
      //   centerTitle: true,
      // ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.only(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Responsive.isDesktop(context))
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors
                            .white, // You can adjust the background color here
                        border: Border.all(
                          color: Colors.grey[400]!, // Border color
                          width: 1.0, // Border width
                        ),

                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Icon(
                                  Icons.directions_car_filled,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Live Staging Report',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Image.asset(
                                  "assets/images/user.png",
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(0),
                                      child: Text(
                                        saveloginname ?? 'Loading...',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(0),
                                      child: Text(
                                        saveloginrole ?? 'Loading....',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                // Icon(
                                //   Icons.arrow_drop_down_outlined,
                                //   size: 27,
                                // ),
                                SizedBox(
                                  width: 30,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.85,
                    decoration: BoxDecoration(
                      color: Colors
                          .white, // You can adjust the background color here
                      border: Border.all(
                        color: Colors.grey[400]!, // Border color
                        width: 1.0, // Border width
                      ),

                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Staging Details :',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[700]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Row(
                          children: [
                            SizedBox(
                              width: Responsive.isDesktop(context) ? 180 : 130,
                              height: 33,
                              child: TextField(
                                controller: searchReqNoController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter Request No',
                                  border: OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                ),
                                onChanged: (value) => searchreqno(),
                                style: textBoxstyle,
                              ),
                            ),
                            SizedBox(
                              width: Responsive.isDesktop(context) ? 180 : 130,
                              height: 33,
                              child: TextField(
                                controller: SearchPickidController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter Pick Id',
                                  border: OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                ),
                                onChanged: (value) => searchreqno(),
                                style: textBoxstyle,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 10, left: 10, top: 10),
                            child: _buildTableView(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showValidationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: const Text('Feild Check'),
          content: const Text('Kindly fill all the fields.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> tableData = [
    // {
    //   'id': 1,
    //   "invoiceno": "2411026553",
    //   'itemcode': 'DEG77888H',
    //   'itemdetails': 'Refrigerator',
    //   'productcode': '1002',
    //   'serialno': '2589647',
    // },
    // {
    //   'id': 2,
    //   "invoiceno": "2411026553",
    //   'itemcode': 'DEG77888H',
    //   'itemdetails': 'Refrigerator',
    //   'productcode': '1002',
    //   'serialno': '2589648',
    // },
    // {
    //   'id': 3,
    //   "invoiceno": "2411026553",
    //   'itemcode': 'DEG77888H',
    //   'itemdetails': 'Refrigerator',
    //   'productcode': '1002',
    //   'serialno': '2589649',
    // },
    // {
    //   'id': 4,
    //   "invoiceno": "2411026553",
    //   'itemcode': 'DEG77888H',
    //   'itemdetails': 'Refrigerator',
    //   'productcode': '1002',
    //   'serialno': '2589650',
    // },
  ];

  void WarningMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.warning, color: Colors.yellow),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                'Kindly Enter All feilds?...',
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

  Future<bool> checkDataExists(
      String reqno, String pickid, String pickedQty) async {
    final IpAddress = await getActiveIpAddress();

    final url =
        Uri.parse('$IpAddress/Truck_scan/?REQ_NO=$reqno&PICK_ID=$pickid');

    print("Fetching URL: $pickedQty: $url");

    try {
      // Safely convert pickedQty from String to double (for decimal values)
      double parsedPickedQty = 0.0;
      try {
        parsedPickedQty =
            double.parse(pickedQty); // Attempt to convert to double
      } catch (e) {
        print('Error parsing pickedQty: $e');
        return false; // If conversion fails, return false
      }

      // Convert the double to an int (by rounding or flooring the value)
      int intPickedQty =
          parsedPickedQty.floor(); // Use .floor() to avoid rounding errors

      print("parsedPickedQty (as int): $intPickedQty: $url");

      final response = await http.get(url);
      // if (response.statusCode == 200) {
      //   var data = json.decode(response.body);

      //   // Check if the "results" field exists and compare the results count with intPickedQty
      //   int resultsCount = (data['results'] as List).length;
      //   print("$resultsCount < $intPickedQty || $resultsCount == 0");
      //   // Show the row if there are no results (data doesn't exist) or the count is less than intPickedQty
      //   return resultsCount < intPickedQty || resultsCount == 0;
      // }
      if (response.statusCode == 200) {
        // Parse the JSON response
        var data = json.decode(response.body);

        // Ensure "results" is a List and filter based on FLAG != 'R'
        List results = (data['results'] as List).where((item) {
          return item['FLAG'] != 'R';
        }).toList();

        // Count the filtered results
        int filteredResultsCount = results.length;
        print(
            "$filteredResultsCount < $intPickedQty || $filteredResultsCount == 0");

        // Return true if the count is less than intPickedQty or no results exist
        return filteredResultsCount == 0 || filteredResultsCount < intPickedQty;
      } else {
        return false; // If not successful, assume no data
      }
    } catch (e) {
      print('Error checking data: $e');
      return false; // On error, assume no data
    }
  }

  Widget _buildTableView() {
    double screenHeight = MediaQuery.of(context).size.height;

    return Responsive.isDesktop(context) ? _buildTable() : _buildCardView();
  }

  // Widget _buildCardView() {
  //   final isDesktop = Responsive.isDesktop(context);

  //   return SingleChildScrollView(
  //     child: Column(
  //       children: filteredData.asMap().entries.map((entry) {
  //         int index = entry.key;
  //         var data = entry.value;

  //         String sNo = (index + 1).toString();
  //         var cusname = data['cusname'];
  //         var reqno = data['reqno'];
  //         var pickid = data['pickid'];
  //         var cussite = data['cussite'];
  //         var loadscanqty = data['loadscanqty'];
  //         var scannedqty = data['scannedqty'];
  //         var sno = data['id'].toString();
  //         var onlyreqno = "$reqno";
  //         var onlypickid = "$pickid";
  //         var cusno = data['cusno'];
  //         var status = data['status'];
  //         var previous_truck_qty = data['previous_truck_qty'];

  //         int finalqty =
  //             int.tryParse(loadscanqty.toString().split('.').first) ?? 0;

  //         return Card(
  //           margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  //           elevation: 4,
  //           shape:
  //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //           child: Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Icon(Icons.receipt_long, color: Colors.blue),
  //                     SizedBox(width: 8),
  //                     Text("Request No: $reqno",
  //                         style: TextStyle(fontWeight: FontWeight.bold)),
  //                   ],
  //                 ),
  //                 SizedBox(height: 8),
  //                 Row(
  //                   children: [
  //                     Icon(Icons.confirmation_number, color: Colors.deepPurple),
  //                     SizedBox(width: 8),
  //                     Text("Pick ID: $pickid"),
  //                   ],
  //                 ),
  //                 SizedBox(height: 8),
  //                 Row(
  //                   children: [
  //                     Icon(Icons.person, color: Colors.green),
  //                     SizedBox(width: 8),
  //                     Expanded(child: Text("Customer Name: $cusname")),
  //                   ],
  //                 ),
  //                 SizedBox(height: 8),
  //                 Row(
  //                   children: [
  //                     Icon(Icons.location_on, color: Colors.redAccent),
  //                     SizedBox(width: 8),
  //                     Expanded(child: Text("Customer Site: $cussite")),
  //                   ],
  //                 ),
  //                 SizedBox(height: 8),
  //                 Row(
  //                   children: [
  //                     Icon(Icons.inventory, color: Colors.orange),
  //                     SizedBox(width: 8),
  //                     RichText(
  //                       text: TextSpan(
  //                         style: TextStyle(
  //                           color: Colors.black,
  //                           fontFamily: 'Roboto', // Default font
  //                           fontSize: 16, // Optional
  //                         ),
  //                         children: [
  //                           TextSpan(text: "Picked Qty: "),
  //                           TextSpan(
  //                             text: "$scannedqty",
  //                             style: TextStyle(
  //                               color: Colors.green,
  //                               fontFamily: 'Roboto', // Same or different font
  //                             ),
  //                           ),
  //                           TextSpan(text: " - "),
  //                           TextSpan(
  //                             text: "$previous_truck_qty",
  //                             style: TextStyle(
  //                               color: Colors.red,
  //                               fontFamily: 'Roboto', // Same or different font
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),

  Widget _buildCardView() {
    final isDesktop = Responsive.isDesktop(context);

    // Filter out rows where scannedqty == previous_truck_qty
    // final visibleData = filteredData.where((data) {
    //   final scanned =
    //       int.tryParse(data['scannedqty'].toString().split('.').first) ?? 0;
    //   final previous = int.tryParse(
    //           data['previous_truck_qty'].toString().split('.').first) ??
    //       0;

    //   return scanned != previous;
    // }).toList();

    if (_isLoadingData) {
      // Loading state
      return Container(
        height: 200,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Filter out rows where scannedqty == previous_truck_qty
    final visibleData = filteredData.where((data) {
      final scanned =
          int.tryParse(data['scannedqty'].toString().split('.').first) ?? 0;
      final previous = int.tryParse(
              data['previous_truck_qty'].toString().split('.').first) ??
          0;
      return scanned != previous;
    }).toList();

    if (visibleData.isEmpty) {
      // No data after filtering
      return Container(
        height: 100,
        child: const Center(
          child: Text(
            "No data available in live stage",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: visibleData.asMap().entries.map((entry) {
          int index = entry.key;
          var data = entry.value;

          String sNo = (index + 1).toString();
          var cusname = data['cusname'];
          var reqno = data['reqno'];
          var pickid = data['pickid'];
          var cussite = data['cussite'];
          var loadscanqty = data['loadscanqty'];
          var scannedqty = data['scannedqty'];
          var sno = data['id'].toString();
          var onlyreqno = "$reqno";
          var onlypickid = "$pickid";
          var cusno = data['cusno'];
          var status = data['status'];
          var previous_truck_qty = data['previous_truck_qty'];
          var totalscannedqty = (data['scannedqty'] ?? 0) is num
              ? (data['scannedqty'] ?? 0)
              : num.tryParse(data['scannedqty'].toString()) ?? 0;
          var totalprevious_truck_qty = (data['previous_truck_qty'] ?? 0) is num
              ? (data['previous_truck_qty'] ?? 0)
              : num.tryParse(data['previous_truck_qty'].toString()) ?? 0;

          var balanceqty = totalscannedqty - totalprevious_truck_qty;

          print("balanceqty card $balanceqty");
          int finalqty =
              int.tryParse(loadscanqty.toString().split('.').first) ?? 0;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Request No: $reqno",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.confirmation_number, color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text("Pick ID: $pickid"),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(child: Text("Customer Name: $cusname")),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Expanded(child: Text("Customer Site: $cussite")),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.inventory, color: Colors.orange),
                      SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Roboto',
                            fontSize: 16,
                          ),
                          children: [
                            TextSpan(text: "Picked Qty: "),
                            TextSpan(
                              text: "$scannedqty",
                              style: TextStyle(color: Colors.green),
                            ),
                            TextSpan(text: " - "),
                            TextSpan(
                              text: "$previous_truck_qty",
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_getButtonLabel(status),
                          style: TextStyle(
                              fontSize: 13, color: _getButtonColor(status))),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          color: _getButtonColor(status),
                          onPressed: () async {
                            await widget.togglePage(
                              data['reqno'].toString(),
                              data['pickid'].toString(),
                              data['cusno'].toString(),
                              data['cusname'].toString(),
                              data['cussite'].toString(),
                              "$balanceqty",
                            );
                          },
                          icon: Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: _getButtonColor(status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = Responsive.isDesktop(context);
        final screenWidth = MediaQuery.of(context).size.width;

        // Responsive sizing calculations
        final tableWidth = isDesktop ? screenWidth * 0.8 : screenWidth;
        final columnWidths = {
          0: isDesktop ? screenWidth * 0.04 : 70.0, // SNo
          1: isDesktop ? screenWidth * 0.07 : 100.0, // Req No
          2: isDesktop ? screenWidth * 0.07 : 100.0, // Pick Id
          3: isDesktop ? screenWidth * 0.07 : 100.0, // Customer No
          4: isDesktop ? screenWidth * 0.25 : 200.0, // Customer Name
          5: isDesktop ? screenWidth * 0.07 : 100.0, // Customer Site
          6: isDesktop ? screenWidth * 0.12 : 100.0, // Picked Qty
          7: isDesktop ? screenWidth * 0.1 : 100.0, // Action
        };

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[400]!, width: 1.0),
          ),
          width: tableWidth,
          child: Stack(
            children: [
              ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: MaterialStateProperty.all(Colors.grey[600]),
                  thumbVisibility: MaterialStateProperty.all(true),
                  thickness: MaterialStateProperty.all(8),
                  radius: const Radius.circular(10),
                ),
                child: Scrollbar(
                  controller: _horizontalScrollController,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: tableWidth,
                      ),
                      child: Column(
                        children: [
                          // Table Header
                          _buildTableHeader(columnWidths, isDesktop),
                          // Table Body
                          if (_isLoadingData)
                            Container(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (filteredData.isNotEmpty)
                            _buildTableBody(columnWidths, isDesktop)
                          else
                            Container(
                              height: 100,
                              child: Center(
                                child: Text("No data available in live stage"),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Scroll Arrows
              if (isDesktop) _buildScrollArrows(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableHeader(Map<int, double> columnWidths, bool isDesktop) {
    final headers = [
      {"icon": Icons.format_list_numbered, "text": "Sno"},
      {"icon": Icons.receipt_long, "text": "Req No"},
      {"icon": Icons.qr_code, "text": "Pick Id"},
      {"icon": Icons.account_circle, "text": "Cus No"},
      {"icon": Icons.person, "text": "Cus Name"},
      {"icon": Icons.person, "text": "Cus Site"},
      {"icon": Icons.info_outline, "text": "Picked Qty"},
      {"icon": Icons.edit, "text": "Action"},
    ];

    return Container(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: headers.asMap().entries.map((entry) {
          final index = entry.key;
          final header = entry.value;
          return Container(
            height: isDesktop ? 25 : 30,
            width: columnWidths[index],
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(header["icon"] as IconData,
                        size: 15, color: Colors.blue),
                    const SizedBox(width: 5),
                    Text(
                      header["text"] as String,
                      style: TextStyle(
                        fontSize: isDesktop ? 12 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableBody(Map<int, double> columnWidths, bool isDesktop) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: filteredData
              .map((data) => _buildTableRow(data, columnWidths, isDesktop))
              .toList(),
        ),
      ),
    );
  }

  // Widget _buildTableRow(Map<String, dynamic> data,
  //     Map<int, double> columnWidths, bool isDesktop) {
  //   final index = filteredData.indexOf(data);
  //   final isEvenRow = index % 2 == 0;
  //   final rowColor = isEvenRow
  //       ? Color.fromARGB(224, 255, 255, 255)
  //       : Color.fromARGB(223, 239, 239, 239);

  //   // Safely parse loadscanqty
  //   double parsedLoadScanQty = 0.0;
  //   try {
  //     parsedLoadScanQty =
  //         double.tryParse(data['loadscanqty'].toString()) ?? 0.0;
  //   } catch (e) {
  //     parsedLoadScanQty = 0.0;
  //   }
  //   int finalqty = parsedLoadScanQty.toInt();

  //   // Safely parse scannedqty
  //   int scannedqty = 0;
  //   try {
  //     scannedqty = double.tryParse(data['scannedqty'].toString())?.toInt() ?? 0;
  //   } catch (e) {
  //     scannedqty = 0;
  //   }

  //   final previous_truck_qty = data['previous_truck_qty'];
  //   final status = data['status'];

  //   return GestureDetector(
  //     onTap: () {},
  //     child: Container(
  //       color: rowColor,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           // SNo
  //           _buildTableCell(
  //             width: columnWidths[0]!,
  //             child: Text(
  //               (index + 1).toString(),
  //               style: TextStyle(fontSize: 12),
  //             ),
  //           ),
  //           // Req No
  //           _buildTableCell(
  //             width: columnWidths[1]!,
  //             child: Text(
  //               data['reqno'].toString(),
  //               style: TextStyle(fontSize: 12),
  //             ),
  //           ),
  //           // Pick Id
  //           _buildTableCell(
  //             width: columnWidths[2]!,
  //             child: Text(
  //               data['pickid'].toString(),
  //               style: TextStyle(fontSize: 12),
  //             ),
  //           ),
  //           // Customer No
  //           _buildTableCell(
  //             width: columnWidths[3]!,
  //             child: Text(
  //               data['cusno'].toString(),
  //               style: TextStyle(fontSize: 12),
  //             ),
  //           ),
  //           // Customer Name
  //           _buildTableCell(
  //             width: columnWidths[4]!,
  //             child: Tooltip(
  //               message: data['cusname'].toString(),
  //               child: Text(
  //                 data['cusname'].toString(),
  //                 overflow: TextOverflow.ellipsis,
  //                 style: TextStyle(fontSize: 12),
  //               ),
  //             ),
  //           ),
  //           // Customer Site
  //           _buildTableCell(
  //             width: columnWidths[5]!,
  //             child: Text(
  //               data['cussite'].toString(),
  //               style: TextStyle(fontSize: 12),
  //             ),
  //           ),
  //           // Picked Qty (Scanned vs Load Qty)
  //           _buildTableCell(
  //             width: columnWidths[6]!,
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               children: [
  //                 Tooltip(
  //                   message: 'Scanned Qty',
  //                   child: Text(
  //                     "$scannedqty",
  //                     style: TextStyle(
  //                       color: Color.fromARGB(255, 65, 147, 72),
  //                       fontSize: isDesktop ? 14 : 12,
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 10),
  //                 Text("-", style: TextStyle(fontSize: isDesktop ? 14 : 12)),
  //                 SizedBox(width: 10),
  //                 Tooltip(
  //                   message: 'Already Trucked Qty',
  //                   child: Text(
  //                     "$previous_truck_qty",
  //                     style: TextStyle(
  //                       color: Color.fromARGB(255, 65, 147, 72),
  //                       fontSize: isDesktop ? 14 : 12,
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 10),
  //                 Text("-", style: TextStyle(fontSize: isDesktop ? 14 : 12)),
  //                 SizedBox(width: 10),
  //                 Tooltip(
  //                   message: 'Load Scan Qty',
  //                   child: Text(
  //                     "$finalqty",
  //                     style: TextStyle(
  //                       color: Color.fromARGB(255, 154, 52, 52),
  //                       fontSize: isDesktop ? 14 : 12,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),

  Widget _buildTableRow(Map<String, dynamic> data,
      Map<int, double> columnWidths, bool isDesktop) {
    final index = filteredData.indexOf(data);
    final isEvenRow = index % 2 == 0;
    final rowColor = isEvenRow
        ? Color.fromARGB(224, 255, 255, 255)
        : Color.fromARGB(223, 239, 239, 239);

    // Safely parse loadscanqty
    double parsedLoadScanQty = 0.0;
    try {
      parsedLoadScanQty =
          double.tryParse(data['loadscanqty'].toString()) ?? 0.0;
    } catch (e) {
      parsedLoadScanQty = 0.0;
    }
    int finalqty = parsedLoadScanQty.toInt();

    // Safely parse scannedqty
    int scannedqty = 0;
    try {
      scannedqty = double.tryParse(data['scannedqty'].toString())?.toInt() ?? 0;
    } catch (e) {
      scannedqty = 0;
    }

    // Safely parse previous_truck_qty
    int previousTruckQty = 0;
    try {
      previousTruckQty =
          double.tryParse(data['previous_truck_qty'].toString())?.toInt() ?? 0;
    } catch (e) {
      previousTruckQty = 0;
    }

    final status = data['status'];

    final balanceqty = scannedqty - previousTruckQty;
    print("balanceqty $balanceqty");

    // 🚫 Skip rendering this row if scannedqty == previousTruckQty
    if (scannedqty == previousTruckQty) {
      return SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {},
      child: Container(
        color: rowColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTableCell(
              width: columnWidths[0]!,
              child: Text(
                (index + 1).toString(),
                style: TextStyle(fontSize: 12),
              ),
            ),
            _buildTableCell(
              width: columnWidths[1]!,
              child: Text(
                data['reqno'].toString(),
                style: TextStyle(fontSize: 12),
              ),
            ),
            _buildTableCell(
              width: columnWidths[2]!,
              child: Text(
                data['pickid'].toString(),
                style: TextStyle(fontSize: 12),
              ),
            ),
            _buildTableCell(
              width: columnWidths[3]!,
              child: Text(
                data['cusno'].toString(),
                style: TextStyle(fontSize: 12),
              ),
            ),
            _buildTableCell(
              width: columnWidths[4]!,
              child: Tooltip(
                message: data['cusname'].toString(),
                child: Text(
                  data['cusname'].toString(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            _buildTableCell(
              width: columnWidths[5]!,
              child: Text(
                data['cussite'].toString(),
                style: TextStyle(fontSize: 12),
              ),
            ),
            _buildTableCell(
              width: columnWidths[6]!,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Tooltip(
                    message: 'Scanned Qty',
                    child: Text(
                      "$scannedqty",
                      style: TextStyle(
                        color: Color.fromARGB(255, 65, 147, 72),
                        fontSize: isDesktop ? 14 : 12,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text("-", style: TextStyle(fontSize: isDesktop ? 14 : 12)),
                  SizedBox(width: 10),
                  Tooltip(
                    message: 'Already Trucked Qty',
                    child: Text(
                      "$previousTruckQty",
                      style: TextStyle(
                        color: Color.fromARGB(255, 65, 147, 72),
                        fontSize: isDesktop ? 14 : 12,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text("-", style: TextStyle(fontSize: isDesktop ? 14 : 12)),
                  SizedBox(width: 10),
                  Tooltip(
                    message: 'Load Scan Qty',
                    child: Text(
                      "$finalqty",
                      style: TextStyle(
                        color: Color.fromARGB(255, 154, 52, 52),
                        fontSize: isDesktop ? 14 : 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action Button
            _buildTableCell(
              width: columnWidths[7]!,
              child: ElevatedButton(
                onPressed: () async {
                  await widget.togglePage(
                    data['reqno'].toString(),
                    data['pickid'].toString(),
                    data['cusno'].toString(),
                    data['cusname'].toString(),
                    data['cussite'].toString(),
                    "$balanceqty",
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonColor(status),
                  minimumSize: Size(isDesktop ? 45.0 : 35.0, 31.0),
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 12 : 8),
                ),
                child: isDesktop
                    ? Text(_getButtonLabel(status), style: commonWhiteStyle)
                    : Icon(Icons.qr_code_scanner, size: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell({required double width, required Widget child}) {
    return Container(
      height: 30,
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: child,
        ),
      ),
    );
  }

  Widget _buildScrollArrows() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_left_outlined,
                color: Colors.blueAccent, size: 30),
            onPressed: () {
              _horizontalScrollController.animateTo(
                _horizontalScrollController.offset - 100,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_right_outlined,
                color: Colors.blueAccent, size: 30),
            onPressed: () {
              _horizontalScrollController.animateTo(
                _horizontalScrollController.offset + 100,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  String _getButtonLabel(String status) {
    if (status == "Completed") {
      return "Scan Completed"; // When status is "Completed"
    } else if (status == "Processing") {
      return "Processing"; // When status is "Processing"
    } else {
      return "Load to Truck"; // When status is "Not Available"
    }
  }

  Color _getButtonColor(String status) {
    if (status == "Completed") {
      return Colors.green; // Green for "Completed"
    } else if (status == "Processing") {
      return Colors.purple; // Purple for "Processing"
    } else {
      return buttonColor; // Default color (can be any color for "Not Available")
    }
  }
}
