import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import '../../Database/IpAddress.dart';
import '../../components/Responsive.dart';
import '../../components/Style.dart';

class Quick_Dispatch_Entry_Form extends StatefulWidget {
  final Function quickBilltogglePage;

  Quick_Dispatch_Entry_Form({
    super.key,
    required this.quickBilltogglePage,
  });

  @override
  State<Quick_Dispatch_Entry_Form> createState() =>
      _Quick_Dispatch_Entry_FormState();
}

class _Quick_Dispatch_Entry_FormState extends State<Quick_Dispatch_Entry_Form> {
  bool _isLoading = true;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  TextEditingController _ReqnoController = TextEditingController();
  TextEditingController _InvoiceNumberController = TextEditingController();
  TextEditingController _CustomerNameController = TextEditingController();
  TextEditingController _CustomerSiteController = TextEditingController();
  TextEditingController _CustomerNumberController = TextEditingController();
  TextEditingController _SalesmanNameController = TextEditingController();
  TextEditingController _SalesmanNoController = TextEditingController();

  List<Map<String, dynamic>> tableData = [];
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _initializeEmptyControllers();
    fetchDataReqnO();
  }

  void _initializeEmptyControllers() {
    _controllers = [];
    _focusNodes = [];
  }

  Future<void> fetchDataReqnO() async {
    if (!mounted) return;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? saleslogiOrgwarehousename =
          prefs.getString('saleslogiOrgwarehousename') ?? '';
      String? reqedid = prefs.getString('reqno');
      String? reqno = reqedid;

      if (reqno == null || reqno.isEmpty) {
        print("No reqno found in shared preferences");
        return;
      }

      final IpAddress = await getActiveIpAddress();
      String urlpathname = 'filtered_dispatchrequest';

      final response = await http.get(Uri.parse(
          '$IpAddress/$urlpathname/$reqno/$saleslogiOrgwarehousename/'));

      print("URL: $IpAddress/$urlpathname/$reqno/$saleslogiOrgwarehousename/");

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> responseData = json.decode(decodedBody);

        if (responseData.isEmpty || responseData[0] == null) {
          print("Empty or invalid response data");
          if (mounted) {
            setState(() {
              _isLoading = false;
              tableData = [];
            });
          }
          return;
        }

        final data = responseData[0];

        if (mounted) {
          setState(() {
            _ReqnoController.text = _safeToString(data['REQ_ID']);

            _SalesmanNoController.text = _safeToString(data['SALESMAN_NO']);
            _SalesmanNameController.text = _safeToString(data['SALESMAN_NAME']);
            _CustomerNumberController.text =
                _safeToString(data['CUSTOMER_NUMBER']);
            _CustomerNameController.text = _safeToString(data['CUSTOMER_NAME']);
            _CustomerSiteController.text =
                _safeToString(data['CUSTOMER_SITE_ID']);

            tableData = [];

            if (data['TABLE_DETAILS'] != null &&
                data['TABLE_DETAILS'] is List) {
              for (var item in data['TABLE_DETAILS']) {
                tableData.add({
                  'Row_id': _safeToString(item['ID']),
                  'id': _safeToString(item['LINE_NUMBER']),
                  'undel_id': (item['UNDEL_ID'] == null ||
                          item['UNDEL_ID'].toString().isEmpty)
                      ? '0'
                      : _safeToString(item['UNDEL_ID']),
                  'invoiceno': _safeToString(item['INVOICE_NUMBER']),
                  'itemcode': _safeToString(item['INVENTORY_ITEM_ID']),
                  'itemdetails': _safeToString(item['ITEM_DESCRIPTION']),
                  'customer_trx_id': _safeToString(item['CUSTOMER_TRX_ID']),
                  'customer_trx_line_id':
                      _safeToString(item['CUSTOMER_TRX_LINE_ID']),
                  'invoiceQty':
                      _safeParseDouble(item['TOT_QUANTITY']).toString(),
                  'totaldisreqqty':
                      _safeParseDouble(item['DISPATCHED_QTY']).toString(),
                  'disreqqty': _safeParseDouble(item['DISPATCHED_BY_MANAGER'])
                      .toString(),
                  'balanceqty':
                      _safeParseDouble(item['BALANCE_QTY']).toString(),
                  'sendqty': '0',
                  'dispatchqty': '0',
                  'status': 'Pending',
                  'amount': _safeParseDouble(item['AMOUNT']).toString(),
                  'item_cost': _safeParseDouble(item['ITEM_COST']).toString(),
                });
              }
              print("Table data loaded: ${tableData.length} items");
              _initializeControllers();
            }
            _isLoading = false;
          });
        }
      } else {
        print(
            'Failed to load dispatch request details: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error in fetchDataReqnO: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _safeToString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  double _safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    try {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  void _initializeControllers() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }

    _controllers = List.generate(
        tableData.length, (index) => TextEditingController(text: "0"));
    _focusNodes = List.generate(tableData.length, (index) => FocusNode());
  }

  Future<bool> saveDispatchRequest() async {
    final IpAddress = await getActiveIpAddress();
    final String apiUrl = "$IpAddress/save_dispatch_request/";

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String warehouseName = prefs.getString('saleslogiOrgwarehousename') ?? '';
    String managerNo = prefs.getString('salesloginno') ?? '';
    String managerName = prefs.getString('saveloginname') ?? '';

    String reqno = _ReqnoController.text.trim();

    try {
      List<Map<String, dynamic>> tabledatas = [];

      // ---------------------------------------------------------
      // BUILD tabledatas ARRAY
      // ---------------------------------------------------------
      for (int i = 0; i < tableData.length; i++) {
        String qtyText = _controllers[i].text.trim();
        double qtyValue = double.tryParse(qtyText) ?? 0;

        if (qtyValue <= 0) continue; // skip rows with 0 qty

        final row = tableData[i];

        tabledatas.add({
          "REQ_ID": reqno,
          "SALESMAN_NO": _SalesmanNoController.text,
          "SALESMAN_NAME": _SalesmanNameController.text.trim(),
          "CUSTOMER_NUMBER": _CustomerNumberController.text.trim(),
          "CUSTOMER_NAME": _CustomerNameController.text.trim(),
          "CUSTOMER_SITE_ID": _CustomerSiteController.text.trim(),
          "UNDEL_ID": row['undel_id'] ?? "0",
          "INVOICE_NUMBER": row['invoiceno'] ?? "",
          "INVENTORY_ITEM_ID": row['itemcode'] ?? "",
          "LINE_NUMBER": row['id']?.toString() ?? "",
          "CUSTOMER_TRX_ID": row['customer_trx_id'] ?? "",
          "CUSTOMER_TRX_LINE_ID": row['customer_trx_line_id'] ?? "",
          "ITEM_DESCRIPTION": row['itemdetails'] ?? "",
          "DISPATCHED_QTY":
              double.tryParse(row['totaldisreqqty'].toString()) ?? 0,
          "SCAN_QTY": qtyValue.toInt(),
        });
      }

      if (tabledatas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please enter a scan quantity greater than 0")),
        );
        return false;
      }

      // ---------------------------------------------------------
      // FINAL BODY TO SEND
      // ---------------------------------------------------------
      Map<String, dynamic> requestBody = {
        "REQ_ID": reqno,
        "TO_WAREHOUSE": warehouseName,
        "MANAGER_NO": managerNo,
        "MANAGER_NAME": managerName,
        "tabledatas": tabledatas,
      };

      print("📤 Sending Body:");
      // print(const JsonEncoder.withIndent('  ').convert(requestBody));

      // ---------------------------------------------------------
      // API CALL
      // ---------------------------------------------------------
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("📥 API Response (${response.statusCode}): ");

      // ---------------------------------------------------------
      // SUCCESS RESPONSE HANDLING
      // ---------------------------------------------------------
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == "success" && data["req_no"] != null) {
          String req = data["req_no"].toString();
          String pick = data["pick_id"].toString();
          String pickQty = data["pick_qty"].toString();

          widget.quickBilltogglePage(
            req,
            pick,
            _CustomerNumberController.text.trim(),
            _CustomerNameController.text.trim(),
            _CustomerSiteController.text.trim(),
            pickQty,
          );

          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Unknown response")),
          );
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error ${response.statusCode}: ${response.body}")),
        );
        return false;
      }
    } catch (e) {
      print("❌ Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exception: $e")),
      );
      return false;
    }
  }

// Function to handle Request for Delivery button press
  Future<void> _onRequestForDelivery() async {
    // Print all table data with qty picking values
    print("=== REQUEST FOR DELIVERY DATA ===");
    print("Req ID: ${_ReqnoController.text}");
    print("Invoice Number: ${_InvoiceNumberController.text}");
    print("Customer Number: ${_CustomerNumberController.text}");
    print("Customer Name: ${_CustomerNameController.text}");
    print("=== ITEMS WITH QTY PICKING ===");

    // First validate if any quantity is entered
    bool hasValidQuantity = false;
    for (int i = 0; i < tableData.length; i++) {
      String qtyPicking = _controllers[i].text;
      double qtyValue = double.tryParse(qtyPicking) ?? 0;

      if (qtyValue > 0) {
        hasValidQuantity = true;
        // print("Item ${i + 1}:");
        // print("  - Undel ID: ${tableData[i]['undel_id']}");
        // print("  - Invoice No: ${tableData[i]['invoiceno']}");
        // print("  - Line No: ${tableData[i]['id']}");
        // print("  - Item Code: ${tableData[i]['itemcode']}");
        // print("  - Item Description: ${tableData[i]['itemdetails']}");
        // print("  - Qty Picking: $qtyPicking");
        // print("  - Dispatch Qty: ${tableData[i]['disreqqty']}");
        // print("  ---");
      }
    }

    if (!hasValidQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Error: Please enter quantity greater than 0 for at least one item")),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Submitting request..."),
              ],
            ),
          ),
        );
      },
    );

    // Call the save function
    bool success = await saveDispatchRequest();

    // Close loading dialog
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          icon: Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red,
            size: 48,
          ),
          title: Text(
            success ? "Request Submitted" : "Request Failed",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: success ? Colors.green : Colors.red,
            ),
          ),
          content: Text(
            success
                ? "Delivery request has been submitted successfully!"
                : "Failed to submit delivery request. Please try again.",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (success) {
                  Navigator.pop(
                      context); // Close the current screen if successful
                }

                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: success ? Colors.green : Colors.red,
              ),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();

    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [
          // HEADER
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Quick Dispatch Entry",
                  style: HeadingStyle,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close, color: Colors.black, size: 22),
                ),
              ],
            ),
          ),

          // INFORMATION FIELDS
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildInfoField("Req ID", _ReqnoController, 120),
                    SizedBox(width: 15),
                    _buildInfoField(
                        "Customer No", _CustomerNumberController, 120),
                    SizedBox(width: 15),
                    _buildInfoField(
                        "Customer Name", _CustomerNameController, 250),
                  ],
                ),
              ],
            ),
          ),

          // BODY - TABLE
          Expanded(
            child: _buildTable(),
          ),

          // REQUEST FOR DELIVERY BUTTON
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: _onRequestForDelivery,
                    icon: Icon(Icons.local_shipping, size: 20),
                    label: Text("Request for Delivery",
                        style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(
      String label, TextEditingController controller, double width) {
    return Container(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 4),
          Container(
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: TextField(
                controller: controller,
                readOnly: true,
                textAlign: TextAlign.center, // Center align text
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  isDense: true,
                ),
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isChecked = false;

  String _removeDecimalIf(dynamic value) {
    if (value is double) {
      return value.truncate().toString();
    } else if (value is String) {
      double? parsedValue = double.tryParse(value);
      if (parsedValue != null) {
        return parsedValue.truncate().toString();
      }
      return value;
    }
    return value.toString();
  }

  List<double> columnWidths = [100, 80, 120, 450, 130, 120, 140, 100];

  Widget _buildTable() {
    isChecked = false;

    double screenHeight = MediaQuery.of(context).size.height;
    double widthFactor = Responsive.isDesktop(context) ? 0.79 : 1.7;
    double heightFactor =
        Responsive.isDesktop(context) ? screenHeight * 0.3 : 250;
    double rowHeight = Responsive.isDesktop(context) ? 25 : 30;

    List<Map<String, dynamic>> headers = [
      {"icon": Icons.receipt_long, "text": "Invoice.No"},
      {"icon": Icons.format_list_numbered, "text": "I.lineNo"},
      {"icon": Icons.qr_code, "text": "Item Code"},
      {"icon": Icons.info_outline, "text": "Item Description"},
      {"icon": Icons.inventory, "text": "Qty.Invoiced"},
      {"icon": Icons.add_shopping_cart, "text": "Qty.Req"},
      {"icon": Icons.local_shipping, "text": "Qty.Picking"},
      {"icon": Icons.verified, "text": "Status"},
    ];

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
                children: [
                  Container(
                    height: heightFactor,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[400]!, width: 1.0),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: headers.map((header) {
                                return Container(
                                  height: rowHeight,
                                  width: columnWidths[headers
                                      .indexOf(header)], // Use fixed widths
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    border:
                                        Border.all(color: Colors.grey[400]!),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(header['icon'],
                                            size: 15, color: Colors.blue),
                                        SizedBox(width: 2),
                                        Expanded(
                                          child: Text(header['text'],
                                              style: commonLabelTextStyle,
                                              textAlign: TextAlign.center),
                                        ),
                                        if (header['text'] == "Qty.Picking")
                                          StatefulBuilder(builder:
                                              (BuildContext context,
                                                  StateSetter setState) {
                                            return Tooltip(
                                              message: "Select All",
                                              child: Transform.scale(
                                                scale:
                                                    0.6, // Adjust the scale factor to make the checkbox smaller
                                                child: Checkbox(
                                                  value: isChecked,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      isChecked =
                                                          value!; // Update the state
                                                      for (int i = 0;
                                                          i < tableData.length;
                                                          i++) {
                                                        double disreqQty = double.tryParse(
                                                                _removeDecimalIf(
                                                                    tableData[i]
                                                                        [
                                                                        'disreqqty'])) ??
                                                            0.0;
                                                        if (isChecked) {
                                                          _controllers[i].text =
                                                              disreqQty
                                                                  .toString();
                                                          tableData[i]
                                                                  ['sendqty'] =
                                                              disreqQty
                                                                  .toString(); // Update sendqty
                                                        } else {
                                                          _controllers[i].text =
                                                              ""; // Clear text
                                                          tableData[i]
                                                                  ['sendqty'] =
                                                              ""; // Clear sendqty if unchecked
                                                        }
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                            );
                                          })
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          if (_isLoading)
                            Padding(
                              padding: const EdgeInsets.only(top: 60.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (tableData.isNotEmpty)
                            ...tableData.asMap().entries.map((entry) {
                              int index = entry.key;
                              var data = entry.value;
                              return _buildRow(index, data);
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
          ),
        ),
      ]),
    );
  }

  Widget _buildRow(int index, Map<String, dynamic> data) {
    bool isEvenRow = index % 2 == 0;
    Color? rowColor = Color.fromARGB(224, 255, 255, 255);

    if (double.parse(data['disreqqty'] ?? '0') == 0) {
      return SizedBox.shrink(); // Return an empty widget if quantity is 0
    }

    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildDataCell(data['invoiceno'] ?? '', rowColor,
                width: columnWidths[0]),
            _buildDataCell(data['id'] ?? '', rowColor, width: columnWidths[1]),
            _buildDataCell(data['itemcode'] ?? '', rowColor,
                width: columnWidths[2]),
            _buildDataCell(data['itemdetails'] ?? '', rowColor,
                width: columnWidths[3]),
            _buildDataCell(data['invoiceQty'] ?? '', rowColor,
                width: columnWidths[4]),
            _buildReqQtyCell(data, rowColor, width: columnWidths[5]),
            _buildTextFieldCell(index, data['disreqqty'] ?? '', rowColor,
                width: columnWidths[6]),
            _buildDataCell(data['status'], rowColor, width: columnWidths[7]),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, Color rowColor, {double width = 100}) {
    return Container(
      height: 30,
      width: width,
      decoration: BoxDecoration(
        color: rowColor,
        border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
      ),
      child: Center(
        // Center the content
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: SelectableText(
            text,
            style: commonLabelTextStyle.copyWith(fontSize: 11),
            showCursor: false,
            cursorColor: Colors.blue,
            cursorWidth: 2.0,
            toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
            textAlign: TextAlign.center, // Center align text
          ),
        ),
      ),
    );
  }

  Widget _buildReqQtyCell(Map<String, dynamic> data, Color rowColor,
      {double width = 100}) {
    return Container(
      width: width,
      height: 30,
      decoration: BoxDecoration(
        color: rowColor,
        border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
      ),
      child: Center(
        // Center the content
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Tooltip(
                message: "Total Dispatch Request Qty",
                child: Text(
                  data['totaldisreqqty'].toString(),
                  textAlign: TextAlign.center, // Center align text
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 128, 34),
                    fontSize: 11,
                  ),
                ),
              ),
              SizedBox(width: 5),
              Text(
                "-",
                textAlign: TextAlign.center, // Center align text
                style: TableRowTextStyle.copyWith(fontSize: 11),
              ),
              SizedBox(width: 5),
              Tooltip(
                message: "Pending Dispatch",
                child: Text(
                  data['disreqqty'].toString(),
                  textAlign: TextAlign.center, // Center align text
                  style: TextStyle(
                    color: Color.fromARGB(255, 147, 0, 0),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldCell(int index, String disreqqty, Color rowColor,
      {double width = 100}) {
    return Container(
      width: width,
      height: 30,
      decoration: BoxDecoration(
        color: rowColor,
        border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: TextField(
            controller: index < _controllers.length
                ? _controllers[index]
                : TextEditingController(),
            focusNode:
                index < _focusNodes.length ? _focusNodes[index] : FocusNode(),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              if (!mounted) return;

              double enteredQty = double.tryParse(value) ?? 0.0;
              double balanceQtyDouble = double.tryParse(disreqqty) ?? 0.0;

              if (enteredQty > balanceQtyDouble) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      backgroundColor: Colors.white,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning, color: Colors.yellow),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'You have entered a quantity that exceeds the Dispatch Request quantity. The quantity will be adjusted to ${_controllers[index].text}. Do you want to proceed?',
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    child: Text('Yes'),
                                    onPressed: () {
                                      if (mounted) {
                                        setState(() {
                                          _controllers[index].text =
                                              disreqqty.toString();
                                          tableData[index]['sendqty'] =
                                              disreqqty.toString();
                                        });
                                      }
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  TextButton(
                                    child: Text('No'),
                                    onPressed: () {
                                      if (mounted) {
                                        setState(() {
                                          _controllers[index].text = "0";
                                          tableData[index]['sendqty'] = "0";
                                        });
                                      }
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                if (mounted) {
                  setState(() {
                    tableData[index]['sendqty'] = value;
                  });
                }
              }
            },
            textAlign: TextAlign.center, // Center align text
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            style: TextStyle(fontSize: 11),
          ),
        ),
      ),
    );
  }
}
