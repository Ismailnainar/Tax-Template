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
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_svg/flutter_svg.dart';

class ViewDispatch extends StatefulWidget {
  final String reqno;
  final bool isViewpoagebool;
  final bool isFromEditPage;
  final Function togglePage;

  const ViewDispatch(
    this.reqno,
    this.isViewpoagebool,
    this.isFromEditPage,
    this.togglePage,
  );
  @override
  State<ViewDispatch> createState() => _ViewDispatchState();
}

class _ViewDispatchState extends State<ViewDispatch> {
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

  TextEditingController DeliveryAddressController = TextEditingController();
  TextEditingController RemarksController = TextEditingController();

  TextEditingController FinalDeliveryAddressController =
      TextEditingController();
  TextEditingController FinalRemarksController = TextEditingController();

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

  FocusNode DeliveryddressFocusNode = FocusNode();
  FocusNode RemardsFocusNode = FocusNode();

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
    requestTypeNoController.text = widget.isViewpoagebool
        ? "${widget.reqno}"
        : (widget.isFromEditPage ? "${widget.reqno}" : "");

    print(
        "requestno controller is ${requestTypeNoController.text} ${widget.isViewpoagebool}  ${widget.isFromEditPage}  ");

    if (widget.isViewpoagebool) {
      fetchDispatchDetails(widget.reqno);
      changedeliveryAddress(widget.reqno);
    }
    if (widget.isFromEditPage) {
      fetchDispatchDetails(widget.reqno);
      changedeliveryAddress(widget.reqno);
    }

    // fetchWarehouseDetails();
    // fetchCustomerNumbers();
    // fetchLastRequestNo();

    // Initialize controllers and focus nodes for each row
    createtableData.forEach((row) {
      _controllers.add(TextEditingController(text: "0"));
      _focusNodes.add(FocusNode());
    });

    // Initialize total amount controller with initial values
    totalamountcontroller.text = "0";

    postLogData("View Dispatch", "Opened");
  }

  Future<void> fetchLastRequestNo() async {
    final IpAddress = await getActiveIpAddress();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno');
    final url = '$IpAddress/Create_DispatchReqno/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String lastReqNo = data['REQ_ID']?.toString() ?? '0';
        int newReqNo =
            int.tryParse(lastReqNo) != null ? int.parse(lastReqNo) + 1 : 1;
        requestNoController.text = newReqNo.toString();
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

  String formattedDate = ''; // Declare at the class level
  List<Map<String, dynamic>> getTableData = [];

  // Future<void> fetchDispatchDetails(String ReqNo) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';

  //   String? salesloginno = prefs.getString('salesloginno') ?? '';
  //   try {
  //     final response =
  //         await http.get(Uri.parse('$IpAddress/dispatch-details/$ReqNo/'));
  //     // print('Response body: ${response.body}');

  //     if (response.body == null || response.body.isEmpty) {
  //       ShowWarning('No data received from the server.');
  //       return;
  //     }

  //     var data;
  //     try {
  //       data = json.decode(response.body);
  //     } catch (e) {
  //       ShowWarning('Failed to decode response: $e');
  //       print('Failed to decode response: $e');
  //       return;
  //     }

  //     if (data == null || data.isEmpty) {
  //       ShowWarning('Kindly enter a correct Req No.');
  //       return;
  //     }

  //     if (data is List) {
  //       List<Map<String, dynamic>> dispatchDetailsList =
  //           List<Map<String, dynamic>>.from(data);
  //       if (dispatchDetailsList.isNotEmpty) {
  //         var dispatchDetails = dispatchDetailsList[0];
  //         // print('Dispatch details fetched successfully: $dispatchDetails');

  //         String orgId = dispatchDetails['ORG_ID']?.toString() ?? '';
  //         if (orgId != saleslogiOrgid) {
  //           // Show dialog box if ORG_ID does not match
  //           await showDialog(
  //             barrierDismissible: false,
  //             context: context,
  //             builder: (BuildContext context) {
  //               return AlertDialog(
  //                 title: Text('Invalid Warehouse'),
  //                 content: Text(
  //                     'This Req ID is not associated with your warehouse details.'),
  //                 actions: [
  //                   TextButton(
  //                     onPressed: () {
  //                       setState(() {
  //                         requestTypeNoController.text = '';
  //                       });
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: Text('OK'),
  //                   ),
  //                 ],
  //               );
  //             },
  //           );
  //           return;
  //         }

  //         String invoiceDateStr =
  //             dispatchDetails['INVOICE_DATE']?.toString() ?? '';
  //         formattedDate = invoiceDateStr.isNotEmpty
  //             ? DateFormat('d-MMM-yyyy').format(DateTime.parse(invoiceDateStr))
  //             : 'Invalid date';

  //         setState(() {
  //           CustomerNoController.text =
  //               dispatchDetails['CUSTOMER_NUMBER']?.toString() ?? '';
  //           CustomeridController.text =
  //               dispatchDetails['CUSTOMER_ID']?.toString() ?? '';
  //           CustomerNameController.text =
  //               dispatchDetails['CUSTOMER_NAME']?.toString() ?? '';
  //           CustomersiteidController.text =
  //               dispatchDetails['CUSTOMER_SITE_ID']?.toString() ?? '';
  //           CustomersitechannelController.text =
  //               dispatchDetails['SALES_CHANNEL']?.toString() ?? '';
  //           WarehouseNameController.text =
  //               dispatchDetails['TO_WAREHOUSE']?.toString() ?? '';
  //           OrganisationIdController.text =
  //               dispatchDetails['ORG_ID']?.toString() ?? '';
  //           OrganisationNameController.text =
  //               dispatchDetails['ORG_NAME']?.toString() ?? '';
  //           SalesmanIdeController.text =
  //               dispatchDetails['SALESMAN_NO']?.toString() ?? '';
  //           SalesmanChannelController.text =
  //               dispatchDetails['SALESREP_ID']?.toString() ?? '';
  //           getTableData = List<Map<String, dynamic>>.from(
  //               dispatchDetails['TABLE_DETAILS'] ?? []);
  //           _updatecount();
  //           _updatedisreqamt();
  //         });
  //       } else {
  //         ShowWarning('Kindly enter a correct Req No.');
  //       }
  //     } else {
  //       ShowWarning('Unexpected data format received from the server.');
  //       print('Unexpected data format received');
  //     }
  //   } catch (e) {
  //     ShowWarning('An error occurred: $e');
  //     print('An error occurred: $e');
  //   }
  // }
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
        // ShowWarning('Failed to decode response: $e');
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

          print(
              "orgIddddd $orgId = ${dispatchDetails['TO_WAREHOUSE']?.toString() ?? ''}; $saleslogiOrgid");
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

            DeliveryAddressController.text =
                dispatchDetails['DELIVERYADDRESS']?.toString() ?? '';
            RemarksController.text =
                dispatchDetails['REMARKS']?.toString() ?? '';
            getTableData = List<Map<String, dynamic>>.from(
                dispatchDetails['TABLE_DETAILS'] ?? []);
            _updatecount();
            _updatedisreqamt();
            getAndFetchInvoiceDetails();
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

  Future<void> changedeliveryAddress(String ReqNo) async {
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
        // ShowWarning('Failed to decode response: $e');
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

          print(
              "orgIddddd $orgId = ${dispatchDetails['TO_WAREHOUSE']?.toString() ?? ''}; $saleslogiOrgid");
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

          String invoiceDateStr =
              dispatchDetails['INVOICE_DATE']?.toString() ?? '';
          formattedDate = invoiceDateStr.isNotEmpty
              ? DateFormat('d-MMM-yyyy').format(DateTime.parse(invoiceDateStr))
              : 'Invalid date';

          setState(() {
            FinalDeliveryAddressController.text =
                dispatchDetails['DELIVERYADDRESS']?.toString() ?? '';
            FinalRemarksController.text =
                dispatchDetails['REMARKS']?.toString() ?? '';
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

  // Future<void> changedeliveryAddress() async {
  //   await fetchDispatchDetails(widget.reqno);
  //   print(
  //       "deliveryyyyyyyyyyy${DeliveryAddressController.text}  ${RemarksController.text}");
  //   setState(() {
  //     FinalDeliveryAddressController.text = DeliveryAddressController.text;
  //     FinalRemarksController.text = RemarksController.text;
  //   });
  //   print(
  //       "deliveryyyyyyyyyyy${FinalDeliveryAddressController.text}  ${FinalRemarksController.text}");
  // }

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
                Text(label, style: textboxheading),
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
                            // hintText: label,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                            filled: true,
                            fillColor: Color.fromARGB(255, 255, 255, 255),
                          ),
                          style: TextStyle(
                              color: Color.fromARGB(255, 73, 72, 72),
                              fontSize: 13),
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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Sort tableData based on the ID
    List<Map<String, dynamic>> sortedTableData = List.from(createtableData)
      ..sort((a, b) {
        try {
          return int.parse(a['ID']?.toString() ?? '0')
              .compareTo(int.parse(b['ID']?.toString() ?? '0'));
        } catch (e) {
          return 0;
        }
      });

    final headers = [
      {'icon': Icons.receipt, 'label': 'Invoice No'},
      {'icon': Icons.list_alt, 'label': 'I.L.No'},
      {'icon': Icons.code, 'label': 'Item Code'},
      {'icon': Icons.description, 'label': 'Item Description'},
      {'icon': Icons.check_circle, 'label': 'Qty.Inv'},
      {'icon': Icons.check_circle, 'label': 'Qty.Bal'},
      {'icon': Icons.assignment, 'label': 'Dis.Req.Qty'},
      if (!widget.isViewpoagebool)
        if (widget.isFromEditPage)
          {'icon': Icons.more_vert, 'label': 'Actions'},
    ];

    return Container(
      width: screenWidth,
      child: Scrollbar(
        thumbVisibility: true,
        controller: _horizontalScrollController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _horizontalScrollController,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height:
                    Responsive.isDesktop(context) ? screenHeight * 0.4 : 400,
                width: Responsive.isDesktop(context)
                    ? screenWidth * 0.8
                    : screenWidth * 3,
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
                          return _buildHeaderCell(icon, label ?? '');
                        }).toList(),
                      ),
                    ),
                    if (sortedTableData.isNotEmpty)
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                sortedTableData.asMap().entries.map((entry) {
                              final int index = entry.key;
                              final data = entry.value;
                              return _buildDataRow(data, index);
                            }).toList(),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 100.0),
                        child: Text("Kindly enter a ReqNo to view dispatch..."),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(Map<String, dynamic> data, int index) {
    // Initialize the original data if not already done
    initializeOriginalData(index, data);
    print('dataaaaaaaaaaaaaaaaaa $data');

    final List<String> keys = [
      'invoice_number',
      'line_number',
      'itemcode',
      'itemdetails',
      'quantity',
      'baldispatched_qty',
      'dis_qty_total',
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
              return _buildDataCell(data, key, index);
            }).toList(),
            if (!widget.isViewpoagebool)
              if (widget.isFromEditPage) _buildActionsCell(data, index),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCell(Map<String, dynamic> data, int index) {
    return Flexible(
      child: Container(
        height: 30,
        width: Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.05
            : 40.0,
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFE2E1E1)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
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
              // Tooltip(
              //   message: 'Delete',
              //   child: GestureDetector(
              //     onDoubleTap: () {
              //       setState(() {
              //         rowColors[index] = Color(0xFFE0FFFFFF);
              //         data['dis_qty_total'] =
              //             originalData[index]?['dis_qty_total']?.toString() ??
              //                 '0';
              //         data['flag'] = 'A';
              //         print(
              //             'Row $index reset: ${data['dis_qty_total']} with flag ${data['flag']}');
              //       });
              //     },
              //     child: IconButton(
              //       onPressed: () {
              //         setState(() {
              //           rowColors[index] = Colors.red.withOpacity(0.3);
              //           data['flag'] = 'D';
              //         });
              //       },
              //       icon: Icon(Icons.delete, color: Colors.red, size: 18),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(Map<String, dynamic> data, String key, int index) {
    final bool editable = isEditable[index] ?? false;
    _focusNodess[index] ??= FocusNode();

    // Safely get the value with null check
    String value = data[key]?.toString() ?? '';
    final controller = TextEditingController(text: value);

    // Define column widths based on key
    double columnWidth;
    switch (key) {
      case 'line_number':
        columnWidth = Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.05
            : 80.0;
        break;
      case 'itemdetails':
        columnWidth = Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.27
            : 250.0;
        break;
      case 'quantity':
      case 'baldispatched_qty':
        columnWidth = Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.05
            : 80.0;
        break;
      case 'dis_qty_total':
        columnWidth = Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.07
            : 80.0;
        break;
      default:
        columnWidth = Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.12
            : 120.0;
    }

    Timer? _debounce;

    return Container(
      width: columnWidth,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE2E1E1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: editable && key == 'dis_qty_total'
                ? TextField(
                    controller: controller,
                    focusNode: _focusNodess[index],
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: textBoxstyle,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onChanged: (newValue) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();

                      _debounce = Timer(const Duration(seconds: 1), () {
                        try {
                          // Validation: special characters
                          final invalidChars = RegExp(r'[()*&^%$#@!~/+=\\.,]');
                          if (invalidChars.hasMatch(newValue)) {
                            ShowWarning('Special characters are not allowed.');
                            controller.text =
                                newValue.replaceAll(invalidChars, '');
                            controller.selection = TextSelection.fromPosition(
                                TextPosition(offset: controller.text.length));
                            return;
                          }

                          double dispatchedQty = double.tryParse(newValue) ?? 0;

                          // Save original values once
                          if (!data.containsKey('existingdata')) {
                            data['existingdata'] = double.tryParse(
                                    data['dis_qty_total']?.toString() ?? '0') ??
                                0;
                          }
                          if (!data.containsKey('initialbaldispatched_qty')) {
                            data['initialbaldispatched_qty'] = double.tryParse(
                                    data['baldispatched_qty']?.toString() ??
                                        '0') ??
                                0;
                          }

                          double existingData = data['existingdata'] as double;
                          double exisDispatchedQty =
                              data['initialbaldispatched_qty'] as double;

                          // Calculate difference
                          double totalQtyCal = existingData - dispatchedQty;

                          // Update values
                          data['dis_qty_total'] = dispatchedQty.toString();
                          data['dis_managerQty_total'] =
                              dispatchedQty.toString();
                          data['baldispatched_qty'] =
                              (exisDispatchedQty + totalQtyCal)
                                  .toStringAsFixed(0);

                          setState(() {});

                          double totalQuantity = double.tryParse(
                                  data['baldispatched_qty']?.toString() ??
                                      '0') ??
                              0;

                          // Zero or negative check
                          if (dispatchedQty <= 0) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => AlertDialog(
                                backgroundColor: Colors.white,
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.warning,
                                            color: Colors.yellow),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            "Zero or negative values are not allowed",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('Ok'),
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                      data['dis_qty_total'] =
                                          existingData.toString();
                                      data['dis_managerQty_total'] =
                                          existingData.toString();
                                      data['baldispatched_qty'] =
                                          exisDispatchedQty.toStringAsFixed(0);
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                          // Max limit check
                          else if (totalQuantity < 0) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => AlertDialog(
                                backgroundColor: Colors.white,
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.warning,
                                            color: Colors.yellow),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            "Quantity cannot exceed limit",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('Ok'),
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                      data['dis_qty_total'] =
                                          (existingData + exisDispatchedQty)
                                              .toString();
                                      data['dis_managerQty_total'] =
                                          (existingData + exisDispatchedQty)
                                              .toString();
                                      data['baldispatched_qty'] = '0';
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        } catch (e) {
                          print('Error in onChanged: $e');
                        }
                      });
                    },
                  )
                : SelectableText(
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
    );
  }

//   Widget _buildDataCell(Map<String, dynamic> data, String key, int index) {
//     final bool editable = isEditable[index] ?? false;
//     _focusNodess[index] ??= FocusNode();
//     final controller = TextEditingController(text: data[key]?.toString() ?? '');

//     // Define column widths based on the key
//     double columnWidth;
//     switch (key) {
//       case 'line_number': // Invoice Line No
//         columnWidth = Responsive.isDesktop(context)
//             ? MediaQuery.of(context).size.width * 0.05 // 8% of screen width
//             : 80.0;
//         break;
//       case 'itemdetails':
//         columnWidth = Responsive.isDesktop(context)
//             ? MediaQuery.of(context).size.width * 0.27 // 25% of screen width
//             : 250.0;
//         break;
//       case 'quantity':
//         columnWidth = Responsive.isDesktop(context)
//             ? MediaQuery.of(context).size.width * 0.05 // 8% of screen width
//             : 80.0;
//       case 'Exisdispatched_qty':
//         columnWidth = Responsive.isDesktop(context)
//             ? MediaQuery.of(context).size.width * 0.05 // 8% of screen width
//             : 80.0;
//       case 'dis_qty_total':
//         columnWidth = Responsive.isDesktop(context)
//             ? MediaQuery.of(context).size.width * 0.07 // 8% of screen width
//             : 80.0;
//         break;

//       default:
//         columnWidth = Responsive.isDesktop(context)
//             ? MediaQuery.of(context).size.width * 0.12 // 12% of screen width
//             : 120.0;
//     }

//     return Container(
//       width: columnWidth, // Set fixed width here
//       height: 30,
//       decoration: BoxDecoration(
//         border: Border.all(color: Color(0xFFE2E1E1)),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: editable && (key == 'dis_qty_total')
//                 ? TextField(
//                     controller: controller,
//                     focusNode: _focusNodess[index],
//                     textInputAction: TextInputAction.next,
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [
//                       FilteringTextInputFormatter
//                           .digitsOnly, // Restrict to digits only
//                     ],
//                     style: textBoxstyle,
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(vertical: 15),
//                     ),
//                     onChanged: (newValue) {
//                       final invalidChars = RegExp(r'[()*&^%$#@!~/+=\\.,]');
//                       if (invalidChars.hasMatch(newValue)) {
//                         ShowWarning('Special characters are not allowed.');
//                         controller.text = newValue.replaceAll(invalidChars, '');
//                         controller.selection = TextSelection.fromPosition(
//                           TextPosition(offset: controller.text.length),
//                         );
//                         return;
//                       }

//                       final dispatchedQty = double.tryParse(newValue);
//                       final totalQuantity = double.tryParse(
//                               data['Exisdispatched_qty']?.toString() ?? '0') ??
//                           0;

//                       if (dispatchedQty != null) {
//                         if (dispatchedQty <= 0) {
//                           ShowWarning(
//                               'Zero or negative values are not allowed.');
//                           controller.text = ''; // Clear invalid input
//                           return;
//                         }
//                         if (dispatchedQty > totalQuantity) {
//                           ShowWarning(
//                               'Kindly enter a quantity that does not exceed the limit.');
//                           controller.text = ''; // Clear invalid input

//                           // Save initial DISPATCHED_QTY into 'existingdata' only once
//                           if (!data.containsKey('existingdata')) {
//                             data['existingdata'] = data['dis_qty_total'] ?? '';
//                           }
//                           if (!data.containsKey('initialExisdispatched_qty')) {
//                             data['initialExisdispatched_qty'] =
//                                 data['Exisdispatched_qty'] ?? '';
//                           }

//                           final disQtyStr = controller.text;
//                           final existingDataStr =
//                               data['existingdata']?.toString() ?? '0';
//                           final exisDispatchedQtyStr =
//                               data['initialExisdispatched_qty']?.toString() ??
//                                   '0';

// // Parse all as double for safety
//                           final disQty = double.tryParse(disQtyStr) ?? 0;
//                           final existingData =
//                               double.tryParse(existingDataStr) ?? 0;
//                           final exisDispatchedQty =
//                               double.tryParse(exisDispatchedQtyStr) ?? 0;

// // Update these values
//                           data['dis_qty_total:'] = disQty.toString();
//                           data['dis_managerQty_total'] = disQty.toString();

// // Calculate the difference
//                           final totalQtyCal = existingData - disQty;
//                           print(
//                               "Calculationssss $totalQtyCal = $disQty - $existingData  $exisDispatchedQty");

// // Update Exisdispatched_qty safely
//                           data['Exisdispatched_qty'] =
//                               (exisDispatchedQty + totalQtyCal)
//                                   .toStringAsFixed(2);

//                           print(
//                               "Table data: existingdata = $existingData, dis_qty_total = ${data['dis_qty_total:']}, dis_managerQty_total = ${data['dis_managerQty_total']}, Exisdispatched_qty = ${data['Exisdispatched_qty']}");

//                           return;
//                         }
//                       }

//                       // Save initial DISPATCHED_QTY into 'existingdata' only once
//                       if (!data.containsKey('existingdata')) {
//                         data['existingdata'] = data['dis_qty_total'] ?? '';
//                       }
//                       if (!data.containsKey('initialExisdispatched_qty')) {
//                         data['initialExisdispatched_qty'] =
//                             data['Exisdispatched_qty'] ?? '';
//                       }

//                       final disQtyStr = controller.text;
//                       final existingDataStr =
//                           data['existingdata']?.toString() ?? '0';
//                       final exisDispatchedQtyStr =
//                           data['initialExisdispatched_qty']?.toString() ?? '0';

// // Parse all as double for safety
//                       final disQty = double.tryParse(disQtyStr) ?? 0;
//                       final existingData =
//                           double.tryParse(existingDataStr) ?? 0;
//                       final exisDispatchedQty =
//                           double.tryParse(exisDispatchedQtyStr) ?? 0;

// // Update these values
//                       data['dis_qty_total:'] = disQty.toString();
//                       data['dis_managerQty_total'] = disQty.toString();

// // Calculate the difference
//                       final totalQtyCal = existingData - disQty;
//                       print(
//                           "Calculationssss $totalQtyCal = $disQty - $existingData  $exisDispatchedQty");

// // Update Exisdispatched_qty safely
//                       data['Exisdispatched_qty'] =
//                           (exisDispatchedQty + totalQtyCal).toStringAsFixed(2);

//                       print(
//                           "Table data: existingdata = $existingData, dis_qty_total = ${data['dis_qty_total:']}, dis_managerQty_total = ${data['dis_managerQty_total']}, Exisdispatched_qty = ${data['Exisdispatched_qty']}");
//                     },
//                   )
//                 : SelectableText(
//                     data[key]?.toString() ?? '',
//                     textAlign: TextAlign.left,
//                     style: TableRowTextStyle,
//                     showCursor: false,
//                     cursorColor: Colors.blue,
//                     cursorWidth: 2.0,
//                     toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
//                     onTap: () {},
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

// Also update the header cells to match the column widths
  Widget _buildHeaderCell(IconData? icon, String? label) {
    // Define header width based on label
    double headerWidth;
    switch (label) {
      case 'I.L.No':
        headerWidth = Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.05
            : 80.0;
        break;
      case 'Item Description':
        headerWidth = Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.27
            : 250.0;
        break;
      case 'Qty.Inv':
        headerWidth = Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.05
            : 80.0;
        break;
      case 'Qty.Bal':
        headerWidth = Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.05
            : 80.0;
        break;
      case 'Dis.Req.Qty':
        headerWidth = Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.07
            : 80.0;
        break;
      case 'Actions':
        headerWidth = Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.05 // 4%
            : 40.0;
        break;
      default:
        headerWidth = Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.12
            : 120.0;
    }

    return Container(
      width: headerWidth,
      height: 30,
      decoration: BoxDecoration(color: Colors.grey[300]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, size: 15, color: Colors.blue),
          SizedBox(width: 5),
          if (label != null)
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Map<int, Map<String, dynamic>> originalData = {};

// Initialize originalData when the row is first created
  void initializeOriginalData(int index, Map<String, dynamic> data) {
    if (!originalData.containsKey(index)) {
      originalData[index] = Map<String, dynamic>.from(data);
      print(
          "Initialized originalData for index $index: ${originalData[index]}");
    }
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
    final IpAddress = await getActiveIpAddress();

    String? salesloginno = prefs.getString('salesloginno');
    String? saleslogiOrgid = prefs.getString('saleslogiOrgid');
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
    final IpAddress = await getActiveIpAddress();

    String customersite = CustomersiteidController.text;
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
            // hintText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            filled: true,
            fillColor: Color.fromARGB(255, 255, 255, 255),
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
                      style: TextStyle(fontSize: 15, color: Colors.black),
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
            // hintText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            filled: true,
            fillColor: Color.fromARGB(255, 255, 255, 255),
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
                  child: Text(suggestion, style: TextStyle(fontSize: 13)),
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
                  style: TextStyle(fontSize: 15, color: Colors.black),
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
                  style: TextStyle(fontSize: 15, color: Colors.black),
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
    final IpAddress = await getActiveIpAddress();

    // Base URL with the salesman_no parameter
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

  List<String> accessControl = [];
  Future<List<String>> fetchAccessControl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lableRoleIDList = prefs.getString('departmentid');
    String? salesloginnoStr = prefs.getString('salesloginno');

    String? commersialno = prefs.getString('commersialno');
    String? commersialrole = prefs.getString('commersialrole');

    final IpAddress = await getActiveIpAddress();

    final String url = commersialrole == null
        ? "$IpAddress/New_Updated_get_submenu_list/$lableRoleIDList/$salesloginnoStr/"
        : "$IpAddress/New_Updated_get_submenu_depid_list/$lableRoleIDList/$commersialno/";
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

  int currentLength = 0;
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
                                  widget.isViewpoagebool
                                      ? Icons.article_outlined
                                      : (widget.isFromEditPage
                                          ? Icons.edit
                                          : Icons.article_outlined),
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    widget.isViewpoagebool
                                        ? 'View Dispatch'
                                        : (widget.isFromEditPage
                                            ? 'Edit Dispatch'
                                            : 'View Dispatch'),
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
                                        ? screenWidth * 0.13
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
                                                  height: 32,
                                                  width: Responsive.isDesktop(
                                                          context)
                                                      ? screenWidth * 0.13
                                                      : screenWidth * 0.4,
                                                  child: MouseRegion(
                                                    cursor: SystemMouseCursors
                                                        .click, // Changes the cursor to indicate interaction

                                                    child: TextFormField(
                                                      controller:
                                                          requestTypeNoController,

                                                      readOnly:
                                                          widget.isFromEditPage
                                                              ? true
                                                              : false,
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
                                                        labelStyle:
                                                            DropdownTextStyle,
                                                      ),
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 73, 72, 72),
                                                          fontSize: 13),
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
                                                                .text
                                                                .toString();

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
                                  if (!widget.isFromEditPage)
                                    Tooltip(
                                      message: 'Search',
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 50.0),
                                        child: InkWell(
                                          onTap: () {
                                            String? value =
                                                requestTypeNoController.text;

                                            // Extract the first number from the value
                                            String? reqno =
                                                requestTypeNoController.text
                                                    .toString();

                                            // Check if pickNo is not null and not empty
                                            if (reqno != null &&
                                                reqno.isNotEmpty) {
                                              // Set the controller text to the desired format "PickNo_123"
                                              requestTypeNoController.text =
                                                  '$reqno';

                                              fetchDispatchDetails(reqno);
                                            } else {
                                              ShowWarning(
                                                  'Kindly enter a ReqNo');
                                            }

                                            postLogData(
                                                "View Dispatch", "Search");
                                          },
                                          child: Container(
                                              height: 28,
                                              width: 30,
                                              decoration: BoxDecoration(
                                                color: Colors
                                                    .blueGrey, // Button background color
                                                shape: BoxShape
                                                    .rectangle, // Makes the button circular
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Icon(
                                                  Icons.search,
                                                  color: Colors.white,
                                                ),
                                              )),
                                        ),
                                      ),
                                    ),

                                  SizedBox(
                                    width: 10,
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

                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? screenWidth * 0.27
                                        : screenWidth * 0.4,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 20),
                                          Row(
                                            children: [
                                              Icon(Icons.location_city,
                                                  size: 14,
                                                  color: Colors.blue[600]),
                                              SizedBox(width: 8),
                                              Text("Delivery Address",
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
                                                    height: 31,
                                                    // width: Responsive.isDesktop(context)
                                                    //     ? screenWidth * 0.086
                                                    //     : 130,

                                                    width: Responsive.isDesktop(
                                                            context)
                                                        ? screenWidth * 0.27
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
                                                      child: TextFormField(
                                                        focusNode:
                                                            DeliveryddressFocusNode,
                                                        onFieldSubmitted: (_) =>
                                                            _fieldFocusChange(
                                                                context,
                                                                DeliveryddressFocusNode,
                                                                RemardsFocusNode),
                                                        maxLength:
                                                            250, // Limits input to 250 characters
                                                        decoration:
                                                            InputDecoration(
                                                          counterText: '',

                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .zero,
                                                          ),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical:
                                                                      10.0,
                                                                  horizontal:
                                                                      10.0),
                                                          filled: true,
                                                          fillColor: Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255), // Hides the default counter text
                                                        ),
                                                        inputFormatters: () {
                                                          // Disallow specific characters for "Truck load"
                                                          return [
                                                            FilteringTextInputFormatter
                                                                .deny(
                                                              RegExp(
                                                                  r'[{}#‡|=&*^$@!\(\)\+]+'),
                                                              replacementString:
                                                                  '',
                                                            )
                                                          ];
                                                        }(),

                                                        controller:
                                                            FinalDeliveryAddressController,
                                                        style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 73, 72, 72),
                                                          fontSize: 15,
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            currentLength =
                                                                value.length;
                                                          });
                                                        },
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Text(
                                              '$currentLength/250',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // _buildTextFieldDesktop(
                                  //     'Delivery Address',
                                  //     FinalDeliveryAddressController.text,
                                  //     Icons.sixteen_mp_outlined,
                                  //     false,
                                  //     DeliveryddressFocusNode,
                                  //     RemardsFocusNode),
                                  SizedBox(
                                    width: 10,
                                  ),

                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? screenWidth * 0.13
                                        : screenWidth * 0.4,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 20),
                                          Row(
                                            children: [
                                              Icon(Icons.more_horiz,
                                                  size: 14,
                                                  color: Colors.blue[600]),
                                              SizedBox(width: 8),
                                              Text("Others",
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
                                                    height: 32,
                                                    // width: Responsive.isDesktop(context)
                                                    //     ? screenWidth * 0.086
                                                    //     : 130,

                                                    width: Responsive.isDesktop(
                                                            context)
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
                                                      child: TextFormField(
                                                        focusNode:
                                                            RemardsFocusNode,
                                                        onFieldSubmitted: (_) =>
                                                            _fieldFocusChange(
                                                                context,
                                                                RemardsFocusNode,
                                                                InvoiceFocusNode),

                                                        inputFormatters: () {
                                                          // Disallow specific characters for "Truck load"
                                                          return [
                                                            FilteringTextInputFormatter
                                                                .deny(
                                                              RegExp(
                                                                  r'[{}#‡|=&*^$@!\(\)\+]+'),
                                                              replacementString:
                                                                  '',
                                                            )
                                                          ];
                                                        }(),
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .zero,
                                                          ),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical:
                                                                      10.0,
                                                                  horizontal:
                                                                      10.0),
                                                          filled: true,
                                                          fillColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  255,
                                                                  255,
                                                                  255),
                                                        ),
                                                        controller:
                                                            FinalRemarksController,
                                                        style: TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    73,
                                                                    72,
                                                                    72),
                                                            fontSize: 15),
                                                        // onEditingComplete: () => _fieldFocusChange(
                                                        //     context, fromFocusNode, toFocusNode),
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // _buildTextFieldDesktop(
                                  //     'Others',
                                  //     FinalRemarksController.text,
                                  //     Icons.sixteen_mp_outlined,
                                  //     false,
                                  //     RemardsFocusNode,
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

                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? MediaQuery.of(context).size.width *
                                            0.31
                                        : MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: Responsive.isDesktop(context)
                                              ? 30
                                              : 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Row(
                                          //   children: [
                                          //     Text("Pending Invoice No",
                                          //         style: textboxheading),
                                          //     Icon(
                                          //       Icons.star,
                                          //       size: 8,
                                          //       color: Colors.red,
                                          //     )
                                          //   ],
                                          // ),
                                          // const SizedBox(height: 4),
                                          // Padding(
                                          //   padding: EdgeInsets.only(
                                          //       left: Responsive.isDesktop(
                                          //               context)
                                          //           ? 0
                                          //           : 10),
                                          //   child: Row(
                                          //     children: [
                                          //       Container(
                                          //           child:
                                          //               _buildInvoiceNoDropdown()),
                                          //       SizedBox(
                                          //         width: 8,
                                          //       ),
                                          //       // Container(
                                          //       //   decoration: BoxDecoration(
                                          //       //       color: buttonColor),
                                          //       //   height: 30,
                                          //       //   child: ElevatedButton(
                                          //       //     onPressed: () async {
                                          //       //       // Prevent multiple clicks if already processing
                                          //       //       if (_isProcessing) {
                                          //       //         return;
                                          //       //       }

                                          //       //       // If invoice number is provided
                                          //       //       if (InvoiceNoController
                                          //       //           .text.isNotEmpty) {
                                          //       //         setState(() {
                                          //       //           _isProcessing =
                                          //       //               true; // Set processing flag to true to block further clicks
                                          //       //         });

                                          //       //         try {
                                          //       //           // Fetch invoice details before showing the dialog
                                          //       //           await fetchInvoiceDetails();

                                          //       //           // Check if _isProcessing is still true (i.e., the fetching is done)
                                          //       //           if (_isProcessing) {
                                          //       //             isChecked = false;

                                          //       //             // Show the dialog once
                                          //       //             await showDialog(
                                          //       //               context: context,
                                          //       //               barrierDismissible:
                                          //       //                   false, // Prevent dismiss by tapping outside

                                          //       //               builder:
                                          //       //                   (BuildContext
                                          //       //                       context) {
                                          //       //                 return _InvoiceNoDetailsDialog(
                                          //       //                   context,
                                          //       //                   "${_totalController.text}",
                                          //       //                   '${InvoiceNoController.text}',
                                          //       //                 );
                                          //       //               },
                                          //       //             );
                                          //       //           }
                                          //       //         } catch (e) {
                                          //       //           // Handle errors gracefully
                                          //       //           print(
                                          //       //               'Error occurred while fetching invoice details: $e');
                                          //       //         } finally {
                                          //       //           // Reset the processing flag after the dialog is closed or if an error occurs
                                          //       //           setState(() {
                                          //       //             _isProcessing =
                                          //       //                 false;
                                          //       //             totalamountcontroller
                                          //       //                     .text =
                                          //       //                 '0'; // Reset amount field
                                          //       //           });
                                          //       //         }
                                          //       //       } else {
                                          //       //         checkinvoice(); // Handle if invoice number is empty
                                          //       //       }
                                          //       //     },
                                          //       //     style: ElevatedButton
                                          //       //         .styleFrom(
                                          //       //       shape:
                                          //       //           RoundedRectangleBorder(
                                          //       //         borderRadius:
                                          //       //             BorderRadius
                                          //       //                 .circular(8),
                                          //       //       ),
                                          //       //       minimumSize: const Size(
                                          //       //           45.0, 20.0),
                                          //       //       backgroundColor:
                                          //       //           Colors.transparent,
                                          //       //       shadowColor:
                                          //       //           Colors.transparent,
                                          //       //     ),
                                          //       //     child: Padding(
                                          //       //       padding:
                                          //       //           const EdgeInsets.only(
                                          //       //               top: 0,
                                          //       //               bottom: 0,
                                          //       //               left: 8,
                                          //       //               right: 8),
                                          //       //       child: const Text(
                                          //       //         'Go',
                                          //       //         style: TextStyle(
                                          //       //             fontSize: 16,
                                          //       //             color:
                                          //       //                 Colors.white),
                                          //       //       ),
                                          //       //     ),
                                          //       //   ),
                                          //       // ),
                                          //       SizedBox(
                                          //         width: 5,
                                          //       ),
                                          //       // Container(
                                          //       //   decoration: BoxDecoration(
                                          //       //       color: buttonColor),
                                          //       //   height: 30,
                                          //       //   child: ElevatedButton(
                                          //       //     onPressed: () async {
                                          //       //       if (InvoiceNoController
                                          //       //           .text.isNotEmpty) {
                                          //       //         await fetchInvoiceDetails();

                                          //       //         await fetchData();

                                          //       //         showDialog(
                                          //       //           barrierDismissible:
                                          //       //               false,
                                          //       //           context: context,
                                          //       //           builder: (BuildContext
                                          //       //               context) {
                                          //       //             return _PreviewInvoiceNoDetailsDialog(
                                          //       //               context,
                                          //       //               "${_totalController.text}",
                                          //       //               '${InvoiceNoController.text}',
                                          //       //             );
                                          //       //           },
                                          //       //         );
                                          //       //       } else {
                                          //       //         checkinvoice();
                                          //       //       }
                                          //       //       print(
                                          //       //           "Print the  create tabe data $createtableData");
                                          //       //     },
                                          //       //     style: ElevatedButton
                                          //       //         .styleFrom(
                                          //       //       shape:
                                          //       //           RoundedRectangleBorder(
                                          //       //         borderRadius:
                                          //       //             BorderRadius
                                          //       //                 .circular(8),
                                          //       //       ),
                                          //       //       minimumSize: const Size(
                                          //       //           45.0, 20.0),
                                          //       //       backgroundColor:
                                          //       //           Colors.transparent,
                                          //       //       shadowColor:
                                          //       //           Colors.transparent,
                                          //       //     ),
                                          //       //     child: Padding(
                                          //       //       padding:
                                          //       //           const EdgeInsets.only(
                                          //       //               top: 0,
                                          //       //               bottom: 0,
                                          //       //               left: 8,
                                          //       //               right: 8),
                                          //       //       child: const Text(
                                          //       //         'Preview',
                                          //       //         style: TextStyle(
                                          //       //             fontSize: 16,
                                          //       //             color:
                                          //       //                 Colors.white),
                                          //       //       ),
                                          //       //     ),
                                          //       //   ),
                                          //       // )
                                          //     ],
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.02),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: Responsive.isDesktop(context)
                                          ? MediaQuery.of(context).size.width *
                                              0.09
                                          : MediaQuery.of(context).size.width *
                                              0.3,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height:
                                                  Responsive.isDesktop(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.01
                                                      : 20,
                                            ),
                                            Row(
                                              children: const [
                                                Text("No.Of Item",
                                                    style: textboxheading),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
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
                                                    : 170,
                                                child: TextField(
                                                    readOnly: true,
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
                              if (!widget.isViewpoagebool)
                                if (widget.isFromEditPage)
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
                                            await updateDispatch();
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
                                            "Update",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 50.0, left: 10),
                                child: Container(
                                  height: 35,
                                  decoration: BoxDecoration(color: buttonColor),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5, top: 3, bottom: 3),
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
                                        List<String> columnNames =
                                            getDisplayedColumns();
                                        await createExcel(
                                            columnNames, convertedData);
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
                                            padding:
                                                const EdgeInsets.only(right: 8),
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
                                    right: MediaQuery.of(context).size.width *
                                        0.03),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: Responsive.isDesktop(context)
                                          ? MediaQuery.of(context).size.width *
                                              0.10
                                          : MediaQuery.of(context).size.width *
                                              0.4,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height:
                                                  Responsive.isDesktop(context)
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
                                              height:
                                                  Responsive.isDesktop(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.006
                                                      : 10,
                                            ),
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
                                                    readOnly: true,
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
                          SizedBox(
                            height: 30,
                          ),
                          // SingleChildScrollView(
                          //   scrollDirection: Axis.horizontal,
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.start,
                          //     children: [
                          //       SizedBox(
                          //         width: Responsive.isDesktop(context) ? 45 : 5,
                          //       ),
                          //       Container(
                          //         height: 35,
                          //         decoration: BoxDecoration(color: buttonColor),
                          //         child: ElevatedButton(
                          //           onPressed: () async {
                          //             if (tableData.isEmpty) {
                          //               searchallfeild();
                          //             } else {
                          //               await postCreateDispatch();
                          //               setState(() {
                          //                 tableData.clear();
                          //                 CustomerNoController.clear();
                          //                 CustomerNameController.clear();
                          //                 CustomersiteidController.clear();
                          //                 CustomersitechannelController.clear();
                          //                 CustomeSiteList = [];
                          //                 InvoiceNoList = [];
                          //                 InvoiceNoController.clear();
                          //                 NoofitemController.text = '0';
                          //                 totaldisreqController.text = '0';
                          //                 totalinvoicecountbool = false;
                          //               });
                          //               _showConfirmationDialog();
                          //             }
                          //           },
                          //           style: ElevatedButton.styleFrom(
                          //             shape: RoundedRectangleBorder(
                          //               borderRadius: BorderRadius.circular(8),
                          //             ),
                          //             minimumSize: const Size(
                          //                 45.0, 31.0), // Set width and height
                          //             backgroundColor: Colors
                          //                 .transparent, // Make background transparent to show gradient
                          //             shadowColor: Colors
                          //                 .transparent, // Disable shadow to preserve gradient
                          //           ),
                          //           child: Padding(
                          //             padding: const EdgeInsets.only(
                          //                 top: 5, bottom: 5, left: 8, right: 8),
                          //             child: const Text(
                          //               'Send',
                          //               style: TextStyle(
                          //                   fontSize: 16, color: Colors.white),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //       // SizedBox(
                          //       //   width:
                          //       //       Responsive.isDesktop(context) ? 45 : 15,
                          //       // ),
                          //       // Container(
                          //       //   height: 35,
                          //       //   decoration: BoxDecoration(color: buttonColor),
                          //       //   child: ElevatedButton(
                          //       //     onPressed: () {
                          //       //       setState(() {
                          //       //         tableData.clear();
                          //       //         InvoiceNoController.clear();
                          //       //         NoofitemController.clear();
                          //       //         totaldisreqController.clear();
                          //       //       });
                          //       //       successfullyLoginMessage();
                          //       //     },
                          //       //     style: ElevatedButton.styleFrom(
                          //       //       shape: RoundedRectangleBorder(
                          //       //         borderRadius: BorderRadius.circular(8),
                          //       //       ),
                          //       //       minimumSize: const Size(
                          //       //           45.0, 31.0), // Set width and height
                          //       //       backgroundColor: Colors
                          //       //           .transparent, // Make background transparent to show gradient
                          //       //       shadowColor: Colors
                          //       //           .transparent, // Disable shadow to preserve gradient
                          //       //     ),
                          //       //     child: Padding(
                          //       //       padding: const EdgeInsets.only(
                          //       //           top: 5, bottom: 5, left: 8, right: 8),
                          //       //       child: const Text(
                          //       //         'Prev.Req',
                          //       //         style: TextStyle(
                          //       //             fontSize: 16, color: Colors.white),
                          //       //       ),
                          //       //     ),
                          //       //   ),
                          //       // ),
                          //       SizedBox(
                          //         width: 5,
                          //       ),
                          //       Container(
                          //         height: 35,
                          //         decoration: BoxDecoration(color: buttonColor),
                          //         child: ElevatedButton(
                          //           onPressed: () {
                          //             setState(() {
                          //               tableData.clear();
                          //               CustomerNoController.clear();
                          //               CustomerNameController.clear();
                          //               CustomersiteidController.clear();
                          //               CustomersitechannelController.clear();

                          //               CustomeSiteList = [];
                          //               InvoiceNoList = [];
                          //               InvoiceNoController.clear();

                          //               NoofitemController.text = '0';
                          //               totaldisreqController.text = '0';
                          //               totalinvoicecountbool = false;
                          //             });
                          //             // successfullyLoginMessage();
                          //           },
                          //           style: ElevatedButton.styleFrom(
                          //             shape: RoundedRectangleBorder(
                          //               borderRadius: BorderRadius.circular(8),
                          //             ),
                          //             minimumSize: const Size(
                          //                 45.0, 31.0), // Set width and height
                          //             backgroundColor: Colors
                          //                 .transparent, // Make background transparent to show gradient
                          //             shadowColor: Colors
                          //                 .transparent, // Disable shadow to preserve gradient
                          //           ),
                          //           child: Padding(
                          //             padding: const EdgeInsets.only(
                          //                 top: 5, bottom: 5, left: 8, right: 8),
                          //             child: const Text(
                          //               'Clear',
                          //               style: TextStyle(
                          //                   fontSize: 16, color: Colors.white),
                          //             ),
                          //           ),
                          //         ),
                          //       )
                          //     ],
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: 30,
                          // ),
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

  Widget _PreviewInvoiceNoDetailsDialog(
      BuildContext context, String totalamt, String invoiceno) {
    double screenWidth = MediaQuery.of(context).size.width;

    Widget _buildTextFieldDesktop(
      String label,
      String value,
    ) {
      double screenWidth = MediaQuery.of(context).size.width;
      return Container(
        width: Responsive.isDesktop(context) ? screenWidth * 0.1 : 130,
        child: Padding(
          padding: const EdgeInsets.only(left: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
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
                        // width: Responsive.isDesktop(context)
                        //     ? screenWidth * 0.086
                        //     : 130,

                        width: Responsive.isDesktop(context)
                            ? screenWidth * 0.1
                            : 125,
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
                            child: TextField(
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
                                  fillColor: Color.fromARGB(255, 250, 250,
                                      250), // Set the background color to grey[200]
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5.0,
                                    horizontal: 10.0,
                                  ),
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

    return Dialog(
      child: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            width: Responsive.isDesktop(context) ? screenWidth * 0.6 : 600,
            height: Responsive.isDesktop(context) ? 500 : 500,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Invoice Preview",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Tooltip(
                        message: 'Close',
                        child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.cancel)),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runSpacing: 5,
                      children: [
                        _buildTextFieldDesktop('Invoice No', invoiceno),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Container(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: _PreviewviewbuildTable(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _InvoiceNoDetailsDialog(
      BuildContext context, String totalamt, String invoiceno) {
    double screenWidth = MediaQuery.of(context).size.width;

    Widget _buildTextFieldDesktop(
      String label,
      String value,
    ) {
      double screenWidth = MediaQuery.of(context).size.width;
      return Container(
        width: Responsive.isDesktop(context) ? screenWidth * 0.1 : 130,
        child: Padding(
          padding: const EdgeInsets.only(left: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
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
                        // width: Responsive.isDesktop(context)
                        //     ? screenWidth * 0.086
                        //     : 130,

                        width: Responsive.isDesktop(context)
                            ? screenWidth * 0.1
                            : 125,
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
                            child: TextField(
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
                                  fillColor: Color.fromARGB(255, 250, 250,
                                      250), // Set the background color to grey[200]
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5.0,
                                    horizontal: 10.0,
                                  ),
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

    return Dialog(
      child: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            width: Responsive.isDesktop(context) ? screenWidth * 0.6 : 600,
            height: Responsive.isDesktop(context) ? 500 : 500,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Invoice Pop-Up",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Tooltip(
                        message: 'Close',
                        child: IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runSpacing: 5,
                      children: [
                        _buildTextFieldDesktop('Invoice No', invoiceno),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Container(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child:
                                  _viewbuildTable(), // Assuming _viewbuildTable() returns a valid widget
                            ),
                          ),
                        ),
                        if (!Responsive.isDesktop(context))
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: Responsive.isDesktop(context)
                                                  ? 0
                                                  : 40,
                                              left:
                                                  Responsive.isDesktop(context)
                                                      ? 30
                                                      : 0),
                                          child: Container(
                                            width: 100,
                                            height: 35,
                                            decoration: BoxDecoration(
                                                color: buttonColor),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                _addData();
                                                Navigator.pop(context);
                                                _updatecount();
                                                _updatedisreqamt();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                backgroundColor: buttonColor,
                                                minimumSize: const Size(45.0,
                                                    40.0), // Set width and height
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(0),
                                                child: const Text(
                                                  'Add',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 10,
                                              right:
                                                  Responsive.isDesktop(context)
                                                      ? 100
                                                      : 10),
                                          child: Container(
                                            width: Responsive.isDesktop(context)
                                                ? screenWidth * 0.11
                                                : 150,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: Responsive.isDesktop(
                                                          context)
                                                      ? 20
                                                      : 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Total Order Req',
                                                      style: textboxheading),
                                                  const SizedBox(height: 10),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                            height: 27,
                                                            width: Responsive
                                                                    .isDesktop(
                                                                        context)
                                                                ? screenWidth *
                                                                    0.086
                                                                : 120,
                                                            child: TextField(
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
                                                                filled:
                                                                    true, // Enable the background fill
                                                                fillColor: Colors
                                                                    .white, // Set the background color to grey[200]
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  vertical: 5.0,
                                                                  horizontal:
                                                                      10.0,
                                                                ),
                                                              ),
                                                              readOnly: true,
                                                              onChanged:
                                                                  (text) {
                                                                _updateTotal(); // Optionally, update total when text changes
                                                              },
                                                              controller:
                                                                  totalamountcontroller, // Use totalamountcontroller directly

                                                              style:
                                                                  textBoxstyle,
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        if (Responsive.isDesktop(context))
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: Responsive.isDesktop(context)
                                                ? 0
                                                : 40,
                                            left: Responsive.isDesktop(context)
                                                ? 30
                                                : 0),
                                        child: Container(
                                          decoration:
                                              BoxDecoration(color: buttonColor),
                                          width: 100,
                                          height: 35,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _addData();
                                              Navigator.pop(context);
                                              _updatecount();
                                              _updatedisreqamt();
                                              setState(() {
                                                InvoiceNoList = InvoiceNoList
                                                    .where((invoiceNo) =>
                                                        !tableData.any((data) =>
                                                            data['invoiceno'] ==
                                                            invoiceNo)).toList();
                                                InvoiceNoController.clear();
                                              });

                                              print(
                                                  "invoice details after tabledata $InvoiceNoList");

                                              print("tableData a $tableData");
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              backgroundColor: buttonColor,

                                              minimumSize: const Size(45.0,
                                                  40.0), // Set width and height
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(0),
                                              child: const Text(
                                                'Add',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 10,
                                            right: Responsive.isDesktop(context)
                                                ? 100
                                                : 10),
                                        child: Container(
                                          width: Responsive.isDesktop(context)
                                              ? screenWidth * 0.11
                                              : 150,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: Responsive.isDesktop(
                                                        context)
                                                    ? 20
                                                    : 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Total Order Req',
                                                    style: textboxheading),
                                                const SizedBox(height: 10),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                          height: 27,
                                                          width: Responsive
                                                                  .isDesktop(
                                                                      context)
                                                              ? screenWidth *
                                                                  0.086
                                                              : 120,
                                                          child: TextField(
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
                                                              filled:
                                                                  true, // Enable the background fill
                                                              fillColor: Colors
                                                                  .white, // Set the background color to grey[200]
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                vertical: 5.0,
                                                                horizontal:
                                                                    10.0,
                                                              ),
                                                            ),
                                                            readOnly: true,
                                                            onChanged: (text) {
                                                              _updateTotal(); // Optionally, update total when text changes
                                                            },
                                                            controller:
                                                                totalamountcontroller, // Use totalamountcontroller directly

                                                            style: textBoxstyle,
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> createtableData = [];
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];

  Future<void> getAndFetchInvoiceDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno');
    final IpAddress = await getActiveIpAddress();

    if (getTableData.isEmpty) {
      print("No data available in getTableData to fetch invoice details.");
      return;
    }

    print("Data available in getTableData: $getTableData");

    // Clear previous data
    createtableData.clear();
    _controllers.clear();
    _focusNodes.clear();

    for (var row in getTableData) {
      try {
        int invoicenumber =
            int.tryParse(row['INVOICE_NUMBER']?.toString() ?? '0') ?? 0;
        int line_number =
            int.tryParse(row['LINE_NUMBER']?.toString() ?? '0') ?? 0;
        int disQtyTotal =
            int.tryParse(row['DISPATCHED_QTY']?.toString() ?? '0') ?? 0;
        int disManagerQtyTotal =
            int.tryParse(row['DISPATCHED_BY_MANAGER']?.toString() ?? '0') ?? 0;

        if (disQtyTotal == 0 && disManagerQtyTotal == 0) {
          print(
              "Skipping row with Invoice No: ${row['INVOICE_NUMBER']} due to 0 dispatch.");
          continue;
        }

        String invoiceNo = row['INVOICE_NUMBER']?.toString() ?? '';
        String itemCode = row['INVENTORY_ITEM_ID']?.toString() ?? '';
        String itemDescription = row['ITEM_DESCRIPTION']?.toString() ?? '';

        if (invoiceNo.isEmpty || itemCode.isEmpty || itemDescription.isEmpty)
          continue;

        // Prepare base row
        Map<String, dynamic> newRow = {
          'id': line_number.toString(),
          'invoice_number': invoiceNo,
          'line_number': line_number.toString(),
          'itemcode': itemCode,
          'itemdetails': itemDescription,
          'dis_qty_total': disQtyTotal.toString(),
          'dis_managerQty_total': disManagerQtyTotal.toString(),
          'invoicebalqty': (disQtyTotal + disManagerQtyTotal).toString(),
          'alreadydispatchedqty': '0',
          'customer_trx_id': row['customer_trx_id']?.toString() ?? '',
          'customer_trx_line_id': row['customer_trx_line_id']?.toString() ?? '',
          'invoiceqty': (disQtyTotal + disManagerQtyTotal).toString(),
          'itemqty': '0',
          'quantity': (disQtyTotal + disManagerQtyTotal).toString(),
          'Exisdispatched_qty': '0',
          // 'baldispatched_qty': (disQtyTotal + disManagerQtyTotal).toString(),
          'disreqqty': '0',
          'getinvoiceNo': row['INVOICE_NUMBER']?.toString() ?? '',
          'getitemcode': row['INVENTORY_ITEM_ID']?.toString() ?? '',
          'getitemdetails': row['ITEM_DESCRIPTION']?.toString() ?? '',
        };

        createtableData.add(newRow);
        _controllers.add(TextEditingController());
        _focusNodes.add(FocusNode());
      } catch (e) {
        print('Error processing row: $e');
      }
    }

    await fetchAdditionalInvoiceDetails(salesloginno, IpAddress!);

    setState(() {
      print("Final updated createtableData (${createtableData.length} items):");
      for (var item in createtableData) {
        print(item);
      }
    });
  }

  Future<void> fetchAdditionalInvoiceDetails(
      String? salesloginno, String IpAddress) async {
    try {
      for (var row in createtableData) {
        try {
          String invoiceNo = row['invoice_number']?.toString() ?? '';
          String itemCode = row['itemcode']?.toString() ?? '';
          if (invoiceNo.isEmpty || itemCode.isEmpty) continue;

          final String detailsUrl =
              '$IpAddress/invoicedetails/?salesman_no=$salesloginno&customer_number=${CustomerNoController.text}&invoice_number=$invoiceNo&item_code=$itemCode';

          print("detailsUrl: $detailsUrl");
          var response = await http.get(Uri.parse(detailsUrl));

          if (response.statusCode == 200 && response.body.isNotEmpty) {
            var data = json.decode(response.body);

            if (data['results'] != null &&
                data['results'] is List &&
                data['results'].isNotEmpty) {
              // Only find row where item_code == itemCode
              var matchedResult = data['results'].firstWhere(
                  (result) => result['item_code'] == itemCode,
                  orElse: () => null);

              if (matchedResult != null) {
                int quantity = int.tryParse(
                        matchedResult['quantity']?.toString() ?? '0') ??
                    0;
                int dispatchedQty = int.tryParse(
                        matchedResult['dispatched_qty']?.toString() ?? '0') ??
                    0;

                // Update the row with old quantity info
                row['undel_id'] = matchedResult['undel_id']?.toString() ?? '';
                row['customer_trx_id'] =
                    matchedResult['customer_trx_id']?.toString() ??
                        row['customer_trx_id'];
                row['customer_trx_line_id'] =
                    matchedResult['customer_trx_line_id']?.toString() ??
                        row['customer_trx_line_id'];
                row['itemdetails'] = matchedResult['description']?.toString() ??
                    row['itemdetails'];
                row['quantity'] = quantity.toString();
                row['alreadydispatchedqty'] = dispatchedQty.toString();

                row['getitemcode'] = matchedResult['item_code']?.toString() ??
                    row['getitemcode'];
                row['getitemdetails'] =
                    matchedResult['description']?.toString() ??
                        row['getitemdetails'];

                // ✅ Add the new extra columns
                row['oldquantity'] = quantity.toString();
                row['olddispatchedqty'] = dispatchedQty.toString();
                row['baldispatched_qty'] =
                    (quantity - dispatchedQty).toString();
              }
            }
          }
        } catch (e) {
          print('Error fetching additional invoice details: $e');
        }
      }

      // Sort rows by line number after all updates
      createtableData.sort((a, b) {
        try {
          return int.parse(a['line_number']?.toString() ?? '0')
              .compareTo(int.parse(b['line_number']?.toString() ?? '0'));
        } catch (_) {
          return 0;
        }
      });
    } catch (e) {
      print('Error in fetchAdditionalInvoiceDetails: $e');
    }
  }

  // Future<void> fetchAdditionalInvoiceDetails(
  //     String? salesloginno, String IpAddress) async {
  //   try {
  //     for (var row in createtableData) {
  //       try {
  //         String invoiceNo = row['invoice_number']?.toString() ?? '';
  //         String itemCode = row['itemcode']?.toString() ?? '';
  //         if (invoiceNo.isEmpty || itemCode.isEmpty) continue;

  //         final String detailsUrl =
  //             '$IpAddress/invoicedetails/?salesman_no=$salesloginno&customer_number=${CustomerNoController.text}&invoice_number=$invoiceNo&item_code=$itemCode';

  //         var response = await http.get(Uri.parse(detailsUrl));
  //         print("detailsUrl: $detailsUrl");

  //         if (response.statusCode == 200 && response.body.isNotEmpty) {
  //           var data = json.decode(response.body);

  //           if (data['results'] != null &&
  //               data['results'] is List &&
  //               data['results'].isNotEmpty) {
  //             var result = data['results'][0];

  //             // Parse and safely handle values
  //             int quantity =
  //                 int.tryParse(result['quantity']?.toString() ?? '0') ?? 0;
  //             int dispatchedQty =
  //                 int.tryParse(result['dispatched_qty']?.toString() ?? '0') ??
  //                     0;

  //             row['undel_id'] = result['undel_id']?.toString() ?? '';
  //             row['customer_trx_id'] = result['customer_trx_id']?.toString() ??
  //                 row['customer_trx_id'];
  //             row['customer_trx_line_id'] =
  //                 result['customer_trx_line_id']?.toString() ??
  //                     row['customer_trx_line_id'];
  //             row['itemdetails'] =
  //                 result['description']?.toString() ?? row['description'];
  //             row['quantity'] = quantity.toString();
  //             row['alreadydispatchedqty'] = dispatchedQty.toString();
  //             row['baldispatched_qty'] = (quantity - dispatchedQty).toString();
  //             row['getitemcode'] =
  //                 result['getitemcode']?.toString() ?? row['getitemcode'];
  //             row['getitemdetails'] =
  //                 result['getitemdetails']?.toString() ?? row['getitemdetails'];
  //           }
  //         }
  //       } catch (e) {
  //         print('Error fetching additional invoice details: $e');
  //       }
  //     }

  //     // Sort after updates
  //     createtableData.sort((a, b) {
  //       try {
  //         return int.parse(a['line_number']?.toString() ?? '0')
  //             .compareTo(int.parse(b['line_number']?.toString() ?? '0'));
  //       } catch (_) {
  //         return 0;
  //       }
  //     });
  //   } catch (e) {
  //     print('Error in fetchAdditionalInvoiceDetails: $e');
  //   }
  // }

  Timer? _timer;
  TextEditingController totalamountcontroller = TextEditingController();
  void _addData() {
    // Initialize a list to store the modified order
    List<Map<String, dynamic>> collapsedTableData = [];

    print("create table after add the rows : $createtableData");

    // First, add the rows in the correct order (row1, row2, row3, etc.)
    for (int i = 0; i < createtableData.length; i++) {
      var item = createtableData[i];
      var disreqQty = double.tryParse(_controllers[i].text) ?? 0.0;

      if (disreqQty > 0) {
        // Prepare the new item for tableData
        Map<String, dynamic> newItem = {
          'id': item['id'],
          'invoiceno': InvoiceNoController.text,
          'itemcode': item['itemcode'],
          'itemdetails': item['itemdetails'],
          'invoiceqty': item['invoiceqty'],
          'dispatchqty': item["alreadydispatchedqty"],
          'balanceqty': (double.parse(item['invoiceqty'].toString()) -
                  double.parse(disreqQty.toString()))
              .toString(), // Calculate balanceqty
          'disreqqty': disreqQty.toString(),
          'invoicebalqty': item['invoicebalqty'],
          'amount': item['amount'],
          'item_cost': item['item_cost'],
          'itemqty': item['itemqty'],
        };
        collapsedTableData.add(newItem); // Add to the collapsed list
      }
    }

    // Apply collapsing logic to reorder rows (row1, row3, row2, row4, etc.)
    List<Map<String, dynamic>> reorderedTableData = [];
    for (int i = 0; i < collapsedTableData.length; i++) {
      // Add odd-indexed rows (row1, row3, row5, ...)
      if (i % 2 == 0) {
        reorderedTableData.add(collapsedTableData[i]);
      }
    }

    for (int i = 0; i < collapsedTableData.length; i++) {
      // Add even-indexed rows (row2, row4, row6, ...)
      if (i % 2 != 0) {
        reorderedTableData.add(collapsedTableData[i]);
      }
    }

    setState(() {
      tableData.addAll(reorderedTableData);
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController2.dispose();
    _verticalScrollController2.dispose();
    requestNoController.dispose();

    // Dispose of controllers, focus nodes, and cancel the timer
    _controllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((focusNode) => focusNode.dispose());

    // _timer?.cancel(); // Cancel the timer
    totalamountcontroller.dispose(); // Dispose of the total controller
    super.dispose();

    postLogData("View Dispatch", "Closed");
  }

  TextEditingController _totalController = TextEditingController();
  // Calculate the total sum of disreqqty
  // Calculate the total sum of disreqqty
  void _updateTotal() {
    // Use the getTotalFinalAmt function to get the total amount
    double totalAmount =
        getTotalFinalAmt(createtableData); // Get the total amount
    totalamountcontroller.text =
        _removeDecimalIfWhole(totalAmount.toString()); // Format and assign

    print("total amountttt ${totalamountcontroller.text}");
  }

  double getTotalFinalAmt(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['disreqqty'] ?? '0') ?? 0.0;
      totalQuantity += quantity;
    }
    return totalQuantity;
  }

  bool isChecked = false; // State variable to manage checkbox value

  Widget _PreviewviewbuildTable() {
    List<Map<String, dynamic>> sortedTableData = List.from(createtableData);
    sortedTableData.sort((a, b) =>
        int.parse(a['id'].toString()).compareTo(int.parse(b['id'].toString())));

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
                width: MediaQuery.of(context).size.width * 0.54,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 0, right: 0, top: 0, bottom: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildHeaderCell("Invoice Line No", Icons.list_alt),
                        buildHeaderCell("Item Code", Icons.code),
                        buildHeaderCell("Item Description", Icons.description),
                        buildHeaderCell("Qty. Invoiced", Icons.check_circle),
                        buildHeaderCell("Qty. Balance", Icons.equalizer),
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
                  else if (createtableData.isNotEmpty)
                    Expanded(
                      // Ensure that the content inside scrolls
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: createtableData.map((data) {
                            var index = createtableData.indexOf(data);
                            return PreviewbuildRow(index, data);
                          }).toList(),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: Text("No data available."),
                    ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget PreviewbuildRow(int index, Map<String, dynamic> data) {
    var id = data['id'].toString();
    var itemcode = _removeDecimalIf(data['itemcode']);
    var itemdetails = _removeDecimalIf(data['itemdetails']);
    var invoiceqty = _removeDecimalIf(data['invoiceqty']);
    var invoicebalqty = _removeDecimalIf(data['invoicebalqty']);

    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildDataCell(id),
          buildDataCell(itemcode),
          buildDataCell(itemdetails),
          buildDataCell(invoiceqty),
          buildDataCell(invoicebalqty),
        ],
      ),
    );
  }

  Widget _viewbuildTable() {
    List<Map<String, dynamic>> sortedTableData = List.from(createtableData);
    sortedTableData.sort((a, b) =>
        int.parse(a['id'].toString()).compareTo(int.parse(b['id'].toString())));

    print("Create table datas : $createtableData");
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
                    ? MediaQuery.of(context).size.width * 0.54
                    : MediaQuery.of(context).size.width * 1.4,
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
                          buildHeaderCell("Invoice Line No", Icons.list_alt),
                          buildHeaderCell("Item Code", Icons.code),
                          buildHeaderCell(
                              "Item Description", Icons.description),
                          buildHeaderCell("Qty. Invoiced", Icons.check_circle),
                          buildHeaderCell("Qty. Balance", Icons.equalizer),
                          Flexible(
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(color: Colors.white),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.assignment,
                                        size: 14, color: Colors.blue),
                                    Text(
                                      "Dis.Req.Qty",
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle,
                                    ),
                                    SizedBox(width: 2),
                                    StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setState) {
                                      return Tooltip(
                                        message: "Select All",
                                        child: Checkbox(
                                          value: isChecked,
                                          // onChanged: (value) {
                                          //   setState(() {
                                          //     isChecked =
                                          //         value!; // Update the state
                                          //     if (isChecked) {
                                          //       // When checked, set all disreqqty
                                          //       for (int i = 0;
                                          //           i <
                                          //               createtableData
                                          //                   .length;
                                          //           i++) {
                                          //         double invoiceBalQty = double
                                          //                 .tryParse(_removeDecimalIf(
                                          //                     createtableData[
                                          //                             i][
                                          //                         'invoicebalqty'])) ??
                                          //             0.0;
                                          //         _controllers[i].text =
                                          //             invoiceBalQty
                                          //                 .toString(); // Update text controllers
                                          //         createtableData[i]
                                          //                 ['disreqqty'] =
                                          //             invoiceBalQty
                                          //                 .toString(); // Update data
                                          //       }
                                          //       _updateTotal();
                                          //     } else {
                                          //       // Optional: Reset to previous values if unchecked
                                          //       for (int i = 0;
                                          //           i <
                                          //               createtableData
                                          //                   .length;
                                          //           i++) {
                                          //         _controllers[i]
                                          //             .clear(); // Clear the text fields if needed
                                          //         createtableData[i]
                                          //                 ['disreqqty'] =
                                          //             ''; // Reset or handle as necessary
                                          //       }
                                          //       totalamountcontroller.text =
                                          //           '0';
                                          //     }
                                          //   });
                                          // },

                                          onChanged: (value) {
                                            setState(() {
                                              isChecked =
                                                  value!; // Update the state
                                              if (isChecked) {
                                                // When checked, prefill all disreqqty fields
                                                for (int i = 0;
                                                    i < createtableData.length;
                                                    i++) {
                                                  double invoiceBalQty = double
                                                          .tryParse(_removeDecimalIf(
                                                              createtableData[i]
                                                                  [
                                                                  'invoicebalqty'])) ??
                                                      0.0;
                                                  _controllers[i].text =
                                                      invoiceBalQty.toString();
                                                  createtableData[i]
                                                          ['disreqqty'] =
                                                      invoiceBalQty.toString();
                                                }
                                              } else {
                                                // Clear fields if unchecked
                                                for (int i = 0;
                                                    i < createtableData.length;
                                                    i++) {
                                                  _controllers[i].clear();
                                                  createtableData[i]
                                                      ['disreqqty'] = '';
                                                }
                                              }
                                              _updateTotal();
                                            });
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          )
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
                    else if (createtableData.isNotEmpty)
                      Expanded(
                        // Ensure that the content inside scrolls
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: createtableData.map((data) {
                              var index = createtableData.indexOf(data);
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
            buildInputCell(index, double.tryParse(invoicebalqty) ?? 0.0),
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

  Widget buildInputCell(int index, double invoicebalqty) {
    return Flexible(
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey),
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
                setState(() {
                  double enteredQty = double.tryParse(value) ?? 0.0;

                  // Allow changes regardless of checkbox status
                  if (enteredQty > invoicebalqty) {
                    // Show dialog only if entered quantity exceeds the balance
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
                                          'The entered quantity exceeds the available balance. Would you like to adjust it to $invoicebalqty?',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
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
                                          setState(() {
                                            _controllers[index].text =
                                                invoicebalqty.toString();
                                            createtableData[index]
                                                    ['disreqqty'] =
                                                invoicebalqty.toString();
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
                                            createtableData[index]
                                                ['disreqqty'] = "0";
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
                  } else {
                    createtableData[index]['disreqqty'] = value;
                  }
                  _updateTotal();
                });
              },
              onSubmitted: (value) {
                double enteredQty = double.tryParse(value) ?? 0;
                setState(() {
                  if (enteredQty > invoicebalqty) {
                    _controllers[index].text = invoicebalqty.toString();
                    createtableData[index]['disreqqty'] =
                        invoicebalqty.toString();
                  } else {
                    createtableData[index]['disreqqty'] = value;
                  }
                  _updateTotal();
                });

                if (index < _focusNodes.length - 1) {
                  FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                } else {
                  FocusScope.of(context).unfocus();
                }
              },
              textAlign: TextAlign.center,
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> PreviewtableData = [];

  Future<void> fetchData() async {
    final IpAddress = await getActiveIpAddress();

    String invoiceno =
        InvoiceNoController.text; // Get the invoice number from the controller
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

  Future<void> postCreateDispatch() async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/Create_Dispatch/';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno') ?? '';
    String? saveloginname = prefs.getString('saveloginname') ?? '';

    DateTime now = DateTime.now();
    // Format it to YYYY-MM-DD'T'HH:mm:ss'
    String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

    try {
      String reqno = requestNoController.text.toString();
      String warehouse = WarehouseNameController.text.isNotEmpty
          ? WarehouseNameController.text
          : '';
      String org_id = OrganisationIdController.text.isNotEmpty
          ? OrganisationIdController.text
          : '';
      String org_name = OrganisationNameController.text.isNotEmpty
          ? OrganisationNameController.text
          : '';
      String salesman_id = SalesmanIdeController.text.isNotEmpty
          ? SalesmanIdeController.text
          : '';
      String salesman_channel = SalesmanChannelController.text.isNotEmpty
          ? SalesmanChannelController.text
          : '0';
      String cusid = CustomeridController.text.isNotEmpty
          ? CustomeridController.text
          : '0';
      String cusname = CustomerNameController.text.isNotEmpty
          ? CustomerNameController.text
          : '';
      String cusno = CustomerNoController.text.isNotEmpty
          ? CustomerNoController.text
          : '0'; // Ensure it's a string

      String cussite = CustomersiteidController.text.isNotEmpty
          ? CustomersiteidController.text
          : '0';
      String invoiceno =
          InvoiceNoController.text.isNotEmpty ? InvoiceNoController.text : '';
      print("tableeeeeeeeeeeeee dataaaaaa: $tableData");
      // Iterate through each row in tableData and create dispatch data for each row
      for (int i = 0; i < tableData.length; i++) {
        var row = tableData[i]; // Use 'i' to access the correct row
        // var disreqQty = double.tryParse(_controllers[i].text) ?? 0.0;
        var disreqQty =
            double.tryParse(row['disreqqty']?.toString() ?? '0') ?? 0.0;

        // Only proceed if disreqQty is greater than 0

        Map<String, dynamic> createDispatchData = {
          "REQ_ID": reqno,
          "TO_WAREHOUSE": warehouse,
          "ORG_ID": org_id,
          "ORG_NAME": org_name,
          "SALESREP_ID": salesman_id,
          "SALESMAN_NO": salesloginno.isNotEmpty ? salesloginno : 'Unknown',
          "SALESMAN_NAME": saveloginname.isNotEmpty ? saveloginname : 'Unknown',
          "SALES_CHANNEL": salesman_channel,
          "CUSTOMER_ID": cusid,
          "CUSTOMER_NUMBER": cusno.toString(),
          "CUSTOMER_NAME": cusname,
          "CUSTOMER_SITE_ID": cussite,
          "INVOICE_DATE": formattedDate,
          "INVOICE_NUMBER": row['invoiceno']?.toString() ?? '0',
          "LINE_NUMBER": row['id']?.toString() ?? '0',
          "INVENTORY_ITEM_ID": row['itemcode']?.toString() ?? '0',
          'ITEM_DESCRIPTION': row['itemdetails']?.toString() ?? '0',
          "TOT_QUANTITY": row['invoiceqty']?.toString() ?? '0',
          "DISPATCHED_QTY": disreqQty.toString(),
          "BALANCE_QTY": (int.tryParse(row['invoiceqty']?.toString() ?? '0')! -
                  disreqQty.toInt())
              .toString(),
          "DISPATCHED_BY_MANAGER": disreqQty.toString(),
          "TRUCK_SCAN_QTY": disreqQty.toString(),
          "AMOUNT": row['amount']?.toString() ?? '0',
          "ITEM_COST": row['item_cost']?.toString() ?? '0',
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
    } catch (e) {
      print('Error occurred while posting dispatch data: $e');
    }
  }

  Future<void> updateDispatch() async {
    print("UpdateDispatch function triggered, table data: $createtableData");

    final IpAddress = await getActiveIpAddress();
    final baseUrl = '$IpAddress/UpdateCreateDispatchRequestView/';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String salesloginno = prefs.getString('salesloginno') ?? '';
      String saveloginname = prefs.getString('saveloginname') ?? '';
      String saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';
      String commersialno = prefs.getString('commersialno') ?? '';
      String commersialname = prefs.getString('commersialname') ?? '';

      String reqno = requestTypeNoController.text.trim();
      String cusname = CustomerNameController.text.trim();
      String cusno = CustomerNoController.text.trim();
      String cussite = CustomersiteidController.text.trim();

      String deliveryaddress = FinalDeliveryAddressController.text.trim();
      String others = FinalRemarksController.text.trim();
      print("Delivery Address $deliveryaddress $others ");
      if (createtableData.isEmpty) {
        showErrorDialog(context, "No table data available.");
        return;
      }

      List<Map<String, dynamic>> validDispatchRows =
          createtableData.where((row) {
        var qtyStr =
            row['dis_qty_total']?.toString()?.toLowerCase()?.trim() ?? '0';
        double qty = double.tryParse(qtyStr) ?? 0;
        return qty > 0;
      }).toList();

      if (validDispatchRows.isEmpty) {
        showErrorDialog(
            context, "The table is empty. Fill in dispatch details.");
        return;
      }

      bool allUpdatesSuccessful = true;

      for (var row in validDispatchRows) {
        String invoiceno = row['getinvoiceNo']?.toString() ?? '';
        String itemCode = row['getitemcode']?.toString() ?? '';
        double dispatchQty =
            double.tryParse(row['dis_qty_total']?.toString() ?? '0') ?? 0.0;
        double balanceQty =
            double.tryParse(row['baldispatched_qty']?.toString() ?? '0') ?? 0.0;

        if (reqno.isEmpty ||
            cusno.isEmpty ||
            cussite.isEmpty ||
            itemCode.isEmpty) {
          print("Skipping row due to missing required parameters.");
          allUpdatesSuccessful = false;
          continue;
        }

        Map<String, dynamic> payload = {
          "reqno": reqno,
          "cusno": cusno,
          "cussite": cussite,
          "invoiceno": invoiceno,
          "itemcode": itemCode,
          "qty": dispatchQty,
          "balanceqty": balanceQty,
          "dispatched_by_manager": dispatchQty,
          "truck_scan_qty": dispatchQty,
          "deliveryaddress": deliveryaddress,
          "others": others,
        };

        print("payload $payload ");
        try {
          final response = await http.post(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          );

          if (response.statusCode == 200) {
            print('Dispatch updated for item: $itemCode');
          } else {
            print(
                'Failed to update item $itemCode. Status: ${response.statusCode}');
            // print('Response body: ${response.body}');
            allUpdatesSuccessful = false;
          }
        } catch (e) {
          print('Error during update for item $itemCode: $e');
          allUpdatesSuccessful = false;
        }
      }

      if (allUpdatesSuccessful) {
        showUpdateSuccessDialog(context);
      }
    } catch (e) {
      print('Unexpected error in updateDispatch: $e');
    }
  }

  // Future<void> updateDispatch() async {
  //   print("UpdateDispatch function triggered  getTableData $createtableData");

  //   final IpAddress = await getActiveIpAddress();
  //   final baseUrl = '$IpAddress/UpdateCreateDispatchRequestView/';

  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String salesloginno = prefs.getString('salesloginno') ?? '';
  //     String saveloginname = prefs.getString('saveloginname') ?? '';
  //     String saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';
  //     String commersialno = prefs.getString('commersialno') ?? '';
  //     String commersialname = prefs.getString('commersialname') ?? '';

  //     DateTime now = DateTime.now();
  //     String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

  //     String reqno = requestTypeNoController.text.trim();
  //     String cusname = CustomerNameController.text.trim();
  //     String cusno = CustomerNoController.text.trim();
  //     String cussite = CustomersiteidController.text.trim();
  //     String warehouse = WarehouseNameController.text.trim();
  //     String orgName = OrganisationNameController.text.trim();
  //     String CustomerTrxLineid = CustomerTrxLineidController.text.trim();
  //     String CustomerTrxid = CustomerTrxidController.text.trim();

  //     if (createtableData.isEmpty) {
  //       print('No data in createtableData to process.');
  //       showErrorDialog(context, "No table data available.");
  //       return;
  //     }

  //     // Filter out rows where DISPATCHED_QTY is invalid (0, 'ds', null, etc.)
  //     List<Map<String, dynamic>> validDispatchRows =
  //         createtableData.where((row) {
  //       var qtyStr =
  //           row['dis_qty_total']?.toString()?.toLowerCase()?.trim() ?? '0';
  //       double qty = double.tryParse(qtyStr) ?? 0;
  //       return qty > 0;
  //     }).toList();

  //     if (validDispatchRows.isEmpty) {
  //       showErrorDialog(
  //           context, "The table database is empty. Kindly fill the details.");
  //       return;
  //     }

  //     bool allUpdatesSuccessful = true;

  //     for (var row in validDispatchRows) {
  //       print('Processing row: $row');

  //       double disreqQty =
  //           double.tryParse(row['dis_qty_total']?.toString() ?? '0') ?? 0.0;
  //       String flagValue = row['flag']?.toString() ?? 'A';
  //       String itemCode = row['itemcode']?.toString() ?? '';
  //       double finaldispathchqty =
  //           (double.tryParse(row['existingdata']?.toString() ?? '0') ?? 0.0) -
  //               (double.tryParse(row['dis_qty_total']?.toString() ?? '0') ??
  //                   0.0);
  //       if (reqno.isEmpty ||
  //           cusno.isEmpty ||
  //           cussite.isEmpty ||
  //           itemCode.isEmpty) {
  //         print("Skipping row due to missing required parameters.");
  //         allUpdatesSuccessful = false;
  //         continue;
  //       }

  //       Map<String, dynamic> updateDispatchData = {
  //         "REQ_ID": reqno,
  //         "PHYSICAL_WAREHOUSE": warehouse,
  //         "ORG_ID": saleslogiOrgid,
  //         "ORG_NAME": orgName,
  //         "SALESMAN_NO": salesloginno,
  //         "SALESMAN_NAME": saveloginname,
  //         "CUSTOMER_NUMBER": cusno,
  //         "CUSTOMER_NAME": cusname,
  //         "CUSTOMER_SITE_ID": cussite,
  //         "INVOICE_DATE": formattedDate,
  //         "INVOICE_NUMBER": row['invoice_number']?.toString() ?? '0',
  //         "LINE_NUMBER": row['line_number']?.toString() ?? '0',
  //         "INVENTORY_ITEM_ID": row['getitemcode']?.toString() ?? '0',
  //         // "CUSTOMER_TRX_ID": CustomerTrxid,
  //         // "CUSTOMER_TRX_LINE_ID": CustomerTrxLineid,
  //         // "ITEM_DESCRIPTION": row['itemdetails']?.toString() ?? '',
  //         "TOT_QUANTITY": row['quantity']?.toString() ?? '0',
  //         "DISPATCHED_QTY": row['dis_qty_total']?.toString() ?? '0',
  //         "BALANCE_QTY": row['baldispatched_qty']?.toString() ?? '0',
  //         "DISPATCHED_BY_MANAGER": row['dis_qty_total']?.toString() ?? '0',
  //         "TRUCK_SCAN_QTY": row['dis_qty_total']?.toString() ?? '0',
  //         "CREATION_DATE": formattedDate,
  //         "CREATED_BY": saveloginname,
  //         "CREATED_IP": 'null',
  //         "CREATED_MAC": 'null',
  //         "LAST_UPDATE_DATE": formattedDate,
  //         "LAST_UPDATED_BY": saveloginname,
  //         "LAST_UPDATE_IP": 'null',
  //         "FLAG": flagValue
  //       };

  //       final url = '$baseUrl/$reqno/$cusno/$cussite/$itemCode/';
  //       print('API URL: $url');

  //       try {
  //         final response = await http.put(
  //           Uri.parse(url),
  //           headers: {'Content-Type': 'application/json'},
  //           body: jsonEncode(updateDispatchData),
  //         );

  //         if (response.statusCode == 200 || response.statusCode == 204) {
  //           print('Dispatch updated successfully for ID: ${row['ID']}');
  //         } else {
  //           print(
  //               'Failed to update dispatch for ID: ${row['ID']}. Status: ${response.statusCode}');
  //           // print('Response body: ${response.body}');
  //           allUpdatesSuccessful = false;
  //         }
  //       } catch (e) {
  //         print('Error during request for ID ${row['ID']}: $e');
  //         allUpdatesSuccessful = false;
  //       }
  //     }

  //     if (allUpdatesSuccessful) {
  //       showUpdateSuccessDialog(context);
  //     }
  //   } catch (e) {
  //     print('Unexpected error in updateDispatch: $e');
  //   }
  // }

// Helper function for showing an error dialog
  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  // Future<void> updateDispatch() async {
  //   print("UpdateDispatch function triggered  getTableData $getTableData");

  //   final IpAddress = await getActiveIpAddress();
  //   final baseUrl = '$IpAddress/UpdateCreateDispatchRequestView';

  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String salesloginno = prefs.getString('salesloginno') ?? '';
  //     String saveloginname = prefs.getString('saveloginname') ?? '';
  //     String saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';
  //     String commersialno = prefs.getString('commersialno') ?? '';
  //     String commersialname = prefs.getString('commersialname') ?? '';

  //     DateTime now = DateTime.now();
  //     String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

  //     String reqno = requestTypeNoController.text.trim();
  //     String cusname = CustomerNameController.text.trim();
  //     String cusno = CustomerNoController.text.trim();
  //     String cussite = CustomersiteidController.text.trim();
  //     String warehouse = WarehouseNameController.text.trim();
  //     String orgName = OrganisationNameController.text.trim();
  //     String CustomerTrxLineid = CustomerTrxLineidController.text.trim();
  //     String CustomerTrxid = CustomerTrxidController.text.trim(); // Corrected

  //     print('Request No: $reqno');
  //     print('Customer Name: $cusname');
  //     print('Customer No: $cusno');
  //     print('Customer Site ID: $cussite');
  //     print('Warehouse: $warehouse');
  //     print('Organisation Name: $orgName');

  //     if (getTableData.isEmpty) {
  //       print('No data in getTableData to process.');
  //       return;
  //     }

  //     bool allUpdatesSuccessful = true;

  //     for (var row in getTableData) {
  //       print('Processing row: $row');

  //       double disreqQty =
  //           double.tryParse(row['DISPATCHED_QTY']?.toString() ?? '0') ?? 0.0;
  //       String flagValue = row['flag']?.toString() ?? 'A';
  //       String itemCode = row['INVENTORY_ITEM_ID']?.toString() ?? '';

  //       Map<String, dynamic> updateDispatchData = {
  //         "REQ_ID": reqno,
  //         "PHYSICAL_WAREHOUSE": warehouse,
  //         "ORG_ID": saleslogiOrgid,
  //         "ORG_NAME": orgName,
  //         // "COMMERCIAL_NO": commersialno,
  //         // "COMMERCIAL_NAME": commersialname,
  //         "SALESMAN_NO": salesloginno,
  //         "SALESMAN_NAME": saveloginname,
  //         "CUSTOMER_NUMBER": cusno,
  //         "CUSTOMER_NAME": cusname,
  //         "CUSTOMER_SITE_ID": cussite,
  //         "INVOICE_DATE": formattedDate,
  //         "INVOICE_NUMBER": row['INVOICE_NUMBER']?.toString() ?? '0',
  //         "LINE_NUMBER": row['LINE_NUMBER']?.toString() ?? '0',
  //         "INVENTORY_ITEM_ID": itemCode,
  //         "CUSTOMER_TRX_ID": CustomerTrxid,
  //         "CUSTOMER_TRX_LINE_ID": CustomerTrxLineid,
  //         "ITEM_DESCRIPTION": row['ITEM_DESCRIPTION']?.toString() ?? '',
  //         "TOT_QUANTITY": row['TOT_QUANTITY']?.toString() ?? '0',
  //         "DISPATCHED_QTY": disreqQty.toString(),
  //         "BALANCE_QTY":
  //             ((int.tryParse(row['TOT_QUANTITY']?.toString() ?? '0') ?? 0) -
  //                     disreqQty.toInt())
  //                 .toString(),
  //         "DISPATCHED_BY_MANAGER": disreqQty.toString(),
  //         "CREATION_DATE": formattedDate,
  //         "CREATED_BY": saveloginname,
  //         "CREATED_IP": 'null',
  //         "CREATED_MAC": 'null',
  //         "LAST_UPDATE_DATE": formattedDate,
  //         "LAST_UPDATED_BY": saveloginname,
  //         "LAST_UPDATE_IP": 'null',
  //         "FLAG": flagValue
  //       };

  //       // Validate URL components
  //       if (reqno.isEmpty ||
  //           cusno.isEmpty ||
  //           cussite.isEmpty ||
  //           itemCode.isEmpty) {
  //         print("Skipping row due to missing required URL parameters.");
  //         allUpdatesSuccessful = false;
  //         continue;
  //       }

  //       final url = '$baseUrl/$reqno/$cusno/$cussite/$itemCode/';
  //       print('API URL: $url');

  //       try {
  //         final response = await http.put(
  //           Uri.parse(url),
  //           headers: {'Content-Type': 'application/json'},
  //           body: jsonEncode(updateDispatchData),
  //         );

  //         if (response.statusCode == 200 || response.statusCode == 204) {
  //           print('Dispatch updated successfully for ID: ${row['ID']}');
  //         } else {
  //           print(
  //               'Failed to update dispatch for ID: ${row['ID']}. Status code: ${response.statusCode}');
  //           print('Response body: ${response.body}');
  //           allUpdatesSuccessful = false;
  //         }
  //       } catch (e) {
  //         print('Error occurred while sending request for ID ${row['ID']}: $e');
  //         allUpdatesSuccessful = false;
  //       }
  //     }

  //     if (allUpdatesSuccessful) {
  //       showUpdateSuccessDialog(context);
  //     }
  //   } catch (e) {
  //     print('Error occurred while updating dispatch data: $e');
  //   }
  // }

  void showUpdateSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 50,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Update Successfully!',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Your changes have been successfully saved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                fetchAccessControl();
                print("access control $accessControl");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainSidebar(
                      initialPageIndex: 2,
                      enabledItems: accessControl,
                    ), // Navigate to MainSidebar
                  ),
                );
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  } // Future<void> postCreateDispatch() async {
  //   final url = '$IpAddress/Create_Dispatch/';

  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String salesloginno = prefs.getString('salesloginno') ?? '';
  //     String saveloginname = prefs.getString('saveloginname') ?? '';

  //     DateTime now = DateTime.now();
  //     String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

  //     String reqno = requestNoController.text.trim();
  //     String warehouse = WarehouseNameController.text.trim();
  //     String org_id = OrganisationIdController.text.trim();
  //     String org_name = OrganisationNameController.text.trim();
  //     String salesman_id = SalesmanIdeController.text.trim();
  //     String salesman_channel = SalesmanChannelController.text.trim();
  //     String cusid = CustomeridController.text.trim();
  //     String cusname = CustomerNameController.text.trim();
  //     String cusno = CustomerNoController.text.trim();
  //     String cussite = CustomersiteidController.text.trim();

  //     // Check for potential data inconsistencies
  //     if (tableData.isEmpty || _controllers.isEmpty) {
  //       print('Table data or controllers are empty.');
  //       return;
  //     }
  //     if (tableData.length != _controllers.length) {
  //       // Regenerate controllers to match tableData length
  //       _controllers = List.generate(
  //         tableData.length,
  //         (index) => TextEditingController(),
  //       );
  //       print('Re-synced _controllers with tableData.');
  //     }

  //     for (int i = 0; i < tableData.length; i++) {
  //       var row = tableData[i];
  //       if (i >= _controllers.length) {
  //         print('Index $i exceeds controllers length.');
  //         continue; // Skip this iteration
  //       }

  //       var disreqQty = double.tryParse(_controllers[i].text) ?? 0.0;
  //       if (disreqQty > 0) {
  //         Map<String, dynamic> createDispatchData = {
  //           "REQ_ID": reqno,
  //           "TO_WAREHOUSE": warehouse,
  //           "ORG_ID": org_id,
  //           "ORG_NAME": org_name,
  //           "SALESREP_ID": salesman_id,
  //           "SALESMAN_NO": salesloginno.isNotEmpty ? salesloginno : 'Unknown',
  //           "SALESMAN_NAME":
  //               saveloginname.isNotEmpty ? saveloginname : 'Unknown',
  //           "SALES_CHANNEL":
  //               salesman_channel.isNotEmpty ? salesman_channel : '0',
  //           "CUSTOMER_ID": cusid,
  //           "CUSTOMER_NUMBER": cusno,
  //           "CUSTOMER_NAME": cusname,
  //           "CUSTOMER_SITE_ID": cussite,
  //           "INVOICE_DATE": formattedDate,
  //           "INVOICE_NUMBER": row['invoiceno']?.toString() ?? '0',
  //           "LINE_NUMBER": row['id']?.toString() ?? '0',
  //           "INVENTORY_ITEM_ID": row['itemcode']?.toString() ?? '0',
  //           "TOT_QUANTITY": row['invoiceqty']?.toString() ?? '0',
  //           "DISPATCHED_QTY": disreqQty.toString(),
  //           "BALANCE_QTY":
  //               (double.tryParse(row['invoiceqty']?.toString() ?? '0')! -
  //                       disreqQty)
  //                   .toString(),
  //           "DISPATCHED_BY_MANAGER": disreqQty.toString(),
  //           "AMOUNT": row['amount']?.toString() ?? '0',
  //           "ITEM_COST": row['item_cost']?.toString() ?? '0',
  //         };

  //         final response = await http.post(
  //           Uri.parse(url),
  //           headers: {
  //             'Content-Type': 'application/json',
  //           },
  //           body: jsonEncode(createDispatchData),
  //         );

  //         if (response.statusCode == 201) {
  //           print(
  //               'Dispatch created successfully for Line Number: ${row['id']?.toString()}');
  //         } else {
  //           print(
  //               'Failed to create dispatch for Line Number: ${row['id']?.toString()}. Status code: ${response.statusCode}');
  //           print('Response body: ${response.body}');
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print('Error occurred while posting dispatch data: $e');
  //   }
  // }

  void _showDialogAndSetQty(
      BuildContext context, int index, double invoiceqty) {
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
                      'You entered more than the Balance invoice quantity. The quantity will be adjusted to $invoiceqty. Do you want to proceed?',
                      style: TextStyle(fontSize: 13, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                // Handle the "Yes" logic here
                Navigator.of(context)
                    .pop(true); // Return true or any other value
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                // Handle the "No" logic here
                Navigator.of(context)
                    .pop(false); // Return false or any other value
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                // Handle "OK" logic (if required)
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void InvoiceAddsuccessMessage() {
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
                'Invoice Product Added !!',
                style: topheadingbold,
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

  void checkinvoice() {
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
                  'Kindly select the invoice.',
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
              ),
            ],
          ),
          actions: [
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
              child: Text('Ok',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  void searchallfeild() {
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
                'Kindly Check all the feild is entered',
                style: TextStyle(fontSize: 13, color: Colors.black),
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

  Future<bool?> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Section: Icon and Title
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 20),
                  const SizedBox(width: 4),
                  const Text(
                    'Confirmed Dispatch',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              // Right Section: Dispatch Controller Value
              Text(
                "${requestNoController.text}", // Replace with your controller
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 68, 67, 67),
                ),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Dispatch Request Sent Successfully !!',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await fetchLastRequestNo();

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: const Size(30.0, 28.0),
              ),
              child: const Text(
                'Ok',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
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
                'Dispatch Request Send Successfully !!',
                style: TextStyle(fontSize: 13, color: Colors.black),
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
}
