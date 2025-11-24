import 'dart:io'; // for File
import 'package:path_provider/path_provider.dart'; // for getApplicationDocumentsDirectory
import 'dart:ui';

import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:syncfusion_flutter_xlsio/xlsio.dart'
    hide Column, Row, Border, Stack;

import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:aljeflutterapp/components/constaints.dart';
import 'package:url_launcher/url_launcher.dart';

class RI_Report_page extends StatefulWidget {
  const RI_Report_page({super.key});

  @override
  State<RI_Report_page> createState() => _RI_Report_pageState();
}

class _RI_Report_pageState extends State<RI_Report_page> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  final TextEditingController ProductCodeController = TextEditingController();

  TextEditingController scannedqtyController = TextEditingController(text: '0');
  final TextEditingController salesserialnoController = TextEditingController();
  final ScrollController _horizontalScrollController1 = ScrollController();

  List<Map<String, dynamic>> filteredData = [];

  List<Map<String, dynamic>> Exported_filteredData = [];
  // List<Map<String, dynamic>> tableData = [];
  @override
  void initState() {
    super.initState();
    filteredData = List.from(tableData);
    fetchAccessControl();
    _loadSalesmanName();
    fetchRI_Reports();
    Exported_fetchRI_Reports();
    // checkStatus();

    postLogData("IR Report", "Opened");

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

    postLogData("IR Report", "Closed");
    super.dispose();
  }

  String? saveloginname = '';

  String? saveloginrole = '';
  String? salesloginno = '';

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      salesloginno = prefs.getString('salesloginno') ?? 'Unknown Salesman';
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
      saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
    });
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('dd-MMM-yyyy').format(parsedDate); // e.g., 11-Nov-2024
    } catch (e) {
      print("Error parsing date: $e");
      return '';
    }
  }

  Future<void> fetchRI_Reports() async {
    final IpAddress = await getActiveIpAddress();

    final String url = '$IpAddress/InvoiceReturn_Details/';
    List<Map<String, dynamic>> filteredDataTemp = [];
    bool hasNextPage = true;
    String? nextPageUrl = url;

    print("urlll $url");
    setState(() {
      _isLoadingData = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';

    try {
      while (hasNextPage && nextPageUrl != null) {
        print("Fetching data from URL: $nextPageUrl");
        final response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
          final Map<String, dynamic> responseData = json.decode(decodedBody);

          if (responseData.containsKey('results')) {
            final List<Map<String, dynamic>> currentPageData =
                List<Map<String, dynamic>>.from(responseData['results']);

            filteredDataTemp.addAll(currentPageData
                .where((item) => item['ORG_ID']?.toString() == saleslogiOrgid));

            nextPageUrl = responseData['next'];
            hasNextPage = nextPageUrl != null;
          } else {
            throw Exception('No results key found in the response');
          }
        } else {
          throw Exception(
              'Failed to load data with status code ${response.statusCode}');
        }
      }

      // Update state with the fetched data
      setState(() {
        filteredData = filteredDataTemp.map((item) {
          return {
            'cusno': item['CUSTOMER_NUMBER']?.toString() ?? '',
            'cusname': item['CUSTOMER_NAME']?.toString() ?? '',
            'cussite': item['CUSTOMER_SITE_ID']?.toString() ?? '',
            'invoiceno': item['INVOICE_NUMBER']?.toString() ?? '',
            'invoice_return_id': item['INVOICE_RETURN_ID']?.toString() ?? '',
            'salesman_no': item['SALESMANO_NO']?.toString() ?? '',
            'salesman_name': item['SALESMAN_NAME']?.toString() ?? '',

            'invociereturnqty': item['TOTAL_RETURNED_QTY']?.toString() ?? '',
            'remarks': item['REMARKS']?.toString() ?? '',
            'date': formatDate(item['DATE']), // Format the date
          };
        }).toList();
        // print("filteredData $filteredData");

        _isLoadingData = false;

        // Trigger date range filtering here
        _filterDataByDate();
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      print('Error fetching data: $e');
    }
  }

  Future<void> Exported_fetchRI_Reports() async {
    String fromDate = _FromdateController.text.trim();
    String toDate = _EnddateController.text.trim();
    final IpAddress = await getActiveIpAddress();

    // ✅ Build URL with query params
    final String url =
        '$IpAddress/Exported_InvoiceReturn_Details/?from_date=$fromDate&to_date=$toDate';

    List<Map<String, dynamic>> filteredDataTemp = [];
    bool hasNextPage = true;
    String? nextPageUrl = url;

    print("Fetching report from API: $url");

    setState(() {
      _isLoadingData = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';

    try {
      while (hasNextPage && nextPageUrl != null) {
        print("Fetching data from URL: $nextPageUrl");
        final response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes);
          final Map<String, dynamic> responseData = json.decode(decodedBody);

          if (responseData.containsKey('results')) {
            final List<Map<String, dynamic>> currentPageData =
                List<Map<String, dynamic>>.from(responseData['results']);

            // ✅ Only filter by ORG_ID (date is already handled by backend)
            filteredDataTemp.addAll(currentPageData.where((item) {
              return item['ORG_ID']?.toString() == saleslogiOrgid;
            }));

            nextPageUrl = responseData['next'];
            hasNextPage = nextPageUrl != null;
          } else {
            throw Exception('No results key found in the response');
          }
        } else {
          throw Exception(
              'Failed to load data with status code ${response.statusCode}');
        }
      }

      // Update state with the fetched data
      setState(() {
        Exported_filteredData = filteredDataTemp.map((item) {
          return {
            'DATE': formatDate(item['DATE']),
            'CUSTOMER NUMBER': item['CUSTOMER_NUMBER']?.toString() ?? '',
            'CUSTOMER NAME': item['CUSTOMER_NAME']?.toString() ?? '',
            'WHR SUPERUSER NO': item['MANAGER_NO']?.toString() ?? '',
            'SALESMAN NO - NAME':
                '${item['SALESMANO_NO']?.toString()} - ${item['SALESMAN_NAME']?.toString()}',
            'INV RETURN ID': item['INVOICE_RETURN_ID']?.toString() ?? '',
            'RE ISSUED INVOICE NO': item['INVOICE_NUMBER']?.toString() ?? '',
            'ITEM CODE': item['ITEM_CODE']?.toString() ?? '',
            'ITEM DESCRIPTION': item['ITEM_DESCRIPTION']?.toString() ?? '',
            'QTY': item['TOTAL_RETURNED_QTY']?.toString() ?? '',
          };
        }).toList();
        _isLoadingData = false;

        // No need for _filterDataByDate() anymore
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      print('Error fetching data: $e');
    }
  }

  DateTime? _selectedDate;
  TextEditingController _FromdateController = TextEditingController(
      text: DateFormat('dd-MMM-yyyy').format(DateTime.now()));

  TextEditingController _EnddateController = TextEditingController(
      text: DateFormat('dd-MMM-yyyy').format(DateTime.now()));

  // Function to show the date picker and set the selected date
  Future<void> _selectfromDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    // Show DatePicker Dialog
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Initial date
      firstDate: DateTime(2000), // Earliest possible date
      lastDate: DateTime(2101), // Latest possible date
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      // Format the selected date as 'dd-MMM-yyyy'
      String formattedDate = DateFormat('dd-MMM-yyyy').format(pickedDate);
      setState(() {
        _FromdateController.text =
            formattedDate; // Set the formatted date to the controller
      });
    }
  }

  // Function to show the date picker and set the selected date
  Future<void> _selectendDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    // Show DatePicker Dialog
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Initial date
      firstDate: DateTime(2000), // Earliest possible date
      lastDate: DateTime(2101), // Latest possible date
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      // Format the selected date as 'dd-MMM-yyyy'
      String formattedDate = DateFormat('dd-MMM-yyyy').format(pickedDate);
      setState(() {
        _EnddateController.text =
            formattedDate; // Set the formatted date to the controller
      });
    }
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
                                  Icons.receipt_long,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'IR Report',
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () => _selectfromDate(
                                                context), // Open the date picker when tapped
                                            child: Container(
                                              height: 32,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 0, horizontal: 20),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Color.fromARGB(
                                                    255, 195, 228, 255),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.calendar_today,
                                                      color: Colors.blue,
                                                      size: 14),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    _FromdateController
                                                            .text.isEmpty
                                                        ? DateFormat(
                                                                'dd-MMM-yyyy')
                                                            .format(
                                                                DateTime.now())
                                                        : _FromdateController
                                                            .text, // Display the selected date
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          GestureDetector(
                                            onTap: () => _selectendDate(
                                                context), // Open the date picker when tapped
                                            child: Container(
                                              height: 32,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 0, horizontal: 20),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Color.fromARGB(
                                                    255, 195, 228, 255),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.calendar_today,
                                                      color: Colors.blue,
                                                      size: 14),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    _EnddateController
                                                            .text.isEmpty
                                                        ? DateFormat(
                                                                'dd-MMM-yyyy')
                                                            .format(
                                                                DateTime.now())
                                                        : _EnddateController
                                                            .text, // Display the selected date
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Container(
                                            height: 32,
                                            decoration: BoxDecoration(
                                                color: buttonColor),
                                            child: ElevatedButton(
                                                onPressed: () async {
                                                  if (_FromdateController
                                                          .text.isEmpty ||
                                                      _EnddateController
                                                          .text.isEmpty) {
                                                    Checkstatus();
                                                  } else {
                                                    DateTime? fromDate =
                                                        DateFormat(
                                                                'dd-MMM-yyyy')
                                                            .parse(
                                                                _FromdateController
                                                                    .text);
                                                    DateTime? endDate =
                                                        DateFormat(
                                                                'dd-MMM-yyyy')
                                                            .parse(
                                                                _EnddateController
                                                                    .text);

                                                    if (endDate
                                                        .isBefore(fromDate)) {
                                                      await showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                "Invalid Date"),
                                                            content: Text(
                                                                "Kindly check the from date and end date."),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    _EnddateController
                                                                        .text = DateFormat(
                                                                            'dd-MMM-yyyy')
                                                                        .format(
                                                                            DateTime.now());
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  });
                                                                },
                                                                child:
                                                                    Text("OK"),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      await fetchRI_Reports();
                                                      // await Exported_fetchRI_Reports();
                                                      await _filterDataByDate();
                                                    }
                                                  }

                                                  postLogData(
                                                      "IR Report", "Search");
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  minimumSize:
                                                      const Size(45.0, 20.0),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                ),
                                                child: Text(
                                                  'Search',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                          ),
                                          SizedBox(width: 16),
                                          Container(
                                            height: 32,
                                            decoration: BoxDecoration(
                                                color: buttonColor),
                                            child: ElevatedButton(
                                                onPressed: () async {
                                                  // Show the processing dialog
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible:
                                                        false, // prevent closing while processing
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        content: Row(
                                                          children: [
                                                            const CircularProgressIndicator(),
                                                            const SizedBox(
                                                                width: 16),
                                                            const Expanded(
                                                              child: Text(
                                                                "Generating report, kindly wait...",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                  await Exported_fetchRI_Reports();

                                                  try {
                                                    // Prepare data
                                                    List<String> columnHeaders =
                                                        Exported_filteredData
                                                            .first.keys
                                                            .toList();
                                                    List<List<dynamic>>
                                                        convertedData =
                                                        Exported_filteredData
                                                            .map((map) {
                                                      return columnHeaders
                                                          .map((header) =>
                                                              map[header])
                                                          .toList();
                                                    }).toList();

                                                    // Generate excel
                                                    await createExcecl_Return_Invoice_details(
                                                        columnHeaders,
                                                        convertedData);

                                                    // Log export
                                                    postLogData(
                                                        "IR Report", "Export");
                                                  } catch (e) {
                                                    // Optional: Show error if something goes wrong
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'No data Found...'),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  } finally {
                                                    // Close the dialog once done
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .pop();
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  minimumSize:
                                                      const Size(45.0, 20.0),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                ),
                                                child: Text(
                                                  'Export',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                          ),
                                          SizedBox(width: 16),
                                          Container(
                                            height: 32,
                                            decoration: BoxDecoration(
                                                color: buttonColor),
                                            child: ElevatedButton(
                                                onPressed: () async {
                                                  await fetchRI_Reports();
                                                  await Exported_fetchRI_Reports();
                                                  _FromdateController.clear();
                                                  _EnddateController.clear();

                                                  postLogData(
                                                      "IR Report", "Clear");
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  minimumSize:
                                                      const Size(45.0, 20.0),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                ),
                                                child: Text(
                                                  'Clear',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10, right: 10, left: 10),
                            child: _buildResponsiveView(),
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

  Future<void> createExcecl_Return_Invoice_details(
    List<String> columnNames,
    List<List<dynamic>> data,
  ) async {
    String Fromdate = _FromdateController.text.trim();
    String enddate = _EnddateController.text.trim();

    try {
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      final String title = "Return Invoice Report";

      // Add main heading
      final Range titleRange = sheet.getRangeByIndex(1, 1);
      titleRange.setText(title);
      titleRange.cellStyle.fontSize = 16;
      titleRange.cellStyle.bold = true;
      sheet.getRangeByIndex(1, 1, 1, columnNames.length).merge();

      // Show filter details below heading
      final Range fromDateCell = sheet.getRangeByIndex(3, 1);
      fromDateCell.setText("From Date: $Fromdate");
      fromDateCell.cellStyle.bold = true;
      fromDateCell.cellStyle.fontSize = 12;

      final Range toDateCell = sheet.getRangeByIndex(4, 1);
      toDateCell.setText("To Date: $enddate");
      toDateCell.cellStyle.bold = true;
      toDateCell.cellStyle.fontSize = 12;

      // Today's date & time
      final DateTime now = DateTime.now();
      final DateTime today = DateTime.now();
      final String formattedTime = DateFormat('hh:mm:ss a').format(now);
      final String formattedToday = DateFormat('dd-MMM-yyyy').format(today);
      // ====== Footer: Runtime & Exported Time ======

      final Range runtimeCell = sheet.getRangeByIndex(5, 1);
      runtimeCell.setText("Runtime : $formattedToday -- $formattedTime");
      runtimeCell.cellStyle
        ..italic = true
        ..fontSize = 11
        ..hAlign = HAlignType.left;

      // Leave a row after details, then table headers
      final int headerRowIndex = 7;

      // Add column headers
      for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
        final Range range = sheet.getRangeByIndex(headerRowIndex, colIndex + 1);
        range.setText(columnNames[colIndex]);
        range.cellStyle.backColor = '#E7F3FD';
        range.cellStyle.fontColor = '#000000';
        range.cellStyle.bold = true;
        range.cellStyle.hAlign = HAlignType.left;
        range.cellStyle.borders.all.lineStyle = LineStyle.thin;
        range.cellStyle.borders.all.color = '#000000';
        range.cellStyle.bold = true;
      }

      // Add table data starting from row below headers
      for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
        final List<dynamic> rowData = data[rowIndex];
        for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
          final Range range = sheet.getRangeByIndex(
              headerRowIndex + 1 + rowIndex, colIndex + 1);

          final dynamic cellValue = rowData[colIndex];

          if (cellValue == null || cellValue.toString().isEmpty) {
            range.setText('');
          } else if (cellValue is num) {
            // ✅ set as number
            range.setNumber(cellValue.toDouble());
          } else {
            // ✅ fallback as text
            range.setText(cellValue.toString());
          }
        }
      }

      // ✅ Auto-fit columns based on content
      for (int i = 1; i <= columnNames.length; i++) {
        sheet.autoFitColumn(i);
      }

      final List<int> bytes = workbook.saveAsStream();
      try {
        workbook.dispose();
      } catch (e) {
        print('Error during workbook disposal: $e');
      }

      String formattedDate =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} Time '
          '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';

      if (kIsWeb) {
        AnchorElement(
            href:
                'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
          ..setAttribute(
              'download', 'Return Invoice Report($formattedDate).xlsx')
          ..click();
      } else {
        final String path = (await getApplicationSupportDirectory()).path;
        final String fileName = Platform.isWindows
            ? '$path\\Excel Return Invoice Report($formattedDate).xlsx'
            : '$path/Excel Return Invoice Report($formattedDate).xlsx';
        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);
        OpenFile.open(fileName);
      }
    } catch (e) {
      print('Error in createExcel: $e');
    }
  }

  _filterDataByDate() {
    final selectedFromDateStr = _FromdateController.text.trim();
    final selectedEndDateStr = _EnddateController.text.trim();

    if (selectedFromDateStr.isNotEmpty && selectedEndDateStr.isNotEmpty) {
      DateFormat dateFormat = DateFormat('dd-MMM-yyyy');

      try {
        DateTime selectedFromDate = dateFormat.parse(selectedFromDateStr);
        DateTime selectedEndDate = dateFormat.parse(selectedEndDateStr);

        setState(() {
          filteredData = filteredData.where((entry) {
            try {
              DateTime entryDate = dateFormat.parse(entry['date']);
              return entryDate
                      .isAfter(selectedFromDate.subtract(Duration(days: 1))) &&
                  entryDate.isBefore(selectedEndDate.add(Duration(days: 1)));
            } catch (e) {
              print("Error parsing entry date: ${entry['date']} - $e");
              return false;
            }
          }).toList();
        });
      } catch (e) {
        print("Error parsing selected dates: $e");
      }
    }
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

  List<Map<String, dynamic>> tableData = [];

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

  bool isDialogOpen = false; // Track if dialog is already opened

  Widget _buildResponsiveView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (Responsive.isDesktop(context)) {
          return _buildTableDesktop();
        } else {
          return _buildCardViewMobile();
        }
      },
    );
  }

// Desktop Table View
  Widget _buildTableDesktop() {
    final screenWidth = MediaQuery.of(context).size.width;
    final columnWidths = {
      'sno': screenWidth * 0.04,
      'date': screenWidth * 0.1,
      'invoice_return_id': screenWidth * 0.1,
      'customerNo': screenWidth * 0.13,
      'salesman_no': screenWidth * 0.13,
      'customerSite': screenWidth * 0.1,
      'invoiceno': screenWidth * 0.1,
      'quantity': screenWidth * 0.12,
    };

    return Container(
      width: screenWidth * 0.86,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[400]!, width: 1.0),
      ),
      child: Scrollbar(
        thumbVisibility: true,
        controller: _horizontalScrollController,
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: screenWidth * 0.86,
            child: Column(
              children: [
                // Table Header
                _buildTableHeaderDesktop(columnWidths),
                // Table Body
                if (_isLoadingData)
                  Container(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()))
                else if (filteredData.isNotEmpty)
                  _buildTableBodyDesktop(columnWidths)
                else
                  Container(
                    height: 100,
                    child: Center(
                        child:
                            Text("Kindly choose date to view shipped datas..")),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeaderDesktop(Map<String, double> columnWidths) {
    final headers = [
      {'icon': Icons.format_list_numbered, 'label': 'Sno', 'key': 'sno'},
      {'icon': Icons.date_range, 'label': 'Date', 'key': 'date'},
      {
        'icon': Icons.numbers,
        'label': 'Inv Return Id',
        'key': 'invoice_return_id'
      },
      {
        'icon': Icons.account_circle,
        'label': 'Customer No',
        'key': 'customerNo'
      },
      {'icon': Icons.person, 'label': 'Customer Site', 'key': 'customerSite'},
      {'icon': Icons.person, 'label': 'Salesman No', 'key': 'salesman_no'},
      {'icon': Icons.person, 'label': 'Invoice No', 'key': 'invoiceno'},
      {
        'icon': Icons.info_outline,
        'label': 'Total Inv Return Qty',
        'key': 'quantity'
      },
    ];

    return Container(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        children: headers.map((header) {
          return Container(
            height: 25,
            width: columnWidths[header['key']],
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(header['icon'] as IconData,
                      size: 15, color: Colors.blue),
                  const SizedBox(width: 5),
                  Text(
                    header['label'] as String,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableBodyDesktop(Map<String, double> columnWidths) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: filteredData
              .map((data) => _buildTableRowDesktop(data, columnWidths))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTableRowDesktop(
      Map<String, dynamic> data, Map<String, double> columnWidths) {
    final index = filteredData.indexOf(data);
    final isEvenRow = index % 2 == 0;
    final rowColor = isEvenRow
        ? const Color.fromARGB(224, 255, 255, 255)
        : const Color.fromARGB(223, 239, 239, 239);

    final sNo = (index + 1).toString();
    final finalqty = double.parse(data['invociereturnqty']).toInt();

    return GestureDetector(
      onDoubleTap: () => _showDetailsDialog(data),
      child: Container(
        color: rowColor,
        child: Row(
          children: [
            _buildTableCell(columnWidths['sno']!, '', sNo),
            _buildTableCell(columnWidths['date']!, '', data['date']),
            _buildTableCell(
              columnWidths['invoice_return_id']!,
              '',
              data['invoice_return_id'],
            ),
            _buildTableCell(
              columnWidths['customerNo']!,
              data['cusname'],
              data['cusno'],
              isTooltip: true,
            ),
            _buildTableCell(
              columnWidths['customerSite']!,
              '',
              data['cussite'],
            ),
            _buildTableCell(
              columnWidths['salesman_no']!,
              data['salesman_name'],
              data['salesman_no'],
              isTooltip: true,
            ),
            _buildTableCell(
              columnWidths['invoiceno']!,
              '',
              data['invoiceno'],
              isTooltip: true,
            ),
            Container(
              height: 30,
              width: columnWidths['quantity'],
              decoration: BoxDecoration(
                color: rowColor,
                border:
                    Border.all(color: const Color.fromARGB(255, 226, 225, 225)),
              ),
              child: Center(
                child: Text(
                  "$finalqty",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 65, 147, 72),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(double width, String tooltipText, String text,
      {bool isTooltip = false}) {
    return SizedBox(
      height: 30,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 226, 225, 225)),
        ),
        child: isTooltip
            ? Tooltip(
                message: tooltipText.isNotEmpty ? tooltipText : text,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: SelectableText(
                        text,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
      ),
    );
  }

// Mobile Card View
  Widget _buildCardViewMobile() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (_isLoadingData)
            const Center(child: CircularProgressIndicator())
          else if (filteredData.isNotEmpty)
            ...filteredData.map((data) => _buildDataCard(data)).toList()
          else
            const Padding(
              padding: EdgeInsets.only(top: 100.0),
              child: Text("Kindly choose date to view shipped datas.."),
            ),
        ],
      ),
    );
  }

  Widget _buildDataCard(Map<String, dynamic> data) {
    final finalqty = double.parse(data['invociereturnqty']).toInt();

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: InkWell(
        onTap: () => _showDetailsDialog(data),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardRow(
                  Icons.numbers, 'Inv Return Id:', data['invoice_return_id']),
              _buildCardRow(Icons.date_range, 'Date:', data['date']),
              _buildCardRow(
                  Icons.account_circle, 'Customer No:', data['cusno']),
              _buildCardRow(Icons.person, 'Customer:', data['cusname']),
              _buildCardRow(Icons.location_on, 'Site:', data['cussite']),
              _buildCardRow(
                  Icons.location_on, 'Invoice No:', data['invoiceno']),
              _buildCardRow(
                Icons.shopping_cart,
                'Quantity:',
                '$finalqty',
                valueStyle: const TextStyle(
                  color: Color.fromARGB(255, 65, 147, 72),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              const Center(
                child: Text(
                  'Double tap for details',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardRow(IconData icon, String label, String value,
      {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: valueStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  TextEditingController invoiceReturnIdController = TextEditingController();
  TextEditingController RemarksdController = TextEditingController();

  TextEditingController invoicenoController = TextEditingController();

  TextEditingController IRReportdatecontroller = TextEditingController();

  void _showDetailsDialog(Map<String, dynamic> data) async {
    if (isDialogOpen) return;

    setState(() => isDialogOpen = true);

    await fetchInvociereturnData(data['invoice_return_id']);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DispatchConpletedDataFetch(
          context,
          data['invoice_return_id'],
          data['cusno'],
          data['cusname'],
          data['cussite'],
          data['salesman_no'],
          data['salesman_name'],
          data['invoiceno'],
          data['date'],
          data['remarks']),
    ).then((_) => setState(() => isDialogOpen = false));

    postLogData("IR Report (Dispatch COmpleted Pop-up)", "Opened");
  }

  TextEditingController customersiteController = TextEditingController();

  TextEditingController SalesmanameController = TextEditingController();

  Widget DispatchConpletedDataFetch(
      BuildContext context,
      String invoice_return_id,
      String cusno,
      String cusname,
      String cussite,
      String salesman_no,
      String salesman_name,
      String invoiceno,
      String date,
      String remarks) {
    double screenWidth = MediaQuery.of(context).size.width;
    customerNameController.text = '$cusname';
    customerNoController.text = '$cusno';

    customersiteController.text = '$cussite';
    invoiceReturnIdController.text = '$invoice_return_id';
    RemarksdController.text = '$remarks';
    SalesmanameController.text = "$salesman_no";

    invoicenoController.text = '$invoiceno';

    IRReportdatecontroller.text = '$date';
    return Dialog(
      child: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            width: Responsive.isDesktop(context) ? screenWidth * 0.65 : 600,
            height: Responsive.isDesktop(context) ? 620 : 500,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Dispatch Completed Pop-Up",
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
                              ? screenWidth * 0.08
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
                                              ? screenWidth * 0.08
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
                                              message: "",
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
                                              message: "${cusname}",
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
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: Responsive.isDesktop(context)
                              ? screenWidth * 0.08
                              : screenWidth * 0.4,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("Customer Site",
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
                                              ? screenWidth * 0.08
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
                                              message: "",
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
                                                    customersiteController,
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
                                    Text("Salesman No", style: textboxheading),
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
                                              message: "${salesman_name}",
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
                                                    SalesmanameController,
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
                              ? screenWidth * 0.1
                              : screenWidth * 0.4,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("Invoice No", style: textboxheading),
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
                                              ? screenWidth * 0.1
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
                                              message: "",
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
                                                controller: invoicenoController,
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
                          padding: const EdgeInsets.only(top: 15, bottom: 15),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Viewtabledata(),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 35,
                              decoration: BoxDecoration(color: buttonColor),
                              child: ElevatedButton(
                                onPressed: () async {
                                  _launchUrl(
                                      context,
                                      SalesmanameController.text,
                                      customerNoController.text,
                                      customerNameController.text,
                                      customersiteController.text,
                                      invoicenoController.text,
                                      IRReportdatecontroller.text,
                                      invoiceReturnIdController.text,
                                      RemarksdController.text);

                                  postLogData(
                                      "IR Report (Dispatch COmpleted Pop-up)",
                                      "Reprint");
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(
                                      45.0, 31.0), // Set width and height
                                  backgroundColor: Colors
                                      .transparent, // Make background transparent to show gradient
                                  shadowColor: Colors
                                      .transparent, // Disable shadow to preserve gradient
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 5, bottom: 5, left: 8, right: 8),
                                  child: const Text(
                                    'Reprint',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  Widget Viewtabledata() {
    // Define column widths
    final double itemCodeWidth = 130;
    final double itemDescWidth = 450;
    final double productCodeWidth = 150;
    final double serialNoWidth = 150;

    return Container(
      width: MediaQuery.of(context).size.width,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 2, // Ensure scrollable width
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
                thumbVisibility: true,
                controller: _horizontalScrollController1,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController1,
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: itemCodeWidth +
                        itemDescWidth +
                        productCodeWidth +
                        serialNoWidth +
                        40,
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            // Table Header (fixed)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 13),
                              child: Row(
                                children: [
                                  _tableHeader("Item Code", Icons.qr_code,
                                      itemCodeWidth),
                                  _tableHeader("Item Description",
                                      Icons.info_outline, itemDescWidth),
                                  _tableHeader("Inv.Qty",
                                      Icons.confirmation_number, serialNoWidth),
                                  _tableHeader("Inv.return Qty",
                                      Icons.qr_code_scanner, productCodeWidth),
                                ],
                              ),
                            ),
                            // Table Content (scrollable)
                            if (_isLoading)
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            else if (viewtableData.isNotEmpty)
                              ...viewtableData.asMap().entries.map((entry) {
                                int index = entry.key;
                                var data = entry.value;

                                String itemcode = data['ITEM_CODE'].toString();
                                String itemdetails =
                                    data['ITEM_DESCRIPTION'].toString();
                                String returnqty =
                                    data['RETURNED_QTY'].toString();
                                String InvQty = data['TOT_QUANTITY'].toString();

                                bool isEvenRow = index % 2 == 0;
                                Color rowColor = isEvenRow
                                    ? Color.fromARGB(224, 255, 255, 255)
                                    : Color.fromARGB(224, 245, 245, 245);

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Action on row tap
                                    },
                                    child: Row(
                                      children: [
                                        _tableRow(
                                            itemcode, rowColor, itemCodeWidth),
                                        _tableRow(itemdetails, rowColor,
                                            itemDescWidth),
                                        _tableRow(
                                            InvQty, rowColor, serialNoWidth),
                                        _tableRow(returnqty, rowColor,
                                            productCodeWidth),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList()
                            else
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child:
                                    Center(child: Text("No data available.")),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_left_outlined,
                      color: Colors.blueAccent,
                      size: 30,
                    ),
                    onPressed: () {
                      _horizontalScrollController1.animateTo(
                        _horizontalScrollController1.offset - 100,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_right_outlined,
                      color: Colors.blueAccent,
                      size: 30,
                    ),
                    onPressed: () {
                      _horizontalScrollController1.animateTo(
                        _horizontalScrollController1.offset + 100,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String text, IconData icon, double width) {
    return Container(
      width: width,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 4),
          Icon(icon, size: 15, color: Colors.blue),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableRow(String data, Color rowColor, double width,
      {String? tooltipMessage}) {
    return Container(
      width: width,
      height: 30,
      decoration: BoxDecoration(
        color: rowColor,
        border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: tooltipMessage != null
              ? Tooltip(
                  message: tooltipMessage,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      data,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                )
              : Text(
                  data,
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ),
    );
  }

  void Checkstatus() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Row(
            children: [
              Icon(Icons.warning, color: Color.fromARGB(255, 198, 179, 10)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kindly select the From and To Date',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(30.0, 28.0),
              ),
              child: Text('Ok',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> viewtableData = [];
  bool _isLoading = false;

  TextEditingController customerNameController = TextEditingController();
  TextEditingController customerNoController = TextEditingController();

  Future<void> fetchInvociereturnData(String dispatchno) async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/invoice-return-details/$dispatchno/';
    print("Fetching data from URL: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
        print('Response body: ${decodedBody}');

        // Decode the JSON response
        final List<dynamic> data = json.decode(decodedBody);

        // Safely cast the list to List<Map<String, dynamic>>
        if (data.isNotEmpty) {
          setState(() {
            viewtableData = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
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

  _launchUrl(
      BuildContext context,
      String salesmano,
      String customerno,
      String customername,
      String customersite,
      String invoiceno,
      String formatedDate,
      String invoicereturnid,
      String remarks) async {
    List<String> productDetails = [];
    int snoCounter = 1;

    // Extract common fields from first item
    String date = '';
    String orgId = '';
    String managerNo = '';
    String managerName = '';

    if (viewtableData.isNotEmpty) {
      date = viewtableData[0]['DATE']?.toString() ?? '';
      orgId = viewtableData[0]['ORG_ID']?.toString() ?? '';
      managerNo = viewtableData[0]['MANAGER_NO']?.toString() ?? '';
      managerName = viewtableData[0]['MANAGER_NAME']?.toString() ?? '';
    }
    // Function to merge table data
    List<Map<String, dynamic>> mergeTableData(
        List<Map<String, dynamic>> viewtableData) {
      Map<String, Map<String, dynamic>> mergedData = {};

      for (var item in viewtableData) {
        String key = '${item['ITEM_CODE']}-${item['ITEM_DESCRIPTION']}';
        int qty = int.tryParse(item['RETURNED_QTY']?.toString() ?? '0') ?? 0;

        if (mergedData.containsKey(key)) {
          mergedData[key]!['RETURNED_QTY'] += qty;
        } else {
          mergedData[key] = {
            'sno': snoCounter++,
            'itemcode': item['ITEM_CODE'],
            'itemdetails': item['ITEM_DESCRIPTION'],
            'balanceqty': qty,
          };
        }
      }

      return mergedData.values.toList();
    }

    // Merge data
    List<Map<String, dynamic>> mergedData = mergeTableData(viewtableData);

    // Total balance quantity
    int totalBalanceQty = 0;

    for (var data in mergedData) {
      int qty = int.tryParse(data['balanceqty'].toString()) ?? 0;
      totalBalanceQty += qty;

      String formattedProduct =
          "{${data['sno']}|x|${data['itemcode']}|${data['itemdetails']}|${data['balanceqty']}}";
      productDetails.add(formattedProduct);
    }

    // Join into one product string
    String productDetailsString = productDetails.join(',');

    // // Get the base IP
    // final IpAddress = await getActiveIpAddress();

    // 🔗 Final dynamic URL with total qty
    // String dynamicUrl =
    //     '$IpAddress/Return_invoice_print/$managerNo/$managerName/$orgId/$formatedDate/$salesmano/$customerno/$customername/$customersite/$invoiceno/$totalBalanceQty/$productDetailsString/';

    // print('urlllllllllll : $dynamicUrl');

    // // Launch the URL
    // if (await canLaunch(dynamicUrl)) {
    //   await launch(dynamicUrl, enableJavaScript: true);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Could not launch $dynamicUrl')),
    //   );
    // }

    final ipAddress = await getActiveOracleIpAddress();

    // ✅ Build proper URL with queryParameters
    final Uri url = Uri.parse('$ipAddress/Return_invoice_print/').replace(
      queryParameters: {
        "uniqulastreqno": invoicereturnid.toString(),
        "remarks": remarks.toString(),
        "superuserno": salesloginno.toString(),
        "superusername": saveloginname.toString(),
        "orgid": orgId.toString(),
        "date": date.toString(),
        "salesmano": salesmano.toString(),
        "customerNo": customerno.toString(),
        "customername": customername.toString(),
        "customersite": customersite.toString(),
        "invoiceno": invoiceno.toString(),
        "itemtotalqty": totalBalanceQty.toString(),
        "products_param": productDetailsString.toString(),
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
