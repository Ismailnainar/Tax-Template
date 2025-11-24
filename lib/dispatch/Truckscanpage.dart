import 'dart:convert';
import 'dart:ui';
import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/components/constaints.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    fetchBypassdatastotruck();
    fetchNoProductcode();

    fetchNoSerialNo();
    postLogData("Truck Loading Scan", "Opened");
    fetchPreviousLoadCount(widget.reqno, widget.pickno);

    scannedqtyController.text = filteredData.length.toString();
    print("Scanned Qty ${scannedqtyController.text}");
  }

  Future<void> fetchBypassdatastotruck() async {
    final IpAddress = await getActiveIpAddress();

    final String url =
        '$IpAddress/compare-scan/${widget.reqno}/${widget.cusno}/${widget.cussite}/';
    print("urllllllllll $url");
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check the status
        if (data['status'] == 'success') {
          setState(() {
            BypassALertButton = true;
          });
        }

        print("Bypass bool value : $BypassALertButton");

        setState(() {});
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchNoProductcode() async {
    final IpAddress = await getActiveIpAddress();

    final String url =
        '$IpAddress/compare-scan-noproductcode/${widget.reqno}/${widget.cusno}/${widget.cussite}/';
    print("urllllllllll $url");
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check the status
        if (data['status'] == 'success') {
          setState(() {
            NoProductCodeButton = true;
          });
        }

        print("NoProductCodeButton bool value : $NoProductCodeButton");

        setState(() {});
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchNoSerialNo() async {
    final IpAddress = await getActiveIpAddress();

    final String url =
        '$IpAddress/compare-scan-noserialno/${widget.reqno}/${widget.cusno}/${widget.cussite}/';
    print("urllllllllll $url");
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check the status
        if (data['status'] == 'success') {
          setState(() {
            NoSerialNoButton = true;
          });
        }

        print("NoSerialNoButton bool value : $NoSerialNoButton");

        setState(() {});
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchBypassdatasaddtabledatas() async {
    final IpAddress = await getActiveIpAddress();

    final String url =
        '$IpAddress/compare-scan/${widget.reqno}/${widget.cusno}/${widget.cussite}/';

    print('urlllll $url save ');
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check the status
        if (data['status'] == 'success') {
          setState(() {
            // BypassALertButton = true;
          });
        }

        print("Bypass bool value : $BypassALertButton");

        // Add tableData
        List<dynamic> fetchedData = data['data'];
        for (var item in fetchedData) {
          Reqnocontroller.text = item['REQ_ID'];
          PickIdcontroller.text = item['PICK_ID'];
          TableProductCodeController.text = item['PRODUCT_CODE'];
          SerialNoproductController.text = item['SERIAL_NO'];
          RequestQtyController.text = item['DISPATCHED_QTY'];
          UdelIdontroller.text = item['UNDEL_ID'];

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

          // Update controllers with the data
          CusNoController.text = item['CUSTOMER_NUMBER'];
          CusNameController.text = item['CUSTOMER_NAME'];
          CusSiteController.text = item['CUSTOMER_SITE_ID'];
          TotalQtyController.text = item['DISPATCHED_QTY'].toString();
          InvoiceDateController.text = item['INVOICE_DATE'];
          InvoiceNoController.text = item['INVOICE_NUMBER'];
          ItemCodeController.text = item['INVENTORY_ITEM_ID'];
          ItemDetailsController.text = item['ITEM_DESCRIPTION'];

          tableData.add({
            'id': item['id'],
            "dispatchId": item['PICK_ID'],
            'salesman': '', // Assuming this comes from a TextEditingController
            'reqno': item['REQ_ID'],
            'salesmanName': item['SALESMAN_NAME'],
            'cusno': item['CUSTOMER_NUMBER'],
            'cusname': item['CUSTOMER_NAME'],
            'cussite': item['CUSTOMER_SITE_ID'],
            'total': item['DISPATCHED_QTY'],
            'date': item['INVOICE_DATE'],
            'invoiceno': item['INVOICE_NUMBER'],
            'itemcode': item['INVENTORY_ITEM_ID'],
            'itemdetails': item['ITEM_DESCRIPTION'],
            'productcode': item['PRODUCT_CODE'],
            'serialno': item['SERIAL_NO'],
            'scan_status': item['SCAN_STATUS'],
          });
          filteredData = List.from(tableData);
          await _sendDataToApi();
          // BypassALertButton = false;
        }
        print("Bypass tableData value : $tableData");
        setState(() {});
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchNoSerialnodatasaddtabledatas() async {
    final IpAddress = await getActiveIpAddress();

    final String url =
        '$IpAddress/compare-scan-noserialno/${widget.reqno}/${widget.cusno}/${widget.cussite}/';

    print('urlllll $url save ');
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check the status
        if (data['status'] == 'success') {
          setState(() {
            // BypassALertButton = true;
          });
        }

        print("Bypass bool value : $BypassALertButton");

        // Add tableData
        List<dynamic> fetchedData = data['data'];
        for (var item in fetchedData) {
          Reqnocontroller.text = item['REQ_ID'];
          PickIdcontroller.text = item['PICK_ID'];
          TableProductCodeController.text = item['PRODUCT_CODE'];
          SerialNoproductController.text = item['SERIAL_NO'];
          RequestQtyController.text = item['DISPATCHED_QTY'];
          UdelIdontroller.text = item['UNDEL_ID'];

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

          // Update controllers with the data
          CusNoController.text = item['CUSTOMER_NUMBER'];
          CusNameController.text = item['CUSTOMER_NAME'];
          CusSiteController.text = item['CUSTOMER_SITE_ID'];
          TotalQtyController.text = item['DISPATCHED_QTY'].toString();
          InvoiceDateController.text = item['INVOICE_DATE'];
          InvoiceNoController.text = item['INVOICE_NUMBER'];
          ItemCodeController.text = item['INVENTORY_ITEM_ID'];
          ItemDetailsController.text = item['ITEM_DESCRIPTION'];

          tableData.add({
            'id': item['id'],
            "dispatchId": item['PICK_ID'],
            'salesman': '', // Assuming this comes from a TextEditingController
            'reqno': item['REQ_ID'],
            'salesmanName': item['SALESMAN_NAME'],
            'cusno': item['CUSTOMER_NUMBER'],
            'cusname': item['CUSTOMER_NAME'],
            'cussite': item['CUSTOMER_SITE_ID'],
            'total': item['DISPATCHED_QTY'],
            'date': item['INVOICE_DATE'],
            'invoiceno': item['INVOICE_NUMBER'],
            'itemcode': item['INVENTORY_ITEM_ID'],
            'itemdetails': item['ITEM_DESCRIPTION'],
            'productcode': item['PRODUCT_CODE'],
            'serialno': item['SERIAL_NO'],
            'scan_status': item['SCAN_STATUS'],
          });
          filteredData = List.from(tableData);
          await _sendDataToApi();
          // BypassALertButton = false;
        }
        print("No Serial no tableData value : $tableData");
        setState(() {});
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
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
      print("Filtered data used for count: $filteredData");
    });
  }
  // String? validProductCode;
  // String message = "";

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
  //             validProductCode = product['PRODUCT_BARCODE'];
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

  @override
  void dispose() {
    ProductCodeController.dispose();
    salesserialnoController.dispose();
    productCodeFocusNode.dispose();
    serialNoFocusNode.dispose();
    addButtonFocusNode.dispose();

    postLogData("Truck Loading Scan", "Closed");
    super.dispose();
  }

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
            filteredData = List.from(tableData);

            _updateCurrentLoadCount();

            scannedqtyController.text = filteredData.length.toString();
          });

          print("Filtered table data: $filteredData");
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
      print('Alllllllllllll fetched data: $allResults');

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

      print('filteredData fetched data: $filteredData');
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

  // Future<void> fetchPreviousLoadCount(String reqno, String pickid) async {
  //   final IpAddress = await getActiveIpAddress();

  //   final String url = '$IpAddress/Truck_scan/?REQ_NO=$reqno&PICK_ID=$pickid';

  //   print("urlllll data $url");
  //   int totalCount = 0;
  //   bool hasNextPage = true;
  //   String? nextPageUrl = url;

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     while (hasNextPage && nextPageUrl != null) {
  //       final response = await http.get(Uri.parse(nextPageUrl));

  //       if (response.statusCode == 200) {
  //         final Map<String, dynamic> responseData = json.decode(response.body);

  //         // Add current page count
  //         if (responseData.containsKey('count')) {
  //           totalCount = responseData['count'];
  //         }

  //         // Check for the next page
  //         nextPageUrl = responseData['next'];
  //         hasNextPage = nextPageUrl != null;
  //       } else {
  //         throw Exception('Failed to fetch data');
  //       }
  //     }

  //     // Update the controller with the total count
  //     setState(() {
  //       print(
  //           "Previous cojnt loadddddddddddd ${PreviousLoadController.text}   ");
  //       PreviousLoadController.text = totalCount.toString();
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     print('Error fetching previous load count: $e');
  //   }
  // }

  int reqno = 0;

  Future<void> _addTableData() async {
    // Fetching the values entered in the text fields
    String productCode = ProductCodeController.text.trim();
    String serialNo = salesserialnoController.text.trim();
    String dispatch_id = Dispatch_idController.text.trim();

    if (productCode.isNotEmpty && serialNo.isNotEmpty) {
      final IpAddress = await getActiveIpAddress();

      // URL for checking productCode and serialNo
      String url =
          '$IpAddress/Pickman_Productcode/${widget.reqno}/$productCode/$serialNo/';
      print("Fetching data from URL: $url");

      try {
        // Make GET request to the URL
        final response = await http.get(Uri.parse(url));
        print("Response: ${response.body}");

        // Check if the response is successful
        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
          List<dynamic> data = jsonDecode(decodedBody);

          // Check if data is returned and not empty
          if (data.isNotEmpty) {
            data.forEach((item) {
              // Check if the data already exists in tableData
              bool alreadyExists = tableData.any((existingItem) =>
                  existingItem['productcode'] == item['PRODUCT_CODE'] &&
                  existingItem['serialno'] == item['SERIAL_NO']);

              if (alreadyExists) {
                print(
                    "Data with product code ${item['PRODUCT_CODE']} and serial number ${item['SERIAL_NO']} already exists. Skipping addition.");
                return; // Skip adding the duplicate data
              }

              // Check if filteredData is not empty and validate customer details
              String customerName = widget.cusname.trim();
              String pickId = widget.pickno.trim();
              String reqId = widget.reqno.trim();
              String customerNumber = widget.cusno.trim();
              String customerSiteId = widget.cussite.trim();
              print(
                  "item['CUSTOMER_NAME'] != customerName ${item['CUSTOMER_NAME']} != $customerName");
              // Validate the fields
              if (item['CUSTOMER_NAME'] != customerName ||
                  // item['PICK_ID'] != pickId ||
                  item['REQ_ID'] != reqId ||
                  item['CUSTOMER_NUMBER'] != customerNumber ||
                  item['CUSTOMER_SITE_ID'] != customerSiteId ||
                  item['PRODUCT_CODE'] != productCode ||
                  item['SERIAL_NO'] != serialNo) {
                // Create a mismatch details message
                String mismatchMessage = "The following details do not match:";

                if (item['CUSTOMER_NAME'] != customerName) {
                  // mismatchMessage +=
                  //     "- CUSTOMER_NAME (Expected: $customerName, Found: ${item['CUSTOMER_NAME']})\n";
                }
                // if (item['PICK_ID'] != pickId) {
                //   // mismatchMessage +=
                //   //     "- PICK_ID (Expected: $pickId, Found: ${item['PICK_ID']})\n";
                // }
                if (item['REQ_ID'] != reqId) {
                  // mismatchMessage +=
                  //     "- REQ_ID (Expected: $reqId, Found: ${item['REQ_ID']})\n";
                }
                if (item['CUSTOMER_NUMBER'] != customerNumber) {
                  // mismatchMessage +=
                  //     "- CUSTOMER_NUMBER (Expected: $customerNumber, Found: ${item['CUSTOMER_NUMBER']})\n";
                }
                if (item['CUSTOMER_SITE_ID'] != customerSiteId) {
                  // mismatchMessage +=
                  //     "- CUSTOMER_SITE_ID (Expected: $customerSiteId, Found: ${item['CUSTOMER_SITE_ID']})\n";
                }

                // Show dialog if any field does not match
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        "Data Mismatch",
                        style: TextStyle(fontSize: 19),
                      ),
                      content: Text(mismatchMessage),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("OK"),
                        ),
                      ],
                    );
                  },
                );

                return; // Exit the function if there is a mismatch
              }
              // If matched or first entry, add data to tableData
              setState(() {
                print("Added data to tableData: ${item['REQ_ID']}");
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

                tableData.add({
                  'id': item['id'],
                  "dispatchId": dispatch_id,
                  'salesman': ProductCodeController.text,
                  'reqno': item['REQ_ID'],
                  'salesmanName': item['SALESMAN_NAME'],
                  'cusno': item['CUSTOMER_NUMBER'],
                  'cusname': item['CUSTOMER_NAME'],
                  'cussite': item['CUSTOMER_SITE_ID'],
                  'total': item['DISPATCHED_QTY'],
                  'date': item['INVOICE_DATE'],
                  'invoiceno': item['INVOICE_NUMBER'],
                  'itemcode': item['INVENTORY_ITEM_ID'],
                  'itemdetails': item['ITEM_DESCRIPTION'],
                  'productcode': item['PRODUCT_CODE'],
                  'serialno': item['SERIAL_NO'],
                  'udel_id': item['UNDEL_ID'],
                });

                // Update controllers with the data
                CusNoController.text = item['CUSTOMER_NUMBER'];
                CusNameController.text = item['CUSTOMER_NAME'];
                CusSiteController.text = item['CUSTOMER_SITE_ID'];
                TotalQtyController.text = item['DISPATCHED_QTY'].toString();
                InvoiceDateController.text = item['INVOICE_DATE'];
                InvoiceNoController.text = item['INVOICE_NUMBER'];
                ItemCodeController.text = item['INVENTORY_ITEM_ID'];
                ItemDetailsController.text = item['ITEM_DESCRIPTION'];

                // Update filteredData
                filteredData = List.from(tableData);
              });
            });

            // Clear the text fields after adding
            scannedqtyController.text = tableData.length.toString();
            if (noProductCheckbox == true) {
              // Reset input fields
              salesserialnoController.clear();
            } else {
              ProductCodeController.clear();
              salesserialnoController.clear();
            }
            print("noProductCheckboxxxxxx 1 $noProductCheckbox");
            await fetchNoProductcode();
          } else {
            // Handle case when no matching data is found
          }
        } else {
          print("Failed to fetch data. Status code: ${response.statusCode}");
        }
      } catch (e) {
        print("Error occurred while fetching data: $e");
      }
    } else {
      // Handle error if either field is empty
      print("Both fields must be filled!");
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

  int getcount(List<Map<String, dynamic>> tableData) {
    return tableData.length;
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

  Future<void> _sendDataToApi() async {
    try {
      // Ensure dispatch_id is always set, defaulting to '0' if empty
      String dispatch_id = Dispatch_idController.text.isNotEmpty
          ? Dispatch_idController.text
          : '0';
      print(
          "Dispatch Request No: $dispatch_id   ${ItemDetailsController.text}");

      print(
          "Dispatch Request No: $dispatch_id   ${ItemDetailsController.text}");

      // Prepare the data to send
      final dataToSend = {
        "dispatch_id": dispatch_id,
        "req_no": Reqnocontroller.text.trim(),
        "pick_id": PickIdcontroller.text.trim(),
        "salesman_no": SalesmanNoController.text.trim(),
        "salesman_name": SalesmanNameController.text.trim(),
        "manager_no": ManagerNoController.text.trim(),
        "manager_name": ManagerNameController.text.trim(),
        "pickman_no": PickManNoController.text.trim(),
        "pickman_name": PickManNameAController.text.trim(),
        "Customer_no": CusNoController.text.trim(),
        "Customer_name": CusNameController.text.trim(),
        "Customer_Site": CusSiteController.text.trim(),
        "invoice_no": InvoiceNoController.text.trim(),
        "Item_code": ItemCodeController.text.trim(),
        "line_no": LineNoController.text.trim(),
        "Item_detailas": ItemDetailsController.text.trim(),
        "Customer_trx_id": CustomerTrxIdController.text.trim(),
        "Customer_trx_line_id": CustomerTrxLineIdController.text.trim(),
        "DisReq_Qty": TotalQtyController.text.trim(),
        "Send_qty": "1", // Hardcoded as '1' (adjust as per your logic)
        "Product_code": TableProductCodeController.text.trim(),
        "Serial_No": SerialNoproductController.text.trim(),
        "Udel_id": UdelIdontroller.text.trim()
      };

      // Log the data to send for debugging
      print("Data to send: $dataToSend");
      final IpAddress = await getActiveIpAddress();

      // Make POST request to the API
      final response = await http.post(
        Uri.parse('$IpAddress/ToGetGenerateDispatchView/'),
        headers: {
          'Content-Type': 'application/json', // Ensure JSON content type
        },
        body: jsonEncode(dataToSend), // Convert data to JSON
      );

      // Handle the response
      if (response.statusCode == 201) {
        print("Data sent successfully for Dispatch ID: $dispatch_id");
      } else {
        print(
            "Failed to send data. Status code: ${response.statusCode}, Dispatch ID: $dispatch_id");
        // print(
        // "Response body: ${response.body}"); // Log response body for debugging
      }
    } catch (e) {
      print("Error occurred while sending data: ");
    }
  }

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
    String Status = 'Request for Delivery';
    final IpAddress = await getActiveIpAddress();
    try {
      final url = Uri.parse(
          "$IpAddress/update-scan-status/${widget.reqno}/${widget.cusno}/${widget.cussite}/$Status/");

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
                                // Product Code Input
                                Padding(
                                  padding: Responsive.isDesktop(context)
                                      ? EdgeInsets.only(top: 10.0)
                                      : EdgeInsets.all(0),
                                  child: _buildInputField(context,
                                      controller: ProductCodeController,
                                      focusNode: productCodeFocusNode,
                                      label: "Enter Product Code",
                                      onSubmitted: (value) {
                                    _fieldFocusChange(
                                        context,
                                        productCodeFocusNode,
                                        SerialcameraFocus);
                                  },
                                      onPressed: _openScannerProdCode,
                                      readonly: noProductCheckbox),
                                ),

                                // Serial No Input
                                Padding(
                                  padding: Responsive.isDesktop(context)
                                      ? EdgeInsets.only(top: 10.0)
                                      : EdgeInsets.all(0),
                                  child: _buildInputField(context,
                                      controller: salesserialnoController,
                                      focusNode: serialNoFocusNode,
                                      label: "Enter Serial No",
                                      onSubmitted: (value) {
                                    _fieldFocusChange(context,
                                        serialNoFocusNode, addButtonFocusNode);
                                  },
                                      onPressed: _openScannerSerial,
                                      readonly: noSerialCheckbox),
                                ),
                                // Add Button
                                // if (BypassALertButton != true)
                                _buildActionButton(
                                  context,
                                  label: 'Add',
                                  onPressed: () async {
                                    if (noSerialCheckbox == true) {
                                      await showConfirmationForNoSerialnoDialog(
                                          context);
                                    } else {
                                      _handleAddButtonPressed();
                                    }
                                  },
                                ),
                                // Clear Button
                                _buildActionButton(
                                  context,
                                  label: 'Clear',
                                  onPressed: () {
                                    setState(() {
                                      ProductCodeController.clear();
                                      salesserialnoController.clear();
                                      filteredData = List.from(
                                          tableData); // Reset filtered data
                                    });
                                    print("Refresh button pressed");
                                    postLogData(
                                        "Truck Loading Scan", "Clear Details");
                                  },
                                ),

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

                                // Load More Button
                                if (BypassALertButton == true)
                                  _buildActionButton(
                                    context,
                                    label: 'Alert',
                                    onPressed: () {
                                      showConfirmationDialog(context);

                                      postLogData("Truck Loading Scan",
                                          "Add ByPass details");
                                    },
                                  ),

                                if (BypassALertButton == false)
                                  SizedBox(
                                    width: Responsive.isDesktop(context)
                                        ? 0
                                        : MediaQuery.of(context).size.width *
                                            0.4,
                                  ),
                                if (NoProductCodeButton == true)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 0,
                                      top:
                                          Responsive.isDesktop(context) ? 8 : 5,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: buttonColor),
                                      ),
                                      width: Responsive.isDesktop(context)
                                          ? MediaQuery.of(context).size.width *
                                              0.08
                                          : MediaQuery.of(context).size.width *
                                              0.4,
                                      // height: 30,
                                      child: Theme(
                                        data: Theme.of(context).copyWith(
                                          unselectedWidgetColor: buttonColor,
                                          checkboxTheme: CheckboxThemeData(
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                        child: Transform.scale(
                                          scale:
                                              0.8, // Adjust this value to make checkbox smaller (0.7-0.9)
                                          child: CheckboxListTile(
                                            checkColor: Colors.white,
                                            activeColor: buttonColor,
                                            fillColor: MaterialStateProperty
                                                .resolveWith<Color>(
                                              (Set<MaterialState> states) {
                                                if (states.contains(
                                                    MaterialState.selected)) {
                                                  return buttonColor;
                                                }
                                                return Colors.transparent;
                                              },
                                            ),
                                            title: Padding(
                                              padding: EdgeInsets.only(
                                                  left:
                                                      4), // Adjust text position
                                              child: Text(
                                                "No ProductCode",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      Responsive.isDesktop(
                                                              context)
                                                          ? 14
                                                          : 12,
                                                ),
                                              ),
                                            ),
                                            value: noProductCheckbox,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                ProductCodeController.text =
                                                    '00';
                                                salesserialnoController.text =
                                                    '';
                                                noProductCheckbox =
                                                    value ?? false;
                                                noSerialCheckbox = false;
                                              });
                                            },
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                            contentPadding: EdgeInsets.only(
                                              left: 4, // Reduced left padding
                                              right: 8,
                                              top: 0,
                                              bottom: 0,
                                            ),
                                            dense: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (NoSerialNoButton == true)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: Responsive.isDesktop(context)
                                          ? 8
                                          : 10,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: buttonColor),
                                      ),
                                      width: Responsive.isDesktop(context)
                                          ? 200
                                          : 160,
                                      // height: 30,
                                      child: Theme(
                                        data: Theme.of(context).copyWith(
                                          unselectedWidgetColor: buttonColor,
                                          checkboxTheme: CheckboxThemeData(
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                        child: Transform.scale(
                                          scale:
                                              0.85, // Adjust this value to make checkbox smaller (0.7-0.9)
                                          child: CheckboxListTile(
                                            checkColor: Colors.white,
                                            activeColor: buttonColor,
                                            fillColor: MaterialStateProperty
                                                .resolveWith<Color>(
                                              (Set<MaterialState> states) {
                                                if (states.contains(
                                                    MaterialState.selected)) {
                                                  return buttonColor;
                                                }
                                                return Colors.transparent;
                                              },
                                            ),
                                            title: Padding(
                                              padding: EdgeInsets.only(
                                                  left:
                                                      4), // Adjust text position
                                              child: Text(
                                                "No SerialNo",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      Responsive.isDesktop(
                                                              context)
                                                          ? 14
                                                          : 12,
                                                ),
                                              ),
                                            ),
                                            value: noSerialCheckbox,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                salesserialnoController.text =
                                                    'null';
                                                ProductCodeController.text = '';
                                                noSerialCheckbox =
                                                    value ?? false;
                                                noProductCheckbox = false;
                                              });
                                            },
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                            contentPadding: EdgeInsets.only(
                                              left: 4, // Reduced left padding
                                              right: 8,
                                              top: 0,
                                              bottom: 0,
                                            ),
                                            dense: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
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
                            child: Text("Scanned Items : ${scanneditems}",
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

                                  if (filteredTable.isEmpty) {
                                    showValidationDialog(context);
                                  } else {
                                    updateScanStatus();

                                    postLogData("Truck Loading Scan",
                                        "Request for Delivery");
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

  Future<void> showConfirmationForNoSerialnoDialog(BuildContext context) async {
    print("Filtered Data: $filteredData");

    final IpAddress = await getActiveIpAddress();

    final String url =
        '$IpAddress/compare-scan-noserialno/${widget.reqno}/${widget.cusno}/${widget.cussite}/';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['status'] == 'success') {
          final List<dynamic> apiData = jsonData['data'];

          // Get product codes from API where serial is null
          List<String> apiProductCodes = apiData
              .where((item) => item['SERIAL_NO'] == 'null')
              .map<String>((item) => item['PRODUCT_CODE'].toString())
              .toList();

          // Get the user entered product code
          String enteredProductCode = ProductCodeController.text.trim();

          // If entered product code is not found in API's product codes
          if (!apiProductCodes.contains(enteredProductCode)) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'Product Code Mismatch',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                      'Entered Product Code does not match with any available No-SerialNo Product Codes.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        ProductCodeController.clear();
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
            return;
          }
        }
      } else {
        print("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching URL data: $e");
    }

    // Local check in filteredData
    bool hasBypassData = filteredData.any((row) =>
        row['serialno'] == "null" &&
        row['productcode'] != "00" &&
        row['req_no'] == widget.reqno &&
        row['pick_id'] == widget.pickno);

    if (hasBypassData) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Already Exists',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: Text('This Product Code and Serial No already exist.'),
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
                'Product with no SerialNo in stage. Do you want to load it into the truck?'),
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
                  await fetchNoSerialnodatasaddtabledatas();
                  setState(() {
                    NoSerialNoButton = false;
                  });

                  await fetchNoSerialNo();
                  print("fetchNoSerialNo 22222 $NoSerialNoButton");
                  await fetchNoSerialNo();
                  if (NoSerialNoButton == false) {
                    // Reset input fields

                    ProductCodeController.clear();
                    salesserialnoController.clear();
                    _fieldFocusChange(
                        context, addButtonFocusNode, productCodeFocusNode);
                    await fetchNoSerialNo();
                  } else {
                    print("fetchNoSerialNo 3333  $noSerialCheckbox");
                  }
                  setState(() {
                    NoSerialNoButton = false;
                  });
                  if (!NoSerialNoButton) {
                    ProductCodeController.clear();
                    salesserialnoController.clear();
                    _fieldFocusChange(
                        context, addButtonFocusNode, productCodeFocusNode);
                  }

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
                  await fetchBypassdatasaddtabledatas();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => MainSidebar(
                  //       initialPageIndex: 21,
                  //       enabledItems: accessControl,
                  //     ),
                  //   ),
                  // );
                  await fetchBypassdatastotruck();

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

  void _openScannerSerial() {
    bool isScanned = false;
    final MobileScannerController scannerController = MobileScannerController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Scan Serial Number',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: MobileScanner(
                        controller: scannerController,
                        onDetect: (BarcodeCapture capture) {
                          if (isScanned) return;
                          isScanned = true;

                          final String? scannedCode =
                              capture.barcodes.first.rawValue;

                          if (scannedCode != null && scannedCode.isNotEmpty) {
                            salesserialnoController.text = scannedCode;
                            Navigator.of(context).pop();

                            // Show success feedback
                            _showScanSuccess(context, 'Serial Number Scanned!');

                            // Trigger the Add function automatically
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              _handleAddButtonPressed();
                            });
                          }
                        },
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Align the barcode within the frame',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.flash_on, size: 20, color: Colors.white),
                    label: Text(
                      'Flash',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => scannerController.toggleTorch(),
                  ),
                ],
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: ScannerOverlayPainter(
                    borderColor: Colors.green,
                    borderRadius: 16,
                    borderWidth: 4,
                    borderLength: 40,
                    cutOutSize: MediaQuery.of(context).size.width * 0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      scannerController.dispose();
      isScanned = false;
      FocusScope.of(context).requestFocus(addButtonFocusNode);
    });
  }

  void _openScannerProdCode() {
    bool isScanned = false;
    final MobileScannerController scannerController = MobileScannerController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(20)),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Scan Product Code',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: MobileScanner(
                        controller: scannerController,
                        onDetect: (BarcodeCapture capture) async {
                          if (isScanned) return;
                          isScanned = true;

                          final String? scannedCode =
                              capture.barcodes.first.rawValue;

                          if (scannedCode != null && scannedCode.isNotEmpty) {
                            ProductCodeController.text = scannedCode;
                            Navigator.of(context).pop();

                            // Show success feedback
                            _showScanSuccess(context, 'Product Code Scanned!');
                            print("noSerialCheckbox  $noSerialCheckbox");
                            if (noSerialCheckbox == true) {
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                showConfirmationForNoSerialnoDialog(context);
                              });
                            } else {
                              Future.delayed(Duration(milliseconds: 800), () {
                                _openScannerSerial();
                              });
                            }
                          }
                        },
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Align the barcode within the frame',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.flash_on,
                              size: 20, color: Colors.white),
                          label: Text(
                            'Flash',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () => scannerController.toggleTorch(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: ScannerOverlayPainter(
                    borderColor: Colors.blueAccent,
                    borderRadius: 16,
                    borderWidth: 4,
                    borderLength: 40,
                    cutOutSize: MediaQuery.of(context).size.width * 0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      scannerController.dispose();
      isScanned = false;
      FocusScope.of(context).requestFocus(SerialcameraFocus);
    });
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
          bool matchesSerial = item['SERIAL_NO'] == serialNo;
          bool matchesProduct =
              productCode == null || item['PRODUCT_CODE'] == productCode;
          bool matchesFlag = item['FLAG'] != 'R' && item['FLAG'] != 'SR';
          return matchesreqno && matchesSerial && matchesProduct && matchesFlag;
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
            Center(child: CircularProgressIndicator())
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Invoice No: ${data['invoiceno']}", style: TableRowTextStyle),
            SizedBox(height: 8),
            Text("Item Code: ${data['itemcode']}", style: TableRowTextStyle),
            SizedBox(height: 8),
            Text("Item Description: ${data['itemdetails']}",
                style: TableRowTextStyle),
            SizedBox(height: 8),
            Text("Product Code: ${data['productcode']}",
                style: TableRowTextStyle),
            SizedBox(height: 8),
            Text("Serial No: ${data['serialno']}", style: TableRowTextStyle),
          ],
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
                                        child: Text(productcode,
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

  void _handleAddButtonPressed() async {
    String productCode = ProductCodeController.text.trim();
    String serialNo = salesserialnoController.text.trim();

    bool alreadyExists = filteredData.any((item) =>
        item['productcode'].toString() == productCode &&
        item['serialno'].toString() == serialNo);

    if (productCode.isNotEmpty || serialNo.isNotEmpty) {
      try {
        // Show the processing dialog
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
        // Exit early if the product and serial number already exist in filteredData
        if (alreadyExists) {
          Navigator.pop(context); // Close the processing dialog
          showVAlreadyExistproductcode(
            context,
            "This Product Code and Serial No already Exist!!!",
          );
          print("This product is already in the list.");
          return;
        }

        // Exit early if the product and serial number already exist in filteredData
        if (productCode == '00' && serialNo == 'null') {
          Navigator.pop(context); // Close the processing dialog
          showVAlreadyExistproductcode(context,
              "This Product Code and Serial Number belong to a bypass product. You can use the 'Alert' button to add a bypass product.");
          print(
              "This Product Code and Serial Number belong to a bypass product. You can use the 'Alert' button to add a bypass product.");
          return;
        }
        final IpAddress = await getActiveIpAddress();

        // Fetch and validate data from Truck_scan API
        bool existsInTruckScan = await checkIfSerialExistsInPaginatedApi(
          '$IpAddress/Truck_scan/',
          widget.reqno,
          serialNo,
          productCode: productCode,
        );

        if (existsInTruckScan) {
          Navigator.pop(context); // Close the processing dialog
          showVAlreadyExistproductcode(
            context,
            "This Product Code and Serial No are already being tracked.",
          );
          print(
              "This product code and serial number are already being tracked in Truck_scan.");
          return;
        }

        // Fetch and validate data from Pickman_scan API
        bool existsInPickmanScan = await checkIfSerialExistsInPaginatedApi(
          '$IpAddress/Pickman_scan/',
          widget.reqno,
          serialNo,
          productCode: productCode,
        );

        if (existsInPickmanScan) {
          print(
              "Serial number exists in Pickman_scan. Proceeding to save the truck data.");
          await _addTableData();

          setState(() {
            filteredData =
                List.from(tableData); // Ensure filteredData is up-to-date
          });

          await _sendDataToApi();
          await fetchDataAndSetControllers();
          await fetchPreviousLoadCount(widget.reqno, widget.pickno);
          await _updateCurrentLoadCount();
          await fetchNoProductcode();
          if (noProductCheckbox == true) {
            // Reset input fields
            salesserialnoController.clear();

            await fetchNoProductcode();
            _fieldFocusChange(context, addButtonFocusNode, serialNoFocusNode);
          } else {
            ProductCodeController.clear();
            salesserialnoController.clear();
            // Change focus to the next field
            _fieldFocusChange(
                context, addButtonFocusNode, productCodeFocusNode);
          }
          setState(() {
            NoProductCodeButton = false;
          });
          await fetchNoProductcode();
          print("noProductCheckboxxxxxx 2 $NoProductCodeButton");
          await fetchNoProductcode();
          if (NoProductCodeButton == false) {
            // Reset input fields
            ProductCodeController.clear();
            _fieldFocusChange(
                context, addButtonFocusNode, productCodeFocusNode);
          }
        } else {
          Navigator.pop(context); // Close the processing dialog
          showVAlreadyExistproductcode(
            context,
            "No matching data found for the entered product code and serial number in Pickman_scan.",
          );
          print("This serial number does not exist in Pickman_scan.");
          return;
        }

        postLogData("Truck Loading Scan", "Add details");
        // Close the processing dialog after operation
        Navigator.pop(context); // Close the processing dialog
      } catch (error) {
        Navigator.pop(context); // Close the processing dialog
        print('Error while checking Pickman_scan or Truck_scan API: $error');
      }
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
