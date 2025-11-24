import 'dart:convert';
import 'dart:math';

import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:aljeflutterapp/components/constaints.dart';
import 'package:aljeflutterapp/dispatch/GeneratePickman.dart';
import 'package:aljeflutterapp/dispatch/NewGenerateDispatch.dart';
import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PickManPendingReport extends StatefulWidget {
  @override
  State<PickManPendingReport> createState() => _PickManPendingReportState();
}

class _PickManPendingReportState extends State<PickManPendingReport> {
  final TextEditingController salesmanIdController = TextEditingController();

  final TextEditingController RwqNoController = TextEditingController();

  final TextEditingController PickidsearchController = TextEditingController();

  final TextEditingController completeRwqNoController = TextEditingController();

  final TextEditingController completePickidsearchController =
      TextEditingController();

  List<Map<String, dynamic>> filteredData = [];
  bool _isLoadingData = true;

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSalesmanName();
    fetchDispatchData();
    fetchCompletedDispatchData();

    postLogData("PickMan Pending View", "Opened");
    filteredData = List.from(tableData); // Initialize with all data
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();

    postLogData("PickMan Pending View", "Closed");
    super.dispose();
  }

  String? saveloginname = '';

  String? saveloginrole = '';
  String? salesloginno = '';
  List<Map<String, dynamic>> originalTableData = []; // Full unfiltered data

  List<Map<String, dynamic>> CompletedoriginalTableData =
      []; // Full unfiltered data

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
      saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
      salesloginno = prefs.getString('salesloginno') ?? 'Unknown ID';
    });
  }

  void _search() {
    String searchId = RwqNoController.text.trim().toLowerCase();
    print("searchId: $searchId");

    setState(() {
      if (searchId.isEmpty) {
        // Reset to full data when input is empty
        tableData = List<Map<String, dynamic>>.from(originalTableData);
      } else {
        tableData = originalTableData.where((data) {
          // Convert REQ_ID to lowercase string and check if it contains the input
          String reqId = data['REQ_ID']?.toString().toLowerCase() ?? '';
          return reqId.contains(searchId);
        }).toList();
      }
    });

    print("Filtered tableData: $tableData");
  }

  void _pickidsearch() {
    // Get the search input, trim and lowercase it
    String searchText = PickidsearchController.text.trim().toLowerCase();
    // print("originalTableDataaaa $originalTableData");
    print("searchText: $searchText");

    setState(() {
      if (searchText.isEmpty) {
        // Show all rows if search is empty
        tableData = List<Map<String, dynamic>>.from(originalTableData);
      } else {
        tableData = originalTableData.where((data) {
          // Get the pickidlist and convert it to a list of trimmed, lowercased values
          List<String> pickIds = data['PICK_IDS']
              .toString()
              .split(',')
              .map((id) => id.trim().toLowerCase())
              .toList();

          // Return true if any pickId contains the searchText (partial match)
          return pickIds.any((pickId) => pickId.contains(searchText));
        }).toList();
      }
    });

    // print("tableDataaaaaaaaaa $tableData");
  }

  void _Completedpicksearch() {
    String searchId = completeRwqNoController.text.trim().toLowerCase();
    print("searchId: $searchId");

    setState(() {
      if (searchId.isEmpty) {
        // Reset to full data when input is empty
        CompletedtableData =
            List<Map<String, dynamic>>.from(CompletedoriginalTableData);
      } else {
        CompletedtableData = CompletedoriginalTableData.where((data) {
          // Convert REQ_ID to lowercase string and check if it contains the input
          String reqId = data['REQ_ID']?.toString().toLowerCase() ?? '';
          return reqId.contains(searchId);
        }).toList();
      }
    });

    // print("Filtered tableData: $tableData");
  }

  void _completedpickidsearch() {
    // Get the search input, trim and lowercase it
    String searchText =
        completePickidsearchController.text.trim().toLowerCase();
    // print("originalTableDataaaa $CompletedoriginalTableData");
    print("searchText: $searchText");

    setState(() {
      if (searchText.isEmpty) {
        // Show all rows if search is empty
        CompletedtableData =
            List<Map<String, dynamic>>.from(CompletedoriginalTableData);
      } else {
        CompletedtableData = CompletedoriginalTableData.where((data) {
          // Get the pickidlist and convert it to a list of trimmed, lowercased values
          List<String> pickIds = data['pickidlist']
              .toString()
              .split(',')
              .map((id) => id.trim().toLowerCase())
              .toList();

          // Return true if any pickId contains the searchText (partial match)
          return pickIds.any((pickId) => pickId.contains(searchText));
        }).toList();
      }
    });

    // print("tableDataaaaaaaaaa $tableData");
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
                                  Icons.pending,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'PickMan Pending',
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

                DefaultTabController(
                  length: 2,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 5, right: 5, bottom: 5),
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
                          // Tab Bar
                          const TabBar(
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey,
                            tabs: [
                              Tab(text: "Pending Pick"),
                              Tab(text: "Completed Pick"),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                /// ---------- Pending Pick Tab ----------
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        if (saveloginrole ==
                                            'WHR SuperUser') ...[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 16, left: 25, bottom: 0),
                                            child: SizedBox(
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? 180
                                                      : 130,
                                              height: 33,
                                              child: TextField(
                                                controller: RwqNoController,
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: 'Enter Request No',
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 10),
                                                ),
                                                onChanged: (value) => _search(),
                                                style: textBoxstyle,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 16, left: 25, bottom: 0),
                                            child: SizedBox(
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? 180
                                                      : 130,
                                              height: 33,
                                              child: TextField(
                                                controller:
                                                    PickidsearchController,
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: 'Enter Pick Id',
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 10),
                                                ),
                                                onChanged: (value) =>
                                                    _pickidsearch(),
                                                style: textBoxstyle,
                                              ),
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    _buildTable(), // show pending data
                                  ],
                                ),

                                /// ---------- Finished Pick Tab ----------
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        if (saveloginrole ==
                                            'WHR SuperUser') ...[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 16, left: 25, bottom: 0),
                                            child: SizedBox(
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? 180
                                                      : 130,
                                              height: 33,
                                              child: TextField(
                                                controller:
                                                    completeRwqNoController,
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: 'Enter Request No',
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 10),
                                                ),
                                                onChanged: (value) =>
                                                    _Completedpicksearch(),
                                                style: textBoxstyle,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 16, left: 25, bottom: 0),
                                            child: SizedBox(
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? 180
                                                      : 130,
                                              height: 33,
                                              child: TextField(
                                                controller:
                                                    completePickidsearchController,
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: 'Enter Pick id',
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 10),
                                                ),
                                                onChanged: (value) =>
                                                    _completedpickidsearch(),
                                                style: textBoxstyle,
                                              ),
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Padding(
                                      padding: EdgeInsets.only(left: 30),
                                      child: _builCompleteddTable(),
                                    ), // show pending data
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Padding(
                //   padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                //   child: Container(
                //     height: screenheight * 0.89,
                //     width: MediaQuery.of(context).size.width,
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       border: Border.all(
                //         color: Colors.grey[400]!,
                //         width: 1.0,
                //       ),
                //     ),
                //     child: Column(
                //       children: [
                //         Row(
                //           children: [
                //             if (saveloginrole == 'WHR SuperUser') ...[
                //               Padding(
                //                 padding: const EdgeInsets.only(
                //                     top: 16, left: 25, bottom: 0),
                //                 child: SizedBox(
                //                   width:
                //                       Responsive.isDesktop(context) ? 180 : 130,
                //                   height: 33,
                //                   child: TextField(
                //                     controller: RwqNoController,
                //                     decoration: const InputDecoration(
                //                       hintText: 'Enter Request No',
                //                       border: OutlineInputBorder(),
                //                       contentPadding:
                //                           EdgeInsets.symmetric(horizontal: 10),
                //                     ),
                //                     onChanged: (value) => _search(),
                //                     style: textBoxstyle,
                //                   ),
                //                 ),
                //               ),
                //             ]
                //           ],
                //         ),
                //         SizedBox(
                //           height: 20,
                //         ),
                //         _buildTable()
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> tableData = [];

  List<Map<String, dynamic>> CompletedtableData = [];

  bool _isLoading = false;

  bool _completedisLoading = false;
  // Future<void> fetchDispatchData() async {
  //   Map<String, Map<String, dynamic>> uniqueData = {};

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? saleslogiOrgid = prefs.getString('saleslogiOrgwarehousename') ?? '';

  //   try {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     final IpAddress = await getActiveIpAddress();

  //     final url = Uri.parse('$IpAddress/filteredPendingdispatch_request_list/');
  //     final response = await http.get(url);
  //     print("urlsssssssssss$IpAddress/filteredPendingdispatch_request_list/");

  //     if (response.statusCode == 200) {
  //       final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
  //       // final responseData = json.decode(decodedBody);

  //       final data = jsonDecode(decodedBody) as List;

  //       // for (var item in data) {
  //       //   String reqNo = item['REQ_ID'].toString();
  //       //   String toWarehouse = item['TO_WAREHOUSE'].toString();
  //       //   double orgId = double.tryParse(item['ORG_ID'].toString()) ?? 0.0;
  //       //   String orgName = item['ORG_NAME'].toString();
  //       //   String invoiceNumber = item['INVOICE_NUMBER'].toString();

  //       //   String customerno = item['CUSTOMER_NUMBER'].toString();
  //       //   String customername = item['CUSTOMER_NAME'].toString();
  //       //   String customersiteid = item['CUSTOMER_SITE_ID'].toString();
  //       //   String salesmanNo = item['SALESMAN_NO'].toString();
  //       //   String salesmanName = item['SALESMAN_NAME'].toString();
  //       //   double invoiceQty =
  //       //       double.tryParse(item['TOT_QUANTITY'].toString()) ?? 0.0;
  //       //   double pickedQty =
  //       //       double.tryParse(item['DISPATCHED_QTY'].toString()) ?? 0.0;
  //       //   String status = item['STATUS'].toString();

  //       //   uniqueData[reqNo] = {
  //       //     "REQ_ID": reqNo,
  //       //     "TO_WAREHOUSE": toWarehouse,
  //       //     "ORG_ID": orgId,
  //       //     "ORG_NAME": orgName,
  //       //     "INVOICE_NUMBER": invoiceNumber,
  //       //     "CUSTOMER_NUMBER": customerno,
  //       //     "CUSTOMER_NAME": customername,
  //       //     "CUSTOMER_SITE_ID": customersiteid,
  //       //     "SALESMAN_NO": salesmanNo,
  //       //     "SALESMAN_NAME": salesmanName,
  //       //     "TOT_QUANTITY": invoiceQty,
  //       //     "DISPATCHED_QTY": pickedQty,
  //       //     "STATUS": status,
  //       //   };
  //       // }

  //       for (var item in data) {
  //         if (item['PHYSICAL_WAREHOUSE'].toString() == saleslogiOrgid) {
  //           String reqNo = item['REQ_ID'].toString();
  //           String toWarehouse = item['TO_WAREHOUSE'].toString();
  //           double orgId = double.tryParse(item['ORG_ID'].toString()) ?? 0.0;
  //           String orgName = item['ORG_NAME'].toString();
  //           String invoiceNumber = item['INVOICE_NUMBER'].toString();

  //           String customerno = item['CUSTOMER_NUMBER'].toString();
  //           String customername = item['CUSTOMER_NAME'].toString();
  //           String customersiteid = item['CUSTOMER_SITE_ID'].toString();
  //           String salesmanNo = item['SALESMAN_NO'].toString();
  //           String salesmanName = item['SALESMAN_NAME'].toString();
  //           double invoiceQty =
  //               double.tryParse(item['TOT_QUANTITY'].toString()) ?? 0.0;
  //           double pickedQty =
  //               double.tryParse(item['DISPATCHED_QTY'].toString()) ?? 0.0;
  //           String status = item['STATUS'].toString();
  //           String pickidlist = item['PICK_IDS'].toString();

  //           String key = "$reqNo|$customerno|$customersiteid"; // Unique key

  //           double dispatchedQty =
  //               double.tryParse(item['DISPATCHED_QTY'].toString()) ?? 0.0;

  //           if (uniqueData.containsKey(key)) {
  //             uniqueData[key]!['DISPATCHED_QTY'] +=
  //                 dispatchedQty; // Sum DISPATCHED_QTY
  //           } else {
  //             uniqueData[key] = {
  //               "REQ_ID": reqNo,
  //               "TO_WAREHOUSE": toWarehouse,
  //               "ORG_ID": orgId,
  //               "ORG_NAME": orgName,
  //               "INVOICE_NUMBER": invoiceNumber,
  //               "CUSTOMER_NUMBER": customerno,
  //               "CUSTOMER_NAME": customername,
  //               "CUSTOMER_SITE_ID": customersiteid,
  //               "SALESMAN_NO": salesmanNo,
  //               "SALESMAN_NAME": salesmanName,
  //               "TOT_QUANTITY": invoiceQty,
  //               "DISPATCHED_QTY": dispatchedQty,
  //               "STATUS": status,
  //               "pickidlist": pickidlist,
  //             };
  //           }
  //         }
  //       }
  //       //  uniqueData[key]!['DISPATCHED_QTY'] += dispatchedQty;
  //       //     uniqueData[reqNo] = {
  //       //       "REQ_ID": reqNo,
  //       //       "TO_WAREHOUSE": toWarehouse,
  //       //       "ORG_ID": orgId,
  //       //       "ORG_NAME": orgName,
  //       //       "INVOICE_NUMBER": invoiceNumber,
  //       //       "CUSTOMER_NUMBER": customerno,
  //       //       "CUSTOMER_NAME": customername,
  //       //       "CUSTOMER_SITE_ID": customersiteid,
  //       //       "SALESMAN_NO": salesmanNo,
  //       //       "SALESMAN_NAME": salesmanName,
  //       //       "TOT_QUANTITY": invoiceQty,
  //       //       "DISPATCHED_QTY": pickedQty,
  //       //       "STATUS": status,
  //       //     };
  //       //   }
  //       // }
  //       setState(() {
  //         originalTableData = uniqueData.values.toList(); // store original data

  //         tableData = uniqueData.values.toList();
  //       });
  //     } else {
  //       print('Failed to load data: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  String? nextPageUrl;
  Future<void> fetchDispatchData() async {
    if (_isLoading) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String saleslogiOrgid = prefs.getString('saleslogiOrgwarehousename') ?? '';

    setState(() {
      _isLoading = true;
    });

    Map<String, Map<String, dynamic>> allUniqueData = {};
    String? nextPageUrl;

    try {
      final ip = await getActiveIpAddress();
      nextPageUrl = '$ip/filteredPendingdispatch_request_list/';

      while (nextPageUrl != null) {
        final response = await http.get(Uri.parse(nextPageUrl));
        print('Fetching page ◾ $nextPageUrl');

        if (response.statusCode != 200) {
          print('Failed to load: ${response.statusCode}');
          break;
        }

        final decoded = utf8.decode(response.bodyBytes);
        final resp = jsonDecode(decoded);
        final data = resp['results'] as List;
        nextPageUrl = resp['next']; // update the URL for next page

        for (var item in data) {
          if (item['PHYSICAL_WAREHOUSE'].toString() == saleslogiOrgid) {
            String reqNo = item['REQ_ID'].toString();
            double dispatchedQty =
                double.tryParse(item['DISPATCHED_QTY'].toString()) ?? 0.0;
            String key =
                '$reqNo|${item['CUSTOMER_NUMBER']}|${item['CUSTOMER_SITE_ID']}';

            if (allUniqueData.containsKey(key)) {
              allUniqueData[key]!['DISPATCHED_QTY'] += dispatchedQty;
            } else {
              allUniqueData[key] = {
                "REQ_ID": reqNo,
                "PHYSICAL_WAREHOUSE": item['PHYSICAL_WAREHOUSE'],
                "ORG_ID": item['ORG_ID'],
                "ORG_NAME": item['ORG_NAME'],
                "INVOICE_NUMBER": item['INVOICE_NUMBER'],
                "CUSTOMER_NUMBER": item['CUSTOMER_NUMBER'],
                "CUSTOMER_NAME": item['CUSTOMER_NAME'],
                "CUSTOMER_SITE_ID": item['CUSTOMER_SITE_ID'],
                "SALESMAN_NO": item['SALESMAN_NO'],
                "SALESMAN_NAME": item['SALESMAN_NAME'],
                "TOT_QUANTITY":
                    double.tryParse(item['TOT_QUANTITY'].toString()) ?? 0.0,
                "DISPATCHED_QTY": dispatchedQty,
                "STATUS": item['STATUS'],
                "PICK_IDS": item['PICK_IDS'],
              };
            }
          }
        }
      }

      setState(() {
        originalTableData = allUniqueData.values.toList();
        tableData = allUniqueData.values.toList();
      });
      print('✅ Total fetched records: ${tableData.length}');
    } catch (e) {
      print('Error fetching dispatch data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? completedNextPageUrl;
  Future<void> fetchCompletedDispatchData() async {
    if (_completedisLoading) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgid = prefs.getString('saleslogiOrgwarehousename') ?? '';

    setState(() {
      _completedisLoading = true;
    });

    Map<String, Map<String, dynamic>> allUniqueData = {};
    String? nextPageUrl;

    try {
      final ipAddress = await getActiveIpAddress();
      nextPageUrl = '$ipAddress/filteredCompletedDispatch_request_list/';

      while (nextPageUrl != null) {
        final response = await http.get(Uri.parse(nextPageUrl!));
        print("Fetching page: $nextPageUrl");

        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes);
          final responseData = jsonDecode(decodedBody);

          final data = responseData['results'] as List;
          nextPageUrl = responseData['next']; // update to next page url

          for (var item in data) {
            if (item['PHYSICAL_WAREHOUSE'].toString() == saleslogiOrgid) {
              String reqNo = item['REQ_ID'].toString();
              String toWarehouse = item['PHYSICAL_WAREHOUSE'].toString();
              double orgId = double.tryParse(item['ORG_ID'].toString()) ?? 0.0;
              String orgName = item['ORG_NAME'].toString();
              String invoiceNumber = item['INVOICE_NUMBER'].toString();

              String customerno = item['CUSTOMER_NUMBER'].toString();
              String customername = item['CUSTOMER_NAME'].toString();
              String customersiteid = item['CUSTOMER_SITE_ID'].toString();
              String salesmanNo = item['SALESMAN_NO'].toString();
              String salesmanName = item['SALESMAN_NAME'].toString();
              double invoiceQty =
                  double.tryParse(item['TOT_QUANTITY'].toString()) ?? 0.0;

              String pickidlist = item['PICK_IDS'].toString();
              String status = item['STATUS'].toString();

              String key = "$reqNo|$customerno|$customersiteid";

              double dispatchedQty =
                  double.tryParse(item['DISPATCHED_QTY'].toString()) ?? 0.0;

              if (allUniqueData.containsKey(key)) {
                allUniqueData[key]!['DISPATCHED_QTY'] += dispatchedQty;
              } else {
                allUniqueData[key] = {
                  "REQ_ID": reqNo,
                  "TO_WAREHOUSE": toWarehouse,
                  "ORG_ID": orgId,
                  "ORG_NAME": orgName,
                  "INVOICE_NUMBER": invoiceNumber,
                  "CUSTOMER_NUMBER": customerno,
                  "CUSTOMER_NAME": customername,
                  "CUSTOMER_SITE_ID": customersiteid,
                  "SALESMAN_NO": salesmanNo,
                  "SALESMAN_NAME": salesmanName,
                  "TOT_QUANTITY": invoiceQty,
                  "DISPATCHED_QTY": dispatchedQty,
                  "STATUS": status,
                  "pickidlist": pickidlist,
                };
              }
            }
          }
        } else {
          print('Failed to load data: ${response.statusCode}');
          break; // stop if any error occurs
        }
      }

      setState(() {
        CompletedoriginalTableData = allUniqueData.values.toList();
        CompletedtableData = allUniqueData.values.toList();
      });

      print('✅ Total records fetched: ${CompletedtableData.length}');
    } catch (e) {
      print('❌ Error fetching completed dispatch data: $e');
    } finally {
      setState(() {
        _completedisLoading = false;
      });
    }
  }

  // Future<void> fetchCompletedDispatchData() async {
  //   Map<String, Map<String, dynamic>> uniqueData = {};

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? saleslogiOrgid = prefs.getString('saleslogiOrgwarehousename') ?? '';

  //   try {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     final IpAddress = await getActiveIpAddress();

  //     final url =
  //         Uri.parse('$IpAddress/filteredCompletedDispatch_request_list/');
  //     final response = await http.get(url);
  //     print("urlsssssssssss$IpAddress/filteredCompletedDispatch_request_list/");

  //     if (response.statusCode == 200) {
  //       final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
  //       // final responseData = json.decode(decodedBody);

  //       final data = jsonDecode(decodedBody) as List;
  //       for (var item in data) {
  //         if (item['PHYSICAL_WAREHOUSE'].toString() == saleslogiOrgid) {
  //           String reqNo = item['REQ_ID'].toString();
  //           String toWarehouse = item['TO_WAREHOUSE'].toString();
  //           double orgId = double.tryParse(item['ORG_ID'].toString()) ?? 0.0;
  //           String orgName = item['ORG_NAME'].toString();
  //           String invoiceNumber = item['INVOICE_NUMBER'].toString();

  //           String customerno = item['CUSTOMER_NUMBER'].toString();
  //           String customername = item['CUSTOMER_NAME'].toString();
  //           String customersiteid = item['CUSTOMER_SITE_ID'].toString();
  //           String salesmanNo = item['SALESMAN_NO'].toString();
  //           String salesmanName = item['SALESMAN_NAME'].toString();
  //           double invoiceQty =
  //               double.tryParse(item['TOT_QUANTITY'].toString()) ?? 0.0;

  //           String pickidlist = item['PICK_IDS'].toString();
  //           String status = item['STATUS'].toString();

  //           String key = "$reqNo|$customerno|$customersiteid"; // Unique key

  //           double dispatchedQty =
  //               double.tryParse(item['DISPATCHED_QTY'].toString()) ?? 0.0;

  //           if (uniqueData.containsKey(key)) {
  //             uniqueData[key]!['DISPATCHED_QTY'] +=
  //                 dispatchedQty; // Sum DISPATCHED_QTY
  //           } else {
  //             uniqueData[key] = {
  //               "REQ_ID": reqNo,
  //               "TO_WAREHOUSE": toWarehouse,
  //               "ORG_ID": orgId,
  //               "ORG_NAME": orgName,
  //               "INVOICE_NUMBER": invoiceNumber,
  //               "CUSTOMER_NUMBER": customerno,
  //               "CUSTOMER_NAME": customername,
  //               "CUSTOMER_SITE_ID": customersiteid,
  //               "SALESMAN_NO": salesmanNo,
  //               "SALESMAN_NAME": salesmanName,
  //               "TOT_QUANTITY": invoiceQty,
  //               "DISPATCHED_QTY": dispatchedQty,
  //               "STATUS": status,
  //               "pickidlist": pickidlist,
  //             };
  //           }
  //         }
  //       }

  //       setState(() {
  //         CompletedoriginalTableData =
  //             List<Map<String, dynamic>>.from(data); // store original data

  //         CompletedtableData = uniqueData.values.toList();
  //       });
  //     } else {
  //       print('Failed to load data: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }
// Add these to your state class
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  int get _totalPages => (CompletedtableData.length / _itemsPerPage).ceil();

  List<dynamic> _getCurrentPageItems() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    if (startIndex >= CompletedtableData.length) return [];
    final endIndex = min(startIndex + _itemsPerPage, CompletedtableData.length);
    return CompletedtableData.sublist(startIndex, endIndex);
  }

  int _pendingcurrentPage = 1;
  final int _pendingitemsPerPage = 10;
  int get _pendingtotalPages => (tableData.length / _itemsPerPage).ceil();

  List<dynamic> _getCurrentPageItemspending() {
    final startIndex = (_pendingcurrentPage - 1) * _pendingitemsPerPage;
    if (startIndex >= tableData.length) return [];
    final endIndex = min(startIndex + _pendingitemsPerPage, tableData.length);
    return tableData.sublist(startIndex, endIndex);
  }

// Modern table header widget
  Widget _modernTableHeader(String text, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.blueGrey[50],
          border: Border(
            right: BorderSide(color: Colors.grey[200]!),
            bottom: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.blueGrey),
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Modern table row widget
  Widget _modernTableRow(String text, Color bgColor, {String? tooltipMessage}) {
    return Expanded(
      child: Tooltip(
        message: tooltipMessage ?? text,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              right: BorderSide(color: Colors.grey[200]!),
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[800],
            ),
          ),
        ),
      ),
    );
  }

  Widget _builCompleteddTable() {
    bool isDialogOpen = false; // Track if dialog is already opened

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
                height: MediaQuery.of(context).size.height * 0.7,
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.8
                    : MediaQuery.of(context).size.width * 1.2,
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _verticalScrollController,
                  child: SingleChildScrollView(
                      controller: _verticalScrollController,
                      child: Column(
                        children: [
                          // Modern Table Header
                          Row(
                            children: [
                              _modernTableHeader(
                                  "S.No", Icons.format_list_numbered),
                              _modernTableHeader("Req No", Icons.numbers),
                              _modernTableHeader("Customer", Icons.person),
                              _modernTableHeader("Pick ID", Icons.list_alt),
                              _modernTableHeader(
                                  "Qty", Icons.format_list_numbered_rtl),
                            ],
                          ),

                          // Loading or Content
                          if (_completedisLoading)
                            Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (CompletedtableData.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: Text(
                                "No data available",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          else
                            ..._getCurrentPageItems()
                                .asMap()
                                .entries
                                .map((entry) {
                              final index = entry.key;
                              final data = entry.value;
                              final actualIndex =
                                  (_currentPage - 1) * _itemsPerPage + index;
                              final bgColor = index % 2 == 0
                                  ? Colors.white
                                  : Colors.grey[50]!;

                              return GestureDetector(
                                onDoubleTap: () async {
                                  if (isDialogOpen) return;
                                  setState(() => isDialogOpen = true);

                                  await fetchPickmanCompletedData(
                                      data['REQ_ID']);

                                  showDialog(
                                    context: context,
                                    builder: (_) =>
                                        pending_pickmandetailsdialogbox(context,
                                            data['REQ_ID'], 'Completed'),
                                  ).then((_) =>
                                      setState(() => isDialogOpen = false));

                                  postLogData("PickMan View", "Details opened");
                                },
                                child: Row(
                                  children: [
                                    _modernTableRow(
                                        (actualIndex + 1).toString(), bgColor),
                                    _modernTableRow(
                                        data['REQ_ID'].toString(), bgColor),
                                    _modernTableRow(
                                      data['CUSTOMER_NUMBER'].toString(),
                                      bgColor,
                                      tooltipMessage:
                                          data['CUSTOMER_NAME'].toString(),
                                    ),
                                    _modernTableRow(
                                        data['pickidlist'].toString(), bgColor),
                                    _modernTableRow(
                                        data['DISPATCHED_QTY'].toString(),
                                        bgColor),
                                  ],
                                ),
                              );
                            }),

                          // Enhanced Pagination
                          if (CompletedtableData.isNotEmpty &&
                              !_completedisLoading)
                            Container(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // First Page
                                  IconButton(
                                    icon: Icon(Icons.first_page),
                                    onPressed: _currentPage > 1
                                        ? () => setState(() => _currentPage = 1)
                                        : null,
                                  ),

                                  // Previous Page
                                  IconButton(
                                    icon: Icon(Icons.chevron_left),
                                    onPressed: _currentPage > 1
                                        ? () => setState(() => _currentPage--)
                                        : null,
                                  ),

                                  // Page Info
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Page $_currentPage of $_totalPages',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),

                                  // Next Page
                                  IconButton(
                                    icon: Icon(Icons.chevron_right),
                                    onPressed: _currentPage < _totalPages
                                        ? () => setState(() => _currentPage++)
                                        : null,
                                  ),

                                  // Last Page
                                  IconButton(
                                    icon: Icon(Icons.last_page),
                                    onPressed: _currentPage < _totalPages
                                        ? () => setState(
                                            () => _currentPage = _totalPages)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildTable() {
  //   bool isDialogOpen = false; // Track if dialog is already opened

  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     child: Scrollbar(
  //       thumbVisibility: true,
  //       controller: _horizontalScrollController,
  //       child: SingleChildScrollView(
  //         controller: _horizontalScrollController,
  //         scrollDirection: Axis.horizontal,
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Container(
  //               color: Colors.white,
  //               height: MediaQuery.of(context).size.height * 0.7,
  //               width: Responsive.isDesktop(context)
  //                   ? MediaQuery.of(context).size.width * 0.8
  //                   : MediaQuery.of(context).size.width * 1.2,
  //               child: Scrollbar(
  //                 thumbVisibility: true,
  //                 controller: _verticalScrollController,
  //                 child: SingleChildScrollView(
  //                   controller: _verticalScrollController,
  //                   child: Column(
  //                     children: [
  //                       // Table Header
  //                       Padding(
  //                         padding: const EdgeInsets.symmetric(
  //                             horizontal: 10, vertical: 13),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: [
  //                             _tableHeader("S.No", Icons.format_list_numbered),
  //                             _tableHeader("Req No", Icons.print),
  //                             _tableHeader("Customer No", Icons.account_circle),
  //                             // _tableHeader("Invoice No", Icons.person),
  //                             _tableHeader("Pick id", Icons.list),
  //                             _tableHeader("Tot.Req.Qty", Icons.list),
  //                           ],
  //                         ),
  //                       ),
  //                       // Loading Indicator or Table Rows
  //                       if (_isLoading)
  //                         Padding(
  //                           padding: const EdgeInsets.only(top: 100.0),
  //                           child: Center(child: CircularProgressIndicator()),
  //                         )
  //                       else if (tableData.isNotEmpty)
  //                         ...tableData.asMap().entries.map((entry) {
  //                           int index = entry.key;
  //                           var data = entry.value;

  //                           String sNo = (index + 1).toString();
  //                           String reqNo = "${data['REQ_ID'].toString()}";
  //                           String customerno =
  //                               data['CUSTOMER_NUMBER'].toString();
  //                           String customername =
  //                               "${data['CUSTOMER_NAME'].toString()}";
  //                           String customersiteid =
  //                               data['CUSTOMER_SITE_ID'].toString();
  //                           String salesmanName =
  //                               data['INVOICE_NUMBER'].toString();
  //                           String invoiceQty = data['TOT_QUANTITY'].toString();
  //                           String pickidlist = data['pickidlist'].toString();
  //                           String dispatchedQty =
  //                               data['DISPATCHED_QTY'].toString();

  //                           bool isEvenRow = index % 2 == 0;
  //                           Color rowColor = isEvenRow
  //                               ? Color.fromARGB(224, 255, 255, 255)
  //                               : Color.fromARGB(224, 255, 255, 255);

  //                           return Padding(
  //                               padding:
  //                                   const EdgeInsets.symmetric(horizontal: 10),
  //                               child: GestureDetector(
  //                                 onDoubleTap: () async {
  //                                   // If dialog is already open, return early
  //                                   if (isDialogOpen) return;

  //                                   setState(() {
  //                                     isDialogOpen =
  //                                         true; // Lock the interaction
  //                                   });

  //                                   // Fetch data and show dialog
  //                                   await fetchPickmanData(data['REQ_ID']);

  //                                   // Show the dialog
  //                                   showDialog(
  //                                     context: context,
  //                                     barrierDismissible: false,
  //                                     builder: (BuildContext context) {
  //                                       return pending_pickmandetailsdialogbox(
  //                                           context, data['REQ_ID'], 'pending');
  //                                     },
  //                                   ).then((_) {
  //                                     setState(() {
  //                                       isDialogOpen =
  //                                           false; // Allow interaction again once dialog is closed
  //                                     });
  //                                   });

  //                                   postLogData("PickMan Pending View",
  //                                       "Details View Pop open");
  //                                 },
  //                                 child: Row(
  //                                   mainAxisAlignment: MainAxisAlignment.center,
  //                                   children: [
  //                                     _tableRow(sNo, rowColor),
  //                                     _tableRow(reqNo, rowColor),
  //                                     _tableRow(customerno, rowColor,
  //                                         tooltipMessage: customername),

  //                                     _tableRow(pickidlist, rowColor),
  //                                     // _tableRow(invoiceQty, rowColor),
  //                                     _tableRow(dispatchedQty, rowColor),
  //                                   ],
  //                                 ),
  //                               ));
  //                         }).toList()
  //                       else
  //                         Padding(
  //                           padding: const EdgeInsets.only(top: 100.0),
  //                           child: Text("No pickman pending data founded.."),
  //                         ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildTable() {
    bool isDialogOpen = false; // Track if dialog is already opened

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
                height: MediaQuery.of(context).size.height * 0.7,
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.8
                    : MediaQuery.of(context).size.width * 1.2,
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _verticalScrollController,
                  child: SingleChildScrollView(
                      controller: _verticalScrollController,
                      child: Column(
                        children: [
                          // Modern Table Header
                          Row(
                            children: [
                              _modernTableHeader(
                                  "S.No", Icons.format_list_numbered),
                              _modernTableHeader("Req No", Icons.numbers),
                              _modernTableHeader("Customer", Icons.person),
                              _modernTableHeader("Pick ID", Icons.list_alt),
                              _modernTableHeader(
                                  "Qty", Icons.format_list_numbered_rtl),
                            ],
                          ),

                          // Loading or Content
                          if (_isLoading)
                            Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (tableData.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: Text(
                                "No data available",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          else
                            ..._getCurrentPageItemspending()
                                .asMap()
                                .entries
                                .map((entry) {
                              final index = entry.key;
                              final data = entry.value;
                              final actualIndex = (_pendingcurrentPage - 1) *
                                      _pendingitemsPerPage +
                                  index;
                              final bgColor = index % 2 == 0
                                  ? Colors.white
                                  : Colors.grey[50]!;

                              return GestureDetector(
                                onDoubleTap: () async {
                                  if (isDialogOpen) return;
                                  setState(() => isDialogOpen = true);

                                  await fetchPickmanData(data['REQ_ID']);

                                  showDialog(
                                    context: context,
                                    builder: (_) =>
                                        pending_pickmandetailsdialogbox(
                                            context, data['REQ_ID'], 'pending'),
                                  ).then((_) =>
                                      setState(() => isDialogOpen = false));

                                  postLogData("PickMan View", "Details opened");
                                },
                                child: Row(
                                  children: [
                                    _modernTableRow(
                                        (actualIndex + 1).toString(), bgColor),
                                    _modernTableRow(
                                        data['REQ_ID'].toString(), bgColor),
                                    _modernTableRow(
                                      data['CUSTOMER_NUMBER'].toString(),
                                      bgColor,
                                      tooltipMessage:
                                          data['CUSTOMER_NAME'].toString(),
                                    ),
                                    _modernTableRow(
                                        data['PICK_IDS'].toString(), bgColor),
                                    _modernTableRow(
                                        data['DISPATCHED_QTY'].toString(),
                                        bgColor),
                                  ],
                                ),
                              );
                            }),

                          // Enhanced Pagination
                          if (tableData.isNotEmpty && !_isLoading)
                            Container(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // First Page
                                  IconButton(
                                    icon: Icon(Icons.first_page),
                                    onPressed: _pendingcurrentPage > 1
                                        ? () => setState(
                                            () => _pendingcurrentPage = 1)
                                        : null,
                                  ),

                                  // Previous Page
                                  IconButton(
                                    icon: Icon(Icons.chevron_left),
                                    onPressed: _pendingcurrentPage > 1
                                        ? () => setState(
                                            () => _pendingcurrentPage--)
                                        : null,
                                  ),

                                  // Page Info
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Page $_pendingcurrentPage of $_pendingtotalPages',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),

                                  // Next Page
                                  IconButton(
                                    icon: Icon(Icons.chevron_right),
                                    onPressed:
                                        _pendingcurrentPage < _pendingtotalPages
                                            ? () => setState(
                                                () => _pendingcurrentPage++)
                                            : null,
                                  ),

                                  // Last Page
                                  IconButton(
                                    icon: Icon(Icons.last_page),
                                    onPressed:
                                        _pendingcurrentPage < _pendingtotalPages
                                            ? () => setState(() =>
                                                _pendingcurrentPage =
                                                    _pendingtotalPages)
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableHeader(String text, IconData icon) {
    return Expanded(
      child: Container(
        height: Responsive.isDesktop(context) ? 25 : 30,
        decoration: TableHeaderColor,
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.start, // Aligns items to the start
          crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
          children: [
            Icon(icon, size: 15, color: Colors.blue),
            SizedBox(width: 2),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.left, // Align text to the start (left)
                style: commonLabelTextStyle,
                overflow: TextOverflow.ellipsis, // Avoid overflow
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableItemDescriptiodetailsRow(String data, Color? rowColor,
      {String? tooltipMessage}) {
    return Container(
      height: 30,
      width: 550,
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

  Widget _tableItemDescRow(String data, Color? rowColor,
      {String? tooltipMessage}) {
    return Container(
      height: 30,
      width: 300,
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

  Widget _tablepickidHeader(String text, IconData icon) {
    return Container(
      height: Responsive.isDesktop(context) ? 25 : 30,
      width: 120,
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
      width: 300,
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

  Widget _tableItemDescdetailsHeader(String text, IconData icon) {
    return Container(
      height: Responsive.isDesktop(context) ? 25 : 30,
      width: 550,
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
    return Expanded(
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: rowColor,
          border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.start, // Aligns items to the start
          crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
          children: [
            Expanded(
              child: tooltipMessage != null
                  ? Tooltip(
                      message: tooltipMessage,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
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
                        //  Text(
                        //   data,
                        //   textAlign: TextAlign.left, // Align text to the start
                        //   style: TableRowTextStyle,
                        //   overflow: TextOverflow.ellipsis,
                        // ),
                      ),
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

  Widget pending_pickmandetailsdialogbox(
      BuildContext context, String reqNo, String StatusString) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      child: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            width: Responsive.isDesktop(context) ? screenWidth * 0.6 : 600,
            height: Responsive.isDesktop(context) ? 550 : 500,
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
                        "Pickman pending Pop-Up",
                        style: TextStyle(
                          fontSize: 15,
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
                                                  // hintText: label,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.zero,
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10.0,
                                                          horizontal: 10.0),
                                                  filled: true,
                                                  fillColor: Color.fromARGB(
                                                      255, 255, 255, 255),
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
                                                  // hintText: label,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.zero,
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10.0,
                                                          horizontal: 10.0),
                                                  filled: true,
                                                  fillColor: Color.fromARGB(
                                                      255, 255, 255, 255),
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
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 15,
                          ),
                          child: Container(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Viewtabledata(StatusString),
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

  TextEditingController pickIdController = TextEditingController();
  TextEditingController pickmanNameController = TextEditingController();

  Widget pending_pickmandetailsdetailsbox(BuildContext context, String reqNo) {
    // STEP 2: Extract values if data exists
    if (filteredprintdatas.isNotEmpty) {
      var firstData =
          filteredprintdatas[0]; // You can use another index if needed
      pickIdController.text = firstData['PICK_ID']?.toString() ?? '';
      pickmanNameController.text =
          firstData['ASSIGN_PICKMAN']?.toString() ?? '';
    }
    double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      child: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            width: Responsive.isDesktop(context) ? screenWidth * 0.6 : 600,
            height: Responsive.isDesktop(context) ? 500 : 500,
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
                        "Pickman pending Details",
                        style: TextStyle(
                          fontSize: 15,
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
                                    Text("Pick Id", style: textboxheading),
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
                                                  "${pickIdController.text}",
                                              child: TextFormField(
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  // hintText: label,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.zero,
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10.0,
                                                          horizontal: 10.0),
                                                  filled: true,
                                                  fillColor: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                ),
                                                controller: pickIdController,
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
                                    Text("Assigned Pickman",
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
                                                  "${pickmanNameController.text}",
                                              child: TextFormField(
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  // hintText: label,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.zero,
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10.0,
                                                          horizontal: 10.0),
                                                  filled: true,
                                                  fillColor: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                ),
                                                controller:
                                                    pickmanNameController,
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
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 15,
                          ),
                          child: Container(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: pickdetailsViewtabledata(),
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

  List<Map<String, dynamic>> filteredprintdatas = [];

  Future<void> fetchAndFilterData(String reqno, String pickid) async {
    try {
      final IpAddress = await getActiveIpAddress();
      final String url = "$IpAddress/filteredpendingpickman/$reqno/pending/";
      final String targetPickId = pickid;
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
        final List<dynamic> jsonData = jsonDecode(decodedBody);

        // Filter only the entries with the specific PICK_ID
        final List<Map<String, dynamic>> matchingData = jsonData
            .where((item) => item['PICK_ID'].toString() == targetPickId)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        setState(() {
          filteredprintdatas = matchingData;
          print("filteredprintdatas  $filteredprintdatas");
        });
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> fetchAndCompletedFilterData(String reqno, String pickid) async {
    try {
      final IpAddress = await getActiveIpAddress();
      final String url = "$IpAddress/filteredCompletedpickman/$reqno/";
      final String targetPickId = pickid;
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
        final List<dynamic> jsonData = jsonDecode(decodedBody);

        // Filter only the entries with the specific PICK_ID
        final List<Map<String, dynamic>> matchingData = jsonData
            .where((item) => item['PICK_ID'].toString() == targetPickId)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        setState(() {
          filteredprintdatas = matchingData;
          print("filteredprintdatascompleted  $filteredprintdatas");
        });
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  TextEditingController customerNameController = TextEditingController();
  TextEditingController customerNoController = TextEditingController();
  TextEditingController customerSiteidController = TextEditingController();

  Future<void> fetchPickmanCompletedData(String reqno) async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/filteredCompletedpickman/$reqno/';
    print("Fetching data from URL: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');

        // Decode the JSON response
        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
        // final responseData = json.decode(decodedBody);

        final List<dynamic> data = json.decode(decodedBody);

        // Safely cast the list to List<Map<String, dynamic>>
        if (data.isNotEmpty) {
          setState(() {
            viewtableData = List<Map<String, dynamic>>.from(data);
            _isLoading = false;

            // Access the first item in the list for controllers
            customerNoController.text =
                viewtableData[0]['CUSTOMER_NUMBER']?.toString() ?? 'N/A';
            customerNameController.text =
                viewtableData[0]['CUSTOMER_NAME']?.toString() ?? 'N/A';
            customerSiteidController.text =
                viewtableData[0]['CUSTOMER_SITE_ID']?.toString() ?? 'N/A';
          });

          print("customerNoController.text: ${customerNoController.text}");
          print("customerNoController.text: ${customerSiteidController.text}");
        } else {
          setState(() {
            _isLoading = false;
          });
          throw Exception('No results found in the response');
        }
      } else {
        // Handle non-200 status codes
        setState(() {
          _isLoading = false;
        });
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (e is FormatException) {
        print('Invalid JSON format: $e');
      } else if (e is http.ClientException) {
        print('HTTP client error: $e');
      } else {
        print('Unknown error: $e');
      }
    }
  }

  Future<void> fetchPickmanData(String reqno) async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/filteredpendingpickman/$reqno/pending/';
    print("Fetching data from URL: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');

        // Decode the JSON response
        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
        // final responseData = json.decode(decodedBody);

        final List<dynamic> data = json.decode(decodedBody);

        // Safely cast the list to List<Map<String, dynamic>>
        if (data.isNotEmpty) {
          setState(() {
            viewtableData = List<Map<String, dynamic>>.from(data);
            _isLoading = false;

            // Access the first item in the list for controllers
            customerNoController.text =
                viewtableData[0]['CUSTOMER_NUMBER']?.toString() ?? 'N/A';
            customerNameController.text =
                viewtableData[0]['CUSTOMER_NAME']?.toString() ?? 'N/A';
            customerSiteidController.text =
                viewtableData[0]['CUSTOMER_SITE_ID']?.toString() ?? 'N/A';
          });

          print("customerNoController.text: ${customerNoController.text}");
          print("customerNoController.text: ${customerSiteidController.text}");
        } else {
          setState(() {
            _isLoading = false;
          });
          throw Exception('No results found in the response');
        }
      } else {
        // Handle non-200 status codes
        setState(() {
          _isLoading = false;
        });
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (e is FormatException) {
        print('Invalid JSON format: $e');
      } else if (e is http.ClientException) {
        print('HTTP client error: $e');
      } else {
        print('Unknown error: $e');
      }
    }
  }

  TextEditingController deliverAddressController = TextEditingController();
  Future<void> fetchDispatchDetails(String reqNo, String StatusString) async {
    if (StatusString == 'pending') await fetchPickmanData(reqNo);
    if (StatusString == 'Completed') await fetchPickmanCompletedData(reqNo);
    // await fetchPickmanData(reqNo);
    String cusno = customerNoController.text;

    String cussite = customerSiteidController.text.toString();

    final IpAddress = await getActiveIpAddress();

    final url =
        '$IpAddress/FilteredCreateDispatchView/${reqNo}/$cusno/$cussite/';
    print("urlllllllllllllll : $url  ");
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final firstItem = data[0];
          setState(() {
            deliverAddressController.text = firstItem['DELIVERYADDRESS'] ?? '';

            print(
                "deliverAddressController : ${deliverAddressController.text}  ");
          });
        } else {
          // Handle empty data
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No data found for the given details.')),
          );
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching details: $e')),
      );
    }
  }

  // _launchUrl(BuildContext context, String reqNo, String StatusString,
  //     String formattedDate) async {
  //   await fetchDispatchDetails(reqNo, StatusString);
  //   await fetchDispatchDetails(reqNo, StatusString);
  //   print("StatusStringgggg  $StatusString $filteredprintdatas");

  //   List<String> productDetails = [];
  //   int snoCounter = 1;

  //   List<Map<String, dynamic>> mergeTableData(
  //       List<Map<String, dynamic>> filteredprintdatas) {
  //     Map<String, Map<String, dynamic>> mergedData = {};

  //     for (var item in filteredprintdatas) {
  //       String key =
  //           '${item['INVOICE_NUMBER']}-${item['INVENTORY_ITEM_ID']}-${item['ITEM_DESCRIPTION']}';
  //       int currentQty =
  //           int.tryParse(item['TRUCK_SEND_QTY']?.toString() ?? '0') ?? 0;

  //       if (mergedData.containsKey(key)) {
  //         int existingQty =
  //             int.tryParse(mergedData[key]!['sendqty']?.toString() ?? '0') ?? 0;
  //         mergedData[key]!['sendqty'] = existingQty + currentQty;
  //       } else {
  //         mergedData[key] = {
  //           'sno': snoCounter++,
  //           'invoiceno': item['INVOICE_NUMBER'],
  //           'itemcode': item['INVENTORY_ITEM_ID'],
  //           'itemdetails': item['ITEM_DESCRIPTION'],
  //           'sendqty': item['PICKED_QTY'], // use parsed currentQty here
  //         };
  //       }
  //     }

  //     return mergedData.values.toList();
  //   }

  //   List<Map<String, dynamic>> mergedData = mergeTableData(filteredprintdatas);

  //   for (var data in mergedData) {
  //     String formattedProduct =
  //         "{${data['sno']}|${data['invoiceno']}|${data['itemcode']}|${data['itemdetails']}|${data['sendqty']}}";
  //     productDetails.add(formattedProduct);
  //   }
  //   String deliveryaddress = deliverAddressController.text.isNotEmpty
  //       ? deliverAddressController.text
  //       : 'null';

  //   String productDetailsString = productDetails.join(',');
  //   DateTime today = DateTime.now();

  //   if (filteredprintdatas is List && filteredprintdatas.isNotEmpty) {
  //     final item = filteredprintdatas.first;

  //     String uniqulastpcikno = item['PICK_ID'] ?? '';
  //     String region = item['PHYSICAL_WAREHOUSE'] ?? '';
  //     String pickmanname = item['ASSIGN_PICKMAN'] ?? 'null';
  //     String customerno = item['CUSTOMER_NUMBER'] ?? 'null';
  //     String customername = item['CUSTOMER_NAME'] ?? 'null';
  //     String customersite = item['CUSTOMER_SITE_ID'] ?? 'null';

  //     int sendqty = 0;
  //     for (var item in filteredprintdatas) {
  //       int qty = int.tryParse(item['PICKED_QTY']?.toString() ?? '0') ?? 0;
  //       sendqty += qty;
  //     }

  //     print('Total Send Qty: $sendqty');
  //     final IpAddress = await getActiveIpAddress();

  //     String dynamicUrl =
  //         '$IpAddress/Generate_picking_print$parameterdivided$uniqulastpcikno$parameterdivided$reqNo$parameterdivided$region$parameterdivided$pickmanname$parameterdivided$deliveryaddress$parameterdivided$formattedDate$parameterdivided$customerno$parameterdivided$customername$parameterdivided$customersite$parameterdivided$sendqty$parameterdivided$productDetailsString$parameterdivided';

  //     print('urlllllllllll : $dynamicUrl');

  //     if (await canLaunch(dynamicUrl)) {
  //       await launch(dynamicUrl, enableJavaScript: true);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Could not launch $dynamicUrl')),
  //       );
  //     }
  //   }
  // }

  _launchUrl(BuildContext context, String reqNo, String statusString,
      String formattedDate) async {
    await fetchDispatchDetails(reqNo, statusString);
    print("StatusStringgggg  $statusString $filteredprintdatas");

    List<String> productDetails = [];
    int snoCounter = 1;

    // Merge table data
    List<Map<String, dynamic>> mergeTableData(
        List<Map<String, dynamic>> filteredprintdatas) {
      Map<String, Map<String, dynamic>> mergedData = {};

      for (var item in filteredprintdatas) {
        String key =
            '${item['INVOICE_NUMBER']}-${item['INVENTORY_ITEM_ID']}-${item['ITEM_DESCRIPTION']}';
        int currentQty =
            int.tryParse(item['TRUCK_SEND_QTY']?.toString() ?? '0') ?? 0;

        if (mergedData.containsKey(key)) {
          int existingQty =
              int.tryParse(mergedData[key]!['sendqty']?.toString() ?? '0') ?? 0;
          mergedData[key]!['sendqty'] = existingQty + currentQty;
        } else {
          mergedData[key] = {
            'sno': snoCounter++,
            'invoiceno': item['INVOICE_NUMBER'],
            'itemcode': item['INVENTORY_ITEM_ID'],
            'itemdetails': item['ITEM_DESCRIPTION'],
            'sendqty': item['PICKED_QTY'], // keep picked qty
          };
        }
      }

      return mergedData.values.toList();
    }

    List<Map<String, dynamic>> mergedData = mergeTableData(filteredprintdatas);

    for (var data in mergedData) {
      String formattedProduct =
          "{${data['sno']}|${data['invoiceno']}|${data['itemcode']}|${data['itemdetails']}|${data['sendqty']}}";
      productDetails.add(formattedProduct);
    }

    String deliveryaddress = deliverAddressController.text.isNotEmpty
        ? deliverAddressController.text
        : 'null';

    String productDetailsString = productDetails.join(',');
    int sendqty = 0;

    if (filteredprintdatas is List && filteredprintdatas.isNotEmpty) {
      final item = filteredprintdatas.first;

      String uniqulastpcikno = item['PICK_ID'] ?? '';
      String region = item['PHYSICAL_WAREHOUSE'] ?? '';
      String pickmanname = item['ASSIGN_PICKMAN'] ?? 'null';
      String customerno = item['CUSTOMER_NUMBER'] ?? 'null';
      String customername = item['CUSTOMER_NAME'] ?? 'null';
      String customersite = item['CUSTOMER_SITE_ID'] ?? 'null';

      for (var it in filteredprintdatas) {
        int qty = int.tryParse(it['PICKED_QTY']?.toString() ?? '0') ?? 0;
        sendqty += qty;
      }

      print('Total Send Qty: $sendqty');
      final ipAddress = await getActiveOracleIpAddress();

      // ✅ Build proper URL with queryParameters
      final Uri url = Uri.parse('$ipAddress/Generate_picking_print/').replace(
        queryParameters: {
          "pickid": uniqulastpcikno,
          "reqno": reqNo,
          "region": region,
          "pickmanname": pickmanname,
          "deliveryaddress": deliveryaddress,
          "date": formattedDate,
          "customerNo": customerno,
          "customername": customername,
          "customersite": customersite,
          "itemtotalqty": sendqty.toString(),
          "products_param": productDetailsString,
        },
      );

      print('urlllllllllll : $url');

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getUniquePickIdData(
      List<Map<String, dynamic>> dataList) {
    final seenPickIds = <String>{};
    final uniqueData = <Map<String, dynamic>>[];

    for (var item in dataList) {
      final pickId = item['PICK_ID'].toString();
      if (!seenPickIds.contains(pickId)) {
        seenPickIds.add(pickId);
        uniqueData.add(item);
      }
    }
    return uniqueData;
  }

  Widget pickdetailsViewtabledata() {
    bool isDialogOpen = false; // Track if dialog is already opened
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
                height: MediaQuery.of(context).size.height * 0.4,
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.55
                    : MediaQuery.of(context).size.width * 2.5,
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
                              _tableHeader("Item Code", Icons.countertops),
                              _tableItemDescdetailsHeader("Item Description",
                                  Icons.person), // Added Pickman Name
                              _tableHeader("Qty.Req", Icons.print),
                            ],
                          ),
                        ),
                        // Loading Indicator or Table Rows
                        if (_isLoading)
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (filteredprintdatas.isNotEmpty)
                          ...filteredprintdatas.asMap().entries.map((entry) {
                            int index = entry.key;
                            var data = entry.value;

                            String itemcode =
                                data['INVENTORY_ITEM_ID'].toString();
                            String itemdetails =
                                data['ITEM_DESCRIPTION'].toString();
                            String sNo = (index + 1).toString();
                            String pickedqty = data['PICKED_QTY'].toString();

                            double pickedQtyDouble =
                                double.tryParse(pickedqty) ?? 0.0;
                            String finalpickqty = pickedQtyDouble.toString();

                            bool isEvenRow = index % 2 == 0;
                            Color rowColor = isEvenRow
                                ? const Color.fromARGB(224, 255, 255, 255)
                                : const Color.fromARGB(224, 245, 245, 245);

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: GestureDetector(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _tableRow(sNo, rowColor),
                                    _tableRow(itemcode, rowColor),
                                    _tableItemDescriptiodetailsRow(
                                        itemdetails, rowColor),
                                    _tableRow(finalpickqty, rowColor),
                                  ],
                                ),
                              ),
                            );
                          }).toList()
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Text("No data available."),
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

  Widget Viewtabledata(String StatusString) {
    bool isDialogOpen = false; // Track if dialog is already opened
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
                    : MediaQuery.of(context).size.width * 2.5,
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
                              _tableHeader("Date", Icons.date_range),
                              _tableHeader("Pick Id", Icons.countertops),
                              _tableItemDescHeader("Pickman Name",
                                  Icons.person), // Added Pickman Name
                              _tableHeader("Action", Icons.print),
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
                          ..._getUniquePickIdData(viewtableData)
                              .asMap()
                              .entries
                              .map((entry) {
                            int index = entry.key;
                            var data = entry.value;

                            // Format date to 'yyyy-MM-dd'
                            // String rawDate = data['DATE'].toString();
                            // String formattedDate = '';
                            // try {
                            //   DateTime parsedDate = DateTime.parse(rawDate);
                            //   formattedDate =
                            //       DateFormat('yyyy-MM-dd').format(parsedDate);
                            // } catch (e) {
                            //   formattedDate =
                            //       rawDate; // fallback if parsing fails
                            // }

// Assuming your raw date from data
                            String rawDate = data['DATE'].toString();

// Parse the raw date into a DateTime object
                            DateTime parsedDate = DateTime.parse(rawDate);

// Format the date as '03 Aug 2025'
                            String formattedDate =
                                DateFormat("dd MMM yyyy").format(parsedDate);

// Use the formattedDate wherever you need
                            print(formattedDate); // Output: 03 Aug 2025
                            String reqno = data['REQ_ID'].toString();
                            String pickid = data['PICK_ID'].toString();
                            String sNo = (index + 1).toString();
                            String pickmanname =
                                data['ASSIGN_PICKMAN'].toString();
                            String pickedqty = data['PICKED_QTY'].toString();

                            double pickedQtyDouble =
                                double.tryParse(pickedqty) ?? 0.0;
                            String finalpickqty = pickedQtyDouble.toString();

                            String item_description =
                                data['ITEM_DESCRIPTION'].toString();
                            bool isEvenRow = index % 2 == 0;
                            Color rowColor = isEvenRow
                                ? Color.fromARGB(224, 255, 255, 255)
                                : Color.fromARGB(224, 245, 245, 245);

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: GestureDetector(
                                onDoubleTap: () async {
                                  // If dialog is already open, return early
                                  if (isDialogOpen) return;

                                  setState(() {
                                    isDialogOpen = true; // Lock the interaction
                                  });

                                  // Fetch data and show dialog
                                  // await fetchPickmanData(data['REQ_ID']);

                                  // await fetchAndFilterData(reqno, pickid);

                                  if (StatusString == 'pending') {
                                    await fetchPickmanData(data['REQ_ID']);
                                    await fetchAndFilterData(reqno, pickid);
                                  }
                                  if (StatusString == 'Completed') {
                                    await fetchPickmanCompletedData(
                                        data['REQ_ID']);
                                    await fetchAndCompletedFilterData(
                                        reqno, pickid);
                                  }

                                  // Show the dialog
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return pending_pickmandetailsdetailsbox(
                                          context, data['REQ_ID']);
                                    },
                                  ).then((_) {
                                    setState(() {
                                      isDialogOpen =
                                          false; // Allow interaction again once dialog is closed
                                    });
                                  });
                                  postLogData("PickMan Pending View",
                                      "Pending details opened");
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _tableRow(sNo, rowColor),

                                    _tableRow(formattedDate, rowColor),
                                    _tableRow(pickid, rowColor),
                                    // Expanded(
                                    //   child: Container(
                                    //     height: 30,
                                    //     width: 120,
                                    //     decoration: BoxDecoration(
                                    //       color: rowColor,
                                    //       border: Border.all(
                                    //           color: Color.fromARGB(
                                    //               255, 226, 225, 225)),
                                    //     ),
                                    //     child: Row(
                                    //       mainAxisAlignment: MainAxisAlignment
                                    //           .start, // Aligns items to the start
                                    //       crossAxisAlignment: CrossAxisAlignment
                                    //           .center, // Center vertically
                                    //       children: [
                                    //         Expanded(
                                    //             child: Tooltip(
                                    //           message: pickmanname,
                                    //           child: SingleChildScrollView(
                                    //             scrollDirection:
                                    //                 Axis.horizontal,
                                    //             child: SelectableText(
                                    //               pickid,
                                    //               textAlign: TextAlign.left,
                                    //               style: TableRowTextStyle,
                                    //               showCursor: false,
                                    //               // overflow: TextOverflow.ellipsis,
                                    //               cursorColor: Colors.blue,
                                    //               cursorWidth: 2.0,
                                    //               toolbarOptions:
                                    //                   ToolbarOptions(
                                    //                       copy: true,
                                    //                       selectAll: true),
                                    //               onTap: () {
                                    //                 // Optional: Handle single tap if needed
                                    //               },
                                    //             ),
                                    //             // Text(
                                    //             //   pickid,
                                    //             //   textAlign: TextAlign
                                    //             //       .left, // Align text to the start
                                    //             //   style: TableRowTextStyle,
                                    //             //   overflow:
                                    //             //       TextOverflow.ellipsis,
                                    //             // ),
                                    //           ),
                                    //         )),
                                    //       ],
                                    //     ),
                                    //   ),
                                    // ),

                                    _tableItemDescRow(pickmanname,
                                        rowColor), // Add Pickman Name Row
                                    Container(
                                      height: 30,
                                      decoration:
                                          BoxDecoration(color: buttonColor),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (StatusString == 'pending')
                                            await fetchAndFilterData(
                                                reqno, pickid);
                                          if (StatusString == 'Completed')
                                            await fetchAndCompletedFilterData(
                                                reqno, pickid);
                                          await _launchUrl(context, reqno,
                                              StatusString, formattedDate);
                                          postLogData("PickMan Pending View",
                                              "Reprint");
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          minimumSize: const Size(45.0,
                                              31.0), // Set width and height
                                          backgroundColor: Colors
                                              .transparent, // Make background transparent to show gradient
                                          shadowColor: Colors
                                              .transparent, // Disable shadow to preserve gradient
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 2,
                                              bottom: 2,
                                              left: 5,
                                              right: 5),
                                          child: const Text(
                                            'Reprint',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // _tableRow(finalpickqty, rowColor),
                                  ],
                                ),
                              ),
                            );
                          }).toList()
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Text("No data available."),
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

  Future<void> savereqno(String dispaatch_requestno) async {
    await SharedPrefs.dispaatch_requestno(dispaatch_requestno);
  }
}
