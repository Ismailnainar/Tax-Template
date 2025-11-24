import 'dart:convert';

import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/components/constaints.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ShippingVieew extends StatefulWidget {
  // final Function togglePage;

  // ShippingVieew(this.togglePage);

  @override
  State<ShippingVieew> createState() => _ShippingVieewState();
}

class _ShippingVieewState extends State<ShippingVieew> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  final TextEditingController ProductCodeController = TextEditingController();

  TextEditingController scannedqtyController = TextEditingController(text: '0');
  final TextEditingController salesserialnoController = TextEditingController();
  final ScrollController _horizontalScrollController1 = ScrollController();

  List<Map<String, dynamic>> filteredData = [];

  List<Map<String, dynamic>> orginalfilteredData = [];
  // List<Map<String, dynamic>> tableData = [];
  @override
  void initState() {
    super.initState();
    filteredData = List.from(tableData);
    fetchAccessControl();
    _loadSalesmanName();
    fetchlivestagingreports();

    // checkStatus();

    postLogData("Shipping View", "Opened");

    scannedqtyController.text = filteredData.length.toString();
    print("Scanned Qty ${scannedqtyController.text}");
  }

  List<bool> accessControl = [];
  bool _isLoadingData = true;

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
  void dispose() {
    ProductCodeController.dispose();
    salesserialnoController.dispose();

    postLogData("Shipping View", "Closed");
    super.dispose();
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

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('dd-MMM-yyyy').format(parsedDate); // e.g., 11-Nov-2024
    } catch (e) {
      print("Error parsing date: $e");
      return '';
    }
  }

  Future<void> fetchlivestagingreports() async {
    final IpAddress = await getActiveIpAddress();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgid = prefs.getString('saleslogiOrgwarehousename') ?? '';

    // final String url = '$IpAddress/filtered_Truck/?ORG_NAME=$saleslogiOrgid';
    final String url = '$IpAddress/filtered_Truck/';

    List<Map<String, dynamic>> filteredDataTemp = [];
    bool hasNextPage = true;
    String? nextPageUrl = url;

    print("urlll $url");
    setState(() {
      _isLoadingData = true;
    });

    try {
      while (hasNextPage && nextPageUrl != null) {
        print("Fetching data from URL: $nextPageUrl");
        final response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes); // <- fix here

          final Map<String, dynamic> responseData = json.decode(decodedBody);

          if (responseData.containsKey('results')) {
            final List<Map<String, dynamic>> currentPageData =
                List<Map<String, dynamic>>.from(responseData['results']);

            filteredDataTemp.addAll(currentPageData.where(
                (item) => item['ORG_NAME']?.toString() == saleslogiOrgid));

            nextPageUrl = responseData['next'];
            hasNextPage = nextPageUrl != null;
          } else {
            throw Exception('No results key found in the response');
          }
        } else {
          throw Exception(
              'Failed to load data with status code ${response.statusCode}');
        }
      }

      // Update state with the fetched data
      setState(() {
        filteredData = filteredDataTemp.map((item) {
          String scanPathRaw = item['SCAN_PATH']?.toString() ?? '';
          Uri uri = Uri.parse(IpAddress!);
          String baseIp = '${uri.scheme}://${uri.host}:9000';

          String scanpath = scanPathRaw.isNotEmpty
              ? '$baseIp$scanPathRaw'
              : 'No Scan Print Uploaded';

          return {
            'cusno': item['CUSTOMER_NUMBER']?.toString() ?? '',
            'cusname': item['CUSTOMER_NAME']?.toString() ?? '',
            'cussite': item['CUSTOMER_SITE_ID']?.toString() ?? '',
            'dispatchno': item['DISPATCH_ID']?.toString() ?? '',
            'reqno': item['REQ_ID']?.toString() ?? '',
            'pickid': item['PICK_ID']?.toString() ?? '',
            'scannedqty': item['TRUCK_SEND_QTY']?.toString() ?? '',
            'scanpath': scanpath,
            'date': formatDate(item['DATE']), // Format the date
          };
        }).toList();
        // print("filteredData $filteredData");
        _isLoadingData = false;
        orginalfilteredData = filteredData;
        // Trigger date range filtering here
        _filterDataByDate();
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      print('Error fetching data: $e');
    }
  }

  DateTime? _selectedDate;
  TextEditingController deliverynocontroller = TextEditingController();
  TextEditingController filteredReqIdcontroller = TextEditingController();
  TextEditingController PickIdcontroller = TextEditingController();
  TextEditingController _FromdateController = TextEditingController(
      text: DateFormat('dd-MMM-yyyy').format(DateTime.now()));

  TextEditingController _EnddateController = TextEditingController(
      text: DateFormat('dd-MMM-yyyy').format(DateTime.now()));

  // Function to show the date picker and set the selected date
  Future<void> _selectfromDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    // Show DatePicker Dialog
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Initial date
      firstDate: DateTime(2000), // Earliest possible date
      lastDate: DateTime(2101), // Latest possible date
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      // Format the selected date as 'dd-MMM-yyyy'
      String formattedDate = DateFormat('dd-MMM-yyyy').format(pickedDate);
      setState(() {
        _FromdateController.text =
            formattedDate; // Set the formatted date to the controller
      });
    }
  }

  // Function to show the date picker and set the selected date
  Future<void> _selectendDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    // Show DatePicker Dialog
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Initial date
      firstDate: DateTime(2000), // Earliest possible date
      lastDate: DateTime(2101), // Latest possible date
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      // Format the selected date as 'dd-MMM-yyyy'
      String formattedDate = DateFormat('dd-MMM-yyyy').format(pickedDate);
      setState(() {
        _EnddateController.text =
            formattedDate; // Set the formatted date to the controller
      });
    }
  }

  List<String> FilteredtypeList = [
    "Deliver Id",
    "Req Id",
    "Pick Id",
  ];

  bool _filterEnabledexported = true;
  int? _hoveredIndexExported;
  int? _selectedIndexExported;

  String? ExportedSelectedValue;
  FocusNode FilteredtypeFocusNode = FocusNode();
  FocusNode FilteredValueFocusNode = FocusNode();

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  TextEditingController FilteredtypeController = TextEditingController();
  TextEditingController FilteredValeController = TextEditingController();

  TextEditingController FilteredReqnoController = TextEditingController();

  TextEditingController FilteredPickidController = TextEditingController();
  TextEditingController FilteredDispatchIdController = TextEditingController();
  Widget _buildSearrchTypeDropdown() {
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
                      width: Responsive.isDesktop(context) ? 200 : 150,
                      child: FilteredDropdown()),
                ],
              ),
            ),
            SizedBox(width: 3),
          ],
        ),
      ),
    );
  }

  Widget FilteredDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                FilteredtypeList.indexOf(FilteredtypeController.text);
            if (currentIndex < FilteredtypeList.length - 1) {
              setState(() {
                _selectedIndexExported = currentIndex + 1;
                // Take only the customer number part before the colon
                FilteredtypeController.text =
                    FilteredtypeList[currentIndex + 1].split(':')[0];
                _filterEnabledexported = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                FilteredtypeList.indexOf(FilteredtypeController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndexExported = currentIndex - 1;
                // Take only the customer number part before the colon
                FilteredtypeController.text =
                    FilteredtypeList[currentIndex - 1].split(':')[0];
                _filterEnabledexported = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: FilteredtypeFocusNode,
          controller: FilteredtypeController,
          onSubmitted: (String? suggestion) async {
            setState(() {
              FilteredValeController.clear();
            });
            _fieldFocusChange(
                context, FilteredtypeFocusNode, FilteredValueFocusNode);
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
            return FilteredtypeList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return FilteredtypeList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = FilteredtypeList.indexOf(suggestion);
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
                          FilteredtypeList.indexOf(
                                  FilteredtypeController.text) ==
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
          constraints: BoxConstraints(maxHeight: 180),
        ),
        onSuggestionSelected: (suggestion) {
          setState(() {
            _selectedIndexExported = FilteredtypeList.indexOf(suggestion);
            // Take only the customer number part before the colon
            FilteredtypeController.text = suggestion.split(':')[0];
            ExportedSelectedValue = suggestion;
            _filterEnabledexported = false;
          });
          setState(() {
            FilteredValeController.clear();
          });

          _fieldFocusChange(
              context, FilteredtypeFocusNode, FilteredValueFocusNode);
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }

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
                                  Icons.local_shipping_outlined,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Shipped View',
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
                    height: MediaQuery.of(context).size.height * 0.85,
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
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(width: 16),
                                            Container(
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? 200
                                                      : 150,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 0),
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              // Icon(Icons.search,
                                                              //     size: 14,
                                                              //     color: Colors
                                                              //             .blue[
                                                              //         600]),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text("",
                                                                  style:
                                                                      textboxheading),
                                                              SizedBox(
                                                                  width: 8),
                                                            ],
                                                          ),
                                                          // Icon(
                                                          //   Icons.star,
                                                          //   size: 8,
                                                          //   color: Colors.red,
                                                          // )
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Container(
                                                      height: 32,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 0,
                                                                bottom: 0),
                                                        child: TextFormField(
                                                          controller:
                                                              FilteredDispatchIdController,
                                                          // focusNode:
                                                          //     FilteredValueFocusNode,
                                                          onChanged:
                                                              (value) async {
                                                            setState(() async {
                                                              setState(() {
                                                                FilteredPickidController
                                                                    .clear();
                                                                FilteredReqnoController
                                                                    .clear();
                                                              });
                                                              await _DispatchnofilterDataByDate(
                                                                  FilteredDispatchIdController
                                                                      .text
                                                                      .trim());
                                                            });
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                "Enter Delivery id",
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
                                                          style: textBoxstyle,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Container(
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? 200
                                                      : 150,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 0),
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              // Icon(Icons.search,
                                                              //     size: 14,
                                                              //     color: Colors
                                                              //             .blue[
                                                              //         600]),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text("",
                                                                  style:
                                                                      textboxheading),
                                                              SizedBox(
                                                                  width: 8),
                                                            ],
                                                          ),
                                                          // Icon(
                                                          //   Icons.star,
                                                          //   size: 8,
                                                          //   color: Colors.red,
                                                          // )
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Container(
                                                      height: 32,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 0,
                                                                bottom: 0),
                                                        child: TextFormField(
                                                          controller:
                                                              FilteredReqnoController,
                                                          onChanged:
                                                              (value) async {
                                                            setState(() {
                                                              FilteredPickidController
                                                                  .clear();
                                                              FilteredDispatchIdController
                                                                  .clear();
                                                            });
                                                            setState(() async {
                                                              await _reqnofilterDataByDate(
                                                                  FilteredReqnoController
                                                                      .text
                                                                      .trim());
                                                            });
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                "Enter Req id",
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
                                                          style: textBoxstyle,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Container(
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? 200
                                                      : 150,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 0),
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              // Icon(Icons.search,
                                                              //     size: 14,
                                                              //     color: Colors
                                                              //             .blue[
                                                              //         600]),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text("",
                                                                  style:
                                                                      textboxheading),
                                                              SizedBox(
                                                                  width: 8),
                                                            ],
                                                          ),
                                                          // Icon(
                                                          //   Icons.star,
                                                          //   size: 8,
                                                          //   color: Colors.red,
                                                          // )
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Container(
                                                      height: 32,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 0,
                                                                bottom: 0),
                                                        child: TextFormField(
                                                          controller:
                                                              FilteredPickidController,
                                                          onChanged:
                                                              (value) async {
                                                            setState(() {
                                                              FilteredReqnoController
                                                                  .clear();
                                                              FilteredDispatchIdController
                                                                  .clear();
                                                            });
                                                            setState(() async {
                                                              await _PicknofilterDataByDate(
                                                                  FilteredPickidController
                                                                      .text
                                                                      .trim());
                                                            });
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                "Enter Pick id",
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
                                                          style: textBoxstyle,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Padding(
                                              padding: EdgeInsets.only(top: 20),
                                              child: GestureDetector(
                                                onTap: () => _selectfromDate(
                                                    context), // Open the date picker when tapped
                                                child: Container(
                                                  height: 32,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 0,
                                                      horizontal: 20),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: Color.fromARGB(
                                                        255, 195, 228, 255),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.calendar_today,
                                                          color: Colors.blue,
                                                          size: 14),
                                                      SizedBox(width: 10),
                                                      Text(
                                                        _FromdateController
                                                                .text.isEmpty
                                                            ? DateFormat(
                                                                    'dd-MMM-yyyy')
                                                                .format(DateTime
                                                                    .now())
                                                            : _FromdateController
                                                                .text, // Display the selected date
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Padding(
                                              padding: EdgeInsets.only(top: 20),
                                              child: GestureDetector(
                                                onTap: () => _selectendDate(
                                                    context), // Open the date picker when tapped
                                                child: Container(
                                                  height: 32,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 0,
                                                      horizontal: 20),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: Color.fromARGB(
                                                        255, 195, 228, 255),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.calendar_today,
                                                          color: Colors.blue,
                                                          size: 14),
                                                      SizedBox(width: 10),
                                                      Text(
                                                        _EnddateController
                                                                .text.isEmpty
                                                            ? DateFormat(
                                                                    'dd-MMM-yyyy')
                                                                .format(DateTime
                                                                    .now())
                                                            : _EnddateController
                                                                .text, // Display the selected date
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Padding(
                                              padding: EdgeInsets.only(top: 20),
                                              child: Container(
                                                height: 32,
                                                decoration: BoxDecoration(
                                                    color: buttonColor),
                                                child: ElevatedButton(
                                                    onPressed: () async {
                                                      if (_FromdateController
                                                              .text.isEmpty ||
                                                          _EnddateController
                                                              .text.isEmpty) {
                                                        Checkstatus();
                                                      } else {
                                                        DateTime? fromDate =
                                                            DateFormat(
                                                                    'dd-MMM-yyyy')
                                                                .parse(
                                                                    _FromdateController
                                                                        .text);
                                                        DateTime? endDate =
                                                            DateFormat(
                                                                    'dd-MMM-yyyy')
                                                                .parse(
                                                                    _EnddateController
                                                                        .text);

                                                        if (endDate.isBefore(
                                                            fromDate)) {
                                                          await showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    "Invalid Date"),
                                                                content: Text(
                                                                    "Kindly check the from date and end date."),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        _EnddateController
                                                                            .text = DateFormat(
                                                                                'dd-MMM-yyyy')
                                                                            .format(DateTime.now());
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      });
                                                                    },
                                                                    child: Text(
                                                                        "OK"),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        } else {
                                                          await fetchlivestagingreports();
                                                          await _filterDataByDate();
                                                        }
                                                      }

                                                      postLogData(
                                                          "Shipping View",
                                                          "Search");
                                                    },
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
                                                    child: Text(
                                                      'Search',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    )),
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Padding(
                                              padding: EdgeInsets.only(top: 20),
                                              child: Container(
                                                height: 32,
                                                decoration: BoxDecoration(
                                                    color: buttonColor),
                                                child: ElevatedButton(
                                                    onPressed: () async {
                                                      setState(() {
                                                        deliverynocontroller
                                                            .clear();
                                                      });
                                                      await _filterDataByDate();
                                                      _FromdateController
                                                          .clear();
                                                      _EnddateController
                                                          .clear();

                                                      postLogData(
                                                          "Shipping View",
                                                          "Clear");
                                                    },
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
                                                    child: Text(
                                                      'Clear',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    )),
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
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, right: 10, left: 10),
                              child: _buildResponsiveView(),
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

  _filterDataByDate() {
    final selectedFromDateStr = _FromdateController.text.trim();
    final selectedEndDateStr = _EnddateController.text.trim();

    if (selectedFromDateStr.isNotEmpty && selectedEndDateStr.isNotEmpty) {
      DateFormat dateFormat = DateFormat('dd-MMM-yyyy');

      try {
        DateTime selectedFromDate = dateFormat.parse(selectedFromDateStr);
        DateTime selectedEndDate = dateFormat.parse(selectedEndDateStr);

        setState(() {
          filteredData = filteredData.where((entry) {
            try {
              DateTime entryDate = dateFormat.parse(entry['date']);
              return entryDate
                      .isAfter(selectedFromDate.subtract(Duration(days: 1))) &&
                  entryDate.isBefore(selectedEndDate.add(Duration(days: 1)));
            } catch (e) {
              print("Error parsing entry date: ${entry['date']} - $e");
              return false;
            }
          }).toList();
        });
      } catch (e) {
        print("Error parsing selected dates: $e");
      }
    }
  }

  int _currentPage = 1;
  int _rowsPerPage = 10;
  int _totalPages = 1;
  _DispatchnofilterDataByDate(String deliverid) {
    print("Filtering by delivery ID: $deliverid");
    if (deliverid.isEmpty) {
      _filterDataByDate();
    } else {
      try {
        setState(() {
          // Reset to first page whenever filtering changes
          _currentPage = 1;

          if (deliverid.isEmpty) {
            // If search field is empty, show all data
            filteredData = List.from(orginalfilteredData);
          } else {
            // Filter data based on dispatch number
            filteredData = orginalfilteredData.where((entry) {
              try {
                // Case-insensitive comparison of dispatch numbers
                return entry['dispatchno']
                    .toString()
                    .toLowerCase()
                    .contains(deliverid.toLowerCase());
              } catch (e) {
                print("Error filtering entry: ${entry['dispatchno']} - $e");
                return false;
              }
            }).toList();
          }

          // Update total pages based on filtered data
          _totalPages = (filteredData.length / _rowsPerPage).ceil();
          if (_totalPages == 0) _totalPages = 1; // Ensure at least 1 page

          print("Found ${filteredData.length} matching records");
        });
      } catch (e) {
        print("Error in _filterDataByDate: $e");
        setState(() {
          filteredData = [];
          _currentPage = 1;
          _totalPages = 1;
        });
      }
    }
  }

  _reqnofilterDataByDate(String deliverid) {
    print("Filtering by delivery ID: $deliverid");
    if (deliverid.isEmpty) {
      _filterDataByDate();
    } else {
      try {
        setState(() {
          // Reset to first page whenever filtering changes
          _currentPage = 1;

          if (deliverid.isEmpty) {
            // If search field is empty, show all data
            filteredData = List.from(orginalfilteredData);
          } else {
            // Filter data based on dispatch number
            filteredData = orginalfilteredData.where((entry) {
              try {
                // Case-insensitive comparison of dispatch numbers
                return entry['reqno']
                    .toString()
                    .toLowerCase()
                    .contains(deliverid.toLowerCase());
              } catch (e) {
                print("Error filtering entry: ${entry['reqno']} - $e");
                return false;
              }
            }).toList();
          }

          // Update total pages based on filtered data
          _totalPages = (filteredData.length / _rowsPerPage).ceil();
          if (_totalPages == 0) _totalPages = 1; // Ensure at least 1 page

          print("Found ${filteredData.length} matching records");
        });
      } catch (e) {
        print("Error in _filterDataByDate: $e");
        setState(() {
          filteredData = [];
          _currentPage = 1;
          _totalPages = 1;
        });
      }
    }
  }

  _PicknofilterDataByDate(String deliverid) {
    print("Filtering by delivery ID: $deliverid");
    if (deliverid.isEmpty) {
      _filterDataByDate();
    } else {
      try {
        setState(() {
          // Reset to first page whenever filtering changes
          _currentPage = 1;

          if (deliverid.isEmpty) {
            // If search field is empty, show all data
            filteredData = List.from(orginalfilteredData);
          } else {
            // Filter data based on dispatch number
            filteredData = orginalfilteredData.where((entry) {
              try {
                // Case-insensitive comparison of dispatch numbers
                return entry['pickid']
                    .toString()
                    .toLowerCase()
                    .contains(deliverid.toLowerCase());
              } catch (e) {
                print("Error filtering entry: ${entry['pickid']} - $e");
                return false;
              }
            }).toList();
          }

          // Update total pages based on filtered data
          _totalPages = (filteredData.length / _rowsPerPage).ceil();
          if (_totalPages == 0) _totalPages = 1; // Ensure at least 1 page

          print("Found ${filteredData.length} matching records");
        });
      } catch (e) {
        print("Error in _filterDataByDate: $e");
        setState(() {
          filteredData = [];
          _currentPage = 1;
          _totalPages = 1;
        });
      }
    }
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

  List<Map<String, dynamic>> tableData = [];

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

  Future<bool> checkDataExists(
      String reqno, String pickid, String pickedQty) async {
    final IpAddress = await getActiveIpAddress();

    final url =
        Uri.parse('$IpAddress/Truck_scan/?REQ_NO=$reqno&PICK_ID=$pickid');

    print("Fetching URL: $pickedQty: $url");

    try {
      // Safely convert pickedQty from String to double (for decimal values)
      double parsedPickedQty = 0.0;
      try {
        parsedPickedQty =
            double.parse(pickedQty); // Attempt to convert to double
      } catch (e) {
        print('Error parsing pickedQty: $e');
        return false; // If conversion fails, return false
      }

      // Convert the double to an int (by rounding or flooring the value)
      int intPickedQty =
          parsedPickedQty.floor(); // Use .floor() to avoid rounding errors

      print("parsedPickedQty (as int): $intPickedQty: $url");

      final response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Check if the "results" field exists and compare the results count with intPickedQty
        int resultsCount = (data['results'] as List).length;

        // Show the row if there are no results (data doesn't exist) or the count is less than intPickedQty
        return resultsCount < intPickedQty || resultsCount == 0;
      } else {
        return false; // If not successful, assume no data
      }
    } catch (e) {
      print('Error checking data: $e');
      return false; // On error, assume no data
    }
  }

  bool isDialogOpen = false; // Track if dialog is already opened

  Widget _buildResponsiveView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (Responsive.isDesktop(context)) {
          return _buildTableDesktop();
        } else {
          return _buildCardViewMobile();
        }
      },
    );
  }

// Add these constants at the top of your file
  double _rowHeight = 40.0; // Height of each table row
  int _defaultVisibleRows = 10; // Number of rows visible by default

// Desktop Table View with Pagination
  Widget _buildTableDesktop() {
    final screenWidth = MediaQuery.of(context).size.width;

    // Column widths adjusted for better proportions
    final columnWidths = {
      'sno': screenWidth * 0.04,
      'date': screenWidth * 0.08,
      'dispatchNo': screenWidth * 0.09,
      'customerNo': screenWidth * 0.09,
      'customerName': screenWidth * 0.18,
      'customerSite': screenWidth * 0.09,
      'deliverypath': screenWidth * 0.18,
      'quantity': screenWidth * 0.08,
    };

    // Pagination variables
    final totalItems = filteredData.length;
    final totalPages = (totalItems / _rowsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = startIndex + _rowsPerPage > totalItems
        ? totalItems
        : startIndex + _rowsPerPage;
    final paginatedData = filteredData.sublist(
      startIndex,
      endIndex,
    );

    // Calculate table body height based on rows per page
    final tableBodyHeight = _rowsPerPage <= _defaultVisibleRows
        ? _rowHeight * _rowsPerPage
        : _rowHeight * _defaultVisibleRows;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          // Table Container
          Container(
            width: screenWidth * 0.88,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[400]!, width: 1.0),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Scrollbar(
              thumbVisibility: true,
              controller: _horizontalScrollController,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  width: screenWidth * 0.88,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        // Table Header
                        _buildTableHeaderDesktop(columnWidths),
                        // Table Body
                        if (_isLoadingData)
                          Container(
                            height: tableBodyHeight,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (filteredData.isNotEmpty)
                          Container(
                            height: tableBodyHeight,
                            child: _buildTableBodyDesktop(
                                columnWidths, paginatedData),
                          )
                        else
                          Container(
                            height: tableBodyHeight,
                            child: Center(
                              child: Text(
                                "Kindly choose date to view shipped datas..",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Pagination Controls
          if (filteredData.isNotEmpty && !_isLoadingData)
            Container(
              margin: EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.first_page),
                    onPressed: _currentPage == 1
                        ? null
                        : () {
                            setState(() {
                              _currentPage = 1;
                            });
                          },
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_left),
                    onPressed: _currentPage == 1
                        ? null
                        : () {
                            setState(() {
                              _currentPage--;
                            });
                          },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Page $_currentPage of $totalPages',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right),
                    onPressed: _currentPage == totalPages
                        ? null
                        : () {
                            setState(() {
                              _currentPage++;
                            });
                          },
                  ),
                  IconButton(
                    icon: Icon(Icons.last_page),
                    onPressed: _currentPage == totalPages
                        ? null
                        : () {
                            setState(() {
                              _currentPage = totalPages;
                            });
                          },
                  ),
                  SizedBox(width: 20),
                  DropdownButton<int>(
                    value: _rowsPerPage,
                    items: [10, 25, 50, 100].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value rows'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _rowsPerPage = value!;
                        _currentPage =
                            1; // Reset to first page when changing rows per page
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderDesktop(Map<String, double> columnWidths) {
    final headers = [
      {'icon': Icons.format_list_numbered, 'label': 'S.No', 'key': 'sno'},
      {'icon': Icons.date_range, 'label': 'Date', 'key': 'date'},
      {'icon': Icons.numbers, 'label': 'Dispatch No', 'key': 'dispatchNo'},
      {
        'icon': Icons.account_circle,
        'label': 'Customer No',
        'key': 'customerNo'
      },
      {'icon': Icons.person, 'label': 'Customer Name', 'key': 'customerName'},
      {
        'icon': Icons.location_on,
        'label': 'Customer Site',
        'key': 'customerSite'
      },
      {
        'icon': Icons.local_shipping,
        'label': 'Delivery Path',
        'key': 'deliverypath'
      },
      {'icon': Icons.info_outline, 'label': 'Quantity', 'key': 'quantity'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: headers.map((header) {
          return SizedBox(
            width: columnWidths[header['key']],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(header['icon'] as IconData,
                      size: 16, color: Colors.blue[700]),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      header['label'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.blue[900],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableBodyDesktop(Map<String, double> columnWidths,
      List<Map<String, dynamic>> paginatedData) {
    return Scrollbar(
      thumbVisibility: true,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: paginatedData.length,
        itemBuilder: (context, index) {
          final data = paginatedData[index];
          return _buildTableRowDesktop(data, columnWidths, index);
        },
      ),
    );
  }

  Widget _buildTableRowDesktop(
      Map<String, dynamic> data, Map<String, double> columnWidths, int index) {
    final isEvenRow = index % 2 == 0;
    final rowColor = isEvenRow ? Colors.white : Colors.grey[50];
    final sNo = ((_currentPage - 1) * _rowsPerPage) + index + 1;
    final finalqty = double.parse(data['scannedqty']).toInt();

    return GestureDetector(
      onDoubleTap: () => _showDetailsDialog(data),
      child: Container(
        height: _rowHeight,
        decoration: BoxDecoration(
          color: rowColor,
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Row(
            children: [
              _buildTableCell(columnWidths['sno']!, sNo.toString()),
              _buildTableCell(columnWidths['date']!, data['date']),
              _buildTableCell(columnWidths['dispatchNo']!, data['dispatchno']),
              _buildTableCell(columnWidths['customerNo']!, data['cusno']),
              _buildTableCell(
                columnWidths['customerName']!,
                data['cusname'],
                isTooltip: true,
              ),
              _buildTableCell(columnWidths['customerSite']!, data['cussite']),
              _buildScanPathTableCell(
                columnWidths['deliverypath']!,
                data['scanpath'],
                isTooltip: true,
              ),
              _buildQuantityCell(columnWidths['quantity']!, finalqty, rowColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(double width, String text, {bool isTooltip = false}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: isTooltip
              ? Tooltip(
                  message: text,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableText(
                      text,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(
                    text,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildScanPathTableCell(double width, String text,
      {bool isTooltip = false}) {
    final bool isValidLink = text != 'No Scan Print Uploaded';

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: isValidLink
              ? MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse(text);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ),
    );
  }

  Widget _buildQuantityCell(double width, int quantity, Color? rowColor) {
    return SizedBox(
      width: width,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            quantity.toString(),
            style: TextStyle(
              color: Colors.green[800],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

// Mobile Card View
  Widget _buildCardViewMobile() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (_isLoadingData)
            const Center(child: CircularProgressIndicator())
          else if (filteredData.isNotEmpty)
            ...filteredData.map((data) => _buildDataCard(data)).toList()
          else
            const Padding(
              padding: EdgeInsets.only(top: 100.0),
              child: Text("Kindly choose date to view shipped datas.."),
            ),
        ],
      ),
    );
  }

  Widget _buildDataCard(Map<String, dynamic> data) {
    final finalqty = double.parse(data['scannedqty']).toInt();

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: InkWell(
        onTap: () => _showDetailsDialog(data),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardRow(Icons.numbers, 'Dispatch No:', data['dispatchno']),
              _buildCardRow(Icons.date_range, 'Date:', data['date']),
              _buildCardRow(
                  Icons.account_circle, 'Customer No:', data['cusno']),
              _buildCardRow(Icons.person, 'Customer:', data['cusname']),
              _buildCardRow(Icons.location_on, 'Site:', data['cussite']),
              _buildCardRow(
                Icons.shopping_cart,
                'Quantity:',
                '$finalqty',
                valueStyle: const TextStyle(
                  color: Color.fromARGB(255, 65, 147, 72),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              const Center(
                child: Text(
                  'Double tap for details',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardRow(IconData icon, String label, String value,
      {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: valueStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(Map<String, dynamic> data) async {
    if (isDialogOpen) return;

    setState(() => isDialogOpen = true);

    await fetchPickmanData(data['dispatchno']);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DispatchConpletedDataFetch(
        context,
        data['reqno'],
        data['pickid'],
        data['dispatchno'],
        data['cusno'],
        data['cusname'],
        data['cussite'],
      ),
    ).then((_) => setState(() => isDialogOpen = false));

    postLogData("Shipping View (Dispatch Completed Pop-up)",
        "Viewed Dispatch Id ${data['dispatchno']}");
  }

  TextEditingController customersiteController = TextEditingController();

  Widget DispatchConpletedDataFetch(
      BuildContext context,
      String Reqno,
      String Pickid,
      String dispatchNo,
      String cusno,
      String cusname,
      String cussite) {
    double screenWidth = MediaQuery.of(context).size.width;
    print(
        "customernameeeeeeeeeeeeeeeeeeeeee : $Reqno    $Pickid  $dispatchNo  ");
    customerNameController.text = '$cusname';
    customerNoController.text = '$cusno';
    reqnoController.text = '$Reqno';
    PicknoController.text = '$Pickid';

    customersiteController.text = '$cussite';

    return Dialog(
      child: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            width: Responsive.isDesktop(context) ? screenWidth * 0.6 : 600,
            height: Responsive.isDesktop(context) ? 620 : 500,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Dispatch Completed Pop-Up",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.cancel))
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runSpacing: 5,
                      children: [
                        Container(
                          width: Responsive.isDesktop(context)
                              ? screenWidth * 0.1
                              : screenWidth * 0.4,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("Req No", style: textboxheading),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0, bottom: 0),
                                  child: Row(
                                    children: [
                                      Container(
                                          height: 32,
                                          // width: Responsive.isDesktop(context)
                                          //     ? screenWidth * 0.086
                                          //     : 130,

                                          width: Responsive.isDesktop(context)
                                              ? screenWidth * 0.1
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
                                              message: "${Reqno}",
                                              child: TextFormField(
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color.fromARGB(
                                                          201, 132, 132, 132),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color.fromARGB(
                                                          255, 58, 58, 58),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  filled:
                                                      true, // Enable the background fill
                                                  fillColor: Color.fromARGB(
                                                      255, 234, 234, 234),

                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 5.0,
                                                    horizontal: 10.0,
                                                  ),
                                                ),
                                                controller: reqnoController,
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 73, 72, 72),
                                                    fontSize: 13),
                                              ),
                                            ),
                                          )),
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
                              ? screenWidth * 0.1
                              : screenWidth * 0.4,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("Pick Id", style: textboxheading),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0, bottom: 0),
                                  child: Row(
                                    children: [
                                      Container(
                                          height: 32,
                                          // width: Responsive.isDesktop(context)
                                          //     ? screenWidth * 0.086
                                          //     : 130,

                                          width: Responsive.isDesktop(context)
                                              ? screenWidth * 0.1
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
                                              message: "${Pickid}",
                                              child: TextFormField(
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color.fromARGB(
                                                          201, 132, 132, 132),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color.fromARGB(
                                                          255, 58, 58, 58),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  filled:
                                                      true, // Enable the background fill
                                                  fillColor: Color.fromARGB(
                                                      255, 234, 234, 234),

                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 5.0,
                                                    horizontal: 10.0,
                                                  ),
                                                ),
                                                controller: PicknoController,
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 73, 72, 72),
                                                    fontSize: 13),
                                              ),
                                            ),
                                          )),
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
                              ? screenWidth * 0.08
                              : screenWidth * 0.4,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("Customer No", style: textboxheading),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0, bottom: 0),
                                  child: Row(
                                    children: [
                                      Container(
                                          height: 32,
                                          // width: Responsive.isDesktop(context)
                                          //     ? screenWidth * 0.086
                                          //     : 130,

                                          width: Responsive.isDesktop(context)
                                              ? screenWidth * 0.08
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
                                              message: "${cusno}",
                                              child: TextFormField(
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color.fromARGB(
                                                          201, 132, 132, 132),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color.fromARGB(
                                                          255, 58, 58, 58),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  filled:
                                                      true, // Enable the background fill
                                                  fillColor: Color.fromARGB(
                                                      255, 234, 234, 234),

                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 5.0,
                                                    horizontal: 10.0,
                                                  ),
                                                ),
                                                controller:
                                                    customerNoController,
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 73, 72, 72),
                                                    fontSize: 13),
                                              ),
                                            ),
                                          )),
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
                              ? screenWidth * 0.13
                              : screenWidth * 0.4,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("Customer Name",
                                        style: textboxheading),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0, bottom: 0),
                                  child: Row(
                                    children: [
                                      Container(
                                          height: 32,
                                          // width: Responsive.isDesktop(context)
                                          //     ? screenWidth * 0.086
                                          //     : 130,

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
                                              message: "${cusname}",
                                              child: TextFormField(
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color.fromARGB(
                                                          201, 132, 132, 132),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color.fromARGB(
                                                          255, 58, 58, 58),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  filled:
                                                      true, // Enable the background fill
                                                  fillColor: Color.fromARGB(
                                                      255, 234, 234, 234),

                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 5.0,
                                                    horizontal: 10.0,
                                                  ),
                                                ),
                                                controller:
                                                    customerNameController,
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 73, 72, 72),
                                                    fontSize: 13),
                                              ),
                                            ),
                                          )),
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
                              ? screenWidth * 0.08
                              : screenWidth * 0.4,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("Customer Site",
                                        style: textboxheading),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0, bottom: 0),
                                  child: Row(
                                    children: [
                                      Container(
                                          height: 32,
                                          // width: Responsive.isDesktop(context)
                                          //     ? screenWidth * 0.086
                                          //     : 130,

                                          width: Responsive.isDesktop(context)
                                              ? screenWidth * 0.08
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
                                              message: "${cussite}",
                                              child: TextFormField(
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color.fromARGB(
                                                          201, 132, 132, 132),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color.fromARGB(
                                                          255, 58, 58, 58),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  filled:
                                                      true, // Enable the background fill
                                                  fillColor: Color.fromARGB(
                                                      255, 234, 234, 234),

                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 5.0,
                                                    horizontal: 10.0,
                                                  ),
                                                ),
                                                controller:
                                                    customersiteController,
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 73, 72, 72),
                                                    fontSize: 13),
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 35,
                              decoration: BoxDecoration(color: buttonColor),
                              child: ElevatedButton(
                                onPressed: () async {
                                  // _launchUrl(context, dispatchNo);
                                  _launchUrldetailed(context, dispatchNo);

                                  postLogData(
                                      "Shipping View (Dispatch Completed Pop-up)",
                                      "Dispatch Details Reprint for the Dispatch Id $dispatchNo");
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
                                    'Details Reprint',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Container(
                              height: 35,
                              decoration: BoxDecoration(color: buttonColor),
                              child: ElevatedButton(
                                onPressed: () async {
                                  _launchUrl(context, dispatchNo);
                                  // _launchUrldetailed(context, dispatchNo);

                                  postLogData(
                                      "Shipping View (Dispatch COmpleted Pop-up)",
                                      "Dispatch Reprint for the Dispatch Id $dispatchNo");
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
                                    'Reprint',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 15),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Viewtabledata(),
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

  // Widget Viewtabledata() {
  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     child: SizedBox(
  //       width: MediaQuery.of(context).size.width * 2, // Ensure scrollable width
  //       child: Stack(
  //         children: [
  //           ScrollbarTheme(
  //             data: ScrollbarThemeData(
  //               thumbColor: MaterialStateProperty.all(Colors.grey[600]),
  //               thumbVisibility: MaterialStateProperty.all(true),
  //               thickness: MaterialStateProperty.all(8),
  //               radius: const Radius.circular(10),
  //             ),
  //             child: Scrollbar(
  //               thumbVisibility: true,
  //               controller: _horizontalScrollController1,
  //               child: SingleChildScrollView(
  //                 controller: _horizontalScrollController1,
  //                 scrollDirection: Axis.horizontal,
  //                 child: Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Container(
  //                       color: Colors.white,
  //                       height: MediaQuery.of(context).size.height * 0.5,
  //                       width: Responsive.isDesktop(context)
  //                           ? MediaQuery.of(context).size.width * 0.90
  //                           : MediaQuery.of(context).size.width * 2,
  //                       child: SingleChildScrollView(
  //                         scrollDirection: Axis.horizontal,
  //                         child: Column(
  //                           children: [
  //                             // Table Header
  //                             Padding(
  //                               padding: const EdgeInsets.symmetric(
  //                                   horizontal: 10, vertical: 13),
  //                               child: Row(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: [
  //                                   // _tableHeader(
  //                                   //     "Req No", Icons.format_list_numbered),
  //                                   // _tableHeader("Pick Id", Icons.countertops),
  //                                   _tableHeader("Item Code", Icons.qr_code),
  //                                   _tableItemDescHeader(
  //                                       "Item Description", Icons.info_outline),
  //                                   _tableHeader(
  //                                       "Product Code", Icons.qr_code_scanner),
  //                                   _tableHeader(
  //                                       "Serial No", Icons.confirmation_number),
  //                                 ],
  //                               ),
  //                             ),
  //                             // Loading Indicator or Table Rows
  //                             if (_isLoading)
  //                               Padding(
  //                                 padding: const EdgeInsets.only(top: 100.0),
  //                                 child:
  //                                     Center(child: CircularProgressIndicator()),
  //                               )
  //                             else if (viewtableData.isNotEmpty)
  //                               ...viewtableData.asMap().entries.map((entry) {
  //                                 int index = entry.key;
  //                                 var data = entry.value;

  //                                 // Extract relevant data
  //                                 String getreqno = data['REQ_ID'].toString();
  //                                 String reqno = 'ReqNo_$getreqno';
  //                                 String getpickid = data['PICK_ID'].toString();
  //                                 String pickid = 'PickId_$getpickid';
  //                                 String itemcode = data['ITEM_CODE'].toString();
  //                                 String itemdetails =
  //                                     data['ITEM_DETAILS'].toString();
  //                                 String productcode =
  //                                     data['PRODUCT_CODE'].toString();
  //                                 String serialno = data['SERIAL_NO'].toString();

  //                                 bool isEvenRow = index % 2 == 0;
  //                                 Color rowColor = isEvenRow
  //                                     ? Color.fromARGB(224, 255, 255, 255)
  //                                     : Color.fromARGB(224, 245, 245, 245);

  //                                 return Padding(
  //                                   padding: const EdgeInsets.symmetric(
  //                                       horizontal: 10),
  //                                   child: GestureDetector(
  //                                     onTap: () {
  //                                       // Action on row tap (e.g., show details)
  //                                     },
  //                                     child: Row(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.center,
  //                                       children: [
  //                                         // _tableRow(reqno, rowColor),
  //                                         // _tableRow(pickid, rowColor),
  //                                         _tableRow(itemcode, rowColor),
  //                                         _tableItemDescRow(
  //                                             itemdetails, rowColor),
  //                                         _tableRow(productcode, rowColor),
  //                                         _tableRow(serialno, rowColor),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 );
  //                               }).toList()
  //                             else
  //                               Padding(
  //                                 padding: const EdgeInsets.only(top: 100.0),
  //                                 child: Text("No data available."),
  //                               ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Positioned(
  //             bottom: 0, // Adjust pos   ition as needed
  //             left: 0,
  //             right: 0,
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 // Left Arrow with click handler
  //                 IconButton(
  //                   icon: Icon(
  //                     Icons.arrow_left_outlined,
  //                     color: Colors.blueAccent,
  //                     size: 30,
  //                   ),
  //                   onPressed: () {
  //                     // Scroll left by a fixed amount
  //                     _horizontalScrollController1.animateTo(
  //                       _horizontalScrollController1.offset -
  //                           100, // Adjust scroll amount
  //                       duration: Duration(milliseconds: 300),
  //                       curve: Curves.easeInOut,
  //                     );
  //                   },
  //                 ),
  //                 // Right Arrow with click handler
  //                 IconButton(
  //                   icon: Icon(
  //                     Icons.arrow_right_outlined,
  //                     color: Colors.blueAccent,
  //                     size: 30,
  //                   ),
  //                   onPressed: () {
  //                     // Scroll right by a fixed amount
  //                     _horizontalScrollController1.animateTo(
  //                       _horizontalScrollController1.offset +
  //                           100, // Adjust scroll amount
  //                       duration: Duration(milliseconds: 300),
  //                       curve: Curves.easeInOut,
  //                     );
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget Viewtabledata() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 2, // Ensure scrollable width
        child: Stack(
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
                controller: _horizontalScrollController1,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController1,
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.90
                        : MediaQuery.of(context).size.width * 2,
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            // Table Header (fixed)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 13),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _tableHeader("Item Code", Icons.qr_code),
                                  _tableItemDescHeader(
                                      "Item Description", Icons.info_outline),
                                  _tableHeader(
                                      "Product Code", Icons.qr_code_scanner),
                                  _tableHeader(
                                      "Serial No", Icons.confirmation_number),
                                ],
                              ),
                            ),
                            // Table Content (scrollable)
                            if (_isLoading)
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            else if (viewtableData.isNotEmpty)
                              ...viewtableData.asMap().entries.map((entry) {
                                int index = entry.key;
                                var data = entry.value;

                                String itemcode = data['ITEM_CODE'].toString();
                                String itemdetails =
                                    data['ITEM_DETAILS'].toString();
                                String productcode =
                                    data['PRODUCT_CODE'].toString();
                                String serialno = data['SERIAL_NO'].toString();

                                bool isEvenRow = index % 2 == 0;
                                Color rowColor = isEvenRow
                                    ? Color.fromARGB(224, 255, 255, 255)
                                    : Color.fromARGB(224, 245, 245, 245);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Action on row tap
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _tableRow(itemcode, rowColor),
                                        _tableItemDescRow(
                                            itemdetails, rowColor),
                                        _tableRow(productcode, rowColor),
                                        _tableRow(serialno, rowColor),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList()
                            else
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child:
                                    Center(child: Text("No data available.")),
                              ),
                          ],
                        ),
                      ),
                    ),
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
                      _horizontalScrollController1.animateTo(
                        _horizontalScrollController1.offset - 100,
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
                      _horizontalScrollController1.animateTo(
                        _horizontalScrollController1.offset + 100,
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
      ),
    );
  }

  Widget _tableHeader(String text, IconData icon) {
    return Expanded(
      child: Container(
        height: Responsive.isDesktop(context) ? 25 : 30,
        decoration: TableHeaderColor,
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.start, // Aligns items to the start
          crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
          children: [
            Icon(icon, size: 15, color: Colors.blue),
            SizedBox(width: 2),
            Expanded(
              child: Text(
                text,

                textAlign: TextAlign.left, // Align text to the start (left)
                style: TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis, // Avoid overflow
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableItemDescHeader(String text, IconData icon) {
    return Container(
      height: Responsive.isDesktop(context) ? 25 : 30,
      width: 550,
      decoration: TableHeaderColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Aligns items to the start
        crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
        children: [
          Icon(icon, size: 15, color: Colors.blue),
          SizedBox(width: 2),
          Expanded(
            child: Text(
              text, style: TextStyle(fontSize: 13),

              textAlign: TextAlign.left, // Align text to the start (left)
              overflow: TextOverflow.ellipsis, // Avoid overflow
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableRow(String data, Color? rowColor, {String? tooltipMessage}) {
    return Expanded(
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: rowColor,
          border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.start, // Aligns items to the start
          crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
          children: [
            Expanded(
              child: tooltipMessage != null
                  ? Tooltip(
                      message: tooltipMessage,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          data,
                          textAlign: TextAlign.left, // Align text to the start
                          style: TableRowTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
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

  Widget _tableItemDescRow(String data, Color? rowColor,
      {String? tooltipMessage}) {
    return Container(
      height: 30,
      width: 550,
      decoration: BoxDecoration(
        color: rowColor,
        border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Aligns items to the start
        crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
        children: [
          Text(
            data,
            textAlign: TextAlign.left, // Align text to the start
            style: TableRowTextStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getButtonLabel(String status) {
    if (status == "Completed") {
      return "Scan Completed"; // When status is "Completed"
    } else if (status == "Processing") {
      return "Processing"; // When status is "Processing"
    } else {
      return "Load to Truck"; // When status is "Not Available"
    }
  }

  Color _getButtonColor(String status) {
    if (status == "Completed") {
      return Colors.green; // Green for "Completed"
    } else if (status == "Processing") {
      return Colors.purple; // Purple for "Processing"
    } else {
      return buttonColor; // Default color (can be any color for "Not Available")
    }
  }

  void Checkstatus() {
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
                  'Kindly select the From and To Date',
                  style: TextStyle(fontSize: 15, color: Colors.black),
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

  List<Map<String, dynamic>> viewtableData = [];
  bool _isLoading = false;

  TextEditingController customerNameController = TextEditingController();
  TextEditingController customerNoController = TextEditingController();

  TextEditingController reqnoController = TextEditingController();
  TextEditingController PicknoController = TextEditingController();

  Future<void> fetchPickmanData(String dispatchno) async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/filtedshippingproductdetails/$dispatchno/';
    print("Fetching data from URL: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');

        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
        // Decode the JSON response
        final List<dynamic> data = json.decode(decodedBody);

        // Safely cast the list to List<Map<String, dynamic>>
        if (data.isNotEmpty) {
          setState(() {
            viewtableData = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          throw Exception('No results found in the response');
        }
      } else {
        // Handle non-200 status codes
        setState(() {
          _isLoading = false;
        });
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (e is FormatException) {
        print('Invalid JSON format: $e');
      } else if (e is http.ClientException) {
        print('HTTP client error: $e');
      } else {
        print('Unknown error: $e');
      }
    }
  }

  _launchUrl(
    BuildContext context,
    String dispatchNo,
  ) async {
    List<String> productDetails = [];
    int snoCounter = 1;
    if (viewtableData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No data available to send.')),
      );
      return;
    }

    final item = viewtableData.first;

    String formattedDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    List<Map<String, dynamic>> mergeTableData(
        List<Map<String, dynamic>> viewtableData) {
      Map<String, Map<String, dynamic>> mergedData = {};

      for (var item in viewtableData) {
        String key =
            '${item['INVOICE_NO']}-${item['ITEM_CODE']}-${item['ITEM_DETAILS']}';
        int currentQty =
            int.tryParse(item['TRUCK_SEND_QTY']?.toString() ?? '0') ?? 0;

        if (mergedData.containsKey(key)) {
          int existingQty = mergedData[key]!['sendqty'] ?? 0;
          mergedData[key]!['sendqty'] = existingQty + currentQty;
        } else {
          mergedData[key] = {
            'sno': snoCounter++,
            'invoiceno': item['INVOICE_NO'],
            'itemcode': item['ITEM_CODE'],
            'itemdetails': item['ITEM_DETAILS'],
            'sendqty': currentQty,
          };
        }
      }

      return mergedData.values.toList();
    }

    // Preprocess the table data before rendering
    List<Map<String, dynamic>> mergedData = mergeTableData(viewtableData);

    for (var data in mergedData) {
      String formattedProduct =
          "{${data['sno']}|${data['invoiceno']}|${data['itemcode']}|${data['itemdetails']}|${data['sendqty']}}";
      productDetails.add(formattedProduct);
    }

    String productDetailsString = productDetails.join('');

    print("productDetailsString  $productDetailsString");

    final ipAddress = await getActiveOracleIpAddress();

    String url = Uri.parse('$ipAddress/Generate_dispatch_print/').replace(
      queryParameters: {
        "deliveryno": dispatchNo,
        "region": item['PHYSICAL_WAREHOUSE'] ?? '',
        "transportor_Name": item['TRANSPORTER_NAME'] ?? '',
        "pickid": item['PICK_ID'] ?? '',
        "pickmanname": item['PICKMAN_NAME'] ?? '',
        "vehicleNo": item['VEHICLE_NO'] ?? '',
        "driverName": item['DRIVER_NAME'] ?? '',
        "driverMobileNo": item['DRIVER_MOBILENO'] ?? '',
        "date": formatDate(item['DATE']),
        "customerNo": item['CUSTOMER_NUMBER'] ?? '',
        "customername": item['CUSTOMER_NAME'] ?? '',
        "customersite": item['CUSTOMER_SITE_ID'] ?? '',
        "deliveryaddress": item['DELIVERYADDRESS'] ?? '',
        "remmarks": item['REMARKS'] ?? '',
        'salesmanremmarks': item['SALESMANREMARKS'] ?? '',
        "itemtotalqty": viewtableData
            .fold(
                0,
                (sum, item) =>
                    sum +
                    (int.tryParse(item['TRUCK_SEND_QTY']?.toString() ?? '0') ??
                        0))
            .toString(),
        "products_param": productDetailsString,
      },
    ).toString();

    if (await canLaunch(url)) {
      await launch(url); // this opens in new window on web
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch URL')),
      );
    }
  }

  _launchUrldetailed(
    BuildContext context,
    String dispatchNo,
  ) async {
    if (viewtableData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No data available to send.')),
      );
      return;
    }

    final item = viewtableData.first;

    String formattedDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    String? baseUrl =
        await getActiveOracleIpAddress(); // Example: http://192.168.0.10:8000

    print("viewtableDataaaa $viewtableData");
    // Encode product list
    String productsParam = viewtableData.map((data) {
      return '{${viewtableData.indexOf(data) + 1}|${data['INVOICE_NO']}|${data['ITEM_CODE']}|${data['ITEM_DETAILS']}|${data['PRODUCT_CODE']}|${data['SERIAL_NO']}}';
    }).join('');

    print("productsParam $productsParam");

    String url = Uri.parse('$baseUrl/Generate_dispatch_details_print/').replace(
      queryParameters: {
        "deliveryno": dispatchNo,
        "region": item['PHYSICAL_WAREHOUSE'] ?? '',
        "transportor_Name": item['TRANSPORTER_NAME'] ?? '',
        "pickid": item['PICK_ID'] ?? '',
        "pickmanname": item['PICKMAN_NAME'] ?? '',
        "vehicleNo": item['VEHICLE_NO'] ?? '',
        "driverName": item['DRIVER_NAME'] ?? '',
        "driverMobileNo": item['DRIVER_MOBILENO'] ?? '',
        "date": formatDate(item['DATE']),
        "customerNo": item['CUSTOMER_NUMBER'] ?? '',
        "customername": item['CUSTOMER_NAME'] ?? '',
        "customersite": item['CUSTOMER_SITE_ID'] ?? '',
        "deliveryaddress": item['DELIVERYADDRESS'] ?? '',
        "remmarks": item['REMARKS'] ?? '',
        'salesmanremmarks': item['SALESMANREMARKS'] ?? '',
        "itemtotalqty": viewtableData
            .fold(
                0,
                (sum, item) =>
                    sum +
                    (int.tryParse(item['TRUCK_SEND_QTY']?.toString() ?? '0') ??
                        0))
            .toString(),
        "products_param": productsParam,
      },
    ).toString();

    if (await canLaunch(url)) {
      await launch(url); // this opens in new window on web
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch URL')),
      );
    }
  }

  // _launchUrldetailed(
  //   BuildContext context,
  //   String dispatchNo,
  // ) async {
  //   List<String> productDetails = [];
  //   int snoCounter = 1;

  //   print("viewtableData: $viewtableData");

  //   List<Map<String, dynamic>> mergeTableData(List<Map<String, dynamic>> data) {
  //     Map<String, Map<String, dynamic>> mergedData = {};

  //     for (var item in data) {
  //       String key = '${item['ITEM_CODE']}-${item['ITEM_DETAILS']}';
  //       int currentQty =
  //           int.tryParse(item['TRUCK_SEND_QTY']?.toString() ?? '0') ?? 0;

  //       if (mergedData.containsKey(key)) {
  //         int existingQty = mergedData[key]!['sendqty'] ?? 0;
  //         mergedData[key]!['sendqty'] = existingQty + currentQty;
  //       } else {
  //         mergedData[key] = {
  //           'sno': snoCounter++,
  //           'invoiceno': item['INVOICE_NO'],
  //           'itemcode': item['ITEM_CODE'],
  //           'itemdetails': item['ITEM_DETAILS'],
  //           'productcode': item['PRODUCT_CODE'],
  //           'serialno': item['SERIAL_NO'],
  //           'sendqty': currentQty,
  //         };
  //       }
  //     }

  //     return mergedData.values.toList();
  //   }

  //   // Merge table data
  //   List<Map<String, dynamic>> mergedData = mergeTableData(viewtableData);

  //   for (int i = 0; i < viewtableData.length; i++) {
  //     var data = viewtableData[i];

  //     String formattedProduct =
  //         "{${i + 1}|${data['INVOICE_NO']}|${data['ITEM_CODE']}|${data['ITEM_DETAILS']}|${data['PRODUCT_CODE']}|${data['SERIAL_NO']}}";

  //     productDetails.add(formattedProduct);
  //   }

  //   String productDetailsString = productDetails.join(',');
  //   DateTime today = DateTime.now();
  //   String formattedDate = DateFormat('dd-MMM-yyyy').format(today);

  //   if (viewtableData.isNotEmpty) {
  //     final item = viewtableData.first;

  //     String region = Uri.encodeComponent(item['PHYSICAL_WAREHOUSE'] ?? '');
  //     String transporterName =
  //         Uri.encodeComponent(item['TRANSPORTER_NAME'] ?? 'null');
  //     String vehicleNo = Uri.encodeComponent(item['VEHICLE_NO'] ?? 'null');
  //     String driverName = Uri.encodeComponent(item['DRIVER_NAME'] ?? 'null');
  //     String driverMobileNo =
  //         Uri.encodeComponent(item['DRIVER_MOBILENO'] ?? 'null');
  //     String customerNo =
  //         Uri.encodeComponent(item['CUSTOMER_NUMBER'] ?? 'null');
  //     String customerName =
  //         Uri.encodeComponent(item['CUSTOMER_NAME'] ?? 'null');
  //     String customerSite =
  //         Uri.encodeComponent(item['CUSTOMER_SITE_ID'] ?? 'null');
  //     String remarks = Uri.encodeComponent(item['SALESMANREMARKS'] ?? 'null');
  //     String deliveryAddress =
  //         Uri.encodeComponent(item['DELIVERYADDRESS'] ?? 'null');

  //     // Calculate total quantity
  //     int totalSendQty = viewtableData.fold(0, (sum, item) {
  //       return sum +
  //           (int.tryParse(item['TRUCK_SEND_QTY']?.toString() ?? '0') ?? 0);
  //     });

  //     print('Total Send Qty: $totalSendQty');

  //     final ipAddress = await getActiveIpAddress();

  //     String dynamicUrl =
  //         '$ipAddress/Generate_dispatch_details_print/$dispatchNo/$region/$transporterName/$vehicleNo/$driverName/$driverMobileNo/$formattedDate/$customerNo/$customerName/$customerSite/$deliveryAddress/$remarks/$totalSendQty/$productDetailsString/';

  //     print('Generated URL: $dynamicUrl');

  //     final encodedUrl = Uri.parse(dynamicUrl);

  //     if (await canLaunchUrl(encodedUrl)) {
  //       await launchUrl(encodedUrl, mode: LaunchMode.externalApplication);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Could not launch $dynamicUrl')),
  //       );
  //     }
  //   }
  // }
}
