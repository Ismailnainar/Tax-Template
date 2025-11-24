import 'dart:typed_data'; // for Uint8List
import 'dart:io'; // for File
import 'package:aljeflutterapp/components/constaints.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';

class ReturnDispatch extends StatefulWidget {
  final Function togglePage;

  ReturnDispatch(this.togglePage);

  @override
  State<ReturnDispatch> createState() => _ReturnDispatchState();
}

class _ReturnDispatchState extends State<ReturnDispatch> {
  bool _isLoading = true;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  Widget _buildTextFieldDesktop(
    String label,
    String value,
    IconData icon,
    bool readOnly,
  ) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: Responsive.isDesktop(context)
          ? screenWidth * 0.14
          : screenWidth * 0.4,
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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 0, bottom: 0),
              child: Row(
                children: [
                  Container(
                      height: 37,
                      width: Responsive.isDesktop(context)
                          ? screenWidth * 0.14
                          : screenWidth * 0.4,
                      child: MouseRegion(
                        onEnter: (event) {},
                        onExit: (event) {},
                        cursor: SystemMouseCursors.click,
                        child: Tooltip(
                          message: value,
                          child: TextField(
                              readOnly: readOnly,
                              decoration: InputDecoration(
                                // hintText: label,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                filled: true,
                                fillColor: Color.fromARGB(255, 255, 255, 255),
                              ),
                              controller: TextEditingController(text: value),
                              style: textBoxstyle),
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

  List<Map<String, dynamic>> getTableData = [];

  TextEditingController DispatchIdController = TextEditingController(text: "");

  Future<void> fetchDisIdDetails(String DisId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';
    try {
      final IpAddress = await getActiveIpAddress();

      final response = await http
          .get(Uri.parse('$IpAddress/Filtered_ReturnDispatch/$DisId/'));
      // print('Response body: ${response.body}');
      print("urllllllllllllll  $IpAddress/Filtered_ReturnDispatch/$DisId/");

      if (response.body == null || response.body.isEmpty) {
        ShowWarning('No data received from the server.');
        return;
      }

      var data;
      try {
        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
        data = json.decode(decodedBody);
        // print('response.body${response.body}');
      } catch (e) {
        ShowWarning('Failed to decode response: $e');
        print('Failed to decode response: $e');
        return;
      }

      if (data == null || data.isEmpty) {
        ShowWarning('Kindly enter a correct Req No.');
        return;
      }

      if (data is List) {
        List<Map<String, dynamic>> picklist =
            List<Map<String, dynamic>>.from(data);
        if (picklist.isNotEmpty) {
          var pickdetails = picklist[0];
          // print('Dispatch details fetched successfully: $pickdetails');
          // Check if ORG_ID matches saleslogiOrgid
          String orgId = pickdetails['ORG_ID']?.toString() ?? '';
          if (orgId != saleslogiOrgid) {
            // Show dialog box if ORG_ID does not match
            await showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Invalid Warehouse'),
                  content: Text(
                      'This Pick ID is not associated with your warehouse details.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          DispatchIdController.text = '';
                        });
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

          setState(() {
            _ReqnoController.text = pickdetails['REQ_ID']?.toString() ?? '';
            _WarehousenameNameController.text =
                pickdetails['PHYSICAL_WAREHOUSE']?.toString() ?? '';

            _CustomerNameController.text =
                pickdetails['CUSTOMER_NAME']?.toString() ?? '';
            _CussiteController.text =
                pickdetails['CUSTOMER_SITE_ID']?.toString() ?? '';
            _CusidController.text =
                pickdetails['CUSTOMER_NUMBER']?.toString() ?? '';

            _RegionController.text = pickdetails['ORG_NAME']?.toString() ?? '';

            _Salesman_idmeController.text =
                pickdetails['SALESMAN_NO']?.toString() ?? '';
            getTableData = List<Map<String, dynamic>>.from(
                pickdetails['TABLE_DETAILS'] ?? []);
            _updatesendqty();
            // print(getTableData);

            // Printing all details
            print("REQ_ID: ${_ReqnoController.text}");
            print("PHYSICAL_WAREHOUSE: ${_WarehousenameNameController.text}");
            print("CUSTOMER_NAME: ${_CustomerNameController.text}");
            print("CUSTOMER_SITE_ID: ${_CussiteController.text}");
            print("CUSTOMER_NUMBER: ${_CusidController.text}");
            print("ORG_NAME: ${_RegionController.text}");
            print("SALESMAN_NO: ${_Salesman_idmeController.text}");
            print("TABLE_DETAILS: ${getTableData}");
          });
        } else {
          ShowWarning('No details found for the provided DisId.');
        }
      } else {
        ShowWarning('Unexpected data format received from the server.');
        print('Unexpected data format received');
      }
    } catch (e) {
      ShowWarning('An error occurred: $e');
      print('An error occurred: $e');
    }
  }

  void ShowWarning(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.yellow),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(fontSize: 13, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> tableData = [];

  @override
  void initState() {
    super.initState();
    _loadSalesmanName();
    // Initialize controllers and focus nodes for each row
    tableData.forEach((row) {
      _controllers.add(TextEditingController(text: "0"));
      _focusNodes.add(FocusNode());
    });
    // clearallcontroller();
    postLogData("Receviced", "Opened");
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    // Dispose of controllers, focus nodes, and cancel the timer
    _controllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((focusNode) => focusNode.dispose());

    postLogData("Receviced", "Closed");
    super.dispose();
  }

  List<String> AssignedstaffList = [];

  bool isLoading = true;

  clearallcontroller() {
    setState(() {
      DispatchIdController.text = "";
      _ReqnoController.text = "";
      _WarehousenameNameController.clear();
      _RegionController.clear();
      _CustomerNameController.clear();
      _CusidController.clear();
      _CussiteController.clear();
      getTableData.clear();
      _AssignedStaffController.clear();
      totalSendqtyController.text = '0';
    });
  }

  Future<void> fetchStaffList() async {
    final IpAddress = await getActiveIpAddress();

    final String initialUrl = '$IpAddress/User_member_details/';
    String? nextPageUrl = initialUrl;

    try {
      List<String> tempPickmanNames = [];

      while (nextPageUrl != null) {
        var response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          if (data['results'] != null && data['results'].isNotEmpty) {
            for (var result in data['results']) {
              // Check if the role is 'pickman' before adding the name
              if (result['name'] != null && result['role'] == 'pickman') {
                tempPickmanNames.add(result['name']);
              }
            }
          }

          // Check for the next page
          nextPageUrl = data['next'];
        } else {
          print('Error: ${response.statusCode}');
          break;
        }
      }

      setState(() {
        AssignedstaffList = tempPickmanNames;
        isLoading = false;
        print("Pickman list: $AssignedstaffList");
      });
    } catch (e) {
      print('Error fetching pickman names: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String? assignedstaffselectedValue;
  bool _filterEnabledassignedstaff = true;
  int? _hoveredIndexAssignedStaff;
  int? _selectedIndexAssignedStaff;
  TextEditingController _AssignedStaffController = TextEditingController();

  Widget _buildAssignedStaffDropdown() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Row(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Container(
                    height: 30,
                    width: Responsive.isDesktop(context)
                        ? screenWidth * 0.13
                        : screenWidth * 0.3,
                    child: AssignedStaffDropdown()),
              ],
            ),
          ),
          SizedBox(width: 3),
        ],
      ),
    );
  }

  Widget AssignedStaffDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                AssignedstaffList.indexOf(_AssignedStaffController.text);
            if (currentIndex < AssignedstaffList.length - 1) {
              setState(() {
                _selectedIndexAssignedStaff = currentIndex + 1;
                _AssignedStaffController.text =
                    AssignedstaffList[currentIndex + 1];
                _filterEnabledassignedstaff = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                AssignedstaffList.indexOf(_AssignedStaffController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndexAssignedStaff = currentIndex - 1;
                _AssignedStaffController.text =
                    AssignedstaffList[currentIndex - 1];
                _filterEnabledassignedstaff = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          enabled: false,
          controller: _AssignedStaffController,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(201, 132, 132, 132),
                width: 1.0,
              ),
            ),
            prefixIcon: Icon(
              Icons.house_siding,
              size: 12,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(255, 58, 58, 58),
                width: 1.0,
              ),
            ),
            filled: true, // Enable the background fill
            fillColor: Color.fromARGB(
                255, 250, 250, 250), // Set the background color to grey[200]
            contentPadding: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 10.0,
            ),
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            ),
          ),
          style: textBoxstyle,
          onChanged: (text) {
            setState(() {
              _filterEnabledassignedstaff = true;
              assignedstaffselectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabledassignedstaff && pattern.isNotEmpty) {
            return AssignedstaffList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return AssignedstaffList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = AssignedstaffList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndexAssignedStaff = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndexAssignedStaff = null;
            }),
            child: Container(
              color: _selectedIndexAssignedStaff == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndexAssignedStaff == null &&
                          AssignedstaffList.indexOf(
                                  _AssignedStaffController.text) ==
                              index
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.transparent,
              height: 30,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                dense: true,
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    suggestion,
                    style: DropdownTextStyle,
                  ),
                ),
              ),
            ),
          );
        },
        suggestionsBoxDecoration: const SuggestionsBoxDecoration(
          constraints: BoxConstraints(maxHeight: 150),
        ),
        onSuggestionSelected: (suggestion) {
          setState(() {
            _AssignedStaffController.text = suggestion;
            assignedstaffselectedValue = suggestion;
            _filterEnabledassignedstaff = false;
          });
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: DropdownTextStyle,
          ),
        ),
      ),
    );
  }

  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];

// Method to initialize TextEditingControllers and FocusNodes based on tableData size
  void _initializeControllers() {
    _controllers =
        List.generate(tableData.length, (index) => TextEditingController());
    _focusNodes = List.generate(tableData.length, (index) => FocusNode());
  }

  bool isChecked = false;
  String _removeDecimalIf(dynamic value) {
    if (value is double) {
      return value
          .truncate()
          .toString(); // Convert to int if it's a whole number
    } else if (value is String) {
      double? parsedValue = double.tryParse(value);
      if (parsedValue != null) {
        return parsedValue
            .truncate()
            .toString(); // Handle string representation of double
      }
      return value; // Return the original string if not a valid number
    }
    return value.toString(); // Fallback for other types
  }

  List<double> columnWidths = [
    150,
    130,
    150,
    480,
    140,
  ];

  Widget _buildTable() {
    double screenHeight = MediaQuery.of(context).size.height;
    double widthFactor = Responsive.isDesktop(context) ? 0.79 : 1.7;
    double heightFactor =
        Responsive.isDesktop(context) ? screenHeight * 0.3 : 250;
    double rowHeight = Responsive.isDesktop(context) ? 25 : 30;

    List<Map<String, dynamic>> headers = [
      {"icon": Icons.receipt_long, "text": "Invoice.No"},
      // {"icon": Icons.receipt_long, "text": "Customer.Trn.Id"},
      // {"icon": Icons.format_list_numbered, "text": "Customer.Trn.LineId"},
      {"icon": Icons.format_list_numbered, "text": "Invoi.lineNo"},
      {"icon": Icons.qr_code, "text": "Item Code"},
      {"icon": Icons.info_outline, "text": "Item Description"},
      {"icon": Icons.inventory, "text": "Qty.Dispatched"},
    ];

    Map<String, Map<String, dynamic>> groupedData = {};
    for (var row in getTableData) {
      String invoiceno = row['INVOICE_NO'].toString();
      String itemCode = row['ITEM_CODE'].toString();
      String bothfilteres =
          '$invoiceno|$itemCode'; // unique key using invoice and item code

      if (!groupedData.containsKey(bothfilteres)) {
        groupedData[bothfilteres] = {
          'INVOICE_NO': row['INVOICE_NO'],
          'LINE_NO': row['LINE_NO'],
          'ITEM_CODE': row['ITEM_CODE'],
          'ITEM_DETAILS': row['ITEM_DETAILS'],
          'TRUCK_SEND_QTY': row['TRUCK_SEND_QTY']
        };
      } else {
        groupedData[bothfilteres]?['TRUCK_SEND_QTY'] += row['TRUCK_SEND_QTY'];
      }
    }

    List<Map<String, dynamic>> groupedTableData = groupedData.values.toList();

    return Container(
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
                // width: MediaQuery.of(context).size.width * widthFactor,
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
                              width: columnWidths[
                                  headers.indexOf(header)], // Use fixed widths
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.grey[400]!),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(header['icon'],
                                            size: 15, color: Colors.blue),
                                        SizedBox(width: 2),
                                        Text(header['text'],
                                            style: commonLabelTextStyle,
                                            textAlign: TextAlign.center),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      if (groupedTableData.isNotEmpty)
                        ...groupedTableData.asMap().entries.map((entry) {
                          int index = entry.key;
                          var data = entry.value;
                          return _buildRow(index, data);
                        }).toList()
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: 60.0),
                          child: Text("Kindly enter a DisId to view details.."),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(int index, Map<String, dynamic> data) {
    bool isEvenRow = index % 2 == 0;
    Color? rowColor = Color.fromARGB(224, 255, 255, 255);

    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildDataCell(data['INVOICE_NO']?.toString() ?? '', rowColor,
                width: columnWidths[0]),
            // _buildDataCell(data['CUSTOMER_TRX_ID']?.toString() ?? '', rowColor,
            //     width: columnWidths[1]),
            // _buildDataCell(
            //     data['CUSTOMER_TRX_LINE_ID']?.toString() ?? '', rowColor,
            //     width: columnWidths[2]),
            _buildDataCell(data['LINE_NO']?.toString() ?? '', rowColor,
                width: columnWidths[1]),
            _buildDataCell(data['ITEM_CODE']?.toString() ?? '', rowColor,
                width: columnWidths[2]),
            _buildDataCell(data['ITEM_DETAILS']?.toString() ?? '', rowColor,
                width: columnWidths[3]),
            _buildDataCell(data['TRUCK_SEND_QTY']?.toString() ?? '', rowColor,
                width: columnWidths[4]),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, Color rowColor, {double width = 100}) {
    return Container(
      height: 30,
      width: width, // Ensure the width matches the header width
      decoration: BoxDecoration(
        color: rowColor,
        border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
    );
  }

  TextEditingController totalSendqtyController =
      TextEditingController(text: '0');

  void _updatesendqty() {
    setState(() {
      double totalAmount =
          gettotaldisreqamt(getTableData); // Get the total amount
      totalSendqtyController.text =
          _removeDecimalIfWholeReqQty(totalAmount.toString()); // Ensure string
    });
    print("totaldisreqController amountttt ${totalSendqtyController.text}");
  }

  String _removeDecimalIfWholeReqQty(String value) {
    if (value.contains('.') && value.split('.').last == '0') {
      return value.split('.').first; // Remove decimal part if it is .0
    }
    return value;
  }

  double gettotaldisreqamt(List<Map<String, dynamic>> getTableData) {
    double totalQuantity = 0.0;
    for (var data in getTableData) {
      // Check the type of the value and ensure it's a string for parsing
      var dispatchedByManager = data['TRUCK_SEND_QTY'].toString();

      double quantity = double.tryParse(dispatchedByManager) ?? 0.0;
      totalQuantity += quantity;
    }
    return totalQuantity;
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

  String? saveloginname = '';

  String? saveloginrole = '';

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
      saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
    });
  }

  TextEditingController _ReqnoController = TextEditingController();
  TextEditingController _CusidController = TextEditingController();
  TextEditingController _CussiteController = TextEditingController();
  TextEditingController _CustomerNameController = TextEditingController();
  TextEditingController _RegionController = TextEditingController();
  TextEditingController _WarehousenameNameController = TextEditingController();
  TextEditingController _Salesman_idmeController = TextEditingController();
  TextEditingController Salesman_channelController = TextEditingController();
  TextEditingController IdController = TextEditingController();

  bool previewbutton = true;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: screenheight,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                // Heading

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
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.grey.withOpacity(0.2), // Shadow color
                        //     spreadRadius: 2, // Spread radius of shadow
                        //     blurRadius: 8, // Blur radius of shadow
                        //     offset: Offset(0, 2), // Offset of shadow
                        //   ),
                        // ],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MainSidebar(
                                        enabledItems: accessControl,
                                        initialPageIndex: 2),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Icon(
                                    Icons.assignment_return,
                                    size: 28,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Receviced Dispatch',
                                      style: TextStyle(
                                        // fontFamily: 'Chrusty',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                                                255, 84, 84, 84)),
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
                                // SizedBox(
                                //   width: 30,
                                // ),
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
                    height: screenheight * 0.89,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: Responsive.isDesktop(context) ? 30 : 10,
                                bottom: 30),
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              runSpacing: 2,
                              children: [
                                Container(
                                  width: Responsive.isDesktop(context)
                                      ? screenWidth * 0.110
                                      : screenWidth * 0.4,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 20),
                                        const Row(
                                          children: [
                                            Text('Delivery ID',
                                                style: textboxheading),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 0, bottom: 0),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 37,
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? screenWidth * 0.110
                                                    : screenWidth * 0.4,
                                                child: MouseRegion(
                                                  cursor: SystemMouseCursors
                                                      .click, // Changes the cursor to indicate interaction

                                                  child: TextFormField(
                                                    controller:
                                                        DispatchIdController,
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
                                                          255, 255, 255, 255),
                                                    ),
                                                    style: textBoxstyle,
                                                    onFieldSubmitted: (value) {
                                                      print(
                                                          'DispatchIdController: ${DispatchIdController.text}');

                                                      if (DispatchIdController
                                                          .text.isNotEmpty) {
                                                        // Text is present, proceed with API call and logic
                                                        fetchDisIdDetails(
                                                            DispatchIdController
                                                                .text);
                                                        _updatesendqty();
                                                      } else {
                                                        // Text is empty, show warning
                                                        ShowWarning(
                                                            'Kindly enter a Disp_ID');
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Padding(
                                  padding: Responsive.isDesktop(context)
                                      ? EdgeInsets.only(top: 45)
                                      : EdgeInsets.only(top: 48),
                                  child: Container(
                                    width:
                                        40, // Adjust width to match the input field
                                    height:
                                        37, // Increase height for proper alignment

                                    color: buttonColor,

                                    child: IconButton(
                                      onPressed: () {
                                        // // Get the text entered in the controller
                                        // String? value =
                                        //     DispatchIdController.text;

                                        // // Extract the first number from the value
                                        // String? disid =
                                        //     RegExp(r'\d+').stringMatch(value);
                                        print(
                                            'DispatchIdController: ${DispatchIdController.text}');

                                        if (DispatchIdController
                                            .text.isNotEmpty) {
                                          // Text is present, proceed with API call and logic
                                          fetchDisIdDetails(
                                              DispatchIdController.text);
                                          _updatesendqty();
                                        } else {
                                          // Text is empty, show warning
                                          ShowWarning('Kindly enter a Disp_ID');
                                        }
                                        postLogData("Receviced", "Search");
                                      },
                                      icon: Icon(
                                        Icons.search,
                                        size:
                                            20, // Adjust icon size to fit properly
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                _buildTextFieldDesktop(
                                    'Dis.Req No',
                                    "${_ReqnoController.text}",
                                    Icons.request_page,
                                    true),
                                SizedBox(
                                  width: 10,
                                ),
                                _buildTextFieldDesktop(
                                    'Physical Warehouse',
                                    _WarehousenameNameController.text,
                                    Icons.warehouse,
                                    true),
                                SizedBox(
                                  width: 10,
                                ),
                                _buildTextFieldDesktop(
                                    'Region',
                                    _RegionController.text,
                                    Icons.location_city,
                                    true),
                                SizedBox(
                                  width: 10,
                                ),
                                _buildTextFieldDesktop(
                                    'Customer No',
                                    _CusidController.text,
                                    Icons.no_accounts,
                                    true),
                                SizedBox(
                                  width: 10,
                                ),
                                _buildTextFieldDesktop(
                                    'Customer Name',
                                    _CustomerNameController.text,
                                    Icons.perm_identity,
                                    true),
                                SizedBox(
                                  width: 10,
                                ),
                                _buildTextFieldDesktop(
                                    'Customer Site',
                                    _CussiteController.text,
                                    Icons.sixteen_mp_outlined,
                                    true),
                              ],
                            ),
                          ),
                          if (Responsive.isDesktop(context))
                            SizedBox(
                              height: 5,
                            ),
                          if (Responsive.isDesktop(context))
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 0, left: 35, right: 35),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Dispatch Items:',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueGrey[700]),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '* Total Dispatch Request',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 23, 122, 5)),
                                              ),
                                              Text(
                                                '* Pending Dispatch Request',
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
                                  SizedBox(height: 10),
                                  Container(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: _buildTable(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (!Responsive.isDesktop(context))
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 5,
                                  left: Responsive.isDesktop(context) ? 35 : 10,
                                  right:
                                      Responsive.isDesktop(context) ? 35 : 10),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text("Picked Items",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Container(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: _buildTable(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.03),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: Responsive.isDesktop(context)
                                          ? EdgeInsets.only(top: 50)
                                          : EdgeInsets.all(0),
                                      child: Container(
                                        decoration:
                                            BoxDecoration(color: buttonColor),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            minimumSize: const Size(45.0, 20.0),
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4,
                                                bottom: 4,
                                                left: 0,
                                                right: 0),
                                            child: const Text(
                                              'Return',
                                              style: commonWhiteStyle,
                                            ),
                                          ),
                                          // onPressed: () {
                                          //   String? value =
                                          //       DispatchIdController.text;

                                          //   // Extract the first number from the value
                                          //   String? disid = RegExp(r'\d+')
                                          //       .stringMatch(value);

                                          //   // Check if pickNo is not null and not empty
                                          //   if (disid != null &&
                                          //       disid.isNotEmpty) {
                                          //     // Set the controller text to the desired format "disid"
                                          //     DispatchIdController.text =
                                          //         'DisId_$disid';

                                          //     showDialog(
                                          onPressed: () {
                                            String? value =
                                                DispatchIdController.text;

                                            postLogData("Receviced Pop-up View",
                                                "Opened");
                                            // Check if DispatchIdController.text is empty
                                            if (value.isEmpty) {
                                              // Show warning if the field is empty
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: const Text(
                                                      'Please fill all required fields.'),
                                                  backgroundColor: Colors.red,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  duration: const Duration(
                                                      seconds: 2),
                                                ),
                                              );
                                              return; // Exit early
                                            }

                                            // Extract the first number from the value
                                            String? disid =
                                                DispatchIdController.text;

                                            // Check if disid is null, empty, or if `getabledata` is empty
                                            if (disid == null ||
                                                disid.isEmpty ||
                                                getTableData.isEmpty) {
                                              // Show warning if required fields are not properly filled

                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    content: Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .check_box_rounded,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    223,
                                                                    196,
                                                                    18)),
                                                        const SizedBox(
                                                            width: 10),
                                                        Expanded(
                                                          child: Text(
                                                            'Kindly Fill all the feilds.',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        2.0),
                                                          ),
                                                          backgroundColor:
                                                              subcolor,
                                                          minimumSize:
                                                              Size(30.0, 28.0),
                                                        ),
                                                        child: Text(
                                                          'Ok',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                              // ScaffoldMessenger.of(context)
                                              //     .showSnackBar(
                                              //   SnackBar(
                                              //     content: const Text(
                                              //         'Please fill all required fields.'),
                                              //     backgroundColor: Colors.red,
                                              //     behavior:
                                              //         SnackBarBehavior.floating,
                                              //     duration: const Duration(
                                              //         seconds: 2),
                                              //   ),
                                              // );
                                              return; // Exit early
                                            }

                                            // Set the controller text to the desired format "DisId_X"

                                            // Show the dialog
                                            showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Container(
                                                    color: Colors.grey[100],
                                                    height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height *
                                                        0.8, // Adjust height
                                                    width: Responsive.isMobile(
                                                            context)
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.8
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6, // Adjust width
                                                    child: ReturnDialog(
                                                      togglePage:
                                                          widget.togglePage,
                                                      disid:
                                                          DispatchIdController
                                                              .text,
                                                      onClear:
                                                          clearallcontroller, // Pass the clear function
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },

                                          //       barrierDismissible: false,
                                          //       context: context,
                                          //       builder:
                                          //           (BuildContext context) {
                                          //         return Dialog(
                                          //           shape:
                                          //               RoundedRectangleBorder(
                                          //             borderRadius:
                                          //                 BorderRadius.circular(
                                          //                     12),
                                          //           ),
                                          //           child: Container(
                                          //             color: Colors.grey[100],
                                          //             height: MediaQuery.of(
                                          //                         context)
                                          //                     .size
                                          //                     .height *
                                          //                 0.8, // Adjust height as needed
                                          //             width: MediaQuery.of(
                                          //                         context)
                                          //                     .size
                                          //                     .width *
                                          //                 0.6, // Adjust width as needed
                                          //             child: ReturnDialog(
                                          //               disid: disid,
                                          //               onClear:
                                          //                   clearallcontroller,
                                          //             ),
                                          //           ),
                                          //         );
                                          //       },
                                          //     );
                                          //   }
                                          // },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Right Side - Total Send Qty Section
                              Padding(
                                padding: EdgeInsets.only(
                                    right: Responsive.isDesktop(context)
                                        ? MediaQuery.of(context).size.width *
                                            0.03
                                        : MediaQuery.of(context).size.width *
                                            0.05),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.10
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.35,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 20),
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  children: const [
                                                    Text("Total Picking Qty",
                                                        style: textboxheading),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0, bottom: 0),
                                                child: Container(
                                                  height: 30,
                                                  width: Responsive.isDesktop(
                                                          context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.09
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.3,
                                                  child: TextField(
                                                      onChanged: (text) {
                                                        _updatesendqty();
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                Color.fromARGB(
                                                                    201,
                                                                    132,
                                                                    132,
                                                                    132),
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    58,
                                                                    58,
                                                                    58),
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        filled: true,
                                                        fillColor:
                                                            Color.fromARGB(255,
                                                                250, 250, 250),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          vertical: 5.0,
                                                          horizontal: 10.0,
                                                        ),
                                                      ),
                                                      controller:
                                                          totalSendqtyController,
                                                      style: textBoxstyle),
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
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // clearallcontroller() {
  //   // _PicknoController.clear();
  //   _ReqnoController.clear();
  //   _WarehousenameNameController.clear();
  //   _RegionController.clear();
  //   _CustomerNameController.clear();
  //   _CusidController.clear();
  //   _CussiteController.clear();
  //   tableData.clear();
  //   _AssignedStaffController.clear();
  //   SharedPrefs.clearreqnoAll();
  // }
}

class ReturnDialog extends StatefulWidget {
  final Function togglePage;
  final String disid;
  final VoidCallback onClear;

  ReturnDialog(
      {required this.togglePage, required this.disid, required this.onClear});

  @override
  State<ReturnDialog> createState() => _ReturnDialogState();
}

class _ReturnDialogState extends State<ReturnDialog> {
  @override
  void initState() {
    super.initState();
    fetchWarehouseDetails();
    fetchAccessControl();
    fetchLastReturnNo();
    fetchDispatchDetails(widget.disid);
  }

  @override
  void dispose() {
    _horizontalScrollController2.dispose();

    super.dispose();
  }

  bool _isLoading = true;

  TextEditingController ReturnReasonController = TextEditingController();
  TextEditingController productCodeController = TextEditingController();
  TextEditingController serialNoController = TextEditingController();
  TextEditingController WarehouseController = TextEditingController();
  TextEditingController RegionController = TextEditingController();

  TextEditingController ReturnNoController = TextEditingController();

  List<Map<String, dynamic>> createtableData = [];

  FocusNode ReturnReasonFocus = FocusNode();
  FocusNode prodCodeFocus = FocusNode();
  FocusNode serialNoFocus = FocusNode();
  FocusNode addfoucnode = FocusNode();

  // Future<void> fetchAndAddData(String productcode, String serialno) async {
  //   final IpAddress = await getActiveIpAddress();
  //   final String fullUrl =
  //       "$IpAddress/Truck_ProductCodedetails/${widget.disid}/$productcode/$serialno/";
  //   print("fullUrl $fullUrl");

  //   try {
  //     final response = await http.get(Uri.parse(fullUrl));

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);

  //       if (data != null && data.isNotEmpty) {
  //         // Check if the data with the same product code and serial number already exists
  //         bool exists = createtableData.any((item) =>
  //             item['PRODUCT_CODE'] == productcode &&
  //             item['SERIAL_NO'] == serialno);

  //         if (exists) {
  //           _showErrorDialog("Already Exist",
  //               "This product code and serial number already exist in the table.");
  //           return;
  //         }

  //         // If noserialcheckbox is true, show quantity dialog
  //         if (noserialnocheckbox && bypasscheckbox) {
  //           final availableQty = data.length;
  //           int returnQty = int.tryParse(_qtyController.text) ?? 0;
  //           {
  //             print("returnQtyqqqqyyyy $returnQty");
  //             if (returnQty != null && returnQty > 0) {
  //               setState(() {
  //                 // Add only the requested quantity of items
  //                 createtableData.addAll(
  //                     List<Map<String, dynamic>>.from(data).take(returnQty));

  //                 // Clear the input fields and refocus
  //                 productCodeController.clear();
  //                 serialNoController.clear();

  //                 FocusScope.of(context).requestFocus(prodCodeFocus);
  //               });
  //             }
  //           }
  //           ;
  //         } else {
  //           // Original behavior when noserialcheckbox is false
  //           setState(() {
  //             createtableData.addAll(List<Map<String, dynamic>>.from(data));
  //             productCodeController.clear();
  //             serialNoController.clear();
  //             if (noproductcodeselectedbox) {
  //               FocusScope.of(context).requestFocus(serialNoFocus);
  //             } else {
  //               FocusScope.of(context).requestFocus(prodCodeFocus);
  //             }
  //           });
  //         }
  //       } else {
  //         _showErrorDialog(
  //             "No Data", "No data found for the given product code.");
  //       }
  //     } else {
  //       _showErrorDialog(
  //           "Error", "Failed to fetch data. Please try again later.");
  //     }
  //   } on http.ClientException catch (e) {
  //     _showErrorDialog("Error", "Failed to connect to the server: $e");
  //     print("HTTP Client Error: $e");
  //   } on FormatException catch (e) {
  //     _showErrorDialog("Error", "Failed to parse data: $e");
  //     print("Format Error: $e");
  //   } catch (error) {
  //     _showErrorDialog("Error", "An unexpected error occurred: $error");
  //     print("An unexpected error occurred: $error");
  //   }
  // }

  Future<void> fetchAndAddData(
      String buttonname, String productcode, String serialno) async {
    if (productcode.trim().isEmpty || serialno.trim().isEmpty) {
      _showErrorDialog(
          "Input Missing", "Please enter both Product Code and Serial Number.");
      print(
          "Error: productcode or serialno is empty. productcode=$productcode, serialno=$serialno");
      return;
    }

    final IpAddress = await getActiveIpAddress();
    final String fullUrl =
        "$IpAddress/Truck_ProductCodedetails/${widget.disid}/$productcode/$serialno/";
    print("Requesting: $fullUrl");

    try {
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
        final List<dynamic> data = json.decode(decodedBody);

        if (data != null && data.isNotEmpty) {
          // Check for duplicate entry
          bool exists = createtableData.any((item) =>
              item['PRODUCT_CODE'] == productcode &&
              item['SERIAL_NO'] == serialno);

          if (exists) {
            _showErrorDialog("Already Exists",
                "This product and serial number already exist.");
            return;
          }

          // If bypass & no serial are checked
          if (noserialnocheckbox || bypasscheckbox) {
            print(
                "noserialnocheckbox && bypasscheckbox  $noserialnocheckbox && $bypasscheckbox");
            int returnQty = int.tryParse(_qtyController.text) ?? 0;

            if (returnQty > 0) {
              print("Returnqty $returnQty");
              if (returnQty > data.length) {
                _showErrorDialog("Not Enough Data",
                    "Requested $returnQty items, but only ${data.length} available.");
                return;
              }

              setState(() {
                createtableData.addAll(
                  List<Map<String, dynamic>>.from(data.take(returnQty)),
                );
                productCodeController.clear();
                serialNoController.clear();
                FocusScope.of(context).requestFocus(prodCodeFocus);
              });
            } else {
              _showErrorDialog(
                  "Invalid Quantity", "Enter a quantity greater than 0.");
            }
          } else {
            int returnQty = int.tryParse(_qtyController.text) ?? 0;
            print("Return qty only display $returnQty");
            // Default behavior
            setState(() {
              createtableData.addAll(List<Map<String, dynamic>>.from(data));
              productCodeController.clear();
              serialNoController.clear();
              if (noproductcodeselectedbox) {
                FocusScope.of(context).requestFocus(serialNoFocus);
              } else {
                FocusScope.of(context).requestFocus(prodCodeFocus);
              }
            });
          }
        } else {
          _showErrorDialog("No Data",
              "No product data found for given code and serial number.");
        }
      } else {
        _showErrorDialog("Error",
            "Failed to fetch data. Server responded with status: ${response.statusCode}");
        print("Server Response: ${response.body}");
      }
    } on http.ClientException catch (e) {
      _showErrorDialog("Connection Error", "Failed to connect: $e");
      print("HTTP Client Error: $e");
    } on FormatException catch (e) {
      _showErrorDialog("Parsing Error", "Invalid response format: $e");
      print("Format Error: $e");
    } catch (error) {
      _showErrorDialog("Unexpected Error", error.toString());
      print("Unexpected error: $error");
    }
  }

  void _showErrorDialog(String heading, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(heading),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                // Add new data to the table

                FocusScope.of(context).requestFocus(prodCodeFocus);
                // Clear the input fields and refocus
                productCodeController.clear();
                serialNoController.clear();
              });
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
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

  FocusNode SerialcameraFocus = FocusNode();

  int noserialnocount = 0;
  int bypasscount = 0;
  int noproductcodecount = 0;
  bool noserialnocheckbox = false;

  bool noproductcodeselectedbox = false;
  bool bypasscheckbox = false;

  Future<void> fetchDispatchDetails(String dispatchId) async {
    final IpAddress = await getActiveIpAddress();
    final url =
        Uri.parse('$IpAddress/Deliver_noserialno_bypassesView/$dispatchId/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          noserialnocount = data['no_serial_qty'] ?? 0;
          bypasscount = data['bypass_qty'] ?? 0;
          noproductcodecount = data['no_productcode_qty'] ?? 0;

          noserialnocheckbox = noserialnocount > 0;
          noproductcodeselectedbox = noproductcodecount > 0;
          bypasscheckbox = bypasscount > 0;
        });

        print("Noserialno count: $noserialnocount");
        print("Bypass count: $bypasscount");
        print("Noserialnocheckbox: $noserialnocheckbox");
        print("Bypasscheckbox: $bypasscheckbox");
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to fetch data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Ensures the dialog adjusts to its content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Cancel Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Return Pop-up View',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            // Product Code and Serial No TextFields in the same row
            buildProductAndSerialInputFields(context),
            SizedBox(height: 30),

            Text(
              'Scanned Items : ',
              style: commonLabelTextStyle,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Container(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: _viewbuildTable(
                      context), // Assuming _viewbuildTable() returns a valid widget
                ),
              ),
            ),
            // Action Buttons
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(color: buttonColor),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(45.0, 35.0),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(0),
                      child: Text('Save', style: commonWhiteStyle),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirmation',
                                style: TextStyle(fontSize: 13)),
                            content: Text(
                              'Are you sure you want to add the return dispatch?',
                              style: TextStyle(fontSize: 13),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context)
                                      .pop(); // Close confirmation dialog

                                  if (createtableData.isEmpty) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          content: Row(
                                            children: [
                                              Icon(Icons.check_box_rounded,
                                                  color: Color.fromARGB(
                                                      255, 223, 196, 18)),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  'Kindly Fill all the fields.',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.0),
                                                ),
                                                backgroundColor: subcolor,
                                                minimumSize: Size(30.0, 28.0),
                                              ),
                                              child: Text('Ok',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    // Show processing dialog
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          elevation: 10,
                                          backgroundColor: Colors.white,
                                          child: Container(
                                            padding: const EdgeInsets.all(24.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Animated loading indicator
                                                SizedBox(
                                                  height: 80,
                                                  width: 80,
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      CircularProgressIndicator(
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                Color>(Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                        strokeWidth: 5,
                                                      ),
                                                      Icon(
                                                        Icons.inventory_rounded,
                                                        size: 30,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 18),
                                                // Title
                                                const Text(
                                                  "Processing Return Dispatch",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                // Subtitle
                                                const Text(
                                                  "Please wait while we process your request",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 16),
                                                // Progress text
                                                StreamBuilder<int>(
                                                  stream: Stream.periodic(
                                                      const Duration(
                                                          milliseconds: 300),
                                                      (count) => count % 4),
                                                  builder: (context, snapshot) {
                                                    String dots = '.' *
                                                        (snapshot.data ?? 0);
                                                    return Text(
                                                      "Loading$dots",
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black54,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );

                                    try {
                                      await postTransactionDetails();
                                      await postReturn_dispatch();
                                      await updateTruckScanData();
                                      await updatePickManscanData();
                                      await updatedispatchrequestdatas();
                                      await updatecreatedispatch();
                                      widget.onClear();
                                      await SaveReturnProducts();
                                    } catch (e) {
                                      // Dismiss the loading dialog if error occurred
                                      if (Navigator.canPop(context)) {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                      }
                                      print('Error occurred while posting: $e');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text("Error: ${e.toString()}"),
                                        backgroundColor: Colors.red,
                                      ));
                                    }
                                  }
                                },
                                child: Text('Yes'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close confirmation dialog
                                },
                                child: Text('No'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  final TextEditingController _qtyController = TextEditingController();
  Widget buildProductAndSerialInputFields(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Wrap(
      spacing: 10, // Space between the fields
      runSpacing: 10, // Space between lines when wrapping
      children: [
        // Product Code TextField

        Container(
          width: Responsive.isDesktop(context)
              ? screenWidth * 0.13
              : screenWidth * 0.8,
          child: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0, bottom: 0),
                  child: Row(
                    children: [
                      Container(
                        height: 32,
                        width: Responsive.isDesktop(context)
                            ? screenWidth * 0.13
                            : screenWidth * 0.5,
                        child: MouseRegion(
                          onEnter: (event) {
                            // Action when mouse enters
                          },
                          onExit: (event) {
                            // Action when mouse leaves
                          },
                          cursor: SystemMouseCursors.click,
                          child: TextFormField(
                            controller: ReturnReasonController,
                            focusNode: ReturnReasonFocus,
                            onFieldSubmitted: (_) => _fieldFocusChange(
                                context, ReturnReasonFocus, prodCodeFocus),
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(201, 132, 132, 132),
                                  width: 1.0,
                                ),
                              ),
                              hintText: 'Enter Return Reason',
                              hintStyle: const TextStyle(
                                  color: Color.fromARGB(255, 73, 72, 72),
                                  fontSize: 13),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 58, 58, 58),
                                  width: 1.0,
                                ),
                              ),
                              filled: true,
                              fillColor: Color.fromARGB(255, 250, 250, 250),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0,
                              ),
                            ),
                            style: const TextStyle(
                                color: Color.fromARGB(255, 73, 72, 72),
                                fontSize: 13),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: Responsive.isDesktop(context)
              ? screenWidth * 0.13
              : screenWidth * 0.8,
          child: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0, bottom: 0),
                  child: Row(
                    children: [
                      Container(
                        height: 32,
                        width: Responsive.isDesktop(context)
                            ? screenWidth * 0.13
                            : screenWidth * 0.5,
                        child: MouseRegion(
                          onEnter: (event) {
                            // Action when mouse enters
                          },
                          onExit: (event) {
                            // Action when mouse leaves
                          },
                          cursor: SystemMouseCursors.click,
                          child: TextFormField(
                            controller: productCodeController,
                            focusNode: prodCodeFocus,
                            onFieldSubmitted: (_) => _fieldFocusChange(
                                context, prodCodeFocus, serialNoFocus),
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(201, 132, 132, 132),
                                  width: 1.0,
                                ),
                              ),
                              hintText: 'Enter Product Code',
                              hintStyle: const TextStyle(
                                  color: Color.fromARGB(255, 73, 72, 72),
                                  fontSize: 13),
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    _openScannerProdCode();
                                  },
                                  icon: Icon(
                                    Icons.qr_code,
                                    size: 18,
                                    color: Colors.blue,
                                  )),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 58, 58, 58),
                                  width: 1.0,
                                ),
                              ),
                              filled: true,
                              fillColor: Color.fromARGB(255, 250, 250, 250),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0,
                              ),
                            ),
                            style: const TextStyle(
                                color: Color.fromARGB(255, 73, 72, 72),
                                fontSize: 13),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Serial Number TextField
        Container(
          width: Responsive.isDesktop(context)
              ? screenWidth * 0.13
              : screenWidth * 0.8,
          child: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0, bottom: 0),
                  child: Row(
                    children: [
                      Container(
                        height: 32,
                        width: Responsive.isDesktop(context)
                            ? screenWidth * 0.13
                            : screenWidth * 0.5,
                        child: MouseRegion(
                          onEnter: (event) {
                            // Action when mouse enters
                          },
                          onExit: (event) {
                            // Action when mouse leaves
                          },
                          cursor: SystemMouseCursors.click,
                          child: TextFormField(
                            controller: serialNoController,
                            focusNode: serialNoFocus,
                            onFieldSubmitted: (_) => _fieldFocusChange(
                                context, serialNoFocus, addfoucnode),
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(201, 132, 132, 132),
                                  width: 1.0,
                                ),
                              ),
                              hintText: 'Enter Serial No',
                              hintStyle: const TextStyle(
                                  color: Color.fromARGB(255, 73, 72, 72),
                                  fontSize: 13),
                              suffixIcon: IconButton(
                                  focusNode: SerialcameraFocus,
                                  onPressed: () {
                                    _openScannerSerial();
                                  },
                                  icon: const Icon(
                                    Icons.qr_code,
                                    size: 18,
                                    color: Colors.blue,
                                  )),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 58, 58, 58),
                                  width: 1.0,
                                ),
                              ),
                              filled: true,
                              fillColor: Color.fromARGB(255, 250, 250, 250),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0,
                              ),
                            ),
                            style: const TextStyle(
                                color: Color.fromARGB(255, 73, 72, 72),
                                fontSize: 13),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Add Button
        Container(
          width: Responsive.isDesktop(context)
              ? screenWidth * 0.08
              : screenWidth * 0.3,
          decoration: BoxDecoration(color: buttonColor),
          child: ElevatedButton(
            focusNode: addfoucnode,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(45.0, 35.0),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: const Padding(
              padding: EdgeInsets.zero,
              child: Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            onPressed: () {
              final returnreason = ReturnReasonController.text.trim();
              final productCode = productCodeController.text.trim();
              final serialNo = serialNoController.text.trim();
              _qtyController.text = '1';

              if (returnreason.isEmpty ||
                  productCode.isEmpty ||
                  serialNo.isEmpty) {
                // Show warning message
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Warning'),
                        content: Text('Kindly enter all fields.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    });
                return;
              }

              // Proceed if all fields are filled
              checkProductReturned('Add_button', productCode, serialNo);
              postLogData("Return Dispatch Pop-up View", "New return Added");
            },
          ),
        ),

// Alert
        if (bypasscheckbox == true)
          Container(
            width: Responsive.isDesktop(context)
                ? screenWidth * 0.08
                : screenWidth * 0.3,
            decoration: BoxDecoration(color: buttonColor),
            child: ElevatedButton(
              focusNode: addfoucnode,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(45.0, 35.0),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Padding(
                padding: EdgeInsets.zero,
                child: Text(
                  'Add Bypass',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              onPressed: () {
                final returnreason = ReturnReasonController.text.trim();
                final productCode = '00';
                final serialNo = 'null';

                if (returnreason.isEmpty) {
                  // Show warning message
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Warning'),
                          content: Text('Kindly enter all fields.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      });
                  return;
                }

                final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
                _qtyController.clear();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Return Item'),
                      content: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Deliver ID: DL12345'),
                            SizedBox(height: 10),
                            Text('There are $bypasscount quantity available.'),
                            SizedBox(height: 10),
                            Text('How many do you want to return?'),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: _qtyController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Quantity',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter quantity';
                                }
                                final qty = int.tryParse(value);
                                if (qty == null) {
                                  return 'Please enter a valid number';
                                }
                                if (qty <= 0) {
                                  return 'Quantity must be greater than 0';
                                }
                                if (qty > bypasscount) {
                                  return 'Quantity cannot exceed $bypasscount';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Submit'),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Valid quantity entered
                              final returnQty = int.parse(_qtyController.text);
                              Navigator.of(context).pop(returnQty);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Returning $returnQty items'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              checkProductReturned(
                                  'submit', productCode, serialNo);
                              postLogData("Return Dispatch Pop-up View",
                                  "New return Added");
                            }
                          },
                        ),
                      ],
                    );
                  },
                ).then((returnQty) {});
                // Proceed if all fields are filled
              },
            ),
          ),
// No Serialno

        if (noproductcodeselectedbox == true)
          // Add Button
          Container(
            width: Responsive.isDesktop(context)
                ? screenWidth * 0.1
                : screenWidth * 0.3,
            decoration: BoxDecoration(color: buttonColor),
            child: ElevatedButton(
              focusNode: addfoucnode,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(45.0, 35.0),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Padding(
                padding: EdgeInsets.zero,
                child: Text(
                  'No Product Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
              onPressed: () {
                final returnreason = ReturnReasonController.text.trim();
                final productCode = '00';
                final serialNo = serialNoController.text.trim();
                _qtyController.text = '1';

                if (returnreason.isEmpty || serialNo.isEmpty) {
                  // Show warning message
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Warning'),
                          content: Text('Kindly enter all fields.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      });
                  return;
                }

                // Proceed if all fields are filled
                checkProductReturned('noproductcode', productCode, serialNo);
                postLogData("Return Dispatch Pop-up View", "New return Added");
              },
            ),
          ),

        if (noserialnocheckbox == true)
          Container(
            width: Responsive.isDesktop(context)
                ? screenWidth * 0.08
                : screenWidth * 0.3,
            decoration: BoxDecoration(color: buttonColor),
            child: ElevatedButton(
              focusNode: addfoucnode,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(45.0, 35.0),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Padding(
                padding: EdgeInsets.zero,
                child: Text(
                  'No Serialno',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              onPressed: () {
                final returnreason = ReturnReasonController.text.trim();
                final productCode = productCodeController.text.trim();
                final serialNo = 'null';

                if (returnreason.isEmpty || productCode.isEmpty) {
                  // Show warning message
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Warning'),
                          content: Text('Kindly enter all fields.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      });
                  return;
                }

                final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
                _qtyController.clear();

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Return Item'),
                      content: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Deliver ID: DL12345'),
                            SizedBox(height: 10),
                            Text(
                                'There are $noserialnocount quantity available.'),
                            SizedBox(height: 10),
                            Text('How many do you want to return?'),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: _qtyController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Quantity',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter quantity';
                                }
                                final qty = int.tryParse(value);
                                if (qty == null) {
                                  return 'Please enter a valid number';
                                }
                                if (qty <= 0) {
                                  return 'Quantity must be greater than 0';
                                }
                                if (qty > noserialnocount) {
                                  return 'Quantity cannot exceed $noserialnocount';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Submit'),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Valid quantity entered
                              final returnQty = int.parse(_qtyController.text);
                              Navigator.of(context).pop(returnQty);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Returning $returnQty items'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              checkProductReturned(
                                  'submit', productCode, serialNo);
                              postLogData("Return Dispatch Pop-up View",
                                  "New return Added");
                            }
                          },
                        ),
                      ],
                    );
                  },
                ).then((returnQty) {});
                // Proceed if all fields are filled
              },
            ),
          ),
      ],
    );
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
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> checkProductReturned(
      String clickbutton, String productCode, String serialNo) async {
    final IpAddress = await getActiveIpAddress();

    String url = '$IpAddress/Return_dispatch/';
    bool isReturned = false;

    while (url != null) {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'];

        // Check if any of the results match the product code and serial number
        isReturned = results.any((item) {
          return item['DISPATCH_ID'] == widget.disid &&
              item['PRODUCT_CODE'] == productCode &&
              item['SERIAL_NO'] == serialNo;
        });
        print("add button status : $isReturned");

        if (isReturned) {
          // If product is already returned, show a warning dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Already Exists'),
                content: Text('This product has already been returned.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        productCodeController.clear();
                        serialNoController.clear();
                      });

                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          break; // No need to check further pages if found
        }

        // Update the URL to fetch the next page
        url = data['next'] ?? ''; // Safeguard against null 'next'
        if (url.isEmpty) break; // Exit the loop if 'next' is null or empty
      } else {
        // Handle error if the response is not successful
        print('Failed to load data');
        break;
      }
    }

    // Check if product has not been returned before proceeding
    if (!isReturned) {
      print("add productCodeController : ${productCode}  ${serialNo}");
      // If not returned, proceed with adding data
      fetchAndAddData(clickbutton, productCode, serialNo);
    }
  }

  void _openScannerProdCode() {
    // Flag to prevent multiple scans
    bool isScanned = false;

    // Create a MobileScannerController instance
    final MobileScannerController scannerController = MobileScannerController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: MobileScanner(
                controller: scannerController,
                onDetect: (BarcodeCapture capture) {
                  if (isScanned) return; // Prevent multiple detections
                  isScanned = true;

                  final String? scannedCode = capture.barcodes.first.rawValue;

                  if (scannedCode != null && scannedCode.isNotEmpty) {
                    // Update the text field with the scanned value
                    productCodeController.text = scannedCode;

                    // Show a small SnackBar message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Product Code Scanned!',
                          style: TextStyle(fontSize: 12), // Small font size
                        ),
                        duration: Duration(
                            seconds: 2), // Duration to show the message
                      ),
                    );

                    // Close the scanner dialog
                    Navigator.of(context).pop();

                    // Delay to allow the SnackBar to show before opening the serial scanner
                    Future.delayed(Duration(seconds: 1), () {
                      // Automatically open the serial number scanner
                      _openScannerSerial();
                    });
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
                  cutOutSize: MediaQuery.of(context).size.width * 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Dispose of the scanner controller after the dialog is closed
      scannerController.dispose();

      // Reset the scanned flag for future use
      isScanned = false;

      // Move focus to the corresponding Serial No text field
      FocusScope.of(context).requestFocus(SerialcameraFocus);
    });
  }

  void _openScannerSerial() {
    // Flag to prevent multiple scans
    bool isScanned = false;

    // Create a MobileScannerController instance
    final MobileScannerController scannerController = MobileScannerController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: MobileScanner(
                controller: scannerController,
                onDetect: (BarcodeCapture capture) {
                  if (isScanned) return; // Prevent multiple detections
                  isScanned = true;

                  final String? scannedCode = capture.barcodes.first.rawValue;

                  if (scannedCode != null && scannedCode.isNotEmpty) {
                    // Update the text field with the scanned value
                    serialNoController.text = scannedCode;

                    // Close the scanner dialog
                    Navigator.of(context).pop();
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
                  cutOutSize: MediaQuery.of(context).size.width * 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Dispose of the scanner controller after the dialog is closed
      scannerController.dispose();

      // Reset the scanned flag for future use
      isScanned = false;

      // Move focus to the corresponding Serial No text field
      // FocusScope.of(context).requestFocus(addButtonFocusNode);

      // Move to the next text field if there are more fields
    });
  }

  final ScrollController _horizontalScrollController2 = ScrollController();

  Widget _viewbuildTable(BuildContext context) {
    return Container(
      child: Scrollbar(
        thumbVisibility: true,
        controller: _horizontalScrollController2,
        child: SingleChildScrollView(
          controller: _horizontalScrollController2,
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey[400]!,
                    width: 1.0,
                  ),
                ),
                height: 220,
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.59
                    : MediaQuery.of(context).size.width * 2.5,
                // child: SingleChildScrollView(
                child: Container(
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 0, right: 0, top: 0, bottom: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // buildHeaderCell("SNo", Icons.numbers,
                          //     context), // Represents numbers
                          buildHeaderCell("Customer No", Icons.person,
                              context), // Represents a customer/user
                          buildHeaderCell("Cus Name", Icons.badge,
                              context), // Badge for customer name
                          buildHeaderCell("Invoice No", Icons.receipt_long,
                              context), // Represents an invoice/receipt
                          buildHeaderCell("Item Code", Icons.qr_code,
                              context), // Represents item/product codes
                          buildHeaderCell("Item Desc", Icons.info_outline,
                              context), // Represents description/info
                          buildHeaderCell(
                              "Product Code",
                              Icons.production_quantity_limits,
                              context), // Represents production/products
                          buildHeaderCell(
                              "Serial No",
                              Icons.format_list_numbered,
                              context), // Represents a serial/list of numbers
                        ],
                      ),
                    ),
                    if (createtableData.isNotEmpty)
                      Expanded(
                        // Ensure that the content inside scrolls
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: createtableData.map((data) {
                              var index = createtableData.indexOf(data);
                              return buildRow(index, data, context);
                            }).toList(),
                          ),
                        ),
                      )
                  ]),
                ),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeaderCell(String label, IconData icon, BuildContext context) {
    return Flexible(
      child: Container(
        height: 30,
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(color: Colors.white),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 15, color: Colors.blue),
              SizedBox(width: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: commonLabelTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRow(int index, Map<String, dynamic> data, BuildContext context) {
    // Convert values to string while removing .0 if necessary
    var cusno = _removeDecimalIf(data['CUSTOMER_NUMBER']);
    var cusname = _removeDecimalIf(data['CUSTOMER_NAME']);
    var invoiceno = _removeDecimalIf(data['INVOICE_NO']);
    var itemcode = _removeDecimalIf(data['ITEM_CODE']);

    var itemdetails = _removeDecimalIf(data['ITEM_DETAILS']);

    var productcode = _removeDecimalIf(data['PRODUCT_CODE']);

    var serialno = _removeDecimalIf(data['SERIAL_NO']);

    return Container(
      margin: EdgeInsets.symmetric(
          vertical: 0), // Optional for spacing between rows

      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // buildDataCell(id, context),
            buildDataCell(cusno, context),
            buildDataCell(cusname, context),
            buildDataCell(invoiceno, context),
            buildDataCell(itemcode, context),
            buildDataCell(itemdetails, context),
            buildDataCell(productcode, context),
            buildDataCell(serialno, context),
          ],
        ),
      ),
    );
  }

  Widget buildDataCell(String value, BuildContext context) {
    return Flexible(
      child: Container(
        height: 30,
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.left,
                style: TableRowTextStyle,
                overflow: TextOverflow.ellipsis, // Avoid overflow
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _removeDecimalIf(dynamic value) {
    if (value is double) {
      return value
          .truncate()
          .toString(); // Convert to int if it's a whole number
    } else if (value is String) {
      double? parsedValue = double.tryParse(value);
      if (parsedValue != null) {
        return parsedValue
            .truncate()
            .toString(); // Handle string representation of double
      }
      return value; // Return the original string if not a valid number
    }
    return value.toString(); // Fallback for other types
  }

  Future<void> fetchWarehouseDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';

    String orgId = saleslogiOrgid;

    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/Physical_Warehouse/';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Find the entry for the given ORGANIZATION_ID
        final result = data['results'].firstWhere(
          (item) => item['ORGANIZATION_ID'] == orgId,
          orElse: () => null,
        );

        if (result != null) {
          // Update the controllers with fetched values
          setState(() {
            WarehouseController.text = result['REGION_NAME'];
            RegionController.text = result['WAREHOUSE_NAME'];
          });
        } else {
          // Clear the controllers if no match is found
          setState(() {
            WarehouseController.text = '';
            RegionController.text = '';
          });
          print('No data found for ORGANIZATION_ID: $orgId');
        }
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  String returnid = '';

  String token = '';
  Future<void> fetchTokenwithCusid() async {
    final IpAddress = await getActiveIpAddress();

    try {
// Send a GET request to fetch the CSRF token from the server
      final response =
          await http.get(Uri.parse('$IpAddress/Return_generate-token/'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        returnid = data['RETURN_ID']?.toString() ?? '';
        token = data['TOCKEN'] ?? 'No Token found';

        String savereturnid = returnid.toString(); // Convert int to String

        setState(() {
          // Only update state variables here
        });

        print('returniddd $returnid  $savereturnid  $token');

        // Save values after setState
        await saveToSharedPreferences(savereturnid, token);

        // await saveToSharedPreferences(newCusid, newToken);
      } else {
        setState(() {
          // Message = 'Failed to fetch data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        // Message = 'Error: $e';
      });
    }
  }

  Future<void> saveToSharedPreferences(String lastCusID, String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uniqulastreqno', lastCusID);
    await prefs.setString('csrf_token', token);
  }

  bool _isProcessing = false;
  Future<void> postReturn_dispatch() async {
    print("Entered in to the Return Dispatch");

    final IpAddress = await getActiveIpAddress();

    await fetchTokenwithCusid();
    final url = '$IpAddress/Return_dispatch/';
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? salesloginno = prefs.getString('salesloginno') ?? '';
    String? saveloginname = prefs.getString('saveloginname') ?? '';
    String? saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';

    DateTime now = DateTime.now();
    // Format to YYYY-MM-DD HH:mm:ss
    String formattedDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(now);

    try {
      for (int i = 0; i < createtableData.length; i++) {
        String warehouse =
            WarehouseController.text.isNotEmpty ? WarehouseController.text : '';
        String orgName =
            RegionController.text.isNotEmpty ? RegionController.text : '';
        returnid =
            ReturnNoController.text.isNotEmpty ? ReturnNoController.text : '';

        String ReturnReason = ReturnReasonController.text.isNotEmpty
            ? ReturnReasonController.text
            : '';

        var row = createtableData[i]; // Access the current row

        print("returnid last with tocken $returnid");

        // Construct the dispatch data
        Map<String, dynamic> createDispatchData = {
          "RETURN_DIS_ID": returnid,
          "DISPATCH_ID": row['DISPATCH_ID']?.toString() ?? '0',
          "REQ_ID": row['REQ_ID']?.toString() ?? '0',
          "PICK_ID": row['PICK_ID']?.toString() ?? '0',
          "DATE": formattedDate,
          "PHYSICAL_WAREHOUSE": warehouse,
          "ORG_ID": saleslogiOrgid.isNotEmpty ? saleslogiOrgid : '0',
          "ORG_NAME": orgName,
          "SALESMAN_NO": row['SALESMAN_NO']?.toString() ?? '0',
          "SALESMAN_NAME": row['SALESMAN_NAME']?.toString() ?? '0',
          "MANAGER_NO": salesloginno.isNotEmpty ? salesloginno : '0',
          "MANAGER_NAME": saveloginname.isNotEmpty ? saveloginname : 'Unknown',
          "CUSTOMER_NUMBER": row['CUSTOMER_NUMBER']?.toString() ?? '0',
          "CUSTOMER_NAME": row['CUSTOMER_NAME']?.toString() ?? '',
          "CUSTOMER_SITE_ID": row['CUSTOMER_SITE_ID']?.toString() ?? '0',
          "CUSTOMER_TRX_ID": row['CUSTOMER_TRX_ID']?.toString() ?? '',
          "CUSTOMER_TRX_LINE_ID": row['CUSTOMER_TRX_LINE_ID']?.toString() ?? '',
          "LINE_NUMBER": row['LINE_NO']?.toString() ?? '0',
          "TRANSPORTER_NAME": row['TRANSPORTER_NAME']?.toString() ?? '',
          "DRIVER_NAME": row['DRIVER_NAME']?.toString() ?? '',
          "DRIVER_MOBILENO": row['DRIVER_MOBILENO']?.toString() ?? '0',
          "VENDOR_NAME": row['VENDOR_NAME']?.toString() ?? '',
          "VEHICLE_NO": row['VEHICLE_NO']?.toString() ?? '',
          "TRUCK_DIMENSION": row['TRUCK_DIMENSION']?.toString() ?? '',
          "LOADING_CHARGES": row['LOADING_CHARGES']?.toString() ?? '0',
          "TRANSPORT_CHARGES": row['TRANSPORT_CHARGES']?.toString() ?? '0',
          "MISC_CHARGES": row['MISC_CHARGES']?.toString() ?? '0',
          "REMARKS": row['REMARKS']?.toString() ?? '',
          "INVOICE_NO": row['INVOICE_NO']?.toString() ?? '0',
          "ITEM_CODE": row['ITEM_CODE']?.toString() ?? '',
          "ITEM_DETAILS": row['ITEM_DETAILS']?.toString() ?? '',
          "PRODUCT_CODE": row['PRODUCT_CODE']?.toString() ?? '',
          "SERIAL_NO": row['SERIAL_NO']?.toString() ?? '',
          "DISREQ_QTY": row['DISREQ_QTY']?.toString() ?? '0',
          "BALANCE_QTY": row['BALANCE_QTY']?.toString() ?? '0',
          "TRUCK_SEND_QTY": row['TRUCK_SEND_QTY']?.toString() ?? '0',
          "CREATION_DATE": formattedDate,
          "CREATED_BY": saveloginname.isNotEmpty ? saveloginname : 'Unknown',
          "CREATED_IP": "null",
          "CREATED_MAC": "null",
          "LAST_UPDATE_DATE": formattedDate,
          "LAST_UPDATED_BY": "null",
          "LAST_UPDATE_IP": "null",
          "FLAG": "A",
          "RETURN_REASON": ReturnReason,
        };

        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(createDispatchData),
        );

        if (response.statusCode == 201) {
          print(
              'Dispatch created successfully for Line Number: ${row['LINE_NUMBER']}');
          setState(() {
            _isProcessing = false;
          });
        } else {
          print(
              'Failed to create dispatch for Line Number: ${row['LINE_NUMBER']}. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      print('Error occurred while posting dispatch data: $e');
    }
  }

  Future<void> updateTruckScanData() async {
    print("Entered in to the Truck Scan ");

    final ipAddress =
        await getActiveIpAddress(); // Get your API IP (e.g., http://192.168.1.10:8000)

    for (var record in createtableData) {
      final id = record['id'];
      if (id == null) {
        print('⚠️ Skipping record with null ID');
        continue;
      }

      // Using GET query parameter, no PATCH/POST body required
      final updateUrl = Uri.parse('$ipAddress/update-truck-flag/$id/');
      print("updateUrllllll $updateUrl");
      try {
        final response =
            await http.post(updateUrl); // Use POST as per Django view

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          print('✅ FLAG updated for ID $id: ${responseData['data']}');
        } else {
          print('❌ Failed to update FLAG for id: $id');
          print('Status Code: ${response.statusCode}');
          print('Body: ${response.body}');
        }
      } catch (e) {
        print('🔥 Exception while updating FLAG for id: $id');
        print('Error: $e');
      }
    }
  }

  Future<void> updatePickManscanData() async {
    print("Entered in to the Pick Scan ");
    final ipAddress = await getActiveIpAddress();
    print("createtableDataaa in pick updated $createtableData");
    for (var record in createtableData) {
      final reqno = record['REQ_ID'];
      final pickid = record['PICK_ID'];

      final invoiceno = record['INVOICE_NO'];

      final productCode = record['PRODUCT_CODE'];
      final serialNo = record['SERIAL_NO'];
      // Count matching rows with same REQ_ID, PICK_ID, INVOICE_NO, PRODUCT_CODE, and SERIAL_NO
      final totalProductCodeCount = createtableData
          .where((element) =>
              element['REQ_ID'] == reqno &&
              element['PICK_ID'] == pickid &&
              element['INVOICE_NO'] == invoiceno &&
              element['PRODUCT_CODE'] == productCode &&
              element['SERIAL_NO'] == serialNo)
          .length;
      final url = Uri.parse(
          '$ipAddress/update_pickman_flag/$reqno/$pickid/$invoiceno/1/$productCode/$serialNo/');
      print("urllllllllllll $url $totalProductCodeCount");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('Success: ${response.body}');
      } else {
        print('Failed to update: ${response.statusCode}');
      }
    }
  }

  Future<void> updatedispatchrequestdatas() async {
    print("Entered in to the Dispatch Request ");
    for (var record in createtableData) {
      final reqid = record['REQ_ID'];
      final cusno = record['CUSTOMER_NUMBER'];
      final cussite = record['CUSTOMER_SITE_ID'];
      final itemcode = record['ITEM_CODE'];
      final truckSendQty = record['TRUCK_SEND_QTY'];

      final IpAddress = await getActiveIpAddress();

      if (reqid != null &&
          cusno != null &&
          cussite != null &&
          itemcode != null &&
          truckSendQty != null) {
        // URL to get the record by REQ_ID, CUSTOMER_NUMBER, CUSTOMER_SITE_ID, and ITEM_CODE
        final getUrl = Uri.parse(
            '$IpAddress/filtereddispatchrequestgetreturnupdateid$parameterdivided$reqid$parameterdivided$cusno$parameterdivided$cussite$parameterdivided$itemcode$parameterdivided');
        final headers = {"Content-Type": "application/json"};

        print(
            "Fetching record for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno, CUSTOMER_SITE_ID: $cussite, ITEM_CODE: $itemcode from $getUrl");

        try {
          // Fetch the record using a GET request
          final getResponse = await http.get(getUrl, headers: headers);

          if (getResponse.statusCode == 200) {
            // Parse the response body to get the 'id' and 'SCANNED_QTY'
            final List<dynamic> records = json.decode(getResponse.body);
            if (records.isNotEmpty) {
              final record =
                  records[0]; // Assuming there's only one record returned
              final id = record['id'];
              final scannedQty = record['SCANNED_QTY'] ?? 0;

              if (id != null) {
                // Ensure scannedQty and truckSendQty are treated as numbers
                final int scannedQtyNum = scannedQty is int
                    ? scannedQty
                    : int.tryParse(scannedQty.toString()) ?? 0;
                final int truckSendQtyNum = truckSendQty is int
                    ? truckSendQty
                    : int.tryParse(truckSendQty.toString()) ?? 0;

                // Calculate the new SCANNED_QTY
                final int finalScannedQty = scannedQtyNum - truckSendQtyNum;

                print(
                    "scanned qty : $finalScannedQty = $scannedQty  + $truckSendQty");

                // Now update the SCANNED_QTY and STATUS for this id
                final updateUrl = Uri.parse('$IpAddress/Dispatch_request/$id/');
                final body = json.encode({
                  // "PICKED_QTY": finalScannedQty,
                  // "SCANNED_QTY": finalScannedQty, // Update with the new total
                  // "STATUS": "pending",
                });

                final putResponse =
                    await http.put(updateUrl, headers: headers, body: body);

                if (putResponse.statusCode == 200) {
                  print(
                      'Updated SCANNED_QTY to $finalScannedQty and STATUS to "pending" for ID: $id');
                } else {
                  print(
                      'Failed to update record for ID: $id. Status code: ${putResponse.statusCode}');
                }
              } else {
                print(
                    'No valid ID found for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno');
              }
            } else {
              print(
                  'No record found for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno, CUSTOMER_SITE_ID: $cussite, ITEM_CODE: $itemcode');
            }
          } else {
            print(
                'Failed to fetch record for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno. Status code: ${getResponse.statusCode}');
          }
        } catch (e) {
          print(
              'Error fetching or updating record for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno: $e');
        }
      } else {
        print('Invalid data for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno');
      }
    }
  }

  // Future<void> updatecreatedispatch() async {
  //   print('Entered in to teh create dispatch ');

  //   for (var record in createtableData) {
  //     final reqid = record['REQ_ID'];
  //     final cusno = record['CUSTOMER_NUMBER'];
  //     final cussite = record['CUSTOMER_SITE_ID'];
  //     final itemcode = record['ITEM_CODE'];
  //     final invoiceno = record['INVOICE_NO'];
  //     final truckSendQty = record['TRUCK_SEND_QTY'];

  //     if (reqid != null &&
  //         cusno != null &&
  //         cussite != null &&
  //         itemcode != null &&
  //         truckSendQty != null) {
  //       // URL to get the record by REQ_ID, CUSTOMER_NUMBER, CUSTOMER_SITE_ID, and ITEM_CODE

  //       final IpAddress = await getActiveIpAddress();

  //       final getUrl = Uri.parse(
  //           '$IpAddress/GetidCreateDispatchView$parameterdivided$reqid$parameterdivided$cusno$parameterdivided$cussite$parameterdivided$invoiceno$parameterdivided$itemcode$parameterdivided');
  //       final headers = {"Content-Type": "application/json"};

  //       print(
  //           "Fetching record for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno, CUSTOMER_SITE_ID: $cussite, ITEM_CODE: $itemcode from $getUrl");

  //       try {
  //         // Fetch the record using a GET request
  //         final getResponse = await http.get(getUrl, headers: headers);

  //         if (getResponse.statusCode == 200) {
  //           // Parse the response body to get the 'id' and 'SCANNED_QTY'
  //           final List<dynamic> records = json.decode(getResponse.body);
  //           if (records.isNotEmpty) {
  //             final record =
  //                 records[0]; // Assuming there's only one record returned
  //             final id = record['id'];
  //             final dispatchmanagerqty = record['DISPATCHED_BY_MANAGER'] ?? 0;

  //             final dispatchQty = record['DISPATCHED_QTY'] ?? 0;

  //             final dispatchscanqty = record['TRUCK_SCAN_QTY'] ?? 0;

  //             if (id != null) {
  //               // Ensure scannedQty and truckSendQty are treated as numbers
  //               final int dispatchmanagerqtyNum = dispatchmanagerqty is int
  //                   ? dispatchmanagerqty
  //                   : int.tryParse(dispatchmanagerqty.toString()) ?? 0;

  //               final int dispatchscanqtyyNum = dispatchscanqty is int
  //                   ? dispatchscanqty
  //                   : int.tryParse(dispatchscanqty.toString()) ?? 0;
  //               final int truckSendQtyNum = truckSendQty is int
  //                   ? truckSendQty
  //                   : int.tryParse(truckSendQty.toString()) ?? 0;

  //               // Calculate the new SCANNED_QTY
  //               final int finalScannedQty = dispatchQty - truckSendQtyNum;

  //               // Calculate the new SCANNED_QTY
  //               final int finalscantruckQty =
  //                   dispatchscanqtyyNum + truckSendQtyNum;

  //               print(
  //                   "scanned qty :  $finalScannedQty = $dispatchmanagerqtyNum  + $truckSendQty    truck scna qty $finalscantruckQty = $dispatchscanqtyyNum + $truckSendQtyNum");

  //               // Now update the SCANNED_QTY and STATUS for this id
  //               final updateUrl = Uri.parse('$IpAddress/Create_Dispatch/$id/');
  //               final body = json.encode({
  //                 "FLAG": "R",
  //                 "TRUCK_SCAN_QTY": finalscantruckQty,
  //                 "DISPATCHED_BY_MANAGER":
  //                     finalScannedQty, // Update with the new total
  //               });

  //               final putResponse =
  //                   await http.put(updateUrl, headers: headers, body: body);

  //               if (putResponse.statusCode == 200) {
  //                 print(
  //                     'Updated SCANNED_QTY to $finalScannedQty and STATUS to "pending" for ID: $id');
  //               } else {
  //                 print(
  //                     'Failed to update record for ID: $id. Status code: ${putResponse.statusCode}');
  //               }
  //             } else {
  //               print(
  //                   'No valid ID found for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno');
  //             }
  //           } else {
  //             print(
  //                 'No record found for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno, CUSTOMER_SITE_ID: $cussite, ITEM_CODE: $itemcode');
  //           }
  //         } else {
  //           print(
  //               'Failed to fetch record for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno. Status code: ${getResponse.statusCode}');
  //         }
  //       } catch (e) {
  //         print(
  //             'Error fetching or updating record for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno: $e');
  //       }
  //     } else {
  //       print('Invalid data for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno');
  //     }
  //   }
  // }

  Future<void> updatecreatedispatch() async {
    print('Entered into the create dispatch');

    // Step 1: Group and sum truckSendQty
    final Map<String, Map<String, dynamic>> groupedData = {};

    for (var record in createtableData) {
      final reqid = record['REQ_ID'];
      final cusno = record['CUSTOMER_NUMBER'];
      final cussite = record['CUSTOMER_SITE_ID'];
      final itemcode = record['ITEM_CODE'];
      final invoiceno = record['INVOICE_NO'];
      final truckSendQty = record['TRUCK_SEND_QTY'];

      if (reqid != null &&
          cusno != null &&
          cussite != null &&
          itemcode != null &&
          invoiceno != null &&
          truckSendQty != null) {
        final key = '$reqid|$cusno|$cussite|$invoiceno|$itemcode';

        final int qty = int.tryParse(truckSendQty.toString()) ?? 0;

        if (!groupedData.containsKey(key)) {
          groupedData[key] = {
            'REQ_ID': reqid,
            'CUSTOMER_NUMBER': cusno,
            'CUSTOMER_SITE_ID': cussite,
            'INVOICE_NO': invoiceno,
            'ITEM_CODE': itemcode,
            'TOTAL_QTY': qty,
          };
        } else {
          groupedData[key]!['TOTAL_QTY'] += qty;
        }
      }
    }

    // Step 2: Fetch and update each unique record
    for (var group in groupedData.values) {
      final reqid = group['REQ_ID'];
      final cusno = group['CUSTOMER_NUMBER'];
      final cussite = group['CUSTOMER_SITE_ID'];
      final invoiceno = group['INVOICE_NO'];
      final itemcode = group['ITEM_CODE'];
      final totalTruckQty = group['TOTAL_QTY'];

      try {
        final IpAddress = await getActiveIpAddress();
        final getUrl = Uri.parse(
            '$IpAddress/GetidCreateDispatchView$parameterdivided$reqid$parameterdivided$cusno$parameterdivided$cussite$parameterdivided$invoiceno$parameterdivided$itemcode$parameterdivided');
        final headers = {"Content-Type": "application/json"};

        print("Fetching record from $getUrl");

        final getResponse = await http.get(getUrl, headers: headers);

        if (getResponse.statusCode == 200) {
          final List<dynamic> records = json.decode(getResponse.body);

          if (records.isNotEmpty) {
            final fetchedRecord = records[0];

            final id = fetchedRecord['id'];
            final dispatchQty = int.tryParse(
                    fetchedRecord['DISPATCHED_QTY']?.toString() ?? '0') ??
                0;
            final dispatchScanQty = int.tryParse(
                    fetchedRecord['TRUCK_SCAN_QTY']?.toString() ?? '0') ??
                0;

            if (id != null) {
              final num finalDispatchManagerQty = totalTruckQty;
              final num finalTruckScanQty = dispatchScanQty + totalTruckQty;

              print(
                  "Updating ID $id => DISPATCHED_BY_MANAGER: $finalDispatchManagerQty, TRUCK_SCAN_QTY: $finalTruckScanQty");

              final updateUrl = Uri.parse('$IpAddress/Create_Dispatch/$id/');
              final body = json.encode({
                // "FLAG": "R",
                "TRUCK_SCAN_QTY": finalTruckScanQty,
                "DISPATCHED_BY_MANAGER": finalDispatchManagerQty,
              });

              final putResponse =
                  await http.put(updateUrl, headers: headers, body: body);

              if (putResponse.statusCode == 200) {
                print('Successfully updated record for ID: $id');
              } else {
                print(
                    'Failed to update record for ID: $id. Status code: ${putResponse.statusCode}');
              }
            } else {
              print(
                  'No valid ID found for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno');
            }
          } else {
            print(
                'No record found for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno, CUSTOMER_SITE_ID: $cussite, ITEM_CODE: $itemcode');
          }
        } else {
          print(
              'Failed to fetch record. Status code: ${getResponse.statusCode}');
        }
      } catch (e) {
        print(
            'Error fetching or updating record for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno: $e');
      }
    }
  }

  Future<void> fetchLastReturnNo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno');

    final IpAddress = await getActiveIpAddress();
    final String url = '$IpAddress/Return_dispatchNo/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String lastreturnid = data['RETURN_ID']?.toString() ?? '';

        // Get current year and month
        DateTime now = DateTime.now();
        String year = now.year.toString().substring(2); // '25'
        String month = now.month.toString().padLeft(2, '0'); // '05'
        String prefix = 'RD$year$month'; // 'RD2505'

        int newNumber = 1; // default number if no valid last return ID

        if (lastreturnid.isNotEmpty && lastreturnid.startsWith(prefix)) {
          String numberPart = lastreturnid
              .substring(prefix.length); // Extract number after prefix
          if (numberPart.isNotEmpty && int.tryParse(numberPart) != null) {
            int lastNumber = int.parse(numberPart);
            newNumber = lastNumber + 1;
          }
        }

        // No need to pad if you want just the next number appended (e.g., RD25052)
        String newReturnId = '$prefix$newNumber';

        ReturnNoController.text = newReturnId;
        print("ReturnNoController: ${ReturnNoController.text}");
      } else {
        ReturnNoController.text = "RETNO_ERR";
      }
    } catch (e) {
      ReturnNoController.text = "RETNO_EXC";
      print("Exception: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Future<void> fetchLastReturnNo() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? salesloginno = prefs.getString('salesloginno');

  //   final IpAddress = await getActiveIpAddress();

  //   final url = '$IpAddress/Return_dispatchNo/';

  //   try {
  //     final response = await http.get(Uri.parse(url));

  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       String lastReturndisno = data['RETURN_DIS_ID']?.toString() ?? '0';
  //       int newreturnid = int.tryParse(lastReturndisno) != null
  //           ? int.parse(lastReturndisno) + 1
  //           : 1;
  //       ReturnNoController.text = newreturnid.toString();
  //     } else {
  //       print('Error: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching request number: $e');
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> updateOracleQuantity(int UndelId, int qty) async {
    final TestingOracleIpAddress = await getActiveOracleIpAddress();

    String url = '$TestingOracleIpAddress/subtract-qty/$UndelId/$qty/';

    print('Calling updateOracleQuantity for UndelId: $UndelId, qty: $qty');
    print('Request URL OracleTable : $url');

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Status Code Oracle: ${response.statusCode}');
      print('Response Body Oracle: ${response.body}');

      if (response.statusCode == 200) {
        print("✅ QTY updatedOracle successfully for UndelId $UndelId");
      } else {
        print("❌ Error in UpdateOracle qty: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Exception Oracle: $e");
    }
  }

  Future<void> updateQuantity(int UndelId, int qty) async {
    final IpAddress = await getActiveIpAddress();

    String url = '$IpAddress/subractUpdate-qty/$UndelId/$qty/';

    print('Calling updateQuantity for UndelId: $UndelId, qty: $qty');
    print('Request URL: $url');

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print("✅ QTY updated successfully for UndelId $UndelId");
      } else {
        print("❌ Error in Update qty: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Exception: $e");
    }
  }

  Future<void> postTransactionDetails() async {
    print("Entered in to the Transaction");
    final ipAddress = await getActiveIpAddress();
    final url = '$ipAddress/add_transaction_detail/';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saveloginname = prefs.getString('saveloginname') ?? '';

    DateTime now = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

    try {
      Map<String, Map<String, dynamic>> aggregatedData = {};
      int undelId = 0;
      for (var row in createtableData) {
        undelId = int.tryParse(row['UNDEL_ID']?.toString() ?? '0') ?? 0;
        var itemCode = row['ITEM_CODE']?.toString() ?? 'UNKNOWN';
        var sendQty =
            int.tryParse(row['TRUCK_SEND_QTY']?.toString() ?? '0') ?? 0;
        await updateQuantity(undelId, sendQty);
        await updateOracleQuantity(undelId, sendQty);
        if (!aggregatedData.containsKey(itemCode)) {
          aggregatedData[itemCode] = {
            "CUSTOMER_TRX_ID":
                int.tryParse(row['CUSTOMER_TRX_ID']?.toString() ?? '0') ?? 0,
            "CUSTOMER_TRX_LINE_ID":
                int.tryParse(row['CUSTOMER_TRX_LINE_ID']?.toString() ?? '0') ??
                    0,
            "ITEM_ID": itemCode,
            "LINE_NO": int.tryParse(row['LINE_NO']?.toString() ?? '0') ?? 0,
            "QTY": sendQty,
          };
        } else {
          aggregatedData[itemCode]!["QTY"] += sendQty;
        }
      }

      for (var entry in aggregatedData.entries) {
        var itemCode = entry.key;
        var data = entry.value;

        returnid =
            ReturnNoController.text.isNotEmpty ? ReturnNoController.text : '';

        var summedQty = data["QTY"] ?? 0;
        var finalSummedQty = summedQty; // Making it negative as required

        Map<String, dynamic> createDispatchData = {
          "UNDEL_ID": undelId, // Replace with real UNDEL_ID if available
          "TRANSACTION_DATE": formattedDate,
          "CUSTOMER_TRX_ID": data["CUSTOMER_TRX_ID"],
          "CUSTOMER_TRX_LINE_ID": data["CUSTOMER_TRX_LINE_ID"],
          "ITEM_ID": itemCode,
          "LINE_NO": data["LINE_NO"],
          "QTY": finalSummedQty,
          "SOURCE": "Return Delivery dispatch",
          "TRANSACTION_TYPE": "INBOUND",
          "DISPATCH_ID": returnid,
          "REFERENCE1": "",
          "REFERENCE2": "",
          "REFERENCE3": "",
          "REFERENCE4": "",
          "CREATED_BY": saveloginname.isNotEmpty ? saveloginname : 'Unknown',
          "CREATED_IP": "",
          "CREATED_MAC": "",
          "LAST_UPDATED_BY":
              saveloginname.isNotEmpty ? saveloginname : 'Unknown',
          "LAST_UPDATE_IP": "",
          "LAST_UPDATE_MAC": "",
          "CREATION_DATE": formattedDate,
          "LAST_UPDATE_DATE": formattedDate,
          "FLAG": "R"
        };

        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(createDispatchData),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('✅ Posted successfully: $itemCode → $finalSummedQty');
        } else {
          print('❌ Failed for $itemCode: ${response.statusCode}');
          print(response.body);
        }
      }
    } catch (e) {
      print('❗ Error posting transaction: $e');
    }
  }

  // Future<void> postTransactionDetails() async {
  //   final IpAddress = await getActiveIpAddress();

  //   final url = '$IpAddress/TransactionDetail/';

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? saveloginname = prefs.getString('saveloginname') ?? '';

  //   DateTime now = DateTime.now();
  //   String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

  //   try {
  //     String returnNo =
  //         ReturnNoController.text.isNotEmpty ? ReturnNoController.text : '';
  //     String disReqNoValue =
  //         returnNo.split('_').last; // Get the value after the last underscore

  //     // Aggregate tableData by itemCode
  //     Map<String, Map<String, dynamic>> aggregatedData = {};
  //     print("createtableDataaaaa $createtableData");
  //     int undelId = 0;
  //     for (var row in createtableData) {
  //       undelId = int.tryParse(row['UNDEL_ID']?.toString() ?? '0') ?? 0;
  //       var itemCode = row['ITEM_CODE']?.toString() ?? '0';
  //       var sendQty =
  //           int.tryParse(row['TRUCK_SEND_QTY']?.toString() ?? '0') ?? 0;
  //       await updateQuantity(undelId, sendQty);
  //       await updateOracleQuantity(undelId, sendQty);
  //       if (!aggregatedData.containsKey(itemCode)) {
  //         aggregatedData[itemCode] = {
  //           "CUSTOMER_TRX_ID":
  //               double.tryParse(row['CUSTOMER_TRX_ID']?.toString() ?? '0') ??
  //                   0.0,
  //           "CUSTOMER_TRX_LINE_ID": double.tryParse(
  //                   row['CUSTOMER_TRX_LINE_ID']?.toString() ?? '0') ??
  //               0.0,
  //           "ITEM_ID":
  //               double.tryParse(row['ITEM_CODE']?.toString() ?? '0') ?? 0.0,
  //           "LINE_NO":
  //               double.tryParse(row['LINE_NO']?.toString() ?? '0') ?? 0.0,
  //           "QTY": sendQty,
  //         };
  //       } else {
  //         aggregatedData[itemCode]!["QTY"] += sendQty;
  //       }
  //     }

  //     // Create and send POST requests for each unique itemCode
  //     for (var entry in aggregatedData.entries) {
  //       var itemCode = entry.key;
  //       var data = entry.value;

  //       var summedQty = data["QTY"] ?? 0;
  //       var finalSummedQty = (summedQty).toStringAsFixed(0);

  //       print("final qty of the tablde item code $finalSummedQty");

  //       Map<String, dynamic> createDispatchData = {
  //         'UNDEL_ID': undelId,
  //         "TRANSACTION_DATE": formattedDate,
  //         "CUSTOMER_TRX_ID": data["CUSTOMER_TRX_ID"],
  //         "CUSTOMER_TRX_LINE_ID": data["CUSTOMER_TRX_LINE_ID"],
  //         "ITEM_ID": itemCode,
  //         "LINE_NO": data["LINE_NO"],
  //         "QTY": finalSummedQty,
  //         "SOURCE": 'Return dispatch',
  //         "TRANSACTION_TYPE": 'INBOUND',
  //         "DISPATCH_ID": disReqNoValue.isNotEmpty ? disReqNoValue : '0',
  //         "CREATION_DATE": formattedDate,
  //         "CREATED_BY": saveloginname.isNotEmpty ? saveloginname : 'Unknown',
  //         "LAST_UPDATE_DATE": formattedDate,
  //         "FLAG": 'N'
  //       };

  //       final response = await http.post(
  //         Uri.parse(url),
  //         headers: {
  //           'Content-Type': 'application/json',
  //         },
  //         body: jsonEncode(createDispatchData),
  //       );

  //       if (response.statusCode == 201) {
  //         print(
  //             'Dispatch created successfully for Item Code: $itemCode with Quantity: $finalSummedQty');
  //       } else {
  //         print(
  //             'Failed to create dispatch for Item Code: $itemCode. Status code: ${response.statusCode}');
  //         // print('Response body: ${response.body}');
  //       }
  //     }
  //   } catch (e) {
  //     print('Error occurred while posting dispatch data: $e');
  //   }
  // }

  SaveReturnProducts() {
    // Store the current context before showing the dialog
    final currentContext = context;

    showDialog(
      context: currentContext,
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
                  'Successfully added the Return Products',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                SharedPrefs.cleartockandreqno();
                postLogData("Return Dispatch Pop-up View", "Returned");

                if (mounted) {
                  setState(() {
                    createtableData = [];
                  });
                }

                // Close all open dialogs
                Navigator.of(context, rootNavigator: true)
                    .pop(); // Success dialog
                Navigator.of(currentContext, rootNavigator: true)
                    .pop(); // ReturnDialog
                Navigator.of(currentContext, rootNavigator: true)
                    .pop(); // Outer Dialog (if any)

                // Give some time to finish popping before navigating
                await Future.delayed(Duration(milliseconds: 100));

                // Use the original context to navigate
                if (mounted) {
                  Navigator.of(currentContext).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MainSidebar(
                        initialPageIndex: 10,
                        enabledItems: accessControl,
                      ),
                    ),
                  );
                }
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
