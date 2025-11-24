import 'dart:ui' as ui;

import 'dart:typed_data'; // for Uint8List
import 'dart:io'; // for File
import 'package:aljeflutterapp/Reports/newtabledesign.dart';
import 'package:aljeflutterapp/components/constaints.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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
import 'dart:math' as math;

// Model class for register details.
class shipmentDetail {
  final Map<String, dynamic> _data;

  shipmentDetail(this._data);

  // Factory constructor to create an instance from JSON
  factory shipmentDetail.fromJson(Map<String, dynamic> json) {
    // Convert all keys to lowercase for case-insensitive access
    Map<String, dynamic> lowercaseMap = {};
    json.forEach((key, value) {
      lowercaseMap[key.toLowerCase()] = value;
    });
    return shipmentDetail(lowercaseMap);
  }

  // Generic getter to access any field case-insensitively
  dynamic get(String field) {
    var value = _data[field.toLowerCase()];

    // Handle numeric conversions
    if (value != null) {
      if (field.toLowerCase().contains('qty') ||
          field.toLowerCase().contains('amount') ||
          field.toLowerCase().contains('cost')) {
        return double.tryParse(value.toString()) ?? 0.0;
      }
    }

    return value ?? '';
  }

  @override
  String toString() {
    return _data.toString();
  }
}

class ShipmentTablePage extends StatefulWidget {
  final String? transfertype;
  final String? columnName;
  final Function togglePage;

  const ShipmentTablePage({
    required this.transfertype,
    required this.columnName,
    required this.togglePage,
    super.key,
  });
  @override
  State<ShipmentTablePage> createState() => _ShipmentTablePageState();
}

class _ShipmentTablePageState extends State<ShipmentTablePage> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  List<String> columnHeaders = [];
  List<shipmentDetail> tableData = [];
  bool isLoading = true;
  String errorMessage = '';
  Map<String, double> columnWidths = {};
  int _currentPage = 1;
  int _rowsPerPage = 10;
  int get _startIndex => (_currentPage - 1) * _rowsPerPage;
  int get _endIndex => math.min(_startIndex + _rowsPerPage, tableData.length);
  int get _totalPages => (tableData.length / _rowsPerPage).ceil();

  @override
  void initState() {
    super.initState();
    print("columnNamennnnn ${widget.columnName}");
    fetchColumnHeaders(widget.columnName);
    fetchAccessControl();
  }

  @override
  void didUpdateWidget(ShipmentTablePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.columnName != widget.columnName
        // oldWidget.columnValue != widget.columnValue ||
        // oldWidget.fromDate != widget.fromDate ||
        // oldWidget.endDate != widget.endDate

        ) {
      fetchData();
      fetchDatadetails();
    }
  }

  // Calculate the width needed for a text
  double _calculateTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection:
          ui.TextDirection.ltr, // Use ui.TextDirection to avoid ambiguity
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.width;
  }

  // Calculate column widths based on content
  void _calculateColumnWidths() {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    const cellStyle = TextStyle(
      fontSize: 13,
    );

    // Initialize with header widths
    for (String header in columnHeaders) {
      double headerWidth = _calculateTextWidth(header, headerStyle);
      // Increase minimum width for longer headers
      double minWidth = header.length > 15 ? 180.0 : 120.0;
      columnWidths[header] = math.max(
          headerWidth + 40, minWidth); // Increased padding and minimum width
    }

    // Check content widths
    for (var row in tableData) {
      for (String header in columnHeaders) {
        String cellValue = getCellValue(row, header);
        double contentWidth = _calculateTextWidth(cellValue, cellStyle);
        double currentWidth = columnWidths[header] ?? 0;
        columnWidths[header] = math.max(currentWidth, contentWidth + 40);
      }
    }

    // Set minimum and maximum constraints with special handling for long headers
    columnWidths.forEach((key, value) {
      double minWidth = key.length > 15 ? 180.0 : 120.0;
      columnWidths[key] = math.min(
          math.max(value, minWidth), 350.0); // Increased max width to 350
    });
  }

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateFormat("dd-MMM-yyyy").parse(date);
      return DateFormat("yyyy-MM-dd").format(parsedDate);
    } catch (e) {
      return date; // Return original if parsing fails
    }
  }

  Future<void> fetchColumnHeaders(String? invoicestatus) async {
    print("invoice status ${widget.columnName}");

    final IpAddress = await getActiveIpAddress();

    final columnUrl = Uri.parse('$IpAddress/GetShipmentTableHeadersView/');

    try {
      final response = await http.get(columnUrl);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          throw Exception("Column names list is empty.");
        }

        setState(() {
          columnHeaders = data.cast<String>();
          isLoading = false;
        });

        // After getting columns, fetch the data
        await fetchData();

        fetchDatadetails();
      } else {
        throw Exception(
            'Failed to load column headers. Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching column headers: $e';
        isLoading = false;
      });
      print(errorMessage);
    }
  }

  Future<void> fetchData() async {
    print("Fetching All Data with:");

    // print("invoicestatus Name: ${widget.invoicestatus}");
    // print("Column Name: ${widget.columnName}");
    // print("Column Value: ${widget.columnValue}");
    // print("From Date: ${widget.fromDate}");
    // print("End Date: ${widget.endDate}");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String salesloginrole = prefs.getString('salesloginrole') ?? '';
    String salesloginno = (salesloginrole == 'Salesman')
        ? (prefs.getString('salesloginno') ?? '')
        : '';
    print("Salesman No : $salesloginno");
    String saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename') ?? '';

    // String fromdatefinal = '${widget.fromDate}';
    // String formattedfromdate = formatDate(fromdatefinal);

    // String enddatefinal = '${widget.endDate}';
    // String formattedenddate = formatDate(enddatefinal);
    // print("formattedfromdate: ${formattedfromdate} ${formattedenddate}");

    final IpAddress = await getActiveIpAddress();

    String apiUrl =
        "$IpAddress/Shipment_detialsView/${widget.transfertype}/${widget.columnName}/$saleslogiOrgwarehousename/";
    List<shipmentDetail> allData = [];

    print("irlsssss $apiUrl");

    try {
      while (apiUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(apiUrl));

        print("Fetching from URL: $apiUrl");

        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
          final jsonResponse = json.decode(decodedBody);
          List<dynamic> results = jsonResponse['results'] ?? [];

          allData.addAll(
              results.map((item) => shipmentDetail.fromJson(item)).toList());

          // Check if there is a next page
          apiUrl = jsonResponse['next'] ?? "";
        } else {
          throw Exception(
              "Failed to load data, status code: ${response.statusCode}");
        }
      }

      setState(() {
        tableData = allData;
        _calculateColumnWidths();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
      print("Error fetching data: $e");
    }
  }

  Future<void> fetchDatadetails() async {
    print("Fetching All Data...");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String salesloginrole = prefs.getString('salesloginrole') ?? '';
    String salesloginno = (salesloginrole == 'Salesman')
        ? (prefs.getString('salesloginno') ?? '')
        : '';

    String saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename') ?? '';
    print("Salesman No : $salesloginno");

    final IpAddress = await getActiveIpAddress();

    String apiUrl =
        "$IpAddress/Shipment_detialsView/${widget.transfertype}/${widget.columnName}/$saleslogiOrgwarehousename/";
    List<shipmentDetail> allData = [];
    Set<String> seenUniqueIds = {};

    bool shipmentNumSet = false;
    bool receiptNumSet = false;
    bool shipmentdateNumSet = false;
    bool fromorgcodeNumSet = false;
    bool fromorgnameNumSet = false;
    bool toorgcodeNumSet = false;
    bool toorgnameNumSet = false;

    print("Initial API URL: $apiUrl");

    try {
      while (apiUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(apiUrl));
        print("Fetching from URL: $apiUrl");

        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
          final jsonResponse = json.decode(decodedBody);
          List<dynamic> results = jsonResponse['results'] ?? [];

          for (var item in results) {
            // Build a unique key (e.g. shipment_num + receipt_num)
            String uniqueKey = "${item['shipment_num']}-${item['receipt_num']}";

            if (!seenUniqueIds.contains(uniqueKey)) {
              seenUniqueIds.add(uniqueKey);

              final detail = shipmentDetail.fromJson(item);
              allData.add(detail);

              if (!shipmentNumSet && item['shipment_num'] != null) {
                ShipmentNumberController.text = item['shipment_num'].toString();
                shipmentNumSet = true;
                print("Set shipment_num: ${item['shipment_num']}");
              }

              if (!receiptNumSet && item['receipt_num'] != null) {
                ReceiptNumberController.text = item['receipt_num'].toString();
                receiptNumSet = true;
                print("Set receipt_num: ${item['receipt_num']}");
              }

              if (!shipmentdateNumSet && item['sh_creation_date'] != null) {
                ShipmentDateController.text =
                    item['sh_creation_date'].toString();
                shipmentdateNumSet = true;
                print("Set sh_creation_date: ${item['sh_creation_date']}");
              }

              if (!fromorgcodeNumSet && item['from_orgn_code'] != null) {
                FromOrgCodeController.text = item['from_orgn_code'].toString();
                fromorgcodeNumSet = true;
                print("Set from_orgn_code: ${item['from_orgn_code']}");
              }

              if (!fromorgnameNumSet && item['from_orgn_name'] != null) {
                FromOrgNameController.text = item['from_orgn_name'].toString();
                fromorgnameNumSet = true;
                print("Set from_orgn_name: ${item['from_orgn_name']}");
              }

              if (!toorgcodeNumSet && item['to_orgn_code'] != null) {
                ToOrgCodeController.text = item['to_orgn_code'].toString();
                toorgcodeNumSet = true;
                print("Set to_orgn_code: ${item['to_orgn_code']}");
              }

              if (!toorgnameNumSet && item['to_orgn_name'] != null) {
                ToOrgNameController.text = item['to_orgn_name'].toString();
                toorgnameNumSet = true;
                print("Set to_orgn_name: ${item['to_orgn_name']}");
              }
            } else {
              print("Duplicate record skipped: $uniqueKey");
            }
          }

          // Follow the pagination
          apiUrl = jsonResponse['next']?.toString() ?? "";
        } else {
          throw Exception(
              "Failed to load data, status code: ${response.statusCode}");
        }
      }

      setState(() {
        // tableData = allData;
        // _calculateColumnWidths();
        // isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
      print("Error fetching data: $e");
    }
  }

  // Future<void> fetchData() async {
  //   print("Fetching All Data with:");

  //   // print("invoicestatus Name: ${widget.invoicestatus}");
  //   // print("Column Name: ${widget.columnName}");
  //   // print("Column Value: ${widget.columnValue}");
  //   // print("From Date: ${widget.fromDate}");
  //   // print("End Date: ${widget.endDate}");
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String salesloginrole = prefs.getString('salesloginrole') ?? '';
  //   String salesloginno = (salesloginrole == 'Salesman')
  //       ? (prefs.getString('salesloginno') ?? '')
  //       : '';
  //   print("Salesman No : $salesloginno");

  //   // String fromdatefinal = '${widget.fromDate}';
  //   // String formattedfromdate = formatDate(fromdatefinal);

  //   // String enddatefinal = '${widget.endDate}';
  //   // String formattedenddate = formatDate(enddatefinal);
  //   // print("formattedfromdate: ${formattedfromdate} ${formattedenddate}");

  //   final IpAddress = await getActiveIpAddress();

  //   String apiUrl =
  //       "$IpAddress/Shipment_detialsView/${widget.transfertype}/${widget.columnName}/";
  //   List<shipmentDetail> allData = [];

  //   print("irlsssss $apiUrl");

  //   try {
  //     while (apiUrl.isNotEmpty) {
  //       final response = await http.get(Uri.parse(apiUrl));

  //       print("Fetching from URL: $apiUrl");

  //       if (response.statusCode == 200) {
  //         final jsonResponse = json.decode(response.body);
  //         List<dynamic> results = jsonResponse['results'] ?? [];

  //         allData.addAll(
  //             results.map((item) => shipmentDetail.fromJson(item)).toList());

  //         // Check if there is a next page
  //         apiUrl = jsonResponse['next'] ?? "";
  //       } else {
  //         throw Exception(
  //             "Failed to load data, status code: ${response.statusCode}");
  //       }
  //     }

  //     setState(() {
  //       tableData = allData;
  //       _calculateColumnWidths();
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       errorMessage = 'Error fetching data: $e';
  //       isLoading = false;
  //     });
  //     print("Error fetching data: $e");
  //   }
  // }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
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

  Widget _buildTextFieldDesktop(
    double desktopviewwidth,
    double mobileviewwidth,
    String label,
    String value,
    IconData icon,
    bool readonly,
  ) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        width: Responsive.isDesktop(context)
            ? screenWidth * desktopviewwidth
            : screenWidth * mobileviewwidth,
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
                      readOnly: readonly,
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

  TextEditingController ShipmentNumberController = TextEditingController();
  TextEditingController ReceiptNumberController = TextEditingController();

  TextEditingController ShipmentDateController = TextEditingController();

  TextEditingController FromOrgCodeController = TextEditingController();

  TextEditingController FromOrgNameController = TextEditingController();

  TextEditingController ToOrgCodeController = TextEditingController();

  TextEditingController ToOrgNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double totalWidth = columnHeaders.fold<double>(
      0,
      (sum, header) => sum + (columnWidths[header] ?? 120),
    );

    return Container(
      height: Responsive.isDesktop(context) ? 500 : 760,
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            children: [
              _buildTextFieldDesktop(0.08, 0.4, 'Shipment Num',
                  "${ShipmentNumberController.text}", Icons.numbers, true),
              SizedBox(
                width: 10,
              ),
              _buildTextFieldDesktop(0.08, 0.4, 'Receipt Num',
                  "${ReceiptNumberController.text}", Icons.numbers, true),
              SizedBox(
                width: 10,
              ),
              _buildTextFieldDesktop(0.08, 0.4, 'Shipment Date',
                  "${ShipmentDateController.text}", Icons.numbers, true),
              SizedBox(
                width: 10,
              ),
              _buildTextFieldDesktop(0.08, 0.4, 'From Org Code',
                  "${FromOrgCodeController.text}", Icons.numbers, true),
              SizedBox(
                width: 10,
              ),
              _buildTextFieldDesktop(0.17, 0.4, 'From Org Name',
                  "${FromOrgNameController.text}", Icons.numbers, true),
              SizedBox(
                width: 10,
              ),
              _buildTextFieldDesktop(0.08, 0.4, 'To Org Code',
                  "${ToOrgCodeController.text}", Icons.numbers, true),
              SizedBox(
                width: 10,
              ),
              _buildTextFieldDesktop(0.17, 0.4, 'To Org Name',
                  "${ToOrgNameController.text}", Icons.numbers, true),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: RawScrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 9,
              thumbColor: const ui.Color.fromARGB(255, 103, 103, 103),
              trackColor:
                  const ui.Color.fromARGB(255, 78, 78, 78).withOpacity(0.2),
              radius: const Radius.circular(8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalController,
                child: Container(
                  width: totalWidth + 18,
                  decoration: BoxDecoration(
                    color: const ui.Color.fromARGB(255, 248, 248, 248),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage.isNotEmpty
                          ? Center(child: Text(errorMessage))
                          : _buildDesktopView(context, tableData),
                ),
              ),
            ),
          ),
          // Fixed Pagination Controls
          Container(
            width: MediaQuery.of(context).size.width,
            child: Responsive.isMobile(context)
                ? Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        child: buttincontainer(),
                      ),
                      Responsive.isMobile(context)
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: pagepagination())
                          : pagepagination()
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buttincontainer(),
                      Responsive.isMobile(context)
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: pagepagination())
                          : pagepagination()
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget buttincontainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: ElevatedButton.icon(
            // onPressed: () async {

            //   print("widget.columnName  ${widget.columnName}");
            //   String shipmentId = widget.columnName.toString();

            //   if (shipmentId != null) {
            //     await widget.togglePage(
            //         shipmentId); // This will trigger MainSidebar change

            //     print("shipmentId shipmentId : $shipmentId");
            //   }
            //   await SaveShipmentid(shipmentId);
            //   print("Search clicked with: $shipmentId");
            // },

            onPressed: () async {
              String transfertype = widget.transfertype.toString();
              String shipmentId = widget.columnName.toString();
              print("widget.columnName: $shipmentId");
              final IpAddress = await getActiveIpAddress();

              if (shipmentId.isNotEmpty) {
                final url = Uri.parse(
                    "$IpAddress/GET_Shipment_Interorg/$transfertype/$shipmentId/");

                try {
                  final response = await http.get(url);

                  if (response.statusCode == 200) {
                    final List<dynamic> data = json.decode(response.body);

                    if (data.isNotEmpty) {
                      // Proceed if data exists
                      await widget.togglePage(shipmentId);
                      await SaveShipmentid(shipmentId);

                      await SaveShipmentid(shipmentId);

                      await SaveTransfertype(transfertype);

                      await SaveTransfertype(transfertype);
                      print("Search clicked with: $shipmentId  $transfertype");
                    } else {
                      // Show warning dialog if no data
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Dialog(
                          insetPadding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width *
                                0.1, // 10% padding on sides
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 8,
                          backgroundColor: Colors.white,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 400, // Maximum width for larger screens
                              minWidth:
                                  280, // Minimum width for smaller screens
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Icon with gradient
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.orange.shade700,
                                          Colors.orange.shade400,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.warning_amber_rounded,
                                      size: 36,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Title
                                  const Text(
                                    "Warning",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Content
                                  const Text(
                                    "There is no data for shipment dispatch.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                      height: 1.4,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange.shade600,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        elevation: 2,
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text(
                                        "OK",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  } else {
                    print("Server error: ${response.statusCode}");
                  }
                } catch (e) {
                  print("Error fetching shipment data: $e");
                }
              } else {
                print("Shipment ID is empty.");
              }
              postLogData(
                  "Inter ORG Transfer", "${transfertype} Load Transfer");
            },
            icon: Icon(Icons.train_outlined, color: Colors.white),
            label: Text(
              'Load Transfer',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget pagepagination() {
    return Row(
      children: [
        Container(
          width: 430,
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.first_page),
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() {
                            _currentPage = 1;
                          });
                        }
                      : null,
                  color: _currentPage > 1 ? Colors.blue : Colors.grey,
                ),
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() {
                            _currentPage--;
                          });
                        }
                      : null,
                  color: _currentPage > 1 ? Colors.blue : Colors.grey,
                ),
                SizedBox(width: 16),
                Text(
                  'Page $_currentPage of $_totalPages',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: _currentPage < _totalPages
                      ? () {
                          setState(() {
                            _currentPage++;
                          });
                        }
                      : null,
                  color: _currentPage < _totalPages ? Colors.blue : Colors.grey,
                ),
                IconButton(
                  icon: Icon(Icons.last_page),
                  onPressed: _currentPage < _totalPages
                      ? () {
                          setState(() {
                            _currentPage = _totalPages;
                          });
                        }
                      : null,
                  color: _currentPage < _totalPages ? Colors.blue : Colors.grey,
                ),
                SizedBox(width: 24),
                DropdownButton<int>(
                  value: _rowsPerPage,
                  items: [10, 15, 20, 30, 50].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value rows'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _rowsPerPage = newValue;
                        _currentPage = 1;
                      });
                    }
                  },
                ),
                SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> SaveShipmentid(String SaveShipmentid) async {
    await SharedPrefs.SaveShipmentid(SaveShipmentid);
  }

  Future<void> SaveTransfertype(String SaveTransfertype) async {
    await SharedPrefs.SaveTransfertype(SaveTransfertype);
  }

  Widget _buildDesktopView(BuildContext context, List<shipmentDetail> data) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: columnHeaders.map((header) {
                return Container(
                  width: columnWidths[header] ?? 120,
                  height: 35,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    header,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                );
              }).toList(),
            ),
          ),
          // Table Content
          Expanded(
            child: RawScrollbar(
              controller: _verticalController,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 9,
              thumbColor: const ui.Color.fromARGB(255, 103, 103, 103),
              trackColor:
                  const ui.Color.fromARGB(255, 78, 78, 78).withOpacity(0.2),
              radius: const Radius.circular(8),
              child: SingleChildScrollView(
                controller: _verticalController,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _buildDataRows(context, data),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRows(BuildContext context, List<shipmentDetail> data) {
    // Get only the data for the current page
    final paginatedData = data.sublist(_startIndex, _endIndex);

    return Column(
      children: [
        Table(
          columnWidths: Map.fromEntries(
            columnHeaders.asMap().entries.map(
                  (entry) => MapEntry(
                    entry.key,
                    FixedColumnWidth(columnWidths[entry.value] ?? 120),
                  ),
                ),
          ),
          children: paginatedData.asMap().entries.map((entry) {
            int index = entry.key;
            shipmentDetail detail = entry.value;
            Color rowColor = index % 2 == 0
                ? Colors.white
                : const Color.fromARGB(255, 255, 255, 255);

            return TableRow(
              decoration: BoxDecoration(color: rowColor),
              children: columnHeaders.map((header) {
                String cellValue = getCellValue(detail, header);
                cellValue = (cellValue == null || cellValue.trim().isEmpty)
                    ? '0'
                    : cellValue;

                return Container(
                  height: 33,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade300),
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    cellValue,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ],
    );
  }

// Function to get cell value dynamically
  String getCellValue(shipmentDetail detail, String header) {
    var value = detail.get(header);

    // Convert the value to string, handling different types
    if (value is double) {
      return value.toString();
    } else if (value is int) {
      return value.toString();
    } else if (value is String) {
      return value;
    } else if (value == null) {
      return '';
    }

    return value.toString();
  }
}
