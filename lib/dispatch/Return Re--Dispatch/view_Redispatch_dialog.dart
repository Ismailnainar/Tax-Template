import 'dart:typed_data'; // for Uint8List
import 'dart:io'; // for File
import 'package:aljeflutterapp/components/constaints.dart';
import 'package:path_provider/path_provider.dart'; // for getApplicationDocumentsDirectory
import 'package:pdf/widgets.dart' as pw;
import 'dart:ui';
import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';

class view_redispatch extends StatefulWidget {
  final String reqno;
  // final String date;
  // final String cussite;
  // final String cusId;
  final String ClickMessage;
  final Function togglePage;

  view_redispatch({
    super.key,
    required this.reqno,
    // required this.date,
    // required this.cussite,
    // required this.cusId,
    required this.ClickMessage,
    required this.togglePage,
  });

  @override
  State<view_redispatch> createState() => _view_redispatchState();
}

class _view_redispatchState extends State<view_redispatch> {
  bool _isLoading = true;

  final ScrollController _horizontalScrollController2 = ScrollController();
  final ScrollController _verticalScrollController2 = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController2.dispose();
    _verticalScrollController2.dispose();
    super.dispose();
    postLogData("Re-Dispatch Request DetailsView Pop-up", "Closed");
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
                              // hintText: label,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              filled: true,
                              fillColor: readOnly
                                  ? Color.fromARGB(255, 240, 240, 240)
                                  : Color.fromARGB(255, 255, 255, 255),
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
      return DateFormat('dd-MMM-yyyy').format(parsedDate).toUpperCase();
    } catch (e) {
      return dateString;
    }
  }

  List<Map<String, dynamic>> createtableData = [];

  TextEditingController _totalController = TextEditingController();

  TextEditingController _DateController = TextEditingController();

  TextEditingController _DeliveryateController = TextEditingController();
  TextEditingController _CusidController = TextEditingController();
  TextEditingController _CussiteController = TextEditingController();
  TextEditingController _CustomerNameController = TextEditingController();
  TextEditingController _RegionController = TextEditingController();
  TextEditingController _WarehousenameNameController = TextEditingController();
  TextEditingController _ReqNoController = TextEditingController();
  TextEditingController _ReturnreasonCOntroller = TextEditingController();

  Widget _viewbuildTable() {
    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight = Responsive.isDesktop(context) ? 30 : 30;

    print("table createtableDataaaaa $createtableData");
    List<Map<String, dynamic>> sortedTableData = List.from(createtableData);
    sortedTableData.sort((a, b) =>
        int.parse(a['id'].toString()).compareTo(int.parse(b['id'].toString())));

    List<Map<String, dynamic>> tableHeaders = [
      {'icon': Icons.receipt, 'label': 'Invoice No'},
      {'icon': Icons.category, 'label': 'L.No'},
      {'icon': Icons.code, 'label': 'Item Code'},
      {'icon': Icons.details, 'label': 'Item Description'},
      {'icon': Icons.check, 'label': 'Qty. Re-Dis'},
      // {'icon': Icons.check_circle, 'label': 'Status'},
    ];

    // Define fixed widths for each column
    List<double> columnWidths = [120, 70, 180, 550, 120];

    Widget _buildHeaderCell(Map<String, dynamic> header, double width) {
      return Container(
        height: containerHeight,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Row(
          children: [
            Icon(header['icon'], size: 15, color: Colors.blue),
            const SizedBox(width: 5),
            Text(
              header['label'],
              textAlign: TextAlign.start,
              style: commonLabelTextStyle,
            ),
          ],
        ),
      );
    }

    Widget _buildDataCell(String value, double width, String Message) {
      return Container(
        height: 50,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: const Color.fromARGB(255, 226, 225, 225)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Tooltip(
              message: Message,
              child: SelectableText(
                value,
                textAlign: TextAlign.start,
                style: TableRowTextStyle,
                showCursor: false,
                // overflow: TextOverflow.ellipsis,
                cursorColor: Colors.blue,
                cursorWidth: 2.0,
                toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
                onTap: () {
                  // Optional: Handle single tap if needed
                },
              ),
            ),

            // Text(
            //   value,
            //   textAlign: TextAlign.start,
            //   style: TableRowTextStyle,
            //   overflow: TextOverflow.ellipsis,
            // ),
          ),
        ),
      );
    }

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tableHeaders.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> header = entry.value;
                  return _buildHeaderCell(header, columnWidths[index]);
                }).toList(),
              ),
            ),
            const SizedBox(height: 5),
            // Data rows
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: _isLoading
                      ? [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 60.0, left: 450),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        ]
                      : (sortedTableData.isNotEmpty
                          ? sortedTableData.map((data) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildDataCell(data['invoiceno']!.toString(),
                                      columnWidths[0], ''),
                                  _buildDataCell(data['id']!.toString(),
                                      columnWidths[1], ''),
                                  _buildDataCell(data['itemcode']!.toString(),
                                      columnWidths[2], ''),
                                  _buildDataCell(
                                      data['itemdetails']!.toString(),
                                      columnWidths[3],
                                      ''),
                                  _buildDataCell(data['itemqty']!.toString(),
                                      columnWidths[4], ''),
                                ],
                              );
                            }).toList()
                          : [
                              Padding(
                                padding: const EdgeInsets.only(top: 60.0),
                                child: Text("No data available."),
                              ),
                            ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool generatepickingbuttonenable = false;
  @override
  void initState() {
    super.initState();
    fetchAccessControl();
    generatepickingbuttonenable = false;
    fetchDataRetrun_redispatch();
    _loadSalesmanName();

    // fetchDispatchDetails();
    postLogData("OnProgress Dispatch DetailsView Pop-up", "Opened");
  }

  List<bool> accessControl = [];

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

  Map<dynamic, dynamic> groupedData = {}; // Accepts any key type
  Future<void> fetchDataRetrun_redispatch() async {
    try {
      // Initialize SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final saleslogiOrgwarehousename =
          prefs.getString('saleslogiOrgwarehousename') ?? '';

      // Get IP address
      final ipAddress = await getActiveIpAddress();
      if (ipAddress!.isEmpty) {
        throw Exception('IP address is not available');
      }

      // Build URL
      final url = Uri.parse(
          '$ipAddress/Filtered_Returndispatch/${widget.reqno}/$saleslogiOrgwarehousename/');
      print(
          '$ipAddress/Filtered_Returndispatch/${widget.reqno}/$saleslogiOrgwarehousename/');

      // Make HTTP request
      final response = await http.get(url).timeout(const Duration(seconds: 30));

      // Clear previous data
      createtableData = [];

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load data: Status code ${response.statusCode}');
      }

      // Parse response

      final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
      final responseData = json.decode(decodedBody) as List<dynamic>;
      if (responseData.isEmpty) {
        print("No data found for the request.");
        return;
      }

      // Process first record
      final data = responseData[0] as Map<String, dynamic>;
      await _updateControllersWithData(data);

      // Process table details
      if (data['TABLE_DETAILS'] != null) {
        await _processTableDetails(data);
      }

      // Group data by REQ_ID - Fixed to handle string or int keys
      _groupDataByReqId(data);
      _updateTotal();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error in fetchDataRetrun_redispatch: $e');
      // Consider showing an error message to the user
    }
  }

  Future<void> _updateControllersWithData(Map<String, dynamic> data) async {
    setState(() {
      _DateController.text = data['INVOICE_DATE']?.toString() ?? '';
      _CusidController.text = data['CUSTOMER_NUMBER']?.toString() ?? '';
      _CussiteController.text = data['CUSTOMER_SITE_ID']?.toString() ?? '';
      _CustomerNameController.text = data['CUSTOMER_NAME']?.toString() ?? '';
      _WarehousenameNameController.text = data['ORG_NAME']?.toString() ?? '';
      _RegionController.text = data['TO_WAREHOUSE']?.toString() ?? '';
      _ReqNoController.text = data['REQ_ID']?.toString() ?? '';
      _ReturnreasonCOntroller.text = data['RETURN_REASON']?.toString() ?? '';
      print("Warehouse details: ${_WarehousenameNameController.text}");
    });
  }

  Future<void> _processTableDetails(Map<String, dynamic> data) async {
    final tableDetails = data['TABLE_DETAILS'] as List<dynamic>;

    for (var item in tableDetails.cast<Map<String, dynamic>>()) {
      final RETURN_QTY =
          int.tryParse(item['DISPATCHED_BY_MANAGER']?.toString() ?? '0') ?? 0;

      createtableData.add({
        'id': item['LINE_NUMBER']?.toString() ?? '',
        'invoiceno': item['INVOICE_NUMBER']?.toString() ?? '',
        'itemcode': item['INVENTORY_ITEM_ID']?.toString() ?? '',
        'itemdetails': item['ITEM_DESCRIPTION']?.toString() ?? '',
        'itemqty': RETURN_QTY,
      });
    }

    print("createtableDataaaaa $createtableData");
    setState(() {
      generatepickingbuttonenable = false;
    });
  }

  void _groupDataByReqId(Map<String, dynamic> data) {
    // First try to get as int, fall back to string if not possible
    final returnDisId = data['RETURN_DIS_ID'];
    final reqno = returnDisId is int
        ? returnDisId
        : int.tryParse(returnDisId?.toString() ?? '') ??
            returnDisId?.toString() ??
            '';

    if (reqno == null || reqno == '') return;

    if (!groupedData.containsKey(reqno)) {
      final RETURN_QTY =
          int.tryParse(data['DISPATCHED_BY_MANAGER']?.toString() ?? '0') ?? 0;

      groupedData[reqno] = {
        'id': data['LINE_NUMBER']?.toString() ?? '',
        'invoiceno': data['INVOICE_NUMBER']?.toString() ?? '',
        'itemcode': data['INVENTORY_ITEM_ID']?.toString() ?? '',
        'itemdetails': data['ITEM_DESCRIPTION']?.toString() ?? '',
        'invoiceqty': data['TOT_QUANTITY']?.toString() ?? '0',
        'itemqty': RETURN_QTY,
      };
    }

    // Calculate total
    double total = 0.0;
    for (var item in createtableData) {
      total += double.tryParse(item['invoiceqty']?.toString() ?? '0') ?? 0.0;
    }
    groupedData[reqno]!['total'] = total;

    print("Grouped data: $groupedData");
  }

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
    _totalController.text = totalSendQuantity.toStringAsFixed(0);

    // Print or return the calculated total (for display, logging, etc.)
    print("Total send quantity: ${totalSendQuantity.toStringAsFixed(2)}");
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
    String date = _formatDate(_DateController.text);

    String deliverydate = _formatDate(_DeliveryateController.text);
    int index = 0; // Example index

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
                      if (!Responsive.isMobile(context))
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("View Re-Dispatch Request Details",
                                style: topheadingbold),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Tooltip(
                                    message: 'Close',
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.cancel,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      if (Responsive.isMobile(context))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Tooltip(
                                      message: 'Close',
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.cancel,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Text("View Re-Dispatch Request Details",
                                style: topheadingbold),
                          ],
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          runSpacing: 5,
                          children: [
                            _buildTextFieldDesktop(
                                'Dis Return Id', "${widget.reqno}", true),
                            _buildTextFieldDesktop(
                                'Req No', _ReqNoController.text, true),
                            _buildTextFieldDesktop('Physical Warehouse',
                                _WarehousenameNameController.text, true),
                            _buildTextFieldDesktop(
                                'Region', _RegionController.text, true),
                            Container(
                              width: Responsive.isDesktop(context)
                                  ? screenWidth * 0.09
                                  : screenWidth,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 0),
                                    Row(
                                      children: [
                                        Text('Date', style: textboxheading),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0, bottom: 0),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 34,
                                            width: Responsive.isDesktop(context)
                                                ? screenWidth * 0.08
                                                : screenWidth * 0.5,
                                            child: MouseRegion(
                                              onEnter: (event) {
                                                // You can perform any action when mouse enters, like logging the value.
                                              },
                                              onExit: (event) {
                                                // Perform any action when the mouse leaves the TextField area.
                                              },
                                              cursor: SystemMouseCursors.click,
                                              child: TextField(
                                                  readOnly:
                                                      true, // Set readOnly state
                                                  decoration: InputDecoration(
                                                      // hintText: label,
                                                      border:
                                                          OutlineInputBorder(
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
                                                          255, 240, 240, 240)),
                                                  controller:
                                                      TextEditingController(
                                                          text: date),
                                                  style: textBoxstyle),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            _buildTextFieldDesktop(
                                'Customer No', _CusidController.text, true),
                            _buildTextFieldDesktop('Customer Name',
                                _CustomerNameController.text, true),
                            _buildTextFieldDesktop(
                                'Customer Site', _CussiteController.text, true),
                            if (widget.ClickMessage == 'ReturnReport')
                              _buildTextFieldDesktop('Return Reason',
                                  _ReturnreasonCOntroller.text, true),
                            if (widget.ClickMessage != 'ReturnReport')
                              if (generatepickingbuttonenable == false)
                                if (salesloginrole == 'Supervisor' ||
                                    salesloginrole == 'WHR SuperUser')
                                  Padding(
                                      padding: const EdgeInsets.only(top: 33.0),
                                      child: Container(
                                        width: 180,
                                        decoration:
                                            BoxDecoration(color: buttonColor),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Action for the "Generate Picking" button
                                            print(
                                                'Generate Picking button clicked');
                                            Navigator.pop(context);
                                            widget.togglePage('Re-Dispatch');
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            backgroundColor: buttonColor,
                                            minimumSize: const Size(45.0, 40.0),
                                          ),
                                          child: const Text(
                                            'Generate Picking',
                                            style: commonWhiteStyle,
                                          ),
                                        ),
                                      )),
                            if (widget.ClickMessage != 'ReturnReport')
                              if (generatepickingbuttonenable == true)
                                if (salesloginrole == 'Supervisor' ||
                                    salesloginrole == 'WHR SuperUser')
                                  Padding(
                                      padding: const EdgeInsets.only(top: 33.0),
                                      child:
                                          // Container(
                                          // child: (dis_qty_total == balance_qty)
                                          //     ? Container(
                                          //         width: 180,
                                          //         color: Colors.green,
                                          //         child: Text(
                                          //           'Pick Request Completed..!!!',
                                          //           style: TextStyle(
                                          //               fontSize: 17, color: Colors.white),
                                          //         ),
                                          //       )
                                          //   :
                                          Container(
                                        width: 200,
                                        decoration:
                                            BoxDecoration(color: Colors.green),
                                        child: ElevatedButton(
                                          onPressed: () async {},
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            backgroundColor: Colors.green,
                                            minimumSize: const Size(45.0, 40.0),
                                          ),
                                          child: const Text(
                                            'Pick Req Completed',
                                            style: commonWhiteStyle,
                                          ),
                                        ),
                                      )),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 240,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey[400]!,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: ScrollbarTheme(
                                      data: ScrollbarThemeData(
                                        thumbColor: MaterialStateProperty.all(
                                            Colors.grey[600]),
                                        thumbVisibility:
                                            MaterialStateProperty.all(true),
                                        thickness: MaterialStateProperty.all(8),
                                        radius: const Radius.circular(10),
                                      ),
                                      child: Scrollbar(
                                        controller:
                                            _horizontalScrollController2,
                                        child: SingleChildScrollView(
                                          controller:
                                              _horizontalScrollController2,
                                          scrollDirection: Axis.horizontal,
                                          child: _viewbuildTable(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0, // Adjust position as needed
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                            _horizontalScrollController2
                                                .animateTo(
                                              _horizontalScrollController2
                                                      .offset -
                                                  100, // Adjust scroll amount
                                              duration:
                                                  Duration(milliseconds: 300),
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
                                            _horizontalScrollController2
                                                .animateTo(
                                              _horizontalScrollController2
                                                      .offset +
                                                  100, // Adjust scroll amount
                                              duration:
                                                  Duration(milliseconds: 300),
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
                            const SizedBox(height: 10),
                            Responsive.isDesktop(context)
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Right Side - Total Send Qty Section
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 10,
                                                  left: Responsive.isDesktop(
                                                          context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.01
                                                      : 0),
                                              child: _buildTextFieldDesktop(
                                                  "Total Re-Dis Qty",
                                                  _totalController.text,
                                                  true),
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
                                      _buildTextFieldDesktop("Total Re-Dis Qty",
                                          _totalController.text, true),
                                      // Padding(
                                      //   padding: EdgeInsets.only(
                                      //       top: 50,
                                      //       left: MediaQuery.of(context).size.width * 0.03),
                                      //   child: Row(
                                      //     mainAxisAlignment: MainAxisAlignment.start,
                                      //     children: [
                                      //       Container(
                                      //         width: 180,
                                      //         decoration: BoxDecoration(color: buttonColor),
                                      //         child: ElevatedButton(
                                      //           onPressed: () {
                                      //             Navigator.pushReplacement(
                                      //               context,
                                      //               MaterialPageRoute(
                                      //                 builder: (context) => MainSidebar(
                                      //                     enabledItems: accessControl,
                                      //                     initialPageIndex:
                                      //                         3), // Navigate to MainSidebar
                                      //               ),
                                      //             );
                                      //           },
                                      //           style: ElevatedButton.styleFrom(
                                      //             shape: RoundedRectangleBorder(
                                      //               borderRadius: BorderRadius.circular(8),
                                      //             ),
                                      //             backgroundColor: buttonColor,
                                      //             minimumSize: const Size(
                                      //                 45.0, 40.0), // Set width and height
                                      //           ),
                                      //           child: Padding(
                                      //             padding: const EdgeInsets.all(0),
                                      //             child: const Text(
                                      //               'Generate Picking',
                                      //               style: TextStyle(color: Colors.white),
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ]))));
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
                      child: Text(
                        data,
                        textAlign: TextAlign.left, // Align text to the start
                        style: TableRowTextStyle,
                        overflow: TextOverflow.ellipsis,
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

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  List<Map<String, dynamic>> viewtableData = [];

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
                width: MediaQuery.of(context).size.width * 0.55,
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
                              _tableHeader("Pick Id", Icons.countertops),
                              _tableHeader("Item Description", Icons.print),
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
                            String pickid = 'PickId_$getpickid';
                            String pickmanname = data['ASS_PICKMAN'].toString();
                            String dispatchqty =
                                "${data['DISPATCHED_QTY'].toString()}";
                            String pickedqty = data['PICKED_QTY'].toString();

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
                                    _tableRow(item_descrption, rowColor),
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

  void showInvoiceDialog(
      BuildContext context,
      bool buttonname,
      List<Map<String, dynamic>> tableData,
      TextEditingController pickNoController,
      TextEditingController reqNoController,
      TextEditingController warehouseNameController,
      TextEditingController regionController,
      TextEditingController customerNumberController,
      TextEditingController customerNameController,
      TextEditingController cussiteController) {
    double _calculateSendQtyTotal(List<Map<String, dynamic>> tableData) {
      double totalSendQty = 0.0;
      for (var row in tableData) {
        var sendQty = row['sendqty'];
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
                              'Pick Man Print',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[800],
                              ),
                            ),
//                             if (buttonname)
//                               Container(
//                                   height: 35,
//                                   decoration: BoxDecoration(color: buttonColor),
//                                   child: ElevatedButton(
//                                     onPressed: () async {
//                                       bool allFilled =
//                                           true; // Assume all fields are filled initially

// // Loop through the controllers to check if any field is empty
//                                       for (int i = 0;
//                                           i < _controllers.length;
//                                           i++) {
//                                         if (_controllers[i].text.isNotEmpty) {
//                                           allFilled =
//                                               false; // At least one field is filled, so we do not need to show the dialog
//                                           break; // Exit the loop as soon as we find a non-empty field
//                                         }
//                                       }

// // If all fields are empty, show the dialog
//                                       if (allFilled) {
//                                         showDialog(
//                                           context: context,
//                                           builder: (BuildContext context) {
//                                             return AlertDialog(
//                                               title: Row(
//                                                 children: [
//                                                   const Icon(
//                                                     Icons.warning,
//                                                     color: Colors.yellow,
//                                                   ),
//                                                   SizedBox(width: 2),
//                                                   Text('Warning'),
//                                                 ],
//                                               ),
//                                               content: const Text(
//                                                   "Kindly fill all the fields."),
//                                               actions: [
//                                                 TextButton(
//                                                   onPressed: () {
//                                                     Navigator.of(context)
//                                                         .pop(); // Close the dialog
//                                                   },
//                                                   child: const Text("OK"),
//                                                 ),
//                                               ],
//                                             );
//                                           },
//                                         );
//                                       } else if (_AssignedStaffController
//                                           .text.isNotEmpty) {
//                                         // Show confirmation dialog before proceeding
//                                         showDialog(
//                                           context: context,
//                                           builder: (BuildContext context) {
//                                             return AlertDialog(
//                                               title: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Row(
//                                                     children: [
//                                                       Icon(Icons.delete,
//                                                           size: 18),
//                                                       SizedBox(
//                                                         width: 4,
//                                                       ),
//                                                       Text('Confirm Assign',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                               fontSize: 17)),
//                                                     ],
//                                                   ),
//                                                 ],
//                                               ),
//                                               content: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 children: [
//                                                   Text(
//                                                     'Are you sure you want to Assigned the Dispatch Quantity?',
//                                                     style:
//                                                         TextStyle(fontSize: 15),
//                                                   ),
//                                                 ],
//                                               ),
//                                               actions: <Widget>[
//                                                 TextButton(
//                                                   onPressed: () {
//                                                     // Close the dialog if "No" is pressed
//                                                     Navigator.of(context).pop();
//                                                   },
//                                                   child: const Text('No'),
//                                                 ),
//                                                 TextButton(
//                                                   onPressed: () async {
//                                                     // Perform actions if "Yes" is pressed
//                                                     await postDispatchRequest();
//                                                     await fetchLastPickNo();
//                                                     setState(() {
//                                                       _ReqnoController.clear();
//                                                       _WarehousenameNameController
//                                                           .clear();
//                                                       _RegionController.clear();
//                                                       _CustomerNameController
//                                                           .clear();
//                                                       _CusidController.clear();
//                                                       _CussiteController
//                                                           .clear();
//                                                       tableData.clear();
//                                                       _AssignedStaffController
//                                                           .clear();
//                                                       SharedPrefs
//                                                           .clearreqnoAll();
//                                                     });
//                                                     // Close the dialog

//                                                     Navigator.of(context).pop();

//                                                     await Navigator
//                                                         .pushReplacement(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             MainSidebar(
//                                                                 enabledItems:
//                                                                     accessControl,
//                                                                 initialPageIndex:
//                                                                     2),
//                                                       ),
//                                                     );

//                                                     // Navigator.pushReplacement(
//                                                     //   context,
//                                                     //   MaterialPageRoute(
//                                                     //     builder: (context) =>
//                                                     //         MainSidebar(
//                                                     //             enabledItems:
//                                                     //                 accessControl,
//                                                     //             initialPageIndex:
//                                                     //                 2), // Navigate to MainSidebar
//                                                     //   ),
//                                                     // );
//                                                     // fetchAccessControl();
//                                                   },
//                                                   child: const Text('Yes'),
//                                                 ),
//                                               ],
//                                             );
//                                           },
//                                         );
//                                       } else if (!allFilled) {
//                                         checkpickQty();
//                                       } else {
//                                         checkpickman();
//                                       }
//                                     },
//                                     style: ElevatedButton.styleFrom(
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       minimumSize: const Size(
//                                           45.0, 31.0), // Set width and height
//                                       backgroundColor: Colors
//                                           .transparent, // Make background transparent to show gradient
//                                       shadowColor: Colors
//                                           .transparent, // Disable shadow to preserve gradient
//                                     ),
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(
//                                           top: 5, bottom: 5, left: 8, right: 8),
//                                       child: const Text(
//                                         'Assign',
//                                         style: TextStyle(
//                                             fontSize: 16, color: Colors.white),
//                                       ),
//                                     ),
//                                   )),
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
                                'Dis. Req ID: ',
                                reqNoController.text,
                                'Customer No: ',
                                customerNumberController.text,
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
                                'Pick Man: ',
                                cussiteController.text,
                                // _AssignedStaffController.text,
                                '',
                                '',
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
                          'Picked Items:',
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
                            child: PrintPreviewTable(tableData: tableData),
                          ),
                        ),
                        SizedBox(height: 7),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Total Qty: ${_calculateSendQtyTotal(tableData)}',
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
                      children: [
                        // Container(
                        //     height: 35,
                        //     decoration: BoxDecoration(color: buttonColor),
                        //     child: ElevatedButton(
                        //       onPressed: () async {
                        //         // await _savePdf();
                        //         _captureAndSavePdf();
                        //       },
                        //       style: ElevatedButton.styleFrom(
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(8),
                        //         ),
                        //         minimumSize: const Size(45.0, 31.0),
                        //         backgroundColor: Colors.transparent,
                        //         shadowColor: Colors.transparent,
                        //       ),
                        //       child: Padding(
                        //         padding: const EdgeInsets.only(
                        //             top: 5, bottom: 5, left: 8, right: 8),
                        //         child: const Text(
                        //           'Print',
                        //           style: TextStyle(
                        //               fontSize: 16, color: Colors.white),
                        //         ),
                        //       ),
                        //     )),
                        // SizedBox(
                        //   width: 20,
                        // ),
                        // Container(
                        //     height: 35,
                        //     decoration: BoxDecoration(color: buttonColor),
                        //     child: ElevatedButton(
                        //       onPressed: () async {
                        //         // await _savePdf();
                        //         _captureAndSavePdf();
                        //       },
                        //       style: ElevatedButton.styleFrom(
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(8),
                        //         ),
                        //         minimumSize: const Size(45.0, 31.0),
                        //         backgroundColor: Colors.transparent,
                        //         shadowColor: Colors.transparent,
                        //       ),
                        //       child: Padding(
                        //         padding: const EdgeInsets.only(
                        //             top: 5, bottom: 5, left: 8, right: 8),
                        //         child: const Text(
                        //           'Generate Pdf',
                        //           style: TextStyle(
                        //               fontSize: 16, color: Colors.white),
                        //         ),
                        //       ),
                        //     )),
                      ],
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
    final filteredData = tableData.where((data) {
      final sendQty = data['sendqty'];
      return sendQty != null &&
          sendQty.toString().isNotEmpty &&
          double.tryParse(sendQty.toString()) != 0;
    }).toList();

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
                _buildTableHeader("In.LN", 50),
                _buildTableHeader("Inv.No", 100),
                _buildTableHeader("I.Code", 100),
                _buildTableHeader(
                    "I.Details", MediaQuery.of(context).size.width * 0.15),
                _buildTableHeader("Qty", 100),
              ],
            ),
          ),
          // Scrollable Table Body
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical, // Enable vertical scrolling
              child: Column(
                children: filteredData.map((data) {
                  String lineno = data['id'].toString();
                  String invNo = data['invoiceno'].toString();
                  String itemcode = data['itemcode'].toString();
                  String itemdetails = data['itemdetails'].toString();
                  String pickedqty = data['sendqty'].toString();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildTableRow(lineno, 50),
                        _buildTableRow(invNo, 100),
                        _buildTableRow(itemcode, 100),
                        _buildTableRow(itemdetails,
                            MediaQuery.of(context).size.width * 0.15),
                        _buildTableRow(pickedqty, 100),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Table Header Builder (Reusable)
  Widget _buildTableHeader(String title, double width) {
    return Container(
      width: width,
      height: 25,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
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
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis, // Prevent overflow
        ),
      ),
    );
  }
}
