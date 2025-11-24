import 'dart:convert';

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

class DeliveredView extends StatefulWidget {
  final Function togglePage;

  DeliveredView(this.togglePage);
  @override
  State<DeliveredView> createState() => _DeliveredViewState();
}

class _DeliveredViewState extends State<DeliveredView> {
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
    filteredData = List.from(tableData); // Initialize with all datas
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
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

  void _search() {
    String searchId = salesmanIdController.text.trim();

    // Perform the filtering
    setState(() {
      filteredData = tableData
          .where((data) => data['salesman'].contains(searchId))
          .toList();
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
                  Container(
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
                                Icons.inventory_2,
                                size: 28,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Intransit Report',
                                  style: TextStyle(
                                    fontSize: 22,
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
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(0),
                                    child: Text(
                                      saveloginrole ?? 'Loading...',
                                      style: TextStyle(
                                          fontSize: 16,
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
                Padding(
                  padding: const EdgeInsets.only(
                      left: 5, right: 5, top: 5, bottom: 5),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Coming Soon..',
                          style: TextStyle(fontSize: 20),
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

  List<Map<String, dynamic>> tableData = [];

  // Future<void> fetchDispatchData() async {
  //   final url = Uri.parse('$IpAddress/Create_Dispatch/');
  //   try {
  //     final response = await http.get(url);
  //     // print('Response status: ${response.statusCode}');
  //     // print('Response body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final results = data['results'] as List?;

  //       if (results == null || results.isEmpty) {
  //         print('No results found');
  //         return; // No data to process
  //       }

  //       Map<String, Map<String, dynamic>> groupedData = {};

  //       for (var item in results) {
  //         String reqno = item['REQ_ID'];
  //         String salesmanId = item['SALESMAN_NO'].toString().split('.')[0];

  //         if (!groupedData.containsKey(reqno)) {
  //           groupedData[reqno] = {
  //             'id': item['id'],
  //             'salesman': salesmanId,
  //             'reqno': reqno,
  //             'salesmanName': item['SALESMAN_NAME'],
  //             'cusno': item['CUSTOMER_NUMBER'],
  //             'cusname': item['CUSTOMER_NAME'],
  //             'cussite': item['CUSTOMER_SITE_ID'],
  //             'total': double.parse(item['DISPATCHED_QTY'].toString()),
  //             'date': item['INVOICE_DATE'],
  //           };
  //         } else {
  //           groupedData[reqno]!['total'] +=
  //               double.parse(item['DISPATCHED_QTY'].toString());
  //         }
  //       }

  //       setState(() {
  //         tableData = groupedData.values.map((item) {
  //           return {
  //             'id': item['id'],
  //             'salesman': item['salesman'],
  //             'salesmanName': item['salesmanName'],
  //             'reqno': item['reqno'],
  //             'cusno': item['cusno'],
  //             'cusname': item['cusname'],
  //             'cussite': item['cussite'],
  //             'total': item['total'].toString(),
  //             'date':
  //                 DateFormat('dd.MM.yyyy').format(DateTime.parse(item['date'])),
  //           };
  //         }).toList();

  //         filteredData = List.from(tableData);
  //       });
  //       _filter();
  //     } else {
  //       print('Failed to load data: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   } finally {
  //     setState(() {
  //       _isLoadingData = false;
  //     });
  //   }
  // }
  Future<void> fetchDispatchData() async {
    final IpAddress = await getActiveIpAddress();

    String? nextPageUrl = '$IpAddress/Create_Dispatch/';
    Map<String, Map<String, dynamic>> groupedData = {};

    try {
      while (nextPageUrl != null && nextPageUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes); // <- fix here

          final data = jsonDecode(decodedBody);
          final results = data['results'] as List?;
          nextPageUrl =
              data['next']; // Update nextPageUrl to the next page link

          if (results == null || results.isEmpty) {
            print('No results found on this page.');
            continue; // Move to the next page if there are no results on the current one
          }

          // Process each item in the current page
          for (var item in results) {
            String reqno = item['REQ_ID'];
            String salesmanId = item['SALESMAN_NO'].toString().split('.')[0];

            if (!groupedData.containsKey(reqno)) {
              groupedData[reqno] = {
                'id': item['id'],
                'salesman': salesmanId,
                'reqno': reqno,
                'salesmanName': item['SALESMAN_NAME'],
                'cusno': item['CUSTOMER_NUMBER'],
                'cusname': item['CUSTOMER_NAME'],
                'cussite': item['CUSTOMER_SITE_ID'],
                'dis_qty_total':
                    double.parse(item['DISPATCHED_QTY'].toString()),
                'dis_mangerQty_total':
                    double.parse(item['DISPATCHED_BY_MANAGER'].toString()),
                'date': item['INVOICE_DATE'],
                'balance_qty': double.parse(item['DISPATCHED_QTY'].toString()) -
                    double.parse(item['DISPATCHED_BY_MANAGER']
                        .toString()), // Calculate balance_qty on first entry
              };
            } else {
              // Update totals for existing reqno
              groupedData[reqno]!['dis_qty_total'] +=
                  double.parse(item['DISPATCHED_QTY'].toString());
              groupedData[reqno]!['dis_mangerQty_total'] +=
                  double.parse(item['DISPATCHED_BY_MANAGER'].toString());

              // Recalculate balance_qty after updating totals
              groupedData[reqno]!['balance_qty'] =
                  groupedData[reqno]!['dis_qty_total'] -
                      groupedData[reqno]!['dis_mangerQty_total'];
            }
          }
        } else {
          print('Failed to load data from page: ${response.statusCode}');
          break;
        }
      }

      setState(() {
        // Convert groupedData to a list and format date
        tableData = groupedData.values.map((item) {
          return {
            'id': item['id'],
            'salesman': item['salesman'],
            'salesmanName': item['salesmanName'],
            'reqno': item['reqno'],
            'cusno': item['cusno'],
            'cusname': item['cusname'],
            'cussite': item['cussite'],
            'dis_qty_total': item['dis_qty_total'].toString(),
            'dis_mangerQty_total': item['dis_mangerQty_total'].toString(),
            'balance_qty': item['balance_qty'].toString(),
            'date':
                DateFormat('dd.MM.yyyy').format(DateTime.parse(item['date'])),
          };
        }).toList();

        filteredData = List.from(tableData); // Clone to filteredData if needed
      });

      // Print tableData
      print('Table Data:');
      for (var row in tableData) {
        print(row);
      }

      // Print filteredData
      print('Filtered Data:');
      for (var row in filteredData) {
        print(row);
      }

      _filter(); // Apply any additional filtering if needed
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  void _filter() {
    if (saveloginrole == 'salesman') {
      String? salesmanId = salesloginno;

      setState(() {
        filteredData =
            tableData.where((data) => data['salesman'] == salesmanId).toList();
      });
    } else {
      setState(() {
        filteredData = List.from(tableData);
      });
    }
  }

  Widget _buildTable() {
    double screenHeight = MediaQuery.of(context).size.height;

    // Helper function to create table headers
    Widget _tableHeader(String text, IconData icon) {
      return Flexible(
        child: Container(
          height: Responsive.isDesktop(context) ? 25 : 30,
          decoration: TableHeaderColor,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(icon, size: 15, color: Colors.blue),
                SizedBox(width: 2),
                Text(text,
                    textAlign: TextAlign.center, style: commonLabelTextStyle),
              ],
            ),
          ),
        ),
      );
    }

    // Helper function to create table rows
    Widget _tableRow(String data, Color? rowColor, {String? tooltipMessage}) {
      return Flexible(
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            color: rowColor,
            border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: tooltipMessage != null
                    ? Tooltip(
                        message: tooltipMessage,
                        child: Text(data,
                            textAlign: TextAlign.center,
                            style: TableRowTextStyle),
                      )
                    : Text(data,
                        textAlign: TextAlign.center, style: TableRowTextStyle),
              ),
            ],
          ),
        ),
      );
    }

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
                height:
                    Responsive.isDesktop(context) ? screenHeight * 0.7 : 400,
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.85
                    : MediaQuery.of(context).size.width * 1.7,
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _verticalScrollController,
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _tableHeader("S.No", Icons.format_list_numbered),
                            _tableHeader("Req No", Icons.print),
                            if (saveloginrole == 'supervisor' ||
                                saveloginrole == 'manager')
                              _tableHeader("Salesman No", Icons.print),
                            _tableHeader("Date", Icons.calendar_today),
                            _tableHeader("CustomerNo", Icons.category),
                            _tableHeader("Cus Name", Icons.person),
                            _tableHeader("Site No", Icons.location_on),
                            _tableHeader("Tot.Req.Qty", Icons.list),
                            // _tableHeader("Actions", Icons.call_to_action),
                          ],
                        ),
                      ),
                      if (_isLoadingData)
                        Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (filteredData.isNotEmpty)
                        ...filteredData
                            .where((data) {
                              // Parse total to a double and check if it's greater than 0
                              var dis_mangerQty_total = double.tryParse(
                                      data['dis_mangerQty_total'].toString()) ??
                                  0;
                              return dis_mangerQty_total > 0;
                            })
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                              // Convert to list and use asMap
                              int index = entry.key;
                              var data = entry.value;

                              String sNo = (index + 1).toString(); // S.No
                              String salesman = data['salesman'].toString();
                              String salesmanName =
                                  data['salesmanName'].toString();

                              String tablereqno =
                                  "ReqNo_${data['reqno'].toString()}";
                              String reqno = data['reqno'].toString();
                              String date = data['date'].toString();

                              List<String> parts =
                                  date.split('.'); // ["17", "10", "2024"]

                              // Check if the parts are valid
                              String formattedDate = "Invalid date format";
                              if (parts.length == 3) {
                                // Convert parts to integers and create a DateTime object
                                int day = int.parse(parts[0]);
                                int month = int.parse(parts[1]);
                                int year = int.parse(parts[2]);

                                // Create DateTime object
                                DateTime dateTime = DateTime(year, month, day);

                                // Format the date as needed
                                formattedDate = DateFormat('MM/dd/yyyy')
                                    .format(dateTime)
                                    .toUpperCase(); // Output: 17:OCT:2024
                              } else {
                                print("Invalid date format");
                              }

                              String cusno = data['cusno'].toString();
                              String cusname = data['cusname'].toString();
                              String cussite = data['cussite'].toString();
                              String dis_qty_total =
                                  data['dis_qty_total'].toString();
                              String dis_mangerQty_total =
                                  data['dis_mangerQty_total'].toString();
                              String balance_qty =
                                  data['balance_qty'].toString();

                              bool isEvenRow =
                                  filteredData.indexOf(data) % 2 == 0;
                              Color? rowColor = isEvenRow
                                  ? Color.fromARGB(224, 255, 255, 255)
                                  : Color.fromARGB(224, 255, 255, 255);

                              return GestureDetector(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      _tableRow(sNo, rowColor),
                                      _tableRow(tablereqno, rowColor),

                                      if (saveloginrole == 'supervisor' ||
                                          saveloginrole == 'manager')
                                        _tableRow(salesman, rowColor,
                                            tooltipMessage:
                                                salesmanName), // Pass the tooltip message

                                      _tableRow(formattedDate, rowColor),
                                      _tableRow(cusno, rowColor),
                                      _tableRow(cusname, rowColor),
                                      _tableRow(cussite, rowColor),

                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225)),
                                          ),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Tooltip(
                                                  message: "Total Dis Req Qty",
                                                  child: Text(dis_qty_total,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 37, 139, 4),
                                                        fontSize: 19,
                                                      )),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text("-",
                                                    textAlign: TextAlign.center,
                                                    style: TableRowTextStyle),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Tooltip(
                                                  message: "Balnce Qty",
                                                  child: Text(
                                                      dis_mangerQty_total,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 225, 19, 19),
                                                        fontSize: 19,
                                                      )),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text("-",
                                                    textAlign: TextAlign.center,
                                                    style: TableRowTextStyle),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Tooltip(
                                                  message:
                                                      "Already Dis Req Qty",
                                                  child: Text(balance_qty,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 176, 9, 179),
                                                        fontSize: 19,
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // _tableRow(
                                      //     "$dis_qty_total - $dis_mangerQty_total - $balance_qty",
                                      //     rowColor),
                                      // Flexible(
                                      //   child: Container(
                                      //     height: MediaQuery.of(context)
                                      //             .size
                                      //             .height *
                                      //         .042,
                                      //     decoration: BoxDecoration(
                                      //       color: rowColor,
                                      //       border: Border.all(
                                      //         color: Color.fromARGB(
                                      //             255, 226, 225, 225),
                                      //       ),
                                      //     ),
                                      //     child: Padding(
                                      //       padding: const EdgeInsets.only(
                                      //           bottom: 0.0),
                                      //       child: Row(
                                      //         mainAxisAlignment:
                                      //             MainAxisAlignment.center,
                                      //         children: [
                                      //           Container(
                                      //             decoration: BoxDecoration(
                                      //                 color: buttonColor),
                                      //             child: ElevatedButton(
                                      //               onPressed: () {
                                      //                 showDialog(
                                      //                   context: context,
                                      //                   builder: (context) {
                                      //                     return Dialog(
                                      //                       child: Container(
                                      //                         color: Colors
                                      //                             .grey[200],
                                      //                         width: MediaQuery.of(
                                      //                                     context)
                                      //                                 .size
                                      //                                 .width *
                                      //                             0.7,
                                      //                         child:
                                      //                             viewdialogbox(
                                      //                           reqno: '$reqno',
                                      //                           togglePage: widget
                                      //                               .togglePage,
                                      //                         ),
                                      //                       ),
                                      //                     );
                                      //                   },
                                      //                 );
                                      //                 savereqno(reqno);
                                      //               },
                                      //               style: ElevatedButton
                                      //                   .styleFrom(
                                      //                 shape:
                                      //                     RoundedRectangleBorder(
                                      //                   borderRadius:
                                      //                       BorderRadius
                                      //                           .circular(8),
                                      //                 ),
                                      //                 minimumSize: const Size(
                                      //                     45.0, 20.0),
                                      //                 backgroundColor:
                                      //                     Colors.transparent,
                                      //                 shadowColor:
                                      //                     Colors.transparent,
                                      //               ),
                                      //               child: Responsive.isDesktop(
                                      //                       context)
                                      //                   ? Text(
                                      //                       'View',
                                      //                       style: TextStyle(
                                      //                         fontSize: 17,
                                      //                         color:
                                      //                             Colors.white,
                                      //                       ),
                                      //                     )
                                      //                   : Icon(
                                      //                       Icons
                                      //                           .remove_red_eye_outlined,
                                      //                       size: 12,
                                      //                       color: Colors.white,
                                      //                     ),
                                      //             ),
                                      //           )
                                      //         ],
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              );
                            })
                            .toList()
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: Text("No data available."),
                        ),
                    ]),
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

class viewdialogbox extends StatefulWidget {
  final String reqno;
  // final String date;
  // final String cussite;
  // final String cusId;
  // final String customerName;
  final Function togglePage;

  viewdialogbox({
    required this.reqno,
    // required this.date,
    // required this.cussite,
    // required this.cusId,
    // required this.customerName,
    required this.togglePage,
  });

  @override
  State<viewdialogbox> createState() => _viewdialogboxState();
}

class _viewdialogboxState extends State<viewdialogbox> {
  bool _isLoading = true;

  final ScrollController _horizontalScrollController2 = ScrollController();
  final ScrollController _verticalScrollController2 = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController2.dispose();
    _verticalScrollController2.dispose();
    super.dispose();
  }

  Widget _buildTextFieldDesktop(
    String label,
    String value,
    bool readOnly, // New parameter to control read-only state
  ) {
    String formattedValue = label == 'Date' && value.isNotEmpty
        ? _formatDate(value) // Call the _formatDate function
        : value;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: Responsive.isDesktop(context) ? screenWidth * 0.15 : screenWidth,
      child: Padding(
        padding: const EdgeInsets.only(left: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 0),
            Row(
              children: [
                Text(label, style: textboxheading),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 0, bottom: 0),
              child: Row(
                children: [
                  Container(
                    height: 34,
                    width: Responsive.isDesktop(context)
                        ? screenWidth * 0.14
                        : screenWidth * 0.5,
                    child: MouseRegion(
                      onEnter: (event) {
                        // You can perform any action when mouse enters, like logging the value.
                      },
                      onExit: (event) {
                        // Perform any action when the mouse leaves the TextField area.
                      },
                      cursor: SystemMouseCursors.click,
                      child: Tooltip(
                        message: value,
                        child: TextField(
                            readOnly: readOnly, // Set readOnly state
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(201, 132, 132, 132),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 58, 58, 58),
                                  width: 1.0,
                                ),
                              ),
                              filled: true,
                              fillColor: readOnly
                                  ? Color.fromARGB(255, 234, 234,
                                      234) // Change fill color when readOnly is true
                                  : Color.fromARGB(255, 250, 250,
                                      250), // Default color when not readOnly
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0,
                              ),
                            ),
                            controller:
                                TextEditingController(text: formattedValue),
                            style: textBoxstyle),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('dd : MMM : yyyy').format(parsedDate).toUpperCase();
    } catch (e) {
      return dateString;
    }
  }

  List<Map<String, dynamic>> createtableData = [];

  TextEditingController _totalController = TextEditingController();

  TextEditingController _DateController = TextEditingController();
  TextEditingController _CusidController = TextEditingController();
  TextEditingController _CussiteController = TextEditingController();
  TextEditingController _CustomerNameController = TextEditingController();
  TextEditingController _RegionController = TextEditingController();
  TextEditingController _WarehousenameNameController = TextEditingController();

  Widget _viewbuildTable() {
    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight = Responsive.isDesktop(context) ? 25 : 30;

    List<Map<String, dynamic>> sortedTableData = List.from(createtableData);
    sortedTableData.sort((a, b) =>
        int.parse(a['id'].toString()).compareTo(int.parse(b['id'].toString())));

    List<Map<String, dynamic>> tableHeaders = [
      {'icon': Icons.receipt, 'label': 'Invoice No'},
      {'icon': Icons.category, 'label': 'Line.No'},
      {'icon': Icons.code, 'label': 'Item Code'},
      {'icon': Icons.details, 'label': 'Item Details'},
      {'icon': Icons.check, 'label': 'Qty.Invoiced'},
      {'icon': Icons.list, 'label': 'Qty.Ordered'},
      {'icon': Icons.check_circle, 'label': 'Status'},
    ];

    Widget _buildHeaderCell(Map<String, dynamic> header) {
      return Flexible(
        child: Container(
          height: containerHeight,
          color: Colors.white,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(header['icon'], size: 15, color: Colors.blue),
                  const SizedBox(width: 5),
                  Text(header['label'],
                      textAlign: TextAlign.center, style: commonLabelTextStyle),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildDataCell(String value) {
      return Flexible(
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: const Color.fromARGB(255, 226, 225, 225)),
          ),
          child: Center(
            child: Text(value,
                textAlign: TextAlign.center, style: TableRowTextStyle),
          ),
        ),
      );
    }

    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.65
                  : MediaQuery.of(context).size.width * 1.7,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: tableHeaders.map(_buildHeaderCell).toList(),
                      ),
                    ),
                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 60.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (sortedTableData.isNotEmpty)
                      ...sortedTableData.map((data) {
                        return GestureDetector(
                          onTap: () {},
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildDataCell(data['invoiceno'].toString()),
                                _buildDataCell(data['id'].toString()),
                                _buildDataCell(data['itemcode'].toString()),
                                _buildDataCell(data['itemdetails'].toString()),
                                _buildDataCell(data['invoiceqty'].toString()),
                                Flexible(
                                  child: Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 226, 225, 225)),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Tooltip(
                                            message:
                                                "Total Dispatch Request Qty",
                                            child: Text(
                                              data['itemqty'].toString(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 0, 128, 34),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "-",
                                            textAlign: TextAlign.center,
                                            style: TableRowTextStyle,
                                          ),
                                          SizedBox(width: 10),
                                          Tooltip(
                                            message:
                                                "Balance Dispatch Request Qty",
                                            child: Text(
                                              data['balitemqty'].toString(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 147, 0, 0),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                _buildDataCell(data['status'].toString()),
                              ],
                            ),
                          ),
                        );
                      }).toList()
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 60.0),
                        child: Text("No data available."),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchAccessControl();
    fetchDataReqnO();
    _loadSalesmanName();
    // _updateTotal();
    fetchDispatchDetails();
  }

  Future<void> fetchDispatchDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? reqno = prefs.getString('reqno');

    final IpAddress = await getActiveIpAddress();

    final response =
        await http.get(Uri.parse('$IpAddress/filtered_dispatchrequest/$reqno'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        var tableDetails = data[0]['TABLE_DETAILS'];

        double totalQty = 0.0;
        for (var item in tableDetails) {
          totalQty += item['DISPATCHED_QTY'];
        }

        setState(() {
          _totalController.text = totalQty.toString();
          print("total amount of the dispatchqty : ${_CusidController.text}");
        });
      }
    } else {
      throw Exception('Failed to load dispatch details');
    }
    setState(() {
      _isLoading = false;
    });
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
        final Map<String, dynamic> data = json.decode(response.body);

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

  Map<int, Map<String, dynamic>> groupedData = {}; // For grouping data
  Future<void> fetchDataReqnO() async {
    final IpAddress = await getActiveIpAddress();

    final response = await http
        .get(Uri.parse('$IpAddress/filtered_dispatchrequest/${widget.reqno}/'));

    print(
        "URL DATAS : ${"$IpAddress/filtered_dispatchrequest/${widget.reqno}/"}");
    createtableData = [];
    if (response.statusCode == 200) {
      final data = json.decode(
          response.body)[0]; // Get the first item from the response array

      // Update controllers with the fetched data
      setState(() {
        _DateController.text = data['INVOICE_DATE'] ?? '';
        _CusidController.text = data['CUSTOMER_ID']?.toString() ?? '';
        _CussiteController.text = data['CUSTOMER_SITE_ID'] ?? '';
        _CustomerNameController.text = data['CUSTOMER_NAME'] ?? '';
        _RegionController.text = data['ORG_NAME'] ?? '';
        _WarehousenameNameController.text = data['TO_WAREHOUSE'] ?? '';

        // Prepare table data
        createtableData = []; // Clear the existing data

        // Populate createtableData based on TABLE_DETAILS
        if (data['TABLE_DETAILS'] != null) {
          for (var item in data['TABLE_DETAILS']) {
            createtableData.add({
              'id': item[
                  'LINE_NUMBER'], // Assuming LINE_NUMBER exists in the item
              'invoiceno': item['INVOICE_NUMBER'] ??
                  '', // Assuming INVOICE_NUMBER exists
              'itemcode': item['INVENTORY_ITEM_ID'] ??
                  '', // Assuming INVENTORY_ITEM_ID exists
              'itemdetails': item['INVENTORY_ITEM_ID'] ??
                  '', // Assuming ITEM_DETAILS exists
              'invoiceqty': item['TOT_QUANTITY']
                  .toString(), // Assuming TOT_QUANTITY exists
              'itemqty': item['DISPATCHED_QTY'].toString(),
              'balitemqty': item['DISPATCHED_BY_MANAGER'].toString(),
              // Assuming DISPATCHED_QTY exists
              'status': item['STATUS'] ?? 'Pending', // Defaulting to 'N.F'
            });
          }
        }

        // Group data based on REQ_ID
        int reqno = data['REQ_ID'];
        if (!groupedData.containsKey(reqno)) {
          // Initialize a new entry for this reqno
          groupedData[reqno] = {
            'id': data['LINE_NUMBER'],
            'invoiceno': data['INVOICE_NUMBER'],
            'itemcode': data['INVENTORY_ITEM_ID'],
            'itemdetails': data['INVENTORY_ITEM_ID'],
            'invoiceqty': data['TOT_QUANTITY'],
            'itemqty': data['DISPATCHED_QTY'],
            'status': 'Pending',
            'total': 0.0, // Initialize total
          };
        }

        // Update the total for this reqno based on the TABLE_DETAILS
        for (var item in createtableData) {
          groupedData[reqno]!['total'] += double.parse(item['invoiceqty']);
        }

        // Print values to verify
        // print("Date: ${_DateController.text}");
        // print("Customer ID: ${_CusidController.text}");
        // print("Customer Site ID: ${_CussiteController.text}");
        // print("Customer Name: ${_CustomerNameController.text}");
        // print("Region: ${_RegionController.text}");
        // print("Warehouse Name: ${_WarehousenameNameController.text}");
        // print("Table Data: $createtableData");
        // print("Grouped Data: $groupedData");
      });
    } else {
      print('Failed to load dispatch request details: ${response.statusCode}');
    }
  }

  // void _updateTotal() {
  //   double totalQuantity = getTotalFinalAmt(createtableData);
  //   _totalController.text =
  //       totalQuantity.toStringAsFixed(2); // Format to 2 decimal places
  //   print("Total quantity: ${_totalController.text}"); // Print for debugging
  // }

  // double getTotalFinalAmt(List<Map<String, dynamic>> createtableData) {
  //   double totalQuantity = 0.0;
  //   for (var data in createtableData) {
  //     double quantity =
  //         double.tryParse(data['itemqty']?.toString() ?? '0') ?? 0.0;
  //     totalQuantity += quantity; // Add to total quantity
  //   }
  //   return totalQuantity; // Return the total quantity
  // }

// Function to update the total item quantity based on createtableData
  void _updateTotal() {
    double totalSendQuantity = 0.0;

    for (int i = 0; i < createtableData.length; i++) {
      // Parse the 'itemqty' from createtableData and calculate the total
      double enteredQty =
          double.tryParse(createtableData[i]['itemqty']?.toString() ?? '0') ??
              0.0;
      totalSendQuantity += enteredQty; // Add to the total send quantity
    }

    // Print or return the calculated total (for display, logging, etc.)
    print("Total send quantity: ${totalSendQuantity.toStringAsFixed(2)}");
  }

// Function to get the total send quantity from table data
  double gettotalsendqty(List<Map<String, dynamic>> createtableData) {
    double totalQuantity = 0.0;
    for (var data in createtableData) {
      // Calculate the total for 'itemqty' in createtableData
      double quantity =
          double.tryParse(data['itemqty']?.toString() ?? '0') ?? 0.0;
      totalQuantity += quantity;
    }
    return totalQuantity; // Return the total calculated quantity
  }

  String? salesloginrole = '';
  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      salesloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        width: Responsive.isDesktop(context)
            ? screenWidth * 0.6
            : screenWidth * 0.9,
        height: 650,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("View Dispatch Request Details",
                  style: topheadingbold),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  runSpacing: 5,
                  children: [
                    _buildTextFieldDesktop(
                        'Dis.Req No', "ReqNo_${widget.reqno}", true),
                    _buildTextFieldDesktop('Physical Warehouse',
                        _WarehousenameNameController.text, true),
                    _buildTextFieldDesktop(
                        'Region', _RegionController.text, true),
                    _buildTextFieldDesktop('Date', _DateController.text, true),
                    _buildTextFieldDesktop(
                        'Customer No', _CusidController.text, true),
                    _buildTextFieldDesktop(
                        'Customer Name', _CustomerNameController.text, true),
                    _buildTextFieldDesktop(
                        'Customer Site', _CussiteController.text, true),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Container(
                        height: 240,
                        decoration: BoxDecoration(
                          color: Colors
                              .white, // You can adjust the background color here
                          border: Border.all(
                            color: Colors.grey[400]!, // Border color
                            width: 1.0, // Border width
                          ),
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          controller: _horizontalScrollController2,
                          child: SingleChildScrollView(
                            controller: _horizontalScrollController2,
                            scrollDirection: Axis.horizontal,
                            child: _viewbuildTable(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Responsive.isDesktop(context)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: 50,
                              left: MediaQuery.of(context).size.width * 0.03),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (salesloginrole == 'supervisor' ||
                                  salesloginrole == 'manager')
                                Container(
                                  width: 180,
                                  decoration: BoxDecoration(color: buttonColor),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      widget.togglePage();
                                      // Navigator.pushReplacement(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => MainSidebar(
                                      //         initialPageIndex:
                                      //             3), // Navigate to MainSidebar
                                      //   ),
                                      // );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      backgroundColor: buttonColor,
                                      minimumSize: const Size(
                                          45.0, 40.0), // Set width and height
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: const Text(
                                        'Generate Picking',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 17),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Right Side - Total Send Qty Section
                        Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.02),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 10,
                                    right: Responsive.isDesktop(context)
                                        ? MediaQuery.of(context).size.width *
                                            0.05
                                        : 0),
                                child: _buildTextFieldDesktop("Total Order Req",
                                    _totalController.text, true),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Wrap(
                      alignment: WrapAlignment.start,
                      children: [
                        // Right Side - Total Send Qty Section
                        _buildTextFieldDesktop("Total Order Req", "281", true),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 50,
                              left: MediaQuery.of(context).size.width * 0.03),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 180,
                                decoration: BoxDecoration(color: buttonColor),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MainSidebar(
                                            enabledItems: accessControl,
                                            initialPageIndex:
                                                3), // Navigate to MainSidebar
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: buttonColor,
                                    minimumSize: const Size(
                                        45.0, 40.0), // Set width and height
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: const Text(
                                      'Generate Picking',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
