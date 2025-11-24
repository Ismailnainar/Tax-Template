import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_svg/flutter_svg.dart';

import 'dart:io'; // for File
import 'dart:ui';
import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'dart:convert';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;

class CommercialReports extends StatefulWidget {
  @override
  State<CommercialReports> createState() => _CommercialReportsState();
}

class _CommercialReportsState extends State<CommercialReports> {
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

    fetchInvoicedetailsData();
    fetchsalesmandetails();
    postLogData("Dispatch Request", "Opened");
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();

    postLogData("Dispatch Request", "Closed");
  }

  String? saveloginname = '';

  String? saveloginrole = '';
  String? salesloginno = '';

  String? commersialname = '';

  String? commersialrole = '';
  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
      saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
      salesloginno = prefs.getString('salesloginno') ?? 'Unknown ID';
      commersialrole =
          prefs.getString('commersialrole') ?? 'Unknown commersialrole';
      commersialname =
          prefs.getString('commersialname') ?? 'Unknown commersialname';
    });
  }

  bool isLoading = true;
  String errorMessage = "";

  List<Map<String, dynamic>> viewtableData = [];
  bool _isLoading = false;
  // Function to fetch dispatch data
  Future<void> fetchDispatchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? commersialno = prefs.getString('commersialno');

    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/CommericialDispatch/$commersialno/';
    print("Fetching data from URL: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');

        // Decode the JSON response
        final List<dynamic> data = json.decode(response.body);

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

  List<String> getDisplayedColumns() {
    return [
      'REQ_ID',
      'INVOICE_DATE',
      'COMMERCIAL_NO',
      'COMMERCIAL_NAME',
      'CUSTOMER_NUMBER',
      'CUSTOMER_NAME',
      'CUSTOMER_SITE_ID',
      'DISPATCHED_QTY',
    ];
  }

  List<String> SalesmanNo_list = [];

  String error = '';
  Future<void> fetchsalesmandetails() async {
    print("Entered fetchsalesmandetails()");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? commersialrole = prefs.getString('commersialrole');

    String? commersialno = prefs.getString('commersialno');

    setState(() {
      isLoading = true;
      error = '';
    });

    final IpAddress = await getActiveIpAddress();

    // Decide salesrep_id based on role
    String salesrep_idurl = commersialrole == "Sales Supervisor"
        ? '$IpAddress/Get_sales_Supervisor_access/3/$commersialno/'
        : '$IpAddress/salesrep/-3/';
    String apiUrl = salesrep_idurl;

    final url = Uri.parse('$salesrep_idurl');
    print("Fetching salesmen from: $url");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          // Filter by ORG_ID (which comes as double like 101.0, so compare as string)
          List<String> filteredList = data
              .map<String>((item) {
                String salesmanNo = item['SALESMAN_NO'] ?? '';
                return '$salesmanNo';
              })
              .toSet() // Remove duplicates
              .toList();
          {
            // Populate the SalesmanNo_list with all salesmen
            setState(() {
              SalesmanNo_list = filteredList;
            });
            print("Filtered Salesman List: $SalesmanNo_list");
          }
        } else {
          setState(() {
            error = 'Invalid data format from API.';
          });
          print("Invalid data format from API");
        }
      } else {
        setState(() {
          error = 'Failed to load data. Status code: ${response.statusCode}';
        });
        print("HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        error = 'Error occurred: $e';
      });
      print("Exception: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> invoicedetailstabledata =
      []; // List to store fetched data
  // Future<void> fetchInvoicedetailsData() async {
  //   await fetchsalesmandetails();
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String salesloginrole = prefs.getString('salesloginrole') ?? 'Unknown ID';

  //   // Convert List<int> to comma-separated string
  //   String salesmanNumbers = SalesmanNo_list.join(',');
  //   print("salesmanNumbersssssssssssss  $salesmanNumbers");

  //   final IpAddress = await getActiveIpAddress();

  //   List<Map<String, dynamic>> allData = []; // To store all fetched data
  //   String? nextUrl =
  //       '$IpAddress/Rport_Undelivery_data/?salesmanno=$salesmanNumbers';
  //   print("nextUrlllllllllllll  $nextUrl");
  //   try {
  //     while (nextUrl != null) {
  //       final response = await http.get(Uri.parse(nextUrl));

  //       if (response.statusCode == 200) {
  //         var decodedData = json.decode(response.body);

  //         if (decodedData is Map<String, dynamic> &&
  //             decodedData.containsKey('results')) {
  //           // Append results to allData
  //           allData.addAll(
  //               List<Map<String, dynamic>>.from(decodedData['results']));

  //           // Get next page URL (could be null)
  //           nextUrl = decodedData['next'];
  //         } else {
  //           print('Invalid response format or missing "results" key.');
  //           break;
  //         }
  //       } else {
  //         throw Exception('Failed to load data from $nextUrl');
  //       }
  //     }

  //     // Update UI after fetching all data
  //     setState(() {
  //       invoicedetailstabledata = allData;
  //       isLoading = false;
  //     });

  //     print('Fetched all pages. Total records: ${allData.length}');
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     print('Error fetching data: $e');
  //   }
  // }

  // Future<void> fetchInvoicedetailsData() async {
  //   await fetchsalesmandetails();
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String salesmanno = prefs.getString('salesloginno') ?? 'Unknown ID';
  //   String salesloginrole = prefs.getString('salesloginrole') ?? 'Unknown ID';
  //   // String salesmanstatus =
  //   //     salesloginrole == 'Salesman' ? '?salesmanno=$salesmanno' : '';
  //   String salesmanNumbers = SalesmanNo_list.join(',');
  //   print("salesmanNumbersssssssssssss  $salesmanNumbers");

  //   final IpAddress = await getActiveIpAddress();

  //   List<Map<String, dynamic>> allData = []; // To store all fetched data
  //   String? nextUrl =
  //       '$IpAddress/Rport_Undelivery_data/?salesmanno=$salesmanNumbers';

  //   print("Fetching data from: $nextUrl");

  //   // Show the loading dialog
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         content: Row(
  //           children: [
  //             CircularProgressIndicator(),
  //             SizedBox(width: 20),
  //             Text("Processing... Kindly wait"),
  //           ],
  //         ),
  //       );
  //     },
  //   );

  //   try {
  //     while (nextUrl != null) {
  //       final response = await http.get(Uri.parse(nextUrl));

  //       if (response.statusCode == 200) {
  //         var decodedData = json.decode(response.body);

  //         if (decodedData is Map<String, dynamic> &&
  //             decodedData.containsKey('results')) {
  //           allData.addAll(
  //               List<Map<String, dynamic>>.from(decodedData['results']));
  //           nextUrl = decodedData['next'];
  //         } else {
  //           print('Invalid response format or missing "results" key.');
  //           break;
  //         }
  //       } else {
  //         throw Exception('Failed to load data from $nextUrl');
  //       }
  //     }

  //     setState(() {
  //       invoicedetailstabledata = allData;
  //       isLoading = false;
  //     });

  //     print('Fetched all pages. Total records: ${allData.length}');
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   } finally {
  //     Navigator.of(context).pop(); // Close the loading dialog
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  Future<void> fetchInvoicedetailsData() async {
    await fetchsalesmandetails();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String salesmanno = prefs.getString('salesloginno') ?? 'Unknown ID';
    String salesloginrole = prefs.getString('salesloginrole') ?? 'Unknown ID';
    String salesmanNumbers = SalesmanNo_list.join(',');
    print("salesmanNumbersssssssssssss  $salesmanNumbers");

    String salesmanstatus = 'salesmanno=$salesmanNumbers';

    final IpAddress = await getActiveIpAddress();

    // Construct first URL (add ? or & properly)
    String nextUrl = '$IpAddress/Rport_Undelivery_data/?$salesmanstatus';

    List<Map<String, dynamic>> allData = [];

    print("Start fetching paginated data...");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Processing... Kindly wait"),
            ],
          ),
        );
      },
    );

    try {
      while (nextUrl.isNotEmpty && nextUrl != "null") {
        print("Fetching page: $nextUrl");
        final response = await http.get(Uri.parse(nextUrl));

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);

          if (decoded is Map<String, dynamic> &&
              decoded.containsKey('results')) {
            allData.addAll(List<Map<String, dynamic>>.from(decoded['results']));

            // Update next URL
            nextUrl = decoded['next']?.toString() ?? '';
          } else {
            print("Unexpected format. 'results' key not found.");
            break;
          }
        } else {
          print("HTTP error ${response.statusCode}");
          break;
        }
      }

      setState(() {
        invoicedetailstabledata = allData;
        isLoading = false;
      });

      print("✅ All pages fetched. Total records: ${allData.length}");
    } catch (e) {
      print("❌ Error while fetching data: $e");
    } finally {
      Navigator.of(context).pop(); // Close loading dialog
    }
  }

  Future<void> createExcelinvoicedetails(
      List<String> columnNames, List<List<dynamic>> data) async {
    // print("dataaaaaaaaaaa $data");
    final Workbook workbook = Workbook();
    try {
      final Worksheet sheet = workbook.worksheets[0];

      // Get today's date in dd-MM-yyyy format
      final DateTime today = DateTime.now();
      final String formattedToday = DateFormat('dd-MMM-yyyy').format(today);

      // Main heading
      final Range titleRange = sheet.getRangeByIndex(1, 1);
      titleRange.setText('Invoice Report (Undelivered Datas)');
      titleRange.cellStyle
        ..fontSize = 16
        ..bold = true;
      titleRange.cellStyle.hAlign = HAlignType.left; // Left align title
      sheet.getRangeByIndex(1, 1, 1, columnNames.length).merge();

      // Subheading with date
      final Range subTitleRange = sheet.getRangeByIndex(3, 1);
      subTitleRange.setText('ALJE Undelivered As On : $formattedToday');
      subTitleRange.cellStyle
        ..fontSize = 12
        ..italic = true;
      subTitleRange.cellStyle.hAlign = HAlignType.left; // Left align subtitle
      sheet.getRangeByIndex(2, 1, 2, columnNames.length).merge();

      // Column headers at row 5
      for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
        final Range range = sheet.getRangeByIndex(5, colIndex + 1);
        range.setText(columnNames[colIndex]);
        range.cellStyle
          ..backColor = '#E7F3FD'
          ..fontColor = '#000000'
          ..bold = true
          ..borders.all.lineStyle = LineStyle.thin
          ..borders.all.color = '#000000'
          ..hAlign = HAlignType.left; // Left align headers
      }

      // Table data from row 6
      for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
        final List<dynamic> rowData = data[rowIndex];
        for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
          final Range range = sheet.getRangeByIndex(rowIndex + 6, colIndex + 1);
          final cellValue = rowData[colIndex];

          // Apply correct data type
          if (cellValue == null) {
            range.setText('');
          } else if (cellValue is num) {
            if (cellValue % 1 == 0) {
              // It's an integer
              range.setNumber(cellValue.toDouble());
              range.numberFormat = '0'; // Format for whole numbers
            } else {
              // It's a decimal number
              range.setNumber(cellValue.toDouble());
              range.numberFormat = '#,##0.00'; // Format for decimal numbers
            }
          } else if (cellValue is DateTime) {
            range.setDateTime(cellValue);
            range.numberFormat = 'DD-MMM-YYYY'; // Format for dates
          } else {
            range.setText(cellValue.toString());
          }

          // Apply styling
          range.cellStyle
            ..borders.all.lineStyle = LineStyle.thin
            ..borders.all.color = '#000000'
            ..hAlign = HAlignType.left; // Left align all data
        }
      }

      // Auto-fit columns
      for (int i = 1; i <= columnNames.length; i++) {
        sheet.autoFitColumn(i);
      }

      final List<int> bytes = workbook.saveAsStream();

      String timestamp = '$formattedToday Time '
          '${today.hour.toString().padLeft(2, '0')}hh-${today.minute.toString().padLeft(2, '0')}mm-${today.second.toString().padLeft(2, '0')}ss';
      if (kIsWeb) {
        final blob = base64.encode(bytes);
        AnchorElement(
          href: 'data:application/octet-stream;charset=utf-16le;base64,$blob',
        )
          ..setAttribute('download', 'Invoice details($timestamp).xlsx')
          ..click();
      } else {
        final String path = (await getApplicationSupportDirectory()).path;
        final String fileName = Platform.isWindows
            ? '$path\\Excel Invoice details($timestamp).xlsx'
            : '$path/Excel Invoice details($timestamp).xlsx';

        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);
        OpenFile.open(fileName);
      }
    } catch (e) {
      print('Error in createExcel: $e');
      rethrow;
    } finally {
      try {
        workbook.dispose();
      } catch (e) {
        print('Error disposing workbook: $e');
      }
    }
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
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                  child: Container(
                    height: screenheight * 0.8,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey[400]!,
                        width: 1.0,
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 45, right: 20),
                                child: SizedBox(
                                  height: 30,
                                  child: PopupMenuButton<String>(
                                    offset: Offset(0,
                                        20), // Adjusted position for the shorter button
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    itemBuilder: (BuildContext context) => [
                                      PopupMenuItem(
                                        value: 'ud',
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/images/excel.svg',
                                              width: 18,
                                              height: 18,
                                              color: buttonColor,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'Undelivered Invoice Details',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onSelected: (String value) async {
                                      if (value == 'ud') {
                                        if (invoicedetailstabledata
                                            .isNotEmpty) {
                                          List<String> columnHeaders =
                                              invoicedetailstabledata.first.keys
                                                  .toList();
                                          List<List<dynamic>> convertedData =
                                              invoicedetailstabledata
                                                  .map((map) {
                                            return columnHeaders
                                                .map((header) => map[header])
                                                .toList();
                                          }).toList();
                                          await createExcelinvoicedetails(
                                              columnHeaders, convertedData);
                                          postLogData("Report Invoice",
                                              "Export Underlivered invoice Report");
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Undelivered invoices exported successfully'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text('Data Loaded Failed...'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'No dispatch invoice data available'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }

                                      postLogData(
                                          "Sales Supervisor Report Invoice",
                                          "Export Button");
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 7), // Reduced padding
                                      decoration: BoxDecoration(
                                        color: buttonColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/excel.svg',
                                            width: 18, // Slightly smaller icon
                                            height: 18,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 6), // Reduced spacing
                                          Text(
                                            'Export',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize:
                                                  14, // Slightly smaller font
                                            ),
                                          ),
                                          SizedBox(width: 2), // Reduced spacing
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.white,
                                            size: 18, // Smaller icon
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.end,
                          //   children: [
                          //     Container(
                          //       width: 180,
                          //       child: Padding(
                          //         padding: const EdgeInsets.only(
                          //             top: 10.0, right: 20),
                          //         child: Container(
                          //           height: 35,
                          //           decoration:
                          //               BoxDecoration(color: buttonColor),
                          //           child: Padding(
                          //             padding: const EdgeInsets.only(
                          //                 left: 5, right: 5, top: 3, bottom: 3),
                          //             child: ElevatedButton(
                          //               onPressed: () async {
                          //                 List<List<dynamic>> convertedData =
                          //                     viewtableData.map((map) {
                          //                   return [
                          //                     map['REQ_ID'],
                          //                     map['INVOICE_DATE'],
                          //                     map['COMMERCIAL_NO'],
                          //                     map['COMMERCIAL_NAME'],
                          //                     map['CUSTOMER_NUMBER'],
                          //                     map['CUSTOMER_NAME'],
                          //                     map['CUSTOMER_SITE_ID'],
                          //                     map['DISPATCHED_QTY'],
                          //                   ];
                          //                 }).toList();
                          //                 // Check if the data is empty
                          //                 if (viewtableData.isEmpty) {
                          //                   // Show dialog if no data is available
                          //                   showDialog(
                          //                     context: context,
                          //                     builder: (BuildContext context) {
                          //                       return AlertDialog(
                          //                         title: Text('Error'),
                          //                         content: Text(
                          //                             'No data available to export.!!'),
                          //                         actions: [
                          //                           TextButton(
                          //                             onPressed: () {
                          //                               Navigator.of(context)
                          //                                   .pop(); // Close the dialog
                          //                             },
                          //                             child: Text('OK'),
                          //                           ),
                          //                         ],
                          //                       );
                          //                     },
                          //                   );
                          //                   return; // Exit if data is empty
                          //                 }
                          //                 List<String> columnNames =
                          //                     getDisplayedColumns();
                          //                 // await createExcel(
                          //                 //     columnNames, convertedData);
                          //               },
                          //               style: ElevatedButton.styleFrom(
                          //                 shape: RoundedRectangleBorder(
                          //                   borderRadius:
                          //                       BorderRadius.circular(8),
                          //                 ),
                          //                 minimumSize: const Size(45.0, 15.0),
                          //                 backgroundColor: Colors.transparent,
                          //                 shadowColor: Colors.transparent,
                          //               ),
                          //               child: Row(
                          //                 children: [
                          //                   Padding(
                          //                     padding: const EdgeInsets.only(
                          //                         right: 8),
                          //                     child: SvgPicture.asset(
                          //                       'assets/images/excel.svg',
                          //                       width: 20,
                          //                       height: 20,
                          //                       color: Colors.white,
                          //                     ),
                          //                   ),
                          //                   Text(
                          //                     "Export",
                          //                     style: commonWhiteStyle,
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),

                          _buildTable()
                        ],
                      ),
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

  // Future<void> createExcel(
  //     List<String> columnNames, List<List<dynamic>> data) async {
  //   try {
  //     final Workbook workbook = Workbook();
  //     final Worksheet sheet = workbook.worksheets[0];

  //     for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
  //       final Range range = sheet.getRangeByIndex(1, colIndex + 1);
  //       range.setText(columnNames[colIndex]);
  //       range.cellStyle.backColor = '#550A35';
  //       range.cellStyle.fontColor = '#F5F5F5';
  //     }

  //     for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
  //       final List<dynamic> rowData = data[rowIndex];
  //       for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
  //         final Range range = sheet.getRangeByIndex(rowIndex + 2, colIndex + 1);
  //         range.setText(rowData[colIndex].toString());
  //       }
  //     }

  //     final List<int> bytes = workbook.saveAsStream();

  //     try {
  //       workbook.dispose();
  //     } catch (e) {
  //       print('Error during workbook disposal: $e');
  //     }

  //     final now = DateTime.now();
  //     final formattedDate =
  //         '${now.day}-${now.month}-${now.year} Time ${now.hour}-${now.minute}-${now.second}';

  //     if (kIsWeb) {
  //       AnchorElement(
  //           href:
  //               'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
  //         ..setAttribute(
  //             'download', 'SalesSupervisorReport ($formattedDate).xlsx')
  //         ..click();
  //     } else {
  //       final String path = (await getApplicationSupportDirectory()).path;
  //       final String fileName = Platform.isWindows
  //           ? '$path\\Excel SalesSupervisorReport ($formattedDate).xlsx'
  //           : '$path/Excel SalesSupervisorReport ($formattedDate).xlsx';
  //       final File file = File(fileName);
  //       await file.writeAsBytes(bytes, flush: true);
  //       OpenFile.open(fileName);
  //     }
  //   } catch (e) {
  //     print('Error in createExcel: $e');
  //   }
  // }

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

    // Helper function to create table headers
    Widget _tableSNoHeader(String text, IconData icon) {
      return Flexible(
        child: Container(
          width: 70,
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

    // Helper function to create table headers
    Widget _tableCusNameHeader(String text, IconData icon) {
      return SingleChildScrollView(
        child: Container(
          width: 250,
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

    // Helper function to create table headers
    Widget _tableCussiteHeader(String text, IconData icon) {
      return SingleChildScrollView(
        child: Container(
          width: 100,
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
                          child:
                              //  Text(data,
                              //     textAlign: TextAlign.center,
                              //     style: TableRowTextStyle),
                              SelectableText(
                            data,
                            textAlign: TextAlign.center,
                            style: TableRowTextStyle,
                            showCursor: false,
                            toolbarOptions:
                                ToolbarOptions(copy: true, selectAll: true),
                            onTap: () {
                              // Optional: Handle single tap if needed
                            },
                          ))
                      : SelectableText(
                          data,
                          textAlign: TextAlign.center,
                          style: TableRowTextStyle,
                          showCursor: false,
                          toolbarOptions:
                              ToolbarOptions(copy: true, selectAll: true),
                          onTap: () {
                            // Optional: Handle single tap if needed
                          },
                        )
                  // Text(data,
                  //     textAlign: TextAlign.center, style: TableRowTextStyle),
                  ),
            ],
          ),
        ),
      );
    }

    Widget _tableSNoRow(String data, Color? rowColor,
        {String? tooltipMessage}) {
      return Flexible(
        child: Container(
          width: 70,
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
                          child:
                              //  Text(data,
                              //     textAlign: TextAlign.center,
                              //     style: TableRowTextStyle),
                              SelectableText(
                            data,
                            textAlign: TextAlign.center,
                            style: TableRowTextStyle,
                            showCursor: false,
                            toolbarOptions:
                                ToolbarOptions(copy: true, selectAll: true),
                            onTap: () {
                              // Optional: Handle single tap if needed
                            },
                          ))
                      : SelectableText(
                          data,
                          textAlign: TextAlign.center,
                          style: TableRowTextStyle,
                          showCursor: false,
                          toolbarOptions:
                              ToolbarOptions(copy: true, selectAll: true),
                          onTap: () {
                            // Optional: Handle single tap if needed
                          },
                        )
                  // Text(data,
                  //     textAlign: TextAlign.center, style: TableRowTextStyle),
                  ),
            ],
          ),
        ),
      );
    }

    Widget _tableReqNoRow(String data, Color? rowColor,
        {String? tooltipMessage}) {
      return Flexible(
        child: Container(
          // width: 140,
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
                          child:
                              //  Text(data,
                              //     textAlign: TextAlign.center,
                              //     style: TableRowTextStyle),
                              SelectableText(
                            data,
                            textAlign: TextAlign.center,
                            style: TableRowTextStyle,
                            showCursor: false,
                            toolbarOptions:
                                ToolbarOptions(copy: true, selectAll: true),
                            onTap: () {
                              // Optional: Handle single tap if needed
                            },
                          ))
                      : SelectableText(
                          data,
                          textAlign: TextAlign.center,
                          style: TableRowTextStyle,
                          showCursor: false,
                          toolbarOptions:
                              ToolbarOptions(copy: true, selectAll: true),
                          onTap: () {
                            // Optional: Handle single tap if needed
                          },
                        )
                  // Text(data,
                  //     textAlign: TextAlign.center, style: TableRowTextStyle),
                  ),
            ],
          ),
        ),
      );
    }

    Widget _tableCusNameRow(String data, Color? rowColor,
        {String? tooltipMessage}) {
      return Container(
        width: 250, // Set a fixed width for the column
        height: 30, // Adjust row height as needed
        decoration: BoxDecoration(
          color: rowColor,
          border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: tooltipMessage != null
                    ? Tooltip(
                        message: tooltipMessage,
                        child: SelectableText(
                          data,
                          maxLines: 1, // Restrict to a single line
                          // overflow: TextOverflow
                          //     .ellipsis, // Add ellipsis for overflow
                          textAlign: TextAlign.center,
                          style: TableRowTextStyle,
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
                        //   maxLines: 1, // Restrict to a single line
                        //   overflow: TextOverflow
                        //       .ellipsis, // Add ellipsis for overflow
                        //   textAlign: TextAlign.center,
                        //   style: TableRowTextStyle,
                        // ),
                      )
                    : SelectableText(
                        data,
                        maxLines: 1, // Restrict to a single line
                        // overflow: TextOverflow
                        //     .ellipsis, // Add ellipsis for overflow
                        textAlign: TextAlign.center,
                        style: TableRowTextStyle,
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
                //     data,
                //     maxLines: 1, // Restrict to a single line
                //     overflow:
                //         TextOverflow.ellipsis, // Add ellipsis for overflow
                //     textAlign: TextAlign.center,
                //     style: TableRowTextStyle,
                //   ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _tableCussiteRow(String data, Color? rowColor,
        {String? tooltipMessage}) {
      return Container(
        width: 100, // Set a fixed width for the column
        height: 30, // Adjust row height as needed
        decoration: BoxDecoration(
          color: rowColor,
          border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: tooltipMessage != null
                    ? Tooltip(
                        message: tooltipMessage,
                        child: SelectableText(
                          data,
                          maxLines: 1, // Restrict to a single line
                          // overflow: TextOverflow
                          //     .ellipsis, // Add ellipsis for overflow
                          textAlign: TextAlign.center,
                          style: TableRowTextStyle,
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
                        //   maxLines: 1, // Restrict to a single line
                        //   overflow: TextOverflow
                        //       .ellipsis, // Add ellipsis for overflow
                        //   textAlign: TextAlign.center,
                        //   style: TableRowTextStyle,
                        // ),
                      )
                    : SelectableText(
                        data,
                        maxLines: 1, // Restrict to a single line
                        // overflow: TextOverflow
                        //     .ellipsis, // Add ellipsis for overflow
                        textAlign: TextAlign.center,
                        style: TableRowTextStyle,
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
                //     data,
                //     maxLines: 1, // Restrict to a single line
                //     overflow:
                //         TextOverflow.ellipsis, // Add ellipsis for overflow
                //     textAlign: TextAlign.center,
                //     style: TableRowTextStyle,
                //   ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _tablestatusRow(String data, Color? rowColor,
        {String? tooltipMessage}) {
      return Container(
        width: 150, // Set a fixed width for the column
        height: 30, // Adjust row height as needed
        decoration: BoxDecoration(
          color: rowColor,
          border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: tooltipMessage != null
                    ? Tooltip(
                        message: tooltipMessage,
                        child: SelectableText(
                          data,
                          maxLines: 1, // Restrict to a single line
                          // overflow: TextOverflow
                          //     .ellipsis, // Add ellipsis for overflow
                          textAlign: TextAlign.center,
                          style: TableRowTextStyle,
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
                        //   maxLines: 1, // Restrict to a single line
                        //   overflow: TextOverflow
                        //       .ellipsis, // Add ellipsis for overflow
                        //   textAlign: TextAlign.center,
                        //   style: TableRowTextStyle,
                        // ),
                      )
                    : SelectableText(
                        data,
                        maxLines: 1, // Restrict to a single line
                        // overflow: TextOverflow
                        //     .ellipsis, // Add ellipsis for overflow
                        textAlign: TextAlign.center,
                        style: TableRowTextStyle,
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
                //     data,
                //     maxLines: 1, // Restrict to a single line
                //     overflow:
                //         TextOverflow.ellipsis, // Add ellipsis for overflow
                //     textAlign: TextAlign.center,
                //     style: TableRowTextStyle,
                //   ),
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
                    : MediaQuery.of(context).size.width * 3,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _tableSNoHeader("S.No", Icons.format_list_numbered),
                        _tableHeader("Req No", Icons.print),
                        _tableHeader("CommercialNo", Icons.print),
                        _tableHeader("Date", Icons.calendar_today),
                        _tableHeader("Customer No", Icons.category),
                        _tableCusNameHeader("Cus Name", Icons.person),
                        _tableCussiteHeader("Site No", Icons.location_on),
                        _tableHeader("Status", Icons.list),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 100.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (viewtableData.isNotEmpty)
                    ...viewtableData.asMap().entries.map((entry) {
                      int index = entry.key;
                      var data = entry.value;

                      String sNo = (index + 1).toString(); // S.No
                      String reqid = data['REQ_ID'].toString();
                      String date = data['INVOICE_DATE'].toString();

                      String commericialno = data['COMMERCIAL_NO'].toString();

                      String commercialname =
                          data['COMMERCIAL_NAME'].toString();

                      String customerno = data['CUSTOMER_NUMBER'].toString();

                      String customername = data['CUSTOMER_NAME'].toString();
                      String customersiteid =
                          data['CUSTOMER_SITE_ID'].toString();
                      String dispatch_qty = data['DISPATCHED_QTY'].toString();

                      List<String> parts =
                          date.split('.'); // ["17", "10", "2024"]
                      bool isEvenRow = filteredData.indexOf(data) % 2 == 0;
                      Color? rowColor = isEvenRow
                          ? Color.fromARGB(224, 255, 255, 255)
                          : Color.fromARGB(224, 255, 255, 255);

                      String formattedDate = "Invalid date format";
                      try {
                        // Parse the ISO 8601 date string
                        DateTime dateTime = DateTime.parse(date);

                        // Format the date as "24-DEC-2024"
                        formattedDate = DateFormat('dd-MMM-yyyy')
                            .format(dateTime)
                            .toUpperCase();
                      } catch (e) {
                        print("Error parsing date: $e");
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GestureDetector(
                          onTap: () {
                            // Action on row tap (e.g., show details)
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _tableSNoRow(sNo, rowColor),
                              _tableReqNoRow(reqid, rowColor),
                              _tableRow(commericialno, rowColor,
                                  tooltipMessage: commercialname),
                              _tableRow(formattedDate, rowColor),
                              _tableRow(customerno, rowColor),
                              _tableCusNameRow(customername, rowColor),
                              _tableCussiteRow(customersiteid, rowColor),
                              _tablestatusRow(dispatch_qty, rowColor),
                            ],
                          ),
                        ),
                      );
                    }).toList()
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text("No req found.."),
                    ),
                ]),
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
