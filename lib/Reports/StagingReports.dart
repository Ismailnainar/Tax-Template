import 'dart:convert';
import 'dart:ui';

import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data'; // for Uint8List
import 'dart:io'; // for File
import 'package:path_provider/path_provider.dart'; // for getApplicationDocumentsDirectory
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';

//No product available in staging
class StagingReports extends StatefulWidget {
  @override
  State<StagingReports> createState() => _StagingReportsState();
}

class _StagingReportsState extends State<StagingReports> {
  final TextEditingController salesmanIdController = TextEditingController();

  List<Map<String, dynamic>> filteredData = [];
  bool _isLoadingData = true;

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSalesmanName();
    fetchDispatchData();

    postLogData("Staging View", "Opened");
    filteredData = List.from(tableData); // Initialize with all data
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();

    postLogData("Staging View", "Closed");
    super.dispose();
  }

  String? saveloginname = '';

  String? saveloginrole = '';
  String? salesloginno = '';

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
      saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
      salesloginno = prefs.getString('salesloginno') ?? 'Unknown ID';
    });
  }

  // void _search() {
  //   String searchId = salesmanIdController.text.trim();

  //   // Perform the filtering
  //   setState(() {
  //     filteredData = tableData
  //         .where((data) => data['salesman'].contains(searchId))
  //         .toList();
  //   });
  // }
  TextEditingController RwqNoController = TextEditingController();

  void _search() {
    String searchId = RwqNoController.text.trim();
    print("searchId: $searchId");

    setState(() {
      if (searchId.isEmpty) {
        // Reset to full data when input is empty
        tableData = List<Map<String, dynamic>>.from(originalTableData);
      } else {
        // Filter from original data every time
        tableData = originalTableData.where((data) {
          return data['REQ_ID']
              .toString()
              .toLowerCase()
              .contains(searchId.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return Scaffold(
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
                                  Icons.view_module,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Staging View',
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
                                        saveloginrole ?? 'Loading...',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: const Color.fromARGB(
                                                255, 68, 67, 67)),
                                      ),
                                    ),
                                  ],
                                ),
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
                  padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                  child: Container(
                    height: screenheight * 0.89,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey[400]!,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            if (saveloginrole == 'WHR SuperUser') ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 16, left: 25, bottom: 0),
                                child: SizedBox(
                                  width:
                                      Responsive.isDesktop(context) ? 180 : 130,
                                  height: 33,
                                  child: TextField(
                                    controller: RwqNoController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter Request No',
                                      border: OutlineInputBorder(),
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                    ),
                                    onChanged: (value) => _search(),
                                    style: textBoxstyle,
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        _buildTable()
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

  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> originalTableData = [];

  bool _isLoading = false;
  Future<void> fetchDispatchData() async {
    //   final IpAddress = await getActiveIpAddress();
    //   final String url = '$IpAddress/Filtered_livestagereports/';
    //   List<Map<String, dynamic>> allData = [];
    //   bool hasNextPage = true;
    //   String? nextPageUrl = url;

    //   print("Fetching live staging reports from URL: $url");

    //   setState(() {
    //     _isLoadingData = true;
    //   });

    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   String? saleslogiOrgid = prefs.getString('saleslogiOrgwarehousename') ?? '';

    //   try {
    //     while (hasNextPage && nextPageUrl != null) {
    //       final response = await http.get(Uri.parse(nextPageUrl));

    //       if (response.statusCode == 200) {
    //         final decodedBody = utf8.decode(response.bodyBytes);
    //         final Map<String, dynamic> responseData = json.decode(decodedBody);
    //         // print("Response data: $responseData");

    //         if (responseData.containsKey('results')) {
    //           final List<Map<String, dynamic>> currentPageData =
    //               List<Map<String, dynamic>>.from(responseData['results']);

    //           for (var item in currentPageData) {
    //             if (item['PHYSICAL_WAREHOUSE']?.toString() == saleslogiOrgid &&
    //                 item['FLAG']?.toString() != "OU") {
    //               String reqNo = item['REQ_ID'] ?? '';
    //               String pickId = item['PICK_ID'] ?? '';
    //               String pickedQty = item['PICKED_QTY'] ?? '';

    //               if (await checkDataExists(reqNo, pickId, pickedQty)) {
    //                 allData.add(item);
    //               }
    //             }
    //           }

    //           nextPageUrl = responseData['next'];
    //           hasNextPage = nextPageUrl != null;
    //         } else {
    //           throw Exception('No "results" key found in the response.');
    //         }
    //       } else {
    //         throw Exception('Failed to load data: ${response.statusCode}');
    //       }
    //     }

    //     setState(() {
    //       tableData = allData.map((item) {
    //         return {
    //           "REQ_ID": item['REQ_ID']?.toString() ?? '',
    //           "TO_WAREHOUSE": item['TO_WAREHOUSE']?.toString() ?? '',
    //           "ORG_ID": double.tryParse(item['ORG_ID']?.toString() ?? '0') ?? 0.0,
    //           "ORG_NAME": item['ORG_NAME']?.toString() ?? '',
    //           "INVOICE_NUMBER": item['INVOICE_NUMBER']?.toString() ?? '',
    //           "CUSTOMER_NUMBER": item['CUSTOMER_NUMBER']?.toString() ?? '',
    //           "CUSTOMER_NAME": item['CUSTOMER_NAME']?.toString() ?? '',
    //           "CUSTOMER_SITE_ID": item['CUSTOMER_SITE_ID']?.toString() ?? '',
    //           "SALESMAN_NO": item['SALESMAN_NO']?.toString() ?? '',
    //           "SALESMAN_NAME": item['SALESMAN_NAME']?.toString() ?? '',
    //           "TOT_QUANTITY":
    //               double.tryParse(item['TOT_QUANTITY']?.toString() ?? '0') ?? 0.0,
    //           "DISPATCHED_QTY":
    //               double.tryParse(item['DISPATCHED_QTY']?.toString() ?? '0') ??
    //                   0.0,
    //           "PICKED_QTY":
    //               double.tryParse(item['PICKED_QTY']?.toString() ?? '0') ?? 0.0,
    //           "STATUS": item['STATUS']?.toString() ?? '',
    //         };
    //       }).toList();

    //       if (allData.isNotEmpty) {
    //         final lastItem = allData.last;
    //         warehouseNameController.text =
    //             lastItem['TO_WAREHOUSE']?.toString() ?? '';
    //         regionController.text = lastItem['ORG_NAME']?.toString() ?? '';
    //         reqNoController.text = lastItem['REQ_ID']?.toString() ?? '';
    //         cussiteController.text =
    //             lastItem['CUSTOMER_SITE_ID']?.toString() ?? '';
    //       }
    //     });

    //     await fetchStatusForItems();
    //     await fetchPreviousLoadCount();

    //     // print("Filtered data: $tableData");
    //     originalTableData =
    //         List<Map<String, dynamic>>.from(tableData); // store original data
    //   } catch (e) {
    //     print('Error fetching live staging reports: $e');
    //   } finally {
    //     setState(() {
    //       _isLoadingData = false;
    //     });
    //   }
    // }

    final IpAddress = await getActiveIpAddress();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename') ?? '';
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

        tableData = allData.where((item) {
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
            'CUSTOMER_NUMBER': item['CUSTOMER_NUMBER'],
            'CUSTOMER_NAME': item['CUSTOMER_NAME'],
            'CUSTOMER_SITE_ID': item['CUSTOMER_SITE_ID'],
            'cussite': item['CUSTOMER_SITE_ID'],
            'REQ_ID': item['REQ_ID'],
            'pickid': item['PICK_ID'],
            // 'PICKED_QTY': item['PICKED_QTY'],
            'status': item['status']?.toString() ?? 'Unknown',
            'PICKED_QTY': item['PICKED_QTY']?.toString() ?? '0',
          };
        }).toList();

        originalTableData =
            List<Map<String, dynamic>>.from(tableData); // store original data
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

  // Future<void> fetchDispatchData() async {
  //   final IpAddress = await getActiveIpAddress();

  //   final String url = '$IpAddress/Filtered_livestagereports/';
  //   List<Map<String, dynamic>> allData = [];
  //   bool hasNextPage = true;
  //   String? nextPageUrl = url;

  //   print("Fetching live staging reports from URL: $url");

  //   setState(() {
  //     _isLoadingData = true;
  //   });

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? saleslogiOrgid = prefs.getString('saleslogiOrgwarehousename') ?? '';

  //   try {
  //     while (hasNextPage && nextPageUrl != null) {
  //       // Fetch data from the current page
  //       final response = await http.get(Uri.parse(nextPageUrl));

  //       if (response.statusCode == 200) {
  //         final decodedBody = utf8.decode(response.bodyBytes); // <- fix here

  //         final Map<String, dynamic> responseData = json.decode(decodedBody);
  //         print("Response data: $responseData");

  //         if (responseData.containsKey('results')) {
  //           // Extract results from the response
  //           final List<Map<String, dynamic>> currentPageData =
  //               List<Map<String, dynamic>>.from(responseData['results']);

  //           // Filter rows using checkDataExists before adding
  //           for (var item in currentPageData) {
  //             if (item['PHYSICAL_WAREHOUSE']?.toString() == saleslogiOrgid &&
  //                 item['FLAG']?.toString() != "OU") {
  //               String reqNo = item['REQ_ID'] ?? '';
  //               String pickId = item['PICK_ID'] ?? '';
  //               String pickedQty = item['PICKED_QTY'] ?? '';

  //               // Add data to the list if it meets the ORG_ID condition
  //               if (await checkDataExists(reqNo, pickId, pickedQty)) {
  //                 allData.add(item);
  //               }
  //             }
  //           }

  //           // Check for the next page
  //           nextPageUrl = responseData['next'];
  //           hasNextPage = nextPageUrl != null;
  //         } else {
  //           throw Exception('No "results" key found in the response.');
  //         }
  //       } else {
  //         throw Exception('Failed to load data: ${response.statusCode}');
  //       }
  //     }

  //     // Process and transform the filtered data
  //     setState(() {
  //       tableData = allData.map((item) {
  //         return {
  //           "REQ_ID": item['REQ_ID']?.toString() ?? '',
  //           "TO_WAREHOUSE": item['TO_WAREHOUSE']?.toString() ?? '',
  //           "ORG_ID": double.tryParse(item['ORG_ID']?.toString() ?? '0') ?? 0.0,
  //           "ORG_NAME": item['ORG_NAME']?.toString() ?? '',
  //           "INVOICE_NUMBER": item['INVOICE_NUMBER']?.toString() ?? '',
  //           "CUSTOMER_NUMBER": item['CUSTOMER_NUMBER']?.toString() ?? '',
  //           "CUSTOMER_NAME": item['CUSTOMER_NAME']?.toString() ?? '',
  //           "CUSTOMER_SITE_ID": item['CUSTOMER_SITE_ID']?.toString() ?? '',
  //           "SALESMAN_NO": item['SALESMAN_NO']?.toString() ?? '',
  //           "SALESMAN_NAME": item['SALESMAN_NAME']?.toString() ?? '',
  //           "TOT_QUANTITY":
  //               double.tryParse(item['TOT_QUANTITY']?.toString() ?? '0') ?? 0.0,
  //           "DISPATCHED_QTY":
  //               double.tryParse(item['DISPATCHED_QTY']?.toString() ?? '0') ??
  //                   0.0,
  //           "PICKED_QTY":
  //               double.tryParse(item['PICKED_QTY']?.toString() ?? '0') ?? 0.0,
  //           "STATUS": item['STATUS']?.toString() ?? '',
  //         };
  //       }).toList();

  //       // Assign values to controllers based on the last item in the data
  //       if (allData.isNotEmpty) {
  //         final lastItem = allData.last;
  //         warehouseNameController.text =
  //             lastItem['TO_WAREHOUSE']?.toString() ?? '';
  //         regionController.text = lastItem['ORG_NAME']?.toString() ?? '';
  //         reqNoController.text = lastItem['REQ_ID']?.toString() ?? '';
  //         cussiteController.text =
  //             lastItem['CUSTOMER_SITE_ID']?.toString() ?? '';
  //       }

  //       _isLoadingData = false;
  //     });

  //     // Fetch statuses and additional details
  //     await fetchStatusForItems();
  //     await fetchPreviousLoadCount();

  //     print("Filtered data: $tableData");
  //   } catch (e) {
  //     setState(() {
  //       _isLoadingData = false;
  //     });
  //     print('Error fetching live staging reports: $e');
  //   }
  // }

  Future<void> fetchStatusForItems() async {
    // Iterate over the filteredData and fetch the status for each item
    for (int i = 0; i < filteredData.length; i++) {
      String reqno =
          filteredData[i]['reqno'].toString(); // Ensure it's a string
      String cusno =
          filteredData[i]['cusno'].toString(); // Ensure it's a string
      String cussite =
          filteredData[i]['cussite'].toString(); // Ensure it's a string
      String pickid = filteredData[i]['pickid'].toString();
      String qty = filteredData[i]['scannedqty'].toString();
      int finalqty = double.parse(qty).toInt(); // Convert to integer

      // Print the values to ensure they are being passed correctly
      print(
          "Fetching status for item ${i + 1}: reqno=$reqno, cusno=$cusno, qty=$finalqty, cussite=$cussite");
      final IpAddress = await getActiveIpAddress();

      try {
        // Make the API request with proper parameters
        final statusResponse = await http.get(
          Uri.parse(
              '$IpAddress/Livestagebuttonstaus/$reqno/$pickid/$cusno/$finalqty/$cussite'),
        );

        // Debugging the API URL to verify the request
        print(
            "Request URL: $IpAddress/Livestagebuttonstaus/$reqno/$pickid/$cusno/$finalqty/$cussite");

        // Check if the response status code is 200 (OK)
        if (statusResponse.statusCode == 200) {
          final statusData = json.decode(statusResponse.body);

          // Update the status in the filteredData list for the correct index
          setState(() {
            filteredData[i]['status'] = statusData['status'] ?? 'Unknown';
            print('FilteredData updated for reqno $reqno:');
          });
        } else {
          print('Failed to fetch status for reqno: $reqno, cusno: $cusno');
        }
      } catch (e) {
        print('Error fetching status for reqno: $reqno, cusno: $cusno: $e');
      }
    }

    // Trigger a final rebuild after the loop finishes
    setState(() {
      print('All status updates completed!');
    });
  }

  Future<void> fetchPreviousLoadCount() async {
    for (int i = 0; i < filteredData.length; i++) {
      // Extract required fields and ensure they are strings
      String reqno = filteredData[i]['reqno'].toString();
      String cusno = filteredData[i]['cusno'].toString();
      String cussite = filteredData[i]['cussite'].toString();
      String pickid = filteredData[i]['pickid'].toString();

      // Parse qty as a double and cast it to an int
      // int count = (double.parse(qty)).round(); // Rounding ensures no type error

      // Log values for debugging
      final IpAddress = await getActiveIpAddress();

      try {
        // API URL for the truck scan
        final truckScanUrl =
            '$IpAddress/Truck_scan/?REQ_NO=$reqno&PICK_ID=$pickid';
        int totalCount = 0;
        bool hasNextPage = true;
        String? nextPageUrl = truckScanUrl;

        setState(() {
          _isLoading = true;
        });

        // Paginated API request logic
        while (hasNextPage && nextPageUrl != null) {
          final response = await http.get(Uri.parse(nextPageUrl));

          if (response.statusCode == 200) {
            final Map<String, dynamic> responseData =
                json.decode(response.body);

            // Increment the total count
            if (responseData.containsKey('count')) {
              totalCount += (responseData['count'] as num).toInt();
            }

            // Determine if there's a next page
            nextPageUrl = responseData['next'];
            hasNextPage = nextPageUrl != null;
          } else {
            throw Exception('Failed to fetch data from $nextPageUrl');
          }
        }

        // Update `previous_truck_qty` in the filtered data
        setState(() {
          filteredData[i]['previous_truck_qty'] = totalCount ?? '0';
          print('Updated previous_truck_qty for reqno $reqno: $totalCount');
        });
      } catch (e) {
        // Handle exceptions and log errors
        print('Error fetching data for reqno: $reqno, cusno: $cusno: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> checkDataExists(
      String reqno, String pickid, String pickedQty) async {
    final IpAddress = await getActiveIpAddress();

    final url =
        Uri.parse('$IpAddress/Truck_scan/?REQ_NO=$reqno&PICK_ID=$pickid');

    // print("Fetching URL: $pickedQty: $url");

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

      // print("parsedPickedQty (as int): $intPickedQty: $url");

      final response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Check if the "results" field exists and compare the results count with intPickedQty
        int resultsCount = (data['results'] as List).length;

        // Show the row if there are no results (data doesn't exist) or the count is less than intPickedQty
        return resultsCount < intPickedQty || resultsCount == 0;
      } else {
        return false; // If not successful, assume no data
      }
    } catch (e) {
      print('Error checking data: $e');
      return false; // On error, assume no data
    }
  }

  List<Map<String, dynamic>> getUniqueTableData(
      List<Map<String, dynamic>> data) {
    final Map<String, Map<String, dynamic>> consolidatedData = {};

    for (var item in data) {
      String reqId = item['REQ_ID'].toString();
      if (consolidatedData.containsKey(reqId)) {
        // If REQ_ID already exists, add PICKED_QTY to the existing value
        consolidatedData[reqId]!['PICKED_QTY'] +=
            double.tryParse(item['PICKED_QTY'].toString()) ?? 0.0;
      } else {
        // Add new entry
        consolidatedData[reqId] = {
          ...item,
          'PICKED_QTY': double.tryParse(item['PICKED_QTY'].toString()) ?? 0.0,
        };
      }
    }

    // Convert the consolidated data map back to a list
    return consolidatedData.values.toList();
  }

  Widget _buildTable() {
    // Preprocess tableData to consolidate entries with the same REQ_ID

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Scrollbar(
        thumbVisibility: true,
        controller: _horizontalScrollController,
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  Container(
              //   color: Colors.white,
              //   height: MediaQuery.of(context).size.height * 0.7,
              //   width: MediaQuery.of(context).size.width * 0.8,
              //   child: Scrollbar(
              //     thumbVisibility: true,
              //     controller: _verticalScrollController,
              //     child: SingleChildScrollView(
              //       controller: _verticalScrollController,
              //       child: Column(
              //         children: [
              //           // Table Header
              //           Padding(
              //             padding: const EdgeInsets.symmetric(
              //                 horizontal: 10, vertical: 13),
              //             child: Row(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 _tableHeader("S.No", Icons.format_list_numbered),
              //                 _tableHeader("Req No", Icons.print),
              //                 _tableHeader("Customer No", Icons.account_circle),
              //                 _tableHeader("Customer Name", Icons.person),
              //                 // _tableHeader("Tot.Invoice.Qty", Icons.list),
              //                 _tableHeader("Tot.Req.Qty", Icons.list),
              //               ],
              //             ),
              //           ),
              //           // Loading Indicator or Table Rows
              //           if (_isLoading)
              //             Padding(
              //               padding: const EdgeInsets.only(top: 100.0),
              //               child: Center(child: CircularProgressIndicator()),
              //             )
              //           else if (tableData.isNotEmpty)
              //             ...tableData.asMap().entries.map((entry) {
              //               int index = entry.key;
              //               var data = entry.value;

              //               String sNo = (index + 1).toString();
              //               String reqNo = "ReqNo_${data['REQ_ID'].toString()}";
              //               String customerno =
              //                   data['CUSTOMER_NUMBER'].toString();
              //               String customername =
              //                   "${data['CUSTOMER_NAME'].toString()}";
              //               String customersiteid =
              //                   data['CUSTOMER_SITE_ID'].toString();
              //               String salesmanName =
              //                   data['INVOICE_NUMBER'].toString();
              //               String invoiceQty = data['TOT_QUANTITY'].toString();

              //               String dispatchedQty =
              //                   data['DISPATCHED_QTY'].toString();

              //               String pickedqty = data['PICKED_QTY'].toString();

              //               bool isEvenRow = index % 2 == 0;
              //               Color rowColor = isEvenRow
              //                   ? Color.fromARGB(224, 255, 255, 255)
              //                   : Color.fromARGB(224, 255, 255, 255);

              //               return Padding(
              //                 padding:
              //                     const EdgeInsets.symmetric(horizontal: 10),
              //                 child: GestureDetector(
              //                   onDoubleTap: () async {
              //                     // Show Dialog on Row Click
              //                     await fetchPickmanData(
              //                         data['REQ_ID'],
              //                         data['CUSTOMER_NUMBER'],
              //                         data['CUSTOMER_SITE_ID']);
              //                     showDialog(
              //                       context: context,
              //                       barrierDismissible: false,
              //                       builder: (BuildContext context) {
              //                         return pending_pickmandetailsdialogbox(
              //                           context,
              //                           data['REQ_ID'],
              //                         );
              //                       },
              //                     );
              //                   },
              //                   child: Row(
              //                     mainAxisAlignment: MainAxisAlignment.center,
              //                     children: [
              //                       _tableRow(sNo, rowColor),
              //                       _tableRow(reqNo, rowColor),
              //                       _tableRow(
              //                         customerno,
              //                         rowColor,
              //                       ),
              //                       _tableRow(customername, rowColor),
              //                       // _tableRow(invoiceQty, rowColor),
              //                       _tableRow(pickedqty, rowColor),
              //                     ],
              //                   ),
              //                 ),
              //               );
              //             }).toList()
              //           else
              //             Padding(
              //               padding: const EdgeInsets.only(top: 100.0),
              //               child: Text("No data available."),
              //             ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),

              Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height * 0.7,
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.8
                    : MediaQuery.of(context).size.width * 1.7,
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _verticalScrollController,
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    child: Column(
                      children: [
                        // Table Header
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 13),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _tableHeader("S.No", Icons.format_list_numbered),
                              _tableHeader("Req No", Icons.print),
                              _tableHeader("Customer No", Icons.account_circle),
                              _tableHeader("Customer Name", Icons.person),
                              _tableHeader("Tot.Picked.Qty", Icons.list),
                            ],
                          ),
                        ),
                        // Loading Indicator or Table Rows
                        if (_isLoadingData)
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (tableData.isNotEmpty)
                          ...getUniqueTableData(tableData)
                              .asMap()
                              .entries
                              .map((entry) {
                            int index = entry.key;
                            var data = entry.value;

                            String sNo = (index + 1).toString();
                            String reqNo = "${data['REQ_ID'].toString()}";
                            String customerno =
                                data['CUSTOMER_NUMBER'].toString();
                            String customername =
                                data['CUSTOMER_NAME'].toString();
                            String pickedqty =
                                data['PICKED_QTY'].toStringAsFixed(0);

                            bool isEvenRow = index % 2 == 0;
                            Color rowColor = isEvenRow
                                ? Color.fromARGB(224, 255, 255, 255)
                                : Color.fromARGB(224, 255, 255, 255);

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: GestureDetector(
                                onDoubleTap: () async {
                                  // Show Dialog on Row Click
                                  await fetchPickmanData(
                                    data['REQ_ID']?.toString() ?? '',
                                    data['CUSTOMER_NUMBER']?.toString() ?? '',
                                    data['CUSTOMER_SITE_ID']?.toString() ?? '',
                                  );
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return pending_pickmandetailsdialogbox(
                                          context,
                                          data['REQ_ID']?.toString() ?? '');
                                    },
                                  );

                                  postLogData("Staging View Pop-up", "Opened");
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _tableRow(sNo, rowColor),
                                    _tableRow(reqNo, rowColor),
                                    _tableRow(customerno, rowColor),
                                    _tableRow(customername, rowColor),
                                    _tableRow(pickedqty, rowColor),
                                  ],
                                ),
                              ),
                            );
                          }).toList()
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Text("No product available in staging"),
                          ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableHeader(String text, IconData icon) {
    return Flexible(
      child: Container(
        height: Responsive.isDesktop(context) ? 25 : 30,
        decoration: TableHeaderColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align to the start
          crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
          children: [
            Icon(icon, size: 15, color: Colors.blue),
            SizedBox(width: 2),
            Expanded(
              // Ensures the text adjusts properly
              child: Text(
                text,
                textAlign: TextAlign.left, // Align text to the start (left)
                style: commonLabelTextStyle,
                overflow: TextOverflow.ellipsis, // Prevent overflow
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tablepickidHeader(String text, IconData icon) {
    return Container(
      height: Responsive.isDesktop(context) ? 25 : 30,
      width: 150,
      decoration: TableHeaderColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Align to the start
        crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
        children: [
          Icon(icon, size: 15, color: Colors.blue),
          SizedBox(width: 2),
          Expanded(
            // Ensures the text adjusts properly
            child: Text(
              text,
              textAlign: TextAlign.left, // Align text to the start (left)
              style: commonLabelTextStyle,
              overflow: TextOverflow.ellipsis, // Prevent overflow
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableItemDescHeader(String text, IconData icon) {
    return Container(
      height: Responsive.isDesktop(context) ? 25 : 30,
      width: 450,
      decoration: TableHeaderColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Align to the start
        crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
        children: [
          Icon(icon, size: 15, color: Colors.blue),
          SizedBox(width: 2),
          Expanded(
            // Ensures the text adjusts properly
            child: Text(
              text,
              textAlign: TextAlign.left, // Align text to the start (left)
              style: commonLabelTextStyle,
              overflow: TextOverflow.ellipsis, // Prevent overflow
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableRow(String data, Color? rowColor, {String? tooltipMessage}) {
    return Flexible(
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: rowColor,
          border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align to the start
          crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
          children: [
            Expanded(
              // Ensures the text adjusts properly
              child: tooltipMessage != null
                  ? Tooltip(
                      message: tooltipMessage,
                      child: SelectableText(
                        data,
                        textAlign: TextAlign.left,
                        style: commonLabelTextStyle,
                        showCursor: false,
                        // overflow: TextOverflow.ellipsis,
                        cursorColor: Colors.blue,
                        cursorWidth: 2.0,
                        toolbarOptions:
                            ToolbarOptions(copy: true, selectAll: true),
                        onTap: () {
                          // Optional: Handle single tap if needed
                        },
                      ),

                      // Text(
                      //   data,
                      //   textAlign: TextAlign.left, // Align text to the start
                      //   style: TableRowTextStyle,
                      //   overflow: TextOverflow.ellipsis,
                      // ),
                    )
                  : SelectableText(
                      data,
                      textAlign: TextAlign.left,
                      style: commonLabelTextStyle,
                      showCursor: false,
                      // overflow: TextOverflow.ellipsis,
                      cursorColor: Colors.blue,
                      cursorWidth: 2.0,
                      toolbarOptions:
                          ToolbarOptions(copy: true, selectAll: true),
                      onTap: () {
                        // Optional: Handle single tap if needed
                      },
                    ),
              //  Text(
              //     data,
              //     textAlign: TextAlign.left, // Align text to the start
              //     style: TableRowTextStyle,
              //     overflow: TextOverflow.ellipsis,
              //   ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableItemDescRow(String data, Color? rowColor,
      {String? tooltipMessage}) {
    return Container(
      height: 30,
      width: 450,
      decoration: BoxDecoration(
        color: rowColor,
        border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Align to the start
        crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
        children: [
          SelectableText(
            data,
            textAlign: TextAlign.left,
            style: commonLabelTextStyle,
            showCursor: false,
            // overflow: TextOverflow.ellipsis,
            cursorColor: Colors.blue,
            cursorWidth: 2.0,
            toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
            onTap: () {
              // Optional: Handle single tap if needed
            },
          ),
        ],
      ),
    );
  }

  Widget pending_pickmandetailsdialogbox(BuildContext context, String reqNo) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      child: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            width: Responsive.isDesktop(context) ? screenWidth * 0.6 : 600,
            height: Responsive.isDesktop(context) ? 560 : 500,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Staging Pop-Up",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.cancel))
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runSpacing: 5,
                      children: [
                        Container(
                          width: Responsive.isDesktop(context)
                              ? screenWidth * 0.13
                              : screenWidth * 0.4,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("Customer No", style: textboxheading),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0, bottom: 0),
                                  child: Row(
                                    children: [
                                      Container(
                                          height: 32,
                                          // width: Responsive.isDesktop(context)
                                          //     ? screenWidth * 0.086
                                          //     : 130,

                                          width: Responsive.isDesktop(context)
                                              ? screenWidth * 0.13
                                              : screenWidth * 0.4,
                                          child: MouseRegion(
                                            onEnter: (event) {
                                              // You can perform any action when mouse enters, like logging the value.
                                            },
                                            onExit: (event) {
                                              // Perform any action when the mouse leaves the TextField area.
                                            },
                                            cursor: SystemMouseCursors
                                                .click, // Changes the cursor to indicate interaction
                                            child: Tooltip(
                                              message:
                                                  "${customerNoController.text}",
                                              child: TextFormField(
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color.fromARGB(
                                                          201, 132, 132, 132),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color.fromARGB(
                                                          255, 58, 58, 58),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  filled:
                                                      true, // Enable the background fill
                                                  fillColor: Color.fromARGB(
                                                      255, 234, 234, 234),

                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 5.0,
                                                    horizontal: 10.0,
                                                  ),
                                                ),
                                                controller:
                                                    customerNoController,
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 73, 72, 72),
                                                    fontSize: 13),
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: Responsive.isDesktop(context)
                              ? screenWidth * 0.13
                              : screenWidth * 0.4,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("Customer Name",
                                        style: textboxheading),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0, bottom: 0),
                                  child: Row(
                                    children: [
                                      Container(
                                          height: 32,
                                          // width: Responsive.isDesktop(context)
                                          //     ? screenWidth * 0.086
                                          //     : 130,

                                          width: Responsive.isDesktop(context)
                                              ? screenWidth * 0.13
                                              : screenWidth * 0.4,
                                          child: MouseRegion(
                                            onEnter: (event) {
                                              // You can perform any action when mouse enters, like logging the value.
                                            },
                                            onExit: (event) {
                                              // Perform any action when the mouse leaves the TextField area.
                                            },
                                            cursor: SystemMouseCursors
                                                .click, // Changes the cursor to indicate interaction
                                            child: Tooltip(
                                              message:
                                                  "${customerNameController.text}",
                                              child: TextFormField(
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color.fromARGB(
                                                          201, 132, 132, 132),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color.fromARGB(
                                                          255, 58, 58, 58),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  filled:
                                                      true, // Enable the background fill
                                                  fillColor: Color.fromARGB(
                                                      255, 234, 234, 234),

                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 5.0,
                                                    horizontal: 10.0,
                                                  ),
                                                ),
                                                controller:
                                                    customerNameController,
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 73, 72, 72),
                                                    fontSize: 13),
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // SizedBox(
                        //   width: 10,
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 26.0),
                        //   child: Container(
                        //     height: 32,
                        //     decoration: BoxDecoration(color: buttonColor),
                        //     child: ElevatedButton(
                        //         onPressed: () async {
                        //           showInvoiceDialog(
                        //             context,
                        //             true,
                        //             tableData,
                        //           );
                        //         },
                        //         style: ElevatedButton.styleFrom(
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(8),
                        //           ),
                        //           minimumSize: const Size(45.0, 20.0),
                        //           backgroundColor: Colors.transparent,
                        //           shadowColor: Colors.transparent,
                        //         ),
                        //         child: Text(
                        //           'Print',
                        //           style: commonWhiteStyle,
                        //         )),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Container(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Viewtabledata(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> viewtableData = [];

  TextEditingController customerNameController = TextEditingController();
  TextEditingController customerNoController = TextEditingController();

  Future<void> fetchPickmanData(
      String reqno, String cusno, String cussite) async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/filteredfinishedpickman/$reqno/$cusno/$cussite';
    print("Fetching data from URL: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // print('Response body: ${response.body}');

        // Decode the JSON response as a List
        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
        final List<dynamic> data = json.decode(decodedBody);

        if (data.isNotEmpty) {
          setState(() {
            // Safely cast the list to List<Map<String, dynamic>>
            viewtableData = List<Map<String, dynamic>>.from(data);

            // Assigning the first item's data to controllers
            customerNoController.text =
                viewtableData[0]['CUSTOMER_NUMBER']?.toString() ?? 'N/A';
            customerNameController.text =
                viewtableData[0]['CUSTOMER_NAME']?.toString() ?? 'N/A';

            cussiteController.text =
                viewtableData[0]['CUSTOMER_SITE_ID']?.toString() ?? 'N/A';

            warehouseNameController.text =
                viewtableData[0]['PHYSICAL_WAREHOUSE']?.toString() ?? 'N/A';
            pickNoController.text =
                viewtableData[0]['PICK_ID']?.toString() ?? 'N/A';
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          throw Exception('No data found in the response');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception(
            'Failed to load data. Server responded with status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (e is http.ClientException) {
        print('Network error: $e');
      } else if (e is FormatException) {
        print('Invalid JSON format: $e');
      } else {
        print('Unknown error: $e');
      }

      print('Error fetching data: $e');
    }
  }

  Widget Viewtabledata() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Scrollbar(
        thumbVisibility: true,
        controller: _horizontalScrollController,
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height * 0.5,
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.55
                    : MediaQuery.of(context).size.width * 1.8,
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _verticalScrollController,
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    child: Column(
                      children: [
                        // Table Header
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 13),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _tableHeader("S.No", Icons.format_list_numbered),
                              _tablepickidHeader("Pick Id", Icons.countertops),
                              _tableItemDescHeader(
                                  "Item Description", Icons.print),
                              // _tableHeader(
                              //     "Qty.Dispatch", Icons.account_circle),
                              _tableHeader("Qty.Staged", Icons.person),
                              // _tableHeader("Qty.Bal", Icons.list),
                            ],
                          ),
                        ),
                        // Loading Indicator or Table Rows
                        if (_isLoading)
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (viewtableData.isNotEmpty)
                          ...viewtableData.asMap().entries.map((entry) {
                            int index = entry.key;
                            var data = entry.value;

                            String sNo = (index + 1).toString();

                            String getpickid = data['PICK_ID'].toString();
                            String pickid = '$getpickid';
                            String pickmanname =
                                data['ASSIGN_PICKMAN'].toString();
                            String dispatchqty =
                                "${data['DISPATCHED_QTY'].toString()}";
                            String pickedqty =
                                data['total_picked_qty'].toString();

                            double dispatchQtyDouble =
                                double.tryParse(dispatchqty) ?? 0.0;
                            double pickedQtyDouble =
                                double.tryParse(pickedqty) ?? 0.0;

                            String item_descrption =
                                data['ITEM_DESCRIPTION'].toString();
// Perform the calculation
                            String finalpickqty = pickedQtyDouble.toString();
                            String finaldisreqty = dispatchQtyDouble.toString();
                            double balanceQtyDouble =
                                dispatchQtyDouble - pickedQtyDouble;

// If you want the balance as a string:
                            String balanceqty = balanceQtyDouble.toString();

                            bool isEvenRow = index % 2 == 0;
                            Color rowColor = isEvenRow
                                ? Color.fromARGB(224, 255, 255, 255)
                                : Color.fromARGB(224, 255, 255, 255);

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: GestureDetector(
                                onTap: () {
                                  // Show Dialog on Row Click
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _tableRow(sNo, rowColor),

                                    Expanded(
                                      child: Container(
                                        height: 30,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .start, // Aligns items to the start
                                          crossAxisAlignment: CrossAxisAlignment
                                              .center, // Center vertically
                                          children: [
                                            Expanded(
                                                child: Tooltip(
                                              message: pickmanname,
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Text(
                                                  pickid,
                                                  textAlign: TextAlign
                                                      .left, // Align text to the start
                                                  style: TableRowTextStyle,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            )),
                                          ],
                                        ),
                                      ),
                                    ),
                                    _tableItemDescRow(
                                        item_descrption, rowColor),
                                    _tableRow(finalpickqty, rowColor),
                                    // _tableRow(balanceqty, rowColor),
                                  ],
                                ),
                              ),
                            );
                          }).toList()
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Text("No product available in staging"),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextEditingController pickNoController = TextEditingController();
  TextEditingController warehouseNameController = TextEditingController();
  TextEditingController regionController = TextEditingController();
  TextEditingController reqNoController = TextEditingController();
  TextEditingController cussiteController = TextEditingController();

  Future<void> savereqno(String dispaatch_requestno) async {
    await SharedPrefs.dispaatch_requestno(dispaatch_requestno);
  }

  void showInvoiceDialog(
    BuildContext context,
    bool buttonname,
    List<Map<String, dynamic>> tableData,
  ) {
    double _calculateSendQtyTotal(List<Map<String, dynamic>> tableData) {
      double totalSendQty = 0.0;
      for (var row in viewtableData) {
        var sendQty = row['total_picked_qty'];
        if (sendQty != null) {
          totalSendQty += double.tryParse(sendQty.toString()) ?? 0.0;
        }
      }
      return totalSendQty;
    }

    String pickno = '${pickNoController.text}';
    String getCurrentTime() {
      final DateTime now = DateTime.now();
      final DateFormat timeFormat = DateFormat('h:mm:ss a'); // 12-hour format
      return timeFormat
          .format(now); // Formats the time as 3:57:10 PM or 3:57:10 AM
    }

    String getCurrentDate() {
      final DateTime now = DateTime.now();
      final DateFormat dateFormat = DateFormat('dd-MMM-yyyy');
      return dateFormat.format(now); // Formats the date as 19-NOV-2024
    }

    GlobalKey _globalKey = GlobalKey();

    Future<void> _captureAndSavePdf() async {
      try {
        // Check if the globalKey's context is null or if the RenderObject is null
        if (_globalKey.currentContext == null) {
          throw Exception(
              "GlobalKey context is null. Ensure the widget is rendered.");
        }

        // Capture the widget content as an image
        RenderRepaintBoundary boundary = _globalKey.currentContext!
            .findRenderObject() as RenderRepaintBoundary;

        if (boundary == null) {
          throw Exception(
              "RenderRepaintBoundary is null. Ensure the widget is rendered.");
        }

        // Capture the image
        var image = await boundary.toImage(pixelRatio: 3.0); // Capture as image

        if (image == null) {
          throw Exception("Image capture failed. The image is null.");
        }

        ByteData? byteData =
            await image.toByteData(format: ImageByteFormat.png);
        if (byteData == null) {
          throw Exception("Failed to convert image to byte data.");
        }

        Uint8List uint8List = byteData.buffer.asUint8List();

        final pdf = pw.Document();

        // Add image to the PDF document
        pdf.addPage(pw.Page(
          build: (pw.Context context) {
            return pw.Image(
              pw.MemoryImage(
                  uint8List), // Use MemoryImage to load image from Uint8List
            );
          },
        ));

        // Get the app's document directory for saving the file
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/invoice.pdf';
        final file = File(filePath);

        // Save the PDF to the file
        await file.writeAsBytes(await pdf.save());

        // Print the location of the saved file
        print("PDF saved to: $filePath");
      } catch (e) {
        print("Error while capturing and saving PDF: $e");
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                  width: 595,
                  height: 842,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Staging Receipt',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        // Header with Company Information
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset('assets/images/logo.jpg', height: 50),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Text(
                                //   'aljeflutterapp',
                                //   style: TextStyle(
                                //     fontSize: 18,
                                //     fontWeight: FontWeight.bold,
                                //     color: Colors.blueGrey[800],
                                //   ),
                                // ),
                                Text('123 Restaurant St, City Name',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                Text('Phone: +91 12345 67890',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                Text('Website: www.aljeflutterapp.com',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 5),

                        // Invoice Details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pick ID: ${pickno}',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[600]),
                            ),
                            // Text(
                            //   'Date: 20-Nov-2024',
                            //   style: TextStyle(
                            //       fontSize: 13, color: Colors.blueGrey[600]),
                            // ),
                          ],
                        ),
                        SizedBox(height: 5),

                        // Customer Information Section
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.5), width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: EdgeInsets.only(
                              left: 12, right: 12, top: 10, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                'Req ID: ',
                                reqNoController.text,
                                'Customer No: ',
                                customerNoController.text,
                              ),
                              _buildDetailRow(
                                'Physical Warehouse: ',
                                warehouseNameController.text,
                                'Customer Name: ',
                                customerNameController.text,
                              ),
                              _buildDetailRow(
                                'Region: ',
                                regionController.text,
                                'Customer Site:',
                                cussiteController.text,
                              ),
                              _buildDetailRow(
                                'Date : ',
                                getCurrentDate() + ' ' + getCurrentTime(),
                                '',
                                '',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),

                        Text(
                          'Staging Details:',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[700]),
                        ),
                        SizedBox(height: 12),

                        // Display the table
                        Container(
                          height: 350,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                                width: 1.5),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: IntrinsicHeight(
                            // Ensures the height matches PrintPreviewTable's height
                            child: PrintPreviewTable(tableData: viewtableData),
                          ),
                        ),
                        SizedBox(height: 7),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Total Qty: ${_calculateSendQtyTotal(viewtableData)}',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[600]),
                            ),
                          ],
                        ),
                        SizedBox(height: 7),

                        Divider(thickness: 1.5),
                        SizedBox(height: 5),
                        // Text(
                        //   'Thank you for your business!',
                        //   style: TextStyle(
                        //       fontSize: 13,
                        //       fontStyle: FontStyle.italic,
                        //       color: Colors.blueGrey[700]),
                        // ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Authorized Signature: __________',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            Text('Pickman Signature: __________',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        Divider(thickness: 1),
                        // SizedBox(height: 8),
                        // Text(
                        //   'Contact us: support@aljeflutterapp.com',
                        //   style: TextStyle(fontSize: 12, color: Colors.grey),
                        // ),
                        // SizedBox(height: 8),
                        // Text(
                        //   'Follow us on social media for updates!',
                        //   style: TextStyle(fontSize: 12, color: Colors.grey),
                        // ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    width: 595,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Helper function to truncate value2
  String _truncateText(String text) {
    const int maxChars = 10; // Number of characters to show
    if (text.length > maxChars) {
      int halfLength = maxChars ~/ 2; // Display half the max characters
      return '${text.substring(0, halfLength)}...';
    }
    return text;
  }

// Helper function to build a detail row
  Widget _buildDetailRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.blueGrey[600],
              ),
            ),
            SizedBox(width: 5),
            Text(
              value1,
              style: TextStyle(fontSize: 12, color: Colors.blueGrey[500]),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),

        SizedBox(width: 20), // Space between the two sections
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label2,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.blueGrey[600],
                ),
              ),
              SizedBox(width: 5),
              Tooltip(
                message: value2,
                child: Text(
                  _truncateText(value2),
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey[500]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PrintPreviewTable extends StatelessWidget {
  final List<Map<String, dynamic>> tableData;

  PrintPreviewTable({required this.tableData});

  @override
  Widget build(BuildContext context) {
    // Filter the tableData to exclude rows with empty or zero 'sendqty'

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Enable horizontal scrolling
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildTableHeader("S.No", 50),
                _buildTableHeader("Pick ID", 100),
                _buildTableHeader("Item Description",
                    MediaQuery.of(context).size.width * 0.17),
                _buildTableHeader("Qty", 100),
              ],
            ),
          ),
          // Scrollable Table Body
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical, // Enable vertical scrolling
              child: Column(
                  children: tableData.asMap().entries.map((entry) {
                int index = entry.key;
                var data = entry.value;

                String sNo = (index + 1).toString();
                String getpickid = data['PICK_ID'].toString();
                String pickid = '$getpickid';

                String pickedqty = data['total_picked_qty'].toString();
                double pickedQtyDouble = double.tryParse(pickedqty) ?? 0.0;
                String finalpickqty = pickedQtyDouble.toString();

                String itemDescription = data['ITEM_DESCRIPTION'].toString();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildTableRow(sNo, 50),
                      _buildTableRow(pickid, 100),
                      _buildTableRow(itemDescription,
                          MediaQuery.of(context).size.width * 0.17),
                      _buildTableRow(finalpickqty, 100),
                    ],
                  ),
                );
              }).toList()),
            ),
          ),
        ],
      ),
    );
  }

  // Table Header Builder (Reusable)
  Widget _buildTableHeader(String title, double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: width,
          height: 25,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Table Row Builder (Reusable)
  Widget _buildTableRow(String text, double width) {
    return Container(
      width: width,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis, // Prevent overflow
              ),
            ),
          ],
        ),
      ),
    );
  }
}
