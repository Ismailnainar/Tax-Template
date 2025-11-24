import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // For parsing JSON
import 'dart:async';
import 'package:aljeflutterapp/components/constaints.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class CreateDispatch extends StatefulWidget {
  const CreateDispatch({Key? key}) : super(key: key);

  @override
  State<CreateDispatch> createState() => _CreateDispatchState();
}

class _CreateDispatchState extends State<CreateDispatch> {
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
  TextEditingController SalesmanIdeController = TextEditingController();
  TextEditingController SalesmanChannelController = TextEditingController();

  TextEditingController RemarkController = TextEditingController();

  TextEditingController deliveryaddressController = TextEditingController();

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

  FocusNode RemarkFocusNode = FocusNode();
  FocusNode deliveryaddressFocusNode = FocusNode();

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  final ScrollController _horizontalScrollController2 = ScrollController();
  final ScrollController _verticalScrollController2 = ScrollController();
  @override
  void initState() {
    super.initState();
    // _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
    //   fetchLastRequestNo(); // Fetch serial number every 10 sec
    // });
    _loadSalesmanName();
    fetchRegionAndWarehouse();
    fetchWarehouseDetails();
    fetchCustomerNumbers();
    fetchLastRequestNo();
    // Initialize controllers and focus nodes for each rows
    createtableData.forEach((row) {
      _controllers.add(TextEditingController(text: "0"));
      _focusNodes.add(FocusNode());
    });

    // Initialize total amount controller with initial value
    totalamountcontroller.text = "0";

    postLogData("Create Dispatch", "Opened");
  }

  bool getreqno = false;

  Future<void> fetchLastRequestNo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno');

    final IpAddress = await getActiveIpAddress();
    final url = '$IpAddress/Create_DispatchReqno/';
    getreqno = true;
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String lastReqNo = data['REQ_ID']?.toString() ?? '';

        if (lastReqNo.isNotEmpty) {
          // Match format like IC25050001
          RegExp regExp = RegExp(r'^([A-Z]{2})(\d{2})(\d{2})(\d+)$');
          Match? match = regExp.firstMatch(lastReqNo);

          if (match != null) {
            String prefix = match.group(1)!; // IC
            String year = match.group(2)!; // 25
            String month = match.group(3)!; // 05
            int lastNumber = int.parse(match.group(4)!); // 0001 → 1
            int newNumber = lastNumber + 1;

            // Pad number to same length as original
            int numberLength = match.group(4)!.length;
            String newNumberStr =
                newNumber.toString().padLeft(numberLength, '0');

            String newReqNo =
                '$prefix$year$month$newNumberStr'; // e.g., IC25050002
            requestNoController.text = newReqNo;
          } else {
            requestNoController.text =
                lastReqNo; // fallback if format doesn't match
          }
        } else {
          // fallback default
          final now = DateTime.now();
          String fallback =
              "IC${now.year % 100}${now.month.toString().padLeft(2, '0')}0001";
          requestNoController.text = fallback;
        }
      } else {
        // Handle non-200 response
        requestNoController.text = "REQNO_ERR";
      }
    } catch (e) {
      // Handle any exception
      requestNoController.text = "REQNO_ERR";
    } finally {
      setState(() {
        _isLoading = false;
        getreqno = false;
      });
    }
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget _buildTextFieldDesktop(String label, String value, IconData icon,
      bool readonly, FocusNode fromfocusnode, FocusNode tofocusnode) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        width: Responsive.isDesktop(context)
            ? screenWidth * 0.13
            : screenWidth * 0.4,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 0), // Consistent vertical spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Icon(icon, size: 14, color: Colors.blue[600]),
                    SizedBox(width: 8),
                    Text(label, style: textboxheading),
                  ],
                ),
              ),
              const SizedBox(height: 8), // Space between label and text field
              Container(
                height: 33,
                width: double.infinity, // Full width for the container
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Tooltip(
                    message: value,
                    child: TextFormField(
                      focusNode: fromfocusnode,
                      readOnly: readonly,
                      onFieldSubmitted: (_) => _fieldFocusChange(
                          context, fromfocusnode, tofocusnode),
                      decoration: InputDecoration(
                        // hintText: label,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        filled: true,
                        fillColor: readonly
                            ? Color.fromARGB(255, 240, 240, 240)
                            : Color.fromARGB(255, 255, 255, 255),
                      ),
                      controller: TextEditingController(text: value),
                      style: textBoxstyle,
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

  List<Map<String, dynamic>> tableData = [];

  Widget _buildTable() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    List<Map<String, dynamic>> sortedTableData = List.from(tableData);
    sortedTableData.sort((a, b) =>
        int.parse(a['id'].toString()).compareTo(int.parse(b['id'].toString())));

    final headers = [
      {'icon': Icons.receipt, 'label': 'Invoice No'},
      {'icon': Icons.list_alt, 'label': 'I.L.No'},
      {'icon': Icons.code, 'label': 'Item Code'},
      {'icon': Icons.description, 'label': 'Item Description'},
      {'icon': Icons.check_circle, 'label': 'Qty.Inv'},
      {'icon': Icons.assignment, 'label': 'Dis.Req.Qty'},
      {'icon': Icons.equalizer, 'label': 'Qty.Bal'},
      // {'icon': Icons.local_shipping, 'label': 'Qty.Dispatched'},
    ];

    Map<String, double> columnWidths = {
      'invoiceno': 0.10, // 10% for Invoice No
      'id': 0.06, // 5% for Line No
      'itemcode': 0.10, // 10% for Item Code
      'itemdetails': 0.35, // 35% for Item Description
      'invoiceqty': 0.06, // 6% for quantities
      'disreqqty': 0.08, // 6% for quantities
      'balanceqty': 0.06, // 6% for quantities
      // 'dispatchqty': 0.10, // 6% for quantities
    };

    Map<String, double> mobileColumnWidths = {
      'invoiceno': 0.30, // Wider for mobile
      'id': 0.30, // Slightly wider for mobile
      'itemcode': 0.30,
      'itemdetails': 0.40, // Slightly smaller for mobile
      'invoiceqty': 0.30,
      'disreqqty': 0.30,
      'balanceqty': 0.30,
      // 'dispatchqty': 0.30,
    };

    // Use different widths based on screen size
    Map<String, double> activeColumnWidths =
        Responsive.isDesktop(context) ? columnWidths : mobileColumnWidths;

    Widget _buildHeaderCell(IconData? icon, String? label) {
      // Get width based on label
      double width;
      TextAlign alignment;

      switch (label) {
        case 'I.L.No':
          width = MediaQuery.of(context).size.width * activeColumnWidths['id']!;
          alignment = TextAlign.center;
          break;
        case 'Invoice No':
          width = MediaQuery.of(context).size.width *
              activeColumnWidths['invoiceno']!;
          alignment = TextAlign.left;
          break;
        case 'Item Code':
          width = MediaQuery.of(context).size.width *
              activeColumnWidths['itemcode']!;
          alignment = TextAlign.left;
          break;
        case 'Qty.Inv':
          width = MediaQuery.of(context).size.width *
              activeColumnWidths['invoiceqty']!;
          alignment = TextAlign.right;
          break;
        case 'Dis.Req.Qty':
          width = MediaQuery.of(context).size.width *
              activeColumnWidths['disreqqty']!;
          alignment = TextAlign.right;
          break;
        case 'Qty.Bal':
          width = MediaQuery.of(context).size.width *
              activeColumnWidths['balanceqty']!;
          alignment = TextAlign.right;
          break;
        // case 'Qty.Dispatched':
        //   width = MediaQuery.of(context).size.width *
        //       activeColumnWidths['dispatchqty']!;
        //   alignment = TextAlign.right;
        //   break;
        default:
          width = MediaQuery.of(context).size.width * 0.10;
          alignment = TextAlign.left;
      }

      return Container(
        height: Responsive.isDesktop(context) ? 25 : 30,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: alignment == TextAlign.center
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              if (icon != null) Icon(icon, size: 15, color: Colors.blue),
              SizedBox(width: 5),
              if (label != null)
                Expanded(
                  child: Text(
                    label,
                    textAlign: alignment,
                    style: commonLabelTextStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    Widget _buildDataCell(String value, bool isEvenRow, String key) {
      double width =
          MediaQuery.of(context).size.width * activeColumnWidths[key]!;

      switch (key) {
        case 'id':
          break;
        case 'invoiceno':
        case 'itemcode':
        case 'itemdetails':
          break;
        case 'invoiceqty':
        case 'disreqqty':
        case 'balanceqty':
          // case 'dispatchqty':
          break;
        default:
      }

      return Container(
        height: 30,
        width: width,
        decoration: BoxDecoration(
          color: isEvenRow ? Color(0xFFE0FFFFFF) : Color(0xFFFFFFFF),
          border: Border.all(color: Color(0xFFE2E1E1)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SelectableText(
            value,
            textAlign: TextAlign.left,
            style: commonLabelTextStyle,
            showCursor: false,
            cursorColor: Colors.blue,
            cursorWidth: 2.0,
            toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
          ),
        ),
      );
    }

    Widget _buildDataRow(Map<String, dynamic> data) {
      final List<String> keys = [
        // 'undel_id',
        'invoiceno',
        'id',
        'itemcode',
        'itemdetails',
        'invoiceqty',
        'disreqqty',
        'balanceqty',
        // 'dispatchqty',
      ];

      return GestureDetector(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: keys.map((key) {
              String value = _removeDecimalIfWhole(data[key]);

              if (key == 'itemdetails') {
                return _buildItemDescriptionCell(
                    value, tableData.indexOf(data) % 2 == 0);
              } else {
                return _buildDataCell(
                    value, tableData.indexOf(data) % 2 == 0, key);
              }
            }).toList(),
          ),
        ),
      );
    }

    return Container(
      width: screenWidth,
      child: Stack(
        // Wrap with Stack to allow Positioned widget
        children: [
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
                      height: Responsive.isDesktop(context)
                          ? screenHeight * 0.4
                          : 400,
                      width: Responsive.isDesktop(context)
                          ? screenWidth * 0.85
                          : MediaQuery.of(context).size.width * 3,
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
                                return label == 'Item Description'
                                    ? _buildItemDescHeaderCell(icon, label)
                                    : _buildHeaderCell(icon, label);
                              }).toList(),
                            ),
                          ),
                          if (_isLoading)
                            Padding(
                              padding: const EdgeInsets.only(top: 100.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (tableData.isNotEmpty)
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: tableData.map((data) {
                                    var index = tableData.indexOf(data);
                                    return _buildDataRow(data);
                                  }).toList(),
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(top: 100.0),
                              child: Text("Dispatch Not Created.."),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Add scroll arrows with click handlers
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
        ],
      ),
    );
  }

// You might also want to update the _buildDataRow to handle specific columns

// Update _buildHeaderCell
  Widget _buildItemDescHeaderCell(IconData? icon, String? label) {
    return Container(
      height: Responsive.isDesktop(context) ? 25 : 30,
      width: MediaQuery.of(context).size.width * 0.37,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            if (icon != null) Icon(icon, size: 15, color: Colors.blue),
            SizedBox(width: 5),
            if (label != null)
              Expanded(
                child: Text(
                  label,
                  style: commonLabelTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Update _buildDataCell
  Widget _buildItemDescriptionCell(String value, bool isEvenRow) {
    return Container(
      height: 30,
      width: MediaQuery.of(context).size.width * 0.37,
      decoration: BoxDecoration(
        color: isEvenRow ? Color(0xFFE0FFFFFF) : Color(0xFFFFFFFF),
        border: Border.all(color: Color(0xFFE2E1E1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(
              child: SelectableText(
                value,
                textAlign: TextAlign.left,
                style: commonLabelTextStyle,
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

  String _removeDecimalIfWhole(dynamic value) {
    if (value == null) return '';

    if (value is num) {
      // Check if the value is a whole number
      if (value == value.truncateToDouble()) {
        return value.toInt().toString(); // Convert to int and then string
      }
      return value.toString();
    }

    // Try parsing as double if it's a string
    if (value is String) {
      try {
        double? number = double.tryParse(value);
        if (number != null && number == number.truncateToDouble()) {
          return number.toInt().toString();
        }
      } catch (e) {
        // If parsing fails, return original string
      }
    }

    return value.toString();
  }

  TextEditingController NoofitemController = TextEditingController(text: "0");
  TextEditingController totaldisreqController =
      TextEditingController(text: '0');
  void _updatecount() {
    // Use the getTotalFinalAmt function to update the total amount
    NoofitemController.text = getcount(tableData).toStringAsFixed(0);
    print("NoofitemController amountttt ${NoofitemController.text}");
  }

  int getcount(List<Map<String, dynamic>> tableData) {
    return tableData.length;
  }

  void _updatedisreqamt() {
    // Use the getTotalFinalAmt function to update the total amount
    double totalAmount = gettotaldisreqamt(tableData); // Get the total amount
    totaldisreqController.text = _removeDecimalIfWhole(
        totalAmount.toString()); // Update controller with formatted amount

    print("totaldisreqController amountttt ${totaldisreqController.text}");
  }

  double gettotaldisreqamt(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['disreqqty'] ?? '0') ?? 0.0;
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

    final String initialUrl = '$IpAddress/CustomerNamelist/$salesloginno/';
    String? nextPageUrl = initialUrl;
    print("salesno : $initialUrl");
    setState(() {
      isomvoiceLoading = true;
      // Show processing dialog
      _showProcessingDialog();
    });

    try {
      List<String> tempCustomerDetails = [];

      while (nextPageUrl != null) {
        var response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
          final data = json.decode(decodedBody);
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
    } finally {
      // Hide the progress indicator
      setState(() {
        isomvoiceLoading = false;
      });

      // Close the processing dialog
      Navigator.pop(context);
    }
  }

  Future<void> fetchCustomerDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno');
    String? saleslogiOrgid = prefs.getString('saleslogiOrgid');

    final IpAddress = await getActiveIpAddress();

    String baseUrl = '$IpAddress/CustomerNamelist/$salesloginno/';
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
          final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
          final data = json.decode(decodedBody);
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
              print('Customer Name: ${CustomerNameController.text}');
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
    String? salesloginno = prefs.getString('salesloginno');
    String customerno = CustomerNoController.text;

    final IpAddress = await getActiveIpAddress();
    final String initialUrl =
        '$IpAddress/CustomerSiteIDList/$salesloginno/$customerno/';
    String? nextPageUrl = initialUrl;

    print("CustomerSite URL: $initialUrl");

    setState(() {
      isomvoiceLoading = true;
      _showProcessingDialog(); // Show loading dialog
    });

    try {
      List<String> tempCustomerDetails = [];

      while (nextPageUrl != null) {
        final response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['results'] != null && data['results'] is List) {
            for (var result in data['results']) {
              String? siteUseId = result['site_use_id']?.toString();
              String? partySiteName = result['party_site_name']?.toString();

              // Use "No site name available" if null or empty
              String displayName =
                  (partySiteName == null || partySiteName.trim().isEmpty)
                      ? "No site name available"
                      : partySiteName;

              if (siteUseId != null && siteUseId.isNotEmpty) {
                tempCustomerDetails.add('$siteUseId :$displayName');
              }
            }
          }

          nextPageUrl = data['next']?.toString();
        } else {
          print('Error: ${response.statusCode}');
          break;
        }
      }

      setState(() {
        CustomeSiteList = tempCustomerDetails;
        isLoading = false;
        print("CustomeSiteList: $CustomeSiteList");
      });
    } catch (e) {
      print('Error fetching customer site numbers: $e');
      setState(() {
        isLoading = false;
      });
    } finally {
      setState(() {
        isomvoiceLoading = false;
      });
      Navigator.pop(context); // Close loading dialog
    }
  }

  TextEditingController TotalInvoiveCountController = TextEditingController();
  List<String> InvoiceNoList = [];
  bool isomvoiceLoading = false; // Tracks whether the data is being loaded

  Future<void> fetchInvoiceNumbers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno');

    String? commersialrolessss = prefs.getString('commersialrole');
    String customerNumber = CustomerNoController.text;
    String customersite = CustomersiteidController.text;

    final IpAddress = await getActiveIpAddress();

    final String initialUrl =
        '$IpAddress/invoice/$salesloginno/$customerNumber/$customersite/';
    String? nextPageUrl = initialUrl;
    print('initialUrlinitialUrlinitialUrlinitialUrl: ${initialUrl} }');
    setState(() {
      isomvoiceLoading = true; // Show progress indicator
      // Show processing dialog
      _showProcessingDialog();
    });

    try {
      List<String> tempInvoiceNumbers = [];

      while (nextPageUrl != null) {
        final response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // if (data['results'] != null && data['results'].isNotEmpty) {
          //   for (var result in data['results']) {
          //     if (commersialrolessss != "Retail Sales Supervisor") {
          //       if (result['invoice_number'] != null) {
          //         tempInvoiceNumbers.add(result['invoice_number']);
          //       }
          //     } else {
          //       if (result['invoice_number'] != null &&
          //           result['rp_invoice_no'] != null) {
          //         String formattedInvoice =
          //             '${result['rp_invoice_no']} - ${result['invoice_number']}';
          //         tempInvoiceNumbers.add(formattedInvoice);
          //       }
          //     }
          //   }
          // }

          if (data['results'] != null && data['results'].isNotEmpty) {
            for (var result in data['results']) {
              if (commersialrolessss != "Retail Sales Supervisor") {
                if (result['invoice_number'] != null) {
                  tempInvoiceNumbers.add(result['invoice_number']);
                }
              } else {
                if (result['invoice_number'] != null) {
                  String rpInvoiceNo =
                      result['rp_invoice_no']?.toString() ?? '';
                  String displayRpInvoice =
                      rpInvoiceNo.trim().isNotEmpty ? rpInvoiceNo : "No RP inv";
                  String formattedInvoice =
                      '$displayRpInvoice - ${result['invoice_number'].toString()}';
                  tempInvoiceNumbers.add(formattedInvoice);
                }
              }
            }
          }

          nextPageUrl = data['next'];
        } else {
          print('Error: ${response.statusCode} - ${response.body}');
          break;
        }
      }

      setState(() {
        InvoiceNoList = tempInvoiceNumbers;
        print("InvoiceNoList $InvoiceNoList");
        TotalInvoiveCountController.text = InvoiceNoList.length.toString();
      });
    } catch (e) {
      print('Error fetching invoice numbers: $e');
    } finally {
      // Hide the progress indicator
      setState(() {
        isomvoiceLoading = false;
      });

      // Close the processing dialog
      Navigator.pop(context);
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
                      height: 33,
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
              borderRadius: BorderRadius.zero,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            filled: true,
            fillColor: Colors.white,
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
                  child: Text(suggestion, style: TextStyle(fontSize: 13)),
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

    RP_bool = false;
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
                          // fetchInvoiceNumbers();
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
        // fetchInvoiceNumbers();

        CustomersiteidController.clear();
        InvoiceNoController.clear();
        CustomeSiteList = [];
        InvoiceNoList = [];

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
                      height: 33,
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
                RP_bool = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: CustomerSiteFocusNode,
          controller: CustomersiteidController,
          onSubmitted: (String? suggestion) async {
            InvoiceNoController.clear();
            await fetchInvoiceNumbers();
            tableData = [];

            if (InvoiceNoList.isEmpty) {
              invoiceavailabilitycheck();
            } else {
              // invoictotalcount();
              totalinvoicecountbool = true;
            }
            RP_bool = false;
            _fieldFocusChange(context, CustomerSiteFocusNode, InvoiceFocusNode);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            filled: true,
            fillColor: Colors.white,
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
            tableData = [];

            InvoiceNoList = [];
          });

          await fetchInvoiceNumbers();
          RP_bool = false;
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

  bool RP_bool = false;

  Future<void> fetchRPinvoicedetails() async {
    RP_bool = false;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? salesloginno = prefs.getString('salesloginno');
      String? commersialrolessss = prefs.getString('commersialrole');

      String customerNumber = CustomerNoController.text.trim();
      String customersite = CustomersiteidController.text.trim();
      String invoiceno = InvoiceNoController.text.trim();

      final IpAddress = await getActiveIpAddress();
      final String url =
          '$IpAddress/invoice/$salesloginno/$customerNumber/$customersite/';
      print("urllllllllllllllll $url");
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Decode response body using UTF-8 to support Arabic and other languages
        final data = json.decode(utf8.decode(response.bodyBytes));

        if (data['results'] != null && data['results'].isNotEmpty) {
          for (var result in data['results']) {
            if (result['invoice_number'] == invoiceno) {
              RP_InvoiceNoController.text =
                  result['rp_invoice_no']?.toString() ?? '';
              RP_CustomernameController.text =
                  result['rp_customer_name']?.toString() ?? '';
              RP_mobilenoController.text =
                  result['rp_mobile_no']?.toString() ?? '';

              print('RP_InvoiceNoController: ${RP_InvoiceNoController.text}');
              print(
                  'RP_CustomernameController: ${RP_CustomernameController.text}');
              print('RP_mobilenoController: ${RP_mobilenoController.text}');

              setState(() {
                if (RP_InvoiceNoController.text.isNotEmpty &&
                    RP_CustomernameController.text.isNotEmpty &&
                    RP_mobilenoController.text.isNotEmpty) RP_bool = true;
              });
              print("RP_bool $RP_bool");
              break;
            }
          }
        } else {
          print("No results found.");
        }
      } else {
        print(
            'Failed to load invoice data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching invoice numbers: $e');
    }
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

  TextEditingController RP_InvoiceNoController = TextEditingController();
  TextEditingController RP_mobilenoController = TextEditingController();
  TextEditingController RP_CustomernameController = TextEditingController();

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
                        ? screenWidth * 0.13
                        : screenWidth * 0.43,
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
            int currentIndex = sortedInvoiceNoList
                .indexWhere((item) => item.contains(InvoiceNoController.text));
            if (currentIndex < sortedInvoiceNoList.length - 1) {
              setState(() {
                _selectedIndex = currentIndex + 1;
                InvoiceNoController.text = sortedInvoiceNoList[currentIndex + 1]
                    .split('-')
                    .last
                    .trim();
                _filterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = sortedInvoiceNoList
                .indexWhere((item) => item.contains(InvoiceNoController.text));
            if (currentIndex > 0) {
              setState(() {
                _selectedIndex = currentIndex - 1;
                InvoiceNoController.text = sortedInvoiceNoList[currentIndex - 1]
                    .split('-')
                    .last
                    .trim();
                _filterEnabled = false;
              });

              fetchRPinvoicedetails();
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: InvoiceFocusNode,
          controller: InvoiceNoController,
          decoration: InputDecoration(
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 15,
            ),
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
              _filterEnabled = true;
              selectedValue = text.isEmpty ? null : text;
            });

            fetchRPinvoicedetails();
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
            // Only set text as the part after the hyphen
            InvoiceNoController.text = suggestion.split('-').last.trim();
            selectedValue = suggestion;
            _filterEnabled = false;
          });
          fetchRPinvoicedetails();
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

  String? saveloginOrgId = '';

  String? commersialrole = '';

  String? commersialname = '';

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
      saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
      saveloginOrgId = prefs.getString('saleslogiOrgid') ?? 'Unknown Salesman';
      commersialrole =
          prefs.getString('commersialrole') ?? 'Unknown commersialrole';
      commersialname =
          prefs.getString('commersialname') ?? 'Unknown commersialname';

      print("commersialrole commersialrole $commersialrole");
    });
  }

  final TextEditingController regionController = TextEditingController();
  final TextEditingController warehouseController = TextEditingController();

  Future<void> fetchRegionAndWarehouse() async {
    await _loadSalesmanName();

    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/Physical_Warehouse/';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Find the entry for the given ORGANIZATION_ID
        final result = data['results'].firstWhere(
          (item) => item['ORGANIZATION_ID'] == saveloginOrgId,
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
          print('No data found for ORGANIZATION_ID: $saveloginOrgId');
        }
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
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
                // warehouseController.text =
                //     _warehouseName ?? ''; // Handle potential null

                // OrganisationIdController.text =
                //     _OrganisationId ?? ''; // Handle potential null

                // OrganisationNameController.text =
                //     _OrganisationName ?? ''; // Handle potential null

                SalesmanIdeController.text = _Salesmanid ?? '';
                SalesmanChannelController.text = _Salesmanchannel ?? '';
              });
              break; // Exit the loop after getting the first warehouse name
            } else {
              // Handle case where to_warehouse is not a string
              setState(() {
                _warehouseName = 'Invalid warehouse data';
              });
            }
          }
        } else {
          // No results found
          setState(() {
            _warehouseName = 'No warehouse details available';
          });
        }

        // Move to the next page if available
        apiUrl = data['next'];
      } else {
        // Handle error
        setState(() {
          _warehouseName = 'Error fetching data';
        });
        return;
      }
    }
  }

  bool _isProcessing = false; // Flag to track if the operation is ongoing

  Future<void> handlePreviousButtonClick() async {
// Prevent multiple clicks
    if (_isProcessing) return;

    // Show the processing dialog

    if (InvoiceNoController.text.isNotEmpty) {
      setState(() {
        _isProcessing = true; // Set the processing flag to true
        _showProcessingDialog();
      });

      try {
        // Fetch invoice details before showing the dialog
        await fetchInvoiceDetails();
        await fetchData();
        if (context.mounted) {
          isChecked = false;

          // Close the processing dialog
          Navigator.pop(context);

          // Show the invoice details dialog
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return _PreviewInvoiceNoDetailsDialog(
                context,
                "${_totalController.text}",
                '${InvoiceNoController.text}',
              );
            },
          );
        }

        postLogData(
            "Create Dispatch Invoice Pop-up (Preview Button)", "Opened");
      } catch (e) {
        // Handle errors gracefully
        print('Error occurred while fetching invoice details: $e');
      } finally {
        // Reset the processing flag
        if (mounted) {
          setState(() {
            _isProcessing = false;
            totalamountcontroller.text = '0'; // Reset total amount field
          });
        }
      }
    } else {
      checkinvoice(
          'Kindly select the invoice.'); // Handle the case when the invoice number is empty
    }
  }

  Future<void> handleGoButtonClick() async {
    // Prevent multiple clicks
    if (_isProcessing) return;
    // -----------------------------------------------
    // 1. CHECK IF INVOICE ALREADY EXISTS IN tableData
    // -----------------------------------------------
    String invoiceNo = InvoiceNoController.text.trim();
    bool invoiceExists = tableData.any(
      (row) =>
          row['invoiceno'].toString().trim().toLowerCase() ==
          invoiceNo.toLowerCase(),
    );

    if (invoiceExists) {
      // Show ERROR MESSAGE BOX (already added)

      checkinvoice(
          'Invoice No $invoiceNo is already in the Below list.'); // Handle the case when the invoice number is empty

      return; // STOP PROCESSING
    }

    // Show the processing dialog

    if (InvoiceNoController.text.isNotEmpty) {
      setState(() {
        _isProcessing = true; // Set the processing flag to true
        _showProcessingDialog();
      });

      try {
        // Fetch invoice details before showing the dialog
        await fetchInvoiceDetails();

        if (context.mounted) {
          isChecked = false;

          // Close the processing dialog
          Navigator.pop(context);

          // Show the invoice details dialog
          await showDialog(
            context: context,
            barrierDismissible: false, // Prevent dismiss by tapping outside
            builder: (BuildContext context) {
              return _InvoiceNoDetailsDialog(
                context,
                "${_totalController.text}",
                '${InvoiceNoController.text}',
              );
            },
          );
        }

        postLogData("Create Dispatch Invoice Pop-up (Go Button)", "Opened");
      } catch (e) {
        // Handle errors gracefully
        print('Error occurred while fetching invoice details: $e');
      } finally {
        // Reset the processing flag
        if (mounted) {
          setState(() {
            _isProcessing = false;
            totalamountcontroller.text = '0'; // Reset total amount field
          });
        }
      }
    } else {
      checkinvoice(
          'Kindly select the invoice.'); // Handle the case when the invoice number is empty
    }
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

  DateTime selectedDate = DateTime.now();
  TextEditingController _FromdateController = TextEditingController(
      text: DateFormat('dd-MMM-yyyy').format(DateTime.now()));

  // Future<void> _selectfromDate(BuildContext context) async {
  //   // Show DatePicker Dialog
  //   DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: selectedDate, // Initial date
  //     firstDate: DateTime(2000), // Earliest possible date
  //     lastDate: DateTime(2101), // Latest possible date
  //   );

  //   if (pickedDate != null && pickedDate != selectedDate) {
  //     // Format the selected date as 'dd-MMM-yyyy'
  //     String formattedDate = DateFormat('dd-MMM-yyyy').format(pickedDate);
  //     setState(() {
  //       _FromdateController.text =
  //           formattedDate; // Set the formatted date to the controller
  //     });
  //   }
  // }

  Future<void> _selectfromDate(BuildContext context) async {
    // Show DatePicker Dialog with only today and future dates allowed
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(), // Disallow past dates
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      String formattedDate = DateFormat('dd-MMM-yyyy').format(pickedDate);
      setState(() {
        selectedDate = pickedDate;
        _FromdateController.text = formattedDate;
      });
    }
  }

  bool _isSecondRowVisible = false;
  int currentLength = 0;

  Widget _buildLabelText(String text) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Color.fromARGB(255, 20, 47, 61),
        ),
      );

  Widget _buildValueText(String text) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.blueGrey,
        ),
      );

  bool proceed = false;
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    // Format it to DD/MM/YYYY
    String formattedDate = DateFormat('dd-MMM-yyyy').format(now);

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
                                  Icons.local_shipping_outlined,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Create Dispatch',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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

                                if (commersialrole == "Sales Supervisor" ||
                                    commersialrole == "Retail Sales Supervisor")
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
                                  // _buildTextFieldDesktop(
                                  //     'Req No',
                                  //     "${requestNoController.text}",
                                  //     Icons.numbers,
                                  //     true,
                                  //     requestnoFocusnode,
                                  //     WarehouseFocusnode),
                                  // SizedBox(
                                  //   width: 10,
                                  // ),
                                  _buildTextFieldDesktop(
                                      'Physical Warehouse',
                                      warehouseController.text,
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
                                      Icons.date_range,
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
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 12.0),
                                            child: Row(
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.list,
                                                        size: 14,
                                                        color:
                                                            Colors.blue[600]),
                                                    SizedBox(width: 8),
                                                    Text("Customer No ",
                                                        style: textboxheading),
                                                    SizedBox(width: 8),
                                                  ],
                                                ),
                                                Icon(
                                                  Icons.star,
                                                  size: 8,
                                                  color: Colors.red,
                                                )
                                              ],
                                            ),
                                          ),
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
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Icon(Icons.local_activity,
                                                  size: 14,
                                                  color: Colors.blue[600]),
                                              SizedBox(width: 8),
                                              Text("Customer Site ",
                                                  style: textboxheading),
                                              Icon(
                                                Icons.star,
                                                size: 8,
                                                color: Colors.red,
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 1),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0, bottom: 0),
                                            child: Container(
                                                child:
                                                    _buildCustomerSiteDropdown()),
                                          ),
                                          if (totalinvoicecountbool == true)
                                            Text(
                                              'Pending Invoice ${TotalInvoiveCountController.text} ',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 23, 122, 5)),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),

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
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_month,
                                                  size: 14,
                                                  color: Colors.blue[600]),
                                              SizedBox(width: 8),
                                              Text("Delivery Date",
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
                                                  height: 33,
                                                  // width: Responsive.isDesktop(context)
                                                  //     ? screenWidth * 0.086
                                                  //     : 130,

                                                  width: Responsive.isDesktop(
                                                          context)
                                                      ? screenWidth * 0.13
                                                      : screenWidth * 0.4,
                                                  child: Container(
                                                    width: Responsive.isDesktop(
                                                            context)
                                                        ? 180
                                                        : 130,
                                                    height: 33,
                                                    child: TextField(
                                                      controller:
                                                          _FromdateController,
                                                      readOnly: true,
                                                      onTap: () => _selectfromDate(
                                                          context), // Open the date picker when tapped
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            'Delivery Date',
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
                                                      style:
                                                          commonLabelTextStyle,
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
                                                            deliveryaddressFocusNode,
                                                        onFieldSubmitted: (_) =>
                                                            _fieldFocusChange(
                                                                context,
                                                                deliveryaddressFocusNode,
                                                                InvoiceFocusNode),
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
                                                            deliveryaddressController,
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

                                  // Container(
                                  //   width: Responsive.isDesktop(context)
                                  //       ? screenWidth * 0.27
                                  //       : screenWidth * 0.4,
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.only(left: 0),
                                  //     child: Column(
                                  //       crossAxisAlignment:
                                  //           CrossAxisAlignment.start,
                                  //       children: [
                                  //         const SizedBox(height: 20),
                                  //         Row(
                                  //           children: [
                                  //             Text('Delivery Address',
                                  //                 style: textboxheading),
                                  //           ],
                                  //         ),
                                  //         const SizedBox(height: 6),
                                  //         Padding(
                                  //           padding: const EdgeInsets.only(
                                  //               left: 0, bottom: 0),
                                  //           child: Row(
                                  //             children: [
                                  //               Container(
                                  //                   height: 32,
                                  //                   // width: Responsive.isDesktop(context)
                                  //                   //     ? screenWidth * 0.086
                                  //                   //     : 130,

                                  //                   width: Responsive.isDesktop(
                                  //                           context)
                                  //                       ? screenWidth * 0.27
                                  //                       : screenWidth * 0.4,
                                  //                   child: MouseRegion(
                                  //                       onEnter: (event) {
                                  //                         // You can perform any action when mouse enters, like logging the value.
                                  //                       },
                                  //                       onExit: (event) {
                                  //                         // Perform any action when the mouse leaves the TextField area.
                                  //                       },
                                  //                       cursor: SystemMouseCursors
                                  //                           .click, // Changes the cursor to indicate interaction
                                  //                       child: Column(
                                  //                         crossAxisAlignment:
                                  //                             CrossAxisAlignment
                                  //                                 .start,
                                  //                         children: [
                                  //                           TextFormField(
                                  //                             focusNode:
                                  //                                 deliveryaddressFocusNode,
                                  //                             onFieldSubmitted: (_) =>
                                  //                                 _fieldFocusChange(
                                  //                                     context,
                                  //                                     deliveryaddressFocusNode,
                                  //                                     InvoiceFocusNode),
                                  //                             maxLength:
                                  //                                 250, // Limits input to 250 characters
                                  //                             decoration:
                                  //                                 InputDecoration(
                                  //                               enabledBorder:
                                  //                                   OutlineInputBorder(
                                  //                                 borderSide:
                                  //                                     BorderSide(
                                  //                                   color: Color
                                  //                                       .fromARGB(
                                  //                                           201,
                                  //                                           132,
                                  //                                           132,
                                  //                                           132),
                                  //                                   width: 1.0,
                                  //                                 ),
                                  //                               ),
                                  //                               focusedBorder:
                                  //                                   OutlineInputBorder(
                                  //                                 borderSide:
                                  //                                     BorderSide(
                                  //                                   color: Color
                                  //                                       .fromARGB(
                                  //                                           255,
                                  //                                           58,
                                  //                                           58,
                                  //                                           58),
                                  //                                   width: 1.0,
                                  //                                 ),
                                  //                               ),
                                  //                               contentPadding:
                                  //                                   const EdgeInsets
                                  //                                       .symmetric(
                                  //                                 vertical: 5.0,
                                  //                                 horizontal:
                                  //                                     10.0,
                                  //                               ),
                                  //                               counterText:
                                  //                                   '', // Hides the default counter text
                                  //                             ),
                                  //                             controller:
                                  //                                 deliveryaddressController,
                                  //                             style: TextStyle(
                                  //                               color: Color
                                  //                                   .fromARGB(
                                  //                                       255,
                                  //                                       73,
                                  //                                       72,
                                  //                                       72),
                                  //                               fontSize: 15,
                                  //                             ),
                                  //                             onChanged:
                                  //                                 (value) {
                                  //                               setState(() {
                                  //                                 currentLength =
                                  //                                     value
                                  //                                         .length;
                                  //                               });
                                  //                             },
                                  //                           ),
                                  //                           Padding(
                                  //                             padding:
                                  //                                 const EdgeInsets
                                  //                                     .only(
                                  //                                     top: 5.0),
                                  //                             child: Text(
                                  //                               '$currentLength/250',
                                  //                               style:
                                  //                                   TextStyle(
                                  //                                 fontSize: 12,
                                  //                                 color: Colors
                                  //                                     .grey,
                                  //                               ),
                                  //                             ),
                                  //                           ),
                                  //                         ],
                                  //                       ))),
                                  //             ],
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
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
                                                            RemarkFocusNode,
                                                        onFieldSubmitted: (_) =>
                                                            _fieldFocusChange(
                                                                context,
                                                                RemarkFocusNode,
                                                                deliveryaddressFocusNode),

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
                                                            RemarkController,
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
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 0,
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
                                        ? MediaQuery.of(context).size.width
                                        : MediaQuery.of(context).size.width *
                                            1.1,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: Responsive.isDesktop(context)
                                              ? 15
                                              : 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.receipt_long,
                                                  size: 14,
                                                  color: Colors.blue[600]),
                                              SizedBox(width: 8),
                                              Text("Pending Invoice No",
                                                  style: textboxheading),
                                              Icon(
                                                Icons.star,
                                                size: 8,
                                                color: Colors.red,
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: Responsive.isDesktop(
                                                        context)
                                                    ? 0
                                                    : 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                    child:
                                                        _buildInvoiceNoDropdown()),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: buttonColor),
                                                  height: 30,
                                                  child: ElevatedButton(
                                                    onPressed: _isProcessing
                                                        ? null
                                                        : handleGoButtonClick,
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      minimumSize: const Size(
                                                          45.0, 20.0),
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      shadowColor:
                                                          Colors.transparent,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 0,
                                                              bottom: 0,
                                                              left: 8,
                                                              right: 8),
                                                      child: const Text(
                                                        'Go',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: buttonColor),
                                                  height: 30,
                                                  child: ElevatedButton(
                                                    onPressed: _isProcessing
                                                        ? null
                                                        : handlePreviousButtonClick,
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      minimumSize: const Size(
                                                          45.0, 20.0),
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      shadowColor:
                                                          Colors.transparent,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 0,
                                                              bottom: 0,
                                                              left: 8,
                                                              right: 8),
                                                      child: const Text(
                                                        'Preview',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 15,
                                                ),
                                                if (RP_bool)
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8,
                                                        horizontal: 12),
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                          left: BorderSide(
                                                              width: 4,
                                                              color: Colors
                                                                  .blueAccent)),
                                                    ),
                                                    child: Wrap(
                                                      alignment:
                                                          WrapAlignment.start,
                                                      children: [
                                                        _buildLabelText(
                                                            'RP Inv No: '),
                                                        _buildValueText(
                                                            RP_InvoiceNoController
                                                                .text),
                                                        const SizedBox(
                                                            width: 15),
                                                        _buildLabelText(
                                                            'RP Cus Name: '),
                                                        _buildValueText(
                                                            RP_CustomernameController
                                                                .text),
                                                        const SizedBox(
                                                            width: 15),
                                                        _buildLabelText(
                                                            'RP Mobile No: '),
                                                        _buildValueText(
                                                            RP_mobilenoController
                                                                .text),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
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
                                      : 15,
                                  left: 20,
                                  right: 0),
                              child: _buildTable(),
                            ),
                          if (!Responsive.isDesktop(context))
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 15, left: 35, right: 35),
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

                              // Right Side - Total Send Qty Section
                              Padding(
                                padding: EdgeInsets.only(
                                    right: MediaQuery.of(context).size.width *
                                        0.02),
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
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: Responsive.isDesktop(context) ? 30 : 5,
                                ),
                                Container(
                                  height: 35,
                                  decoration: BoxDecoration(color: buttonColor),
                                  child: ElevatedButton(
                                    // onPressed: () async {
                                    //   if (tableData.isEmpty) {
                                    //     searchallfeild();
                                    //   } else {
                                    //     // Show the processing dialog
                                    //     await fetchTokenwithCusid();
                                    //     showDialog(
                                    //       context: context,
                                    //       barrierDismissible:
                                    //           false, // Prevent dismissing the dialog manually
                                    //       builder: (BuildContext context) {
                                    //         return const AlertDialog(
                                    //           content: Row(
                                    //             children: [
                                    //               CircularProgressIndicator(
                                    //                   color: Colors.blue),
                                    //               SizedBox(width: 20),
                                    //               Text(
                                    //                 "Processing...",
                                    //                 style:
                                    //                     TextStyle(fontSize: 16),
                                    //               ),
                                    //             ],
                                    //           ),
                                    //         );
                                    //       },
                                    //     );

                                    //     showDialog(
                                    //       context: context,
                                    //       barrierDismissible:
                                    //           false, // Prevents closing when tapping outside
                                    //       builder: (BuildContext context) {
                                    //         return AlertDialog(
                                    //           title: Text("Confirmation"),
                                    //           content: Text(
                                    //               "Are you sure you want to proceed?"),
                                    //           actions: [
                                    //             TextButton(
                                    //               onPressed: () {
                                    //                 Navigator.of(context)
                                    //                     .pop(); // Close dialog
                                    //               },
                                    //               child: Text("No",
                                    //                   style: TextStyle(
                                    //                       color: Colors.red)),
                                    //             ),
                                    //             TextButton(
                                    //               onPressed: () async {
                                    //                 Navigator.of(context)
                                    //                     .pop(); // Close dialog
                                    //                 await postCreateDispatch();

                                    //                 // Clear data and reset controllers after processing
                                    //                 setState(() {
                                    //                   tableData.clear();
                                    //                   CustomerNoController
                                    //                       .clear();
                                    //                   CustomerNameController
                                    //                       .clear();
                                    //                   CustomersiteidController
                                    //                       .clear();
                                    //                   CustomersitechannelController
                                    //                       .clear();
                                    //                   deliveryaddressController
                                    //                       .clear();
                                    //                   RemarkController.clear();
                                    //                   CustomeSiteList = [];
                                    //                   InvoiceNoList = [];
                                    //                   InvoiceNoController
                                    //                       .clear();
                                    //                   NoofitemController.text =
                                    //                       '0';
                                    //                   totaldisreqController
                                    //                       .text = '0';
                                    //                   totalinvoicecountbool =
                                    //                       false;
                                    //                 });

                                    //                 // Close the processing dialog
                                    //                 Navigator.of(context).pop();

                                    //                 // Show the confirmation dialog
                                    //                 _showConfirmationDialog();
                                    //               },
                                    //               child: Text("Yes",
                                    //                   style: TextStyle(
                                    //                       color: Colors.green)),
                                    //             ),
                                    //           ],
                                    //         );
                                    //       },
                                    //     );

                                    //     // Perform your processing
                                    //   }
                                    //   postLogData("Create Dispatch", "Saved");
                                    // },

                                    onPressed: () async {
                                      if (tableData.isEmpty) {
                                        searchallfeild();
                                      } else {
                                        // Show processing dialog first
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              content: Row(
                                                children: const [
                                                  CircularProgressIndicator(
                                                      color: Colors.blue),
                                                  SizedBox(width: 20),
                                                  Text(
                                                    "Processing...",
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );

                                        // Close the processing dialog before showing confirmation dialog
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                        }

                                        // Show confirmation dialog
                                        if (context.mounted) {
                                          proceed = await showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius
                                                        .zero), // Removes border radius
                                                child: Container(
                                                  width: 300,
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            "Confirmation",
                                                            style:
                                                                textboxheading,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 15),
                                                      const Text(
                                                        "Are you sure you want to proceed?",
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: textBoxstyle,
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(false);
                                                            },
                                                            child: const Text(
                                                                "No",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red)),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(true);
                                                            },
                                                            child: const Text(
                                                                "Yes",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .green)),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );

                                          if (proceed) {
                                            // Show processing dialog again for posting dispatch
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  content: Row(
                                                    children: const [
                                                      CircularProgressIndicator(
                                                          color: Colors.blue),
                                                      SizedBox(width: 20),
                                                      Text(
                                                        "Processing...",
                                                        style: TextStyle(
                                                            fontSize: 13),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                            // Perform processing
                                            await fetchTokenwithCusid();

                                            await postCreateDispatch();

                                            // Close the processing dialog
                                            if (context.mounted) {
                                              Navigator.of(context).pop();
                                            }

                                            await fetchCustomerNumbers();

                                            // Clear data and reset controllers
                                            setState(() {
                                              tableData.clear();
                                              CustomerNoController.clear();
                                              CustomerNameController.clear();
                                              CustomersiteidController.clear();
                                              CustomersitechannelController
                                                  .clear();
                                              deliveryaddressController.clear();
                                              RemarkController.clear();
                                              CustomeSiteList = [];
                                              InvoiceNoList = [];
                                              InvoiceNoController.clear();
                                              NoofitemController.text = '0';
                                              totaldisreqController.text = '0';
                                              totalinvoicecountbool = false;

                                              RP_bool = false;
                                            });

                                            RP_bool = false;

                                            // Show confirmation dialog after completion
                                          }
                                        }
                                      }

                                      RP_bool = false;
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
                                        'Send',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  height: 35,
                                  decoration: BoxDecoration(color: buttonColor),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        tableData.clear();
                                        CustomerNoController.clear();
                                        CustomerNameController.clear();
                                        CustomersiteidController.clear();
                                        CustomersitechannelController.clear();

                                        CustomeSiteList = [];
                                        InvoiceNoList = [];
                                        InvoiceNoController.clear();

                                        NoofitemController.text = '0';
                                        totaldisreqController.text = '0';
                                        totalinvoicecountbool = false;
                                      });

                                      postLogData("Create Dispatch", "Clear");
                                      // successfullyLoginMessage();
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
                                        'Clear',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: Responsive.isDesktop(context) ? 10 : 50,
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

  void showInvoiceCancellationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool isCancelled = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.white, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Invoice Cancellation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isCancelled) ...[
                            const Text(
                              'You are about to cancel this invoice. Please review the details below:',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Details Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildDetailItem(
                                    icon: Icons.person_outline,
                                    label: 'Customer No',
                                    value: CustomerNoController.text,
                                  ),
                                  const Divider(height: 16, color: Colors.grey),
                                  _buildDetailItem(
                                    icon: Icons.badge_outlined,
                                    label: 'Customer Name',
                                    value: CustomerNameController.text,
                                  ),
                                  const Divider(height: 16, color: Colors.grey),
                                  _buildDetailItem(
                                    icon: Icons.location_on_outlined,
                                    label: 'Site ID',
                                    value: CustomersiteidController.text,
                                  ),
                                  const Divider(height: 16, color: Colors.grey),
                                  _buildDetailItem(
                                    icon: Icons.receipt_outlined,
                                    label: 'Invoice No',
                                    value: InvoiceNoController.text,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Warning message
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Colors.orange.shade700),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'This action cannot be undone. Please confirm your decision.',
                                      style: TextStyle(
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    side: BorderSide(
                                      color: Colors.grey.shade400,
                                      width: 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Go Back',
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    print("Cancel confirmation button clicked");

                                    await fetchInvoiceStatus();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade700,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Confirm Cancellation',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String message = '';

  Future<void> fetchInvoiceStatus() async {
    setState(() {
      isLoading = true;
      message = '';
    });

    String invoiceno = InvoiceNoController.text;
    String customerId = CustomersiteidController.text;
    String customerno = CustomerNoController.text;
    final IpAddress = await getActiveIpAddress();

    final url = Uri.parse(
        '$IpAddress/Check_InvoiceStatus_CancelInvoice/$customerno/$customerId/$invoiceno/');

    print(
        "$IpAddress/Check_InvoiceStatus_CancelInvoice/$customerno/$customerId/$invoiceno/");
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final statusMessage = data['message'] ?? 'No message found';

        if (statusMessage
            .toLowerCase()
            .contains('invoice not found in any records')) {
          // Show success dialog for this specific case

          Navigator.of(context).pop(true);
          await updateFlagStatus();
          showCancellationSuccessDialog(context);

          print("Stared message is like this $statusMessage");
        } else {
          // Show warning dialog for other messages
          Navigator.of(context).pop(true);
          showWarningDialog(context, statusMessage);
          print("Stared $statusMessage");
        }
      } else {
        showErrorDialog(context, 'Failed to fetch data',
            'Status Code: ${response.statusCode}\n${response.body}');
      }
    } on http.ClientException catch (e) {
      showErrorDialog(context, 'Connection Error', e.message);
    } on TimeoutException {
      showErrorDialog(
          context, 'Timeout', 'The request took too long to complete.');
    } catch (e) {
      showErrorDialog(context, 'Unexpected Error', e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateFlagStatus() async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/Update_flag_status_Underlivered/';

    final body = {
      "CUSTOMER_NUMBER": CustomerNoController.text.trim(),
      "CUSTOMER_SITE_ID": CustomersiteidController.text.trim(),
      "INVOICE_NUMBER": InvoiceNoController.text.trim(),
    };

    print("Sending data to URL: $url");
    print("Request body: $body");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          print("✅ Success: ${jsonResponse['message']}");
          message = "✅ Success: ${jsonResponse['message']}";
        });
      } else {
        final errorResponse = jsonDecode(response.body);
        setState(() {
          print(
              "❌ Error: ${errorResponse['error'] ?? errorResponse['message']}");
          message =
              "❌ Error: ${errorResponse['error'] ?? errorResponse['message']}";
        });
      }
    } catch (e) {
      setState(() {
        print("❌ Exception: $e");
        message = "❌ Exception: $e";
      });
    }
  }

  void showWarningDialog(BuildContext context, String message) {
    showAnimatedDialog(
      context: context,
      title: 'Warning',
      message: message,
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.orange,
      gradientColors: [Colors.orangeAccent, Colors.deepOrange],
    );
  }

  void showErrorDialog(BuildContext context, String title, String message) {
    showAnimatedDialog(
      context: context,
      title: title,
      message: message,
      icon: Icons.error_outline_rounded,
      iconColor: Colors.red,
      gradientColors: [Colors.redAccent, Colors.red],
    );
  }

  void showAnimatedDialog({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required List<Color> gradientColors,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
          ),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
              elevation: 8,
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width *
                      0.25, // 80% of screen width
                  minWidth: 200, // Minimum width
                ),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10))
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated Icon
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 600),
                        tween: Tween<double>(begin: 0, end: 1),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: gradientColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: iconColor.withOpacity(0.4),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: Icon(
                                icon,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Title with fade animation
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 500),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Message with fade animation
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 500),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Text(
                                message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Animated Button
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 600),
                        tween: Tween<double>(begin: 0, end: 1),
                        curve: Curves.fastOutSlowIn,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.scale(
                              scale: value,
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    backgroundColor: iconColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 3,
                                    shadowColor: iconColor.withOpacity(0.3),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      tableData.clear();

                                      InvoiceNoController.clear();
                                      NoofitemController.text = '0';
                                      totaldisreqController.text = '0';
                                      totalinvoicecountbool = false;
                                    });
                                  },
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showCancellationSuccessDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
          ),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              insetAnimationDuration: const Duration(milliseconds: 300),
              insetAnimationCurve: Curves.easeInOut,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
              elevation: 8,
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.22,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Success Icon
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween<double>(begin: 0, end: 1),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF4CAF50),
                                  Color(0xFF8BC34A),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF4CAF50).withOpacity(0.4),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Title with fade animation
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: const Text(
                              'Successfully Canceled',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Message with fade animation
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: const Text(
                              'Your action has been canceled successfully.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Animated Button
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween<double>(begin: 0, end: 1),
                      curve: Curves.fastOutSlowIn,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: value,
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: const Color(0xFF4CAF50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                  shadowColor:
                                      const Color(0xFF4CAF50).withOpacity(0.3),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    tableData.clear();
                                    CustomerNoController.clear();
                                    CustomerNameController.clear();
                                    CustomersiteidController.clear();
                                    CustomersitechannelController.clear();
                                    deliveryaddressController.clear();
                                    RemarkController.clear();
                                    CustomeSiteList = [];
                                    InvoiceNoList = [];
                                    InvoiceNoController.clear();
                                    NoofitemController.text = '0';
                                    totaldisreqController.text = '0';
                                    totalinvoicecountbool = false;
                                  });
                                },
                                child: const Text(
                                  'Close',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Invoice Cancelled Successfully!',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'INV-2023-147 has been cancelled',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  elevation: 2,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'View Cancellation Receipt',
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
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
                          fontSize: 14,
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

    return Dialog(
      child: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            width: Responsive.isDesktop(context) ? screenWidth * 0.76 : 600,
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
                          fontSize: 16,
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
                                                // Check if all fields are empty
                                                bool allEmpty =
                                                    true; // Assume all fields are empty initially
                                                for (int i = 0;
                                                    i < _controllers.length;
                                                    i++) {
                                                  if (_controllers[i]
                                                      .text
                                                      .isNotEmpty) {
                                                    allEmpty =
                                                        false; // As soon as we find one filled field, set allEmpty to false
                                                    break; // Exit loop as soon as we find a non-empty field
                                                  }
                                                }

                                                if (allEmpty) {
                                                  // Show validation dialog if all fields are empty
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Row(
                                                          children: const [
                                                            Icon(
                                                              Icons.warning,
                                                              color:
                                                                  Colors.yellow,
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    8), // Adjust spacing
                                                            Text(
                                                              'Warning',
                                                              style:
                                                                  textboxheading,
                                                            ),
                                                          ],
                                                        ),
                                                        content: const Text(
                                                          "Kindly enter a qty..!!",
                                                          style: textboxheading,
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // Close the dialog
                                                            },
                                                            child: const Text(
                                                              "OK",
                                                              style:
                                                                  textboxheading,
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  // Perform the actions if at least one field is filled
                                                  _addData();
                                                  print(
                                                      "tableDataaaaaaaaaa $tableData");
                                                  Navigator.pop(context);
                                                  _updatecount();
                                                  _updatedisreqamt();

                                                  // Filter the InvoiceNoList to remove existing invoice numbers
                                                  setState(() {
                                                    // InvoiceNoList = InvoiceNoList
                                                    //     .where((invoiceNo) =>
                                                    //         !tableData.any((data) =>
                                                    //             data[
                                                    //                 'invoiceno'] ==
                                                    //             invoiceNo)).toList();
                                                    // InvoiceNoController.clear();
                                                    print(
                                                        "before the added invoice list $InvoiceNoList");
                                                    if (commersialrole ==
                                                        "Retail Sales Supervisor") {
                                                      // Extract the number after the hyphen in each invoice string
                                                      List<String>
                                                          cleanedInvoiceNoList =
                                                          InvoiceNoList.map(
                                                              (inv) {
                                                        // Split by hyphen and trim
                                                        if (inv.contains('-')) {
                                                          return inv
                                                              .split('-')[1]
                                                              .trim();
                                                        }
                                                        return inv
                                                            .trim(); // Fallback in case '-' is missing
                                                      }).toList();

                                                      // Filter only those not present in tableData
                                                      InvoiceNoList = cleanedInvoiceNoList
                                                          .where((invoiceNo) =>
                                                              !tableData.any(
                                                                  (data) =>
                                                                      data[
                                                                          'invoiceno'] ==
                                                                      invoiceNo))
                                                          .toList();
                                                    } else {
                                                      // Normal comparison when not Retail Sales Supervisor
                                                      InvoiceNoList = InvoiceNoList
                                                          .where((invoiceNo) =>
                                                              !tableData.any((data) =>
                                                                  data[
                                                                      'invoiceno'] ==
                                                                  invoiceNo)).toList();
                                                    }
                                                    print(
                                                        "After the added invoice list $InvoiceNoList");
                                                  });

                                                  // Print the updated data
                                                  print(
                                                      "invoice details after tabledata $InvoiceNoList");
                                                  print(
                                                      "tableData a $tableData");

                                                  postLogData(
                                                      "Create Dispatch Invoice Pop-up",
                                                      "Added");
                                                }
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
                                              child: const Text(
                                                'Add',
                                                style: commonWhiteStyle,
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
                                                            left: 0),
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
                                                                // hintText: label,
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
                                                                fillColor: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        255),
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
                                              // Check if all fields are empty
                                              bool allEmpty =
                                                  true; // Assume all fields are empty initially
                                              for (int i = 0;
                                                  i < _controllers.length;
                                                  i++) {
                                                if (_controllers[i]
                                                    .text
                                                    .isNotEmpty) {
                                                  allEmpty =
                                                      false; // As soon as we find one filled field, set allEmpty to false
                                                  break; // Exit loop as soon as we find a non-empty field
                                                }
                                              }

                                              if (allEmpty) {
                                                // Show validation dialog if all fields are empty
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Row(
                                                        children: const [
                                                          Icon(
                                                            Icons.warning,
                                                            color:
                                                                Colors.yellow,
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  8), // Adjust spacing
                                                          Text('Warning'),
                                                        ],
                                                      ),
                                                      content: const Text(
                                                          "Kindly enter a qty..!!"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Close the dialog
                                                          },
                                                          child:
                                                              const Text("OK"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              } else {
                                                // Perform the actions if at least one field is filled
                                                _addData();
                                                print(
                                                    "tableDataaaaaaaaaa $tableData");

                                                Navigator.pop(context);
                                                _updatecount();
                                                _updatedisreqamt();

                                                // Filter the InvoiceNoList to remove existing invoice numbers
                                                setState(() {
                                                  // InvoiceNoList = InvoiceNoList
                                                  //     .where((invoiceNo) =>
                                                  //         !tableData.any((data) =>
                                                  //             data[
                                                  //                 'invoiceno'] ==
                                                  //             invoiceNo)).toList();
                                                  // InvoiceNoController.clear();
                                                  print(
                                                      "before the added invoice list $InvoiceNoList");
                                                  if (commersialrole ==
                                                      "Retail Sales Supervisor") {
                                                    // Extract the number after the hyphen in each invoice string
                                                    InvoiceNoList =
                                                        InvoiceNoList.where(
                                                            (fullInv) {
                                                      String invoiceNo =
                                                          fullInv.contains('-')
                                                              ? fullInv
                                                                  .split('-')[1]
                                                                  .trim()
                                                              : fullInv.trim();
                                                      return !tableData.any(
                                                          (data) =>
                                                              data[
                                                                  'invoiceno'] ==
                                                              invoiceNo);
                                                    }).toList();
                                                  } else {
                                                    // Normal comparison when not Retail Sales Supervisor
                                                    InvoiceNoList = InvoiceNoList
                                                        .where((invoiceNo) =>
                                                            !tableData.any((data) =>
                                                                data[
                                                                    'invoiceno'] ==
                                                                invoiceNo)).toList();
                                                  }
                                                  print(
                                                      "After the added invoice list $InvoiceNoList");
                                                  InvoiceNoController.clear();
                                                });

                                                // Print the updated data
                                                print(
                                                    "invoice details after tabledata $InvoiceNoList");
                                                print("tableData a $tableData");

                                                postLogData(
                                                    "Create Dispatch Invoice Pop-up",
                                                    "Added");
                                              }
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
                                                style: commonWhiteStyle,
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
                                                    ? 0
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
                                                          left: 0),
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
                                                              // hintText: label,
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
                                                              fillColor: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      255),
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

  List<Map<String, dynamic>> blockedInvoiceList = [];

  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];
  List<Map<String, dynamic>> createtableData = [];

  Future<void> fetchInvoiceDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno');
    String customerNumber = CustomerNoController.text;
    String invocieno = InvoiceNoController.text;
    final IpAddress = await getActiveIpAddress();

    final String initialUrl =
        '$IpAddress/invoicedetails/?salesman_no=$salesloginno&customer_number=$customerNumber&invoice_number=$invocieno';
    String? nextPageUrl = initialUrl;
    print("Invoice details URrrrrL: $nextPageUrl");

    createtableData = [];
    _controllers.clear();
    _focusNodes.clear();

    try {
      // Loop through all pages of invoice details
      while (nextPageUrl != null) {
        var response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          // Check if 'results' is not null or empty
          if (data['results'] != null && data['results'].isNotEmpty) {
            for (var result in data['results']) {
              // Validate and process the inventory_item_id
              String inventoryItemId = result['item_code'].toString();
              if (inventoryItemId.isEmpty) {
                print("Invalid item_code: $inventoryItemId");
                continue;
              }

              // Validate and process the invoice quantity
              String invoiceqty = result['quantity'].toString();
              if (invoiceqty.isEmpty || double.tryParse(invoiceqty) == null) {
                print("Invalid quantity: $invoiceqty");
                continue;
              }

              // Fetch the DISPATCHED_QTY from the balance_dispatch URL
              final String balanceDispatchUrl =
                  '$IpAddress/balance_dispatch/?SALESMAN_NO=$salesloginno&INVOICE_NUMBER=$invocieno';
              var balanceResponse =
                  await http.get(Uri.parse(balanceDispatchUrl));

              // print('Balance dispatch URL: $balanceDispatchUrl');

              String invoicebalqty =
                  invoiceqty; // Default to full invoice quantity
              int totalDispatchedQty = 0;

              if (balanceResponse.statusCode == 200) {
                var balanceData = json.decode(balanceResponse.body);

                // If balanceResponse body has data, process it
                if (balanceData.isNotEmpty) {
                  for (var item in balanceData) {
                    String dispatchedQty = item['DISPATCHED_QTY'].toString();
                    String balanceItemId = item['INVENTORY_ITEM_ID'].toString();

                    if (balanceItemId == inventoryItemId &&
                        dispatchedQty.isNotEmpty &&
                        double.tryParse(dispatchedQty) != null) {
                      totalDispatchedQty += double.parse(dispatchedQty).toInt();
                    }
                  }

                  // print(
                  //     "Balance dispatch data found. $invoicebalqty = ${double.parse(invoiceqty)} - $totalDispatchedQty");
                  // Subtract the total dispatched quantity from invoiceqty
                  invoicebalqty =
                      (double.parse(invoiceqty) - totalDispatchedQty)
                          .toString();
                } else {
                  print("No balance dispatch data found.");
                }
              } else {
                // print(
                //     'Error fetching balance dispatch details: ${balanceResponse.statusCode} - ${balanceResponse.body}');
              }

              // Only add data to createtableData if invoicebalqty is greater than 0
              if (double.tryParse(invoicebalqty) != null &&
                  double.parse(invoicebalqty) > 0) {
                createtableData.add({
                  'id': result['line_number'],
                  'undel_id': result['undel_id'],
                  'invoicebalqty': invoicebalqty,
                  'alreadydispatchedqty': totalDispatchedQty,
                  'itemcode': result['item_code'].toString(),
                  'itemdetails': result['description'].toString(),
                  'customer_trx_id': result['customer_trx_id'],
                  'customer_trx_line_id': result['customer_trx_line_id'],
                  'invoiceqty': invoiceqty,
                  'itemqty': result['dispatch_qty'].toString(),
                  'quantity': result['quantity'],
                  'Exisdispatched_qty': (result['dispatched_qty'] ?? 0),
                  'dispatched_qty': (result['quantity'] ?? 0) -
                      (result['dispatched_qty'] ?? 0),
                  'disreqqty': '0',
                });
                _controllers.add(TextEditingController());
                _focusNodes.add(FocusNode());
              }
            }
          }

          // Get the next page URL, if available
          nextPageUrl = data['next'];

          print('response.body: ${response.body}');
          if (data is Map &&
              data.containsKey("Message") &&
              data["Message"] == "This invoice is blocked") {
            setState(() {
              blockedInvoiceList.add({
                'Customer_Number': data["Customer_Number"],
                'Invoice_Number': data["Invoice_Number"],
                'Message': data["Message"],
              });
            });
          }

          print('blockedInvoiceList: ${blockedInvoiceList}');
        } else {
          print(
              'Error fetching invoice details: ${response.statusCode} - ${response.body}');
          break;
        }
      }

      // Sort createtableData by 'line_number' in ascending order
      createtableData.sort((a, b) {
        return a['id'].compareTo(b['id']);
      });

      // Update the state with the invoice details
      setState(() {
        // print('Final Invoice Details: $createtableData');
      });
    } catch (e) {
      print('Error fetching invoice details: $e');
    }
  }

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
          'undel_id': item['undel_id'],
          'itemcode': item['itemcode'],
          'itemdetails': item['itemdetails'],
          'invoiceqty': item['invoiceqty'],
          'dispatchqty': item["Exisdispatched_qty"],
          'balanceqty': (double.parse(item['dispatched_qty'].toString()) -
                  double.parse(disreqQty.toString()))
              .toString(), // Calculate balanceqty
          'disreqqty': disreqQty.toString(),
          'invoicebalqty': item['invoicebalqty'],
          'amount': item['amount'],
          'item_cost': item['item_cost'],
          'itemqty': item['itemqty'],

          'customer_trx_id': item['customer_trx_id'],
          'customer_trx_line_id': item['customer_trx_line_id'],
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
    // Dispose of controllers, focus nodes, and cancel the timer
    _controllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((focusNode) => focusNode.dispose());
    // _timer?.cancel(); // Cancel the timer
    totalamountcontroller.dispose(); // Dispose of the total controller
    super.dispose();

    postLogData("Create Dispatch", "Closed");
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
  double previousviewcalculateTableWidth(BuildContext context) {
    // Calculate total width based on column proportions
    return MediaQuery.of(context).size.width *
        0.4; // Adjust this multiplier as needed
  }

  Widget _PreviewviewbuildTable() {
    List<Map<String, dynamic>> sortedTableData = List.from(createtableData);
    sortedTableData.sort((a, b) =>
        int.parse(a['id'].toString()).compareTo(int.parse(b['id'].toString())));

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
              child: Container(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey[400]!,
                    width: 1.0,
                  ),
                ),
                height: 220,
                width: previousviewcalculateTableWidth(context),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 0, right: 0, top: 0, bottom: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildHeaderCell("I.L.No", Icons.list_alt),
                        buildHeaderItemcodeCell("Item Code", Icons.code),
                        buildItemDescpreviewHeaderCell(
                            "Item Description", Icons.description),
                        buildHeaderCell("Q.Inv", Icons.check_circle),
                        buildHeaderCell("Q.Bal", Icons.equalizer),
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
            ),
          ),
        ),
        Positioned(
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
                  _horizontalScrollController2.animateTo(
                    _horizontalScrollController2.offset - 100,
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
                  _horizontalScrollController2.animateTo(
                    _horizontalScrollController2.offset + 100,
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

  Widget PreviewbuildRow(int index, Map<String, dynamic> data) {
    var id = data['id'].toString();
    var itemcode = _removeDecimalIf(data['itemcode']);
    var itemdetails = _removeDecimalIf(data['itemdetails']);
    var invoiceqty = _removeDecimalIf(data['invoiceqty']);
    var invoicebalqty = _removeDecimalIf(data['invoicebalqty']);

    var dispatched_qty = _removeDecimalIf(data['dispatched_qty']);

    var customer_trx_id = _removeDecimalIf(data['customer_trx_id']);
    var customer_trx_line_id = _removeDecimalIf(data['customer_trx_line_id']);

    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDataCell(id),
          buildDataitemcodeCell(itemcode),
          buildItempreviewDescCell(itemdetails),
          buildDataCell(invoiceqty),
          buildDataCell(dispatched_qty),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _tableCell(String data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        data,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  // Helper function to calculate total table width dynamically
  double calculateTableWidth(BuildContext context) {
    double columnWidths = MediaQuery.of(context).size.width * 0.03 +
        MediaQuery.of(context).size.width * 0.3 +
        MediaQuery.of(context).size.width * 0.45 +
        MediaQuery.of(context).size.width * 0.03 +
        MediaQuery.of(context).size.width * 0.03 +
        MediaQuery.of(context).size.width * 0.05;

    return columnWidths;
  }

  Widget _viewbuildTable() {
    List<Map<String, dynamic>> sortedTableData = List.from(createtableData);
    sortedTableData.sort((a, b) =>
        int.parse(a['id'].toString()).compareTo(int.parse(b['id'].toString())));

    print("Create table datas : $createtableData");
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildHeaderCell("I.L.No", Icons.list_alt),
                              buildHeaderItemcodeCell("Item Code", Icons.code),
                              buildItemDescHeaderCell(
                                  "Item Description", Icons.description),
                              buildHeaderCell("Q.Inv", Icons.check_circle),
                              buildHeaderCell("Q.Bal", Icons.equalizer),
                              Flexible(
                                child: Container(
                                  height: 30,
                                  width: Responsive.isDesktop(context)
                                      ? MediaQuery.of(context).size.width * 0.1
                                      : MediaQuery.of(context).size.width *
                                          0.80,
                                  decoration:
                                      BoxDecoration(color: Colors.white),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.send_outlined,
                                            size: 15, color: Colors.blue),
                                        SizedBox(width: 2),
                                        Text(
                                          "Dis.R.Qty",
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
                                              onChanged: (value) {
                                                setState(() {
                                                  isChecked =
                                                      value!; // Update the state
                                                  if (isChecked) {
                                                    // When checked, prefill all disreqqty fields
                                                    for (int i = 0;
                                                        i <
                                                            createtableData
                                                                .length;
                                                        i++) {
                                                      double invoiceBalQty =
                                                          double.tryParse(_removeDecimalIf(
                                                                  createtableData[
                                                                          i][
                                                                      'dispatched_qty'])) ??
                                                              0.0;
                                                      _controllers[i].text =
                                                          invoiceBalQty
                                                              .toString();
                                                      createtableData[i]
                                                              ['disreqqty'] =
                                                          invoiceBalQty
                                                              .toString();
                                                    }
                                                  } else {
                                                    // Clear fields if unchecked
                                                    for (int i = 0;
                                                        i <
                                                            createtableData
                                                                .length;
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
                        else if (createtableData.isEmpty &&
                            blockedInvoiceList.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 60.0),
                            child: Container(
                                width: 500,
                                child: Text(
                                    "Message: This invoice has been blocked by the Credit Department.")),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 60.0),
                            child: Container(
                                width: 500,
                                child: Text(
                                    "Note: All items under this invoice have already been requested by the salesman. Therefore, no items are displayed here. Once the requested items are forwarded to trucking, this invoice will no longer appear under this customer.")),
                          ),
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

  Widget buildHeaderCell(String label, IconData icon) {
    return Flexible(
      child: Container(
        height: 30,
        width: Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.045
            : MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(color: Colors.white),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 15, color: Colors.blue),
              SizedBox(width: 2),
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

  Widget buildHeaderItemcodeCell(String label, IconData icon) {
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
              SizedBox(width: 2),
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

  Widget buildItemDescpreviewHeaderCell(String label, IconData icon) {
    return Container(
      height: 30,
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(color: Colors.white),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: Colors.blue),
            SizedBox(width: 2),
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

  Widget buildItemDescHeaderCell(String label, IconData icon) {
    return Container(
      height: 30,
      width: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(color: Colors.white),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: Colors.blue),
            SizedBox(width: 2),
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

  Widget buildRow(int index, Map<String, dynamic> data) {
    // Convert values to string while removing .0 if necessary
    var id = data['id'].toString();
    var itemcode = _removeDecimalIf(data['itemcode']);
    var itemdetails = _removeDecimalIf(data['itemdetails']);
    var invoiceqty = _removeDecimalIf(data['invoiceqty']);
    var invoicebalqty = _removeDecimalIf(data['invoicebalqty']);

    var dispatched_qty = _removeDecimalIf(data['dispatched_qty']);

    var customer_trx_id = _removeDecimalIf(data['customer_trx_id']);
    var customer_trx_line_id = _removeDecimalIf(data['customer_trx_line_id']);

    return Container(
      margin: EdgeInsets.symmetric(
          vertical: 0), // Optional for spacing between rows

      child: Padding(
        padding: const EdgeInsets.only(left: 0.0, right: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDataCell(id),
            buildDataitemcodeCell(itemcode),
            buildItemDescCell(itemdetails),
            buildDataCell(invoiceqty),
            // buildDataCell(invoicebalqty),
            buildDataCell(dispatched_qty),
            buildInputCell(index, double.tryParse(dispatched_qty) ?? 0.0),
          ],
        ),
      ),
    );
  }

  Widget buildDataCell(String value) {
    return Flexible(
      child: Container(
        height: 30,
        width: Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.045
            : MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
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
                onTap: () {
                  // Optional: Handle single tap if needed
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDataitemcodeCell(String value) {
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
              child: SelectableText(
                value,
                textAlign: TextAlign.left,
                style: TableRowTextStyle,
                showCursor: false,
                cursorColor: Colors.blue,
                cursorWidth: 2.0,
                toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
                onTap: () {
                  // Optional: Handle single tap if needed
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItempreviewDescCell(String value) {
    return Container(
      height: 30,
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
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
              onTap: () {
                // Optional: Handle single tap if needed
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItemDescCell(String value) {
    return Container(
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
            child: SelectableText(
              value,
              textAlign: TextAlign.left,
              style: TableRowTextStyle,
              showCursor: false,
              cursorColor: Colors.blue,
              cursorWidth: 2.0,
              toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
              onTap: () {
                // Optional: Handle single tap if needed
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInputCell(int index, double invoicebalqty) {
    return Flexible(
      child: Container(
        height: 30,
        width: Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.08
            : MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 17),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) {
                setState(() {
                  int enteredQty = int.tryParse(value) ?? 0;
                  int maxQty = invoicebalqty.toInt();

                  if (enteredQty > maxQty) {
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
                                          'The entered quantity exceeds the available balance. Would you like to adjust it to $maxQty?',
                                          style: TextStyle(
                                            fontSize: 13,
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
                                                maxQty.toString();
                                            double totalMaxQty = _controllers
                                                .fold(0, (sum, controller) {
                                              double value = double.tryParse(
                                                      controller.text) ??
                                                  0;
                                              return sum + value;
                                            });

                                            // Update a specific controller with the total sum
                                            totalamountcontroller.text =
                                                totalMaxQty.toString();
                                            createtableData[index]
                                                    ['disreqqty'] =
                                                maxQty.toString();
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      SizedBox(width: 10),
                                      TextButton(
                                        child: Text('No'),
                                        onPressed: () {
                                          setState(() {
                                            _controllers[index].text = "0";
                                            double totalMaxQty = _controllers
                                                .fold(0, (sum, controller) {
                                              double value = double.tryParse(
                                                      controller.text) ??
                                                  0;
                                              return sum + value;
                                            });

                                            // Update a specific controller with the total sum
                                            totalamountcontroller.text =
                                                totalMaxQty.toString();
                                            createtableData[index]
                                                ['disreqqty'] = "0";
                                          });
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
                    createtableData[index]['disreqqty'] = value;
                  }
                  _updateTotal();
                });
              },
              onSubmitted: (value) {
                int enteredQty = int.tryParse(value) ?? 0;
                int maxQty = invoicebalqty.toInt();

                setState(() {
                  if (enteredQty > maxQty) {
                    _controllers[index].text = maxQty.toString();
                    createtableData[index]['disreqqty'] = maxQty.toString();
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
              style: textBoxstyle,
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

  int reqno = 0;
  String token = '';

  Future<void> fetchTokenwithCusid() async {
    final IpAddress = await getActiveIpAddress();

    try {
      // Send a GET request to fetch the REQ_ID and token from the server
      final response = await http.get(
        Uri.parse('$IpAddress/ReqId_generate-token/'),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // Get full REQ_ID string like "REQ_25_04_4"
        String reqID = data['REQ_ID']?.toString() ?? '';
        token = data['tocken'] ?? 'No Token found'; // correct key spelling

        setState(() {
          // You can set any state variables if needed
        });

        print('reqID: $reqID  token: $token');

        // Save to shared preferences
        await saveToSharedPreferences(reqID, token);
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> postCreateDispatch() async {
    await fetchRegionAndWarehouse();

    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/Create_Dispatch/';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno') ?? '';
    String? saveloginname = prefs.getString('saveloginname') ?? '';
    String? saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';

    String? commersialno = prefs.getString('commersialno') ?? '';
    String? commersialname = prefs.getString('commersialname') ?? '';

    String? uniqulastreqno = prefs.getString('uniqulastreqno');

    DateTime now = DateTime.now();
    // Format it to YYYY-MM-DD'T'HH:mm:ss'
    String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);
    DateTime parsedDate =
        DateFormat("dd-MMM-yyyy").parse(_FromdateController.text);

    // Format the date as "yyyy-MM-dd HH:mm:ss.SSS"
    String formattedDeliveryDate =
        DateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(parsedDate);

    print(
        "formattedDeliveryDate $reqno ${_FromdateController.text} $selectedDate");
    try {
      // String reqno = requestNoController.text.toString();
      String warehouse =
          warehouseController.text.isNotEmpty ? warehouseController.text : '';

      String org_name =
          regionController.text.isNotEmpty ? regionController.text : '';

      String cusname = CustomerNameController.text.isNotEmpty
          ? CustomerNameController.text
          : '';
      String cusno = CustomerNoController.text.isNotEmpty
          ? CustomerNoController.text
          : '0'; // Ensure it's a string

      String cussite = CustomersiteidController.text.isNotEmpty
          ? CustomersiteidController.text
          : '0';

      String remards = RemarkController.text.isNotEmpty
          ? RemarkController.text
          : 'null'; // Ensure it's a string

      String deliveryaddress = deliveryaddressController.text.isNotEmpty
          ? deliveryaddressController.text
          : 'null';
      print(
          "tableeeeeeeeeeeeee dataaaaaa: org_name $org_name saveloginOrgId $saleslogiOrgid  $tableData  ");
      // Iterate through each row in tableData and create dispatch data for each row
      for (int i = 0; i < tableData.length; i++) {
        var row = tableData[i]; // Use 'i' to access the correct row
        // var disreqQty = double.tryParse(_controllers[i].text) ?? 0.0;
        var disreqQty =
            double.tryParse(row['disreqqty']?.toString() ?? '0') ?? 0.0;
        var Exisdispatched_qty =
            double.tryParse(row['Exisdispatched_qty']?.toString() ?? '0') ??
                0.0;

        var CUSTOMER_TRX_LINE_ID =
            double.tryParse(row['customer_trx_line_id']?.toString() ?? '0') ??
                0.0;

        var CUSTOMER_TRX_ID =
            double.tryParse(row['customer_trx_id']?.toString() ?? '0') ?? 0.0;

        print(
            "customer trx iod and line id $CUSTOMER_TRX_LINE_ID and customer id is $CUSTOMER_TRX_ID  commersialno commersialno $commersialno");
        // Only proceed if disreqQty is greater than 0

        Map<String, dynamic> createDispatchData = {
          "REQ_ID": uniqulastreqno,
          "PHYSICAL_WAREHOUSE": warehouse,
          "ORG_ID": saleslogiOrgid.isNotEmpty ? saleslogiOrgid : 'Unknown',
          "ORG_NAME": org_name,
          "COMMERCIAL_NO": commersialno.isNotEmpty ? commersialno : 0,
          "COMMERCIAL_NAME":
              commersialname.isNotEmpty ? commersialname : 'Unknown',
          "SALESMAN_NO": salesloginno.isNotEmpty ? salesloginno : 'Unknown',
          "SALESMAN_NAME": saveloginname.isNotEmpty ? saveloginname : 'Unknown',
          "CUSTOMER_NUMBER": cusno.toString(),
          "CUSTOMER_NAME": cusname,
          "CUSTOMER_SITE_ID": cussite,
          "INVOICE_DATE": formattedDate,
          "INVOICE_NUMBER": row['invoiceno']?.toString() ?? '0',
          "LINE_NUMBER": row['id']?.toString() ?? '0',
          "INVENTORY_ITEM_ID": row['itemcode']?.toString() ?? '0',
          "CUSTOMER_TRX_ID": CUSTOMER_TRX_ID,
          "CUSTOMER_TRX_LINE_ID": CUSTOMER_TRX_LINE_ID,
          "ITEM_DESCRIPTION": row['itemdetails']?.toString() ?? '0',
          "TOT_QUANTITY": row['invoiceqty']?.toString() ?? '0',
          "DISPATCHED_QTY": disreqQty.toString(),
          "BALANCE_QTY": row['invoicebalqty']?.toString() ?? '0',
          // (int.tryParse(row['Exisdispatched_qty']?.toString() ?? '0')! -
          //         disreqQty.toInt())
          //     .toString(),
          "DISPATCHED_BY_MANAGER": disreqQty.toString(),
          "TRUCK_SCAN_QTY": disreqQty.toString(),
          "CREATION_DATE": formattedDate,
          "CREATED_BY": saveloginname.isNotEmpty ? saveloginname : 'Unknown',
          "CREATED_IP": 'null',
          "CREATED_MAC": 'null',
          "LAST_UPDATE_DATE": formattedDate,
          "LAST_UPDATED_BY": 'null',
          "LAST_UPDATE_IP": 'null',
          "FLAG": 'A',
          "DELIVERYADDRESS": deliveryaddress,
          "REMARKS": remards,
          "DELIVERY_DATE": formattedDeliveryDate,
          "UNDEL_ID": row['undel_id'] != null
              ? row['undel_id'].toString().split('.')[0]
              : '0',
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

          postLogData("Create Dispatch", "Saved Request $uniqulastreqno");
        } else {
          print(
              'Failed to create dispatch for Line Number: ${row['id']?.toString()}. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          setState(() {
            proceed = false;
          });
          postLogData("Create Dispatch",
              "Failed Request $uniqulastreqno { ${response.statusCode}}");
          await fetchLastRequestNo();

          bool status = requestNoController.text == 'REQNO_ERR' ? true : false;
          print('status $status  ${requestNoController.text}');
          startTimer();

          _showConfirmationDialog(
              'Failed Dispatch',
              'Sorry, This Dispatch Request cannot sent now for some technical reason. Try Again..',
              const Color.fromARGB(255, 152, 35, 35),
              Icons.cancel,
              status);
        }
      }
      await fetchLastRequestNo();
      bool status = requestNoController.text == 'REQNO_ERR' ? true : false;
      print('status $status  ${requestNoController.text}');
      startTimer();
      _showConfirmationDialog(
          'Confirmed Dispatch',
          'Dispatch Request Sent Successfully !!',
          subcolor,
          Icons.check_circle_rounded,
          status);
    } catch (e) {
      print('Error occurred while posting dispatch data: $e');
      setState(() {
        proceed = false;
      });
      postLogData("Create Dispatch", "Failed Request $uniqulastreqno {${e}}");
      await fetchLastRequestNo();

      bool status = requestNoController.text == 'REQNO_ERR' ? true : false;
      print('status $status  ${requestNoController.text}');
      startTimer();

      _showConfirmationDialog(
          'FailedDispatch',
          'Sorry, Your network is not work properly for this dispatch request. Kindly Try Again...',
          const Color.fromARGB(255, 152, 35, 35),
          Icons.cancel,
          status);
    }
  }

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
                      style: TextStyle(fontSize: 15, color: Colors.black),
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

  void checkinvoice(String Message) {
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
                  Message,
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  InvoiceNoController.clear();
                });
                FocusScope.of(context).requestFocus(InvoiceFocusNode);
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

  Future<void> saveToSharedPreferences(String lastCusID, String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uniqulastreqno', lastCusID);
    await prefs.setString('csrf_token', token);
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

  double progress = 0.0; // 0.0 to 1.0

  int elapsedSeconds = 0;
  Timer? timer;

  void startTimer() {
    progress = 0.0;
    elapsedSeconds = 0;
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        elapsedSeconds++;
        progress = elapsedSeconds / 10; // 10 seconds to complete
      });

      if (elapsedSeconds >= 10) {
        t.cancel();
      }
    });
  }

  Future<bool?> _showConfirmationDialog(
    String Heading,
    String Message,
    Color color,
    IconData icon,
    bool getreqno,
  ) async {
    isLoading = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uniqulastreqno = prefs.getString('uniqulastreqno');

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        double progress = 0.0;
        bool showTryButton = false;
        Timer? timer;

        return StatefulBuilder(
          builder: (context, setState) {
            // Start loading if getreqno is true and timer is not already started
            if (getreqno && timer == null) {
              timer = Timer.periodic(const Duration(milliseconds: 200), (t) {
                setState(() {
                  progress += 2; // Increase percentage
                  if (progress >= 100) {
                    t.cancel();
                    timer = null;
                    showTryButton = true; // Show Try Again after load completes
                  }
                });
              });
            }

            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Row(
                      children: [
                        Icon(icon, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          Heading,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (!getreqno) // OK button for false
                    Text(
                      "ReqNo_${uniqulastreqno ?? ''}",
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
                children: [
                  Text(
                    Message,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  // In your widget:
                  // if (getreqno && !showTryButton) ...[
                  //   LinearProgressIndicator(value: progress / 100),
                  //   const SizedBox(height: 6),
                  //   Text(
                  //     '${elapsedSeconds}s',
                  //     style: const TextStyle(fontSize: 12),
                  //   ),
                  // ]
                ],
              ),
              actions: [
                if (!getreqno) // OK button for false
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });

                      await fetchLastRequestNo();
                      await SharedPrefs.cleartockandreqno();

                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                      backgroundColor: color,
                      minimumSize: const Size(60.0, 36.0),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Ok',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                  ),
                if (getreqno) // Try Again button
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });

                      await fetchLastRequestNo();
                      await SharedPrefs.cleartockandreqno();

                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                      backgroundColor: color,
                      minimumSize: const Size(60.0, 36.0),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Try Again',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // Future<bool?> _showConfirmationDialog(String Heading, String Message,
  //     Color color, IconData icon, bool getreqno) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   String? uniqulastreqno = prefs.getString('uniqulastreqno');
  //   return await showDialog<bool>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(5)),
  //         ),
  //         title: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             // Left Section: Icon and Title
  //             Row(
  //               children: [
  //                 Icon(icon, size: 20),
  //                 const SizedBox(width: 4),
  //                 Text(
  //                   '${Heading} ',
  //                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
  //                 ),
  //               ],
  //             ),
  //             // Right Section: Dispatch Controller Value
  //             Text(
  //               "ReqNo_${uniqulastreqno}", // Replace with your controller
  //               style: const TextStyle(
  //                 fontSize: 13,
  //                 fontWeight: FontWeight.bold,
  //                 color: Color.fromARGB(255, 68, 67, 67),
  //               ),
  //             ),
  //           ],
  //         ),
  //         content: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               Message,
  //               style: TextStyle(fontSize: 13),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           ElevatedButton(
  //             onPressed: () async {
  //               await fetchLastRequestNo();
  //               await SharedPrefs.cleartockandreqno();

  //               Navigator.pop(context);
  //             },
  //             style: ElevatedButton.styleFrom(
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(2.0),
  //               ),
  //               backgroundColor: color,
  //               minimumSize: const Size(30.0, 28.0),
  //             ),
  //             child: const Text(
  //               'Ok',
  //               style: TextStyle(color: Colors.white, fontSize: 12),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
