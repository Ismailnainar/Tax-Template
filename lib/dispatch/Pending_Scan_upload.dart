import 'dart:convert';

import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/components/constaints.dart';
import 'package:aljeflutterapp/dispatch/fileupload.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Delivery_Status_page extends StatefulWidget {
  const Delivery_Status_page({super.key});

  @override
  State<Delivery_Status_page> createState() => _Delivery_Status_pageState();
}

class _Delivery_Status_pageState extends State<Delivery_Status_page> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  final TextEditingController ProductCodeController = TextEditingController();

  TextEditingController scannedqtyController = TextEditingController(text: '0');
  final TextEditingController salesserialnoController = TextEditingController();
  final ScrollController _horizontalScrollController1 = ScrollController();

  List<Map<String, dynamic>> filteredData = [];
  // List<Map<String, dynamic>> tableData = [];
  @override
  void initState() {
    super.initState();
    fetchAccessControl();
    _loadSalesmanName();
    fetchlivestagingreports();

    postLogData("Pending Scan", "Opened");
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

    postLogData("Pending Scan", "Closed");
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

  Future<void> fetchlivestagingreports() async {
    final IpAddress = await getActiveIpAddress();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgid = prefs.getString('saleslogiOrgwarehousename') ?? '';
    // final String url = '$IpAddress/filtered_Truck/?ORG_NAME=$saleslogiOrgid';
    final String url = '$IpAddress/filtered_Truck/';

    List<Map<String, dynamic>> filteredDataTemp = [];
    bool hasNextPage = true;
    String? nextPageUrl = url;

    print("urlll $url");

    setState(() {
      _isLoadingData = true;
    });

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

            filteredDataTemp.addAll(
              currentPageData.where((item) {
                final orgIdMatches =
                    item['ORG_NAME']?.toString() == saleslogiOrgid;
                final isNotDelivered =
                    item['DELIVERY_STATUS']?.toString() != 'Delivery Completed';
                return orgIdMatches && isNotDelivered;
              }),
            );

            nextPageUrl = responseData['next'];
            hasNextPage = nextPageUrl != null;
          } else {
            throw Exception('No "results" key found in the response');
          }
        } else {
          throw Exception(
            'Failed to load data with status code ${response.statusCode}',
          );
        }
      }

      // Update state with the filtered data
      setState(() {
        filteredData = filteredDataTemp.map((item) {
          return {
            'cusno': item['CUSTOMER_NUMBER']?.toString() ?? '',
            'cusname': item['CUSTOMER_NAME']?.toString() ?? '',
            'cussite': item['CUSTOMER_SITE_ID']?.toString() ?? '',
            'dispatchno': item['DISPATCH_ID']?.toString() ?? '',
            'salesmanno': item['SALESMAN_NO']?.toString() ?? '',
            'salesmanname': item['SALESMAN_NAME']?.toString() ?? '',
            'reqno': item['REQ_ID']?.toString() ?? '',
            'pickid': item['PICK_ID']?.toString() ?? '',
            'scannedqty': item['TRUCK_SEND_QTY']?.toString() ?? '',
            'loadingcharge': item['LOADING_CHARGES']?.toString() ?? '',
            'transportcharge': item['TRANSPORT_CHARGES']?.toString() ?? '',
            'misccharge': item['MISC_CHARGES']?.toString() ?? '',
            'date': formatDate(item['DATE']),
          };
        }).toList();

        tableData = List.from(filteredData);
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      print('Error fetching data: $e');
    }
  }

  TextEditingController deliverynocontroller = TextEditingController();

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  FocusNode entereddeliveryidfocusnode = FocusNode();
  FocusNode Searchfocusnode = FocusNode();

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
                                  Icons.track_changes,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Pending Scan View',
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
                                          Container(
                                            width: Responsive.isDesktop(context)
                                                ? 200
                                                : 150,
                                            height: 33,
                                            color: Colors.grey[200],
                                            child: TextFormField(
                                              controller: deliverynocontroller,
                                              focusNode:
                                                  entereddeliveryidfocusnode,
                                              onFieldSubmitted: (_) =>
                                                  _fieldFocusChange(
                                                      context,
                                                      entereddeliveryidfocusnode,
                                                      Searchfocusnode),
                                              onChanged: (value) {
                                                setState(() {
                                                  // _search();
                                                  _filterDataByDate();
                                                });
                                                _filterDataByDate();
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'Enter Delivery Id',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.zero,
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                                filled: true,
                                                fillColor: Color.fromARGB(
                                                    255, 255, 255, 255),
                                              ),
                                              style: textBoxstyle,
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Container(
                                            height: 32,
                                            decoration: BoxDecoration(
                                                color: buttonColor),
                                            child: ElevatedButton(
                                                focusNode: Searchfocusnode,
                                                onPressed: () async {
                                                  if (deliverynocontroller
                                                      .text.isEmpty) {
                                                    Checkstatus();
                                                  } else {
                                                    await fetchlivestagingreports();
                                                    await _filterDataByDate();
                                                  }

                                                  postLogData(
                                                      "Pending Scan", "Search");
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
                                                  await fetchlivestagingreports();
                                                  deliverynocontroller.clear();

                                                  postLogData(
                                                      "Pending Scan", "Clear");
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

  int _currentPage = 1;
  int _rowsPerPage = 10;
  int _totalPages = 1;
  _filterDataByDate() {
    final deliverid = deliverynocontroller.text.trim();
    print("Filtering by delivery ID: $deliverid");

    try {
      setState(() {
        // Reset to first page whenever filtering changes
        _currentPage = 1;

        if (deliverid.isEmpty) {
          // If search field is empty, show all data
          filteredData = List.from(tableData);
        } else {
          // Filter data based on dispatch number
          filteredData = tableData.where((entry) {
            try {
              // Case-insensitive comparison of dispatch numbers
              return entry['dispatchno']
                  .toString()
                  .toLowerCase()
                  .contains(deliverid.toLowerCase());
            } catch (e) {
              print("Error filtering entry: ${entry['dispatchno']} - $e");
              return false;
            }
          }).toList();
        }

        // Update total pages based on filtered data
        _totalPages = (filteredData.length / _rowsPerPage).ceil();
        if (_totalPages == 0) _totalPages = 1; // Ensure at least 1 page

        print("Found ${filteredData.length} matching records");
      });
    } catch (e) {
      print("Error in _filterDataByDate: $e");
      setState(() {
        filteredData = [];
        _currentPage = 1;
        _totalPages = 1;
      });
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

// Add these constants at the top of your file
  double _rowHeight = 40.0; // Height of each table row
  int _defaultVisibleRows = 10; // Number of rows visible by default

// Desktop Table View with Pagination
  Widget _buildTableDesktop() {
    final screenWidth = MediaQuery.of(context).size.width;

    // Column widths adjusted for better proportions
    final columnWidths = {
      'sno': screenWidth * 0.04,
      'date': screenWidth * 0.1,
      'dispatchNo': screenWidth * 0.1,
      'customerNo': screenWidth * 0.1,
      'customerName': screenWidth * 0.3,
      'customerSite': screenWidth * 0.1,
      'quantity': screenWidth * 0.1,
    };

    // Pagination variables
    final totalItems = filteredData.length;
    final totalPages = (totalItems / _rowsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = startIndex + _rowsPerPage > totalItems
        ? totalItems
        : startIndex + _rowsPerPage;
    final paginatedData = filteredData.sublist(
      startIndex,
      endIndex,
    );

    // Calculate table body height based on rows per page
    final tableBodyHeight = _rowsPerPage <= _defaultVisibleRows
        ? _rowHeight * _rowsPerPage
        : _rowHeight * _defaultVisibleRows;

    return Column(
      children: [
        // Table Container
        Container(
          width: screenWidth * 0.86,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[400]!, width: 1.0),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
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
                        height: tableBodyHeight,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (filteredData.isNotEmpty)
                      Container(
                        height: tableBodyHeight,
                        child:
                            _buildTableBodyDesktop(columnWidths, paginatedData),
                      )
                    else
                      Container(
                        height: tableBodyHeight,
                        child: Center(
                          child: Text(
                            "Kindly choose date to view shipped datas..",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Pagination Controls
        if (filteredData.isNotEmpty && !_isLoadingData)
          Container(
            margin: EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.first_page),
                  onPressed: _currentPage == 1
                      ? null
                      : () {
                          setState(() {
                            _currentPage = 1;
                          });
                        },
                ),
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: _currentPage == 1
                      ? null
                      : () {
                          setState(() {
                            _currentPage--;
                          });
                        },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Page $_currentPage of $totalPages',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: _currentPage == totalPages
                      ? null
                      : () {
                          setState(() {
                            _currentPage++;
                          });
                        },
                ),
                IconButton(
                  icon: Icon(Icons.last_page),
                  onPressed: _currentPage == totalPages
                      ? null
                      : () {
                          setState(() {
                            _currentPage = totalPages;
                          });
                        },
                ),
                SizedBox(width: 20),
                DropdownButton<int>(
                  value: _rowsPerPage,
                  items: [10, 25, 50, 100].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value rows'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _rowsPerPage = value!;
                      _currentPage =
                          1; // Reset to first page when changing rows per page
                    });
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTableHeaderDesktop(Map<String, double> columnWidths) {
    final headers = [
      {'icon': Icons.format_list_numbered, 'label': 'Sno', 'key': 'sno'},
      {'icon': Icons.date_range, 'label': 'Date', 'key': 'date'},
      {'icon': Icons.numbers, 'label': 'DispatchNo', 'key': 'dispatchNo'},
      {
        'icon': Icons.account_circle,
        'label': 'Customer No',
        'key': 'customerNo'
      },
      {'icon': Icons.person, 'label': 'Customer Name', 'key': 'customerName'},
      {'icon': Icons.person, 'label': 'Customer Site', 'key': 'customerSite'},
      {
        'icon': Icons.info_outline,
        'label': 'Total Delivered Qty',
        'key': 'quantity'
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: headers.map((header) {
          return SizedBox(
            width: columnWidths[header['key']],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(header['icon'] as IconData,
                      size: 16, color: Colors.blue[700]),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      header['label'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.blue[900],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableBodyDesktop(Map<String, double> columnWidths,
      List<Map<String, dynamic>> paginatedData) {
    return Scrollbar(
      thumbVisibility: true,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: paginatedData.length,
        itemBuilder: (context, index) {
          final data = paginatedData[index];
          return _buildTableRowDesktop(data, columnWidths, index);
        },
      ),
    );
  }

  Widget _buildTableRowDesktop(
      Map<String, dynamic> data, Map<String, double> columnWidths, int index) {
    final isEvenRow = index % 2 == 0;
    final rowColor = isEvenRow ? Colors.white : Colors.grey[50];
    final sNo = ((_currentPage - 1) * _rowsPerPage) + index + 1;
    final finalqty = double.parse(data['scannedqty']).toInt();

    return GestureDetector(
      onDoubleTap: () => _showDetailsDialog(data),
      child: Container(
        height: _rowHeight,
        decoration: BoxDecoration(
          color: rowColor,
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Row(
            children: [
              _buildTableCell(columnWidths['sno']!, sNo.toString()),
              _buildTableCell(columnWidths['date']!, data['date']),
              _buildTableCell(columnWidths['dispatchNo']!, data['dispatchno']),
              _buildTableCell(columnWidths['customerNo']!, data['cusno']),
              _buildTableCell(
                columnWidths['customerName']!,
                data['cusname'],
                isTooltip: true,
              ),
              _buildTableCell(columnWidths['customerSite']!, data['cussite']),
              _buildQuantityCell(columnWidths['quantity']!, finalqty, rowColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(double width, String text, {bool isTooltip = false}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: isTooltip
              ? Tooltip(
                  message: text,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      text,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    text,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildQuantityCell(double width, int quantity, Color? rowColor) {
    return SizedBox(
      width: width,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            quantity.toString(),
            style: TextStyle(
              color: Colors.green[800],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

// Add these variables to your state class

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
    final finalqty = double.parse(data['scannedqty']).toInt();

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
              _buildCardRow(Icons.numbers, 'Dispatch No:', data['dispatchno']),
              _buildCardRow(Icons.date_range, 'Date:', data['date']),
              _buildCardRow(
                  Icons.account_circle, 'Customer No:', data['cusno']),
              _buildCardRow(Icons.person, 'Customer:', data['cusname']),
              _buildCardRow(Icons.location_on, 'Site:', data['cussite']),
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

  void _showDetailsDialog(Map<String, dynamic> data) async {
    if (isDialogOpen) return;
    print("dataaaaaaaaaaaaa $data");
    setState(() => isDialogOpen = true);

    await fetchPickmanData(data['dispatchno']);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DispatchConpletedDataFetch(
        context,
        data['reqno'],
        data['pickid'],
        data['dispatchno'],
        data['salesmanno'],
        data['salesmanname'],
        data['cusno'],
        data['cusname'],
        data['cussite'],
        data['loadingcharge'],
        data['transportcharge'],
        data['misccharge'],
      ),
    ).then((_) => setState(() => isDialogOpen = false));

    postLogData("Pending Scan (Dispatch Completed Pop-up)",
        "Viewed Dispatch Id ${data['dispatchno']}");
  }

  TextEditingController customersiteController = TextEditingController();
  TextEditingController deliveryidController = TextEditingController();

  TextEditingController SalesmannoController = TextEditingController();

  TextEditingController SalesmannameController = TextEditingController();

  TextEditingController loadingchargecontroller = TextEditingController();
  TextEditingController transportorchargecontroller = TextEditingController();
  TextEditingController miscchargecontroller = TextEditingController();
  PlatformFile? _selectedFile;
  String? _fileName;
  double _uploadProgress = 0;
  bool _isUploading = false;
  bool _isCompressing = false;
  final double _maxFileSizeKB = 20; // 11 KB maximum size
  final double _compressThresholdKB =
      20 * 1024; // 20 MB threshold for compression

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileSizeKB = file.size / 1024;

        // Check file size
        if (fileSizeKB > _maxFileSizeKB) {
          // Check if file is compressible
          if (fileSizeKB > _compressThresholdKB) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'File too large (${fileSizeKB.toStringAsFixed(1)} KB). Max ${_maxFileSizeKB} KB allowed.',
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Simulate compression for files between 11KB and 20MB
          setState(() {
            _isCompressing = true;
            _selectedFile = file;
            _fileName = 'Compressing ${file.name}...';
          });

          // Simulate compression process
          for (int i = 0; i <= 100; i++) {
            await Future.delayed(const Duration(milliseconds: 20));
            setState(() {
              _uploadProgress = i / 100;
            });
          }

          setState(() {
            _isCompressing = false;
            _fileName = '${file.name} (compressed)';
          });
        } else {
          // File is within size limit
          setState(() {
            _selectedFile = file;
            _fileName = file.name;
          });
        }

        // Start upload process
        setState(() {
          _isUploading = true;
          _uploadProgress = 0;
        });

        // Simulate upload progress
        for (int i = 0; i <= 100; i++) {
          await Future.delayed(const Duration(milliseconds: 30));
          setState(() {
            _uploadProgress = i / 100;
          });
        }

        setState(() {
          _isUploading = false;
        });

        // Log file info
        print('File name: ${file.name}');
        print('File size: ${(file.size / 1024).toStringAsFixed(1)} KB');
        if (file.bytes != null) {
          print('File bytes available (web)');
        } else if (file.path != null) {
          print('File path available (mobile/desktop)');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget DispatchConpletedDataFetch(
    BuildContext context,
    String Reqno,
    String Pickid,
    String dispatchNo,
    String salesmano,
    String salesmanname,
    String cusno,
    String cusname,
    String cussite,
    String loadingcharge,
    String transportcharge,
    String misecharge,
  ) {
    double screenWidth = MediaQuery.of(context).size.width;
    print(
        "customernameeeeeeeeeeeeeeeeeeeeee : $loadingcharge  $salesmano  $salesmanname  $transportcharge  $misecharge,  ");
    customerNameController.text = '$cusname';
    customerNoController.text = '$cusno';
    reqnoController.text = '$Reqno';
    PicknoController.text = '$Pickid';

    customersiteController.text = '$cussite';
    deliveryidController.text = '$dispatchNo';
    SalesmannoController.text = '$salesmano';
    SalesmannameController.text = "$salesmanname";
    loadingchargecontroller.text = '$loadingcharge';
    transportorchargecontroller.text = '$transportcharge';

    miscchargecontroller.text = '$misecharge';

    return Dialog(
      child: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            width: Responsive.isDesktop(context) ? screenWidth * 0.85 : 600,
            height: Responsive.isDesktop(context) ? 800 : 500,
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
                  const SizedBox(height: 7),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runSpacing: 5,
                      children: [
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
                                    Text("Req No", style: textboxheading),
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
                                              message: "${Reqno}",
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
                                                controller: reqnoController,
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
                                              message: "${Pickid}",
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
                                                controller: PicknoController,
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
                                              message: "${cusno}",
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
                                              message: "${cussite}",
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
                              ? screenWidth * 0.08
                              : screenWidth * 0.4,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("Loading Charge",
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
                                              message: "${loadingcharge}",
                                              child: TextFormField(
                                                // readOnly: true,
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
                                                    loadingchargecontroller,
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
                                    Text("Transport Charge",
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
                                              message: "${transportcharge}",
                                              child: TextFormField(
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
                                                    transportorchargecontroller,
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
                                    Text("Misc Charge", style: textboxheading),
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
                                              message: "${misecharge}",
                                              child: TextFormField(
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
                                                    miscchargecontroller,
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
                          padding: const EdgeInsets.only(top: 15, bottom: 5),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Viewtabledata(),
                          ),
                        ),
                        Text('${SalesmannameController.text}'),
                        FileUploadScreen(
                            SalesmannoController,
                            SalesmannameController,
                            deliveryidController,
                            transportorchargecontroller,
                            loadingchargecontroller,
                            miscchargecontroller)
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.white,
                        height: MediaQuery.of(context).size.height * 0.35,
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width * 0.81
                            : MediaQuery.of(context).size.width * 2,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: [
                              // Table Header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 13),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // _tableHeader(
                                    //     "Req No", Icons.format_list_numbered),
                                    // _tableHeader("Pick Id", Icons.countertops),
                                    _tableHeader("Item Code", Icons.qr_code),
                                    _tableItemDescHeader(
                                        "Item Description", Icons.info_outline),
                                    _tableHeader(
                                        "Product Code", Icons.qr_code_scanner),
                                    _tableHeader(
                                        "Serial No", Icons.confirmation_number),
                                  ],
                                ),
                              ),
                              // Loading Indicator or Table Rows
                              if (_isLoading)
                                Padding(
                                  padding: const EdgeInsets.only(top: 100.0),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              else if (viewtableData.isNotEmpty)
                                ...viewtableData.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  var data = entry.value;

                                  // Extract relevant data
                                  String getreqno = data['REQ_ID'].toString();
                                  String reqno = 'ReqNo_$getreqno';
                                  String getpickid = data['PICK_ID'].toString();
                                  String pickid = 'PickId_$getpickid';
                                  String itemcode =
                                      data['ITEM_CODE'].toString();
                                  String itemdetails =
                                      data['ITEM_DETAILS'].toString();
                                  String productcode =
                                      data['PRODUCT_CODE'].toString();
                                  String serialno =
                                      data['SERIAL_NO'].toString();

                                  bool isEvenRow = index % 2 == 0;
                                  Color rowColor = isEvenRow
                                      ? Color.fromARGB(224, 255, 255, 255)
                                      : Color.fromARGB(224, 245, 245, 245);

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: GestureDetector(
                                      onTap: () {
                                        // Action on row tap (e.g., show details)
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // _tableRow(reqno, rowColor),
                                          // _tableRow(pickid, rowColor),
                                          _tableRow(itemcode, rowColor),
                                          _tableItemDescRow(
                                              itemdetails, rowColor),
                                          _tableRow(productcode, rowColor),
                                          _tableRow(serialno, rowColor),
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
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0, // Adjust pos   ition as needed
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Arrow with click handler
                  IconButton(
                    icon: Icon(
                      Icons.arrow_left_outlined,
                      color: Colors.blueAccent,
                      size: 30,
                    ),
                    onPressed: () {
                      // Scroll left by a fixed amount
                      _horizontalScrollController1.animateTo(
                        _horizontalScrollController1.offset -
                            100, // Adjust scroll amount
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  // Right Arrow with click handler
                  IconButton(
                    icon: Icon(
                      Icons.arrow_right_outlined,
                      color: Colors.blueAccent,
                      size: 30,
                    ),
                    onPressed: () {
                      // Scroll right by a fixed amount
                      _horizontalScrollController1.animateTo(
                        _horizontalScrollController1.offset +
                            100, // Adjust scroll amount
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
                style: TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis, // Avoid overflow
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableItemDescHeader(String text, IconData icon) {
    return Container(
      height: Responsive.isDesktop(context) ? 25 : 30,
      width: 550,
      decoration: TableHeaderColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Aligns items to the start
        crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
        children: [
          Icon(icon, size: 15, color: Colors.blue),
          SizedBox(width: 2),
          Expanded(
            child: Text(
              text, style: TextStyle(fontSize: 13),

              textAlign: TextAlign.left, // Align text to the start (left)
              overflow: TextOverflow.ellipsis, // Avoid overflow
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
                        child: Text(
                          data,
                          textAlign: TextAlign.left, // Align text to the start
                          style: TableRowTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  : Text(
                      data,
                      textAlign: TextAlign.left, // Align text to the start
                      style: TableRowTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
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
      width: 550,
      decoration: BoxDecoration(
        color: rowColor,
        border: Border.all(color: const Color.fromARGB(255, 226, 225, 225)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Tooltip(
            message: data,
            child: Text(
              data,
              style: TableRowTextStyle,
            ),
          ),
        ),
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

  TextEditingController reqnoController = TextEditingController();
  TextEditingController PicknoController = TextEditingController();

  Future<void> fetchPickmanData(String dispatchno) async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/filtedshippingproductdetails/$dispatchno/';
    print("Fetching data from URL: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');

        // Decode the JSON response

        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
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
}
