import 'dart:io'; // for File
import 'package:aljeflutterapp/Reports/Inter_ORG_Report/Inter_Org_controllers.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:path_provider/path_provider.dart'; // for getApplicationDocumentsDirectory
import 'dart:ui';

import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_svg/svg.dart';

class ExportReport extends StatefulWidget {
  const ExportReport({super.key});

  @override
  State<ExportReport> createState() => _ExportReportState();
}

class _ExportReportState extends State<ExportReport> {
  TextEditingController ShipmentNoController = TextEditingController();
  TextEditingController ShipmentLineidController = TextEditingController();
  TextEditingController searchReqNoController = TextEditingController();
  List<Map<String, dynamic>> InterORGPendingDetailstabledata =
      []; // List to store fetched data

  List<Map<String, dynamic>> InterORGCompletedDetailstabledata =
      []; // List to store fetched data

  List<Map<String, dynamic>> InterORGTransferDetailstabledata =
      []; // List to store fetched data
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchInvoicedetailsData('alldata');
    // fetchInvoiceCompleteddetailsData();

    // fetchInterORGTransferdetailsData();

    postLogData("Inter ORG Report", "Opened");
  }

  @override
  void dispose() {
    super.dispose();
    postLogData("Inter ORG Report", "Closed");
  }

  Future<void> fetchInvoicedetailsData(String Exporttype) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String salesmanno = prefs.getString('salesloginno') ?? 'Unknown ID';
    String salesloginrole = prefs.getString('salesloginrole') ?? 'Unknown ID';
    final selectedFromDateStr = _FromdateController.text.trim();
    final selectedEndDateStr = _EnddateController.text.trim();

    String shipmentid = ShipmentNoController.text.trim();
    String shipmentlineid = ShipmentLineidController.text.trim();

    String ShipmentNum = shipmentlineid.isEmpty
        ? (shipmentid.isEmpty ? '' : "?shipmentnum=$shipmentid")
        : '?shipmentlineid=$shipmentlineid';

    String finalstring = Exporttype == 'shipment_num' ? ShipmentNum : '';

    final IpAddress = await getActiveIpAddress();

    // Construct first URL (add ? or & properly)
    String nextUrl = '$IpAddress/InterORGReportView/$finalstring';

    List<Map<String, dynamic>> allData = [];

    print("Start fetching paginated data...  $Exporttype $nextUrl");

    try {
      while (nextUrl.isNotEmpty && nextUrl != "null") {
        print("Fetching page: $nextUrl");
        final response = await http.get(Uri.parse(nextUrl));

        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
          final decoded = json.decode(decodedBody);

          if (decoded is Map<String, dynamic> &&
              decoded.containsKey('results')) {
            allData.addAll(List<Map<String, dynamic>>.from(decoded['results']));

            // Update next URL
            nextUrl = decoded['next']?.toString() ?? '';
          } else {
            print("Unexpected format. 'results' key not found.");
            break;
          }
        } else {
          print("HTTP error ${response.statusCode}");
          break;
        }
      }

      setState(() {
        InterORGPendingDetailstabledata = allData;
        isLoading = false;
      });

      print("✅ All pages fetched. Total records: ${allData.length}");
    } catch (e) {
      print("❌ Error while fetching data: $e");
    } finally {
      // Navigator.of(context).pop(); // Close loading dialog
    }
  }

  Future<void> fetchInvoiceCompleteddetailsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String salesmanno = prefs.getString('salesloginno') ?? 'Unknown ID';
    String salesloginrole = prefs.getString('salesloginrole') ?? 'Unknown ID';
    String shipmentid = ShipmentNoController.text.trim();

    String shipmentlineid = ShipmentLineidController.text.trim();

    String ShipmentNum = shipmentlineid.isEmpty
        ? (shipmentid.isEmpty ? '' : "?shipmentnum=$shipmentid")
        : '?shipmentlineid=$shipmentlineid';
    final IpAddress = await getActiveIpAddress();

    // Construct first URL (add ? or & properly)
    String nextUrl = '$IpAddress/InterORGReportCompletedView/$ShipmentNum';

    List<Map<String, dynamic>> allData = [];

    print("Start fetching paginated data... $nextUrl");

    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       content: Row(
    //         children: [
    //           CircularProgressIndicator(),
    //           SizedBox(width: 20),
    //           Text("Processing... Kindly wait"),
    //         ],
    //       ),
    //     );
    //   },
    // );

    try {
      while (nextUrl.isNotEmpty && nextUrl != "null") {
        print("Fetching page: $nextUrl");
        final response = await http.get(Uri.parse(nextUrl));

        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
          final decoded = json.decode(decodedBody);

          if (decoded is Map<String, dynamic> &&
              decoded.containsKey('results')) {
            allData.addAll(List<Map<String, dynamic>>.from(decoded['results']));

            // Update next URL
            nextUrl = decoded['next']?.toString() ?? '';
          } else {
            print("Unexpected format. 'results' key not found.");
            break;
          }
        } else {
          print("HTTP error ${response.statusCode}");
          break;
        }
      }

      setState(() {
        InterORGCompletedDetailstabledata = allData;
        // isLoading = false;
      });

      print("✅ All pages fetched. Total records: ${allData.length}");
    } catch (e) {
      print("❌ Error while fetching data: $e");
    } finally {
      // Navigator.of(context).pop(); // Close loading dialog
    }
  }

  String formatDateForApi(String inputDate) {
    try {
      // Parse from "dd-MMM-yyyy"
      DateTime parsedDate = DateFormat("dd-MMM-yyyy").parse(inputDate);

      // Convert to "yyyy-MM-dd"
      return DateFormat("yyyy-MM-dd").format(parsedDate);
    } catch (e) {
      print("Invalid date format: $e");
      return inputDate; // fallback to original if parsing fails
    }
  }

  Future<void> fetchInterORGTransferdetailsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String salesmanno = prefs.getString('salesloginno') ?? 'Unknown ID';
    String salesloginrole = prefs.getString('salesloginrole') ?? 'Unknown ID';
    String shipmentid = ShipmentNoController.text.trim();
    print("from date ${_FromdateController.text}");

    print("end date ${_EnddateController.text}");
// Example usage:
    String fromdate = _FromdateController.text.trim();
    String enddate = _EnddateController.text.trim();

    String apiFromDate = formatDateForApi(fromdate);
    String apiEndDate = formatDateForApi(enddate);

    String shipmentlineid = ShipmentLineidController.text.trim();

    String ShipmentNum = shipmentlineid.isEmpty
        ? (shipmentid.isEmpty ? '' : "&shipmentnum=$shipmentid")
        : '&shipmentlineid=$shipmentlineid';
    final IpAddress = await getActiveOracleIpAddress();

    // Construct first URL (add ? or & properly)
    String nextUrl =
        '$IpAddress/InterORG_Shipment_transferdView/?from_date=$apiFromDate&to_date=$apiEndDate$ShipmentNum';

    List<Map<String, dynamic>> allData = [];

    print("Start fetching paginated data... $nextUrl");

    try {
      while (nextUrl.isNotEmpty && nextUrl != "null") {
        print("Fetching page: $nextUrl");
        final response = await http.get(Uri.parse(nextUrl));

        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
          final decoded = json.decode(decodedBody);

          if (decoded is Map<String, dynamic> &&
              decoded.containsKey('results')) {
            allData.addAll(List<Map<String, dynamic>>.from(decoded['results']));

            // Update next URL
            nextUrl = decoded['next']?.toString() ?? '';
          } else {
            print("Unexpected format. 'results' key not found.");
            break;
          }
        } else {
          print("HTTP error ${response.statusCode}");
          break;
        }
      }

      setState(() {
        InterORGTransferDetailstabledata = allData;
        // isLoading = false;
      });

      print("✅ All pages fetched. Total records: ${allData.length}");
    } catch (e) {
      print("❌ Error while fetching data: $e");
    } finally {
      // Navigator.of(context).pop(); // Close loading dialog
    }
  }

  TextEditingController _FromdateController = TextEditingController(
      text: DateFormat('dd-MMM-yyyy').format(DateTime.now()));

  TextEditingController _EnddateController = TextEditingController(
      text: DateFormat('dd-MMM-yyyy').format(DateTime.now()));
// Function to show the date picker and set the selected from-date
  Future<void> _selectfromDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      // Format the selected date as 'yyyy-MM-dd'
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _FromdateController.text = formattedDate;
        changefromdate = true;
      });
    }
  }

// Function to show the date picker and set the selected to-date
  Future<void> _selectendDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      // Format the selected date as 'yyyy-MM-dd'
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _EnddateController.text = formattedDate;
        changeenddate = true;
      });
    }
  }

  bool changefromdate = false;

  bool changeenddate = false;

  List<String> ExportedList = [
    "Inter ORG Completed Report",
    "Inter ORG Pending Report",
    "Inter ORG Transfer Report",
  ];

  bool _filterEnabledexported = true;
  int? _hoveredIndexExported;
  int? _selectedIndexExported;

  String? ExportedSelectedValue;
  FocusNode ExportedFocusNode = FocusNode();

  TextEditingController ExportedController = TextEditingController();
  Widget _buildSearchExportedDropdown() {
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
                          ? screenWidth * 0.11
                          : screenWidth * 0.4,
                      child: ExportedReportDropdown()),
                ],
              ),
            ),
            SizedBox(width: 3),
          ],
        ),
      ),
    );
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget ExportedReportDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex = ExportedList.indexOf(ExportedController.text);
            if (currentIndex < ExportedList.length - 1) {
              setState(() {
                _selectedIndexExported = currentIndex + 1;
                // Take only the customer number part before the colon
                ExportedController.text =
                    ExportedList[currentIndex + 1].split(':')[0];
                _filterEnabledexported = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = ExportedList.indexOf(ExportedController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndexExported = currentIndex - 1;
                // Take only the customer number part before the colon
                ExportedController.text =
                    ExportedList[currentIndex - 1].split(':')[0];
                _filterEnabledexported = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: ExportedFocusNode,
          controller: ExportedController,
          onSubmitted: (String? suggestion) async {
            fromdatebool = false;
            Todatebool = false;
            Exportbuttonbool = false;
            setState(() {
              _FromdateController.text =
                  DateFormat('dd-MMM-yyyy').format(DateTime.now());
              _EnddateController.text =
                  DateFormat('dd-MMM-yyyy').format(DateTime.now());
              if (ExportedController.text == 'Inter ORG Completed Report') {
                Exportbuttonbool = true;
              } else if (ExportedController.text ==
                  'Inter ORG Pending Report') {
                Exportbuttonbool = true;
              } else if (ExportedController.text ==
                  'Inter ORG Transfer Report') {
                fromdatebool = true;
                Todatebool = true;
                Exportbuttonbool = true;
              }
            });
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
              _filterEnabledexported = true;
              ExportedSelectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabledexported && pattern.isNotEmpty) {
            return ExportedList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return ExportedList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = ExportedList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndexExported = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndexExported = null;
            }),
            child: Container(
              color: _selectedIndexExported == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndexExported == null &&
                          ExportedList.indexOf(ExportedController.text) == index
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
          constraints: BoxConstraints(maxHeight: 200),
        ),
        onSuggestionSelected: (suggestion) {
          setState(() {
            _selectedIndexExported = ExportedList.indexOf(suggestion);
            // Take only the customer number part before the colon
            ExportedController.text = suggestion.split(':')[0];
            ExportedSelectedValue = suggestion;
            _filterEnabledexported = false;
          });
          fromdatebool = false;
          Todatebool = false;
          Exportbuttonbool = false;
          setState(() {
            _FromdateController.text =
                DateFormat('dd-MMM-yyyy').format(DateTime.now());
            _EnddateController.text =
                DateFormat('dd-MMM-yyyy').format(DateTime.now());
            if (ExportedController.text == 'Inter ORG Completed Report') {
              Exportbuttonbool = true;
            } else if (ExportedController.text == 'Inter ORG Pending Report') {
              Exportbuttonbool = true;
            } else if (ExportedController.text == 'Inter ORG Transfer Report') {
              fromdatebool = true;
              Todatebool = true;
              Exportbuttonbool = true;
            }
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

  bool fromdatebool = false;
  bool Todatebool = false;
  bool Exportbuttonbool = false;

  @override
  Widget build(BuildContext context) {
    Offset _tapPosition = Offset.zero;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    final controller = Provider.of<Inter_Org_Controller>(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 20),
          child: Row(
            children: [
              Container(
                width: Responsive.isDesktop(context)
                    ? screenWidth * 0.12
                    : screenWidth * 0.4,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Row(
                          children: [
                            Row(
                              children: [
                                Text("", style: textboxheading),
                                SizedBox(width: 8),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 0, bottom: 0),
                        child: Container(
                          height: 32,
                          child: TextField(
                            controller: searchReqNoController,
                            decoration: const InputDecoration(
                              hintText: 'Enter dispatch No',
                              border: OutlineInputBorder(),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                            ),
                            onChanged: (value) {
                              setState(() {
                                changefromdate = false;

                                changeenddate = false;
                              });
                              controller.searchreqno(value);
                            },
                            style: textBoxstyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: Responsive.isDesktop(context)
                    ? screenWidth * 0.12
                    : screenWidth * 0.4,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Row(
                          children: [
                            Row(
                              children: [
                                Text("", style: textboxheading),
                                SizedBox(width: 8),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 0, bottom: 0),
                        child: Container(
                          height: 32,
                          child: TextField(
                            controller: ShipmentLineidController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter Shipment Line Id',
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                            ),
                            onChanged: (value) {
                              setState(() {
                                changefromdate = false;

                                changeenddate = false;
                              });
                              controller.searchshipmentlineid(value);
                            },
                            style: textBoxstyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: Responsive.isDesktop(context)
                    ? screenWidth * 0.12
                    : screenWidth * 0.4,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Row(
                          children: [
                            Row(
                              children: [
                                Text("", style: textboxheading),
                                SizedBox(width: 8),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 0, bottom: 0),
                        child: Container(
                          height: 32,
                          child: TextField(
                            controller: ShipmentNoController,
                            decoration: const InputDecoration(
                              hintText: 'Enter Shipment Num',
                              border: OutlineInputBorder(),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                            ),
                            onChanged: (value) {
                              setState(() {
                                changefromdate = false;

                                changeenddate = false;
                              });
                              controller.searchshipmentnum(value);
                            },
                            style: textBoxstyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: Responsive.isDesktop(context)
                    ? screenWidth * 0.11
                    : screenWidth * 0.4,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Row(
                          children: [
                            Row(
                              children: [
                                Text("Exported Reports", style: textboxheading),
                                SizedBox(width: 8),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 1),
                      Padding(
                        padding: const EdgeInsets.only(left: 0, bottom: 0),
                        child: Container(child: _buildSearchExportedDropdown()),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (fromdatebool)
                Container(
                  width: Responsive.isDesktop(context)
                      ? screenWidth * 0.09
                      : screenWidth * 0.4,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  Text("From date", style: textboxheading),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.star,
                                    size: 8,
                                    color: Colors.red,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 0, bottom: 0),
                          child: Container(
                            height: 32,
                            child: GestureDetector(
                              onTap: () => _selectfromDate(
                                  context), // Open the date picker when tapped
                              child: Container(
                                height: 32,
                                width: screenWidth * 0.1,
                                padding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color.fromARGB(255, 195, 228, 255),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.calendar_today,
                                        color: Colors.blue, size: 14),
                                    SizedBox(width: 10),
                                    Text(
                                      _FromdateController.text.isEmpty
                                          ? DateFormat('dd-MMM-yyyy')
                                              .format(DateTime.now())
                                          : _FromdateController
                                              .text, // Display the selected date
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (fromdatebool) SizedBox(width: 16),
              if (Todatebool)
                Container(
                  width: Responsive.isDesktop(context)
                      ? screenWidth * 0.09
                      : screenWidth * 0.4,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  Text("To date", style: textboxheading),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.star,
                                    size: 8,
                                    color: Colors.red,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 0, bottom: 0),
                          child: Container(
                            height: 32,
                            child: GestureDetector(
                              onTap: () => _selectendDate(
                                  context), // Open the date picker when tapped
                              child: Container(
                                height: 32,
                                width: screenWidth * 0.1,
                                padding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color.fromARGB(255, 195, 228, 255),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.calendar_today,
                                        color: Colors.blue, size: 14),
                                    SizedBox(width: 10),
                                    Text(
                                      _EnddateController.text.isEmpty
                                          ? DateFormat('dd-MMM-yyyy')
                                              .format(DateTime.now())
                                          : _EnddateController
                                              .text, // Display the selected date
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (Todatebool) SizedBox(width: 16),
              if (Exportbuttonbool)
                Container(
                  width: Responsive.isDesktop(context)
                      ? screenWidth * 0.07
                      : screenWidth * 0.4,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  Text("", style: textboxheading),
                                  SizedBox(width: 8),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 0, bottom: 0),
                          child: Container(
                            height: 32,
                            child: GestureDetector(
                              onTapDown: (details) =>
                                  _tapPosition = details.globalPosition,
                              onTap: () => _handleTap(context, _tapPosition),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: buttonColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/excel.svg',
                                      width: 18,
                                      height: 18,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Export',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
    );
  }

  // void _handleTap(BuildContext context, Offset tapPosition) async {
  //   String selected = ExportedController.text;
  //   if (ShipmentNoController.text.isNotEmpty &&
  //       ShipmentLineidController.text.isNotEmpty) {
  //     print(
  //         "ShipmentNo: ${ShipmentNoController.text}, LineID: ${ShipmentLineidController.text}");
  //     _showWarningDialog(context);
  //   } else {
  //     {
  //       if (selected == 'Inter ORG Completed Report') {
  //         if (changefromdate == true || changeenddate == true) {
  //           await fetchInvoicedetailsData('datefilered');
  //         } else {
  //           await fetchInvoicedetailsData('shipment_num');
  //         }
  //         if (InterORGPendingDetailstabledata.isNotEmpty) {
  //           List<String> columnHeaders =
  //               InterORGPendingDetailstabledata.first.keys.toList();
  //           List<List<dynamic>> convertedData =
  //               InterORGPendingDetailstabledata.map((map) {
  //             return columnHeaders.map((header) => map[header]).toList();
  //           }).toList();

  //           await createExcelinvoicedetails(columnHeaders, convertedData);
  //           postLogData("Inter ORG Report", "Export Inter ORG Pending Details");

  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('Inter ORG Pending Report exported successfully'),
  //               backgroundColor: Colors.green,
  //             ),
  //           );
  //         } else {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('There is no pending data under this Details...'),
  //               backgroundColor: Colors.red,
  //             ),
  //           );
  //         }
  //       } else if (selected == 'Inter ORG Pending Report') {
  //         await fetchInvoiceCompleteddetailsData();
  //         if (InterORGCompletedDetailstabledata.isNotEmpty) {
  //           List<String> columnHeaders =
  //               InterORGCompletedDetailstabledata.first.keys.toList();
  //           List<List<dynamic>> convertedData =
  //               InterORGCompletedDetailstabledata.map((map) {
  //             return columnHeaders.map((header) => map[header]).toList();
  //           }).toList();

  //           await createExcecreatedispatchlinvoicedetails(
  //               columnHeaders, convertedData);
  //           postLogData(
  //               "Inter ORG Report", "Export Inter ORG Completed Details");

  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content:
  //                   Text('Inter ORG Compleed Report exported successfully'),
  //               backgroundColor: Colors.green,
  //             ),
  //           );
  //         } else {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content:
  //                   Text('There is no completed data under this Details...'),
  //               backgroundColor: Colors.red,
  //             ),
  //           );
  //         }
  //       } else if (selected == 'Inter ORG Transfer Report') {
  //         await fetchInterORGTransferdetailsData();
  //         if (InterORGTransferDetailstabledata.isNotEmpty) {
  //           List<String> columnHeaders =
  //               InterORGTransferDetailstabledata.first.keys.toList();
  //           List<List<dynamic>> convertedData =
  //               InterORGTransferDetailstabledata.map((map) {
  //             return columnHeaders.map((header) => map[header]).toList();
  //           }).toList();

  //           await createExcecreateInterORGTransfer(
  //               columnHeaders, convertedData);
  //           postLogData(
  //               "Inter ORG Report", "Export Inter ORG Transfer Details");

  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content:
  //                   Text('Inter ORG Transfer Details exported successfully'),
  //               backgroundColor: Colors.green,
  //             ),
  //           );
  //         } else {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content:
  //                   Text('There is no completed data under this Details...'),
  //               backgroundColor: Colors.red,
  //             ),
  //           );
  //         }
  //       }
  //       postLogData("Inter ORG Report", "Export Button");
  //     }
  //   }
  // }

  void _handleTap(BuildContext context, Offset tapPosition) async {
    String selected = ExportedController.text;

    if (ShipmentNoController.text.isNotEmpty &&
        ShipmentLineidController.text.isNotEmpty) {
      print(
          "ShipmentNo: ${ShipmentNoController.text}, LineID: ${ShipmentLineidController.text}");
      _showWarningDialog(context);
      return;
    }

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Processing... Kindly wait"),
            ],
          ),
        );
      },
    );
    try {
      if (selected == 'Inter ORG Pending Report') {
        if (changefromdate == true || changeenddate == true) {
          await fetchInvoicedetailsData('datefilered');
        } else {
          await fetchInvoicedetailsData('shipment_num');
        }

        if (InterORGPendingDetailstabledata.isNotEmpty) {
          List<String> columnHeaders =
              InterORGPendingDetailstabledata.first.keys.toList();
          List<List<dynamic>> convertedData =
              InterORGPendingDetailstabledata.map((map) {
            return columnHeaders.map((header) => map[header]).toList();
          }).toList();

          await createExcelinvoicedetails(columnHeaders, convertedData);
          postLogData("Inter ORG Report", "Export Inter ORG Pending Details");

          Navigator.of(context).pop(); // Close dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inter ORG Pending Report exported successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          Navigator.of(context).pop(); // Close dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('There is no pending data under this Details...'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (selected == 'Inter ORG Completed Report') {
        await fetchInvoiceCompleteddetailsData();
        if (InterORGCompletedDetailstabledata.isNotEmpty) {
          List<String> columnHeaders =
              InterORGCompletedDetailstabledata.first.keys.toList();
          List<List<dynamic>> convertedData =
              InterORGCompletedDetailstabledata.map((map) {
            return columnHeaders.map((header) => map[header]).toList();
          }).toList();

          await createExcecreatedispatchlinvoicedetails(
              columnHeaders, convertedData);
          postLogData("Inter ORG Report", "Export Inter ORG Completed Details");

          Navigator.of(context).pop(); // Close dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inter ORG Completed Report exported successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          Navigator.of(context).pop(); // Close dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('There is no completed data under this Details...'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (selected == 'Inter ORG Transfer Report') {
        await fetchInterORGTransferdetailsData();
        if (InterORGTransferDetailstabledata.isNotEmpty) {
          List<String> columnHeaders =
              InterORGTransferDetailstabledata.first.keys.toList();
          List<List<dynamic>> convertedData =
              InterORGTransferDetailstabledata.map((map) {
            return columnHeaders.map((header) => map[header]).toList();
          }).toList();

          await createExcecreateInterORGTransfer(columnHeaders, convertedData);
          postLogData("Inter ORG Report", "Export Inter ORG Transfer Details");

          Navigator.of(context).pop(); // Close dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inter ORG Transfer Details exported successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          Navigator.of(context).pop(); // Close dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('There is no transfer data under this Details...'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      postLogData("Inter ORG Report", "Export Button");
    } catch (e) {
      Navigator.of(context).pop(); // Ensure dialog closes even on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error occurred: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Add this function outside your widget build method
  Future<void> _showWarningDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.amber),
              SizedBox(width: 8),
              Text('Warning!'),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Kindly clear the Any one field.'),
                Text('You cannot export while these two fields are filled.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> createExcecreatedispatchlinvoicedetails(
      List<String> columnNames, List<List<dynamic>> data) async {
    // print("dataaaaaaaaaaa $data");
    final Workbook workbook = Workbook();
    try {
      final Worksheet sheet = workbook.worksheets[0];

      // Get today's date in dd-MM-yyyy format
      final DateTime today = DateTime.now();
      final String formattedToday = DateFormat('dd-MMM-yyyy').format(today);

      // Main heading
      final Range titleRange = sheet.getRangeByIndex(1, 1);
      titleRange.setText('Inter ORG Report (Completed Datas)');
      titleRange.cellStyle
        ..fontSize = 16
        ..bold = true;
      titleRange.cellStyle.hAlign = HAlignType.left; // Left align title
      sheet.getRangeByIndex(1, 1, 1, columnNames.length).merge();

      // Subheading with date
      final Range subTitleRange = sheet.getRangeByIndex(3, 1);
      subTitleRange.setText('ALJE Inter ORG Reports As On : $formattedToday');
      subTitleRange.cellStyle
        ..fontSize = 12
        ..italic = true;
      subTitleRange.cellStyle.hAlign = HAlignType.left; // Left align subtitle
      sheet.getRangeByIndex(2, 1, 2, columnNames.length).merge();

      // Column headers at row 5
      for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
        final Range range = sheet.getRangeByIndex(5, colIndex + 1);
        range.setText(columnNames[colIndex]);
        range.cellStyle
          ..backColor = '#E7F3FD'
          ..fontColor = '#000000'
          ..bold = true
          ..borders.all.lineStyle = LineStyle.thin
          ..borders.all.color = '#000000'
          ..hAlign = HAlignType.left; // Left align headers
      }

      // Table data from row 6
      for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
        final List<dynamic> rowData = data[rowIndex];
        for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
          final Range range = sheet.getRangeByIndex(rowIndex + 6, colIndex + 1);
          final cellValue = rowData[colIndex];

          // Apply correct data type
          if (cellValue == null) {
            range.setText('');
          } else if (cellValue is num) {
            if (cellValue % 1 == 0) {
              // It's an integer
              range.setNumber(cellValue.toDouble());
              range.numberFormat = '0'; // Format for whole numbers
            } else {
              // It's a decimal number
              range.setNumber(cellValue.toDouble());
              range.numberFormat = '#,##0.00'; // Format for decimal numbers
            }
          } else if (cellValue is DateTime) {
            range.setDateTime(cellValue);
            range.numberFormat = 'DD-MMM-YYYY'; // Format for dates
          } else {
            range.setText(cellValue.toString());
          }

          // Apply styling
          range.cellStyle
            ..borders.all.lineStyle = LineStyle.thin
            ..borders.all.color = '#000000'
            ..hAlign = HAlignType.left; // Left align all data
        }
      }

      // Auto-fit columns
      for (int i = 1; i <= columnNames.length; i++) {
        sheet.autoFitColumn(i);
      }

      final List<int> bytes = workbook.saveAsStream();

      String timestamp = '$formattedToday Time '
          '${today.hour.toString().padLeft(2, '0')}hh-${today.minute.toString().padLeft(2, '0')}mm-${today.second.toString().padLeft(2, '0')}ss';
      if (kIsWeb) {
        final blob = base64.encode(bytes);
        AnchorElement(
          href: 'data:application/octet-stream;charset=utf-16le;base64,$blob',
        )
          ..setAttribute(
              'download', 'InterORG Completed details($timestamp).xlsx')
          ..click();
      } else {
        final String path = (await getApplicationSupportDirectory()).path;
        final String fileName = Platform.isWindows
            ? '$path\\Excel InterORG Completed details($timestamp).xlsx'
            : '$path/Excel InterORG Completed details($timestamp).xlsx';

        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);
        OpenFile.open(fileName);
      }
    } catch (e) {
      print('Error in createExcel: $e');
      rethrow;
    } finally {
      try {
        workbook.dispose();
      } catch (e) {
        print('Error disposing workbook: $e');
      }
    }
  }

  Future<void> createExcecreateInterORGTransfer(
      List<String> columnNames, List<List<dynamic>> data) async {
    // print("dataaaaaaaaaaa $data");
    final Workbook workbook = Workbook();
    try {
      final Worksheet sheet = workbook.worksheets[0];

      // Get today's date in dd-MM-yyyy format
      final DateTime today = DateTime.now();
      final String formattedToday = DateFormat('dd-MMM-yyyy').format(today);

      // Main heading
      final Range titleRange = sheet.getRangeByIndex(1, 1);
      titleRange.setText('Inter ORG Report (Transfer Datas)');
      titleRange.cellStyle
        ..fontSize = 16
        ..bold = true;
      titleRange.cellStyle.hAlign = HAlignType.left; // Left align title
      sheet.getRangeByIndex(1, 1, 1, columnNames.length).merge();

      // Subheading with date
      final Range subTitleRange = sheet.getRangeByIndex(3, 1);
      subTitleRange
          .setText('ALJE Inter ORG Transfer Details As On : $formattedToday');
      subTitleRange.cellStyle
        ..fontSize = 12
        ..italic = true;
      subTitleRange.cellStyle.hAlign = HAlignType.left; // Left align subtitle
      sheet.getRangeByIndex(2, 1, 2, columnNames.length).merge();

      // Column headers at row 5
      for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
        final Range range = sheet.getRangeByIndex(5, colIndex + 1);
        range.setText(columnNames[colIndex]);
        range.cellStyle
          ..backColor = '#E7F3FD'
          ..fontColor = '#000000'
          ..bold = true
          ..borders.all.lineStyle = LineStyle.thin
          ..borders.all.color = '#000000'
          ..hAlign = HAlignType.left; // Left align headers
      }

      // Table data from row 6
      for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
        final List<dynamic> rowData = data[rowIndex];
        for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
          final Range range = sheet.getRangeByIndex(rowIndex + 6, colIndex + 1);
          final cellValue = rowData[colIndex];

          // Apply correct data type
          if (cellValue == null) {
            range.setText('');
          } else if (cellValue is num) {
            if (cellValue % 1 == 0) {
              // It's an integer
              range.setNumber(cellValue.toDouble());
              range.numberFormat = '0'; // Format for whole numbers
            } else {
              // It's a decimal number
              range.setNumber(cellValue.toDouble());
              range.numberFormat = '#,##0.00'; // Format for decimal numbers
            }
          } else if (cellValue is DateTime) {
            range.setDateTime(cellValue);
            range.numberFormat = 'DD-MMM-YYYY'; // Format for dates
          } else {
            range.setText(cellValue.toString());
          }

          // Apply styling
          range.cellStyle
            ..borders.all.lineStyle = LineStyle.thin
            ..borders.all.color = '#000000'
            ..hAlign = HAlignType.left; // Left align all data
        }
      }

      // Auto-fit columns
      for (int i = 1; i <= columnNames.length; i++) {
        sheet.autoFitColumn(i);
      }

      final List<int> bytes = workbook.saveAsStream();

      String timestamp = '$formattedToday Time '
          '${today.hour.toString().padLeft(2, '0')}hh-${today.minute.toString().padLeft(2, '0')}mm-${today.second.toString().padLeft(2, '0')}ss';
      if (kIsWeb) {
        final blob = base64.encode(bytes);
        AnchorElement(
          href: 'data:application/octet-stream;charset=utf-16le;base64,$blob',
        )
          ..setAttribute(
              'download', 'InterORG Transfer details($timestamp).xlsx')
          ..click();
      } else {
        final String path = (await getApplicationSupportDirectory()).path;
        final String fileName = Platform.isWindows
            ? '$path\\Excel InterORG Transfer details($timestamp).xlsx'
            : '$path/Excel InterORG Transfer details($timestamp).xlsx';

        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);
        OpenFile.open(fileName);
      }
    } catch (e) {
      print('Error in createExcel: $e');
      rethrow;
    } finally {
      try {
        workbook.dispose();
      } catch (e) {
        print('Error disposing workbook: $e');
      }
    }
  }

  Future<void> createExcelinvoicedetails(
      List<String> columnNames, List<List<dynamic>> data) async {
    // print("dataaaaaaaaaaa $data");
    final Workbook workbook = Workbook();
    try {
      final Worksheet sheet = workbook.worksheets[0];

      // Get today's date in dd-MM-yyyy format
      final DateTime today = DateTime.now();
      final String formattedToday = DateFormat('dd-MMM-yyyy').format(today);

      // Main heading
      final Range titleRange = sheet.getRangeByIndex(1, 1);
      titleRange.setText('Inter ORG Report (Pending Datas)');
      titleRange.cellStyle
        ..fontSize = 16
        ..bold = true;
      titleRange.cellStyle.hAlign = HAlignType.left; // Left align title
      sheet.getRangeByIndex(1, 1, 1, columnNames.length).merge();

      // Subheading with date
      final Range subTitleRange = sheet.getRangeByIndex(3, 1);
      subTitleRange.setText('ALJE Inter ORG Reports As On : $formattedToday');
      subTitleRange.cellStyle
        ..fontSize = 12
        ..italic = true;
      subTitleRange.cellStyle.hAlign = HAlignType.left; // Left align subtitle
      sheet.getRangeByIndex(2, 1, 2, columnNames.length).merge();

      // Column headers at row 5
      for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
        final Range range = sheet.getRangeByIndex(5, colIndex + 1);
        range.setText(columnNames[colIndex]);
        range.cellStyle
          ..backColor = '#E7F3FD'
          ..fontColor = '#000000'
          ..bold = true
          ..borders.all.lineStyle = LineStyle.thin
          ..borders.all.color = '#000000'
          ..hAlign = HAlignType.left; // Left align headers
      }

      // Table data from row 6
      for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
        final List<dynamic> rowData = data[rowIndex];
        for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
          final Range range = sheet.getRangeByIndex(rowIndex + 6, colIndex + 1);
          final cellValue = rowData[colIndex];

          // Apply correct data type
          if (cellValue == null) {
            range.setText('');
          } else if (cellValue is num) {
            if (cellValue % 1 == 0) {
              // It's an integer
              range.setNumber(cellValue.toDouble());
              range.numberFormat = '0'; // Format for whole numbers
            } else {
              // It's a decimal number
              range.setNumber(cellValue.toDouble());
              range.numberFormat = '#,##0.00'; // Format for decimal numbers
            }
          } else if (cellValue is DateTime) {
            range.setDateTime(cellValue);
            range.numberFormat = 'DD-MMM-YYYY'; // Format for dates
          } else {
            range.setText(cellValue.toString());
          }

          // Apply styling
          range.cellStyle
            ..borders.all.lineStyle = LineStyle.thin
            ..borders.all.color = '#000000'
            ..hAlign = HAlignType.left; // Left align all data
        }
      }

      // Auto-fit columns
      for (int i = 1; i <= columnNames.length; i++) {
        sheet.autoFitColumn(i);
      }

      final List<int> bytes = workbook.saveAsStream();

      String timestamp = '$formattedToday Time '
          '${today.hour.toString().padLeft(2, '0')}hh-${today.minute.toString().padLeft(2, '0')}mm-${today.second.toString().padLeft(2, '0')}ss';
      if (kIsWeb) {
        final blob = base64.encode(bytes);
        AnchorElement(
          href: 'data:application/octet-stream;charset=utf-16le;base64,$blob',
        )
          ..setAttribute(
              'download', 'InterORG Pending details($timestamp).xlsx')
          ..click();
      } else {
        final String path = (await getApplicationSupportDirectory()).path;
        final String fileName = Platform.isWindows
            ? '$path\\Excel InterORG Pending Report($timestamp).xlsx'
            : '$path/Excel InterORG Pending Report($timestamp).xlsx';

        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);
        OpenFile.open(fileName);
      }
    } catch (e) {
      print('Error in createExcel: $e');
      rethrow;
    } finally {
      try {
        workbook.dispose();
      } catch (e) {
        print('Error disposing workbook: $e');
      }
    }
  }
}
