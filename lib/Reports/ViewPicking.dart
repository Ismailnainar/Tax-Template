import 'dart:typed_data'; // for Uint8List
import 'dart:io'; // for File
import 'package:path_provider/path_provider.dart'; // for getApplicationDocumentsDirectorys
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
import 'package:url_launcher/url_launcher.dart';

class ViewPicking extends StatefulWidget {
  const ViewPicking({super.key});

  @override
  State<ViewPicking> createState() => _ViewPickingState();
}

class _ViewPickingState extends State<ViewPicking> {
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
                                fillColor: readOnly
                                    ? Color.fromARGB(255, 240, 240, 240)
                                    : Color.fromARGB(255, 255, 255, 255),
                              ),
                              controller: TextEditingController(text: value),
                              style: TextStyle(
                                  color: Color.fromARGB(255, 73, 72, 72),
                                  fontSize: 13)),
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

  TextEditingController PickManSearchController =
      TextEditingController(text: "");

  Future<void> fetchPickDetails(String PickID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgid = prefs.getString('saleslogiOrgwarehousename') ?? '';
    String? salesloginno = prefs.getString('salesloginno') ?? '';

    final IpAddress = await getActiveIpAddress();

    try {
      final response =
          await http.get(Uri.parse('$IpAddress/ViewPickiddetails/$PickID'));

      // Debugging: Print status code and response body
      print('URLSSS: $IpAddress/ViewPickiddetails/$PickID');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        ShowWarning('Server error: ${response.statusCode}');
        return;
      }

      if (response.body.isEmpty) {
        ShowWarning('No data received from the server.');
        return;
      }

      dynamic data;
      try {
        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here

        data = json.decode(decodedBody);
      } catch (e) {
        ShowWarning(
            'Failed to decode JSON response. Check API response format.');
        print('Failed to decode JSON: $e');
        return;
      }

      if (data == null || (data is List && data.isEmpty)) {
        ShowWarning('Kindly enter a correct Pick_No.');
        return;
      }

      if (data is List) {
        List<Map<String, dynamic>> picklist =
            List<Map<String, dynamic>>.from(data);
        if (picklist.isNotEmpty) {
          var pickdetails = picklist[0];

          // Validate ORG_ID
          String orgId = pickdetails['TO_WAREHOUSE']?.toString() ?? '';
          if (orgId != saleslogiOrgid) {
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
                          PickManSearchController.text = '';
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
                pickdetails['TO_WAREHOUSE']?.toString() ?? '';
            _AssignedStaffController.text =
                pickdetails['ASS_PICKMAN']?.toString() ?? '';
            _CustomerNameController.text =
                pickdetails['CUSTOMER_NAME']?.toString() ?? '';
            _CussiteController.text =
                pickdetails['CUSTOMER_SITE_ID']?.toString() ?? '';
            _CusidController.text =
                pickdetails['CUSTOMER_NUMBER']?.toString() ?? '';
            PickManSearchController.text =
                '${pickdetails['PICK_ID']?.toString() ?? ''}';
            Salesman_channelController.text =
                pickdetails['SALES_CHANNEL']?.toString() ?? '';
            _RegionController.text = pickdetails['ORG_NAME']?.toString() ?? '';
            _Salesman_idmeController.text =
                pickdetails['SALESMAN_NO']?.toString() ?? '';

            // ✅ Safe CREATION_DATE formatting
            final rawCreationDate = pickdetails['CREATION_DATE'];
            if (rawCreationDate != null) {
              try {
                DateTime parsedDate;

                if (rawCreationDate is String) {
                  parsedDate = DateTime.parse(rawCreationDate);
                } else if (rawCreationDate is int) {
                  parsedDate = DateTime.fromMillisecondsSinceEpoch(
                      rawCreationDate * 1000);
                } else {
                  throw FormatException("Unknown date format");
                }

                _Creation_DateController.text =
                    DateFormat('dd MMM yyyy').format(parsedDate);
              } catch (e) {
                _Creation_DateController.text = '';
                print('Date parse error: $e');
              }
            } else {
              _Creation_DateController.text = '';
            }

            print(
                "_Creation_DateController.texeeeeeeet  ${_Creation_DateController.text}");
            getTableData = List<Map<String, dynamic>>.from(
                pickdetails['TABLE_DETAILS'] ?? []);
            _updatesendqty();
          });
        } else {
          ShowWarning('No details found for the provided PickNo.');
        }
      } else {
        ShowWarning('Unexpected data format received from the server.');
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

  List<Map<String, dynamic>> tableData = [
    // {
    //   'id': 1,
    //   'invoiceno': '2411026553',
    //   'itemcode': 'DEG78888E',
    //   'itemdetails': 'A/C',
    //   'disreqqty': '67',
    //   'dispatchqty': '0',
    //   'balanceqty': '167',
    //   'sendqty': '0',
    //   'status': 'Pending'
    // },
    // {
    //   'id': 2,
    //   'invoiceno': '2411026599',
    //   'itemcode': 'DEG77887D',
    //   'itemdetails': 'Washing Machine',
    //   'disreqqty': '107',
    //   'dispatchqty': '0',
    //   'balanceqty': '107',
    //   'sendqty': '0',
    //   'status': 'Pending'
    // },
    // {
    //   'id': 3,
    //   'invoiceno': '2411026583',
    //   'itemcode': 'DEG77888H',
    //   'itemdetails': 'Refrigerator',
    //   'disreqqty': '107',
    //   'dispatchqty': '0',
    //   'balanceqty': '57',
    //   'sendqty': '50',
    //   'status': 'Pending'
    // },
  ];

  @override
  void initState() {
    super.initState();
    // _updatecount();
    // _updatesendqty();
    _loadSalesmanName();
    fetchAccessControl();
    fetchStaffList();
    // fetchDataReqnO();
    // fetchLastPickNo();
    // Initialize controllers and focus nodes for each row
    tableData.forEach((row) {
      _controllers.add(TextEditingController(text: "0"));
      _focusNodes.add(FocusNode());
    });

    postLogData("View Picking", "Opened");
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    // Dispose of controllers, focus nodes, and cancel the timer
    _controllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((focusNode) => focusNode.dispose());

    postLogData("View Picking", "Closed");
    super.dispose();
  }

  List<String> AssignedstaffList = [];

  bool isLoading = true;

  Future<void> fetchStaffList() async {
    final IpAddress = await getActiveIpAddress();

    final String initialUrl = '$IpAddress/User_member_details/';
    String? nextPageUrl = initialUrl;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgid = prefs.getString('saleslogiOrgwarehousename') ?? '';
    try {
      List<String> tempPickmanNames = [];

      while (nextPageUrl != null) {
        var response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          if (data['results'] != null && data['results'].isNotEmpty) {
            for (var result in data['results']) {
              // Check if the role is 'pickman' before adding the name
              if (result['PHYSICAL_WAREHOUSE'] == saleslogiOrgid) {
                if (result['EMP_NAME'] != null &&
                    result['EMP_ROLE'] == 'Pickup') {
                  // Correctly concatenate EMP_NAME and EMPLOYEE_ID
                  tempPickmanNames
                      .add('${result['EMP_NAME']} - ${result['EMPLOYEE_ID']}');
                }
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
                        ? screenWidth * 0.23
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
          controller: _AssignedStaffController,
          decoration: InputDecoration(
            // hintText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            filled: true,
            fillColor: Color.fromARGB(255, 255, 255, 255),
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            ),
            prefixIcon: Icon(
              Icons.house_siding,
              size: 12,
            ),
          ),
          style: TextStyle(fontSize: 12),
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
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    suggestion,
                    style: TextStyle(fontSize: 12),
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
          // Split the suggestion string to extract the name
          String selectedName =
              suggestion.split(' - ')[0]; // Get the name before the " - "
          setState(() {
            _AssignedStaffController.text =
                selectedName; // Set the controller text to only the name
            assignedstaffselectedValue =
                selectedName; // Update the selected value
            _filterEnabledassignedstaff = false; // Disable filtering
          });
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: TextStyle(fontSize: 12),
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

  List<double> columnWidths = [100, 70, 120, 530, 130, 140, 140, 100];

  Widget _buildTable() {
    double screenHeight = MediaQuery.of(context).size.height;
    double widthFactor = Responsive.isDesktop(context) ? 0.79 : 1.7;
    double heightFactor =
        Responsive.isDesktop(context) ? screenHeight * 0.3 : 250;
    double rowHeight = Responsive.isDesktop(context) ? 25 : 30;

    List<Map<String, dynamic>> headers = [
      {"icon": Icons.receipt_long, "text": "Invoice.No"},
      {"icon": Icons.format_list_numbered, "text": "I.L.No"},
      {"icon": Icons.qr_code, "text": "Item Code"},
      {"icon": Icons.info_outline, "text": "Item Description"},
      {"icon": Icons.inventory, "text": "Qty.Invoiced"},
      {"icon": Icons.add_shopping_cart, "text": "Qty.Requested"},
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
                                  width: columnWidths[headers
                                      .indexOf(header)], // Use fixed widths
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    border:
                                        Border.all(color: Colors.grey[400]!),
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
                                            // if (header['text'] == "Qty.Picking")
                                            //   if (header['text'] == "Qty.Picking")
                                            //     StatefulBuilder(builder:
                                            //         (BuildContext context,
                                            //             StateSetter setState) {
                                            //       return Tooltip(
                                            //         message: "Select All",
                                            //         child: Transform.scale(
                                            //           scale:
                                            //               0.6, // Adjust the scale factor to make the checkbox smaller
                                            //           child: Checkbox(
                                            //             value: isChecked,
                                            //             onChanged: (value) {
                                            //               setState(() {
                                            //                 isChecked =
                                            //                     value!; // Update the state
                                            //                 for (int i = 0;
                                            //                     i < tableData.length;
                                            //                     i++) {
                                            //                   double disreqQty =
                                            //                       double.tryParse(
                                            //                               _removeDecimalIf(
                                            //                                   tableData[
                                            //                                           i]
                                            //                                       [
                                            //                                       'disreqqty'])) ??
                                            //                           0.0;
                                            //                   if (isChecked) {
                                            //                     _controllers[i].text =
                                            //                         disreqQty
                                            //                             .toString();
                                            //                     tableData[i]
                                            //                             ['sendqty'] =
                                            //                         disreqQty
                                            //                             .toString(); // Update sendqty

                                            //                     _updatesendqty();
                                            //                   } else {
                                            //                     _controllers[i].text =
                                            //                         ""; // Clear text
                                            //                     tableData[i]
                                            //                             ['sendqty'] =
                                            //                         ""; // Clear sendqty if unchecked
                                            //                     totalSendqtyController
                                            //                         .text = '0';
                                            //                   }
                                            //                 }
                                            //               });
                                            //             },
                                            //           ),
                                            //         ),
                                            //       );
                                            //     })
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          // if (_isLoading)
                          //   Padding(
                          //     padding: const EdgeInsets.only(top: 60.0),
                          //     child: Center(child: CircularProgressIndicator()),
                          //   )
                          if (getTableData.isNotEmpty)
                            ...getTableData.asMap().entries.map((entry) {
                              int index = entry.key;
                              var data = entry.value;
                              return _buildRow(index, data);
                            }).toList()
                          else
                            Padding(
                              padding: const EdgeInsets.only(top: 60.0),
                              child: Text(
                                  "Kindly enter a PickNo to view details.."),
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

  Widget _buildRow(int index, Map<String, dynamic> data) {
    bool isEvenRow = index % 2 == 0;
    Color? rowColor = Color.fromARGB(224, 255, 255, 255);

    if (double.tryParse(data['DISPATCHED_QTY']?.toString() ?? '0') == 0) {
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
            _buildDataCell(data['INVOICE_NUMBER']?.toString() ?? '', rowColor,
                width: columnWidths[0]),
            _buildDataCell(data['LINE_NUMBER']?.toString() ?? '', rowColor,
                width: columnWidths[1]),
            _buildDataCell(
                data['INVENTORY_ITEM_ID']?.toString() ?? '', rowColor,
                width: columnWidths[2]),
            _buildDataCell(data['ITEM_DESCRIPTION']?.toString() ?? '', rowColor,
                width: columnWidths[3]),
            _buildDataCell(data['TOT_QUANTITY']?.toString() ?? '', rowColor,
                width: columnWidths[4]),
            _buildDataCell(data['DISPATCHED_QTY']?.toString() ?? '', rowColor,
                width: 135),
            _buildDataCell(data['PICKED_QTY']?.toString() ?? '', rowColor,
                width: 120),
            _buildDataCell(
              data['STATUS']?.toString() ?? '', // Use a fallback value
              rowColor,
              width: columnWidths[7],
            ),
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
            child: SelectableText(
              text,
              textAlign: TextAlign.left,
              style: commonLabelTextStyle,
              showCursor: false,
              // overflow: TextOverflow.ellipsis,
              cursorColor: Colors.blue,
              cursorWidth: 2.0,
              toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
              onTap: () {
                // Optional: Handle single tap if needed
              },
            ),
            //  Text(
            //   text,
            //   textAlign: TextAlign.left, // Align text to the start (left)
            //   style: commonLabelTextStyle,
            //   overflow: TextOverflow.ellipsis, // Avoid overflow
            // ),
          ),
        ],
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
          padding: const EdgeInsets.only(bottom: 7),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              double enteredQty = double.tryParse(value) ?? 0.0;
              double balanceQtyDouble = double.tryParse(disreqqty) ?? 0.0;

              setState(() {
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
                                            fontSize: 15, color: Colors.black),
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
                                        // Set qty to invoicebalqty when clicking "Yes"
                                        setState(() {
                                          _controllers[index].text =
                                              disreqqty.toString();
                                          tableData[index]['sendqty'] =
                                              disreqqty.toString();
                                          _updatesendqty();
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    SizedBox(width: 10),
                                    TextButton(
                                      child: Text('No'),
                                      onPressed: () {
                                        // Set qty to "0" when clicking "No"
                                        setState(() {
                                          _controllers[index].text = "0";
                                          tableData[index]['sendqty'] = "0";
                                          _updatesendqty();
                                        });
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
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
                }
              });
              _updatesendqty();
            },
            onSubmitted: (value) {
              _updatesendqty();
            },
            textAlign: TextAlign.center,
            decoration: InputDecoration(border: InputBorder.none),
          ),
        ),
      ),
    );
  }

//   Widget _buildTextFieldCell(
//     int index, String disreqqty, String balanceqty, Color rowColor) {
//   // Store the original balance quantity in the tableData if not stored before
//   if (!tableData[index].containsKey('oldBalanceQty')) {
//     tableData[index]['oldBalanceQty'] = balanceqty;
//   }
//   if (!tableData[index].containsKey('currentBalanceQty')) {
//     tableData[index]['currentBalanceQty'] = balanceqty;
//   }

//   return Flexible(
//     child: Container(
//       height: 30,
//       decoration: BoxDecoration(
//         color: rowColor,
//         border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
//       ),
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.only(bottom: 5),
//           child: TextField(
//             controller: _controllers[index],
//             focusNode: _focusNodes[index],
//             keyboardType: TextInputType.number,
//             inputFormatters: <TextInputFormatter>[
//               FilteringTextInputFormatter.digitsOnly,
//             ],
//             onChanged: (value) {
//               double enteredQty = double.tryParse(value) ?? 0.0;
//               double currentBalanceQty =
//                   double.tryParse(tableData[index]['currentBalanceQty']) ?? 0.0;

//               setState(() {
//                 if (enteredQty > currentBalanceQty) {
//                   showDialog(
//                     context: context,
//                     barrierDismissible: false,
//                     builder: (BuildContext context) {
//                       return Dialog(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         backgroundColor: Colors.white,
//                         child: SizedBox(
//                           width: MediaQuery.of(context).size.width * 0.3,
//                           child: Padding(
//                             padding: const EdgeInsets.all(20.0),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Icon(Icons.warning_rounded,
//                                         color: Colors.red),
//                                     SizedBox(width: 10),
//                                     Expanded(
//                                       child: Text(
//                                         'You entered more than the Dispatch Request quantity. Do you want to adjust to ${disreqqty} or reset to 0?',
//                                         style: TextStyle(
//                                             fontSize: 13, color: Colors.black),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 20),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     TextButton(
//                                       child: Text('Yes'),
//                                       onPressed: () {
//                                         // Set qty to dispatch request quantity when "Yes" is clicked
//                                         setState(() {
//                                           _controllers[index].text = disreqqty;
//                                           tableData[index]['sendqty'] =
//                                               disreqqty;
//                                           double originalBalanceQty =
//                                               double.tryParse(tableData[index]
//                                                       ['oldBalanceQty']) ??
//                                                   0.0;
//                                           tableData[index]['currentBalanceQty'] =
//                                               (originalBalanceQty -
//                                                       double.tryParse(disreqqty)!)
//                                                   .toString();
//                                           tableData[index]['balanceqty'] =
//                                               tableData[index]
//                                                   ['currentBalanceQty'];
//                                         });
//                                         Navigator.of(context)
//                                             .pop(); // Close the dialog
//                                       },
//                                     ),
//                                     TextButton(
//                                       child: Text('No'),
//                                       onPressed: () {
//                                         // Reset picking qty to 0
//                                         setState(() {
//                                           _controllers[index].text = "0";
//                                           tableData[index]['sendqty'] = "0";
//                                           tableData[index]['balanceqty'] =
//                                               tableData[index]['oldBalanceQty'];
//                                           tableData[index]['currentBalanceQty'] =
//                                               tableData[index]['oldBalanceQty'];
//                                         });
//                                         Navigator.of(context)
//                                             .pop(); // Close the dialog
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 } else {
//                   // Update the current balance quantity when valid qty is entered
//                   double originalBalanceQty =
//                       double.tryParse(tableData[index]['oldBalanceQty']) ?? 0.0;
//                   tableData[index]['currentBalanceQty'] =
//                       (originalBalanceQty - enteredQty).toString();
//                   tableData[index]['balanceqty'] =
//                       tableData[index]['currentBalanceQty'];
//                 }
//               });
//             },
//             onSubmitted: (value) {},
//             textAlign: TextAlign.center,
//             decoration: InputDecoration(border: InputBorder.none),
//           ),
//         ),
//       ),
//     ),
//   );
// }

// Function to show a dialog and adjust the qty if needed
  void _showDialogAndSetQty(BuildContext context, int index, double disreqqty) {
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
              Expanded(
                child: Text(
                  'You entered more than the Balance quantity. The quantity will be adjusted to $disreqqty.',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
            ],
          ),
        );
      },
    );

    // Automatically close the dialog after 1 second
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  TextEditingController NoofitemController = TextEditingController(text: '0');
  TextEditingController totalSendqtyController =
      TextEditingController(text: '0');

  void _updatecount() {
    setState(() {
      // Ensure that getcount returns an integer value and then convert it to a string
      NoofitemController.text =
          getcount(getTableData).toString(); // Convert int to string
    });
    print("NoofitemController amountttt ${NoofitemController.text}");
  }

  int getcount(List<Map<String, dynamic>> getTableData) {
    return getTableData.length;
  }

// Helper function to remove .0 if the number is a whole number
  String _removeDecimalIfWhole(String value) {
    double? parsedValue = double.tryParse(value);
    if (parsedValue != null) {
      return parsedValue
          .truncate()
          .toString(); // Convert to whole number string
    }
    return value; // Return original value if parsing fails
  }

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
      var dispatchedByManager = data['PICKED_QTY'].toString();
      print('DISPATCHED_BY_MANAGER value: $dispatchedByManager');

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

  TextEditingController _InvoiceNumberController = TextEditingController();
  TextEditingController _ReqnoController = TextEditingController();
  TextEditingController _PicknoController = TextEditingController();
  TextEditingController _DateController = TextEditingController();
  TextEditingController _CusidController = TextEditingController();
  TextEditingController _CussiteController = TextEditingController();
  TextEditingController _CustomerNameController = TextEditingController();
  TextEditingController _RegionController = TextEditingController();
  TextEditingController _WarehousenameNameController = TextEditingController();
  TextEditingController _CustomerNumberController = TextEditingController();

  TextEditingController _Org_idController = TextEditingController();
  TextEditingController _Org_nameController = TextEditingController();
  TextEditingController _Salesman_idmeController = TextEditingController();

  TextEditingController deliverAddressController = TextEditingController();
  TextEditingController _Creation_DateController = TextEditingController();
  TextEditingController Salesman_channelController = TextEditingController();
  TextEditingController IdController = TextEditingController();

  Future<void> fetchDataReqnO() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? reqno = prefs.getString('reqno');

    final IpAddress = await getActiveIpAddress();

    final response = await http
        .get(Uri.parse('$IpAddress/filtered_dispatchrequest/$reqno/'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData =
          json.decode(response.body); // Ensure this is a list

      if (responseData.isEmpty || responseData[0] == null) {
        print("Empty or invalid response data");
        return;
      }

      final data =
          responseData[0]; // Get the first item from the response array

      setState(() {
        // Update the controller fields

        _ReqnoController.text = data['REQ_ID']?.toString() ?? '';
        _DateController.text = data['INVOICE_DATE']?.toString() ?? '';

        _InvoiceNumberController.text =
            data['INVOICE_NUMBER']?.toString() ?? '';
        _CusidController.text = data['CUSTOMER_NUMBER']?.toString() ?? '';
        _CussiteController.text = data['CUSTOMER_SITE_ID']?.toString() ?? '';
        _CustomerNameController.text = data['CUSTOMER_NAME']?.toString() ?? '';

        _CustomerNumberController.text =
            data['CUSTOMER_NUMBER']?.toString() ?? '';
        _RegionController.text = data['ORG_NAME']?.toString() ?? '';
        _WarehousenameNameController.text =
            data['TO_WAREHOUSE']?.toString() ?? '';
        _Salesman_idmeController.text = data['SALESREP_ID']?.toString() ?? '';
        final timestamp = data['CREATION_DATE'];
        if (timestamp is int) {
          final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
          _Creation_DateController.text =
              DateFormat('dd MMM yyyy').format(date);
        } else {
          _Creation_DateController.text =
              data['CREATION_DATE']?.toString() ?? '';
        }

        // _Creation_DateController.text = data['CREATION_DATE']?.toString() ?? '';
        Salesman_channelController.text =
            data['SALES_CHANNEL']?.toString() ?? '';

        _Org_idController.text = data['ORG_ID']?.toString() ?? '';
        _Org_nameController.text = data['ORG_NAME']?.toString() ?? '';
        print(
            "_Creation_DateController.text  ${_Creation_DateController.text}");
        // Clear the existing table data and populate with new data
        tableData = [];

        if (data['TABLE_DETAILS'] != null) {
          for (var item in data['TABLE_DETAILS']) {
            tableData.add({
              'Row_id': item['ID']?.toString() ?? '',

              'id': item['LINE_NUMBER']?.toString() ?? '',
              'invoiceno': item['INVOICE_NUMBER']?.toString() ?? '',
              'itemcode': item['INVENTORY_ITEM_ID']?.toString() ?? '',
              'itemdetails': item['ITEM_DESCRIPTION']?.toString() ??
                  '', // Adjust based on actual details

              'invoiceQty': item['TOT_QUANTITY']?.toString() ?? '0',

              'totaldisreqqty': item['DISPATCHED_QTY']?.toString() ?? '0',
              'disreqqty': item['DISPATCHED_BY_MANAGER']?.toString() ?? '0',
              'balanceqty': item['BALANCE_QTY']?.toString() ?? '0',
              'sendqty': '0', // Initial value for sending quantity
              'dispatchqty': '0',
              'status': 'Pending',

              'amount': item['AMOUNT']?.toString() ?? '0',
              'item_cost': item['ITEM_COST']?.toString() ?? '0',
            });
          }
          _initializeControllers(); // Initialize controllers based on tableData length
        }
      });
    } else {
      print('Failed to load dispatch request details: ${response.statusCode}');
    }
  }

  Future<void> fetchLastPickNo() async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/highest-pick/'; // Ensure this URL is correct

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the response body as JSON
        var data = json.decode(response.body);

        // Ensure 'PICK_ID' exists and is a string, or default to '0'
        String lastPickNo = data['PICK_ID']?.toString() ?? '0';

        // Increment the last PICK_ID
        int newPickNo =
            int.tryParse(lastPickNo) != null ? int.parse(lastPickNo) + 1 : 1;
        _PicknoController.text = newPickNo.toString();

        print('_PicknoController No: ${_PicknoController.text}');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching PICK_ID: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                                    Icons.visibility,
                                    size: 28,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'View Picking',
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
                                      ? screenWidth * 0.10
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
                                            Text('Pick_No',
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
                                                    ? screenWidth * 0.10
                                                    : screenWidth * 0.4,
                                                child: MouseRegion(
                                                  cursor: SystemMouseCursors
                                                      .click, // Changes the cursor to indicate interaction

                                                  child: TextFormField(
                                                    controller:
                                                        PickManSearchController,
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
                                                    style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 73, 72, 72),
                                                        fontSize: 13),
                                                    onFieldSubmitted: (value) {
                                                      String? pickNo =
                                                          PickManSearchController
                                                              .text
                                                              .toString();

                                                      if (pickNo != null &&
                                                          pickNo.isNotEmpty) {
                                                        fetchPickDetails(
                                                            pickNo);
                                                        _updatesendqty();
                                                      } else {
                                                        ShowWarning(
                                                            'Kindly enter a Pick_No');
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
                                // Padding(
                                //   padding: Responsive.isDesktop(context)
                                //       ? EdgeInsets.only(top: 50)
                                //       : EdgeInsets.all(0),
                                //   child: Container(
                                //     decoration:
                                //         BoxDecoration(color: buttonColor),
                                //     child: ElevatedButton(
                                //       style: ElevatedButton.styleFrom(
                                //         shape: RoundedRectangleBorder(
                                //           borderRadius:
                                //               BorderRadius.circular(8),
                                //         ),
                                //         minimumSize: const Size(45.0, 20.0),
                                //         backgroundColor: Colors.transparent,
                                //         shadowColor: Colors.transparent,
                                //       ),
                                //       child: Padding(
                                //         padding: const EdgeInsets.only(
                                //             top: 0,
                                //             bottom: 0,
                                //             left: 0,
                                //             right: 0),
                                //         child: const Text(
                                //           'Search',
                                //           style: TextStyle(
                                //               fontSize: 16,
                                //               color: Colors.white),
                                //         ),
                                //       ),
                                //       onPressed: () {},
                                //     ),
                                //   ),
                                // ),
                                Padding(
                                  padding: Responsive.isDesktop(context)
                                      ? EdgeInsets.only(top: 45)
                                      : EdgeInsets.only(top: 48),
                                  child: Tooltip(
                                    message: 'Search',
                                    child: Container(
                                      width:
                                          40, // Adjust width to match the input field
                                      height:
                                          37, // Increase height for proper alignment

                                      color: buttonColor,

                                      child: IconButton(
                                        onPressed: () {
                                          String? value =
                                              PickManSearchController.text;
                                          String? pickNo =
                                              PickManSearchController.text
                                                  .toString();

                                          if (pickNo != null &&
                                              pickNo.isNotEmpty) {
                                            fetchPickDetails(pickNo);
                                            _updatesendqty();
                                          } else {
                                            ShowWarning(
                                                'Kindly enter a Pick_No');
                                          }

                                          postLogData("View Picking", "Search");
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
                                SizedBox(
                                  width: 10,
                                ),
                                _buildTextFieldDesktop(
                                    'Creation Date',
                                    _Creation_DateController.text,
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
                                            'Picked Items:',
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
                                    Container(
                                      width: Responsive.isDesktop(context)
                                          ? MediaQuery.of(context).size.width *
                                              0.24
                                          : 180,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 20),
                                            Row(
                                              children: const [
                                                Text("Assign PickMan",
                                                    style: textboxheading),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0, bottom: 0),
                                              child: Container(
                                                  child:
                                                      _buildAssignedStaffDropdown()),
                                            ),
                                          ],
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
                                            0.1),
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
                                              Row(
                                                children: const [
                                                  Text("Total Picking Qty",
                                                      style: textboxheading),
                                                ],
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
                                                                horizontal:
                                                                    10.0),
                                                        filled: true,
                                                        fillColor:
                                                            Color.fromARGB(255,
                                                                255, 255, 255),
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
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: Responsive.isDesktop(context) ? 45 : 5,
                                ),
                                Container(
                                    height: 35,
                                    decoration:
                                        BoxDecoration(color: buttonColor),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (PickManSearchController
                                                .text.isEmpty ||
                                            _ReqnoController.text.isEmpty) {
                                          showMessage("Kindly Fill all fields",
                                              isError: true);
                                        } else {
                                          await assignPickman();
                                          await _launchUrl(context);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                            top: 5,
                                            bottom: 5,
                                            left: 8,
                                            right: 8),
                                        child: const Text(
                                          'Update Assign',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                      ),
                                    )),
                              ],
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

  Future<void> assignPickman() async {
    final String pickid = PickManSearchController.text.trim();
    final String reqno = _ReqnoController.text.trim();
    final String pickmanName = _AssignedStaffController.text.trim();

    if (pickid.isEmpty || reqno.isEmpty || pickmanName.isEmpty) {
      showMessage("Please fill all fields", isError: true);
      return;
    }
    final IpAddress = await getActiveIpAddress();

    final url = Uri.parse(
        '$IpAddress/Update_assign_Pickman/'); // Replace with your actual API URL

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'pickid': pickid,
          'reqno': reqno,
          'pickman_name': pickmanName,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 &&
          responseData['message'] == 'Pickman assigned successfully') {
        showMessage(responseData['message'], isError: false);
      } else if (response.statusCode == 400 &&
          responseData['message'] ==
              'Pickman has already started scanning. Cannot assign again.') {
        showMessage(responseData['message'], isError: true);
      } else {
        showMessage('Unexpected response: ${responseData['message']}',
            isError: true);
      }
    } catch (e) {
      showMessage('Error occurred: $e', isError: true);
    }
  }

  Future<void> fetchDispatchDetails(String reqNo) async {
    String cusno = _CusidController.text;

    String cussite = _CussiteController.text.toString();

    final IpAddress = await getActiveIpAddress();

    final url =
        '$IpAddress/FilteredCreateDispatchView/${reqNo}/$cusno/$cussite/';
    print("urlllllllllllllll : $url  ");
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final firstItem = data[0];
          setState(() {
            deliverAddressController.text = firstItem['DELIVERYADDRESS'] ?? '';

            print(
                "deliverAddressController : ${deliverAddressController.text}  ");
          });
        } else {
          // Handle empty data
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('No data found for the given details.')),
          // );
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error fetching details: $e')),
      // );
    }
  }

  _launchUrl(BuildContext context) async {
    String reqno = _ReqnoController.text.trim();

    await fetchDispatchDetails(
        reqno); // Ensure this updates getTableData properly

    List<String> productDetails = [];
    int snoCounter = 1;

    print("getTableData: ${deliverAddressController.text}");

    // Merge logic
    List<Map<String, dynamic>> mergeTableData(List<Map<String, dynamic>> data) {
      Map<String, Map<String, dynamic>> mergedData = {};

      for (var item in data) {
        String key =
            '${item['INVOICE_NUMBER']}-${item['INVENTORY_ITEM_ID']}-${item['ITEM_DESCRIPTION']}';

        if (mergedData.containsKey(key)) {
          mergedData[key]!['sendqty'] +=
              int.tryParse(item['PICKED_QTY']?.toString() ?? '0') ?? 0;
        } else {
          mergedData[key] = {
            'sno': 0,
            'invoiceno': item['INVOICE_NUMBER']?.toString() ?? '',
            'itemcode': item['INVENTORY_ITEM_ID']?.toString() ?? '',
            'itemdetails': item['ITEM_DESCRIPTION']?.toString() ?? '',
            'sendqty': int.tryParse(item['PICKED_QTY']?.toString() ?? '0') ?? 0,
          };
        }
      }
      print("mergedData.values  ${mergedData.values} ");

      return mergedData.values.toList();
    }

    List<Map<String, dynamic>> mergedData = mergeTableData(getTableData);

    for (var data in mergedData) {
      if (data['sendqty'] > 0) {
        data['sno'] = snoCounter++;

        String formattedProduct =
            "{${data['sno']}|${data['invoiceno']}|${data['itemcode']}|${data['itemdetails']}|${data['sendqty']}}";
        productDetails.add(formattedProduct);
      }
    }

    String productDetailsString = productDetails.join(',');
    print("productDetailsStringaaaaa$productDetailsString ");
    DateTime today = DateTime.now();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uniqulastpcikno = PickManSearchController.text.isNotEmpty
        ? PickManSearchController.text
        : '';
// Format the date
    String formattedDate = _Creation_DateController.text.isNotEmpty
        ? _Creation_DateController.text
        : '';

    print(formattedDate); // Output: 11-Jan-2025 (example)
    // String pickid =
    //     _PicknoController.text.isNotEmpty ? _PicknoController.text : '';

    String region =
        _RegionController.text.isNotEmpty ? _RegionController.text : '';
    String pickmanname = _AssignedStaffController.text.isNotEmpty
        ? _AssignedStaffController.text
        : '';

    String customerno =
        _CusidController.text.isNotEmpty ? _CusidController.text : '';

    String customername = _CustomerNameController.text.isNotEmpty
        ? _CustomerNameController.text
        : '';
    String customersite =
        _CussiteController.text.isNotEmpty ? _CussiteController.text : '';
    String sendqty = totalSendqtyController.text.isNotEmpty
        ? totalSendqtyController.text
        : 'null';
// Construct the dynamic URL
    String deliveryaddress = deliverAddressController.text.isNotEmpty
        ? deliverAddressController.text
        : 'null';

    final IpAddress = await getActiveOracleIpAddress();

//     String dynamicUrl =
//         '$IpAddress/Generate_picking_print$parameterdivided$uniqulastpcikno$parameterdivided$reqno$parameterdivided$region$parameterdivided$pickmanname$parameterdivided$deliveryaddress$parameterdivided$formattedDate$parameterdivided$customerno$parameterdivided$customername$parameterdivided$customersite$parameterdivided$sendqty$parameterdivided$productDetailsString$parameterdivided';

//     // 'http://192.168.10.139:82//print/DINE-IN%20ORDER/$tableno/$formattedDate/$formattedTime/$serventName/$productDetailsString';
// // http://192.168.10.140:82//print/DINE-IN%20ORDER/5/2024-08-21/12:30:00%20AM/John/product1,2;product2,3;product3,1/

//     print('urlllllllllll : $dynamicUrl');

// // Launch the dynamic URL
//     if (await canLaunch(dynamicUrl)) {
//       await launch(
//         dynamicUrl,
//         enableJavaScript: true,
//       ); // Enable JavaScript if necessary,forceSafariVC: false, forceWebView: false);
//     } else {
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   SnackBar(content: Text('Could not launch $dynamicUrl')),
//       // );
//     }

    final Uri url = Uri.parse('$IpAddress/Generate_picking_print/').replace(
      queryParameters: {
        "pickid": uniqulastpcikno,
        "reqno": reqno,
        "region": region,
        "pickmanname": pickmanname,
        "deliveryaddress": deliveryaddress,
        "date": formattedDate,
        "customerNo": customerno,
        "customername": customername,
        "customersite": customersite,
        "itemtotalqty": sendqty.toString(),
        "products_param": productDetailsString,
      },
    );

    print('urlllllllllll : $url');

// Launch the dynamic URL
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  void showMessage(String message, {required bool isError}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: isError ? Colors.red[50] : Colors.green[50],
        title: Text(
          isError ? 'Warning' : 'Success',
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await fetchAccessControl();
              isError
                  ? Navigator.of(context).pop()
                  : await Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainSidebar(
                            enabledItems: accessControl, initialPageIndex: 4),
                      ),
                    );
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void checkpickman() {
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
              SizedBox(
                  width: 8), // Optional: Add some spacing between icon and text
              Text(
                'Kindly Select the Pickman.',
                style: TextStyle(fontSize: 13, color: Colors.black),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Handle the OK button press
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'OK',
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.blue), // Customize the text style as needed
              ),
            ),
          ],
        );
      },
    );
  }

  void checkpickQty() {
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
              SizedBox(
                  width: 8), // Optional: Add some spacing between icon and text
              Text(
                'Kindly Enter the Picking Qty.',
                style: TextStyle(fontSize: 13, color: Colors.black),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Handle the OK button press
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'OK',
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.blue), // Customize the text style as needed
              ),
            ),
          ],
        );
      },
    );
  }

  clearallcontroller() {
    // _PicknoController.clear();
    _ReqnoController.clear();
    _WarehousenameNameController.clear();
    _RegionController.clear();
    _CustomerNameController.clear();
    _CusidController.clear();
    _CussiteController.clear();
    tableData.clear();
    _AssignedStaffController.clear();
    SharedPrefs.clearreqnoAll();
    fetchLastPickNo();
  }

  void successfullyLoginMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.check_circle_rounded, color: Colors.green),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                'Assigned Dispatch Request Successfully !!',
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

  Future<bool?> _showAsignedDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.delete, size: 18),
                  SizedBox(
                    width: 4,
                  ),
                  Text('Confirm Assign',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.grey),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to Assigned the Dispatch Quantity?',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Loop through each item in tableData and update the quantities
                  for (var i = 0; i < tableData.length; i++) {
                    var item = tableData[i];

                    // Convert disreqqty and sendqty to int to perform subtraction
                    int disreqqty = int.tryParse(item['disreqqty']) ?? 0;
                    int sendqty = int.tryParse(item['sendqty']) ?? 0;

                    // Update dispatchqty
                    item['dispatchqty'] = sendqty.toString();

                    // Calculate new balanceqty (disreqqty - sendqty)
                    item['balanceqty'] = (disreqqty - sendqty).toString();

                    // Reset sendqty to 0
                    item['sendqty'] = '0';

                    // Update the corresponding controller text for sendqty
                    _controllers[i].text = '0';
                  }

                  totalSendqtyController.text = '0';
                });

                // Display the success message
                successfullyLoginMessage();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: buttonColor,
                minimumSize: Size(30.0, 28.0),
              ),
              child: Text('Yes, Sure',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  Future<void> postDispatchRequest() async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/Dispatch_request/';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno') ?? '';
    String? saveloginname = prefs.getString('saveloginname') ?? '';

    DateTime now = DateTime.now();
    // Format it to YYYY-MM-DD'T'HH:mm:ss'
    String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

    try {
      String reqno = _ReqnoController.text.toString();
      String pickno =
          _PicknoController.text.isNotEmpty ? _PicknoController.text : '';
      String assignpcikman = _AssignedStaffController.text.isNotEmpty
          ? _AssignedStaffController.text
          : '';
      String warehouse = _WarehousenameNameController.text.isNotEmpty
          ? _WarehousenameNameController.text
          : '';
      String org_id =
          _Org_idController.text.isNotEmpty ? _Org_idController.text : '';
      String org_name =
          _Org_nameController.text.isNotEmpty ? _Org_nameController.text : '';
      String salesman_id = _Salesman_idmeController.text.isNotEmpty
          ? _Salesman_idmeController.text
          : '';
      String salesman_channel = Salesman_channelController.text.isNotEmpty
          ? Salesman_channelController.text
          : '0';
      String cusid =
          _CusidController.text.isNotEmpty ? _CusidController.text : '0';
      String cusname = _CustomerNameController.text.isNotEmpty
          ? _CustomerNameController.text
          : '';
      String cusno = _CustomerNumberController.text.isNotEmpty
          ? _CustomerNumberController.text
          : '0';
      String cussite =
          _CussiteController.text.isNotEmpty ? _CussiteController.text : '0';
      String invoiceno = _InvoiceNumberController.text.isNotEmpty
          ? _InvoiceNumberController.text
          : '';

      //  'invoiceno': item['INVOICE_NUMBER']?.toString() ?? '',
      // 'itemcode': item['INVENTORY_ITEM_ID']?.toString() ?? '',
      // 'itemdetails': item['INVENTORY_ITEM_ID']?.toString() ??
      //     '', // Adjust based on actual details
      // 'disreqqty': item['DISPATCHED_QTY']?.toString() ?? '0',
      // 'balanceqty': item['BALANCE_QTY']?.toString() ?? '0',
      // 'sendqty': '0', // Initial value for sending quantity
      // 'dispatchqty': '0',
      // 'status': 'Pending',

      // Iterate through each row in tableData and create dispatch data for each row
      for (int i = 0; i < tableData.length; i++) {
        var row = tableData[i]; // Use 'i' to access the correct row
        var disreqQty = double.tryParse(_controllers[i].text) ?? 0.0;
        print("Processing row with ID: ${row['Row_id']?.toString() ?? '0'}");
        print("Processing row with ID: ${row['Row_id']?.toString() ?? '0'}");

        print("tabl;e to send to the generate dispatch $tableData");

        String rowid = row['Row_id']?.toString() ?? "0";
        double dispatchedQty =
            (double.tryParse(row['disreqqty']?.toString() ?? '0') ?? 0.0) -
                disreqQty;

        // Update the dispatched quantity for the current row
        await updateDispatchedQty(rowid, dispatchedQty.toString());
        String Date = DateFormat('yyyy-MM-dd').format(DateTime.now());

        if (disreqQty > 0) {
          Map<String, dynamic> createDispatchData = {
            "PICK_ID": pickno,
            "DATE": Date,
            "REQ_ID": reqno,
            "ASS_PICKMAN": assignpcikman,
            "TO_WAREHOUSE": warehouse,
            "ORG_ID": org_id,
            "ORG_NAME": org_name,
            "SALESREP_ID": salesman_id,
            "SALESMAN_NO": salesloginno.isNotEmpty ? salesloginno : 'Unknown',
            "SALESMAN_NAME":
                saveloginname.isNotEmpty ? saveloginname : 'Unknown',
            "SALES_CHANNEL": salesman_channel,
            "CUSTOMER_ID": cusid,
            "CUSTOMER_NUMBER": cusno,
            "CUSTOMER_NAME": cusname,
            "CUSTOMER_SITE_ID": cussite,
            "INVOICE_DATE": formattedDate,
            "INVOICE_NUMBER": invoiceno,
            "LINE_NUMBER": row['id']?.toString() ?? '0',
            "INVENTORY_ITEM_ID": row['itemcode']?.toString() ?? '0',
            "ITEM_DESCRIPTION": row['itemdetails']?.toString() ?? '0',
            "TOT_QUANTITY": row['invoiceQty']?.toString() ?? '0',
            "DISPATCHED_QTY": row['disreqqty']?.toString() ?? '0',
            "BALANCE_QTY": row['balanceqty']?.toString() ?? '0',
            "PICKED_QTY": disreqQty.toString(),
            "AMOUNT": row['amount']?.toString() ?? '0',
            "ITEM_COST": row['item_cost']?.toString() ?? '0',
            "STATUS": "pending"
          };

          // Send the POST request for the row if disreqQty > 0
          final response = await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(createDispatchData),
          );

          if (response.statusCode == 201) {
            print(
                'Dispatch created successfully for Line Number: ${row['id']?.toString()}');
          } else {
            print(
                'Failed to create dispatch for Line Number: ${row['id']?.toString()}. Status code: ${response.statusCode}');
            print('Response body: ${response.body}');
          }

          // Increment reqno for the next iteration
          // int currentReqno = int.tryParse(reqno) ?? 0;
          // reqno = (currentReqno + 1).toString();
        }
      }
    } catch (e) {
      print('Error occurred while posting dispatch data: $e');
    }
  }

  Future<void> updateDispatchedQty(String id, String dispatchedQty) async {
    final IpAddress = await getActiveIpAddress();

    final String url =
        '$IpAddress/Create_Dispatch/$id/'; // Assuming id is in the URL

    try {
      // Prepare the body of the PUT request
      Map<String, dynamic> body = {
        "DISPATCHED_BY_MANAGER":
            dispatchedQty, // Key must match the field name in the Django model
      };

      // Make the PUT request
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // If the server returned a 200 OK response, the update was successful
        print("Dispatched quantity updated successfully for ID: $id");
      } else {
        // If the server did not return a 200 OK response, throw an error
        print("Failed to update dispatched quantity. Error: ${response.body}");
      }
    } catch (e) {
      // Handle errors like network issues, invalid URL, etc.
      print("An error occurred while updating dispatched quantity: $e");
    }
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
                            if (buttonname)
                              Container(
                                  height: 35,
                                  decoration: BoxDecoration(color: buttonColor),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      bool allFilled =
                                          true; // Assume all fields are filled initially

// Loop through the controllers to check if any field is empty
                                      for (int i = 0;
                                          i < _controllers.length;
                                          i++) {
                                        if (_controllers[i].text.isNotEmpty) {
                                          allFilled =
                                              false; // At least one field is filled, so we do not need to show the dialog
                                          break; // Exit the loop as soon as we find a non-empty field
                                        }
                                      }

// If all fields are empty, show the dialog
                                      if (allFilled) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.warning,
                                                    color: Colors.yellow,
                                                  ),
                                                  SizedBox(width: 2),
                                                  Text('Warning'),
                                                ],
                                              ),
                                              content: const Text(
                                                  "Kindly fill all the fields."),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                  child: const Text("OK"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else if (_AssignedStaffController
                                          .text.isNotEmpty) {
                                        // Show confirmation dialog before proceeding
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(Icons.delete,
                                                          size: 18),
                                                      SizedBox(
                                                        width: 4,
                                                      ),
                                                      Text('Confirm Assign',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 17)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              content: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Are you sure you want to Assigned the Dispatch Quantity?',
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  ),
                                                ],
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    // Close the dialog if "No" is pressed
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('No'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    // Perform actions if "Yes" is pressed
                                                    await postDispatchRequest();
                                                    await fetchLastPickNo();
                                                    setState(() {
                                                      _ReqnoController.clear();
                                                      _WarehousenameNameController
                                                          .clear();
                                                      _RegionController.clear();
                                                      _CustomerNameController
                                                          .clear();
                                                      _CusidController.clear();
                                                      _CussiteController
                                                          .clear();
                                                      tableData.clear();
                                                      _AssignedStaffController
                                                          .clear();
                                                      SharedPrefs
                                                          .clearreqnoAll();
                                                    });
                                                    // Close the dialog

                                                    Navigator.of(context).pop();

                                                    await Navigator
                                                        .pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MainSidebar(
                                                                enabledItems:
                                                                    accessControl,
                                                                initialPageIndex:
                                                                    2),
                                                      ),
                                                    );

                                                    // Navigator.pushReplacement(
                                                    //   context,
                                                    //   MaterialPageRoute(
                                                    //     builder: (context) =>
                                                    //         MainSidebar(
                                                    //             enabledItems:
                                                    //                 accessControl,
                                                    //             initialPageIndex:
                                                    //                 2), // Navigate to MainSidebar
                                                    //   ),
                                                    // );
                                                    // fetchAccessControl();
                                                  },
                                                  child: const Text('Yes'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else if (!allFilled) {
                                        checkpickQty();
                                      } else {
                                        checkpickman();
                                      }
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
                                        'Assign',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                  )),
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
                                Text(
                                  'aljeflutterapp',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[800],
                                  ),
                                ),
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
                              'Pick ID: 2311060380',
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
                                _AssignedStaffController.text,
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
                        Container(
                            height: 35,
                            decoration: BoxDecoration(color: buttonColor),
                            child: ElevatedButton(
                              onPressed: () async {
                                // await _savePdf();
                                _captureAndSavePdf();
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: const Size(45.0, 31.0),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 5, bottom: 5, left: 8, right: 8),
                                child: const Text(
                                  'Print',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            )),
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                            height: 35,
                            decoration: BoxDecoration(color: buttonColor),
                            child: ElevatedButton(
                              onPressed: () async {
                                // await _savePdf();
                                _captureAndSavePdf();
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: const Size(45.0, 31.0),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 5, bottom: 5, left: 8, right: 8),
                                child: const Text(
                                  'Generate Pdf',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            )),
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

// Helper function to build a detail row
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

// class PrintPreviewContainer extends StatelessWidget {
//   final List<Map<String, dynamic>> tableData;

//   PrintPreviewContainer({required this.tableData});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1.5),
//         borderRadius: BorderRadius.circular(5),
//       ),
//       child: IntrinsicHeight(
//         // Ensures the height matches PrintPreviewTable's height
//         child: SingleChildScrollView(
//             child: PrintPreviewTable(tableData: tableData)),
//       ),
//     );
//   }
// }

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
