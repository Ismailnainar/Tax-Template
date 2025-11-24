import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/components/constaints.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart'
    hide Column, Row, Border, Stack;
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_svg/flutter_svg.dart';

class PickScanListPage extends StatefulWidget {
  final Function togglePage;

  PickScanListPage(this.togglePage);

  @override
  State<PickScanListPage> createState() => _PickScanListPageState();
}

class _PickScanListPageState extends State<PickScanListPage> {
  final TextEditingController salesmanIdController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadSalesmanName();
    FetchAssignedDatas();
    postLogData("Pick Scan View", "Opened");
  }

  String? saveloginname = '';
  String? saveloginno = '';
  String? saveloginrole = '';
  String? saveloginOrgid = '';

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
      saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
      saveloginno = prefs.getString('salesloginno') ?? 'Unknown Salesman';
      saveloginOrgid = prefs.getString('saleslogiOrgid') ?? 'Unknown Salesman';
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();

    postLogData("Pick Scan View", "Closed");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return Scaffold(
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
                                Image.asset(
                                  'assets/images/barcode.png',
                                  height: 30,
                                  width: 30,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Pick Scan View',
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
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // SizedBox(
                                //   width: 10,
                                // ),
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
                  padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                  child: Container(
                    height: screenheight * 0.84,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey[400]!,
                        width: 1.0,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Assigned Task :',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey[700]),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius:
                                                  3, // Adjust the size of the bullet
                                              backgroundColor: Color.fromARGB(
                                                  255,
                                                  23,
                                                  122,
                                                  5), // Bullet color
                                            ),
                                            SizedBox(
                                                width:
                                                    8), // Space between bullet and text
                                            Text(
                                              'Scanned Qty',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 23, 122, 5),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            CircleAvatar(
                                                radius:
                                                    3, // Adjust the size of the bullet
                                                backgroundColor: Color.fromARGB(
                                                    255, 200, 10, 10)),
                                            SizedBox(
                                                width:
                                                    8), // Space between bullet and text
                                            Text(
                                              ' Pending Scan Qty',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 200, 10, 10)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width:
                                    Responsive.isDesktop(context) ? 180 : 150,
                                height: 33,
                                child: TextField(
                                  controller: searchpickidController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter Pickid',
                                    border: OutlineInputBorder(),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  onChanged: (value) => searchreqno(),
                                  style: textBoxstyle,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10.0, right: 10),
                                child: Container(
                                  height: 35,
                                  decoration: BoxDecoration(color: buttonColor),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // Check if the data is empty
                                      if (tableData.isEmpty) {
                                        // Show dialog if no data is available
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Error'),
                                              content: Text(
                                                  'No data available to export.!!'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                  child: Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        return; // Exit if data is empty
                                      }

                                      // Manually generate the 'sNo' as 1, 2, 3, 4, etc.
                                      List<List<dynamic>> convertedData = [];
                                      int serialNumber =
                                          1; // Initialize serial number

                                      for (var map in tableData) {
                                        convertedData.add([
                                          serialNumber++, // Incremental serial number starting from 1
                                          map['pick_id'],
                                          map['date'],
                                          map['des_id'],
                                          map['total'],
                                          map['scanned_qty'],
                                          map['balance_qty'],
                                        ]);
                                      }

                                      List<String> columnNames =
                                          getDisplayedColumns();
                                      await createExcel(
                                          columnNames, convertedData);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .transparent, // Transparent for gradient
                                      shadowColor:
                                          Colors.transparent, // Remove shadow
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      elevation: 0, // Flat design
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/excel.svg',
                                          width: 20,
                                          height: 20,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Text("Export", style: commonWhiteStyle),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          _buildTable()
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> createExcel(
      List<String> columnNames, List<List<dynamic>> data) async {
    try {
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
        final Range range = sheet.getRangeByIndex(1, colIndex + 1);
        range.setText(columnNames[colIndex]);
        range.cellStyle.backColor = '#550A35';
        range.cellStyle.fontColor = '#F5F5F5';
      }

      for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
        final List<dynamic> rowData = data[rowIndex];
        for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
          final Range range = sheet.getRangeByIndex(rowIndex + 2, colIndex + 1);
          range.setText(rowData[colIndex].toString());
        }
      }

      final List<int> bytes = workbook.saveAsStream();

      try {
        workbook.dispose();
      } catch (e) {
        print('Error during workbook disposal: $e');
      }

      final now = DateTime.now();
      final formattedDate =
          '${now.day}-${now.month}-${now.year} Time ${now.hour}-${now.minute}-${now.second}';

      if (kIsWeb) {
        AnchorElement(
            href:
                'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
          ..setAttribute('download', 'PickScanView ($formattedDate).xlsx')
          ..click();
      } else {
        final String path = (await getApplicationSupportDirectory()).path;
        final String fileName = Platform.isWindows
            ? '$path\\Excel PickScanView ($formattedDate).xlsx'
            : '$path/Excel PickScanView ($formattedDate).xlsx';
        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);
        OpenFile.open(fileName);
      }
    } catch (e) {
      print('Error in createExcel: $e');
    }
  }

  List<String> getDisplayedColumns() {
    return [
      'Sno',
      'Pick_ID',
      'Date',
      'Qty.Invoice',
      'Qty.Requested',
      'Scanned.Qty',
      'Pending.Scan.Qty',
    ];
  }

  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> OrginaltableData = [];
  List<Map<String, dynamic>> filteredData = [];
  double totalQty = 0.0;
  double totalPickedQty = 0.0;
  double totalScannedQty = 0.0;
  double totalBalanceQty = 0.0;

  // Future<void> FetchAssignedDatas() async {
  //   int currentPage = 1;
  //   bool isLastPage = false;
  //   Map<String, Map<String, dynamic>> uniqueData = {};
  //   DateFormat dateFormat = DateFormat('dd-MMM-yyyy');

  //   try {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     final IpAddress = await getActiveIpAddress();

  //     // Fetching paginated data
  //     while (!isLastPage) {
  //       final url = Uri.parse('$IpAddress/Dispatch_request/?page=$currentPage');
  //       final response = await http.get(url);
  //       print("URL: $url");

  //       if (response.statusCode == 200) {
  //         final data = jsonDecode(response.body);
  //         final results = data['results'] as List?;
  //         final nextPageUrl = data['next'];

  //         // If no results, exit the loop
  //         if (results == null || results.isEmpty) {
  //           print('No results found');
  //           break;
  //         }

  //         // Processing each item in the result
  //         for (var item in results) {
  //           String pickname = item['ASSIGN_PICKMAN'].toString();
  //           String pickId = item['PICK_ID'].toString();
  //           String reqid = item['REQ_ID'].toString();
  //           String formattedDate =
  //               dateFormat.format(DateTime.parse(item['DATE']));
  //           String status = item['STATUS'].toString();

  //           double invoiceQty =
  //               double.tryParse(item['TOT_QUANTITY'].toString()) ?? 0.0;
  //           double pickedQty =
  //               double.tryParse(item['PICKED_QTY'].toString()) ?? 0.0;
  //           double scanned_qty =
  //               double.tryParse(item['SCANNED_QTY'].toString()) ?? 0.0;
  //           String flag = item['FLAG'].toString();

  //           // Correctly calculate balance_qty for each (pickId, reqid)
  //           double balance_qty = pickedQty - scanned_qty;

  //           // Unique key based on both pickId and reqid
  //           String uniqueKey = '$pickId-$reqid';

  //           // Check if the (pickId, reqid) already exists in uniqueData
  //           if (uniqueData.containsKey(uniqueKey)) {
  //             // Update quantities for the existing entry
  //             uniqueData[uniqueKey]!['des_id'] += invoiceQty;
  //             uniqueData[uniqueKey]!['total'] += pickedQty;
  //             uniqueData[uniqueKey]!['scanned_qty'] += scanned_qty;
  //             uniqueData[uniqueKey]!['balance_qty'] += balance_qty;

  //             // Update the overall status based on the current item's status
  //             if (status == 'pending') {
  //               uniqueData[uniqueKey]!['status'] = 'pending';
  //             } else if (uniqueData[uniqueKey]!['status'] != 'pending' &&
  //                 status == 'Finished') {
  //               uniqueData[uniqueKey]!['status'] = 'Finished';
  //             }
  //           } else {
  //             // Create a new entry for the unique (pickId, reqid)
  //             uniqueData[uniqueKey] = {
  //               'id': item['id'],
  //               'pickMan_Name': pickname,
  //               'reqid': reqid,
  //               'pick_id': pickId,
  //               'date': formattedDate,
  //               'des_id': invoiceQty,
  //               'total': pickedQty,
  //               'balance_qty': balance_qty,
  //               'scanned_qty': scanned_qty,
  //               'flag': flag,
  //               'status': status,
  //             };
  //           }
  //         }

  //         // Move to the next page if it exists
  //         if (nextPageUrl != null) {
  //           currentPage++;
  //         } else {
  //           isLastPage = true;
  //         }
  //       } else {
  //         print('Failed to load data: ${response.statusCode}');
  //         break;
  //       }
  //     }

  //     // Filter data to only include rows with balance_qty != 0
  //     final filteredResults = uniqueData.values
  //         .where(
  //             (entry) => entry['balance_qty'] != 0.0 && entry['flag'] != 'OU')
  //         .toList();

  //     setState(() {
  //       tableData = filteredResults;

  //       OrginaltableData = filteredResults;
  //       filteredData = List.from(tableData);
  //       _isLoading = false;
  //     });

  //     // print('Filtered Data: $filteredData');
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> FetchAssignedDatas() async {
    try {
      setState(() {
        _isLoading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';

      final IpAddress = await getActiveIpAddress();

      // ✅ Direct API call with pickman + status
      final url = Uri.parse(
          '$IpAddress/Get-Pickman_dispatch-request/?pickman=$saveloginname&status=pickmanpending');

      print("URL: $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final results = (data['data'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        if (results == null || results.isEmpty) {
          print('No results found');
          setState(() {
            tableData = [];
            OrginaltableData = [];
            filteredData = [];
            _isLoading = false;
          });
          return;
        }

        // ✅ No need for grouping/aggregation here, backend already did it
        setState(() {
          tableData = results;
          OrginaltableData = results;
          filteredData = List.from(tableData);
          _isLoading = false;
        });

        print("Fetched ${results.length} records");
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  TextEditingController searchpickidController = TextEditingController();

  void searchreqno() {
    String searchText = searchpickidController.text.trim().toLowerCase();

    setState(() {
      tableData = OrginaltableData.where((item) {
        String reqno = item['pick_id']?.toString().toLowerCase() ?? '';

        // Check if the search text is contained anywhere in the reqno string
        return searchText.isEmpty || reqno.contains(searchText);
      }).toList();
    });
  }

  Future<void> savepickno(String Pickman_pickno) async {
    await SharedPrefs.pickman_Pickno(Pickman_pickno);
  }

  Widget _buildTable() {
    double screenHeight = MediaQuery.of(context).size.height;
    int serialNumber = 1;

    return Container(
      child: Stack(children: [
        ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.all(Colors.grey[600]),
            thumbVisibility: MaterialStateProperty.all(true),
            thickness: MaterialStateProperty.all(8),
            radius: const Radius.circular(10),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Check if the screen width is suitable for displaying the table
              bool isWeb =
                  constraints.maxWidth > 600; // Adjust threshold as needed

              if (isWeb) {
                // Render the table for web
                return _buildTableView();
              } else {
                // Render the list for mobile
                return _buildListView(serialNumber);
              }
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildListView(int serialNumber) {
    var filteredData = tableData
        .where((data) => data['pickMan_Name'] == saveloginname)
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Loading indicator
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else if (filteredData.isEmpty) // Check if tableData is empty
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Text(
                  "No Picking alerted Contact manager..",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            )
          else
            ...filteredData.map((data) {
              String sNo = serialNumber.toString();
              serialNumber++;

              var pick_id = data['pick_id'].toString();
              var date = data['date'].toString();
              var total = data['total'].toString();
              var scanned_qty = data['scanned_qty'].toString();
              var balance_qty = data['balance_qty'].toString();
              var status = data['status'].toString();
              var reqid = data['reqid'].toString();
              var des_id = data['des_id'].toString();

              return Card(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                child: ListTile(
                  leading: Icon(Icons.assignment, color: Colors.blue),
                  title: Text(
                    "Pick ID: $pick_id",
                    style: TextStyle(fontSize: 13),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.date_range, size: 16, color: Colors.grey),
                          SizedBox(width: 5),
                          Text("Date: $date"),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.numbers, size: 16, color: Colors.purple),
                          SizedBox(width: 5),
                          Text(
                            "Qty.Invoice: ${double.tryParse(des_id)?.toInt().toString() ?? des_id}",
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.request_page,
                              size: 16, color: Colors.orange),
                          SizedBox(width: 5),
                          Text(
                            "Qty.Requested: ${double.tryParse(total)?.toInt().toString() ?? total}",
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 16, color: Colors.green),
                          SizedBox(width: 5),
                          Text(
                            "Scanned Qty: ${double.tryParse(scanned_qty)?.toInt().toString() ?? scanned_qty}",
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.pending, size: 16, color: Colors.red),
                          SizedBox(width: 5),
                          Text(
                            "Pending Scan Qty: ${double.tryParse(balance_qty)?.toInt().toString() ?? balance_qty}",
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: status == "Finished" ? Colors.green : buttonColor,
                    ),
                    child: ElevatedButton(
                      onPressed: status == "Finished"
                          ? null
                          : () async {
                              widget.togglePage();
                              savepickno(pick_id);
                              savereqno(reqid);
                            },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(45.0, 20.0),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Responsive.isDesktop(context)
                          ? Text(status == "Finished" ? "Finished" : 'View',
                              style: commonWhiteStyle)
                          : Icon(
                              status == "Finished"
                                  ? Icons.check
                                  : Icons.remove_red_eye_outlined,
                              size: 20,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildTableView() {
    double screenHeight = MediaQuery.of(context).size.height;
    int serialNumber = 1;
    return Container(
      child: Stack(children: [
        ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.all(Colors.grey[600]),
            thumbVisibility: MaterialStateProperty.all(true),
            thickness: MaterialStateProperty.all(8),
            radius: const Radius.circular(10),
          ),
          child: Scrollbar(
            thumbVisibility: true,
            controller: _horizontalScrollController,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.white,
                    height: Responsive.isDesktop(context)
                        ? screenHeight * 0.7
                        : 400,
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.85
                        : MediaQuery.of(context).size.width * 2,
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: _verticalScrollController,
                      child: SingleChildScrollView(
                        controller: _verticalScrollController,
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10.0, right: 10, top: 13, bottom: 5.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Container(
                                    width: 80,
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.numbers,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text("S.No",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.assignment_turned_in,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text("Pick Id",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.date_range,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text("Date",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.file_copy,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                    Responsive.isDesktop(
                                                            context)
                                                        ? "Qty.Invoice"
                                                        : "Qty.Invoi",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.shopping_cart,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                    Responsive.isDesktop(
                                                            context)
                                                        ? "Qty.Requested"
                                                        : "Qty.Req",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.done_all,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 3),
                                                Text(
                                                    Responsive.isDesktop(
                                                            context)
                                                        ? "Scanned.Qty"
                                                        : "S.Qty",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.pending,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 3),
                                                Text(
                                                    Responsive.isDesktop(
                                                            context)
                                                        ? "Pending.Scan.Qty"
                                                        : "P.S.Qty",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.disabled_visible_sharp,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text("Actions",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isLoading)
                            Padding(
                              padding: const EdgeInsets.only(top: 100.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (tableData.isNotEmpty)
                            ...tableData.asMap().entries.where((entry) {
                              var data = entry.value;
                              return data['pickMan_Name'] == saveloginname;
                            }).map((entry) {
                              int index = entry.key;
                              var data = entry.value;
                              // Start serial number counter

                              // Assign continuous serial number to filtered data
                              String sNo = serialNumber.toString();
                              serialNumber++; // Increment serial number for each matching entry

                              var reqid = data['reqid'].toString();
                              var pick_id = data['pick_id'].toString();
                              var pickMan_name =
                                  data['pickMan_Name'].toString();

                              var date = data['date'].toString();

                              var des_id =
                                  double.tryParse(data['des_id'].toString())
                                          ?.toInt()
                                          .toString() ??
                                      data['des_id'].toString();
                              var total =
                                  double.tryParse(data['total'].toString())
                                          ?.toInt()
                                          .toString() ??
                                      data['total'].toString();

                              var scanned_qty = double.tryParse(
                                          data['scanned_qty'].toString())
                                      ?.toInt()
                                      .toString() ??
                                  data['scanned_qty'].toString();
                              var balance_qty = double.tryParse(
                                          data['balance_qty'].toString())
                                      ?.toInt()
                                      .toString() ??
                                  data['balance_qty'].toString();

                              var status = data['status'].toString();
                              bool isEvenRow = index % 2 == 0;
                              Color? rowColor = isEvenRow
                                  ? Color.fromARGB(224, 255, 255, 255)
                                  : Color.fromARGB(224, 255, 255, 255);

                              return GestureDetector(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SelectableText(
                                                sNo,
                                                textAlign: TextAlign.left,
                                                style: TableRowTextStyle,
                                                showCursor: false,
                                                // overflow: TextOverflow.ellipsis,
                                                cursorColor: Colors.blue,
                                                cursorWidth: 2.0,
                                                toolbarOptions: ToolbarOptions(
                                                    copy: true,
                                                    selectAll: true),
                                                onTap: () {
                                                  // Optional: Handle single tap if needed
                                                },
                                              ),
                                              // Text(sNo,
                                              //     textAlign: TextAlign.center,
                                              //     style: TableRowTextStyle),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text("$pick_id",
                                                  textAlign: TextAlign.center,
                                                  style: TableRowTextStyle),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SelectableText(
                                                date,
                                                textAlign: TextAlign.left,
                                                style: TableRowTextStyle,
                                                showCursor: false,
                                                // overflow: TextOverflow.ellipsis,
                                                cursorColor: Colors.blue,
                                                cursorWidth: 2.0,
                                                toolbarOptions: ToolbarOptions(
                                                    copy: true,
                                                    selectAll: true),
                                                onTap: () {
                                                  // Optional: Handle single tap if needed
                                                },
                                              ),

                                              // Text(date,
                                              //     textAlign: TextAlign.center,
                                              //     style: TableRowTextStyle),
                                            ],
                                          ),
                                        ),
                                      ),

                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text("$des_id",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 0, 0, 0),
                                                    fontSize: 13,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text("$total",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 0, 0, 0),
                                                    fontSize: 13,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Flexible(
                                      //   child: Container(
                                      //     height: 30,
                                      //     decoration: BoxDecoration(
                                      //       color: rowColor,
                                      //       border: Border.all(
                                      //         color: Color.fromARGB(
                                      //             255, 226, 225, 225),
                                      //       ),
                                      //     ),
                                      //     child: Row(
                                      //       crossAxisAlignment:
                                      //           CrossAxisAlignment.start,
                                      //       mainAxisAlignment:
                                      //           MainAxisAlignment.start,
                                      //       children: [
                                      //         SelectableText(
                                      //           des_id,
                                      //           textAlign: TextAlign.left,
                                      //           style: TextStyle(
                                      //             color: Color.fromARGB(
                                      //                 255, 73, 72, 72),
                                      //             fontSize: 16,
                                      //           ),
                                      //           showCursor: false,
                                      //           // overflow: TextOverflow.ellipsis,
                                      //           cursorColor: Colors.blue,
                                      //           cursorWidth: 2.0,
                                      //           toolbarOptions: ToolbarOptions(
                                      //               copy: true,
                                      //               selectAll: true),
                                      //           onTap: () {
                                      //             // Optional: Handle single tap if needed
                                      //           },
                                      //         ),
                                      //         // Text(des_id,
                                      //         //     textAlign: TextAlign.center,
                                      //         //     style: TableRowTextStyle),
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ),
                                      // Flexible(
                                      //   child: Container(
                                      //     height: 30,
                                      //     decoration: BoxDecoration(
                                      //       color: rowColor,
                                      //       border: Border.all(
                                      //         color: Color.fromARGB(
                                      //             255, 226, 225, 225),
                                      //       ),
                                      //     ),
                                      //     child: Row(
                                      //       crossAxisAlignment:
                                      //           CrossAxisAlignment.start,
                                      //       mainAxisAlignment:
                                      //           MainAxisAlignment.start,
                                      //       children: [
                                      //         SelectableText(
                                      //           total,
                                      //           textAlign: TextAlign.left,
                                      //           style: TextStyle(
                                      //             color: Color.fromARGB(
                                      //                 255, 73, 72, 72),
                                      //             fontSize: 16,
                                      //           ),
                                      //           showCursor: false,
                                      //           // overflow: TextOverflow.ellipsis,
                                      //           cursorColor: Colors.blue,
                                      //           cursorWidth: 2.0,
                                      //           toolbarOptions: ToolbarOptions(
                                      //               copy: true,
                                      //               selectAll: true),
                                      //           onTap: () {
                                      //             // Optional: Handle single tap if needed
                                      //           },
                                      //         ),
                                      //         // Text(total,
                                      //         //     textAlign: TextAlign.center,
                                      //         //     style: TableRowTextStyle),
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Tooltip(
                                                message:
                                                    "Scanned Qty (Picked Qty)",
                                                child: Text("$scanned_qty",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 3, 145, 50),
                                                      fontSize: 13,
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Tooltip(
                                                message: "Pending Scan Qty",
                                                child: Text("$balance_qty",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 204, 22, 22),
                                                      fontSize: 13,
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 0.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color:
                                                          status == "Finished"
                                                              ? Colors.green
                                                              : buttonColor),
                                                  child: ElevatedButton(
                                                      onPressed: status ==
                                                              "Finished"
                                                          ? null
                                                          : () async {
                                                              widget
                                                                  .togglePage();
                                                              // Navigator.pushReplacement(
                                                              //   context,
                                                              //   MaterialPageRoute(
                                                              //     builder: (context) =>
                                                              //         MainSidebar(
                                                              //             initialPageIndex:
                                                              //                 5), // Navigate to MainSidebar
                                                              //   ),
                                                              // );

                                                              savepickno(
                                                                  pick_id);
                                                              savereqno(reqid);
                                                            },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        minimumSize: const Size(
                                                            45.0, 20.0),
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        shadowColor:
                                                            Colors.transparent,
                                                      ),
                                                      child: Responsive
                                                              .isDesktop(
                                                                  context)
                                                          ? Text(
                                                              status ==
                                                                      "Finished"
                                                                  ? "Finished"
                                                                  : 'View',
                                                              style:
                                                                  commonWhiteStyle)
                                                          : Icon(
                                                              status ==
                                                                      "Finished"
                                                                  ? Icons.check
                                                                  : Icons
                                                                      .remove_red_eye_outlined,
                                                              size: 20,
                                                              color:
                                                                  Colors.white,
                                                            )),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList()
                          else
                            Padding(
                              padding: const EdgeInsets.only(top: 100.0),
                              child: Text("No Picking detail alerted.."),
                            ),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0, // Adjust position as needed
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
                  _horizontalScrollController.animateTo(
                    _horizontalScrollController.offset -
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
                  _horizontalScrollController.animateTo(
                    _horizontalScrollController.offset +
                        100, // Adjust scroll amount
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Future<void> savereqno(String Pickman_ReqNo) async {
    await SharedPrefs.dispaatch_requestno(Pickman_ReqNo);
  }
}
