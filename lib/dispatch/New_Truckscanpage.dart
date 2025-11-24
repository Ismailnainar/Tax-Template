import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:aljeflutterapp/components/constaints.dart';

class TruckScanList extends StatefulWidget {
  final Function togglePage;
  final String reqno;
  final String pickno;

  final String cusno;
  final String cusname;
  final String cussite;
  final String pickedqty;

  TruckScanList(this.togglePage, this.reqno, this.pickno, this.cusno,
      this.cusname, this.cussite, this.pickedqty);

  @override
  State<TruckScanList> createState() => _TruckScanListState();
}

class _TruckScanListState extends State<TruckScanList> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final TextEditingController ProductCodeController = TextEditingController();

  TextEditingController scannedqtyController = TextEditingController(text: '0');
  final TextEditingController salesserialnoController = TextEditingController();

  List<Map<String, dynamic>> filteredData = [];
  // List<Map<String, dynamic>> tableData = [];

  bool BypassALertButton = false;

  bool NoProductCodeButton = false;

  bool NoSerialNoButton = false;
  @override
  void initState() {
    super.initState();
    filteredData = List.from(tableData);
    fetchAccessControl();
    _loadSalesmanName();
    FetchLastDipatchNo();
    fetchDispatchData();
    fetchDataAndSetControllers();
    postLogData("Truck Loading Scan", "Opened");
    fetchPreviousLoadCount(widget.reqno, widget.pickno);

    scannedqtyController.text = filteredData.length.toString();
    print(
        "Scanned Qtyyyyyyyyyyyyyyyyy ${widget.pickedqty}  ${scannedqtyController.text}");
  }

  bool _isLoadingData = true;

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

  _updateCurrentLoadCount() {
    setState(() {
      final filteredCount = filteredData
          .where((item) => item['scan_status'] != 'Request for Delivery')
          .length;
      CurrentLoadController.text = filteredCount.toString();
      // print("Filtered data used for count: $filteredData");
    });
  }

  void dispose() {
    ProductCodeController.dispose();
    salesserialnoController.dispose();
    productCodeFocusNode.dispose();
    serialNoFocusNode.dispose();
    addButtonFocusNode.dispose();

    postLogData("Truck Loading Scan", "Closed");
    super.dispose();
  }

  TextEditingController totcountunderreqController = TextEditingController();

  calculatebalanceqty() {
    int totalCount = int.tryParse(totcountunderreqController.text.trim()) ?? 0;
    int pickedQty = int.tryParse(widget.pickedqty.trim()) ?? 0;

// Subtract to get balance quantity
    balanceQty = pickedQty - totalCount;

// Optional: Show result in a Text widget or print
    print("✅ Balance Qty: $balanceQty");
    print(
        "totcountunderreqController.text ${totcountunderreqController.text}  ${widget.pickedqty}");
  }

  int balanceQty = 0;
  Future<void> fetchDispatchData() async {
    String disreqno =
        Dispatch_idController.text.isNotEmpty ? Dispatch_idController.text : '';
    String disReqNoValue =
        disreqno.split('_').last; // Extract value after last underscore

    final IpAddress = await getActiveIpAddress();

    // Constructing the URL for the API request
    final String url =
        '$IpAddress/filteredToGetGenerateDispatchView/${widget.reqno}/${widget.cusno}/${widget.cussite}/';
    print("URL for the generate scan truck man: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
        final List<dynamic> responseData = json.decode(decodedBody);

        // Check if the response is a list (as per the response pattern provided)
        if (responseData is List) {
          int sno = 1;

          setState(() {
            tableData = responseData.map((item) {
              return {
                'id': item['id'], // Map 'id' from the response
                'sno': sno++, // Auto-increment serial number

                'req_no': item['req_no'], // Map Customer_no
                'pick_id': item['pick_id'], // Map Customer_name
                'cusno': item['Customer_no'], // Map Customer_no
                'cusname': item['Customer_name'], // Map Customer_name
                'cussite': item['Customer_Site'], // Map Customer_Site
                'invoiceno': item['invoice_no'], // Map invoice_no
                'itemcode': item['Item_code'],
                'itemdetails': item['Item_detailas'], // Map Item_code
                'disreqqty': item['DisReq_Qty'], // Map DisReq_Qty
                'productcode': item['Product_code'], // Map Product_code
                'serialno': item['Serial_No'], // Map Serial_No
                'scan_status': item['SCAN_STATUS'],
              };
            }).toList();
            // filteredData = List.from(tableData);y
            filteredData = tableData
                .where((item) => item['pick_id'] == widget.pickno)
                .toList();
            if (filteredData != null) {
              totcountunderreqController.text = filteredData.length.toString();
            }

            _updateCurrentLoadCount();

            scannedqtyController.text = filteredData.length.toString();
          });

          // print("Filtered table data: $filteredData");
        } else {
          print("Error: Response data is not a list.");
        }
      } else {
        throw Exception('Failed to load dispatch data');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  TextEditingController Dispatch_idController = TextEditingController();

  bool _isLoading = true;

  Future<void> FetchLastDipatchNo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno');

    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/Truck_scan_DispatchNo/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String lastReqNo = data['DISPATCH_ID']?.toString() ?? '0';
        int newReqNo =
            int.tryParse(lastReqNo) != null ? int.parse(lastReqNo) + 1 : 1;
        Dispatch_idController.text = newReqNo.toString();
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching request number: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final TextEditingController SalesmanNoController = TextEditingController();
  final TextEditingController SalesmanNameController = TextEditingController();
  final TextEditingController ManagerNoController = TextEditingController();
  final TextEditingController ManagerNameController = TextEditingController();
  final TextEditingController PickManNoController = TextEditingController();
  final TextEditingController PickManNameAController = TextEditingController();

  final TextEditingController Reqnocontroller = TextEditingController();

  final TextEditingController UdelIdontroller = TextEditingController();

  final TextEditingController PickIdcontroller = TextEditingController();
  final TextEditingController CusNoController = TextEditingController();
  final TextEditingController CusNameController = TextEditingController();
  final TextEditingController CusSiteController = TextEditingController();
  final TextEditingController TotalQtyController = TextEditingController();
  final TextEditingController InvoiceDateController = TextEditingController();
  final TextEditingController InvoiceNoController = TextEditingController();
  final TextEditingController ItemCodeController = TextEditingController();
  final TextEditingController ItemDetailsController = TextEditingController();
  final TextEditingController SerialNoproductController =
      TextEditingController();
  final TextEditingController TableProductCodeController =
      TextEditingController();

  final TextEditingController RequestQtyController = TextEditingController();
  final TextEditingController ScannedQtyController = TextEditingController();
  final TextEditingController PreviousLoadController = TextEditingController();

  final TextEditingController LiveTruckincountController =
      TextEditingController();
  final TextEditingController CurrentLoadController = TextEditingController();
  final TextEditingController CustomerTrxLineIdController =
      TextEditingController();
  final TextEditingController CustomerTrxIdController = TextEditingController();
  final TextEditingController LineNoController = TextEditingController();

  Future<void> fetchDataAndSetControllers() async {
    final IpAddress = await getActiveIpAddress();

    String? url = '$IpAddress/Filtered_livestagereports/';
    try {
      List<dynamic> allResults = [];

      // Fetch all paginated data
      while (url != null) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          final List<dynamic> results = jsonResponse['results'] ?? [];
          allResults.addAll(results);
          url = jsonResponse['next']; // Set next page URL
        } else {
          print('Failed to fetch data. Status code: ${response.statusCode}');
          break;
        }
      }
      // print('Alllllllllllll fetched data: $allResults');

      // Filter the data
      final filteredData = allResults.firstWhere(
        (item) =>
            item['PICK_ID'] == widget.pickno &&
            item['REQ_ID'] == widget.reqno &&
            item['CUSTOMER_NUMBER'] == widget.cusno &&
            item['CUSTOMER_NAME'] == widget.cusname &&
            item['CUSTOMER_SITE_ID'] == widget.cussite,
        orElse: () => null, // Returns null if no match is found
      );

      // print('filteredData fetched data: $filteredData');
      if (filteredData != null) {
        // Set values to the controllers
        setState(() {
          RequestQtyController.text =
              double.parse(filteredData['DISPATCHED_QTY'].toString())
                  .toStringAsFixed(0);
          ScannedQtyController.text =
              double.parse(filteredData['PICKED_QTY'].toString())
                  .toStringAsFixed(0);
          print('Request Qty: ${RequestQtyController.text}');
          print('Scanned Qty: ${ScannedQtyController.text}');
        });

        // Print the controller values
        print('Request Qty: ${RequestQtyController.text}');
        print('Scanned Qty: ${ScannedQtyController.text}');
      } else {
        print('Noooooooooooooooooooooo matching data found.');
      }
    } catch (e) {
      print('Errorrrrrrrrrrrrrrrrr fetching data: $e');
    }
  }

  Future<void> fetchPreviousLoadCount(String reqno, String pickid) async {
    final IpAddress = await getActiveIpAddress();
    final String url = '$IpAddress/Truck_scan/?REQ_NO=$reqno&PICK_ID=$pickid';

    print("Fetching URL: $url");

    int totalCount = 0;
    bool hasNextPage = true;
    String? nextPageUrl = url;

    setState(() {
      _isLoading = true;
    });

    try {
      while (hasNextPage && nextPageUrl != null) {
        final response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);

          // Check and iterate over results
          if (responseData.containsKey('results')) {
            final List<dynamic> results = responseData['results'];
            for (var item in results) {
              if (item['FLAG'] == 'A') {
                totalCount++;
              }
            }
          }

          // Get next page URL
          nextPageUrl = responseData['next'];
          hasNextPage = nextPageUrl != null;
        } else {
          throw Exception('Failed to fetch data from server');
        }
      }

      // Update the controller with the total count of FLAG: "A"
      setState(() {
        PreviousLoadController.text = totalCount.toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching previous load count: $e');
    }
  }

  int reqno = 0;
  // Future<void> _addTableData() async {
  //   String productCode = 'empty';
  //   String serialNo = 'empty';
  //   String dispatch_id = Dispatch_idController.text.trim();

  //   final IpAddress = await getActiveIpAddress();
  //   String url =
  //       '$IpAddress/Pickman_Productcode/${widget.reqno}/$productCode/$serialNo/';
  //   print("Fetching data from URL: $url");

  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     print("Response: ${response.body}");

  //     if (response.statusCode == 200) {
  //       final decodedBody = utf8.decode(response.bodyBytes);
  //       List<dynamic> data = jsonDecode(decodedBody);

  //       if (data.isNotEmpty) {
  //         List<Map<String, dynamic>> newEntries = [];

  //         for (var item in data) {
  //           // ✅ Only process if PICK_ID matches widget.pickno
  //           if (item['PICK_ID'].toString().trim() != widget.pickno.trim()) {
  //             print(
  //                 "Skipping item with PICK_ID: ${item['PICK_ID']} (mismatch)");
  //             continue;
  //           }

  //           bool alreadyExists = tableData.any((existingItem) =>
  //               existingItem['reqno'] == item['REQ_ID'] &&
  //               existingItem['pickid'] == item['PICK_ID'] &&
  //               existingItem['productcode'] == item['PRODUCT_CODE'] &&
  //               existingItem['serialno'] == item['SERIAL_NO']);

  //           if (alreadyExists) {
  //             print(
  //                 "Data with product code ${item['PRODUCT_CODE']} and serial number ${item['SERIAL_NO']} already exists. Skipping.");
  //             continue;
  //           }

  //           // Validate essential customer-related fields
  //           if ((item['CUSTOMER_NAME'] != widget.cusname.trim()) ||
  //               (item['PICK_ID'] != widget.pickno.trim()) ||
  //               (item['REQ_ID'] != widget.reqno.trim()) ||
  //               (item['CUSTOMER_NUMBER'] != widget.cusno.trim()) ||
  //               (item['CUSTOMER_SITE_ID'] != widget.cussite.trim())) {
  //             // Optionally show dialog for mismatch – skipping here for bulk processing
  //             print("Mismatch found. Skipping item: ${item['PRODUCT_CODE']}");
  //             continue;
  //           }

  //           // Build entry for the table
  //           newEntries.add({
  //             'id': item['id'],
  //             "dispatchId": dispatch_id,
  //             'salesman': ProductCodeController.text,
  //             'reqno': item['REQ_ID'],
  //             'pickid': item['PICK_ID'],
  //             'salesmanName': item['SALESMAN_NAME'],
  //             'cusno': item['CUSTOMER_NUMBER'],
  //             'cusname': item['CUSTOMER_NAME'],
  //             'cussite': item['CUSTOMER_SITE_ID'],
  //             'total': item['DISPATCHED_QTY'],
  //             'date': item['INVOICE_DATE'],
  //             'line_no': item['LINE_NUMBER'],
  //             'invoiceno': item['INVOICE_NUMBER'],
  //             'itemcode': item['INVENTORY_ITEM_ID'],
  //             'itemdetails': item['ITEM_DESCRIPTION'],
  //             'productcode': item['PRODUCT_CODE'],
  //             'dispatch_id': item['DISPATCHED_QTY'],
  //             'serialno': item['SERIAL_NO'],
  //             'udel_id': item['UNDEL_ID'],
  //           });

  //           // Assign the first item’s data to controllers
  //           if (newEntries.length == 1) {
  //             Reqnocontroller.text = item['REQ_ID'];
  //             UdelIdontroller.text = item['UNDEL_ID'];
  //             PickIdcontroller.text = item['PICK_ID'];
  //             TableProductCodeController.text = item['PRODUCT_CODE'];
  //             SerialNoproductController.text = item['SERIAL_NO'];
  //             RequestQtyController.text = item['DISPATCHED_QTY'];
  //             ScannedQtyController.text = item['PICKED_QTY'];
  //             SalesmanNoController.text = item['SALESMAN_NO'];
  //             SalesmanNameController.text = item['SALESMAN_NAME'];
  //             ManagerNoController.text = item['MANAGER_NO'];
  //             ManagerNameController.text = item['MANAGER_NAME'];
  //             PickManNoController.text = item['PICKMAN_NO'];
  //             PickManNameAController.text = item['PICKMAN_NAME'];
  //             CustomerTrxIdController.text = item['CUSTOMER_TRX_ID'];
  //             CustomerTrxLineIdController.text = item['CUSTOMER_TRX_LINE_ID'];
  //             LineNoController.text = item['LINE_NUMBER'];
  //             CusNoController.text = item['CUSTOMER_NUMBER'];
  //             CusNameController.text = item['CUSTOMER_NAME'];
  //             CusSiteController.text = item['CUSTOMER_SITE_ID'];
  //             TotalQtyController.text = item['DISPATCHED_QTY'].toString();
  //             InvoiceDateController.text = item['INVOICE_DATE'];
  //             InvoiceNoController.text = item['INVOICE_NUMBER'];
  //             ItemCodeController.text = item['INVENTORY_ITEM_ID'];
  //             ItemDetailsController.text = item['ITEM_DESCRIPTION'];
  //           }
  //         }

  //         print("PickIdcontroller.text ${PickIdcontroller.text}");

  //         if (newEntries.isNotEmpty) {
  //           setState(() {
  //             tableData.addAll(newEntries);
  //             filteredData = List.from(tableData);
  //             scannedqtyController.text = tableData.length.toString();
  //           });
  //         } else {
  //           print("No new valid entries to add.");
  //         }
  //       } else {
  //         print("No data returned from API.");
  //       }
  //     } else {
  //       print("Failed to fetch data. Status code: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Error occurred while fetching data: $e");
  //   }
  // }

  Future<void> _addTableData({required int balanceCount}) async {
    String productCode = 'empty';
    String serialNo = 'empty';
    String dispatch_id = Dispatch_idController.text.trim();

    print("balnacve count in add button $balanceCount");

    final IpAddress = await getActiveIpAddress();
    String url =
        '$IpAddress/Pickman_Productcode/${widget.reqno}/$productCode/$serialNo/';
    print("Fetching data from URL: $url");

    try {
      final response = await http.get(Uri.parse(url));
      // print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> data = jsonDecode(decodedBody);

        if (data.isNotEmpty) {
          List<Map<String, dynamic>> newEntries = [];

          for (var item in data) {
            if (newEntries.length == balanceCount) {
              break; // ✅ Stop if balance count reached
            }

            // ✅ Only process if PICK_ID matches
            if (item['PICK_ID'].toString().trim() != widget.pickno.trim()) {
              print(
                  "Skipping item with PICK_ID: ${item['PICK_ID']} (mismatch)");
              continue;
            }

            bool alreadyExists = tableData.any((existingItem) =>
                existingItem['reqno'] == item['REQ_ID'] &&
                existingItem['pickid'] == item['PICK_ID'] &&
                existingItem['productcode'] == item['PRODUCT_CODE'] &&
                existingItem['serialno'] == item['SERIAL_NO']);

            if (alreadyExists) {
              print(
                  "Already exists: ${item['PRODUCT_CODE']} - ${item['SERIAL_NO']}");
              continue;
            }

            // ✅ Validate customer-related fields
            if ((item['CUSTOMER_NAME'] != widget.cusname.trim()) ||
                (item['PICK_ID'] != widget.pickno.trim()) ||
                (item['REQ_ID'] != widget.reqno.trim()) ||
                (item['CUSTOMER_NUMBER'] != widget.cusno.trim()) ||
                (item['CUSTOMER_SITE_ID'] != widget.cussite.trim())) {
              print(
                  "Customer mismatch. Skipping item: ${item['PRODUCT_CODE']}");
              continue;
            }

            // ✅ Add new entry
            newEntries.add({
              'id': item['id'],
              "dispatchId": dispatch_id,
              'salesman': ProductCodeController.text,
              'reqno': item['REQ_ID'],
              'pickid': item['PICK_ID'],
              'salesmanName': item['SALESMAN_NAME'],
              'cusno': item['CUSTOMER_NUMBER'],
              'cusname': item['CUSTOMER_NAME'],
              'cussite': item['CUSTOMER_SITE_ID'],
              'total': item['DISPATCHED_QTY'],
              'date': item['INVOICE_DATE'],
              'line_no': item['LINE_NUMBER'],
              'invoiceno': item['INVOICE_NUMBER'],
              'customer_trx_id': item['CUSTOMER_TRX_ID'],
              'customer_trx_line_id': item['CUSTOMER_TRX_LINE_ID'],
              'itemcode': item['INVENTORY_ITEM_ID'],
              'itemdetails': item['ITEM_DESCRIPTION'],
              'productcode': item['PRODUCT_CODE'],
              'dispatch_id': item['DISPATCHED_QTY'],
              'serialno': item['SERIAL_NO'],
              'udel_id': item['UNDEL_ID'],
              'is_sent': false,
            });

            if (newEntries.length == 1) {
              // Fill controllers only once
              Reqnocontroller.text = item['REQ_ID'];
              UdelIdontroller.text = item['UNDEL_ID'];
              PickIdcontroller.text = item['PICK_ID'];
              TableProductCodeController.text = item['PRODUCT_CODE'];
              SerialNoproductController.text = item['SERIAL_NO'];
              RequestQtyController.text = item['DISPATCHED_QTY'];
              ScannedQtyController.text = item['PICKED_QTY'];
              SalesmanNoController.text = item['SALESMAN_NO'];
              SalesmanNameController.text = item['SALESMAN_NAME'];
              ManagerNoController.text = item['MANAGER_NO'];
              ManagerNameController.text = item['MANAGER_NAME'];
              PickManNoController.text = item['PICKMAN_NO'];
              PickManNameAController.text = item['PICKMAN_NAME'];
              CustomerTrxIdController.text = item['CUSTOMER_TRX_ID'];
              CustomerTrxLineIdController.text = item['CUSTOMER_TRX_LINE_ID'];
              LineNoController.text = item['LINE_NUMBER'];
              CusNoController.text = item['CUSTOMER_NUMBER'];
              CusNameController.text = item['CUSTOMER_NAME'];
              CusSiteController.text = item['CUSTOMER_SITE_ID'];
              TotalQtyController.text = item['DISPATCHED_QTY'].toString();
              InvoiceDateController.text = item['INVOICE_DATE'];
              InvoiceNoController.text = item['INVOICE_NUMBER'];
              ItemCodeController.text = item['INVENTORY_ITEM_ID'];
              ItemDetailsController.text = item['ITEM_DESCRIPTION'];
            }
          }

          print("PickIdcontroller.text ${PickIdcontroller.text}");

          if (newEntries.isNotEmpty) {
            setState(() {
              tableData.addAll(newEntries);
              filteredData = List.from(tableData);
              scannedqtyController.text = tableData.length.toString();
            });
          } else {
            print("No new valid entries to add.");
          }
        } else {
          print("No data returned from API.");
        }
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred while fetching data: $e");
    }
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

  Future<void> showButtonTruckDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String salesloginno = prefs.getString('salesloginno') ?? 'Unknown Salesman';
    final IpAddress = await getActiveIpAddress();
    final url = Uri.parse("$IpAddress/Show_button_truck_details/");
    String dispatch_id = Dispatch_idController.text.isNotEmpty
        ? Dispatch_idController.text
        : '0';
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "dispatch_id": dispatch_id,
          "reqid": Reqnocontroller.text.trim(),
          "pickid": PickIdcontroller.text.trim(),
          "loadman_no": salesloginno,
          "loadman_name": saveloginname,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("✅ Success: ${data['message']}");
        print("Inserted ReqID: ${data['reqid']}, PickID: ${data['pickid']}");
      } else {
        print("❌ Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Exception: $e");
    }
  }

  // Future<void> _sendDataToApi({required int balanceCount}) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String salesloginno = prefs.getString('salesloginno') ?? 'Unknown Salesman';
  //   try {
  //     String dispatch_id = Dispatch_idController.text.isNotEmpty
  //         ? Dispatch_idController.text
  //         : '0';

  //     final IpAddress = await getActiveIpAddress();

  //     // ✅ Get only unsent items for this reqno & pickid
  //     List<Map<String, dynamic>> filteredByPick = filteredData
  //         .where((item) =>
  //             item['pickid'].toString() == widget.pickno &&
  //             item['reqno'].toString() == widget.reqno &&
  //             (item['is_sent'] != true)) // ✅ Only unsent items
  //         .toList();

  //     if (filteredByPick.isEmpty) {
  //       print("❗ No unsent items available.");
  //       return;
  //     }

  //     // ✅ Limit to balanceCount only
  //     List<Map<String, dynamic>> toSend =
  //         filteredByPick.take(balanceCount).toList();

  //     print("✅ Sending ${toSend.length} of $balanceCount unsent items...");

  //     for (int i = 0; i < toSend.length; i++) {
  //       final item = toSend[i];

  //       final dataToSend = {
  //         "dispatch_id": dispatch_id,
  //         "req_no": Reqnocontroller.text.trim(),
  //         "pick_id": PickIdcontroller.text.trim(),
  //         "salesman_no": SalesmanNoController.text.trim(),
  //         "salesman_name": SalesmanNameController.text.trim(),
  //         "loadman_no": salesloginno,
  //         "loadman_name": saveloginname,
  //         "manager_no": ManagerNoController.text.trim(),
  //         "manager_name": ManagerNameController.text.trim(),
  //         "pickman_no": PickManNoController.text.trim(),
  //         "pickman_name": PickManNameAController.text.trim(),
  //         "Customer_no": CusNoController.text.trim(),
  //         "Customer_name": CusNameController.text.trim(),
  //         "Customer_Site": CusSiteController.text.trim(),
  //         "invoice_no": item['invoiceno'],
  //         "Item_code": item['itemcode'],
  //         "line_no": item['line_no'],
  //         "Item_detailas": item['itemdetails'],
  //         "Customer_trx_id": item['customer_trx_id'],
  //         "Customer_trx_line_id": item['customer_trx_line_id'],
  //         "DisReq_Qty": item['total'].toString(),
  //         "Send_qty": "1",
  //         "Product_code": item['productcode'],
  //         "Serial_No": item['serialno'],
  //         "Udel_id": item['udel_id'],
  //       };

  //       // print("➡️ Sending item ${i + 1}/${toSend.length}");

  //       final response = await http.post(
  //         Uri.parse('$IpAddress/ToGetGenerateDispatchView/'),
  //         headers: {'Content-Type': 'application/json'},
  //         body: jsonEncode(dataToSend),
  //       );

  //       if (response.statusCode == 201) {
  //         // print("✅ Successfully sent item ${i + 1}");

  //         // ✅ Mark item as sent in `filteredData`
  //         int index = filteredData.indexOf(item);
  //         if (index != -1) {
  //           filteredData[index]['is_sent'] = true;
  //         }
  //       } else {
  //         print(
  //             "❌ Failed to send item ${i + 1}. Status: ${response.statusCode}, Body: ${response.body}");
  //       }
  //     }

  //     print("✅ Finished sending available balance items.");
  //     await fetchDispatchData(); // Optional refresh
  //   } catch (e, stacktrace) {
  //     print("❌ Error during send: $e");
  //     print(stacktrace);
  //   }
  // }

// Declare FocusNodes
  FocusNode productCodeFocusNode = FocusNode();
  FocusNode serialNoFocusNode = FocusNode();
  FocusNode addButtonFocusNode = FocusNode();

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget _buildTextFieldDesktop(
    String label,
    String value,
    bool readOnly, // New parameter to control read-only state
  ) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: Responsive.isDesktop(context)
          ? screenWidth * 0.15
          : screenWidth * 0.5,
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
                    height: 33,
                    width: Responsive.isDesktop(context)
                        ? screenWidth * 0.14
                        : screenWidth * 0.45,
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
                            controller: TextEditingController(text: value),
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

  bool isLoading = false;
  String resultMessage = "";
  bool isSuccess = false;

  Future<void> updateScanStatus() async {
    setState(() {
      isLoading = true;
      resultMessage = "";
    });

    int scannedCount = filteredData.where((data) {
      final productCode = (data['productcode'] ?? '').toString().toLowerCase();
      final serialNo = (data['serialno'] ?? '').toString().toLowerCase();
      return productCode != 'empty' || serialNo != 'empty';
    }).length;

    postLogData("Truck Loading Scan",
        "Request for Delivery with $scannedCount quantities For RequestNo ${widget.reqno} and Pickid ${widget.pickno}");
    String Status = 'Request for Delivery';
    final IpAddress = await getActiveIpAddress();
    try {
      final url = Uri.parse(
          "$IpAddress/update-scan-status/${widget.reqno}/${widget.pickno}/${widget.cusno}/${widget.cussite}/$Status/");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          isSuccess = true;
          resultMessage = "Status updated successfully!";
        });
        SaveReturnProducts();
      } else {
        setState(() {
          isSuccess = false;
          resultMessage = "Error: ${response.statusCode} - ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        isSuccess = false;
        resultMessage = "Exception: ${e.toString()}";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  SaveReturnProducts() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Row(
            children: [
              Icon(Icons.check_box_rounded,
                  color: Color.fromARGB(255, 3, 158, 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Success Send the request to delivery',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // widget.onClear();
                Navigator.of(context).pop();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainSidebar(
                      initialPageIndex: 17,
                      enabledItems: accessControl,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(30.0, 28.0),
              ),
              child: Text(
                'Ok',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  bool noProductCheckbox = false; // Add this to your state
  bool noSerialCheckbox = false; // Add this to your state

// Count of completed scans (green cards)
  int get completedCount {
    return filteredData.where((item) {
      return item['scan_status'] != 'Request for Delivery' &&
          item['productcode']?.toString() != 'empty' &&
          item['serialno']?.toString() != 'empty';
    }).length;
  }

// Count of valid items (excluding 'Request for Delivery')
  int get totalValidItems {
    return filteredData.where((item) {
      return item['scan_status'] != 'Request for Delivery';
    }).length;
  }

// Pending items calculation
  int get pendingQty {
    return totalValidItems - completedCount;
  }

  @override
  Widget build(BuildContext context) {
    String Totalitems = scannedqtyController.text;
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
                                  Icons.qr_code,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Truck Loading Scan',
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
                    height: MediaQuery.of(context).size.height * 0.83,
                    decoration: BoxDecoration(
                      color: Colors
                          .white, // You can adjust the background color here
                      border: Border.all(
                        color: Colors.grey[400]!, // Border color
                        width: 1.0, // Border width
                      ),

                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16, left: 16, bottom: 10),
                            child: Responsive.isDesktop(context)
                                ? _buildDesktopView(screenWidth)
                                : _buildMobileView(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Text(
                                    '* Click Show button for view items',
                                    style: TextStyle(
                                        color: Colors.green, fontSize: 12),
                                  )),
                            ],
                          ),
                          if (!Responsive.isDesktop(context))
                            SizedBox(
                              height: 10,
                            ),
                          Padding(
                            padding: Responsive.isDesktop(context)
                                ? const EdgeInsets.only(
                                    top: 5, left: 16, bottom: 10)
                                : EdgeInsets.only(top: 5, left: 30, bottom: 10),
                            child: Wrap(
                              spacing: 10, // Horizontal space between elements
                              runSpacing: 10, // Vertical space between rows
                              alignment: WrapAlignment.start,
                              children: [
                                _buildActionButton(
                                  context,
                                  label: 'Show',
                                  onPressed: () async {
                                    _handleAddButtonPressed();
                                  },
                                ),
                                // Clear Button
                                // _buildActionButton(
                                //   context,
                                //   label: 'Clear',
                                //   onPressed: () {
                                //     setState(() {
                                //       ProductCodeController.clear();
                                //       salesserialnoController.clear();
                                //       filteredData = List.from(
                                //           tableData); // Reset filtered data
                                //     });
                                //     print("Refresh button pressed");
                                //     postLogData(
                                //         "Truck Loading Scan", "Clear Details");
                                //   },
                                // ),

                                // Load More Button
                                _buildActionButton(
                                  context,
                                  label: 'Load More',
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MainSidebar(
                                          initialPageIndex: 17,
                                          enabledItems: accessControl,
                                        ),
                                      ),
                                    );
                                    postLogData("Truck Loading Scan",
                                        "Move to Live Stage Page");
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (!Responsive.isDesktop(context))
                            Padding(
                                padding: EdgeInsets.only(
                                    top: 16, left: 16, bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Scanned Quantity
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: Colors.green, width: 1),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            size: 14,
                                            color: Colors.green,
                                          ),
                                          SizedBox(
                                            width: 3,
                                          ),
                                          Text(
                                            'Scanned: $completedCount',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Pending Quantity
                                    Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: Colors.red, width: 1),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.pending_actions,
                                              size: 14,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 3),
                                            Text(
                                              'Pending: $pendingQty',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          Padding(
                            padding: const EdgeInsets.only(right: 10, left: 10),
                            child: _buildTable(),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(top: 16, left: 16, bottom: 10),
                            child: Text("Total Items : ${Totalitems}",
                                style: TextStyle(fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 5, left: 16, bottom: 10),
                            child: Container(
                              decoration: BoxDecoration(color: buttonColor),
                              height: 30,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final filteredTable = tableData
                                      .where((data) =>
                                          data['scan_status'] !=
                                          'Request for Delivery')
                                      .toList();

                                  final scanfilteredTable =
                                      tableData.where((data) {
                                    final productCode =
                                        data['productcode']?.toString().trim();
                                    final serialNo =
                                        data['serialno']?.toString().trim();
                                    return (productCode != 'empty') &&
                                        (serialNo != "empty") &&
                                        data['scan_status'] !=
                                            'Request for Delivery';
                                  }).toList();
                                  print("scanfilteredTable $scanfilteredTable");

                                  if (filteredTable.isEmpty) {
                                    showValidationDialog(context);
                                  }
                                  if (scanfilteredTable.isEmpty) {
                                    showscanValidationDialog(context);
                                  } else {
                                    updateScanStatus();

                                    // await DeleteDispatchData();
                                    // await _sendDataToApi();
                                    // await widget.togglePage(
                                    //   widget.reqno,
                                    //   widget.pickno,
                                    //   widget.cusno,
                                    //   widget.cusname,
                                    //   widget.cussite,
                                    //   widget.pickedqty,
                                    // );
                                  }
                                  // Navigator.pushReplacement(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => MainSidebar(
                                  //         initialPageIndex:
                                  //             7), // Navigate to MainSidebar
                                  //   ),
                                  // );
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(45.0, 20.0),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0, bottom: 0, left: 8, right: 8),
                                  child: const Text(
                                    'Request for Delivery',
                                    style: commonWhiteStyle,
                                  ),
                                ),
                              ),
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
        ),
      ),
    );
  }

  Widget _buildDesktopView(double screenWidth) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTextFieldDesktop("Customer No", widget.cusno, true),
          _buildTextFieldDesktop("Customer Name", widget.cusname, true),
          _buildTextFieldDesktop("Customer Site", widget.cussite, true),
          SizedBox(
            width: 10,
          ),
          // _buildQuantityField("Request Qty", RequestQtyController, screenWidth),
          // SizedBox(
          //   width: 10,
          // ),
          // _buildQuantityField("Picked Qty", ScannedQtyController, screenWidth),
          // SizedBox(
          //   width: 10,
          // ),
          // _buildQuantityField(
          //     "Previous Load", PreviousLoadController, screenWidth),
          // SizedBox(
          //   width: 10,
          // ),
          _buildQuantityField(
              "Current Load", CurrentLoadController, screenWidth),
        ],
      ),
    );
  }

  Widget _buildMobileView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child:
                      _buildTextFieldMobile("Customer No", widget.cusno, true)),
              Expanded(
                  child: _buildTextFieldMobile(
                      "Customer Site", widget.cussite, true)),
            ],
          ),
          SizedBox(height: 10), // Space between rows
          _buildTextFieldMobile("Customer Name", widget.cusname, true),
          SizedBox(height: 10), // Space between fields
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Expanded(
          //         child: _buildQuantityFieldMobile(
          //             "Request Qty", RequestQtyController)),
          //     Expanded(
          //         child: _buildQuantityFieldMobile(
          //             "Picked Qty", ScannedQtyController)),
          //   ],
          // ),
          // SizedBox(height: 10), // Space between rows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Expanded(
              //     child: _buildQuantityFieldMobile(
              //         "Previous Load", PreviousLoadController)),
              Expanded(
                  child: _buildQuantityFieldMobile(
                      "Current Load", CurrentLoadController)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldMobile(
    String label,
    String value,
    bool readOnly,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
      child: Container(
        height: 34,
        child: TextField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Color.fromARGB(255, 213, 250, 212),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          controller: TextEditingController(text: value),
          style: textBoxstyle,
        ),
      ),
    );
  }

  Widget _buildQuantityField(
      String label, TextEditingController controller, double screenWidth) {
    return Container(
      width: screenWidth * 0.075,
      child: Padding(
        padding: const EdgeInsets.only(left: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textboxheading),
            SizedBox(height: 10),
            Container(
              height: 33,
              child: TextField(
                readOnly: true,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(201, 132, 132, 132), width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 58, 58, 58), width: 1.0),
                  ),
                  filled: true,
                  fillColor: Color.fromARGB(255, 213, 250, 212),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 10.0),
                ),
                controller: controller,
                style: textBoxstyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityFieldMobile(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 33,
            child: TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color.fromARGB(255, 213, 250, 212),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
              controller: controller,
              style: textBoxstyle,
            ),
          ),
        ],
      ),
    );
  }

  void showConfirmationDialog(BuildContext context) async {
    print("filtereddatassssss $filteredData");

    bool hasBypassData = filteredData.any((row) =>
        row['productcode'] == '00' &&
        row['serialno'] == "null" &&
        row['req_no'] == widget.reqno &&
        row['pick_id'] == widget.pickno);

    if (hasBypassData) {
      // Show bypass exists message
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Already Exists',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content:
                Text('This Product Code and Serial No is already Exist!!!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Show confirmation dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Confirmation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: Text(
                'No Product with no SerialNo in stage do you want to load into truck.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  print("Action canceled");
                },
                child: Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  await fetchDispatchData();
                  await _updateCurrentLoadCount();
                  setState(() {
                    BypassALertButton = false;
                  });
                  print("Action confirmed");
                },
                child: Text('Yes'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showScanSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
      ),
    );
  }

// Helper function to check if serial number exists in a paginated API
  Future<bool> checkIfSerialExistsInPaginatedApi(
    String apiUrl,
    String sendreqno,
    String sendpickid,
    String serialNo, {
    String? productCode,
  }) async {
    String? nextUrl = apiUrl;

    while (nextUrl != null) {
      final response = await http.get(Uri.parse(nextUrl));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<dynamic> results = jsonData['results'];

        // Check for existence of the serial number (and product code if provided)
        bool exists = results.any((item) {
          bool matchesreqno = item['REQ_ID'] == sendreqno;

          bool matchespickid = item['PICK_ID'] == sendpickid;
          bool matchesSerial = item['SERIAL_NO'] == serialNo;
          bool matchesProduct =
              productCode == null || item['PRODUCT_CODE'] == productCode;
          bool matchesFlag = item['FLAG'] != 'R' && item['FLAG'] != 'SR';
          return matchesreqno &&
              matchespickid &&
              matchesSerial &&
              matchesProduct &&
              matchesFlag;
        });

        if (exists) {
          return true; // Serial number found in current page
        }

        nextUrl = jsonData['next']; // Update nextUrl for pagination
      } else {
        print('Failed to fetch data from API: ${response.statusCode}');
        throw Exception('Error fetching data from API.');
      }
    }

    return false; // Serial number not found in all pages
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

  void showscanValidationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: const Text('Feild Check'),
          content: const Text(
              'You cannot click "Request for Delivery" before scanning.'),

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

  Widget _buildMobileCardView() {
    List<Map<String, dynamic>> displayData = filteredData
        .where((data) => data['scan_status'] != 'Request for Delivery')
        .toList();

    print("displayDataaaaaaaaaaa  $displayData");
    print("filteredDataaaaaaaaaaaaaa  $filteredData");

    return SingleChildScrollView(
      child: Column(
        children: [
          if (_isLoadingData)
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (displayData.isNotEmpty)
            ...displayData.map((data) => _buildCard(data)).toList()
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("No data available."),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> data) {
    var invoiceno = data['invoiceno'].toString();
    var itemcode = data['itemcode'].toString();

    var cusno = data['cusno'].toString();
    var cusname = data['cusname'].toString();
    var cussite = data['cussite'].toString();
    var itemdetails = data['itemdetails'].toString();
    var productcode = data['productcode'].toString();
    var serialno = data['serialno'].toString();

    var scanstatus = productcode == 'empty' || serialno == 'empty'
        ? 'ScanButton'
        : 'visibilecode';
    // print("scanstatussssss $scanstatus");
    return InkWell(
      onTap: () async {
        if (scanstatus == 'ScanButton') {
          int totalCount = filteredData
              .where((row) =>
                  row['itemcode'].toString() == itemcode &&
                  row['itemdetails'].toString() == itemdetails &&
                  row['invoiceno'].toString() == invoiceno &&
                  (row['productcode'].toString() == 'empty' ||
                      row['productcode'] == null) &&
                  (row['serialno'].toString() == 'empty' ||
                      row['serialno'] == null))
              .length;
          if (scanstatus == 'ScanButton')
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Dialog(
                  insetPadding:
                      EdgeInsets.all(10), // Adjust the padding as needed
                  child: Container(
                    color: Colors.grey[100],
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.65
                        : MediaQuery.of(context).size.width * 0.9, // 90% width
                    height:
                        MediaQuery.of(context).size.height * 0.90, // 80% height
                    child: Stack(
                      children: [
                        CustomerDetailsDialog(
                          togglePage: widget.togglePage,
                          reqno: widget.reqno,
                          pickno: widget.pickno,
                          assignpickname: PickIdcontroller.text,
                          assignpickman: PickIdcontroller.text,
                          warehouse: '',
                          org_id: '',
                          org_name: '',
                          salesman_No: SalesmanNoController.text,
                          salesman_Name: SalesmanNameController.text,
                          Manager_No: SalesmanNoController.text,
                          Manager_Name: SalesmanNameController.text,
                          cusid: CusNoController.text,
                          cusname: cusname,
                          cusno: cusno,
                          cussite: cussite,
                          invoiceno: invoiceno,
                          customer_trx_line_id:
                              CustomerTrxLineIdController.text,
                          customer_trx_id: CustomerTrxIdController.text,
                          undel_id: UdelIdontroller.text,
                          line_id: LineNoController.text,
                          itemcode: itemcode,
                          itemdetails: itemdetails,
                          scannedqty: '5',
                          nofoqty: totalCount.toString(),
                          alreadyscannedqty: '7',
                          invoiceQty: '8',
                          dispatch_qty: '9',
                          amount: '',
                          item_cost: '5',
                          balance_qty: '10',
                          Row_id: '',
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );

          await FetchLastDipatchNo();
          await fetchDispatchData();
          await fetchDataAndSetControllers();
          await fetchPreviousLoadCount(widget.reqno, widget.pickno);
        }
      },
      child: Card(
        color:
            scanstatus == 'ScanButton' ? Colors.grey[100] : Colors.green[100],
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Invoice No: ${data['invoiceno']}",
                  style: TableRowTextStyle),
              SizedBox(height: 8),
              Text("Item Code: ${data['itemcode']}", style: TableRowTextStyle),
              SizedBox(height: 8),
              Text("Item Description: ${data['itemdetails']}",
                  style: TableRowTextStyle),
              SizedBox(height: 8),
              Text(
                scanstatus == 'ScanButton'
                    ? "Product Code: Scan Now"
                    : "Product Code: ${data['productcode']}",
                style: TableRowTextStyle,
              ),
              SizedBox(height: 8),
              Text(
                  scanstatus == 'ScanButton'
                      ? "Serial No: Scan Now"
                      : "Serial No: ${data['serialno']}",
                  style: TableRowTextStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      height: screenHeight * 0.4,
      width: MediaQuery.of(context).size.width * 0.85,
      child: Stack(children: [
        Responsive.isDesktop(context)
            ? _buildWebTable(screenHeight)
            : _buildMobileCardView(),
        if (Responsive.isDesktop(context)) _buildScrollButtons(),
      ]),
    );
  }

  Widget _buildScrollButtons() {
    return Positioned(
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
              _horizontalScrollController.animateTo(
                _horizontalScrollController.offset - 100,
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

  Widget _buildWebTable(screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // You can adjust the background color here
        border: Border.all(
          color: Colors.grey[400]!, // Border color
          width: 1.0, // Border width
        ),
      ),
      height: screenHeight * 0.4,
      width: MediaQuery.of(context).size.width * 0.85,
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
                children: [
                  Container(
                    color: Colors.white,
                    height: Responsive.isDesktop(context)
                        ? screenHeight * 0.4
                        : 400,
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.85
                        : MediaQuery.of(context).size.width * 1.4,
                    child: SingleChildScrollView(
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 0.0, right: 0, top: 0, bottom: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  width: Responsive.isDesktop(context)
                                      ? MediaQuery.of(context).size.width * 0.05
                                      : 70,
                                  decoration: TableHeaderColor,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.format_list_numbered,
                                          size: 15,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 5),
                                        Text("Sno",
                                            textAlign: TextAlign.center,
                                            style: commonLabelTextStyle),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  width: Responsive.isDesktop(context)
                                      ? MediaQuery.of(context).size.width * 0.1
                                      : 100,
                                  decoration: TableHeaderColor,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.receipt_long,
                                          size: 15,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 5),
                                        Text("Invoice No",
                                            textAlign: TextAlign.center,
                                            style: commonLabelTextStyle),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  width: Responsive.isDesktop(context)
                                      ? MediaQuery.of(context).size.width * 0.4
                                      : 100,
                                  decoration: TableHeaderColor,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.qr_code,
                                          size: 15,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 5),
                                        Text("Item Code",
                                            textAlign: TextAlign.center,
                                            style: commonLabelTextStyle),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: Responsive.isDesktop(context) ? 25 : 30,
                                width:
                                    Responsive.isDesktop(context) ? 500 : 100,
                                decoration: TableHeaderColor,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 15,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(width: 5),
                                      Text("Item Description",
                                          textAlign: TextAlign.center,
                                          style: commonLabelTextStyle),
                                    ],
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  width: Responsive.isDesktop(context)
                                      ? MediaQuery.of(context).size.width * 0.1
                                      : 100,
                                  decoration: TableHeaderColor,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.qr_code_scanner,
                                          size: 15,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 5),
                                        Text("Product Code",
                                            textAlign: TextAlign.center,
                                            style: commonLabelTextStyle),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  width: Responsive.isDesktop(context)
                                      ? MediaQuery.of(context).size.width * 0.1
                                      : 100,
                                  decoration: TableHeaderColor,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.confirmation_number,
                                          size: 15,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 5),
                                        Text("Serial No",
                                            textAlign: TextAlign.center,
                                            style: commonLabelTextStyle),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
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
                              .where((data) =>
                                  data['scan_status'] != 'Request for Delivery')
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            int index = entry.key;
                            var data = entry.value;

                            String sNo = (index + 1).toString(); // S.No
                            var sno = data['id'].toString();

                            var invoiceno = data['invoiceno'].toString();
                            var itemcode = data['itemcode'].toString();

                            var cusno = data['cusno'].toString();
                            var cusname = data['cusname'].toString();
                            var cussite = data['cussite'].toString();
                            var itemdetails = data['itemdetails'].toString();
                            var productcode = data['productcode'].toString();
                            var serialno = data['serialno'].toString();
                            var scanstatus =
                                productcode == 'empty' || serialno == 'empty'
                                    ? 'ScanButton'
                                    : 'visibilecode';
                            // print("scanstatus $scanstatus");
                            bool isEvenRow = index % 2 == 0;
                            Color? rowColor = isEvenRow
                                ? Color.fromARGB(224, 255, 255, 255)
                                : Color.fromARGB(224, 255, 255, 255);
                            return GestureDetector(
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 0.0, right: 0, bottom: 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        height: 30,
                                        width: Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05
                                            : 70,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: SelectableText(
                                          sNo,
                                          textAlign: TextAlign.left,
                                          style: TableRowTextStyle,
                                          showCursor: false,
                                          // overflow: TextOverflow.ellipsis,
                                          cursorColor: Colors.blue,
                                          cursorWidth: 2.0,
                                          toolbarOptions: ToolbarOptions(
                                              copy: true, selectAll: true),
                                          onTap: () {
                                            // Optional: Handle single tap if needed
                                          },
                                        ),
                                        //  Text(sNo, style: TableRowTextStyle),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 30,
                                        width: Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.1
                                            : 100,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Text(invoiceno,
                                            style: TableRowTextStyle),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 30,
                                        width: Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4
                                            : 100,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Text(itemcode,
                                            style: TableRowTextStyle),
                                      ),
                                    ),
                                    Container(
                                      height: 30,
                                      width: Responsive.isDesktop(context)
                                          ? 500
                                          : 100,
                                      decoration: BoxDecoration(
                                        color: rowColor,
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 226, 225, 225),
                                        ),
                                      ),
                                      child: Text(itemdetails,
                                          style: TableRowTextStyle),
                                    ),
                                    Flexible(
                                      child: scanstatus == 'ScanButton'
                                          ? Container(
                                              height: 30,
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.1
                                                      : 100,
                                              decoration: BoxDecoration(
                                                color: rowColor,
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 226, 225, 225),
                                                ),
                                              ),
                                              child: InkWell(
                                                onTap: () async {
                                                  int totalCount = filteredData
                                                      .where((row) =>
                                                          row['itemcode']
                                                                  .toString() ==
                                                              itemcode &&
                                                          row['itemdetails']
                                                                  .toString() ==
                                                              itemdetails &&
                                                          row['invoiceno']
                                                                  .toString() ==
                                                              invoiceno &&
                                                          (row['productcode']
                                                                      .toString() ==
                                                                  'empty' ||
                                                              row['productcode'] ==
                                                                  null) &&
                                                          (row['serialno']
                                                                      .toString() ==
                                                                  'empty' ||
                                                              row['serialno'] ==
                                                                  null))
                                                      .length;
                                                  await showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder:
                                                        (BuildContext context) {
                                                      return Dialog(
                                                        insetPadding:
                                                            EdgeInsets.all(
                                                                10), // Adjust the padding as needed
                                                        child: Container(
                                                          color:
                                                              Colors.grey[100],
                                                          width: Responsive
                                                                  .isDesktop(
                                                                      context)
                                                              ? MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.65
                                                              : MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.9, // 90% width
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.90, // 80% height
                                                          child: Stack(
                                                            children: [
                                                              CustomerDetailsDialog(
                                                                togglePage: widget
                                                                    .togglePage,
                                                                reqno: widget
                                                                    .reqno,
                                                                pickno: widget
                                                                    .pickno,
                                                                assignpickname:
                                                                    PickIdcontroller
                                                                        .text,
                                                                assignpickman:
                                                                    PickIdcontroller
                                                                        .text,
                                                                warehouse: '',
                                                                org_id: '',
                                                                org_name: '',
                                                                salesman_No:
                                                                    SalesmanNoController
                                                                        .text,
                                                                salesman_Name:
                                                                    SalesmanNameController
                                                                        .text,
                                                                Manager_No:
                                                                    SalesmanNoController
                                                                        .text,
                                                                Manager_Name:
                                                                    SalesmanNameController
                                                                        .text,
                                                                cusid:
                                                                    CusNoController
                                                                        .text,
                                                                cusname:
                                                                    cusname,
                                                                cusno: cusno,
                                                                cussite:
                                                                    cussite,
                                                                invoiceno:
                                                                    invoiceno,
                                                                customer_trx_line_id:
                                                                    CustomerTrxLineIdController
                                                                        .text,
                                                                customer_trx_id:
                                                                    CustomerTrxIdController
                                                                        .text,
                                                                undel_id:
                                                                    UdelIdontroller
                                                                        .text,
                                                                line_id:
                                                                    LineNoController
                                                                        .text,
                                                                itemcode:
                                                                    itemcode,
                                                                itemdetails:
                                                                    itemdetails,
                                                                scannedqty: '5',
                                                                nofoqty: totalCount
                                                                    .toString(),
                                                                alreadyscannedqty:
                                                                    '7',
                                                                invoiceQty: '8',
                                                                dispatch_qty:
                                                                    '9',
                                                                amount: '',
                                                                item_cost: '5',
                                                                balance_qty:
                                                                    '10',
                                                                Row_id: '',
                                                              ),
                                                              Positioned(
                                                                top: 10,
                                                                right: 10,
                                                                child:
                                                                    IconButton(
                                                                  icon: Icon(
                                                                      Icons
                                                                          .cancel,
                                                                      color: Colors
                                                                          .red),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(); // Close the dialog
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );

                                                  await FetchLastDipatchNo();
                                                  await fetchDispatchData();
                                                  await fetchDataAndSetControllers();
                                                  await fetchPreviousLoadCount(
                                                      widget.reqno,
                                                      widget.pickno);
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 2,
                                                      left: 15,
                                                      right: 15,
                                                      bottom: 2),
                                                  child: Container(
                                                    color: buttonColor,
                                                    child: Center(
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .visibility,
                                                                  size: 15,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                SizedBox(
                                                                    width: 5),
                                                                Text("Scan",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        commonWhiteStyle),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              height: 30,
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.1
                                                      : 100,
                                              decoration: BoxDecoration(
                                                color: rowColor,
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 226, 225, 225),
                                                ),
                                              ),
                                              child: Text(productcode,
                                                  style: TableRowTextStyle),
                                            ),
                                    ),
                                    Flexible(
                                      child: scanstatus == 'ScanButton'
                                          ? Container(
                                              height: 30,
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.1
                                                      : 100,
                                              decoration: BoxDecoration(
                                                color: rowColor,
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 226, 225, 225),
                                                ),
                                              ),
                                              child: InkWell(
                                                onTap: () async {
                                                  int totalCount = filteredData
                                                      .where((row) =>
                                                          row['itemcode']
                                                                  .toString() ==
                                                              itemcode &&
                                                          row['itemdetails']
                                                                  .toString() ==
                                                              itemdetails &&
                                                          row['invoiceno']
                                                                  .toString() ==
                                                              invoiceno &&
                                                          (row['productcode']
                                                                      .toString() ==
                                                                  'empty' ||
                                                              row['productcode'] ==
                                                                  null) &&
                                                          (row['serialno']
                                                                      .toString() ==
                                                                  'empty' ||
                                                              row['serialno'] ==
                                                                  null))
                                                      .length;
                                                  await showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder:
                                                        (BuildContext context) {
                                                      return Dialog(
                                                        insetPadding:
                                                            EdgeInsets.all(
                                                                10), // Adjust the padding as needed
                                                        child: Container(
                                                          color:
                                                              Colors.grey[100],
                                                          width: Responsive
                                                                  .isDesktop(
                                                                      context)
                                                              ? MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.65
                                                              : MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.9, // 90% width
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.90, // 80% height
                                                          child: Stack(
                                                            children: [
                                                              CustomerDetailsDialog(
                                                                togglePage: widget
                                                                    .togglePage,
                                                                reqno: widget
                                                                    .reqno,
                                                                pickno: widget
                                                                    .pickno,
                                                                assignpickname:
                                                                    PickIdcontroller
                                                                        .text,
                                                                assignpickman:
                                                                    PickIdcontroller
                                                                        .text,
                                                                warehouse: '',
                                                                org_id: '',
                                                                org_name: '',
                                                                salesman_No:
                                                                    SalesmanNoController
                                                                        .text,
                                                                salesman_Name:
                                                                    SalesmanNameController
                                                                        .text,
                                                                Manager_No:
                                                                    SalesmanNoController
                                                                        .text,
                                                                Manager_Name:
                                                                    SalesmanNameController
                                                                        .text,
                                                                cusid:
                                                                    CusNoController
                                                                        .text,
                                                                cusname:
                                                                    cusname,
                                                                cusno: cusno,
                                                                cussite:
                                                                    cussite,
                                                                invoiceno:
                                                                    invoiceno,
                                                                customer_trx_line_id:
                                                                    CustomerTrxLineIdController
                                                                        .text,
                                                                customer_trx_id:
                                                                    CustomerTrxIdController
                                                                        .text,
                                                                undel_id:
                                                                    UdelIdontroller
                                                                        .text,
                                                                line_id:
                                                                    LineNoController
                                                                        .text,
                                                                itemcode:
                                                                    itemcode,
                                                                itemdetails:
                                                                    itemdetails,
                                                                scannedqty: '5',
                                                                nofoqty: totalCount
                                                                    .toString(),
                                                                alreadyscannedqty:
                                                                    '7',
                                                                invoiceQty: '8',
                                                                dispatch_qty:
                                                                    '9',
                                                                amount: '',
                                                                item_cost: '5',
                                                                balance_qty:
                                                                    '10',
                                                                Row_id: '',
                                                              ),
                                                              Positioned(
                                                                top: 10,
                                                                right: 10,
                                                                child:
                                                                    IconButton(
                                                                  icon: Icon(
                                                                      Icons
                                                                          .cancel,
                                                                      color: Colors
                                                                          .red),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(); // Close the dialog
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 2,
                                                      left: 15,
                                                      right: 15,
                                                      bottom: 2),
                                                  child: Container(
                                                    color: buttonColor,
                                                    child: Center(
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .visibility,
                                                                  size: 15,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                SizedBox(
                                                                    width: 5),
                                                                Text("Scan",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        commonWhiteStyle),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              height: 30,
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.1
                                                      : 100,
                                              decoration: BoxDecoration(
                                                color: rowColor,
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 226, 225, 225),
                                                ),
                                              ),
                                              child: Text(serialno,
                                                  style: TableRowTextStyle),
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
                            child: Text("No data available."),
                          ),
                      ]),
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

  FocusNode SerialcameraFocus = FocusNode();

  Widget _buildInputField(BuildContext context,
      {required TextEditingController controller,
      required FocusNode focusNode,
      required String label,
      required Function(String) onSubmitted,
      required Function() onPressed,
      bool? readonly}) {
    return Container(
      width: Responsive.isDesktop(context) ? 200 : 180,
      height: Responsive.isDesktop(context) ? 33 : 35,
      color: Colors.grey[200],
      child: TextField(
        readOnly: readonly ?? false,
        onSubmitted: onSubmitted,
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            focusNode: SerialcameraFocus,
            onPressed: onPressed,
            icon: Icon(Icons.qr_code, color: Colors.blue, size: 18),
          ),
          labelText: label,
          labelStyle: textBoxstyle,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        style: TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required Function() onPressed,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: Responsive.isDesktop(context) ? 13 : 0),
      child: Container(
        decoration: BoxDecoration(color: buttonColor),
        height: 30,
        width: Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.08
            : MediaQuery.of(context).size.width * 0.4,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(45.0, 20.0),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(label, style: commonWhiteStyle),
          ),
        ),
      ),
    );
  }

  // void _handleAddButtonPressed() async {
  //   String productCode = "empty";
  //   String serialNo = "empty";

  //   if (productCode.isEmpty || serialNo.isEmpty) {
  //     showVAlreadyExistproductcode(
  //         context, "Please enter product code and serial number.");
  //     return;
  //   }

  //   bool alreadyExists = filteredData.any((item) =>
  //       item['req_no'].toString() == widget.reqno &&
  //       item['pick_id'].toString() == widget.pickno &&
  //       item['productcode'].toString() == productCode &&
  //       item['serialno'].toString() == serialNo);

  //   if (alreadyExists) {
  //     showVAlreadyExistproductcode(
  //       context,
  //       "This Product Code and Serial No already exist!",
  //     );
  //     print("This product is already in the list.");
  //     return;
  //   }

  //   try {
  //     // ✅ Show loading dialog
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) => Center(
  //         child: Container(
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(16),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black26,
  //                 blurRadius: 10,
  //                 spreadRadius: 2,
  //               ),
  //             ],
  //           ),
  //           padding: EdgeInsets.all(20),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               SizedBox(
  //                 width: 20,
  //                 height: 20,
  //                 child: CircularProgressIndicator(
  //                   strokeWidth: 2,
  //                   valueColor:
  //                       AlwaysStoppedAnimation<Color>(Colors.green.shade700),
  //                 ),
  //               ),
  //               SizedBox(height: 5),
  //               Text(
  //                 'Processing...',
  //                 style: TextStyle(
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.w500,
  //                   color: Colors.grey.shade800,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );

  //     final ipAddress = await getActiveIpAddress();

  //     final response = await http.post(
  //       Uri.parse('$ipAddress/check_serial_and_fetch_data/'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({
  //         'reqno': widget.reqno,
  //         'pickid': widget.pickno,
  //         'productcode': productCode,
  //         'serialno': serialNo,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);

  //       if (responseData['already_tracked'] == true) {
  //         Navigator.pop(context); // ❗ Close loading dialog on early return
  //         showVAlreadyExistproductcode(
  //           context,
  //           "This Product Code and Serial No are already being tracked.",
  //         );
  //         return;
  //       }

  //       if (responseData['data'] != null && responseData['data'].isNotEmpty) {
  //         print("Data found in Pickman_scan. Proceeding to save...");

  //         await _addTableData();

  //         setState(() {
  //           filteredData = List.from(tableData);
  //         });

  //         await _sendDataToApi();
  //         await _updateCurrentLoadCount();
  //         await fetchDispatchData(); // ✅ Processing ends here

  //         if (noProductCheckbox == true) {
  //           salesserialnoController.clear();
  //           _fieldFocusChange(context, addButtonFocusNode, serialNoFocusNode);
  //         } else {
  //           ProductCodeController.clear();
  //           salesserialnoController.clear();
  //           _fieldFocusChange(
  //               context, addButtonFocusNode, productCodeFocusNode);
  //         }

  //         setState(() {
  //           NoProductCodeButton = false;
  //         });

  //         if (!NoProductCodeButton) {
  //           ProductCodeController.clear();
  //           _fieldFocusChange(
  //               context, addButtonFocusNode, productCodeFocusNode);
  //         }

  //         await fetchDispatchData(); // If needed again
  //         postLogData("Truck Loading Scan", "Add details");
  //       } else {
  //         Navigator.pop(context); // ❗ Close loading dialog on early return
  //         showVAlreadyExistproductcode(
  //           context,
  //           "No matching data found for the entered product code and serial number in Pickman_scan.",
  //         );
  //         print("No matching data found in Pickman_scan.");
  //         return;
  //       }
  //     } else {
  //       Navigator.pop(context); // ❗ Close loading dialog on early return
  //       showVAlreadyExistproductcode(
  //         context,
  //         "Server Error: ${response.statusCode}",
  //       );
  //     }

  //     Navigator.pop(context); // ✅ Finally close the dialog when all done
  //   } catch (error) {
  //     Navigator.pop(context); // ❗ Close loading dialog on error
  //     showVAlreadyExistproductcode(context, "Error: $error");
  //     print('Error: $error');
  //   }
  // }

  void _handleAddButtonPressed() async {
    String productCode = "empty";
    String serialNo = "empty";

    await calculatebalanceqty();
    print("balnaceqtyyyyyyyyyyy $balanceQty");

    if (productCode.isEmpty || serialNo.isEmpty) {
      showVAlreadyExistproductcode(
          context, "Please enter product code and serial number.");
      return;
    }

    // Count current scanned items under same pickid and reqno
    int currentCount = filteredData
        .where((item) =>
            item['pick_id'].toString() == widget.pickno &&
            item['req_no'].toString() == widget.reqno)
        .length;

    // Compare with expected picked quantity
    print(
        "picked qty check   $currentCount == ${(int.tryParse(widget.pickedqty) ?? 0)}");
    if (currentCount >= (int.tryParse(widget.pickedqty) ?? 0)) {
      showVAlreadyExistproductcode(
        context,
        "This Product Code and Serial No Under this Pickid are already exist!",
      );
      return;
    }

    try {
      // ✅ Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.green.shade700),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Processing...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final ipAddress = await getActiveIpAddress();

      final response = await http.post(
        Uri.parse('$ipAddress/check_serial_and_fetch_data/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'reqno': widget.reqno,
          'pickid': widget.pickno,
          'productcode': productCode,
          'serialno': serialNo,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['already_tracked'] == true) {
          Navigator.pop(context); // ❗ Close loading dialog
          showVAlreadyExistproductcode(
            context,
            "This Product Code and Serial No are already being tracked.",
          );
          return;
        }

        if (responseData['data'] != null && responseData['data'].isNotEmpty) {
          print("Data found in Pickman_scan. Proceeding to save...");

          // ✅ Add table data from server based on balance qty only
          await _addTableData(balanceCount: balanceQty);

          setState(() {
            filteredData = tableData
                .where((item) =>
                    item['pickid'].toString() == widget.pickno &&
                    item['reqno'].toString() == widget.reqno)
                .toList();
          });

          // await _sendDataToApi(balanceCount: balanceQty);
          await showButtonTruckDetails();
          await _updateCurrentLoadCount();
          await fetchDispatchData();

          if (noProductCheckbox == true) {
            salesserialnoController.clear();
            _fieldFocusChange(context, addButtonFocusNode, serialNoFocusNode);
          } else {
            ProductCodeController.clear();
            salesserialnoController.clear();
            _fieldFocusChange(
                context, addButtonFocusNode, productCodeFocusNode);
          }

          setState(() {
            NoProductCodeButton = false;
          });

          if (!NoProductCodeButton) {
            ProductCodeController.clear();
            _fieldFocusChange(
                context, addButtonFocusNode, productCodeFocusNode);
          }
        } else {
          Navigator.pop(context); // ❗ Close loading dialog
          showVAlreadyExistproductcode(
            context,
            "No matching data found for the entered product code and serial number in Pickman_scan.",
          );
          return;
        }
      } else {
        Navigator.pop(context); // ❗ Close loading dialog
        showVAlreadyExistproductcode(
          context,
          "Server Error: ${response.statusCode}",
        );
      }

      Navigator.pop(context); // ✅ Finally close the dialog
    } catch (error) {
      Navigator.pop(context); // ❗ Close loading dialog
      showVAlreadyExistproductcode(context, "Error: $error");
      print('Error: $error');
    }
  }

  void showVAlreadyExistproductcode(BuildContext context, String body) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: const Text('Feild Check'),
          content: Text("$body"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // fetchDispatchData();
                if (noProductCheckbox == true) {
                  // Reset input fields
                  salesserialnoController.clear();
                  _fieldFocusChange(
                      context, addButtonFocusNode, serialNoFocusNode);
                } else {
                  ProductCodeController.clear();
                  salesserialnoController.clear();
                  // Change focus to the next field
                  _fieldFocusChange(
                      context, addButtonFocusNode, productCodeFocusNode);
                }
                // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class CustomerDetailsDialog extends StatefulWidget {
  final Function togglePage;
  final String reqno;
  final String pickno;
  final String assignpickname;
  final String assignpickman;
  final String warehouse;
  final String org_id;
  final String org_name;
  final String salesman_No;
  final String salesman_Name;

  final String Manager_No;
  final String Manager_Name;
  final String cusid;
  final String cusname;
  final String cusno;
  final String cussite;
  final String invoiceno;
  final String itemcode;
  final String itemdetails;
  final String line_id;
  final String customer_trx_line_id;
  final String customer_trx_id;
  final String undel_id;
  final String scannedqty;
  final String alreadyscannedqty;
  final String nofoqty;
  final String invoiceQty;
  final String dispatch_qty;
  final String amount;
  final String item_cost;
  final String balance_qty;
  final String Row_id;

  CustomerDetailsDialog({
    required this.togglePage,
    required this.reqno,
    required this.pickno,
    required this.assignpickname,
    required this.assignpickman,
    required this.warehouse,
    required this.org_id,
    required this.org_name,
    required this.salesman_No,
    required this.salesman_Name,
    required this.Manager_No,
    required this.Manager_Name,
    required this.cusid,
    required this.cusname,
    required this.cusno,
    required this.cussite,
    required this.invoiceno,
    required this.line_id,
    required this.customer_trx_line_id,
    required this.customer_trx_id,
    required this.undel_id,
    required this.itemcode,
    required this.itemdetails,
    required this.scannedqty,
    required this.alreadyscannedqty,
    required this.nofoqty,
    required this.invoiceQty,
    required this.dispatch_qty,
    required this.amount,
    required this.balance_qty,
    required this.item_cost,
    required this.Row_id,
    // required this.Row_id
  });

  @override
  _CustomerDetailsDialogState createState() => _CustomerDetailsDialogState();
}

class _CustomerDetailsDialogState extends State<CustomerDetailsDialog> {
  List<Map<String, dynamic>> createtableData = [];
  List<TextEditingController> barcodeControllers = [];
  List<TextEditingController> serialnoControllers = [];
  List<FocusNode> barcodeFocusNodes = [];
  List<FocusNode> serialnoFocusNodes = [];
  // FocusNode SavebuttonFocus = FocusNode();

  TextEditingController idcontroller = TextEditingController();

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  final TextEditingController _alreadyScaneedqty = TextEditingController();
  final _serialNumbers = <String>{}; // For O(1) duplicate checking
  int _cachedMaxQuantity = 0; // Initialize in initState()

  String? validProductCode = '⎋';
  @override
  void initState() {
    super.initState();
    invoiceNoController.text = widget.invoiceno;
    ItemcodeController.text = widget.itemcode;
    itemDescriptionController.text = widget.itemdetails;
    _loadTableData(widget.pickno, widget.reqno, widget.itemcode,
        widget.itemdetails, widget.invoiceno);
    postLogData("LoadMan Scan Pop-up View", "Opend");
    fetchAccessControl();
    fetchPickmanData();
    fetchAndFilterData();

    fetchRegionAndWarehouse();
    // Initialize quantity based on passed values
    // int nofoqtycount = int.tryParse(widget.nofoqty) ?? 0;

    int nofoqtycount = double.tryParse(widget.nofoqty)?.toInt() ?? 0;

    // Generate table data based on quantity count
    createtableData = List.generate(nofoqtycount, (index) {
      return {
        'id': index + 1,
        'line_id': widget.line_id,
        'invoiceno': widget.invoiceno,
        'customer_trx_id': widget.customer_trx_id,
        'undel_id': widget.undel_id,
        'customer_trx_line_id': widget.customer_trx_line_id,
        'itemcode': widget.itemcode,
        'itemdetails': widget.itemdetails,
        'invoiceQty': widget.invoiceQty,
        'dispatch_qty': widget.dispatch_qty,
        'amount': widget.amount,
        'balance_qty': widget.balance_qty,
        'item_cost': widget.item_cost,
        'barcode': '',
        'serialno': '',
      };
    });
    // Output to verify data population
    // print(
    //     "Initialized createtableData:  $nofoqtycount ${widget.nofoqty}  $createtableData");

    // Initialize controllers and focus nodes for barcode and serial numbers
    barcodeControllers =
        List.generate(nofoqtycount, (index) => TextEditingController());
    serialnoControllers =
        List.generate(nofoqtycount, (index) => TextEditingController());
    barcodeFocusNodes = List.generate(nofoqtycount, (index) => FocusNode());
    serialnoFocusNodes = List.generate(nofoqtycount, (index) => FocusNode());

    // Attach listeners for real-time updates on scanned item count

    idcontroller.text = widget.Row_id;
    _alreadyScaneedqty.text = widget.alreadyscannedqty;
    print("Already Scanned Qty: ${_alreadyScaneedqty.text}");
    validProductCode == null;

    print("validation product code : ${_alreadyScaneedqty.text}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scanMode == 0 && barcodeFocusNodes.isNotEmpty) {
        if (validProductCode == '00') {
          print("entered in to no product code .000");
          FocusScope.of(context).requestFocus(serialnoFocusNodes[0]);
        } else {
          print("entered product code 00");
          FocusScope.of(context).requestFocus(barcodeFocusNodes[0]);
        }
      }
    });

    _cachedMaxQuantity =
        int.tryParse((widget.nofoqty ?? '').split('.').first) ?? 0;
  }

  String? validSerialno;
  String message = "";

  // Future<void> fetchAndFilterData() async {
  //   final String url =
  //       "$IpAddress/filteredProductcodeGetView/${widget.itemcode}";

  //   // "$IpAddress/filteredProductcodeGetView/07MKD06";

  //   try {
  //     final response = await http.get(Uri.parse(url));

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);

  //       // Check if the response is a list
  //       if (data is List && data.isNotEmpty) {
  //         final product = data[0]; // Get the first item
  //         if (product['SERIAL_STATUS'] == 'Y') {
  //           setState(() {
  //             validProductCode = product['CUT_PRODUCT_CODE'];
  //             message = "Valid product code found.";
  //             print("Valid product code found.  $validProductCode");
  //           });
  //         } else {
  //           setState(() {
  //             validProductCode = null;

  //             print("Validddd not product code found.  $validProductCode");
  //             message =
  //                 "This item code cannot be scanned because SERIAL_STATUS is not \"Y\".";
  //           });
  //         }
  //       } else if (data is Map && data.containsKey('message')) {
  //         setState(() {
  //           validProductCode = null;
  //           message = data['message'];

  //           print("Valid producttttt  not code found.  $validProductCode");
  //         });
  //       } else {
  //         setState(() {
  //           validProductCode = null;
  //           message = "Unexpected response format.";

  //           print("Valid product codeeeee not found.  $validProductCode");
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         validProductCode = null;
  //         message = "Failed to fetch data. Status code: ${response.statusCode}";
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       validProductCode = null;
  //       message = "An error occurred: $e";
  //     });
  //   }
  // }

  Future<void> fetchAndFilterData() async {
    final IpAddress = await getActiveIpAddress();

    final String url =
        "$IpAddress/filteredProductcodeGetView$parameterdivided${widget.itemcode}$parameterdivided${widget.itemdetails}$parameterdivided";
    print("urllll urlllll $url");
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if the response is a list
        if (data is List && data.isNotEmpty) {
          final product = data[0]; // Get the first item
          String cutProductCode = product['PRODUCT_BARCODE'] ?? '';

          // Clean up the product code (remove unexpected characters and spaces)
          cutProductCode =
              cutProductCode.trim().replaceAll(RegExp(r'[^\x20-\x7E]'), '');

          // Check if SERIAL_STATUS is 'Y' and CUT_PRODUCT_CODE is valid
          if (product['SERIAL_STATUS'] == 'Y' && cutProductCode.isNotEmpty) {
            setState(() {
              validProductCode = (cutProductCode == 0 || cutProductCode == "0")
                  ? "00"
                  : cutProductCode.toString();
              validSerialno = '';
              message = "Valid product code found.";
              print("Valid product code found: $validProductCode");
            });
          } else if (product['SERIAL_STATUS'] == 'N' &&
              cutProductCode.isNotEmpty) {
            setState(() {
              validProductCode = cutProductCode;
              validSerialno = 'null';
              message = "Valid product code found.";
              print(
                  "Valid product code found WITH NULL : $validProductCode $validSerialno");
            });
          } else {
            setState(() {
              validProductCode = null;
              message = cutProductCode.isEmpty
                  ? "CUT_PRODUCT_CODE is empty or contains only invalid characters."
                  : "This item code cannot be scanned because SERIAL_STATUS is not \"Y\".";
              print("Invalid product code or SERIAL_STATUS issue.");
            });
            print("validProductCodEEEe: $validProductCode");
          }
        } else if (data is Map && data.containsKey('message')) {
          setState(() {
            validProductCode = null;
            message = data['message'];
            print("Message from server: $message");
          });
          print("validProductCodEEEe:11 $validProductCode");
        } else {
          setState(() {
            validProductCode = null;
            message = "Unexpected response format.";
            print("Unexpected response format.");
          });
          print("validProductCodEEEe: 222 $validProductCode");
        }
      } else {
        setState(() {
          validProductCode = null;
          message = "Failed to fetch data. Status code: ${response.statusCode}";
          print("HTTP error: ${response.statusCode}");
        });
        print("validProductCodEEEe333: $validProductCode");
      }
    } catch (e) {
      setState(() {
        validProductCode = null;
        message = "An error occurred: $e";
        print("Exception: $e");
        print("validProductCodEEEe:444 $validProductCode");
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content:
              const Text("All picked quantities are scanned successfully."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    for (var controller in barcodeControllers) {
      controller.dispose();
    }
    for (var controller in serialnoControllers) {
      controller.dispose();
    }
    for (var node in barcodeFocusNodes) {
      node.dispose();
    }
    for (var node in serialnoFocusNodes) {
      node.dispose();
    }
    super.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();

    postLogData("LoadMan Scan Pop-up View", "Closed");
  }

  final TextEditingController regionController = TextEditingController();
  final TextEditingController warehouseController = TextEditingController();

  Future<void> fetchRegionAndWarehouse() async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/Physical_Warehouse/';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Find the entry for the given ORGANIZATION_ID
        final result = data['results'].firstWhere(
          (item) => item['ORGANIZATION_ID'] == saleslogiOrgid,
          orElse: () => null,
        );

        if (result != null) {
          // Update the controllers with fetched values
          setState(() {
            regionController.text = result['REGION_NAME'];
            warehouseController.text = result['WAREHOUSE_NAME'];
          });
        } else {
          // Clear the controllers if no match is found
          setState(() {
            regionController.text = '';
            warehouseController.text = '';
          });
          print('No data found for ORGANIZATION_ID: $saleslogiOrgid');
        }
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  bool isPosting = false; // Flag to prevent multiple submissions

  Future<void> sendProductDetails() async {
    String reqid = widget.reqno;
    String pickid = widget.pickno;
    String invoiceno = widget.invoiceno;
    String itemcode = widget.itemcode;
    String description = widget.itemdetails;

    print("Request ID: $reqid");
    print("Pick ID: $pickid");
    print("Invoice No: $invoiceno");
    print("Item Code: $itemcode");
    print("Description: $description");

    final IpAddress = await getActiveIpAddress();
    // print("tableDataaaa: $tableData");
    String apiUrl =
        "$IpAddress/update-truck-picked_Scanned/"; // Replace with your actual endpoint
    // print("tableDataaaaaaaaaaaa $tableData");

    var body = {
      "reqid": reqid,
      "pickid": pickid,
      "invoiceno": invoiceno,
      "itemcode": itemcode,
      "description": description,
      "tabledata": tableData
    };

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print(
            "Successfully updated: ${body["Product Code"]}, ${body["Serial No"]}");
      } else {
        print("Failed to update: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error sending data: $e");
    }

    _deleteTableData(widget.pickno, widget.reqno, widget.itemcode,
        widget.itemdetails, widget.invoiceno);
  }

  Future<void> postPickmanScan(int balanceqty) async {
    if (isPosting) {
      print('Already posting. Please wait.');
      return; // Prevent duplicate submissions
    }

    // print("tableDataaaaaaaaaaaaa:sssss  $tableData");

    isPosting = true;

    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/Pickman_scasssssssn/';
    await fetchRegionAndWarehouse();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno') ?? '';
    String? saveloginname = prefs.getString('saveloginname') ?? '';
    String? saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';

    try {
      DateTime now = DateTime.now();
      String date = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

      String reqno = widget.reqno.toString();
      String pickno = widget.pickno.isNotEmpty ? widget.pickno : '';
      String assignpickman =
          widget.assignpickname.isNotEmpty ? widget.assignpickname : '';
      String warehouse =
          warehouseController.text.isNotEmpty ? warehouseController.text : '';
      String org_name =
          regionController.text.isNotEmpty ? regionController.text : '';

      for (int i = 0; i < createtableData.length; i++) {
        var row = createtableData[i];
        var relatedRow = tableData.isNotEmpty ? tableData[i] : {};

        // Parsing numeric fields and ensuring correct data types
        var customer_trx_line_id =
            int.tryParse(row['customer_trx_line_id']?.toString() ?? '0') ?? 0;
        var customer_trx_id =
            int.tryParse(row['customer_trx_id']?.toString() ?? '0') ?? 0;

        // print("tableDataaaaaaaaaaaaa:  $tableData");

        if (tableData.isNotEmpty) {
          Map<String, dynamic> createDispatchData = {
            "PICK_ID": pickno,
            "REQ_ID": reqno,
            "DATE": date,
            "ASSIGN_PICKMAN": assignpickman,
            "PHYSICAL_WAREHOUSE": warehouse,
            "ORG_ID": saleslogiOrgid.isNotEmpty ? saleslogiOrgid : 'Unknown',
            "ORG_NAME": org_name,
            "SALESMAN_NO": widget.salesman_No,
            "SALESMAN_NAME": widget.salesman_Name,
            "MANAGER_NO": widget.Manager_No,
            "MANAGER_NAME": widget.Manager_Name,
            "PICKMAN_NO": salesloginno.isNotEmpty ? salesloginno : 'Unknown',
            "PICKMAN_NAME":
                saveloginname.isNotEmpty ? saveloginname : 'Unknown',
            "CUSTOMER_NUMBER": widget.cusno,
            "CUSTOMER_NAME": widget.cusname,
            "CUSTOMER_SITE_ID": widget.cussite,
            "INVOICE_DATE": date,
            "INVOICE_NUMBER": invoiceNoController.text.isNotEmpty
                ? invoiceNoController.text
                : 'Unknown',
            "LINE_NUMBER": row['line_id']?.toString() ??
                '0', // Ensure this is a string if expected
            "INVENTORY_ITEM_ID": row['itemcode']?.toString() ?? '0',
            "ITEM_DESCRIPTION": row['itemdetails']?.toString() ?? '0',
            "CUSTOMER_TRX_ID": customer_trx_id,
            "CUSTOMER_TRX_LINE_ID": customer_trx_line_id,
            "TOT_QUANTITY": row['invoiceQty']?.toString() ?? '0',
            "DISPATCHED_QTY": row['dispatch_qty']?.toString() ?? '0',
            "BALANCE_QTY":
                (int.tryParse(row['dispatch_qty']?.toString() ?? '0') ??
                        0 - balanceqty)
                    .toString(),
            "PICKED_QTY": 1,
            "PRODUCT_CODE": relatedRow['Product Code'] ?? '',
            "SERIAL_NO": relatedRow['Serial No'] ?? '',
            "CREATION_DATE": date,
            "CREATED_BY": saveloginname.isNotEmpty ? saveloginname : 'Unknown',
            "LAST_UPDATE_DATE": date,
            "FLAG": 'A',
            "UNDEL_ID": widget.undel_id,
          };

          final response = await http.post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(createDispatchData),
          );

          if (response.statusCode == 201) {
            _deleteTableData(widget.pickno, widget.reqno, widget.itemcode,
                widget.itemdetails, widget.invoiceno);
            print(
                'Dispatch created successfully for Line Number: ${row['line_id']}');
          } else {
            print(
                'Failed to create dispatch for Line Number: ${row['line_id']}. Status code: ${response.statusCode}');
            print('Response body: ${response.body}');
          }
        }
      }
    } catch (e) {
      print('Error occurred while posting dispatch data: $e');
    } finally {
      isPosting = false;
    }
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

  bool byepassCheckbox = false; // State to track checkbox
// Toggle checkbox function
  void toggleCheckbox(bool? value) {
    setState(() {
      byepassCheckbox = value ?? false;

      // If the checkbox is checked, reset barcodeControllers and serialnoControllers
      if (byepassCheckbox) {
        barcodeControllers =
            List.generate(5, (index) => TextEditingController(text: "00"));
        serialnoControllers =
            List.generate(5, (index) => TextEditingController(text: "null"));
      } else {
        // Reinitialize them with 5 items or set default values if needed
        barcodeControllers =
            List.generate(5, (index) => TextEditingController(text: ""));
        serialnoControllers =
            List.generate(5, (index) => TextEditingController(text: ""));
      }
    });
  }

  TextEditingController invoiceNoController = TextEditingController();
  TextEditingController ItemcodeController = TextEditingController();
  TextEditingController itemDescriptionController = TextEditingController();

  // @override
  // Widget build(BuildContext context) {
  //   double screenWidth = MediaQuery.of(context).size.width;
  //   int totalItems = createtableData.length;
  //   int _scanOption = 0; // 0 for Barcode, 1 for Cam/Manual

  //   // print("tableDataaaaaaaaaaaaa:  $tableData");
  //   return Padding(
  //     padding: const EdgeInsets.all(5),
  //     child: Container(
  //       width: Responsive.isDesktop(context)
  //           ? screenWidth * 0.7
  //           : screenWidth * 0.9,
  //       // height: MediaQuery.of(context).size.height * 0.4,
  //       padding: const EdgeInsets.all(16.0),
  //       child: SingleChildScrollView(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text("Scan Pop-Up View", style: TextStyle(fontSize: 14)),
  //             const SizedBox(height: 10),
  //             Row(mainAxisAlignment: MainAxisAlignment.end, children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: [
  //                   Text(
  //                     'Count : ${tableData.length}/${widget.nofoqty.contains('.') ? widget.nofoqty.split('.')[0] : widget.nofoqty}', // Remove decimal part
  //                     style: TextStyle(fontSize: 15),
  //                   ),
  //                 ],
  //               )
  //             ]),
  //             const SizedBox(height: 10),
  //             if (validProductCode == null)
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.end,
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: <Widget>[
  //                   if (!Responsive.isMobile(context))
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.end,
  //                       children: [
  //                         Checkbox(
  //                           value: byepassCheckbox,
  //                           onChanged:
  //                               toggleCheckbox, // Handle checkbox state change
  //                         ),
  //                         const Text('Bypass Product Code and Serial No'),
  //                       ],
  //                     ),
  //                   if (Responsive.isMobile(context))
  //                     SingleChildScrollView(
  //                       scrollDirection: Axis.horizontal,
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.end,
  //                         children: [
  //                           Checkbox(
  //                             value: byepassCheckbox,
  //                             onChanged:
  //                                 toggleCheckbox, // Handle checkbox state change
  //                           ),
  //                           const Text('Bypass Product Code and Serial No'),
  //                         ],
  //                       ),
  //                     ),
  //                 ],
  //               ),

  //             if (!Responsive.isMobile(context))
  //               StatefulBuilder(builder: (context, setState) {
  //                 return Padding(
  //                   padding: const EdgeInsets.only(left: 0.0),
  //                   child: SingleChildScrollView(
  //                     scrollDirection: Axis.horizontal,
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       children: [
  //                         _buildTextFieldPopup(
  //                           'Invoice No',
  //                           invoiceNoController.text,
  //                           Icons.numbers,
  //                           true,
  //                           33,
  //                           120,
  //                         ),
  //                         SizedBox(
  //                           width: 8,
  //                         ),
  //                         _buildTextFieldPopup(
  //                           'Item Code',
  //                           ItemcodeController.text,
  //                           Icons.numbers,
  //                           true,
  //                           33,
  //                           120,
  //                         ),
  //                         SizedBox(
  //                           width: 8,
  //                         ),
  //                         _buildTextFieldPopup(
  //                           'Item Description',
  //                           itemDescriptionController.text,
  //                           Icons.numbers,
  //                           true,
  //                           33,
  //                           200,
  //                         ),
  //                         SizedBox(
  //                           width: 8,
  //                         ),
  //                         _buildScanField(0)
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               }),
  //             if (Responsive.isMobile(context))
  //               StatefulBuilder(builder: (context, setState) {
  //                 return Padding(
  //                   padding: const EdgeInsets.only(left: 5.0),
  //                   child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     children: [
  //                       _buildInfoRow(Icons.receipt, 'Invoice No:',
  //                           invoiceNoController.text),
  //                       _buildInfoRow(
  //                           Icons.code, 'Item Code:', ItemcodeController.text),
  //                       _buildInfoRow(Icons.description, 'Item Desc:',
  //                           itemDescriptionController.text,
  //                           minLines: 4),
  //                       Row(
  //                         children: [
  //                           Transform.scale(
  //                             scale: 0.8,
  //                             child: Radio(
  //                               value: 0,
  //                               groupValue: _scanMode,
  //                               onChanged: (value) {
  //                                 setState(() {
  //                                   _scanMode = value!;
  //                                   if (_scanMode == 0) {
  //                                     // Delay required to allow widget to build before focusing
  //                                     Future.delayed(
  //                                         Duration(milliseconds: 300), () {
  //                                       FocusScope.of(context)
  //                                           .requestFocus(barcodeFocusNodes[0]);
  //                                     });
  //                                   }
  //                                 });
  //                               },
  //                             ),
  //                           ),
  //                           Text("Barcode", style: TextStyle(fontSize: 13)),
  //                           SizedBox(width: 10),
  //                           Transform.scale(
  //                             scale: 0.8,
  //                             child: Radio(
  //                               value: 1,
  //                               groupValue: _scanMode,
  //                               onChanged: (value) {
  //                                 setState(() {
  //                                   _scanMode = value!;
  //                                 });
  //                               },
  //                             ),
  //                           ),
  //                           Text("Cam/Manual", style: TextStyle(fontSize: 13)),
  //                         ],
  //                       ),
  //                       SingleChildScrollView(
  //                           scrollDirection: Axis.horizontal,
  //                           child: _buildScanField(0)),
  //                     ],
  //                   ),
  //                 );
  //               }),
  //             const SizedBox(
  //               height: 5,
  //             ),
  //             const Divider(),
  //             const SizedBox(
  //               height: 10,
  //             ),

  //             _viewbuildTable(),

  //             const SizedBox(
  //               height: 10,
  //             ),
  //             // Padding(
  //             //   padding: EdgeInsets.all(Responsive.isDesktop(context) ? 15 : 5),
  //             //   child: Container(
  //             //     height: 200,
  //             //     child: SingleChildScrollView(
  //             //       scrollDirection: Axis.vertical,
  //             //       child: _viewbuildTable(),
  //             //     ),
  //             //   ),
  //             // ),
  //             const SizedBox(height: 15),
  //             Responsive.isDesktop(context)
  //                 ? Row(
  //                     children: [
  //                       SizedBox(
  //                           width: Responsive.isDesktop(context) ? 30 : 10),
  //                       Text(
  //                         'No. of Items: $totalItems',
  //                         style: const TextStyle(
  //                             color: Colors.black,
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.bold),
  //                       ),
  //                       const SizedBox(width: 30),
  //                       Text(
  //                         'Scanned Items: ${tableData.length}', // Dynamically updated text
  //                         style: const TextStyle(
  //                             color: Colors.black,
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.bold),
  //                       ),
  //                       const SizedBox(width: 30),
  //                       Text(
  //                         'Balance Items: ${totalItems - tableData.length}',
  //                         style: const TextStyle(
  //                             color: Colors.black,
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.bold),
  //                       ),
  //                     ],
  //                   )
  //                 : Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       SizedBox(height: 10),
  //                       Text(
  //                         'No. of Items: $totalItems',
  //                         style: const TextStyle(
  //                             color: Colors.black,
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.bold),
  //                       ),
  //                       SizedBox(height: 10),
  //                       Text(
  //                         'Scanned Items: ${tableData.length}', // Dynamically updated text
  //                         style: const TextStyle(
  //                             color: Colors.black,
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.bold),
  //                       ),
  //                       SizedBox(height: 10),
  //                       Text(
  //                         'Balance Items: ${totalItems - tableData.length}',
  //                         style: const TextStyle(
  //                             color: Colors.black,
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.bold),
  //                       ),
  //                     ],
  //                   ),
  //             Padding(
  //               padding: const EdgeInsets.only(top: 25),
  //               child: Container(
  //                   height: 35,
  //                   decoration: BoxDecoration(color: buttonColor),
  //                   child: ElevatedButton(
  //                     onPressed: _isLoading
  //                         ? null
  //                         : () async {
  //                             await _onSavePressed();

  //                             // postLogData("Pick Man Scan Pop-up", "Saved");
  //                           },
  //                     style: ElevatedButton.styleFrom(
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       minimumSize:
  //                           const Size(45.0, 20.0), // Set width and height
  //                       backgroundColor: Colors
  //                           .transparent, // Make background transparent to show gradient
  //                       shadowColor: Colors
  //                           .transparent, // Disable shadow to preserve gradient
  //                     ),
  //                     child: _isLoading
  //                         ? Container(
  //                             height: 20,
  //                             child: const CircularProgressIndicator(
  //                               color: Colors.white,
  //                             ),
  //                           )
  //                         : Text('Save', style: TextStyle(color: Colors.white)),
  //                   )),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int totalItems = createtableData.length;

    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: Container(
        width: Responsive.isDesktop(context)
            ? screenWidth * 0.7
            : screenWidth * 0.9,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Scan Pop-Up View",
                        style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Count : ${tableData.length}/${widget.nofoqty.contains('.') ? widget.nofoqty.split('.')[0] : widget.nofoqty}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (validProductCode == null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Checkbox(
                                value: byepassCheckbox,
                                onChanged: toggleCheckbox,
                              ),
                              const Text('Bypass Product Code and Serial No'),
                            ],
                          ),
                        ],
                      ),

                    // Desktop fields
                    if (!Responsive.isMobile(context))
                      StatefulBuilder(builder: (context, setState) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildTextFieldPopup(
                                    'Invoice No',
                                    invoiceNoController.text,
                                    Icons.numbers,
                                    true,
                                    33,
                                    120),
                                const SizedBox(width: 8),
                                _buildTextFieldPopup(
                                    'Item Code',
                                    ItemcodeController.text,
                                    Icons.numbers,
                                    true,
                                    33,
                                    120),
                                const SizedBox(width: 8),
                                _buildTextFieldPopup(
                                    'Item Description',
                                    itemDescriptionController.text,
                                    Icons.numbers,
                                    true,
                                    33,
                                    200),
                                const SizedBox(width: 8),
                                _buildScanField(0),
                              ],
                            ),
                          ),
                        );
                      }),

                    // Mobile fields
                    if (Responsive.isMobile(context))
                      StatefulBuilder(builder: (context, setState) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Column(
                            children: [
                              _buildInfoRow(Icons.receipt, 'Invoice No:',
                                  invoiceNoController.text),
                              _buildInfoRow(Icons.code, 'Item Code:',
                                  ItemcodeController.text),
                              _buildInfoRow(Icons.description, 'Item Desc:',
                                  itemDescriptionController.text,
                                  minLines: 4),
                              Row(
                                children: [
                                  Transform.scale(
                                    scale: 0.8,
                                    child: Radio(
                                      value: 0,
                                      groupValue: _scanMode,
                                      onChanged: (value) {
                                        setState(() {
                                          _scanMode = value!;
                                          if (_scanMode == 0) {
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 300), () {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      barcodeFocusNodes[0]);
                                            });
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  const Text("Barcode",
                                      style: TextStyle(fontSize: 13)),
                                  const SizedBox(width: 10),
                                  Transform.scale(
                                    scale: 0.8,
                                    child: Radio(
                                      value: 1,
                                      groupValue: _scanMode,
                                      onChanged: (value) {
                                        setState(() {
                                          _scanMode = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  const Text("Cam/Manual",
                                      style: TextStyle(fontSize: 13)),
                                ],
                              ),
                              SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: _buildScanField(0)),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 5),
                    const Divider(),
                    const SizedBox(height: 10),

                    _viewbuildTable(),
                    const SizedBox(height: 10),

                    Responsive.isDesktop(context)
                        ? Row(
                            children: [
                              const SizedBox(width: 30),
                              Text('No. of Items: $totalItems',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 30),
                              Text('Scanned Items: ${tableData.length}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 30),
                              Text(
                                  'Balance Items: ${totalItems - tableData.length}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Text('No. of Items: $totalItems',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Text('Scanned Items: ${tableData.length}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Text(
                                  'Balance Items: ${totalItems - tableData.length}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                  ],
                ),
              ),
            ),

            // Footer Save Button (fixed at bottom)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async => await _onSavePressed(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Save',
                              style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Helper method to build the info row
  Widget _buildInfoRow(IconData icon, String label, String value,
      {int minLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.blueAccent,
          ), // Add the icon here
          SizedBox(width: 3), // Space between icon and label
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 99, 97, 97)),
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(
              value,
              maxLines: minLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewbuildTable() {
    return Padding(
      padding: Responsive.isDesktop(context)
          ? EdgeInsets.only(left: 15.0)
          : EdgeInsets.only(left: 0),
      child: Container(
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[400]!, // Border color
                      width: 1.0, // Border width
                    ),
                  ),
                  height: 220,
                  width: Responsive.isDesktop(context)
                      ? MediaQuery.of(context).size.width * 0.54
                      : MediaQuery.of(context).size.width * 0.80,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildHeaderCell("Product Code", Icons.code),
                            buildHeaderCell(
                                "Serial No", Icons.format_list_numbered),
                            buildHeaderDeleteCell('', Icons.delete),
                          ],
                        ),
                      ),
                      if (_isLoading)
                        Padding(
                          padding: const EdgeInsets.only(top: 60.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (tableData.isNotEmpty)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: tableData.map((data) {
                                var index = tableData.indexOf(data);
                                return buildRow(index, data);
                              }).toList(),
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: 60.0),
                          child: Text("No data available."),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRow(int index, Map<String, dynamic> data) {
    var productcode = data['Product Code'];
    var serialno = data['Serial No'];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDataCell(productcode),
            buildDataCell(serialno),
            buildDeleteCell(index, data),
          ],
        ),
      ),
    );
  }

  Widget buildDeleteCell(int index, Map<String, dynamic> data) {
    var productcode = data['Product Code'];
    var serialno = data['Serial No'];
    return Container(
      width: 50,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
      ),
      child: IconButton(
        icon: Icon(Icons.delete, size: 18),
        color: Colors.red,
        onPressed: () {
          postLogData("Truck Loading Scan pop-up",
              "Deleted Already Added with ProductCode $productcode and Serialno $serialno");
          _deleteRow(index);
        },
      ),
    );
  }

  void _deleteRow(int index) async {
    // First remove from the local tableData list
    setState(() {
      tableData.removeAt(index);
    });

    // Then update SharedPreferences
    await _updateSharedPreferences();

    // Optional: Show a snackbar confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

// Helper method to update SharedPreferences
  Future<void> _updateSharedPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String key =
          'tableData_${widget.pickno}_${widget.reqno}_${widget.itemcode}_${widget.itemdetails}_${widget.invoiceno}';

      // Convert current tableData to string list
      List<String> tableDataStringList = tableData.map((data) {
        return json.encode(data);
      }).toList();

      // Save to SharedPreferences
      await prefs.setStringList(key, tableDataStringList);
    } catch (e) {
      print('Error updating SharedPreferences: $e');
      // Optionally show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update storage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget buildDataCell(String value) {
    return Flexible(
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(
              color: Color.fromARGB(255, 226, 225, 225)), // Border color
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: SelectableText(
                value,
                textAlign: TextAlign.left,
                style: TableRowTextStyle,
                showCursor: false,
                cursorColor: Colors.blue,
                cursorWidth: 2.0,
                toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeaderCell(String label, IconData icon) {
    return Flexible(
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(
              color: Color.fromARGB(255, 226, 225, 225)), // Border color
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 15, color: Colors.blue),
              SizedBox(width: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TableRowTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeaderDeleteCell(String label, IconData icon) {
    return Container(
      width: 50,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(
            color: Color.fromARGB(255, 226, 225, 225)), // Border color
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: Colors.blue),
            SizedBox(width: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TableRowTextStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldPopup(
    String label,
    String value,
    IconData icon,
    bool readOnly,
    double height,
    double width, {
    int? minLines,
    int? maxLines,
    TextInputType keyboardType = TextInputType.text,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(left: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Responsive.isDesktop(context) ? 20 : 10),
            Row(
              children: [
                Text(label, style: textboxheading),
                if (!readOnly)
                  Icon(
                    Icons.star,
                    size: 8,
                    color: Colors.red,
                  )
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 0, bottom: 0),
              child: Row(
                children: [
                  Container(
                      height: height,
                      // width: Responsive.isDesktop(context)
                      //     ? screenWidth * 0.086
                      //     : 130,

                      width: width,
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
                          message: value,
                          child: TextFormField(
                            readOnly: readOnly,
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
                              filled: true, // Enable the background fill
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
                            keyboardType: keyboardType,
                            minLines: minLines,
                            maxLines: maxLines, // Allows wrapping
                            controller: TextEditingController(text: value),
                            style: TextStyle(
                                color: Color.fromARGB(255, 73, 72, 72),
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
    );
  }

  bool _isLoading = false;

  // Mock function to simulate async operation
  Future<void> _onSavePressed() async {
    int totalItems = createtableData.length;
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Replace with your actual logic here
      await Future.delayed(Duration(milliseconds: 100)); // Simulate async work

      bool allFieldsEmpty = tableData.isEmpty;

      bool productCodeInvalid = false;
      int invalidBarcodeIndex = -1;

      // Validate barcodes
      for (int i = 0; i < barcodeControllers.length; i++) {
        String barcodeValue = barcodeControllers[i].text;
        if (barcodeValue.isNotEmpty && barcodeValue != validProductCode) {
          productCodeInvalid = true;
          invalidBarcodeIndex = i;
          break;
        }
      }

      if (validProductCode == null) {
        // Show confirmation dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmation', style: TextStyle(fontSize: 14)),
              content: const Text(
                  'Are you sure you want to save this product code and serial number details?',
                  style: TextStyle(fontSize: 12)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    int balanceqty = totalItems - tableData.length;
                    print('balanceqty: $balanceqty');

                    try {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      );
                      await sendProductDetails(); // Call function to save data
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      postLogData("Load Man Pop-Up ",
                          "Saved ${tableData.length} Quantities under the RequestNo ${widget.reqno} and Pickid ${widget.pickno}");

                      Navigator.of(context).pop();
                    } catch (e) {
                      Navigator.of(context).pop(); // close loader if open
                      print('Error saving data: $e');
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: Text('Failed to save data: $e'),
                            actions: [
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

                    // int balanceqty = totalItems - tableData.length;
                    // print('okkk balanceqty: $balanceqty');

                    // await sendProductDetails(); // Save data
                    // Navigator.of(context).pop();
                    // await Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => MainSidebar(
                    //       enabledItems: accessControl,
                    //       initialPageIndex: 17,
                    //     ),
                    //   ),
                    // );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Handling empty fields and invalid barcodes
        if (allFieldsEmpty) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Warning', style: TextStyle(fontSize: 17)),
                content: const Text(' Kindly fill all the fields.',
                    style: TextStyle(fontSize: 15)),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else if (productCodeInvalid) {
          print("savebutonnnnn");
          if (byepassCheckbox = true)
            showwarningbarcode(context, barcodeControllers[invalidBarcodeIndex],
                barcodeFocusNodes[invalidBarcodeIndex]);
        } else {
          // Check for missing serial numbers
          List<int> missingSerialnoIndexes = [];
          for (int i = 0; i < barcodeControllers.length; i++) {
            String barcodeValue = barcodeControllers[i].text;
            String serialnoValue = serialnoControllers[i].text;

            if (barcodeValue.isNotEmpty && serialnoValue.isEmpty) {
              missingSerialnoIndexes.add(i);
            }
          }

          if (missingSerialnoIndexes.isNotEmpty && validProductCode != '00') {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Warning', style: TextStyle(fontSize: 17)),
                  content: const Text(
                      'You entered barcode(s) without filling the corresponding serial number(s). Kindly fill in all fields.',
                      style: TextStyle(fontSize: 15)),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        for (var index in missingSerialnoIndexes) {
                          serialnoControllers[index].clear();
                        }
                        FocusScope.of(context).requestFocus(
                            serialnoFocusNodes[missingSerialnoIndexes[0]]);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          } else {
            // Check for duplicate serial numbers
            Set<String> seenSerials = {};
            bool hasDuplicates = false;
            List<int> duplicateIndexes = [];

            for (int i = 0; i < serialnoControllers.length; i++) {
              String serialValue = serialnoControllers[i].text;
              if (serialValue.isNotEmpty) {
                if (seenSerials.contains(serialValue)) {
                  hasDuplicates = true;
                  duplicateIndexes.add(i);
                } else {
                  seenSerials.add(serialValue);
                }
              }
            }

            if (hasDuplicates) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title:
                        const Text('Warning', style: TextStyle(fontSize: 17)),
                    content: const Text(
                        'Duplicate serial numbers found. Kindly ensure all serial numbers are unique.',
                        style: TextStyle(fontSize: 15)),
                    actions: [
                      TextButton(
                        onPressed: () {
                          for (var index in duplicateIndexes) {
                            serialnoControllers[index].clear();
                          }
                          Navigator.of(context).pop(); // Close dialog
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            } else {
              // Proceed with saving data
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirmation',
                        style: TextStyle(fontSize: 13)),
                    content: const Text(
                        'Are you sure you want to save this product code and serial number details?',
                        style: TextStyle(fontSize: 13)),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          int balanceqty = totalItems - tableData.length;
                          print('balanceqty: $balanceqty');

                          try {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => const Center(
                                  child: CircularProgressIndicator()),
                            );
                            await sendProductDetails(); // Call function to save data
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            postLogData("Load Man Pop-Up ",
                                "Saved ${tableData.length} Quantities under the RequestNo ${widget.reqno} and Pickid ${widget.pickno}");

                            Navigator.of(context).pop();
                          } catch (e) {
                            Navigator.of(context).pop(); // close loader if open
                            print('Error saving data: $e');
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: Text('Failed to save data: $e'),
                                  actions: [
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
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          }
        }
      }
    } catch (e) {
      // Handle unexpected errors
      print('Unexpected error: $e');
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'An unexpected error occurred. Please try again later.'),
            actions: [
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
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }
// Function to fetch serial numbers from the API

  // Future<List<String>> fetchExistingSerialNumbers() async {
  //   Set<String> serialNumbers = {}; // Use Set to automatically avoid duplicates
  //   String? url = '$IpAddress/Pickman_scan/';

  //   while (url != null) {
  //     final response = await http.get(Uri.parse(url));

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);

  //       // Add serial numbers from the current page to the set if FLAG != 'R' and FLAG != 'SR'
  //       for (var item in data['results']) {
  //         if (item['FLAG'] != 'R' && item['FLAG'] != 'SR') {
  //           serialNumbers
  //               .add(item['SERIAL_NO']); // Adding to Set prevents duplicates
  //         }
  //       }

  //       // Update the URL for the next page, or null if there is no next page
  //       url = data['next'];
  //     } else {
  //       throw Exception('Failed to load serial numbers');
  //     }
  //   }

  //   // Convert Set back to List to return it
  //   return serialNumbers.toList();
  // }

  Future<List<String>> fetchExistingSerialNumbers({
    String? productCode,
  }) async {
    print("entered in to teh serialno check");
    Set<String> serialNumbers = {}; // Use Set to automatically avoid duplicates

    final IpAddress = await getActiveIpAddress();

    String? url = '$IpAddress/Pickman_scan/';

    while (url != null) {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Add serial numbers from the current page to the set if FLAG != 'R' and FLAG != 'SR'
        for (var item in data['results']) {
          if (item['FLAG'] != 'R' &&
              item['FLAG'] != 'SR' &&
              item['PRODUCT_CODE'] == productCode) {
            serialNumbers
                .add(item['SERIAL_NO']); // Adding to Set prevents duplicates
          }
        }

        // Update the URL for the next page, or null if there is no next page
        url = data['next'];
      } else {
        throw Exception('Failed to load serial numbers');
      }
    }

    // Convert Set back to List to return it
    return serialNumbers.toList();
  }

  Future<bool> checkIfSerialExistsInPaginatedApi(
    String apiUrl,
    String serialNo, {
    String? productCode,
  }) async {
    print(
        "Checking if serial exists in paginated API: $apiUrl $serialNo  $productCode");
    String? nextUrl = apiUrl;

    while (nextUrl != null) {
      final response = await http.get(Uri.parse(nextUrl));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<dynamic> results = jsonData['results'];

        // Check for existence of the serial number, product code, and FLAG == 'R'
        bool exists = results.any((item) {
          bool matchesSerial = item['SERIAL_NO'] == serialNo;
          // bool matchesProduct =
          // productCode == null || item['PRODUCT_CODE'] == productCode;
          bool matchesProduct = item['PRODUCT_CODE'] == productCode;
          bool matchesFlag = item['FLAG'] != 'R' && item['FLAG'] != 'SR';
          return matchesSerial && matchesProduct && matchesFlag;
        });

        if (exists) {
          return true; // Serial number found in the current page
        }

        nextUrl = jsonData['next']; // Update nextUrl for pagination
      } else {
        print('Failed to fetch data from API: ${response.statusCode}');
        throw Exception('Error fetching data from API.');
      }
    }

    return false; // Serial number not found in all pages
  }

  // Future<bool> _isDuplicateEntry(
  //   String text,
  //   String serialnovalue,
  //   String value, {
  //   String? productCode,
  // }) async {
  //   print("Checking: $text | Serial No: $serialnovalue | Product: $value");

  //   final IpAddress = await getActiveIpAddress();

  //   String apiUrl = '$IpAddress/Truck_scan/';
  //   bool existsInPaginatedApi = await checkIfSerialExistsInPaginatedApi(
  //     apiUrl,
  //     serialnovalue,
  //     productCode: value,
  //   );
  //   if (existsInPaginatedApi) {
  //     print("Found in paginated API");
  //     return true;
  //   }

  //   List<String> existingSerialNumbers =
  //       await fetchExistingSerialNumbers(productCode: value);
  //   if (existingSerialNumbers.contains(serialnovalue)) {
  //     print("Found in all serial numbers");
  //     return true;
  //   }

  //   print("No duplicates found");
  //   return false;
  // }

  Future<bool> _isDuplicateEntry(
    String text,
    String serialnovalue,
    String value, {
    String? productCode,
  }) async {
    print("Checking: $text | Serial No: $serialnovalue | Product: $value");
    final IpAddress = await getActiveIpAddress();

    // Build the URL with query parameters
    final String apiUrl =
        '$IpAddress/check-duplicate/?product_code=$value&serial_no=$serialnovalue';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Expecting response format: { "is_duplicate": true/false }
        bool isDuplicate = data['is_duplicate'] ?? false;
        print("Duplicate check result: $isDuplicate");
        return isDuplicate;
      } else {
        print(
            "Failed to fetch duplicate status. Status code: ${response.statusCode}");
        return false; // fallback to false on failed request
      }
    } catch (e) {
      print("Error checking duplicate: $e");
      return false; // fallback to false on error
    }
  }

  Future<void> _showDuplicateAlert(
    BuildContext context,
    String heading,
    TextEditingController controller,
    FocusNode focusNode,
  ) async {
    // Set the flag before showing dialog
    isDuplicateAlertShown = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(heading, style: const TextStyle(fontSize: 18)),
          content: const Text("This code already exists.",
              style: TextStyle(fontSize: 13)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
                controller.clear(); // Clear the controller
                focusNode.requestFocus(); // Refocus the field
                // Reset the flag after dialog is dismissed
                isDuplicateAlertShown = false;
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showWarning(BuildContext context, TextEditingController controller,
      FocusNode focusNode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Warning", style: TextStyle(fontSize: 18)),
          content: Text("This field cannot be  empty",
              style: TextStyle(fontSize: 13)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

//   Widget _viewbuildTable() {
//     return Scrollbar(
//       thumbVisibility: true,
//       controller: _horizontalScrollController,
//       child: SingleChildScrollView(
//         controller: _horizontalScrollController,
//         scrollDirection: Axis.horizontal,
//         child: Container(
//           width: Responsive.isDesktop(context)
//               ? MediaQuery.of(context).size.width * 0.50
//               : MediaQuery.of(context).size.width * 1.1,
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // _buildTableHeaderCell("No"),
//                     // _buildTableHeaderCell("Invoice No"),
//                     // _buildTableHeaderCell("Item Code"),
//                     // _buildTableHeaderCell("Item Details"),
//                     _buildTableHeaderCell("Product Code"),
//                     _buildTableHeaderCell("Serial No"),
//                   ],
//                 ),
//               ),
//               ...createtableData.asMap().entries.map((entry) {
//                 int index = entry.key;
//                 return _buildDataRow(index);
//               }).toList(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTableHeaderCell(String label) {
//     return Flexible(
//       child: Container(
//         height: Responsive.isDesktop(context) ? 25 : 30,
//         color: Colors.grey.shade300,
//         child: Center(
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Text(label,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold)),
//           ),
//         ),
//       ),
//     );
//   }

// // Updated _buildDataRow function to apply the duplicate check only to serialnoControllers
//   Widget _buildDataRow(int index) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           if (index < barcodeControllers.length)
//             Flexible(
//               child: _buildInputField(
//                 controller: barcodeControllers[
//                     index], // Pass the controller for barcode
//                 focusNode:
//                     barcodeFocusNodes[index], // Pass the focusNode for barcode
//                 textInputAction:
//                     TextInputAction.next, // Set the next action for input field
//                 icon1: Icons.qr_code_scanner, // Set the first icon
//                 iconColor1: Colors.blue, // Set the color for the first icon
//                 icon2: Icons.camera_alt, // Set the second icon
//                 iconColor2: Colors.green, // Set the color for the second icon
//                 onIconPressed: () => _openScannerProdCode(
//                     barcodeControllers[index],
//                     barcodeFocusNodes[index],
//                     index), // Icon press action
//                 // onIconPressed: () => {},

//                 onFieldSubmitted: (value) {
//                   // Barcode validation and field switching logic
//                   if (validProductCode != null) {
//                     if (barcodeControllers[index].text.isNotEmpty &&
//                         barcodeControllers[index].text == validProductCode) {
//                       if (index < createtableData.length) {
//                         FocusScope.of(context)
//                             .requestFocus(serialnoFocusNodes[index]);
//                       }
//                     } else {
//                       showwarningbarcode(
//                         context,
//                         barcodeControllers[index],
//                         barcodeFocusNodes[index],
//                       );
//                     }
//                   }

//                   // else {
//                   //   if (barcodeControllers[index].text.isNotEmpty) {
//                   //     if (index < createtableData.length) {
//                   //       FocusScope.of(context)
//                   //           .requestFocus(serialnoFocusNodes[index]);
//                   //     }
//                   //   }
//                   // }
//                 },
//                 index: index, // Pass the index to track specific controller
//               ),
//             ),
//           if (index < serialnoControllers.length)
//             Flexible(
//               child: _buildInputField(
//                 controller: serialnoControllers[
//                     index], // Pass the controller for serialno
//                 focusNode: serialnoFocusNodes[
//                     index], // Pass the focusNode for serialno
//                 textInputAction:
//                     TextInputAction.next, // Set the next action for input field
//                 icon1: Icons.qr_code_scanner, // Set the first icon
//                 iconColor1: Colors.blue, // Set the color for the first icon
//                 icon2: Icons.camera_alt, // Set the second icon
//                 iconColor2: Colors.green, // Set the color for the second icon
//                 onIconPressed: () =>
//                     _openScannerSerial(index), // Icon press action
//                 // onIconPressed: () => {},
//                 onFieldSubmitted: (value) async {
//                   if (serialnoControllers[index].text.isEmpty) {
//                     _showWarning(context, serialnoControllers[index],
//                         serialnoFocusNodes[index]);
//                   } else if (await _isDuplicateEntry(
//                       serialnoControllers, value)) {
//                     _showDuplicateAlert(context, serialnoControllers[index],
//                         serialnoFocusNodes[index]);
//                   } else {
//                     if (index < createtableData.length - 1) {
//                       FocusScope.of(context)
//                           .requestFocus(barcodeFocusNodes[index + 1]);
//                     } else {
//                       FocusScope.of(context).requestFocus(barcodeFocusNodes[0]);
//                     }
//                   }
//                 },

//                 index: index, // Pass the index to track specific controller
//               ),
//             ),
//         ],
//       ),
//     );
//   }

  List<Map<String, String>> tableData = []; // Table data
  bool isProcessing = false; // Declare the isProcessing variable

  Future<bool> _isDuplicateEntryNew(
      List<TextEditingController> controllers, String serialNo) async {
    // Check for duplicate entries based on serialNo (you can implement the actual check logic here)
    for (var controller in controllers) {
      if (controller.text == serialNo) {
        return true; // Duplicate entry found
      }
    }
    return false; // No duplicate found
  }

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog manually
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: const [
              CircularProgressIndicator(color: Colors.blue),
              SizedBox(width: 20),
              Text(
                "Processing...",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  // Future<void> _addToTable(int index) async {
  //   // Prevent multiple submissions while processing
  //   if (isProcessing) return;

  //   String barcode =
  //       barcodeControllers[index].text.trim(); // Trim spaces from the input
  //   String serialNo = serialnoControllers[index].text.trim();

  //   // Validation: Check if fields are empty
  //   if (barcode.isEmpty || serialNo.isEmpty) {
  //     _showWarningDialog(context, "Warning",
  //         "Kindly fill in all the information by scanning.");
  //     return;
  //   }

  //   // Validation: Check if barcode matches valid product code
  //   if (!_isButtonDisabled) {
  //     print('showwarningbarcode  -$barcode-${validProductCode.toString()}');
  //     if (barcode != validProductCode.toString()) {
  //       showwarningbarcode(
  //           context, barcodeControllers[index], barcodeFocusNodes[index]);
  //       return;
  //     }
  //   }

  //   // Validation: Check for duplicate serial number
  //   if (!_isButtonDisabled) {
  //     if (await _isDuplicateEntry(serialnoControllers, serialNo)) {
  //       if (!isDuplicateAlertShown) {
  //         _showDuplicateAlert(
  //           context,
  //           serialnoControllers[index],
  //           serialnoFocusNodes[index],
  //         );
  //         isDuplicateAlertShown = true; // Mark the duplicate alert as shown
  //       }
  //       return; // Prevent duplicate entry
  //     }
  //   }

  //   // Validation: Ensure serial number is valid
  //   if (serialNo.isEmpty) {
  //     _showDuplicateAlert(
  //       context,
  //       serialnoControllers[index],
  //       serialnoFocusNodes[index],
  //     );
  //     print('Invalid serial number');
  //     return; // Prevent invalid entry
  //   }

  //   // Disable the button temporarily to prevent multiple clicks
  //   setState(() {
  //     isProcessing = true;
  //   });
  //   try {
  //     // Add data to the table
  //     setState(() {
  //       tableData.add({
  //         'Product Code': barcode,
  //         'Serial No': serialNo,
  //       });

  //       // Clear the input fields
  //       barcodeControllers[index].clear();
  //       serialnoControllers[index].clear();
  //     });
  //   } catch (e) {
  //     print("Error adding to table: $e");
  //   } finally {
  //     // Re-enable the button once the operation is complete
  //     setState(() {
  //       isProcessing = false;
  //     });
  //   }
  // }

  Future<void> _addToTable(int index) async {
    if (isProcessing) return; // Prevent multiple submissions

    String barcode = barcodeControllers[index].text.trim();
    String serialNo = serialnoControllers[index].text.trim();

    // Validation: Check if fields are empty
    if (barcode.isEmpty || serialNo.isEmpty) {
      _showWarningDialog(context, "Warning",
          "Kindly fill in all the information by scanning.");
      return;
    }

    // Check for valid product code only if button is not disabled
    if (!_isButtonDisabled && barcode != validProductCode.toString()) {
      if (byepassCheckbox) {
        showwarningbarcode(
            context, barcodeControllers[index], barcodeFocusNodes[index]);
      }
      return;
    }

    // // Check for duplicate serial number
    // if (await _isDuplicateEntry(
    //     'Checking for duplicate entry1111111', serialNo, barcode)) {
    //   _showDuplicateAlert(context, "Duplicate Entry",
    //       serialnoControllers[index], serialnoFocusNodes[index]);
    //   return;
    // }

    // Disable the button temporarily to prevent multiple clicks
    setState(() {
      isProcessing = true;
    });

    try {
      // Add data to the table
      tableData.add({
        'Product Code': barcode,
        'Serial No': serialNo,
      });
      unawaited(postLogData("Load Man Pop-Up added",
          "Added ProductCode and SerialNo as 1 quantity under the RequestNo ${widget.reqno} and Pickid ${widget.pickno}"));

      // Clear the input fields
      barcodeControllers[index].clear();
      serialnoControllers[index].clear();

      // Manage focus
      if (tableData.length != int.parse(widget.nofoqty.split('.')[0])) {
        if (validProductCode == '00') {
          print("entered in to no product code ");
          FocusScope.of(context).requestFocus(serialnoFocusNodes[index]);
        } else {
          print("entered product code ");
          FocusScope.of(context).requestFocus(barcodeFocusNodes[index]);
        }
        print("adding to table: ");
      } else {
        FocusScope.of(context).unfocus();
        serialnoFocusNodes[index].unfocus();
        print(" table:eeeee ${tableData.length}");
      }
    } catch (e) {
      print("Error adding to table: $e");
    } finally {
      setState(() {
        isProcessing = false; // Re-enable the button
      });
    }
  }

  Future<void> _addToTablebypass(int index) async {
    if (isProcessing) return; // Prevent multiple submissions

    String barcode = barcodeControllers[index].text.trim();
    String serialNo = serialnoControllers[index].text.trim();

    // Parse maxQty once
    int maxQty = widget.nofoqty.contains('.')
        ? int.parse(widget.nofoqty.split('.')[0])
        : int.parse(widget.nofoqty);

    print("Max quantity allowed: $maxQty");

    // Allow '00' and empty values
    bool isBarcodeEmpty = barcode.isEmpty || barcode == "00";
    bool isSerialEmpty = serialNo.isEmpty || serialNo == "null";

    // Validation: Barcode and Serial No cannot be same unless they're empty or "00"
    if (!isBarcodeEmpty && !isSerialEmpty && barcode == serialNo) {
      _showWarningDialog(
        context,
        "Warning",
        "Product code and serial number should not be the same.",
      );
      return;
    }

    // Validation: Check if barcode matches valid product code (if validation is enabled)
    if (!_isButtonDisabled && !isBarcodeEmpty) {
      if (barcode != validProductCode.toString()) {
        print("Barcode does not match valid product code.");
        if (byepassCheckbox == true) {
          showwarningbarcode(
            context,
            barcodeControllers[index],
            barcodeFocusNodes[index],
          );
        }
        return;
      }
    }

    setState(() {
      isProcessing = true;
    });

    try {
      // Determine how many more items can be added
      int remainingQty = maxQty - tableData.length;
      print("Remaining Qty: $remainingQty");

      for (int i = 0; i < remainingQty; i++) {
        tableData.add({
          'Product Code': barcode,
          'Serial No': serialNo,
        });
      }

      unawaited(postLogData("Load Man Pop-Up added",
          "Added ProductCode and SerialNo as $remainingQty quantity under the RequestNo ${widget.reqno} and Pickid ${widget.pickno}"));
      // Clear input fields
      barcodeControllers[index].clear();
      serialnoControllers[index].clear();

      FocusScope.of(context).unfocus();
    } catch (e) {
      print("Error adding to table: $e");
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  // Future<void> _addToTablebypass(int index) async {
  //   if (isProcessing) return; // Prevent multiple submissions

  //   String barcode = barcodeControllers[index].text.trim();
  //   String serialNo = serialnoControllers[index].text.trim();

  //   // Validation: Check if fields are empty
  //   if (barcode.isEmpty || serialNo.isEmpty) {
  //     _showWarningDialog(context, "Warning",
  //         "Kindly fill in all the information by scanning.");
  //     return;
  //   }

  //   // Validation: Product Code and Serial Number should not be the same
  //   if (barcode == serialNo) {
  //     _showWarningDialog(context, "Warning",
  //         "Product code and serial number should not be the same.");
  //     return;
  //   }

  //   // Validation: Check if barcode matches valid product code
  //   if (!_isButtonDisabled) {
  //     print(
  //         'showwarningbarcodeeeeeeeeeeeee  -$barcode-${validProductCode.toString()}');
  //     if (barcode != validProductCode.toString()) {
  //       print("savebutonnnnn3");
  //       if (byepassCheckbox == true) {
  //         showwarningbarcode(
  //             context, barcodeControllers[index], barcodeFocusNodes[index]);
  //       }
  //       return;
  //     }
  //   }

  //   // Validation: Check for duplicate serial number
  //   // if (_isButtonDisabled) {
  //   //   if (await _isDuplicateEntry(serialnoControllers, serialNo,
  //   //       productCode: barcode)) {
  //   //     _showDuplicateAlert(
  //   //       context,
  //   //       "Duplicate Entry",
  //   //       serialnoControllers[index],
  //   //       serialnoFocusNodes[index],
  //   //     );
  //   //     isDuplicateAlertShown = true;
  //   //     return;
  //   //   }
  //   // }

  //   // Validation: Ensure serial number is valid
  //   if (serialNo.isEmpty) {
  //     _showDuplicateAlert(
  //       context,
  //       "Duplicate Entry",
  //       serialnoControllers[index],
  //       serialnoFocusNodes[index],
  //     );
  //     print('Invalid serial number');
  //     return;
  //   }
  //   // Disable the button temporarily to prevent multiple clicks
  //   setState(() {
  //     isProcessing = true;
  //   });

  //   try {
  //     // Add data to the table

  //     setState(() {
  //       tableData.add({
  //         'Product Code': barcode,
  //         'Serial No': serialNo,
  //       });

  //       // Clear the input fields
  //       barcodeControllers[index].clear();
  //       serialnoControllers[index].clear();

  //       int maxQty = widget.nofoqty.contains('.')
  //           ? int.parse(widget.nofoqty.split('.')[0])
  //           : int.parse(widget.nofoqty);
  //       print("maxQtyyyyyyyyyy $maxQty");
  //       if (tableData.length != maxQty) {
  //         FocusScope.of(context).requestFocus(barcodeFocusNodes[index]);
  //       } else {
  //         FocusScope.of(context).unfocus();
  //         serialnoFocusNodes[index].unfocus();
  //       }
  //     });

  //     // Clear the input fields
  //     barcodeControllers[index].clear();
  //     serialnoControllers[index].clear();
  //   } catch (e) {
  //     print("Error adding to table: $e");
  //   } finally {
  //     setState(() {
  //       isProcessing = false; // Re-enable the button
  //     });
  //   }
  // }

  // Future<void> _addToTable(int index) async {
  //   // Prevent multiple submissions while processing
  //   if (isProcessing) return;

  //   String barcode =
  //       barcodeControllers[index].text.trim(); // Trim spaces from the input
  //   String serialNo = serialnoControllers[index].text.trim();

  //   // Validation: Check if fields are empty
  //   if (barcode.isEmpty || serialNo.isEmpty) {
  //     _showWarningDialog(context, "Warning",
  //         "Kindly fill in all the information by scanning.");
  //     return;
  //   }

  //   // Validation: Check if barcode matches valid product code
  //   if (!_isButtonDisabled) {
  //     print(
  //         'showwarningbarcodeeeeeeeeeeeee  -$barcode-${validProductCode.toString()}');
  //     if (barcode != validProductCode.toString()) {
  //       print("savebutonnnnn3");
  //       if (byepassCheckbox = true)
  //         showwarningbarcode(
  //             context, barcodeControllers[index], barcodeFocusNodes[index]);
  //       return;
  //     }
  //   }

  //   // Validation: Check for duplicate serial number
  //   if (_isButtonDisabled) {
  //     if (await _isDuplicateEntry(serialnoControllers, serialNo,
  //         productCode: barcode)) {
  //       // if (!isDuplicateAlertShown)
  //       {
  //         _showDuplicateAlert(
  //           context,
  //           "Duplicate Entry",
  //           serialnoControllers[index],
  //           serialnoFocusNodes[index],
  //         );
  //         isDuplicateAlertShown = true; // Mark the duplicate alert as shown
  //       }
  //       return; // Prevent duplicate entry
  //     }
  //   }

  //   // Validation: Ensure serial number is valid
  //   if (serialNo.isEmpty) {
  //     _showDuplicateAlert(
  //       context,
  //       "Duplicate Entry",
  //       serialnoControllers[index],
  //       serialnoFocusNodes[index],
  //     );
  //     print('Invalid serial number');
  //     return; // Prevent invalid entry
  //   }

  //   // Disable the button temporarily to prevent multiple clicks
  //   setState(() {
  //     isProcessing = true;
  //   });
  //   try {
  //     // Add data to the table
  //     setState(() {
  //       tableData.add({
  //         'Product Code': barcode,
  //         'Serial No': serialNo,
  //       });

  //       // Clear the input fields
  //       barcodeControllers[index].clear();
  //       serialnoControllers[index].clear();
  //       if (tableData.length !=
  //           (widget.nofoqty.contains('.')
  //               ? int.parse(widget.nofoqty.split('.')[0])
  //               : int.parse(widget.nofoqty))) {
  //         FocusScope.of(context).requestFocus(barcodeFocusNodes[index]);
  //       } else {
  //         FocusScope.of(context).unfocus(); // Unfocus any existing focus
  //         serialnoFocusNodes[index].unfocus(); // Unfocus serial number field
  //       }
  //     });
  //   } catch (e) {
  //     print("Error adding to table: $e");
  //   } finally {
  //     // Re-enable the button once the operation is complete
  //     setState(() {
  //       isProcessing = false;
  //     });
  //   }
  // }

  bool _isButtonDisabled = false;
  bool isDuplicateAlertShown = false;

  FocusNode buttonFocus = FocusNode();
  FocusNode SerialcameraFocus = FocusNode();
  FocusNode ProductcameraFocus = FocusNode();
  int _scanMode = 0; // 0 = Barcode, 1 = Cam/Manual

  Widget _buildScanField(int index) {
    String quantity = widget.nofoqty ?? ''; // Ensure it’s not null
    quantity = quantity.contains('.') ? quantity.split('.')[0] : quantity;
    int maxQuantity = int.tryParse(quantity) ?? 0;
    // Use a fallback value if conversion fails
    Timer? _typingTimer;
    Timer? _serialTypingTimer; // Add this as a class member variable
    bool _isAdding = false; // Add this flag to prevent multiple additions

    return Padding(
      padding: Responsive.isDesktop(context)
          ? EdgeInsets.only(top: 50)
          : EdgeInsets.only(top: 10, right: 50),
      child: Padding(
        padding: const EdgeInsets.only(right: 0, top: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barcode TextField
// Barcode TextField
            if (index < barcodeControllers.length)
              Container(
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.3
                    : MediaQuery.of(context).size.width * 0.63,
                height: 33,
                child: TextField(
                  readOnly: (validProductCode == '00') ||
                      (validSerialno == null) ||
                      byepassCheckbox,
                  controller: barcodeControllers[index]
                    ..text = validProductCode == '00'
                        ? '00'
                        : barcodeControllers[index].text,
                  focusNode: barcodeFocusNodes[index],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(201, 132, 132, 132),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 58, 58, 58),
                        width: 1.0,
                      ),
                    ),
                    suffixIcon: (_scanMode == 1)
                        ? IconButton(
                            focusNode: ProductcameraFocus,
                            onPressed: () {
                              _openScannerProdCode(barcodeControllers[index],
                                  barcodeFocusNodes[index], index);
                            },
                            icon: Icon(Icons.camera_alt, color: Colors.green),
                          )
                        : null,
                    labelText: "Product Code",
                    labelStyle: TextStyle(fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 10.0,
                    ),
                  ),
                  // onSubmitted: (value) {
                  //   if (validProductCode != null &&
                  //       barcodeControllers[index].text.trim() ==
                  //           validProductCode.toString() &&
                  //       index < createtableData.length) {
                  //     // Focus on the Serial No camera input
                  //     FocusScope.of(context).requestFocus(SerialcameraFocus);

                  //     // Open the camera for Serial No immediately
                  //     _openScannerProdCode(
                  //         serialnoControllers[index], SerialcameraFocus, index);
                  //   } else {
                  //     print("savebutonnnnn5");
                  //     if (byepassCheckbox) {
                  //       showwarningbarcode(context, barcodeControllers[index],
                  //           barcodeFocusNodes[index]);
                  //     }
                  //   }
                  // },
                  onChanged: (value) {
                    final input =
                        value.trim().replaceAll(RegExp(r'[\n\r]'), '');
                    final validCode = validProductCode?.trim();

                    if (_scanMode == 0 && validCode != null) {
                      // Cancel previous timer if it exists
                      _typingTimer?.cancel();

                      // Start a new timer that will trigger after 500ms of inactivity
                      _typingTimer =
                          Timer(const Duration(milliseconds: 500), () {
                        if (input.length == validCode.length) {
                          if (input == validCode) {
                            // ✅ Valid → focus serial
                            FocusScope.of(context)
                                .requestFocus(serialnoFocusNodes[index]);
                          } else {
                            // ❌ Invalid → show warning
                            showwarningbarcode(
                              context,
                              barcodeControllers[index],
                              barcodeFocusNodes[index],
                            );
                            barcodeControllers[index].clear();
                            FocusScope.of(context)
                                .requestFocus(barcodeFocusNodes[index]);
                          }
                        }
                        // If length doesn't match, do nothing (user might still be typing)
                      });
                    }
                  },
                  onSubmitted: (value) {
                    final input =
                        value.trim().replaceAll(RegExp(r'[\n\r]'), '');
                    final validCode = validProductCode?.trim();

                    if (_scanMode == 0 &&
                        validCode != null &&
                        input == validCode) {
                      // ✅ Focus on Serial No
                      FocusScope.of(context)
                          .requestFocus(serialnoFocusNodes[index]);
                    } else {
                      // ❌ Invalid
                      showwarningbarcode(
                        context,
                        barcodeControllers[index],
                        barcodeFocusNodes[index],
                      );
                      barcodeControllers[index].clear();
                      FocusScope.of(context)
                          .requestFocus(barcodeFocusNodes[index]);
                    }
                  },

                  style: TextStyle(fontSize: 13),
                ),
              ),
            SizedBox(height: 15), // Add spacing between fields

            // Serial No TextField
            if (index < serialnoControllers.length)
              Container(
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.3
                    : MediaQuery.of(context).size.width * 0.63,
                height: 33,
                child: TextField(
                  readOnly: (validSerialno == 'null') ||
                      (validSerialno == null) ||
                      byepassCheckbox,
                  controller: serialnoControllers[index]
                    ..text = (validSerialno == 'null')
                        ? 'null'
                        : serialnoControllers[index].text,
                  focusNode: serialnoFocusNodes[index],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(201, 132, 132, 132),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 58, 58, 58),
                        width: 1.0,
                      ),
                    ),
                    suffixIcon: (_scanMode == 1)
                        ? IconButton(
                            focusNode: SerialcameraFocus,
                            onPressed: () {
                              _openScannerSerial(index);
                            },
                            icon: Icon(Icons.camera_alt, color: Colors.green),
                          )
                        : null,
                    labelText: "Serial No",
                    labelStyle: TextStyle(fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 10.0,
                    ),
                  ),
                  onChanged: (value) async {
                    final input =
                        value.trim().replaceAll(RegExp(r'[\n\r]'), '');
                    if (input.isEmpty) return;

                    // Cancel previous timer if it exists
                    _serialTypingTimer?.cancel();

                    // Start a new timer that will trigger after a delay
                    _serialTypingTimer =
                        Timer(const Duration(milliseconds: 500), () async {
                      // Prevent multiple additions and check if duplicate alert is already shown
                      if (_isAdding || isDuplicateAlertShown) return;

                      _isAdding = true;

                      try {
                        // Check for duplicate entry
                        // final isDuplicate = await _isDuplicateEntry(
                        //   'Checking for duplicate entry:2222',
                        //   serialnoControllers[index].text,
                        //   barcodeControllers[index].text,
                        // );

                        // if (isDuplicate) {
                        //   if (!isDuplicateAlertShown) {
                        //     isDuplicateAlertShown = true;
                        //     await _showDuplicateAlert(
                        //       context,
                        //       "Duplicate Entry",
                        //       serialnoControllers[index],
                        //       serialnoFocusNodes[index],
                        //     );
                        //     isDuplicateAlertShown =
                        //         false; // Reset after dialog is closed
                        //   }
                        //   return; // Exit if duplicate
                        // }

                        // Only proceed with addition if not a duplicate
                        await _handleAddSerial(index);

                        // Clear fields only if addition was successful
                        barcodeControllers[index].clear();
                        serialnoControllers[index].clear();

                        // Delay focus change to ensure fields are cleared
                        await Future.delayed(const Duration(milliseconds: 50));

                        if (mounted) {
                          if (validProductCode == '00') {
                            print("entered in to no product code 111");
                            FocusScope.of(context)
                                .requestFocus(serialnoFocusNodes[index]);
                          } else {
                            print("entered product code ");
                            FocusScope.of(context)
                                .requestFocus(barcodeFocusNodes[index]);
                          }
                        }
                      } finally {
                        _isAdding = false;
                      }
                    });
                  },

                  // onChanged: (text) async {
                  //   if (await _isDuplicateEntry(
                  //           serialnoControllers, text) &&
                  //       !isDuplicateAlertShown) {
                  //     _showDuplicateAlert(
                  //         context,
                  //         serialnoControllers[index],
                  //         serialnoFocusNodes[index]);
                  //     isDuplicateAlertShown =
                  //         true; // Set the flag to true after showing the alert
                  //   }
                  // },
                  // onSubmitted: (value) async {
                  //   if (serialnoControllers[index].text.isEmpty) {
                  //     _showWarning(context, serialnoControllers[index],
                  //         serialnoFocusNodes[index]);
                  //   } else if (await _isDuplicateEntry(
                  //           serialnoControllers, value) &&
                  //       !isDuplicateAlertShown) {
                  //     _showDuplicateAlert(
                  //         context,
                  //         "Duplicate Entry",
                  //         serialnoControllers[index],
                  //         serialnoFocusNodes[index]);
                  //     isDuplicateAlertShown =
                  //         true; // Prevent showing alert again
                  //   } else if (index < createtableData.length - 1) {
                  //     FocusScope.of(context).requestFocus(buttonFocus);
                  //   } else {
                  //     FocusScope.of(context).requestFocus(barcodeFocusNodes[0]);
                  //   }
                  // },

                  onSubmitted: (value) async {
                    if (_scanMode == 0) {
                      // Barcode mode auto add
                      if (serialnoControllers[index].text.isEmpty) {
                        _showWarning(context, serialnoControllers[index],
                            serialnoFocusNodes[index]);
                      }

                      //  else if (await _isDuplicateEntry(
                      //         'Checking for duplicate entry6666666',
                      //         // serialnoControllers,
                      //         serialnoControllers[index].text,
                      //         barcodeControllers[index].text) &&
                      //     !isDuplicateAlertShown) {
                      //   _showDuplicateAlert(
                      //       context,
                      //       "Duplicate Entry",
                      //       serialnoControllers[index],
                      //       serialnoFocusNodes[index]);
                      //   isDuplicateAlertShown = true;
                      // }

                      else {
                        // Auto Add
                        _handleAddSerial(index);
                      }
                    } else {
                      // Manual mode existing logic
                      if (serialnoControllers[index].text.isEmpty) {
                        _showWarning(context, serialnoControllers[index],
                            serialnoFocusNodes[index]);
                      }

                      // else if (await _isDuplicateEntry(
                      //         'Checking for duplicate entry:444444',
                      //         // serialnoControllers,
                      //         serialnoControllers[index].text,
                      //         barcodeControllers[index].text) &&
                      //     !isDuplicateAlertShown) {
                      //   _showDuplicateAlert(
                      //       context,
                      //       "Duplicate Entry",
                      //       serialnoControllers[index],
                      //       serialnoFocusNodes[index]);
                      //   isDuplicateAlertShown = true;
                      // }

                      else if (index < createtableData.length - 1) {
                        FocusScope.of(context).requestFocus(buttonFocus);
                      } else {
                        FocusScope.of(context)
                            .requestFocus(barcodeFocusNodes[0]);
                      }
                    }
                  },

                  style: TextStyle(fontSize: 13),
                ),
              ),
            SizedBox(height: 10), // Add spacing between fields

            // Add button
            if (_scanMode == 1 ||
                validProductCode == '00' ||
                validProductCode == null ||
                validSerialno == 'null')
              Container(
                decoration: BoxDecoration(color: buttonColor),
                height: 30,
                child: ElevatedButton(
                  onPressed:
                      _isButtonDisabled ? null : () => _handleAddSerial(index),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(45.0, 20.0),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 0, bottom: 0, left: 8, right: 8),
                    child: const Text(
                      'Add',
                      style: commonWhiteStyle,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

// Add this to your state class
  bool _isProcessing = false;

  Future<void> _handleAddSerial(int index) async {
    if (_isProcessing || !mounted) return;

    final context = this.context;
    final serialNo = serialnoControllers[index].text.trim();
    final currentBarcode = barcodeControllers[index].text.trim();
    final maxQuantity =
        int.tryParse((widget.nofoqty ?? '').split('.').first) ?? 0;

    setState(() {
      _isProcessing = true;
      _isButtonDisabled = true;
    });

    bool dialogShown = false;

    try {
      if (tableData.length >= maxQuantity) {
        _handleMaxQuantityReached(index);
        return;
      }

      if (currentBarcode.isEmpty || serialNo.isEmpty) return;

      if (currentBarcode == serialNo) {
        _showWarningDialog(
          context,
          "Warning",
          "Product code and serial number cannot be the same.",
          clearSerialNo: true,
        );
        _refocusAfterWarning(index);
        return;
      }

      final lowerSerial = serialNo.toLowerCase();
      final isDuplicate = tableData.any((entry) =>
          (entry['Serial No']?.toString().trim().toLowerCase() ?? '') ==
          lowerSerial);

      if (isDuplicate) {
        _showWarningDialog(
          context,
          "Duplicate Entry",
          "This serial number is already added.",
          clearSerialNo: true,
        );
        _refocusSerialField(index);
        return;
      }

      final isInvalidProductCode = (validProductCode?.isNotEmpty ?? false) &&
          currentBarcode != validProductCode &&
          !byepassCheckbox;

      if (isInvalidProductCode) {
        showwarningbarcode(
          context,
          barcodeControllers[index],
          barcodeFocusNodes[index],
        );
        return;
      }

      // Show dialog only if necessary
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _buildProcessingDialog(),
      );
      dialogShown = true;

      if (validSerialno == 'null') {
        await _handleNullSerialCase(
            index, maxQuantity, currentBarcode, serialNo);
      } else {
        await _addToTableOrBypass(index);
        unawaited(_saveTableData(
          widget.pickno,
          widget.reqno,
          widget.itemcode,
          widget.itemdetails,
          widget.invoiceno,
        ));
        setState(() {
          isProcessing = false; // Re-enable the button
        });
      }

      if (tableData.length < maxQuantity) {
        _clearFields(index);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (_scanMode == 0) {
            FocusScope.of(context).requestFocus(barcodeFocusNodes[index]);
          } else {
            FocusScope.of(context).requestFocus(ProductcameraFocus);
            (validProductCode == '00')
                ? _openScannerSerial(index)
                : _openScannerProdCode(
                    barcodeControllers[index],
                    barcodeFocusNodes[index],
                    index,
                  );
          }
        });
      } else {
        _clearAndRefocus(index);
      }
    } catch (e) {
      debugPrint("Error in _handleAddSerial: $e");
      if (mounted) {
        _showWarningDialog(
          context,
          "Error",
          "An error occurred while processing.",
        );
      }
    } finally {
      if (mounted) {
        if (validSerialno != 'null') {
          if (dialogShown && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
        setState(() {
          _isProcessing = false;
          _isButtonDisabled = false;
        });
      }
    }
  }

// Helper Methods
  Widget _buildProcessingDialog() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.green.shade700),
              ),
            ),
            SizedBox(height: 10),
            Text('Processing...', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _handleMaxQuantityReached(int index) {
    // Navigator.of(context).pop();
    _showWarningDialog(
      context,
      "Scan limit reached",
      "You can't scan more items.",
    );
    _clearAndRefocus(index);
  }

  bool _isDuplicateInTable(String serialNo) {
    return tableData.any((entry) =>
        entry['Serial No']?.toString().trim().toLowerCase() ==
        serialNo.toLowerCase());
  }

  bool _isInvalidProductCode(String currentBarcode) {
    return (validProductCode?.isNotEmpty ?? false) &&
        currentBarcode != validProductCode &&
        !byepassCheckbox;
  }

  Future<void> _handleNullSerialCase(
      int index, int maxQuantity, String barcode, String serialNo) async {
    final int remainingQty = maxQuantity - tableData.length;
    for (int i = 0; i < remainingQty; i++) {
      tableData.add({
        "Product Code": barcode,
        "Serial No": serialNo,
      });
    }
    unawaited(postLogData("Load Man Pop-Up added",
        "Added ProductCode and SerialNo as $remainingQty quantity under the RequestNo ${widget.reqno} and Pickid ${widget.pickno}"));
    _clearAllFields();
    await _saveTableData(
      widget.pickno,
      widget.reqno,
      widget.itemcode,
      widget.itemdetails,
      widget.invoiceno,
    );
    Navigator.of(context).pop();
    postLogData("Load Man Pop-Up", "Multiple entries added");
    _refocusAfterNullSerial(index);
  }

  Future<void> _addToTableOrBypass(int index) async {
    if ((validProductCode ?? '').isEmpty) {
      await _addToTablebypass(index);
    } else {
      await _addToTable(index);
    }
  }

  Future<void> _prepareNextInput(int index, int maxQuantity) async {
    if (tableData.length < maxQuantity) {
      _clearFields(index);
      await Future.delayed(Duration(milliseconds: 10));
      if (mounted) {
        if (_scanMode == 0) {
          FocusScope.of(context).requestFocus(barcodeFocusNodes[index]);
        } else {
          FocusScope.of(context).requestFocus(ProductcameraFocus);
          (validProductCode == '00')
              ? _openScannerSerial(index)
              : _openScannerProdCode(
                  barcodeControllers[index],
                  barcodeFocusNodes[index],
                  index,
                );
        }
      }
    } else {
      _clearAndRefocus(index);
    }
  }

  void _clearAllFields() {
    serialnoControllers.forEach((c) => c.clear());
    barcodeControllers.forEach((c) => c.clear());
  }

  void _clearFields(int index) {
    barcodeControllers[index].clear();
    serialnoControllers[index].clear();
  }

  void _clearAndRefocus(int index) {
    _clearFields(index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        FocusScope.of(context).requestFocus(barcodeFocusNodes[index]);
    });
  }

  void _refocusAfterWarning(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scanMode != 0 && mounted) {
        _focusScanner(index);
      } else if (mounted) {
        FocusScope.of(context).requestFocus(serialnoFocusNodes[index]);
      }
    });
  }

  void _refocusSerialField(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        FocusScope.of(context).requestFocus(serialnoFocusNodes[index]);
    });
  }

  void _refocusAfterNullSerial(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scanMode != 0 && mounted) {
        _openScannerProdCode(
          barcodeControllers[index],
          barcodeFocusNodes[index],
          index,
        );
      }
    });
  }

  void _focusScanner(int index) {
    final isMobile = Platform.isAndroid || Platform.isIOS;
    if (isMobile) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (context.mounted) _openScannerSerial(index);
      });
    } else {
      FocusScope.of(context).requestFocus(serialnoFocusNodes[index]);
    }
  }

  // _handleAddSerial(int index) async {
  //   String quantity = widget.nofoqty ?? '';
  //   quantity = quantity.contains('.') ? quantity.split('.')[0] : quantity;
  //   int maxQuantity = int.tryParse(quantity) ?? 0;

  //   setState(() {
  //     _isButtonDisabled = true;
  //     _isProcessing = true;
  //   });

  //   // Show processing dialog
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => Center(
  //       child: Container(
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(16),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black26,
  //               blurRadius: 10,
  //               spreadRadius: 2,
  //             ),
  //           ],
  //         ),
  //         padding: EdgeInsets.all(20),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             SizedBox(
  //               width: 20,
  //               height: 20,
  //               child: CircularProgressIndicator(
  //                 strokeWidth: 2,
  //                 valueColor:
  //                     AlwaysStoppedAnimation<Color>(Colors.green.shade700),
  //               ),
  //             ),
  //             SizedBox(height: 5),
  //             Text(
  //               'Processing...',
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.w500,
  //                 color: Colors.grey.shade800,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );

  //   try {
  //     String serialNo = serialnoControllers[index].text.trim();
  //     String currentBarcode = barcodeControllers[index].text.trim();

  //     // Check for max quantity
  //     if (tableData.length >= maxQuantity) {
  //       Navigator.of(context).pop(); // Close loading
  //       _showWarningDialog(
  //           context, "Scan limit reached", "You can't scan more items.");
  //       return;
  //     }

  //     // If serial already exists in the table
  //     if (currentBarcode == serialNo) {
  //       Navigator.of(context).pop(); // Close loading
  //       await _showWarningDialog(
  //         context,
  //         "Warning",
  //         "The product code cannot be the same as the serial number.",
  //       );

  //       final isMobile = Platform.isAndroid || Platform.isIOS;
  //       if (context.mounted) {
  //         if (isMobile) {
  //           await Future.delayed(Duration(seconds: 1));
  //           if (context.mounted) {
  //             _openScannerSerial(index);
  //           }
  //         } else {
  //           FocusScope.of(context).requestFocus(serialnoFocusNodes[index]);
  //         }
  //       }
  //       return;
  //     }

  //     // ------------------ Handle when validSerialno == 'null' ------------------
  //     if (validSerialno == 'null') {
  //       int remainingQty = maxQuantity - tableData.length;
  //       // Barcode mismatch check
  //       if ((validProductCode ?? '').isNotEmpty &&
  //           currentBarcode != validProductCode &&
  //           !byepassCheckbox) {
  //         print("sales serialno is null ");
  //         Navigator.of(context).pop(); // Close loading
  //         showwarningbarcode(
  //           context,
  //           barcodeControllers[index],
  //           barcodeFocusNodes[index],
  //         );
  //         return;
  //       } else {
  //         print("sales serialno is null wrongggg ");

  //         for (int i = 0; i < remainingQty; i++) {
  //           tableData.add({
  //             "Product Code": currentBarcode,
  //             "Serial No": serialNo,
  //           });
  //         }

  //         // Clear all inputs
  //         for (var controller in serialnoControllers) {
  //           controller.clear();
  //         }
  //         for (var controller in barcodeControllers) {
  //           controller.clear();
  //         }

  //         await _saveTableData(
  //             widget.pickno, widget.reqno, widget.itemcode, widget.invoiceno);

  //         postLogData("Pick Man Pop-Up", "Multiple entries added");

  //         Navigator.of(context).pop(); // Close loading dialog

  //         setState(() {
  //           _isButtonDisabled = false;
  //           _isProcessing = false;
  //         });
  //         _openScannerProdCode(
  //           barcodeControllers[index],
  //           barcodeFocusNodes[index],
  //           index,
  //         );

  //         return;
  //       }
  //     }
  //     // ------------------------------------------------------------------------

  //     // If serial already exists in the table
  //     if (tableData.any((entry) => entry['Serial No'] == serialNo)) {
  //       Navigator.of(context).pop(); // Close loading
  //       await _showWarningDialog(
  //         context,
  //         "Entry already exists",
  //         "This serial number is already ordered.",
  //       );

  //       final isMobile = Platform.isAndroid || Platform.isIOS;
  //       if (context.mounted) {
  //         if (isMobile) {
  //           await Future.delayed(Duration(seconds: 1));
  //           if (context.mounted) {
  //             _openScannerSerial(index);
  //           }
  //         } else {
  //           FocusScope.of(context).requestFocus(serialnoFocusNodes[index]);
  //         }
  //       }
  //       return;
  //     }

  //     // Duplicate entry check across controllers
  //     if (!byepassCheckbox) {
  //       if (await _isDuplicateEntry(
  //         serialnoControllers,
  //         serialNo,
  //         productCode: currentBarcode,
  //       )) {
  //         Navigator.of(context).pop(); // Close loading
  //         _showDuplicateAlert(
  //           context,
  //           "Duplicate Entry",
  //           serialnoControllers[index],
  //           serialnoFocusNodes[index],
  //         );
  //         return;
  //       }
  //     }

  //     // Barcode mismatch check
  //     if ((validProductCode ?? '').isNotEmpty &&
  //         currentBarcode != validProductCode &&
  //         !byepassCheckbox) {
  //       Navigator.of(context).pop(); // Close loading
  //       showwarningbarcode(
  //         context,
  //         barcodeControllers[index],
  //         barcodeFocusNodes[index],
  //       );
  //       return;
  //     }

  //     // Add item based on barcode validation
  //     if ((validProductCode ?? '').isEmpty) {
  //       await _addToTablebypass(index);
  //     } else {
  //       await _addToTable(index);
  //     }

  //     await _saveTableData(
  //         widget.pickno, widget.reqno, widget.itemcode, widget.invoiceno);

  //     Navigator.of(context).pop(); // Close loading dialog

  //     // Prepare for next scan if still under limit
  //     if (tableData.length < maxQuantity) {
  //       barcodeControllers[index].clear();
  //       FocusScope.of(context).requestFocus(ProductcameraFocus);

  //       if (validProductCode == '00') {
  //         _openScannerSerial(index);
  //       } else {
  //         _openScannerProdCode(
  //           barcodeControllers[index],
  //           barcodeFocusNodes[index],
  //           index,
  //         );
  //       }
  //     }

  //     postLogData("Pick Man Pop-Up", "Details Added");
  //   } catch (e) {
  //     Navigator.of(context).pop(); // Close loading
  //     print("Error in _handleAddSerial: $e");
  //   } finally {
  //     setState(() {
  //       _isButtonDisabled = false;
  //       _isProcessing = false;
  //     });
  //   }
  // }

  Future<void> _saveTableData(String pickID, String reqID, String itemCode,
      String itemdetails, String invoiceNo) async {
    print(
        "Saving table data for $pickID, $reqID, $itemCode, $itemdetails, $invoiceNo");
    try {
      final prefs = await SharedPreferences.getInstance();

      // Encode each item in tableData to JSON string
      final List<String> tableDataStringList = tableData.map((data) {
        return json.encode(data);
      }).toList();

      // Generate a unique key using the provided parameters
      final String key =
          'tableData_${pickID}_${reqID}_${itemCode}_${itemdetails}_$invoiceNo';

      // Save the JSON string list to SharedPreferences
      await prefs.setStringList(key, tableDataStringList);
    } catch (e) {
      debugPrint('Error saving table data: $e');
    }
  }

  Future<void> _loadTableData(String pickID, String reqID, String itemCode,
      String Itemdetails, String invoiceNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key =
        'tableData_${pickID}_${reqID}_${itemCode}_${Itemdetails}_$invoiceNo';

    List<String>? tableDataStringList = prefs.getStringList(key);

    if (tableDataStringList != null && tableDataStringList.isNotEmpty) {
      try {
        setState(() {
          tableData = tableDataStringList.map((data) {
            return Map<String, String>.from(json.decode(data));
          }).toList();
        });
      } catch (e) {
        print('Error loading table data: $e');
        setState(() {
          tableData = [];
        });
      }
    } else {
      setState(() {
        tableData = [];
      });
    }
  }

  Future<void> _deleteTableData(String pickID, String reqID, String itemCode,
      String itemdetails, String invoiceNo) async {
    print("Deleting table data for $pickID, $reqID, $itemCode, $invoiceNo");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key =
        'tableData_${pickID}_${reqID}_${itemCode}_${itemdetails}_$invoiceNo';

    await prefs.remove(key);

    setState(() {
      tableData.removeWhere((data) =>
          data['pickID'] == pickID &&
          data['reqID'] == reqID &&
          data['itemCode'] == itemCode &&
          data['invoiceNo'] == invoiceNo);
    });
  }

// Warning dialog function
  Future<void> _showWarningDialog(
    BuildContext context,
    String title,
    String message, {
    bool clearSerialNo = false,
    bool clearProductCode = false,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 13)),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (clearProductCode) {
                    for (var controller in barcodeControllers) {
                      controller.clear();
                    }
                  }
                  if (clearSerialNo) {
                    for (var controller in serialnoControllers) {
                      controller.clear();
                    }
                  }
                },
                child: Text("OK"),
              ),
            ],
          );
        });
      },
    );
  }

  showwarningbarcode(BuildContext context, TextEditingController controller,
      FocusNode focusnode) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invalid Barcode'),
        content: Container(
          height: MediaQuery.of(context).size.width * 0.3,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    'The entered productode is not valid for this item code. Kindly check and try again.'),
                Text(
                  'Note : Product Code is $validProductCode',
                  style:
                      TextStyle(color: const Color.fromARGB(255, 0, 118, 37)),
                ),
                Text(
                  'Note : For any changes contact to admin',
                  style:
                      TextStyle(color: const Color.fromARGB(255, 143, 12, 2)),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clear();
              Navigator.of(context).pop();
              FocusScope.of(context).requestFocus(focusnode);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell({required String data}) {
    return Flexible(
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color.fromARGB(255, 226, 225, 225)),
        ),
        child: Center(
          child: Text(data,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Timer? _debounce;

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required Function(String) onFieldSubmitted,
    required TextInputAction textInputAction,
    required IconData icon1,
    required Color iconColor1,
    required IconData icon2,
    required Color iconColor2,
    required VoidCallback onIconPressed,
    required int index, // Add index to identify which controller to validate
  }) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color.fromARGB(255, 173, 173, 173)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.width * 0.012),
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(255, 58, 58, 58),
                width: 1.0,
              ),
            ),
            suffixIcon: controller.text.isEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          icon1,
                          color: iconColor1,
                          size: 15,
                        ),
                        onPressed: onIconPressed,
                      ),
                      IconButton(
                        icon: Icon(icon2, color: iconColor2, size: 15),
                        onPressed: onIconPressed,
                      ),
                    ],
                  )
                : null,
          ),
          // onChanged: (text) {
          //   // Cancel any previous debounce timer
          //   if (_debounce?.isActive ?? false) _debounce?.cancel();

          //   // Start a new debounce timer
          //   _debounce = Timer(const Duration(seconds: 2), () async {
          //     // Now that typing has finished (after 300ms), check for duplicates
          //     if (controller == serialnoControllers[index]) {
          //       if (await _isDuplicateEntry(serialnoControllers, text)) {
          //         _showDuplicateAlert(context, controller, focusNode);
          //       }
          //     }
          //     if (controller == barcodeControllers[index]) {
          //       if (validProductCode != null) {
          //         if (barcodeControllers[index].text.isNotEmpty &&
          //             barcodeControllers[index].text == validProductCode) {
          //           if (index < createtableData.length) {
          //             FocusScope.of(context)
          //                 .requestFocus(serialnoFocusNodes[index]);
          //           }
          //         } else {
          //           showwarningbarcode(context, barcodeControllers[index],
          //               barcodeFocusNodes[index]);
          //         }
          //       }
          //     }
          //   });
          // },
          onChanged: (text) {
            // Cancel any previous debounce timer
            if (_debounce?.isActive ?? false) _debounce?.cancel();

            // Start a new debounce timer
            _debounce = Timer(const Duration(seconds: 2), () async {
              // Now that typing has finished (after 2 seconds), check for barcode mismatch
              // if (controller == serialnoControllers[index]) {
              //   // Check for duplicate serial number
              //   if (await _isDuplicateEntry(
              //       'Checking for duplicate entry:333333',
              //       // serialnoControllers,
              //       serialnoControllers[index].text,
              //       barcodeControllers[index].text)) {
              //     _showDuplicateAlert(
              //         context, "Duplicate Entry", controller, focusNode);
              //   }
              // } else

              if (controller == barcodeControllers[index]) {
                // Check if the typed barcode is not equal to validProductCode
                if (text != validProductCode) {
                  print("savebutonnnnn8");
                  if (byepassCheckbox = true)
                    showwarningbarcode(
                      context,
                      barcodeControllers[index],
                      barcodeFocusNodes[index],
                    );
                }
              }
            });
          },
          style: const TextStyle(
              fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool _flashOn = false;

  // Current active index for the scanned barcode field
  int _currentSerialFieldIndex = 0;

  // Callback for when QR code or barcode is scanned
  // void _onQRViewCreatedSerial(QRViewController controller) {
  //   _qrController = controller;

  //   // Boolean flag to prevent multiple dialogs
  //   bool isDialogShowing = false;

  //   // Start listening to the scanned data stream
  //   _qrController!.scannedDataStream.listen((scanData) async {
  //     // Ensure scanData and scanData.code are not null
  //     if (scanData != null &&
  //         scanData.code != null &&
  //         scanData.code!.isNotEmpty) {
  //       String scannedValue = scanData.code!;

  //       // Pause scanning to prevent repeated events
  //       _qrController?.pauseCamera();

  //       // Check if the scanned value is a duplicate
  //       bool isDuplicate = false;

  //       for (int i = 0; i < serialnoControllers.length; i++) {
  //         if (serialnoControllers[i].text == scannedValue) {
  //           isDuplicate = true;

  //           // Show duplicate dialog if no other dialog is showing
  //           if (!isDialogShowing) {
  //             isDialogShowing = true;

  //             // Show duplicate dialog
  //             _showDuplicateAlert(
  //               context,
  //               serialnoControllers[_currentSerialFieldIndex],
  //               serialnoFocusNodes[_currentSerialFieldIndex],
  //             );

  //             // Automatically close the dialog after 4 seconds
  //             Future.delayed(Duration(seconds: 2), () {
  //               if (Navigator.canPop(context)) {
  //                 Navigator.of(context).pop();
  //               }

  //               // Clear the current text box after dialog dismissal
  //               setState(() {
  //                 serialnoControllers[_currentSerialFieldIndex].text = '';
  //               });

  //               // Resume the camera for scanning
  //               _qrController?.resumeCamera();
  //               isDialogShowing = false; // Reset dialog flag
  //             });
  //           }
  //           return; // Exit early to prevent further processing
  //         }
  //       }

  //       // If it's not a duplicate, update the current text field
  //       if (!isDuplicate) {
  //         setState(() {
  //           serialnoControllers[_currentSerialFieldIndex].text = scannedValue;

  //           // Move to the next text field after filling the current one
  //           if (_currentSerialFieldIndex < serialnoControllers.length - 1) {
  //             _currentSerialFieldIndex++;
  //             // Move focus to the next text field
  //             FocusScope.of(context)
  //                 .requestFocus(barcodeFocusNodes[_currentSerialFieldIndex]);
  //           } else {
  //             // Remove focus if it's the last field
  //             FocusScope.of(context).unfocus();
  //           }

  //           // Optionally, close the QR scanner after the scan is successful
  //           Navigator.of(context).pop();
  //         });
  //       }

  //       // Resume scanning if no dialog was shown
  //       if (!isDialogShowing) {
  //         _qrController?.resumeCamera();
  //       }
  //     }
  //   });
  // }

  // int _currentFieldIndex = 0;

  // // Callback for when QR code or barcode is scanned
  // void _onQRViewCreatedProdCode(QRViewController controller) {
  //   _qrController1 = controller;

  //   // Start listening to the scanned data stream
  //   _qrController1!.scannedDataStream.listen((scanData) {
  //     // Ensure scanData and scanData.code are not null
  //     if (scanData != null &&
  //         scanData.code != null &&
  //         scanData.code!.isNotEmpty) {
  //       setState(() {
  //         // Update the text field with the scanned code
  //         barcodeControllers[_currentFieldIndex].text = scanData.code!;

  //         // Move to the next text field after filling the current one
  //         if (_currentFieldIndex < barcodeControllers.length - 1) {
  //           _currentFieldIndex++;
  //           // Move focus to the next text field
  //           FocusScope.of(context)
  //               .requestFocus(serialnoFocusNodes[_currentSerialFieldIndex]);
  //         } else {
  //           // Explicitly focus the last text field
  //           FocusScope.of(context)
  //               .requestFocus(serialnoFocusNodes[_currentSerialFieldIndex]);
  //         }

  //         // Pause the camera to prevent further scanning
  //         _qrController1?.pauseCamera();
  //         // Optionally, close the QR scanner after the scan is successful
  //         Navigator.of(context).pop();
  //       });
  //     }
  //   });
  // }

  // // Method to open the QR scanner
  // void _openScannerSerial(int fieldIndex) {
  //   setState(() {
  //     _currentSerialFieldIndex = fieldIndex;
  //   });

  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       child: AspectRatio(
  //         aspectRatio: 1,
  //         child: QRView(
  //           key: qrKey,
  //           onQRViewCreated: _onQRViewCreatedSerial,
  //           overlay: QrScannerOverlayShape(
  //             borderColor: Colors.green,
  //             borderRadius: 10,
  //             borderLength: 30,
  //             borderWidth: 10,
  //             cutOutSize: MediaQuery.of(context).size.width * 0.8,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  int _currentFieldIndex = 0;
  // void _openScannerProdCode(TextEditingController controller, int fieldIndex) {
  //   // Set the current field index for scanning
  //   setState(() {
  //     _currentFieldIndex = fieldIndex;
  //   });

  //   // Flag to prevent multiple scans
  //   bool isScanned = false;

  //   // Create a MobileScannerController instance
  //   final MobileScannerController scannerController = MobileScannerController();

  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       child: Stack(
  //         children: [
  //           AspectRatio(
  //             aspectRatio: 1,
  //             child: MobileScanner(
  //               controller: scannerController,
  //               onDetect: (BarcodeCapture capture) {
  //                 if (isScanned) return; // Prevent multiple detections
  //                 isScanned = true;

  //                 final String? scannedCode = capture.barcodes.first.rawValue;

  //                 if (scannedCode != null && scannedCode.isNotEmpty) {
  //                   // Check if the scanned product code matches the valid product code
  //                   if (scannedCode != validProductCode) {
  //                     // If the product codes don't match, show the mismatch alert
  //                     showwarningbarcode(
  //                       context,
  //                       controller,
  //                     );
  //                     // Navigator.of(context).pop();
  //                   } else {
  //                     // Update the text field with the scanned value
  //                     barcodeControllers[fieldIndex].text = scannedCode;

  //                     // Close the scanner dialog
  //                     Navigator.of(context).pop();
  //                   }
  //                 }
  //               },
  //               fit: BoxFit.cover,
  //             ),
  //           ),
  //           Positioned.fill(
  //             child: CustomPaint(
  //               painter: ScannerOverlayPainter(
  //                 borderColor: Colors.green,
  //                 borderRadius: 10,
  //                 borderWidth: 5,
  //                 borderLength: 30,
  //                 cutOutSize: MediaQuery.of(context).size.width * 0.8,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   ).then((_) {
  //     // Dispose of the scanner controller after the dialog is closed
  //     scannerController.dispose();

  //     // Reset the scanned flag for future use
  //     isScanned = false;

  //     // Move focus to the corresponding Serial No text field
  //     FocusScope.of(context)
  //         .requestFocus(serialnoFocusNodes[_currentFieldIndex]);

  //     // Move to the next text field if there are more fields
  //     setState(() {
  //       if (_currentFieldIndex < barcodeControllers.length - 1) {
  //         _currentFieldIndex++;
  //       }
  //     });
  //   });
  // }

  void _openScannerProdCode(
      TextEditingController controller, FocusNode focusNode, int fieldIndex) {
    // Set the current field index for scanning
    setState(() {
      _currentFieldIndex = fieldIndex;
    });

    // Flag to prevent multiple scans
    bool isScanned = false;

    // Create a MobileScannerController instance
    final MobileScannerController scannerController = MobileScannerController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with label and close button
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scan Product Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              // Instruction text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Align the barcode within the frame to scan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              // Scanner preview with overlay
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: MobileScanner(
                        controller: scannerController,
                        onDetect: (BarcodeCapture capture) {
                          if (isScanned) return; // Prevent multiple detections
                          isScanned = true;

                          final String? scannedCode =
                              capture.barcodes.first.rawValue;

                          if (scannedCode != null && scannedCode.isNotEmpty) {
                            // Check if the scanned product code matches the valid product code
                            if (scannedCode != validProductCode) {
                              Navigator.of(context).pop();
                              showwarningbarcode(
                                context,
                                barcodeControllers[fieldIndex],
                                barcodeFocusNodes[fieldIndex],
                              );
                            } else {
                              // Update the text field with the scanned value
                              barcodeControllers[fieldIndex].text = scannedCode;

                              // Show a small SnackBar message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Product Code Scanned!',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );

                              // Close the scanner dialog
                              Navigator.of(context).pop();

                              // Delay to allow the SnackBar to show before opening the serial scanner
                              Future.delayed(Duration(seconds: 1), () {
                                // Automatically open the serial number scanner

                                if (validSerialno == 'null') {
                                  _handleAddSerial(fieldIndex);
                                  // _openScannerProdCode(
                                  //   barcodeControllers[fieldIndex],
                                  //   barcodeFocusNodes[fieldIndex],
                                  //   fieldIndex,
                                  // );
                                } else {
                                  _openScannerSerial(fieldIndex);
                                }
                              });
                            }
                          }
                        },
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: ScannerOverlayPainter(
                          borderColor: Colors.green,
                          borderRadius: 10,
                          borderWidth: 5,
                          borderLength: 30,
                          cutOutSize: MediaQuery.of(context).size.width * 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Manual entry option
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  focusNode.requestFocus();
                },
                child: Text(
                  'Enter Code Manually',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ).then((_) {
      // Dispose of the scanner controller after the dialog is closed
      scannerController.dispose();

      // Reset the scanned flag for future use
      isScanned = false;

      // Move focus to the corresponding Serial No text field
      FocusScope.of(context).requestFocus(SerialcameraFocus);

      // Move to the next text field if there are more fields
      setState(() {
        if (_currentFieldIndex < barcodeControllers.length - 1) {
          _currentFieldIndex++;
        }
      });
    });
  }

  bool _isScanning = true; // Boolean flag to control scanner state

  void _openScannerSerial(int fieldIndex) {
    setState(() {
      _currentFieldIndex = fieldIndex;
      _isScanning = true;
    });

    bool isScanned = false;
    bool isDialogShowing = false;

    final MobileScannerController _scannerController =
        MobileScannerController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with title and close button
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Scan Serial Number',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            _scannerController.stop();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  // Instruction text
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Align the serial number barcode within the frame',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Scanner container
                  if (_isScanning)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: MobileScanner(
                          controller: _scannerController,
                          onDetect: (BarcodeCapture capture) async {
                            if (isScanned) return;
                            isScanned = true;

                            final String? scannedCode =
                                capture.barcodes.first.rawValue;

                            if (scannedCode != null && scannedCode.isNotEmpty) {
                              setState(() {
                                serialnoControllers[fieldIndex].text =
                                    scannedCode;
                              });

                              String scannedValue =
                                  serialnoControllers[fieldIndex].text;
                              bool isDuplicate = false;

                              // Check for duplicates
                              for (int i = 0;
                                  i < serialnoControllers.length;
                                  i++) {
                                if (serialnoControllers[i].text ==
                                        scannedValue &&
                                    i != fieldIndex) {
                                  isDuplicate = true;

                                  if (!isDialogShowing) {
                                    isDialogShowing = true;

                                    _showDuplicateAlert(
                                      context,
                                      "Duplicate Entry",
                                      serialnoControllers[_currentFieldIndex],
                                      serialnoFocusNodes[_currentFieldIndex],
                                    );

                                    Future.delayed(Duration(seconds: 2), () {
                                      if (Navigator.canPop(dialogContext)) {
                                        Navigator.of(dialogContext).pop();
                                      }

                                      setState(() {
                                        serialnoControllers[_currentFieldIndex]
                                            .text = '';
                                      });

                                      _scannerController.stop();
                                      isDialogShowing = false;
                                    });
                                  }
                                  return;
                                }
                              }

                              if (!isDuplicate) {
                                // Show success feedback
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Serial Number Scanned!'),
                                    duration: Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );

                                setState(() {
                                  if (_currentFieldIndex <
                                      serialnoControllers.length - 1) {
                                    _currentFieldIndex++;
                                    FocusScope.of(context).requestFocus(
                                        barcodeFocusNodes[_currentFieldIndex]);
                                  } else {
                                    FocusScope.of(context).unfocus();
                                  }
                                });

                                Navigator.of(dialogContext).pop();
                                _scannerController.stop();
                                _isScanning = false;

                                // ✅ Automatically add after successful scan
                                await _handleAddSerial(fieldIndex);
                              }
                            }
                          },
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  // Manual entry option
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _scannerController.stop();
                      serialnoFocusNodes[fieldIndex].requestFocus();
                    },
                    child: Text(
                      'Enter Serial Number Manually',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
              // Scanner overlay
              if (_isScanning)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: CustomPaint(
                        painter: ScannerOverlayPainter(
                          borderColor: Colors.green,
                          borderRadius: 10,
                          borderWidth: 5,
                          borderLength: 30,
                          cutOutSize: MediaQuery.of(context).size.width * 0.6,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).then((_) {
      _scannerController.dispose();
      isScanned = false;

      if (_currentFieldIndex < serialnoControllers.length - 1) {
        FocusScope.of(context)
            .requestFocus(barcodeFocusNodes[_currentFieldIndex]);
      }
    }).whenComplete(() {
      _scannerController.stop();
    });
  }

  List<Map<String, dynamic>> alreadyscantableData = [];
  bool isLoading = true;
  Future<void> fetchPickmanData() async {
    String reqno = widget.reqno.toString();
    String pickno = widget.pickno.isNotEmpty ? widget.pickno : '';
    String invoiceno = widget.invoiceno.isNotEmpty ? widget.invoiceno : '';
    String itemCode = widget.itemcode.isNotEmpty ? widget.itemcode : '';

    final IpAddress = await getActiveIpAddress();

    final url = Uri.parse(
        '$IpAddress/Scanned_Pickman/?PICK_ID=$pickno&REQ_ID=$reqno&INVOICE_NUMBER=$invoiceno&INVENTORY_ITEM_ID=$itemCode');
    // print("Fetching data from: $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decode the JSON array
        final List<dynamic> jsonData = json.decode(response.body);

        // Convert the JSON array to a list of maps
        final List<Map<String, dynamic>> fetchedData =
            List<Map<String, dynamic>>.from(jsonData);

        // Filter out rows where FLAG == 'R'
        final List<Map<String, dynamic>> filteredData = fetchedData
            .where((row) => row['FLAG'] != 'R' && row['FLAG'] != 'SR')
            .toList();

        setState(() {
          alreadyscantableData = filteredData; // Only rows where FLAG != 'R'
          isLoading = false;
        });

        // print("Filtered data: $alreadyscantableData");
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderRadius;
  final double borderWidth;
  final double borderLength;
  final double cutOutSize;

  ScannerOverlayPainter({
    required this.borderColor,
    required this.borderRadius,
    required this.borderWidth,
    required this.borderLength,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    // Draw rounded rectangle
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    canvas.drawRRect(rrect, paint);

    // Draw border length (optional)
    final halfBorderLength = borderLength / 2;
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + halfBorderLength, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right - halfBorderLength, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + halfBorderLength, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right - halfBorderLength, rect.bottom),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
