import 'dart:io';

import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // For parsing JSON
import 'dart:async';
import 'package:aljeflutterapp/components/constaints.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart'
    hide Column, Row, Border, Stack;
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Stage_returnView extends StatefulWidget {
  final String reqno;

  const Stage_returnView(
    this.reqno,
  );

  @override
  State<Stage_returnView> createState() => _Stage_returnViewState();
}

class _Stage_returnViewState extends State<Stage_returnView> {
  List<String> CustomerNameList = [];
  List<String> CustomeSiteList = [];
  String? cusnameselectedValue;
  bool _filterEnabledcusname = true;
  int? _hoveredIndexcusname;
  int? _selectedIndexcusname;
  String? cussiteselectedValue;
  bool _filterEnabledcussite = true;
  int? _hoveredIndexcussite;
  int? _selectedIndexcussite;

  TextEditingController requestNoController = TextEditingController();
  TextEditingController CustomerNoController = TextEditingController();
  TextEditingController CustomeridController = TextEditingController();
  TextEditingController CustomerNameController = TextEditingController();
  TextEditingController CustomersiteidController = TextEditingController();
  TextEditingController CustomersitechannelController = TextEditingController();
  TextEditingController WarehouseNameController = TextEditingController();
  TextEditingController OrganisationIdController = TextEditingController();
  TextEditingController OrganisationNameController = TextEditingController();
  TextEditingController SalesmanIdeController = TextEditingController();
  TextEditingController SalesmanChannelController = TextEditingController();
  TextEditingController CustomerTrxidController = TextEditingController();
  TextEditingController CustomerTrxLineidController = TextEditingController();

  TextEditingController requestTypeNoController =
      TextEditingController(text: "");

  String? _warehouseName;
  String? _OrganisationId;
  String? _OrganisationName;
  String? _Salesmanid;
  String? _Salesmanchannel;

  bool totalinvoicecountbool = false;
  bool _isLoading = true;
  FocusNode requestnoFocusnode = FocusNode();
  FocusNode WarehouseFocusnode = FocusNode();
  FocusNode DateFocusNode = FocusNode();
  FocusNode CustomerNoFocusNode = FocusNode();
  FocusNode CustomerNameFocusNode = FocusNode();
  FocusNode CustomerSiteFocusNode = FocusNode();
  FocusNode SiteAddressFocusNode = FocusNode();
  FocusNode InvoiceFocusNode = FocusNode();

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  final ScrollController _horizontalScrollController2 = ScrollController();
  final ScrollController _verticalScrollController2 = ScrollController();
  bool _isSecondRowVisible = false;
  @override
  void initState() {
    super.initState();
    fetchAccessControl();
    _loadSalesmanName();
    requestTypeNoController.text = "";
    requestTypeNoController.text = "${widget.reqno}";
    print("requestno controller is ${requestTypeNoController.text}");
    if (widget.reqno.isNotEmpty) {
      fetchDispatchDetails(widget.reqno);
    }

    // Initialize total amount controller with initial values
    totalamountcontroller.text = "0";

    postLogData("Stage Return", "Opened");
  }

  String formattedDate = ''; // Declare at the class level
  List<Map<String, dynamic>> getTableData = [];

  Future<void> fetchDispatchDetails(String ReqNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgid = prefs.getString('saleslogiOrgwarehousename') ?? '';
    String? salesloginno = prefs.getString('salesloginno') ?? '';

    final IpAddress = await getActiveIpAddress();

    try {
      final response =
          await http.get(Uri.parse('$IpAddress/dispatch-details/$ReqNo/'));
      // print('Response body: ${response.body}');

      if (response.body == null || response.body.isEmpty) {
        ShowWarning('No data received from the server.');
        return;
      }

      var data;
      try {
        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here

        data = json.decode(decodedBody);
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
        List<Map<String, dynamic>> dispatchDetailsList =
            List<Map<String, dynamic>>.from(data);
        if (dispatchDetailsList.isNotEmpty) {
          var dispatchDetails = dispatchDetailsList[0];
          // print('Dispatch details fetched successfully: $dispatchDetails');

          String orgId = dispatchDetails['TO_WAREHOUSE']?.toString() ?? '';
          if (orgId != saleslogiOrgid) {
            // Show dialog box if ORG_ID does not match
            await showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Invalid Warehouse'),
                  content: Text(
                      'This Req ID is not associated with your warehouse details.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          requestTypeNoController.text = '';
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

          // Check if SALESMAN_NO matches salesloginno before showing the table data
          // String saleslogiOrgid = dispatchDetails['ORG_ID']?.toString() ?? '';
          // if (saleslogiOrgid != saleslogiOrgid) {
          //   await showDialog(
          //     barrierDismissible: false,
          //     context: context,
          //     builder: (BuildContext context) {
          //       return AlertDialog(
          //         title: Text('Access Denied'),
          //         content: Text(
          //             'This ReqId is not your entry. You do not have permission to access it.'),
          //         actions: [
          //           TextButton(
          //             onPressed: () {
          //               setState(() {
          //                 requestTypeNoController.text = '';
          //               });
          //               Navigator.of(context).pop();
          //             },
          //             child: Text('OK'),
          //           ),
          //         ],
          //       );
          //     },
          //   );
          //   return;
          // }

          String invoiceDateStr =
              dispatchDetails['INVOICE_DATE']?.toString() ?? '';
          formattedDate = invoiceDateStr.isNotEmpty
              ? DateFormat('d-MMM-yyyy').format(DateTime.parse(invoiceDateStr))
              : 'Invalid date';

          setState(() {
            CustomerNoController.text =
                dispatchDetails['CUSTOMER_NUMBER']?.toString() ?? '';
            CustomeridController.text =
                dispatchDetails['CUSTOMER_ID']?.toString() ?? '';
            CustomerNameController.text =
                dispatchDetails['CUSTOMER_NAME']?.toString() ?? '';
            CustomersiteidController.text =
                dispatchDetails['CUSTOMER_SITE_ID']?.toString() ?? '';
            CustomersitechannelController.text =
                dispatchDetails['SALES_CHANNEL']?.toString() ?? '';
            WarehouseNameController.text =
                dispatchDetails['TO_WAREHOUSE']?.toString() ?? '';
            OrganisationIdController.text =
                dispatchDetails['ORG_ID']?.toString() ?? '';
            OrganisationNameController.text =
                dispatchDetails['ORG_NAME']?.toString() ?? '';
            SalesmanIdeController.text =
                dispatchDetails['SALESMAN_NO']?.toString() ?? '';
            SalesmanChannelController.text =
                dispatchDetails['SALESREP_ID']?.toString() ?? '';
            CustomerTrxidController.text =
                dispatchDetails['CUSTOMER_TRX_ID']?.toString() ?? '';
            CustomerTrxLineidController.text =
                dispatchDetails['CUSTOMER_TRX_LINE_ID']?.toString() ?? '';
            getTableData = List<Map<String, dynamic>>.from(
                dispatchDetails['TABLE_DETAILS'] ?? []);
            _updatecount();
            _updatedisreqamt();
          });
        } else {
          ShowWarning('Kindly enter a correct Req No.');
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

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget _buildTextFieldDesktop(String label, String value, IconData icon,
      bool readonly, FocusNode fromFocusNode, FocusNode toFocusNode,
      {void Function(String)?
          onFieldSubmitted} // optional parameter for the onFieldSubmitted callback
      ) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Use the controller passed from the parent widget for the TextField
    TextEditingController controller = TextEditingController(text: value);

    return Container(
      width: Responsive.isDesktop(context)
          ? screenWidth * 0.13
          : screenWidth * 0.4,
      child: Padding(
        padding: const EdgeInsets.only(left: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Text(label, style: TextStyle(fontSize: 13)),
                if (!readonly)
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
                    height: 32,
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
                        message: value,
                        child: TextFormField(
                          focusNode: fromFocusNode,
                          readOnly: readonly,
                          onFieldSubmitted: onFieldSubmitted,
                          controller:
                              controller, // Use the controller with the initial value
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
                            fillColor: Color.fromARGB(255, 250, 250, 250),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 5.0,
                              horizontal: 10.0,
                            ),
                          ),
                          style: TextStyle(
                              color: Color.fromARGB(255, 73, 72, 72),
                              fontSize: 12),
                          onEditingComplete: () => _fieldFocusChange(
                              context, fromFocusNode, toFocusNode),
                        ),
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

  List<Map<String, dynamic>> tableData = [];
  Map<int, FocusNode> _focusNodess = {}; // Manage FocusNodes
  Map<int, Color> rowColors = {}; // Track row colors
  Map<int, bool> isEditable = {}; // Track editable rows

  Widget _buildTable() {
    if (Responsive.isMobile(context)) {
      return _buildMobileCardView();
    } else {
      return _buildDesktopTableView();
    }
  }

  Widget _buildMobileCardView() {
    // Sort tableData based on the ID
    List<Map<String, dynamic>> sortedTableData = List.from(getTableData)
      ..sort((a, b) => int.parse(a['ID'].toString())
          .compareTo(int.parse(b['ID'].toString())));

    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.all(8),
      itemCount: sortedTableData.length,
      itemBuilder: (context, index) {
        final data = sortedTableData[index];
        return Container(
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.white,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100.withOpacity(0.3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.receipt, color: Colors.blue.shade700, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Invoice ${data['INVOICE_NUMBER']}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${data['LINE_NUMBER']}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Code & Description
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.inventory,
                              size: 18, color: Colors.blue.shade800),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['INVENTORY_ITEM_ID']?.toString() ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                data['ITEM_DESCRIPTION']?.toString() ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Quantity Indicators
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildQuantityIndicator(
                            'Qty.Invoiced',
                            data['TOT_QUANTITY'],
                            Colors.orange.shade700,
                          ),
                          _buildQuantityIndicator(
                            'Dis.Req.Qty',
                            data['DISPATCHED_QTY'],
                            Colors.green.shade700,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuantityIndicator(String label, dynamic value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value?.toString() ?? '0',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemDescHeaderCell(IconData? icon, String? label) {
    return Container(
      height: 30,
      width: Responsive.isDesktop(context)
          ? MediaQuery.of(context).size.width * 0.4
          : MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(color: Colors.grey[300]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, size: 15, color: Colors.blue),
          SizedBox(width: 5),
          if (label != null)
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(IconData? icon, String? label) {
    return Flexible(
      child: Container(
        height: 30,
        decoration: BoxDecoration(color: Colors.grey[300]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (icon != null) Icon(icon, size: 15, color: Colors.blue),
            SizedBox(width: 5),
            if (label != null)
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  // Define originalData map
  Map<int, Map<String, dynamic>> originalData = {};

// Initialize originalData when the row is first created
  void initializeOriginalData(int index, Map<String, dynamic> data) {
    if (!originalData.containsKey(index)) {
      originalData[index] = Map<String, dynamic>.from(data);
      print(
          "Initialized originalData for index $index: ${originalData[index]}");
    }
  }

// Modify _buildDataRow to ensure initialization
  Widget _buildDataRow(Map<String, dynamic> data, int index) {
    // Initialize the original data if not already done
    initializeOriginalData(index, data);

    final List<String> keys = [
      'INVOICE_NUMBER',
      'LINE_NUMBER',
      'INVENTORY_ITEM_ID',
      'ITEM_DESCRIPTION',
      'TOT_QUANTITY',
      'DISPATCHED_QTY',
    ];

    final defaultColor =
        index % 2 == 0 ? Color(0xFFE0FFFFFF) : Color(0xFFFFFFFF);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        color: rowColors[index] ?? defaultColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ...keys.map((key) {
              if (key == 'ITEM_DESCRIPTION') {
                // Apply custom design for the Item Description column
                return _buildItemDescDataCell(data, key, index);
              } else {
                return _buildDataCell(data, key, index);
              }
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTableView() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Sort tableData based on the ID
    List<Map<String, dynamic>> sortedTableData = List.from(getTableData)
      ..sort((a, b) => int.parse(a['ID'].toString())
          .compareTo(int.parse(b['ID'].toString())));

    final headers = [
      {'icon': Icons.receipt, 'label': 'Invoice No'},
      {'icon': Icons.list_alt, 'label': 'I.L.No'},
      {'icon': Icons.code, 'label': 'Item Code'},
      {'icon': Icons.description, 'label': 'Item Description'},
      {'icon': Icons.check_circle, 'label': 'Qty. Invoiced'},
      {'icon': Icons.assignment, 'label': 'Dis.Req.Qty'},
    ];

    return Container(
      width: screenWidth,
      child: ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(Colors.grey[600]),
          thumbVisibility: MaterialStateProperty.all(true),
          thickness: MaterialStateProperty.all(8),
          radius: const Radius.circular(10),
        ),
        child: Scrollbar(
          thumbVisibility: true,
          controller: _horizontalScrollController2,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _horizontalScrollController,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: screenHeight * 0.4,
                  width: screenWidth * 0.8,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: headers.map((header) {
                            IconData? icon = header['icon'] as IconData?;
                            String? label = header['label'] as String?;
                            if (label == 'Item Description') {
                              return _buildItemDescHeaderCell(icon, label);
                            } else {
                              return _buildHeaderCell(icon, label);
                            }
                          }).toList(),
                        ),
                      ),
                      if (sortedTableData.isNotEmpty)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: sortedTableData.asMap().entries.map(
                                (entry) {
                                  final int index = entry.key;
                                  final data = entry.value;
                                  return _buildDataRow(data, index);
                                },
                              ).toList(),
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child:
                              Text("Kindly enter a ReqNo to view dispatch..."),
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

  Widget _buildActionsCell(Map<String, dynamic> data, int index) {
    return Flexible(
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFE2E1E1)),
        ),
        child: Row(
          children: [
            Tooltip(
              message: 'Edit',
              child: IconButton(
                onPressed: () {
                  setState(() {
                    isEditable[index] = !(isEditable[index] ?? false);
                    rowColors[index] = (isEditable[index] ?? false
                        ? Colors.green.withOpacity(0.3)
                        : null)!;
                    if (isEditable[index] == true) {
                      data['flag'] = 'E';

                      _focusNodess[index]?.requestFocus();
                    }
                  });
                },
                icon: Icon(Icons.edit, color: Colors.green, size: 18),
              ),
            ),
            Tooltip(
                message: 'Delete',
                child: GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      // Reset row color to default
                      rowColors[index] = Color(0xFFE0FFFFFF);

                      // Revert DISPATCHED_QTY to its original value (store the original value somewhere initially)
                      data['DISPATCHED_QTY'] =
                          originalData[index]?['DISPATCHED_QTY'];

                      // Update the flag to 'A'
                      data['flag'] = 'A';

                      print(
                          'Row $index reset: ${data['DISPATCHED_QTY']} with flag ${data['flag']}');
                    });
                  },
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        // Update the row color to indicate deletion
                        rowColors[index] = Colors.red.withOpacity(0.3);

                        // Set flag to 'D'
                        data['flag'] = 'D';
                      });
                    },
                    icon: Icon(Icons.delete, color: Colors.red, size: 18),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell(Map<String, dynamic> data, String key, int index) {
    final bool editable = isEditable[index] ?? false;
    _focusNodess[index] ??= FocusNode();

    final controller = TextEditingController(text: data[key]?.toString() ?? '');

    return Flexible(
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFE2E1E1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: editable && (key == 'DISPATCHED_QTY')
                  ? TextField(
                      controller: controller,
                      focusNode: _focusNodess[index],
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onChanged: (newValue) {
                        final dispatchedQty = double.tryParse(newValue);
                        final totalQuantity = double.tryParse(
                                data['TOT_QUANTITY']?.toString() ?? '0') ??
                            0;
                        data['DISPATCHED_QTY'] = controller.text;

                        if (dispatchedQty != null &&
                            dispatchedQty > totalQuantity) {
                          ShowWarning(
                              'Kindly enter a quantity that does not exceed the limit.');
                        }
                      },
                    )
                  : SelectableText(
                      data[key]?.toString() ?? '', // Use data value
                      textAlign: TextAlign.left,
                      style: TableRowTextStyle,
                      showCursor: false,
                      cursorColor: Colors.blue,
                      cursorWidth: 2.0,
                      toolbarOptions:
                          ToolbarOptions(copy: true, selectAll: true),
                      onTap: () {},
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDescDataCell(
      Map<String, dynamic> data, String key, int index) {
    final bool editable = isEditable[index] ?? false;
    _focusNodess[index] ??= FocusNode();

    final controller = TextEditingController(text: data[key]?.toString() ?? '');

    return Container(
      height: 30,
      width: Responsive.isDesktop(context)
          ? MediaQuery.of(context).size.width * 0.4
          : MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE2E1E1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SelectableText(
              data[key]?.toString() ?? '', // Use data value
              textAlign: TextAlign.left,
              style: TableRowTextStyle,
              showCursor: false,
              cursorColor: Colors.blue,
              cursorWidth: 2.0,
              toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

// Helper function to remove .0 if the number is whole
  String _removeDecimalIfWhole(dynamic value) {
    if (value is double) {
      if (value == value.toInt()) {
        return value
            .toInt()
            .toString(); // Convert to int if it's a whole number
      }
    }
    return value
        .toString(); // Return as string if it's not a double or has decimals
  }

  TextEditingController NoofitemController = TextEditingController(text: "0");
  TextEditingController totaldisreqController =
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

  void _updatedisreqamt() {
    setState(() {
      double totalAmount =
          gettotaldisreqamt(getTableData); // Get the total amount
      totaldisreqController.text =
          _removeDecimalIfWholeReqQty(totalAmount.toString()); // Ensure string
    });
    print("totaldisreqController amountttt ${totaldisreqController.text}");
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
      var dispatchedByManager = data['DISPATCHED_QTY'].toString();
      print('DISPATCHED_BY_MANAGER value: $dispatchedByManager');

      double quantity = double.tryParse(dispatchedByManager) ?? 0.0;
      totalQuantity += quantity;
    }
    return totalQuantity;
  }

  bool isLoading = true;
  Future<void> fetchCustomerNumbers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? salesloginno = prefs.getString('salesloginno');
    String? saleslogiOrgid = prefs.getString('saleslogiOrgid');

    final IpAddress = await getActiveIpAddress();

    final String initialUrl = '$IpAddress/CustomerNamelist/$salesloginno';
    String? nextPageUrl = initialUrl;
    // print("salesno : $salesloginno");
    try {
      List<String> tempCustomerDetails = [];

      while (nextPageUrl != null) {
        var response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          if (data['results'] != null && data['results'].isNotEmpty) {
            for (var result in data['results']) {
              String? customerNumber = result['customer_number'];
              String? customerName = result['customer_name'];

              // Check if both customer_number and customer_name are not null
              if (customerNumber != null && customerName != null) {
                tempCustomerDetails.add('$customerNumber: $customerName');
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
        CustomerNameList = tempCustomerDetails;
        isLoading = false;
        // print("customer list : $CustomerNameList");
      });
    } catch (e) {
      print('Error fetching customer numbers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCustomerDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno');
    String? saleslogiOrgid = prefs.getString('saleslogiOrgid');

    final IpAddress = await getActiveIpAddress();

    String baseUrl = '$IpAddress/CustomerNamelist/$salesloginno';
    String customerNumber = CustomerNoController.text;
    String? nextPageUrl = baseUrl;

    print("baseUrl : $baseUrl");
    CustomerNameController.clear();
    try {
      bool customerFound = false;

      // Loop through each page until customer details are found or no more pages
      while (nextPageUrl != null && nextPageUrl.isNotEmpty && !customerFound) {
        final response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<dynamic> results = data['results'];

          // Find the matching customer details
          for (var entry in results) {
            if (entry['customer_number'] == customerNumber) {
              setState(() {
                // Set the text values of the controllers
                CustomerNameController.text = entry['customer_name'] ?? '';
                // CustomeridController.text =
                //     entry['customer_id'].toString() ?? '';
                // CustomersiteidController.text =
                //     entry['customer_site_id'].toString() ?? '';
                // CustomersitechannelController.text =
                //     entry['customer_site_channel'].toString() ?? '';
              });

              // Print the values to verify
              // print('Customer Name: ${CustomerNameController.text}');
              // print('Customer Site ID: ${CustomersiteidController.text}');
              customerFound = true;
              break; // Exit the loop after finding the customer
            }
          }

          // Update nextPageUrl to check the next page if available
          nextPageUrl = data['next'];
        } else {
          print('Failed to fetch customer details: ${response.statusCode}');
          break;
        }
      }

      if (!customerFound) {
        print('Customer with number $customerNumber not found in any page.');
      }
    } catch (e) {
      print('Error fetching customer details: $e');
    }
  }

  Future<void> fetchCustomerSiteNumbers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgid = prefs.getString('saleslogiOrgid');
    String customerno = CustomerNoController.text;
    String customername = CustomerNameController.text;

    final IpAddress = await getActiveIpAddress();

    final String initialUrl =
        '$IpAddress/CustomerSiteIDList/$saleslogiOrgid/$customerno';
    String? nextPageUrl = initialUrl;
    print("customersite url $initialUrl");

    try {
      List<String> tempCustomerDetails = [];

      while (nextPageUrl != null) {
        var response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          if (data['results'] != null && data['results'] is List) {
            for (var result in data['results']) {
              // Extract site_use_id and ensure it's treated as a String
              String? customerSiteno = result['site_use_id']?.toString();

              // Check if customerSiteno is not null
              if (customerSiteno != null && customerSiteno.isNotEmpty) {
                tempCustomerDetails.add(customerSiteno);
              }
            }
          }

          // Update nextPageUrl for pagination
          nextPageUrl = data['next']?.toString();
        } else {
          print('Error: ${response.statusCode}');
          break;
        }
      }

      setState(() {
        CustomeSiteList = tempCustomerDetails;
        isLoading = false;
        print("CustomeSiteList list : $CustomeSiteList");
      });
    } catch (e) {
      print('Error fetching customer numbers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  TextEditingController TotalInvoiveCountController = TextEditingController();
  List<String> InvoiceNoList = [];
  Future<void> fetchInvoiceNumbers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno');
    String customerNumber = CustomerNoController.text;

    String customersite = CustomersiteidController.text;

    final IpAddress = await getActiveIpAddress();

    final String initialUrl =
        // '$IpAddress/invoice/?salesman_no=$salesloginno&customer_number=$customerNumber';

        '$IpAddress/invoice/$salesloginno/$customerNumber/$customersite';
    String? nextPageUrl = initialUrl;
    print("invoice numbers $initialUrl");

    try {
      // Temporary list to hold invoice numbers
      List<String> tempInvoiceNumbers = [];

      // Loop through all pages until 'next' is null
      while (nextPageUrl != null) {
        var response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          // Check if 'results' is not null or empty
          if (data['results'] != null && data['results'].isNotEmpty) {
            for (var result in data['results']) {
              if (result['invoice_number'] != null) {
                tempInvoiceNumbers.add(result['invoice_number']);
              }
            }
          }

          // print('Invoice list : $tempInvoiceNumbers');
          // print('Invoice initialUrl  : $initialUrl');

          // Get the next page URL, if available
          nextPageUrl = data['next'];
        } else {
          print('Error: ${response.statusCode} - ${response.body}');
          break;
        }
      }

      // Update the state with the fetched invoice numbers
      setState(() {
        InvoiceNoList = tempInvoiceNumbers;

        TotalInvoiveCountController.text = InvoiceNoList.length.toString();
        // print('Invoice Number List updated: $InvoiceNoList');
      });
    } catch (e) {
      print('Error fetching invoice numbers: $e');
    }
  }

  Widget _buildCustomerNameDropdown() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Container(
                      height: 32,
                      width: Responsive.isDesktop(context)
                          ? screenWidth * 0.1
                          : screenWidth * 0.4,
                      child: CustomerNameDropdown()),
                ],
              ),
            ),
            SizedBox(width: 3),
          ],
        ),
      ),
    );
  }

  Widget CustomerNameDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                CustomerNameList.indexOf(CustomerNoController.text);
            if (currentIndex < CustomerNameList.length - 1) {
              setState(() {
                _selectedIndexcusname = currentIndex + 1;
                // Take only the customer number part before the colon
                CustomerNoController.text =
                    CustomerNameList[currentIndex + 1].split(':')[0];
                _filterEnabledcusname = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                CustomerNameList.indexOf(CustomerNoController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndexcusname = currentIndex - 1;
                // Take only the customer number part before the colon
                CustomerNoController.text =
                    CustomerNameList[currentIndex - 1].split(':')[0];
                _filterEnabledcusname = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          enabled: false,
          focusNode: CustomerNoFocusNode,
          controller: CustomerNoController,
          onSubmitted: (String? suggestion) async {
            // InvoiceNoController.clear();

            // CustomersiteidController..clear();
            // await fetchInvoiceNumbers();
            // _fieldFocusChange(
            //     context, CustomerNoFocusNode, CustomerNameFocusNode);

            _handleCustomerNameChange(suggestion!);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Color.fromARGB(201, 132, 132, 132), width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.only(bottom: 10, left: 5),
            labelStyle: DropdownTextStyle,
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            ),
          ),
          style: DropdownTextStyle,
          onChanged: (text) {
            setState(() {
              _filterEnabledcusname = true;
              cussiteselectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabledcusname && pattern.isNotEmpty) {
            return CustomerNameList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return CustomerNameList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = CustomerNameList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndexcusname = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndexcusname = null;
            }),
            child: Container(
              color: _selectedIndexcusname == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndexcusname == null &&
                          CustomerNameList.indexOf(CustomerNoController.text) ==
                              index
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.transparent,
              height: 28,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                dense: true,
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(suggestion, style: TextStyle(fontSize: 15)),
                ),
              ),
            ),
          );
        },
        suggestionsBoxDecoration: const SuggestionsBoxDecoration(
          constraints: BoxConstraints(maxHeight: 150),
        ),
        onSuggestionSelected: (suggestion) {
          // setState(() {
          // Take only the customer number part before the colon
          //   CustomerNoController.text = suggestion.split(':')[0];
          //   cussiteselectedValue = suggestion;
          //   _filterEnabledcusname = false;

          //   FocusScope.of(context).requestFocus(CustomerNameFocusNode);
          //   InvoiceNoController.clear();
          //   CustomerNameController..clear();
          // });

          // fetchCustomerDetails();
          // fetchCustomerSiteNumbers();
          // fetchInvoiceNumbers();
          // CustomersiteidController..clear();
          _handleCustomerNameChange(suggestion);
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

  // Handle customer name change
  void _handleCustomerNameChange(String newCustomer) {
    // Check if tableData has any data
    if (tableData.isNotEmpty) {
      // Show confirmation dialog

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
                      'Changing the customer will clear the current dispatch details. Are you sure you want to proceed?',
                      style: TextStyle(fontSize: 13, color: Colors.black),
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          tableData.clear();
                          CustomerNoController.text = newCustomer.split(':')[0];
                          cussiteselectedValue = newCustomer;
                          _filterEnabledcusname = false;

                          // Fetch operations for the new customer
                          fetchCustomerDetails();
                          fetchCustomerSiteNumbers();
                          fetchInvoiceNumbers();
                          CustomersiteidController.clear();
                        });

                        CustomersiteidController.clear();
                        Navigator.pop(context); // Close the dialog
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                        backgroundColor: subcolor,
                        minimumSize: Size(30.0, 28.0),
                      ),
                      child: Text('Yes',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    SizedBox(
                      width: 15,
                    ),
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
                      child: Text('No',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            );
          });
    } else {
      // If tableData is empty, simply proceed without any confirmation
      setState(() {
        // Update selected customer value and text field controller
        CustomerNoController.text = newCustomer.split(':')[0];
        cussiteselectedValue = newCustomer;
        _filterEnabledcusname = false;

        // Perform necessary fetch operations
        fetchCustomerDetails();
        fetchCustomerSiteNumbers();
        fetchInvoiceNumbers();

        CustomersiteidController.clear();
        InvoiceNoController.clear();
        totalinvoicecountbool = false;
      });
    }
  }

  Widget _buildCustomerSiteDropdown() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Container(
                      height: 32,
                      width: Responsive.isDesktop(context)
                          ? screenWidth * 0.1
                          : screenWidth * 0.4,
                      child: CustomerSiteDropdown()),
                ],
              ),
            ),
            SizedBox(width: 3),
          ],
        ),
      ),
    );
  }

  Widget CustomerSiteDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                CustomeSiteList.indexOf(CustomersiteidController.text);
            if (currentIndex < CustomeSiteList.length - 1) {
              setState(() {
                _selectedIndexcussite = currentIndex + 1;
                // Take only the customer number part before the colon
                CustomersiteidController.text =
                    CustomeSiteList[currentIndex + 1].split(':')[0];
                _filterEnabledcussite = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                CustomeSiteList.indexOf(CustomersiteidController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndexcussite = currentIndex - 1;
                // Take only the customer number part before the colon
                CustomersiteidController.text =
                    CustomeSiteList[currentIndex - 1].split(':')[0];
                _filterEnabledcussite = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          enabled: false,
          focusNode: CustomerSiteFocusNode,
          controller: CustomersiteidController,
          onSubmitted: (String? suggestion) async {
            InvoiceNoController.clear();
            await fetchInvoiceNumbers();
            if (InvoiceNoList.isEmpty) {
              invoiceavailabilitycheck();
            } else {
              // invoictotalcount();
              totalinvoicecountbool = true;
            }
            _fieldFocusChange(context, CustomerSiteFocusNode, InvoiceFocusNode);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Color.fromARGB(201, 132, 132, 132), width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.only(bottom: 10, left: 5),
            labelStyle: DropdownTextStyle,
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            ),
          ),
          style: DropdownTextStyle,
          onChanged: (text) {
            setState(() {
              _filterEnabledcussite = true;
              cussiteselectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabledcussite && pattern.isNotEmpty) {
            return CustomeSiteList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return CustomeSiteList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = CustomeSiteList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndexcussite = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndexcussite = null;
            }),
            child: Container(
              color: _selectedIndexcussite == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndexcussite == null &&
                          CustomeSiteList.indexOf(
                                  CustomersiteidController.text) ==
                              index
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.transparent,
              height: 28,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                dense: true,
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(suggestion, style: TextStyle(fontSize: 15)),
                ),
              ),
            ),
          );
        },
        suggestionsBoxDecoration: const SuggestionsBoxDecoration(
          constraints: BoxConstraints(maxHeight: 150),
        ),
        onSuggestionSelected: (suggestion) async {
          setState(() {
            // Take only the customer number part before the colon
            CustomersiteidController.text = suggestion.split(':')[0];
            cussiteselectedValue = suggestion;
            _filterEnabledcussite = false;

            FocusScope.of(context).requestFocus(CustomerNameFocusNode);
            InvoiceNoController.clear();
          });

          await fetchInvoiceNumbers();

          if (InvoiceNoList.isEmpty) {
            invoiceavailabilitycheck();
          } else {
            // invoictotalcount();

            totalinvoicecountbool = true;
          }
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

  void invoiceavailabilitycheck() {
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
                  'No Invoice found for selected Customer',
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Clear fields and refocus
                CustomerNoController.clear();
                CustomersiteidController.clear();
                CustomerNameController.clear();
                // FocusScope.of(context).requestFocus(CustomerNoFocusNode);
                totalinvoicecountbool = false;

                // Close the dialog
                Navigator.of(context).pop();
                FocusScope.of(context).requestFocus(CustomerNoFocusNode);
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

  void invoictotalcount() {
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
                  'There are ${TotalInvoiveCountController.text} invoices available for the selected customer.',
                  style: TextStyle(fontSize: 13, color: Colors.black),
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

  String? selectedValue;
  bool _filterEnabled = true;
  int? _hoveredIndex;
  int? _selectedIndex;
  TextEditingController InvoiceNoController = TextEditingController();

  Widget _buildInvoiceNoDropdown() {
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
                    height: 32,
                    width: Responsive.isDesktop(context)
                        ? screenWidth * 0.1
                        : screenWidth * 0.4,
                    child: InvoiceNoDropdown()),
              ],
            ),
          ),
          SizedBox(width: 3),
        ],
      ),
    );
  }

  Widget InvoiceNoDropdown() {
    // Sort the InvoiceNoList in ascending order
    List<String> sortedInvoiceNoList = List.from(InvoiceNoList)..sort();

    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                sortedInvoiceNoList.indexOf(InvoiceNoController.text);
            if (currentIndex < sortedInvoiceNoList.length - 1) {
              setState(() {
                _selectedIndex = currentIndex + 1;
                InvoiceNoController.text =
                    sortedInvoiceNoList[currentIndex + 1];
                _filterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                sortedInvoiceNoList.indexOf(InvoiceNoController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndex = currentIndex - 1;
                InvoiceNoController.text =
                    sortedInvoiceNoList[currentIndex - 1];
                _filterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: InvoiceFocusNode,
          controller: InvoiceNoController,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.person,
              size: 12,
            ),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.only(bottom: 10, left: 5),
            labelStyle: DropdownTextStyle,
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            ),
          ),
          style: DropdownTextStyle,
          onChanged: (text) {
            setState(() {
              _filterEnabled = true;
              selectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabled && pattern.isNotEmpty) {
            return sortedInvoiceNoList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return sortedInvoiceNoList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = sortedInvoiceNoList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndex = null;
            }),
            child: Container(
              color: _selectedIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndex == null &&
                          sortedInvoiceNoList
                                  .indexOf(InvoiceNoController.text) ==
                              index
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.transparent,
              height: 28,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                dense: true,
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    suggestion,
                    style: textBoxstyle,
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
            InvoiceNoController.text = suggestion;
            selectedValue = suggestion;
            _filterEnabled = false;
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

  String? saveloginname = '';

  String? saveloginrole = '';

  String? commersialrole = '';

  String? commersialname = '';

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
      saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
      commersialrole =
          prefs.getString('commersialrole') ?? 'Unknown commersialrole';
      commersialname =
          prefs.getString('commersialname') ?? 'Unknown commersialname';
    });
  }

  Future<void> fetchWarehouseDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno');

    if (salesloginno == null) {
      // Handle case where salesloginno is null
      setState(() {
        _warehouseName = 'Salesman number not found';
      });
      return;
    }

    // Base URL with the salesman_no parameter

    final IpAddress = await getActiveIpAddress();

    String apiUrl =
        '$IpAddress/loginsalesmanwarehousedetails/?salesman_no=$salesloginno';

    // Initialize the warehouse name
    _warehouseName = null;

    while (apiUrl != null) {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check results
        if (data['results'] != null && data['results'].isNotEmpty) {
          for (var result in data['results']) {
            // Ensure that to_warehouse is available and is a string
            if (result['to_warehouse'] is String) {
              setState(() {
                _warehouseName = result['to_warehouse'];
                _OrganisationId = result['org_id'];
                _OrganisationName = result['org_name'];
                _Salesmanid = result["salesrep_id"];

                _Salesmanchannel = result["salesman_channel"];
                WarehouseNameController.text =
                    _warehouseName ?? ''; // Handle potential null

                OrganisationIdController.text =
                    _OrganisationId ?? ''; // Handle potential null

                OrganisationNameController.text =
                    _OrganisationName ?? ''; // Handle potential null

                SalesmanIdeController.text = _Salesmanid ?? '';
                SalesmanChannelController.text = _Salesmanchannel ?? '';
                print(
                    "Warehouse name: ${WarehouseNameController.text}     ${OrganisationIdController.text}   ${OrganisationNameController.text}");
              });
              break; // Exit the loop after getting the first warehouse name
            } else {
              // Handle case where to_warehouse is not a string
              setState(() {
                _warehouseName = 'Invalid warehouse data';
                WarehouseNameController.text = ''; // Clear the controller text
              });
            }
          }
        } else {
          // No results found
          setState(() {
            _warehouseName = 'No warehouse details available';
            WarehouseNameController.text = ''; // Clear the controller text
          });
        }

        // Move to the next page if available
        apiUrl = data['next'];
      } else {
        // Handle error
        setState(() {
          _warehouseName = 'Error fetching data';
          WarehouseNameController.text = ''; // Clear the controller text
        });
        return;
      }
    }
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    bool _isProcessing = false; // Tracks if the operation is already ongoing

    return Scaffold(
      body: Center(
        child: Container(
          height: screenheight,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
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
                        padding: EdgeInsets.only(top: 8, bottom: 8),
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
                                  Icons.keyboard_return,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Staging Return',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // First Row
                                if (commersialrole == "Sales Supervisor")
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Image.asset(
                                        "assets/images/user.png",
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              commersialname ?? 'Loading...',
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              commersialrole ?? 'Loading...',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: const Color.fromARGB(
                                                      255, 79, 79, 79)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 10),
                                      // Down arrow to toggle visibility of the second row
                                      IconButton(
                                        icon: Icon(
                                          _isSecondRowVisible
                                              ? Icons.arrow_drop_up_outlined
                                              : Icons.arrow_drop_down_outlined,
                                          size: 27,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isSecondRowVisible =
                                                !_isSecondRowVisible;
                                          });
                                        },
                                      ),
                                      SizedBox(width: 30),
                                    ],
                                  ),
                                // Second Row (only visible if _isSecondRowVisible is true)
                                if (_isSecondRowVisible)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Image.asset(
                                        "assets/images/user.png",
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                      255, 79, 79, 79)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 10),
                                      // Optionally, you can add another arrow icon to toggle the row visibility here as well
                                    ],
                                  ),
                                // Second Row (only visible if _isSecondRowVisible is true)
                                if (commersialrole == "Unknown commersialrole")
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Image.asset(
                                        "assets/images/user.png",
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                      255, 79, 79, 79)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 10),
                                      // Optionally, you can add another arrow icon to toggle the row visibility here as well
                                    ],
                                  ),
                              ],
                            )
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
                                bottom: 0),
                            child: Container(
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
                                              Text('Req_No',
                                                  style:
                                                      TextStyle(fontSize: 13)),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0, bottom: 0),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 32,
                                                  width: Responsive.isDesktop(
                                                          context)
                                                      ? screenWidth * 0.10
                                                      : screenWidth * 0.4,
                                                  child: MouseRegion(
                                                    cursor: SystemMouseCursors
                                                        .click, // Changes the cursor to indicate interaction

                                                    child: TextFormField(
                                                      controller:
                                                          requestTypeNoController,
                                                      decoration:
                                                          const InputDecoration(
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
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 73, 72, 72),
                                                          fontSize: 12),
                                                      // onFieldSubmitted:
                                                      //     (value) {
                                                      //   if (requestTypeNoController
                                                      //       .text.isNotEmpty) {
                                                      //     fetchDispatchDetails(
                                                      //         requestTypeNoController
                                                      //             .text);
                                                      //     _updatecount();
                                                      //   } else {
                                                      //     ShowWarning(
                                                      //         'Kindly enter a Req_No');
                                                      //   }
                                                      // },
                                                      onFieldSubmitted:
                                                          (value) {
                                                        // Extracts the first number from the value
                                                        String? reqno =
                                                            requestTypeNoController
                                                                .text;

                                                        // Check if pickNo is not null and not empty
                                                        if (reqno != null &&
                                                            reqno.isNotEmpty) {
                                                          // Set the controller text to the extracted number
                                                          requestTypeNoController
                                                              .text = '$reqno';

                                                          // Use the numeric value in the API call
                                                          fetchDispatchDetails(
                                                              reqno);
                                                          _updatecount();
                                                        } else {
                                                          ShowWarning(
                                                              'Kindly enter a ReqNo');
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
                                  // if (widget.isFromEditPage)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 46.0),
                                    child: InkWell(
                                      onTap: () {
                                        String? value =
                                            requestTypeNoController.text;

                                        // Extract the first number from the value
                                        String? reqno =
                                            requestTypeNoController.text;

                                        // Check if pickNo is not null and not empty
                                        if (reqno != null && reqno.isNotEmpty) {
                                          // Set the controller text to the desired format "PickNo_123"
                                          requestTypeNoController.text =
                                              '$reqno';

                                          fetchDispatchDetails(reqno);
                                        } else {
                                          ShowWarning('Kindly enter a ReqNo');
                                        }

                                        postLogData("Stage Return", "Search");
                                      },
                                      child: Container(
                                          height: 28,
                                          width: 30,
                                          decoration: BoxDecoration(
                                            color:
                                                buttonColor, // Button background color
                                            shape: BoxShape
                                                .rectangle, // Makes the button circular
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Icon(
                                              Icons.search,
                                              color: Colors.white,
                                            ),
                                          )),
                                    ),
                                  ),

                                  SizedBox(
                                    width: 5,
                                  ),
                                  _buildTextFieldDesktop(
                                      'Physical Warehouse',
                                      WarehouseNameController.text,
                                      Icons.warehouse,
                                      true,
                                      WarehouseFocusnode,
                                      DateFocusNode),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  _buildTextFieldDesktop(
                                      'Date',
                                      formattedDate,
                                      Icons.location_city,
                                      true,
                                      DateFocusNode,
                                      CustomerNoFocusNode),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? MediaQuery.of(context).size.width *
                                            0.1
                                        : MediaQuery.of(context).size.width *
                                            0.4,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 20),
                                          Text("Customer No ",
                                              style: textboxheading),
                                          const SizedBox(height: 1),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0, bottom: 0),
                                            child: Container(
                                                child:
                                                    _buildCustomerNameDropdown()),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  _buildTextFieldDesktop(
                                      'Customer Name',
                                      CustomerNameController.text,
                                      Icons.no_accounts,
                                      true,
                                      CustomerNameFocusNode,
                                      CustomerSiteFocusNode),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  // _buildTextFieldDesktop(
                                  //     'Customer site',
                                  //     CustomersiteidController.text,
                                  //     Icons.perm_identity,
                                  //     false,
                                  //     CustomerSiteFocusNode,
                                  //     SiteAddressFocusNode),

                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? MediaQuery.of(context).size.width *
                                            0.1
                                        : MediaQuery.of(context).size.width *
                                            0.4,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 20),
                                          Text("Customer Site ",
                                              style: textboxheading),
                                          const SizedBox(height: 1),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0, bottom: 0),
                                            child: Container(
                                                child:
                                                    _buildCustomerSiteDropdown()),
                                          ),
                                          // if (totalinvoicecountbool == true)
                                          //   Text(
                                          //     'Pending Invoice ${TotalInvoiveCountController.text} ',
                                          //     style: TextStyle(
                                          //         fontSize: 11,
                                          //         fontWeight: FontWeight.bold,
                                          //         color: Color.fromARGB(
                                          //             255, 23, 122, 5)),
                                          //   ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    width: 10,
                                  ),
                                  // _buildTextFieldDesktop(
                                  //     'Site Address',
                                  //     CustomersitechannelController.text,
                                  //     Icons.sixteen_mp_outlined,
                                  //     false,
                                  //     SiteAddressFocusNode,
                                  //     InvoiceFocusNode),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: Responsive.isDesktop(context)
                                        ? 30
                                        : 10),
                                child: Text("Dispatch Product Details",
                                    style: topheadingbold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8), // Add spacing

                          // Divider
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    Responsive.isDesktop(context) ? 30 : 10),
                            child: Divider(
                              thickness: 1.5,
                              color: Colors.grey.shade400, // Divider color
                            ),
                          ),

                          SizedBox(
                            height: 15,
                          ),
                          if (Responsive.isDesktop(context))
                            Padding(
                              padding: EdgeInsets.only(
                                  top: Responsive.isDesktop(context)
                                      ? MediaQuery.of(context).size.width * 0.01
                                      : 10,
                                  left: 35,
                                  right: 0),
                              child: _buildTable(),
                            ),
                          if (!Responsive.isDesktop(context))
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 35, right: 35),
                              child: Container(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: _buildTable(),
                                ),
                              ),
                            ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 2,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.03),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.09
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: Responsive.isDesktop(
                                                          context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.01
                                                      : 20,
                                                ),
                                                Row(
                                                  children: const [
                                                    Text("No. Of Item",
                                                        style: textboxheading),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 0, bottom: 0),
                                                  child: Container(
                                                    height: 30,
                                                    width: Responsive.isDesktop(
                                                            context)
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.09
                                                        : 170,
                                                    child: TextField(
                                                        readOnly: true,
                                                        decoration:
                                                            InputDecoration(
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Color
                                                                  .fromARGB(
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
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      58,
                                                                      58,
                                                                      58),
                                                              width: 1.0,
                                                            ),
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  250,
                                                                  250,
                                                                  250),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            vertical: 5.0,
                                                            horizontal: 10.0,
                                                          ),
                                                        ),
                                                        controller:
                                                            NoofitemController,
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
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 50.0, left: 10),
                                    child: Container(
                                      height: 35,
                                      decoration:
                                          BoxDecoration(color: buttonColor),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5,
                                            right: 5,
                                            top: 3,
                                            bottom: 3),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            if (getTableData.isEmpty) {
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
                                                                fontSize: 15,
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
                                            } else {
                                              String? value =
                                                  requestTypeNoController.text;

                                              // Extract the first number from the value
                                              String? reqno =
                                                  requestTypeNoController.text;
                                              String? customerno =
                                                  CustomerNoController.text;
                                              String? customersite =
                                                  CustomersiteidController.text;

                                              // Check if pickNo is not null and not empty
                                              if (reqno != null &&
                                                  reqno.isNotEmpty) {
                                                // Set the controller text to the desired format "PickNo_123"
                                                requestTypeNoController.text =
                                                    '$reqno';

                                                showDialog(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      insetPadding:
                                                          EdgeInsets.all(10),
                                                      child: Container(
                                                        color: Colors.grey[100],
                                                        width: Responsive
                                                                .isDesktop(
                                                                    context)
                                                            ? MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.7
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
                                                        child: ReturnDialog(
                                                          dispatch_qty:
                                                              getTableData
                                                                  .fold<double>(
                                                                    0,
                                                                    (sum, row) =>
                                                                        sum +
                                                                        double.tryParse(
                                                                            row['DISPATCHED_QTY'].toString())!,
                                                                  )
                                                                  .toStringAsFixed(
                                                                      0), // Converts to string with 2 decimal places
                                                          reqno: reqno,
                                                          customerno:
                                                              customerno,
                                                          customersite:
                                                              customersite,
                                                          onClear:
                                                              clearallfeilds,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              } else {
                                                ShowWarning(
                                                    'Kindly enter a ReqNo');
                                              }
                                            }

                                            postLogData("Stage Return (Pop-up)",
                                                "Return Opened");
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            minimumSize: const Size(45.0, 15.0),
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                          ),
                                          child: const Text(
                                            "Return",
                                            style: commonWhiteStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 50.0, left: 10),
                                    child: Container(
                                      height: 35,
                                      decoration:
                                          BoxDecoration(color: buttonColor),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5,
                                            right: 5,
                                            top: 3,
                                            bottom: 3),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            clearallfeilds();

                                            postLogData(
                                                "Stage Return", "Clear");
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            minimumSize: const Size(45.0, 15.0),
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                          ),
                                          child: const Text(
                                            "Clear",
                                            style: commonWhiteStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 50.0, left: 10),
                                    child: Container(
                                      height: 35,
                                      decoration:
                                          BoxDecoration(color: buttonColor),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5,
                                            right: 5,
                                            top: 3,
                                            bottom: 3),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            List<List<dynamic>> convertedData =
                                                getTableData.map((map) {
                                              return [
                                                map[' INVOICE_NUMBER'],
                                                map['LINE_NUMBER'],
                                                map['INVENTORY_ITEM_ID'],
                                                map['ITEM_DESCRIPTION'],
                                                map['TOT_QUANTITY'],
                                                map['DISPATCHED_QTY'],
                                              ];
                                            }).toList();
                                            // Check if the data is empty
                                            if (getTableData.isEmpty) {
                                              // Show dialog if no data is available
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
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
                                            List<String> columnNames =
                                                getDisplayedColumns();
                                            await createExcel(
                                                columnNames, convertedData);

                                            postLogData("Stage Return",
                                                "Export Details");
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            minimumSize: const Size(45.0, 15.0),
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8),
                                                child: SvgPicture.asset(
                                                  'assets/images/excel.svg',
                                                  width: 20,
                                                  height: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                "Export",
                                                style: commonWhiteStyle,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Spacer(),

                                  // Right Side - Total Send Qty Section
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right:
                                            MediaQuery.of(context).size.width *
                                                0.03),
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
                                                  0.4,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: Responsive.isDesktop(
                                                          context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.015
                                                      : 20,
                                                ),
                                                Row(
                                                  children: const [
                                                    Text("Total Requested Qty",
                                                        style: textboxheading),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: Responsive.isDesktop(
                                                          context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.006
                                                      : 10,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                        readOnly: true,
                                                        decoration:
                                                            InputDecoration(
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Color
                                                                  .fromARGB(
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
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      58,
                                                                      58,
                                                                      58),
                                                              width: 1.0,
                                                            ),
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  250,
                                                                  250,
                                                                  250),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            vertical: 5.0,
                                                            horizontal: 10.0,
                                                          ),
                                                        ),
                                                        controller:
                                                            totaldisreqController,
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
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: Responsive.isDesktop(context) ? 30 : 50,
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

  clearallfeilds() {
    setState(() {
      requestTypeNoController.text = '';
      WarehouseNameController.clear();
      CustomerNameController.clear();
      CustomerNoController.clear();
      CustomersiteidController.clear();
      NoofitemController.text = '0';
      totaldisreqController.text = '0';
      getTableData = [];
    });
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
          ..setAttribute('download', 'ViewDispatch ($formattedDate).xlsx')
          ..click();
      } else {
        final String path = (await getApplicationSupportDirectory()).path;
        final String fileName = Platform.isWindows
            ? '$path\\Excel ViewDispatch ($formattedDate).xlsx'
            : '$path/Excel ViewDispatch ($formattedDate).xlsx';
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
      'Invoice No',
      'Invoice Line No',
      'Item Code',
      'Item Description',
      'Qty. Invoiced',
      'Dispatch Req Qty',
    ];
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

  Timer? _timer;
  TextEditingController totalamountcontroller = TextEditingController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController2.dispose();
    _verticalScrollController2.dispose();
    requestNoController.dispose();

    // _timer?.cancel(); // Cancel the timer
    totalamountcontroller.dispose(); // Dispose of the total controller
    super.dispose();

    postLogData("Stage Return", "Closed");
  }

  TextEditingController _totalController = TextEditingController();

  double getTotalFinalAmt(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['disreqqty'] ?? '0') ?? 0.0;
      totalQuantity += quantity;
    }
    return totalQuantity;
  }

  bool isChecked = false; // State variable to manage checkbox value

  Widget buildHeaderCell(String label, IconData icon) {
    return Flexible(
      child: Container(
        height: 30,
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
                style: TableRowTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRow(int index, Map<String, dynamic> data) {
    // Convert values to string while removing .0 if necessary
    var id = data['id'].toString();
    var itemcode = _removeDecimalIf(data['itemcode']);
    var itemdetails = _removeDecimalIf(data['itemdetails']);
    var invoiceqty = _removeDecimalIf(data['invoiceqty']);
    var invoicebalqty = _removeDecimalIf(data['invoicebalqty']);

    return Container(
      margin: EdgeInsets.symmetric(
          vertical: 0), // Optional for spacing between rows

      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDataCell(id),
            buildDataCell(itemcode),
            buildDataCell(itemdetails),
            buildDataCell(invoiceqty),
            buildDataCell(invoicebalqty),
            buildDataCell(invoicebalqty),
          ],
        ),
      ),
    );
  }

  Widget buildDataCell(String value) {
    return Flexible(
      child: Container(
        height: 30,
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

  List<Map<String, dynamic>> PreviewtableData = [];

  Future<void> fetchData() async {
    String invoiceno =
        InvoiceNoController.text; // Get the invoice number from the controller

    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/Create_Dispatch/';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the JSON data and assign it to PreviewtableData
        Map<String, dynamic> jsonData = json.decode(response.body);

        // Extract the results array from the response
        List<dynamic> results = jsonData['results'];

        // Filter the results where INVOICE_NUMBER matches invoiceno
        List<dynamic> filteredResults = results.where((item) {
          return item['INVOICE_NUMBER'] == invoiceno;
        }).toList();

        setState(() {
          // Map the filtered results to PreviewtableData as a list of Maps
          PreviewtableData = filteredResults
              .map((item) => item as Map<String, dynamic>)
              .toList();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
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
}

class ReturnDialog extends StatefulWidget {
  final String dispatch_qty;
  final String reqno;
  final String customerno;
  final String customersite;
  final VoidCallback onClear;

  const ReturnDialog({
    Key? key,
    required this.dispatch_qty,
    required this.reqno,
    required this.customerno,
    required this.customersite,
    required this.onClear,
  }) : super(key: key);

  @override
  State<ReturnDialog> createState() => _ReturnDialogState();
}

class _ReturnDialogState extends State<ReturnDialog> {
  @override
  void initState() {
    super.initState();
    fetchWarehouseDetails();
    fetchBypassdatastotruck();
    fetchNoProductcode();

    fetchNoSerialNo();
    print("dispatch_qtyyy ${widget.dispatch_qty}");
    // fetchLastReturnNo();
  }

  @override
  void dispose() {
    _horizontalScrollController2.dispose();

    super.dispose();
  }

  bool _isLoading = true;
  TextEditingController productCodeController = TextEditingController();
  TextEditingController serialNoController = TextEditingController();
  TextEditingController WarehouseController = TextEditingController();
  TextEditingController RegionController = TextEditingController();

  TextEditingController ReturnNoController = TextEditingController();

  List<Map<String, dynamic>> createtableData = [];
  FocusNode prodCodeFocus = FocusNode();
  FocusNode serialNoFocus = FocusNode();
  FocusNode addfoucnode = FocusNode();

  FocusNode SerialcameraFocus = FocusNode();
  FocusNode ProdcameraFocus = FocusNode();

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  bool BypassALertButton = false;

  bool NoProductCodeButton = false;

  bool NoSerialNoButton = false;

  Future<void> fetchBypassdatastotruck() async {
    final IpAddress = await getActiveIpAddress();

    final String url =
        '$IpAddress/compare-scan/${widget.reqno}/${widget.customerno}/${widget.customersite}/';
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
        '$IpAddress/compare-scan-noproductcode/${widget.reqno}/${widget.customerno}/${widget.customersite}/';
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
        '$IpAddress/compare-scan-noserialno/${widget.reqno}/${widget.customerno}/${widget.customersite}/';
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

            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Return Pop-up View',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Count : ${createtableData.length}/${widget.dispatch_qty}')
              ],
            ),
            SizedBox(height: 16),
            // Product Code and Serial No TextFields in the same row
            Container(
              child: Responsive.isDesktop(context)
                  ? Row(
                      children: [
                        // Product Code TextField
                        _buildTextField(
                            suffixFocusNode: ProdcameraFocus,
                            controller: productCodeController,
                            focusNode: prodCodeFocus,
                            hintText: 'Enter Product Code',
                            onSubmitted: (_) => _fieldFocusChange(
                                context, prodCodeFocus, serialNoFocus),
                            onSuffixIconPressed: _openScannerProdCode,
                            readonly: noProductCheckbox),
                        SizedBox(width: 10), // Space between the fields
                        // Serial Number TextField
                        _buildTextField(
                            suffixFocusNode: SerialcameraFocus,
                            controller: serialNoController,
                            focusNode: serialNoFocus,
                            hintText: 'Enter SerialNo',
                            onSubmitted: (_) => _fieldFocusChange(
                                context, serialNoFocus, addfoucnode),
                            onSuffixIconPressed: _openScannerSerial,
                            readonly: noSerialCheckbox),
                        SizedBox(width: 10), // Space between the fields
                        // Add Button
                        Row(
                          children: [
                            _buildAddButton(context),
                            SizedBox(
                              width: 10,
                            ),
                            if (BypassALertButton == true)
                              _buildBypassButton(context),
                          ],
                        ),
                        _buildNoProductcode(context)
                      ],
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Code TextField
                          _buildTextField(
                              suffixFocusNode: ProdcameraFocus,
                              controller: productCodeController,
                              focusNode: prodCodeFocus,
                              hintText: 'Enter Product Code',
                              onSubmitted: (_) => _fieldFocusChange(
                                  context, prodCodeFocus, serialNoFocus),
                              onSuffixIconPressed: _openScannerProdCode,
                              readonly: noProductCheckbox),
                          SizedBox(height: 10), // Space between the fields
                          // Serial Number TextField
                          _buildTextField(
                              suffixFocusNode: SerialcameraFocus,
                              controller: serialNoController,
                              focusNode: serialNoFocus,
                              hintText: 'Enter SerialNo',
                              onSubmitted: (_) => _fieldFocusChange(
                                  context, serialNoFocus, addfoucnode),
                              onSuffixIconPressed: _openScannerSerial,
                              readonly: noSerialCheckbox),
                          SizedBox(height: 10), // Space between the fields
                          // Add Button

                          Row(
                            children: [
                              _buildAddButton(context),
                              SizedBox(
                                width: 10,
                              ),
                              if (BypassALertButton == true)
                                _buildBypassButton(context),
                            ],
                          ),
                          _buildNoProductcode(context)
                        ],
                      ),
                    ),
            ),

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
                  height: 30,
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
                        padding: const EdgeInsets.only(
                            top: 0, bottom: 0, left: 0, right: 0),
                        child: const Text(
                          'Save',
                          style: commonWhiteStyle,
                        ),
                      ),
                      onPressed: () async {
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
                                        color:
                                            Color.fromARGB(255, 223, 196, 18)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Kindly Fill all the feilds.',
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.black),
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
                                            BorderRadius.circular(2.0),
                                      ),
                                      backgroundColor: subcolor,
                                      minimumSize: Size(30.0, 28.0),
                                    ),
                                    child: Text(
                                      'Ok',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
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
                                title: Text('Confirmation'),
                                content: Text(
                                    'Are you sure you want to add the return dispatch?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context)
                                          .pop(); // Close the current dialog

                                      try {
                                        // Perform all asynchronous operations sequentially
                                        await updateTruckScanData();
                                        await updatedispatchrequestdatas();
                                        postLogData("Stage Return (Pop-up)",
                                            "Saved Details");
                                        // Navigate back only after all the above processes are completed
                                        Navigator.pop(
                                            context); // Navigate back to the previous screen
                                        widget.onClear();
                                      } catch (e) {
                                        // Handle any errors if needed
                                        print(
                                            "Error occurred during operations: $e");
                                      }
                                    },
                                    child: Text('Yes'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog if "No" is pressed
                                    },
                                    child: Text('No'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required FocusNode focusNode,
      required String hintText,
      required Function(String) onSubmitted,
      required VoidCallback onSuffixIconPressed,
      required FocusNode suffixFocusNode, // NEW
      bool? readonly}) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: Responsive.isDesktop(context)
          ? screenWidth * 0.13
          : screenWidth * 0.70,
      height: 35,
      child: Padding(
        padding: const EdgeInsets.only(left: 0),
        child: MouseRegion(
          onEnter: (event) {},
          onExit: (event) {},
          cursor: SystemMouseCursors.click,
          child: TextFormField(
            readOnly: readonly ?? false,
            controller: controller,
            focusNode: focusNode,
            onFieldSubmitted: onSubmitted,
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                    color: Color.fromARGB(201, 132, 132, 132), width: 1.0),
              ),
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 13),
              suffixIcon: Focus(
                focusNode: suffixFocusNode,
                child: IconButton(
                  onPressed: onSuffixIconPressed,
                  icon: Icon(Icons.camera_alt, size: 18, color: Colors.blue),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                    color: Color.fromARGB(255, 58, 58, 58), width: 1.0),
              ),
              filled: true,
              fillColor: Color.fromARGB(255, 250, 250, 250),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            ),
            style: const TextStyle(
                color: Color.fromARGB(255, 73, 72, 72), fontSize: 15),
          ),
        ),
      ),
    );
  }

  bool noProductCheckbox = false; // Add this to your state
  bool noSerialCheckbox = false; // Add this to your state

  Widget _buildAddButton(BuildContext context) {
    return Container(
      height: 30,
      width: Responsive.isDesktop(context)
          ? MediaQuery.of(context).size.width * 0.08
          : MediaQuery.of(context).size.width * 0.33,
      decoration: BoxDecoration(color: buttonColor),
      child: ElevatedButton(
        focusNode: addfoucnode,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size(20.0, 20.0),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: const Text('Add', style: commonWhiteStyle),
        onPressed: () {
          final productCode = productCodeController.text;
          final serialNo = serialNoController.text;

          if (productCode.isEmpty && serialNo.isEmpty) {
            _showDialog('Warning', 'Kindly fill the information', true, true);
          } else {
            checkProductReturned(productCode, serialNo);
          }
          postLogData("Stage Retur (Pop-up)", "Details Added");
        },
      ),
    );
  }

  Widget _buildBypassButton(BuildContext context) {
    return Container(
      height: 30,
      width: Responsive.isDesktop(context)
          ? MediaQuery.of(context).size.width * 0.08
          : MediaQuery.of(context).size.width * 0.33,
      decoration: BoxDecoration(color: buttonColor),
      child: ElevatedButton(
        focusNode: addfoucnode,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size(20.0, 20.0),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: const Text('Alert', style: commonWhiteStyle),
        onPressed: () {
          final productCode = productCodeController.text;
          final serialNo = serialNoController.text;

          {
            checkProductReturned('00', 'null');
          }
          postLogData("Stage Retur (Pop-up)", "Details Added");
        },
      ),
    );
  }

  Widget _buildNoProductcode(BuildContext context) {
    return Container(
        // decoration: BoxDecoration(color: buttonColor),
        child: Wrap(
      alignment: WrapAlignment.start,
      children: [
        if (NoProductCodeButton == true)
          Padding(
            padding: EdgeInsets.only(
              left: 0,
              top: Responsive.isDesktop(context) ? 8 : 10,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: buttonColor),
              ),
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.09
                  : MediaQuery.of(context).size.width * 0.33,
              // height: 30,
              child: Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: buttonColor,
                  checkboxTheme: CheckboxThemeData(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                child: Transform.scale(
                  scale:
                      0.9, // Adjust this value to make checkbox smaller (0.7-0.9)
                  child: CheckboxListTile(
                    checkColor: Colors.white,
                    activeColor: buttonColor,
                    fillColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return buttonColor;
                        }
                        return Colors.transparent;
                      },
                    ),
                    title: Padding(
                      padding: EdgeInsets.only(left: 4), // Adjust text position
                      child: Text(
                        "No Product Code",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: Responsive.isDesktop(context) ? 12 : 12,
                        ),
                      ),
                    ),
                    value: noProductCheckbox,
                    onChanged: (bool? value) {
                      setState(() {
                        productCodeController.text = '00';
                        serialNoController.text = '';
                        noProductCheckbox = value ?? false;
                        noSerialCheckbox = false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.only(
                      left: 2, // Reduced left padding
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
        SizedBox(
          width: 10,
        ),
        if (NoSerialNoButton == true)
          Padding(
            padding: EdgeInsets.only(
              top: Responsive.isDesktop(context) ? 8 : 10,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: buttonColor),
              ),
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.09
                  : MediaQuery.of(context).size.width * 0.33,
              // height: 30,
              child: Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: buttonColor,
                  checkboxTheme: CheckboxThemeData(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                child: Transform.scale(
                  scale:
                      0.85, // Adjust this value to make checkbox smaller (0.7-0.9)
                  child: CheckboxListTile(
                    checkColor: Colors.white,
                    activeColor: buttonColor,
                    fillColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return buttonColor;
                        }
                        return Colors.transparent;
                      },
                    ),
                    title: Padding(
                      padding: EdgeInsets.only(left: 4), // Adjust text position
                      child: Text(
                        "No Serial No",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: Responsive.isDesktop(context) ? 12 : 12,
                        ),
                      ),
                    ),
                    value: noSerialCheckbox,
                    onChanged: (bool? value) {
                      setState(() {
                        serialNoController.text = 'null';
                        productCodeController.text = '';
                        noSerialCheckbox = value ?? false;
                        noProductCheckbox = false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
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
    ));
  }

  bool isLoading = false;
  String responseMessage = "";

  Future<void> checkProductReturned(String productCode, String serialNo) async {
    String reqno = widget.reqno;
    print("Product code: $reqno $productCode $serialNo");

    final IpAddress = await getActiveIpAddress();

    final url = Uri.parse(
        '$IpAddress/Findstatusforstagereturn/$reqno/$productCode/$serialNo/');
    print("URL: $url");

    setState(() {
      isLoading = true;
      responseMessage = "";
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody.containsKey('message')) {
          final message = responseBody['message'];

          // Handle different message cases and show dialog accordingly
          if (message == "This product is staging only.") {
            await fetchAndAddData(reqno, productCode, serialNo);
            // _showDialog("Warning", message, true, true);
          } else if (message ==
              "The serial no is correct but the product code is wrong.") {
            _showDialog("Warning", message, true, false);
          } else if (message ==
              "The product code is available under the Reqid but serial no is wrong.") {
            _showDialog("Warning", message, false, true);
          } else if (message == "This product is already trucking.") {
            _showDialog("Warning", message, true, true);
          } else if (message == "There is no matching data.") {
            _showDialog("Warning", message, true, true);
          } else {
            _showDialog("Unknown Message",
                "Unexpected message received: $message", false, false);
          }
        } else {
          setState(() {
            responseMessage = "Response does not contain a 'message' key.";
          });
          _showDialog("Error", responseMessage, false, false);
        }
      } else {
        // Handle failed HTTP request status code
        final Map<String, dynamic> responseBody = json.decode(response.body);
        String errorMessage = "Unknown error occurred";

        // Check if response contains 'message' and display it
        if (responseBody.containsKey('message')) {
          errorMessage = responseBody['message'];
        } else {
          // If the message key is not present, use a fallback message
          errorMessage =
              "Failed to fetch product status. Status code: ${response.statusCode}";
        }

        setState(() {
          responseMessage = errorMessage;
        });

        if (errorMessage == "This product is staging only.") {
          await fetchAndAddData(reqno, productCode, serialNo);
          // _showDialog("Warning", errorMessage, true, true);
        } else if (errorMessage ==
            "The serial no is correct but the product code is wrong.") {
          _showDialog("Warning", errorMessage, true, false);
        } else if (errorMessage ==
            "The product code is available under the Reqid but serial no is wrong.") {
          _showDialog("Warning", errorMessage, false, true);
        } else if (errorMessage == "This product is already trucking.") {
          _showDialog("Warning", errorMessage, true, true);
        } else if (errorMessage == "There is no matching data.") {
          _showDialog("Warning", errorMessage, true, true);
        } else {
          _showDialog("Warning Message",
              "Unexpected message received: $errorMessage", false, false);
        }
        // Show the dialog with the error message from the response
        // _showDialog("Warning", errorMessage, true, true);
      }
    } catch (e) {
      // Catch errors during the HTTP request process
      setState(() {
        responseMessage = "Error occurred: $e";
      });
      // _showDialog("Error", "An error occurred: $e", false, false);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  _showDialog(String heading, String message, bool clearproductcode,
      bool clearserialno) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(heading),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (clearproductcode == true && clearproductcode == true)
                  setState(() {
                    if (noProductCheckbox == true) {
                      serialNoController.clear();
                      FocusScope.of(context).requestFocus(serialNoFocus);
                    } else if (noSerialCheckbox == true) {
                      productCodeController.clear();
                      FocusScope.of(context).requestFocus(prodCodeFocus);
                    } else {
                      productCodeController.clear();
                      serialNoController.clear();
                      FocusScope.of(context).requestFocus(prodCodeFocus);
                    }
                  });
                if (clearproductcode == true)
                  setState(() {
                    productCodeController.clear();

                    FocusScope.of(context).requestFocus(prodCodeFocus);
                  });
                if (clearserialno == true)
                  setState(() {
                    serialNoController.clear();

                    FocusScope.of(context).requestFocus(serialNoFocus);
                  });
                // filteredData = [];
                FocusScope.of(context).requestFocus(prodCodeFocus);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchAndAddData(
      String reqno, String productcode, String serialno) async {
    final IpAddress = await getActiveIpAddress();

    final String fullUrl =
        "$IpAddress/Pickman_Productcode/$reqno/$productcode/$serialno/";

    try {
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        // Parse the response
        final List<dynamic> data = json.decode(response.body);

        if (data != null && data.isNotEmpty) {
          // Check if the data with the same product code and serial number already exists
          bool exists = createtableData.any((item) =>
              item['PRODUCT_CODE'] == productcode &&
              item['SERIAL_NO'] == serialno);

          if (exists) {
            // Show error dialog if the data already exists
            _showDialog(
                "Already Exist",
                "This product code and serial number already exist in the table.",
                true,
                true);
          } else {
            // Assuming the data contains valid product details to add
            setState(() {
              // Add new data to the table
              createtableData.addAll(List<Map<String, dynamic>>.from(data));

              // Clear the input fields and refocus
              if (noProductCheckbox == true) {
                serialNoController.clear();
                FocusScope.of(context).requestFocus(serialNoFocus);
                Future.delayed(Duration(seconds: 1), () {
                  // Automatically open the serial number scanner
                  _openScannerSerial();
                });
              } else if (noSerialCheckbox == true) {
                productCodeController.clear();
                serialNoController.clear();
                setState(() {
                  noSerialCheckbox = false;
                });
              } else {
                productCodeController.clear();
                serialNoController.clear();
                FocusScope.of(context).requestFocus(prodCodeFocus);
                // Delay to allow the SnackBar to show before opening the serial scanner
                Future.delayed(Duration(seconds: 1), () {
                  // Automatically open the serial number scanner
                  _openScannerProdCode();
                });
              }
            });
          }
        } else {
          // Show error dialog if data is empty or null
          _showDialog("No Data", "No data found for the given product code.",
              true, true);
        }
      } else {
        // Handle server error
        _showDialog("Error", "Failed to fetch data. Please try again later.",
            true, true);
      }
    } on http.ClientException catch (e) {
      // Handle HTTP client exceptions
      _showDialog("Error", "Failed to connect to the server: $e", true, true);
      print("HTTP Client Error: $e");
    } on FormatException catch (e) {
      // Handle JSON format exception
      _showDialog("Error", "Failed to parse data: $e", true, true);
      print("Format Error: $e");
    } catch (error) {
      // Handle any other exceptions
      _showDialog("Error", "An unexpected error occurred: $error", true, true);
      print("An unexpected error occurred: $error");
    }
  }

  Future<void> updateTruckScanData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? saveloginname = prefs.getString('saveloginname') ?? '';
    for (var record in createtableData) {
      final id = record['id'];

      DateTime now = DateTime.now();
      // Format to YYYY-MM-DD HH:mm:ss
      String formattedDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(now);

      if (id != null) {
        final IpAddress = await getActiveIpAddress();

        final updateUrl = Uri.parse('$IpAddress/Pickman_scan/$id/');
        final headers = {"Content-Type": "application/json"};
        final body = json.encode({
          "LAST_UPDATE_DATE": formattedDate,
          "LAST_UPDATED_BY":
              saveloginname.isNotEmpty ? saveloginname : 'Unknown',
          'FLAG': 'SR',
        });

        try {
          final response =
              await http.put(updateUrl, headers: headers, body: body);

          if (response.statusCode == 200) {
            print('Updated FLAG for id: $id');
          } else {
            print(
                'Failed to update FLAG for id: $id. Status code: ${response.statusCode}');
          }
        } catch (e) {
          print('Error updating FLAG for id: $id: $e');
        }
      }
    }
  }

  Future<void> updatedispatchrequestdatas() async {
    final IpAddress = await getActiveIpAddress();
    final headers = {"Content-Type": "application/json"};
    print("createtableDataaaaaaaaaaa: $createtableData");
    for (var record in createtableData) {
      final reqid = record['REQ_ID'];
      final cusno = record['CUSTOMER_NUMBER'];
      final cussite = record['CUSTOMER_SITE_ID'];
      final itemcode = record['INVENTORY_ITEM_ID'];
      final truckSendQty = 1;

      if (reqid != null &&
          cusno != null &&
          cussite != null &&
          itemcode != null) {
        final getUrl = Uri.parse(
          '$IpAddress/filtereddispatchrequestgetreturnupdateid$parameterdivided$reqid$parameterdivided$cusno$parameterdivided$cussite$parameterdivided$itemcode$parameterdivided',
        );

        print(
            "Fetching record for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno, CUSTOMER_SITE_ID: $cussite, ITEM_CODE: $itemcode from $getUrl");

        try {
          final getResponse = await http.get(getUrl, headers: headers);

          if (getResponse.statusCode == 200) {
            final List<dynamic> records = json.decode(getResponse.body);

            if (records.isNotEmpty) {
              final record = records[0];
              final id = record['id'];
              final scannedQty = record['SCANNED_QTY'] ?? 0;

              if (id != null) {
                final int scannedQtyNum = scannedQty is int
                    ? scannedQty
                    : int.tryParse(scannedQty.toString()) ?? 0;

                final int finalScannedQty = scannedQtyNum - truckSendQty;

                print(
                    "scanned qty : $finalScannedQty = $scannedQty - $truckSendQty");

                final updateUrl = Uri.parse('$IpAddress/Dispatch_request/$id/');
                final body = json.encode({
                  "SCANNED_QTY": finalScannedQty,
                  "STATUS": "pending",
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
                print('No valid ID found in response for REQ_ID: $reqid');
              }
            } else {
              print(
                  'No record found for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno, CUSTOMER_SITE_ID: $cussite, ITEM_CODE: $itemcode');
            }
          } else {
            print(
                'Failed to fetch record for REQ_ID: $reqid. Status code: ${getResponse.statusCode}');
          }
        } catch (e) {
          print(
              'Error fetching or updating record for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno: $e');
        }
      } else {
        print('Invalid data in record: $record');
      }
    }

    // Final steps (once after all records processed)
    Navigator.pop(context);
    await SaveReturnProducts();
  }

  void _openScannerProdCode() {
    String quantity = widget.dispatch_qty ?? '';
    quantity = quantity.contains('.') ? quantity.split('.')[0] : quantity;
    int maxQuantity = int.tryParse(quantity) ?? 0;

    bool isScanned = false;
    final MobileScannerController scannerController = MobileScannerController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade900,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.qr_code_scanner, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Scan Product Code',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),

                  // Scanner Area
                  AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        MobileScanner(
                          controller: scannerController,
                          onDetect: (BarcodeCapture capture) async {
                            if (isScanned)
                              return; // Prevent multiple detections
                            isScanned = true;

                            final String? scannedCode =
                                capture.barcodes.first.rawValue;

                            if (scannedCode != null && scannedCode.isNotEmpty) {
                              // Update the text field with the scanned value
                              productCodeController.text = scannedCode;

                              // Show a small SnackBar message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Product Code Scanned!',
                                    style: TextStyle(
                                        fontSize: 12), // Small font size
                                  ),
                                  duration: Duration(
                                      seconds:
                                          2), // Duration to show the message
                                ),
                              );

                              // Close the scanner dialog
                              Navigator.of(context).pop();

                              final productCode = productCodeController.text;
                              final serialNo = serialNoController.text;
                              if (noSerialCheckbox == true) {
                                if (productCode.isNotEmpty &&
                                    serialNo.isNotEmpty) {
                                  await checkProductReturned(
                                      productCode, serialNo);

                                  postLogData(
                                      "Stage Return (Pop-up)", "Details Added");
                                }
                              } else {
                                Future.delayed(Duration(seconds: 1), () {
                                  // Automatically open the serial number scanner
                                  _openScannerSerial();
                                });
                              }
                            }
                          },
                          fit: BoxFit.cover,
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: ScannerOverlayPainter(
                              borderColor: Colors.green.shade400,
                              borderRadius: 10,
                              borderWidth: 4,
                              borderLength: 40,
                              cutOutSize:
                                  MediaQuery.of(context).size.width * 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Footer with instructions
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Align the Product Code within the frame',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 8),
                        // Simple flash toggle button without state listener
                        ElevatedButton.icon(
                          icon: Icon(
                            Icons.flash_on,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Toggle Flash',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          onPressed: () => scannerController.toggleTorch(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade800,
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
    ).then((_) {
      // Dispose of the scanner controller after the dialog is closed
      scannerController.dispose();

      // Reset the scanned flag for future use
      isScanned = false;

      // Move focus to the corresponding Serial No text field
      FocusScope.of(context).requestFocus(SerialcameraFocus);

      // Move to the next text field if there are more fields
    });
  }

  void _openScannerSerial() {
    String quantity = widget.dispatch_qty ?? '';
    quantity = quantity.contains('.') ? quantity.split('.')[0] : quantity;
    int maxQuantity = int.tryParse(quantity) ?? 0;

    bool isScanned = false;
    final MobileScannerController scannerController = MobileScannerController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.qr_code_scanner, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Scan Serial Number',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),

                  // Scanner Area
                  AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        MobileScanner(
                          controller: scannerController,
                          onDetect: (BarcodeCapture capture) async {
                            if (isScanned) return;
                            isScanned = true;

                            final String? scannedCode =
                                capture.barcodes.first.rawValue;

                            if (scannedCode != null && scannedCode.isNotEmpty) {
                              serialNoController.text = scannedCode;

                              Navigator.of(context)
                                  .pop(); // Close the scanner dialog

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Serial Number Scanned Successfully!',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );

                              final productCode = productCodeController.text;
                              final serialNo = serialNoController.text;

                              if (productCode.isNotEmpty &&
                                  serialNo.isNotEmpty) {
                                await checkProductReturned(
                                    productCode, serialNo);

                                postLogData(
                                    "Stage Return (Pop-up)", "Details Added");
                              }
                            }
                          },
                          fit: BoxFit.cover,
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: ScannerOverlayPainter(
                              borderColor: Colors.blue.shade400,
                              borderRadius: 10,
                              borderWidth: 4,
                              borderLength: 40,
                              cutOutSize:
                                  MediaQuery.of(context).size.width * 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Footer with instructions
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Align the SerialNo within the frame',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 8),
                        // Simple flash toggle button without state listener
                        ElevatedButton.icon(
                          icon: Icon(
                            Icons.flash_on,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Toggle Flash',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          onPressed: () => scannerController.toggleTorch(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade800,
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
    ).then((_) {
      scannerController.dispose();
      isScanned = false;
    });
  }

  final ScrollController _horizontalScrollController2 = ScrollController();

  Widget _viewbuildTable(BuildContext context) {
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
                        ? MediaQuery.of(context).size.width * 0.80
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
                              buildHeaderCell("Item Des", Icons.info_outline,
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
                  _horizontalScrollController2.animateTo(
                    _horizontalScrollController2.offset -
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
                  _horizontalScrollController2.animateTo(
                    _horizontalScrollController2.offset +
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
    var invoiceno = _removeDecimalIf(data['INVOICE_NUMBER']);
    var itemcode = _removeDecimalIf(data['INVENTORY_ITEM_ID']);

    var itemdetails = _removeDecimalIf(data['ITEM_DESCRIPTION']);

    var productcode = _removeDecimalIf(data['PRODUCT_CODE']);

    var serialno = _removeDecimalIf(data['SERIAL_NO']);

    var id = _removeDecimalIf(data['id']);

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
                  'Success Add the Stage Return Products',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                widget.onClear();
                Navigator.of(context).pop();
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
