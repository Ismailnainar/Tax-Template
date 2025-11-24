import 'dart:io';
import 'package:aljeflutterapp/dispatch/shipmenttabledesign.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui';
import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';
import 'package:aljeflutterapp/Reports/newtabledesign.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;

class Inter_ORG_Transfer extends StatefulWidget {
  final Function togglePage;
  const Inter_ORG_Transfer(this.togglePage, {super.key});
  @override
  State<Inter_ORG_Transfer> createState() => _Inter_ORG_TransferState();
}

class _Inter_ORG_TransferState extends State<Inter_ORG_Transfer> {
  final TextEditingController salesmanIdController = TextEditingController();

  List<Map<String, dynamic>> filteredData = [];
  bool _isLoadingData = true;

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSalesmanName();
    postLogData("Inter ORG Transfer", "Opened");
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
    postLogData("Inter ORG Transfer", "Closed");
  }

  String? saveloginname = '';
  String? saveloginrole = '';
  String? salesloginno = '';
  String? commersialname = '';
  String? commersialrole = '';

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
      saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
      salesloginno = prefs.getString('salesloginno') ?? 'Unknown ID';
      commersialrole =
          prefs.getString('commersialrole') ?? 'Unknown commersialrole';
      commersialname =
          prefs.getString('commersialname') ?? 'Unknown commersialname';
    });
  }

  void _search() {
    String searchId = salesmanIdController.text.trim();

    // Perform the filtering
    setState(() {});
  }

  bool _isSecondRowVisible = false;

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget _buildTextFieldDesktop(String label, String value, IconData icon,
      bool readonly, FocusNode fromfocusnode, FocusNode tofocusnode) {
    final FocusNode fromFocusNode = fromfocusnode;
    final FocusNode toFocusNode = tofocusnode;
    double screenWidth = MediaQuery.of(context).size.width;
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
                          message: value,
                          child: TextFormField(
                            focusNode: fromfocusnode,
                            readOnly: readonly,
                            onFieldSubmitted: (_) => _fieldFocusChange(
                                context, fromfocusnode, tofocusnode),
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
                              fillColor: readonly
                                  ? Color.fromARGB(255, 234, 234,
                                      234) // Change fill color when readOnly is true
                                  : Color.fromARGB(255, 250, 250,
                                      250), // Default color when not readOnly
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0,
                              ),
                            ),
                            controller: TextEditingController(text: value),
                            style: TextStyle(
                                color: Color.fromARGB(255, 73, 72, 72),
                                fontSize: 15),
                            // onEditingComplete: () => _fieldFocusChange(
                            //     context, fromFocusNode, toFocusNode),
                          ),
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

  List<String> ColumnNameList = [];

  List<String> ColumnvalueList = [];

  TextEditingController ShipmentController = TextEditingController();
  List<String> columnHeaders = [];
  FocusNode ShipmentIdFocusnode = FocusNode();
  FocusNode Searchbuttonfocusnode = FocusNode();

  Future<void> fetchColumnHeaders() async {
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
        // await fetchData();
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

  bool _isProcessing = false; // Flag to track if the operation is ongoing
  Future<void> fetchColumnValueList(
      String invoicestatus, String columnanametext) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String salesloginrole = prefs.getString('salesloginrole') ?? '';
    String salesloginno = (salesloginrole == 'Salesman')
        ? (prefs.getString('salesloginno') ?? '')
        : '';
    final IpAddress = await getActiveIpAddress();

    final String url =
        '$IpAddress/GetUndeliveredData_columnName_valuesView/$salesloginno/$invoicestatus/$columnanametext/';
    print("urllllll: $url");

    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    // Show processing dialog
    _showProcessingDialog();

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
        var data = json.decode(decodedBody);

        if (data is List && data.isNotEmpty) {
          List<String> tempColumnNames = data.map((e) => e.toString()).toList();
          setState(() {
            ColumnvalueList = tempColumnNames;
            print("column values $ColumnvalueList");
          });
        } else {
          print('No column names found in the response');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching column names: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        // Close the processing dialog
        Navigator.of(context, rootNavigator: true).pop();
      }
      // FocusScope.of(context).requestFocus(ColumnValueFocusNode);
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
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  String? fromorgcode,
      fromorgname,
      toorgcode,
      toorgname,
      transfertype,
      shipmentno,
      receiptno,
      columnName,
      columnValue;

  // Add this variable to track if search was clicked
  bool _hasSearched = false;

  List<String> typeList = ["Shipment Number"];

  bool _filterEnabledtype = true;
  int? _hoveredIndextype;
  int? _selectedIndextype;

  String? TypeSelectedValue;
  FocusNode TypeFocusNode = FocusNode();

  TextEditingController TransferTypeController =
      TextEditingController(text: 'Shipment Number');
  Widget _buildSearchTypeDropdown() {
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
                          ? screenWidth * 0.13
                          : screenWidth * 0.4,
                      child: TransferTypeDropdown()),
                ],
              ),
            ),
            SizedBox(width: 3),
          ],
        ),
      ),
    );
  }

  Widget TransferTypeDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex = typeList.indexOf(TransferTypeController.text);
            if (currentIndex < typeList.length - 1) {
              setState(() {
                _selectedIndextype = currentIndex + 1;
                // Take only the customer number part before the colon
                TransferTypeController.text =
                    typeList[currentIndex + 1].split(':')[0];
                _filterEnabledtype = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = typeList.indexOf(TransferTypeController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndextype = currentIndex - 1;
                // Take only the customer number part before the colon
                TransferTypeController.text =
                    typeList[currentIndex - 1].split(':')[0];
                _filterEnabledtype = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: TypeFocusNode,
          controller: TransferTypeController,
          onSubmitted: (String? suggestion) async {
            _fieldFocusChange(context, TypeFocusNode, ShipmentIdFocusnode);
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
              _filterEnabledtype = true;
              TypeSelectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabledtype && pattern.isNotEmpty) {
            return typeList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return typeList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = typeList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndextype = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndextype = null;
            }),
            child: Container(
              color: _selectedIndextype == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndextype == null &&
                          typeList.indexOf(TransferTypeController.text) == index
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
          setState(() {
            _selectedIndextype = typeList.indexOf(suggestion);
            // Take only the customer number part before the colon
            TransferTypeController.text = suggestion.split(':')[0];
            TypeSelectedValue = suggestion;
            _filterEnabledtype = false;
          });

          _fieldFocusChange(context, TypeFocusNode, ShipmentIdFocusnode);
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

  bool exportenable = false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return Scaffold(
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
                                  Icons.compare_arrows,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Inter ORG Transfer',
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
                    height: screenheight * 0.83,
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
                        crossAxisAlignment: Responsive.isDesktop(context)
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        mainAxisAlignment: Responsive.isDesktop(context)
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.start,
                            runSpacing: 5,
                            children: [
                              SizedBox(
                                width: Responsive.isDesktop(context) ? 30 : 0,
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
                                      Padding(
                                        padding: const EdgeInsets.only(top: 0),
                                        child: Row(
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.list,
                                                    size: 14,
                                                    color: Colors.blue[600]),
                                                SizedBox(width: 8),
                                                Text("Document No Type ",
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
                                            child: _buildSearchTypeDropdown()),
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
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Text("Document No",
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
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Color.fromARGB(
                                                              201,
                                                              132,
                                                              132,
                                                              132),
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
                                                      // filled:
                                                      //     true, // Enable the background fill
                                                      // fillColor: Color.fromARGB(
                                                      //     255,
                                                      //     250,
                                                      //     250,
                                                      //     250), // Default color when not readOnly
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        vertical: 5.0,
                                                        horizontal: 10.0,
                                                      ),
                                                    ),
                                                    controller:
                                                        ShipmentController,
                                                    focusNode:
                                                        ShipmentIdFocusnode,
                                                    onFieldSubmitted: (_) {
                                                      _fieldFocusChange(
                                                          context,
                                                          ShipmentIdFocusnode,
                                                          Searchbuttonfocusnode);
                                                    },
                                                    style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 73, 72, 72),
                                                        fontSize: 12),
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
                              SizedBox(
                                width: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 45),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    // Validate required fields
                                    if (ShipmentController.text.isEmpty) {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("Missing Information"),
                                            content: Text(
                                                "Please fill in all required fields."),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: Text("OK"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      return;
                                    } else {
                                      setState(() {
                                        _hasSearched =
                                            false; // Reset _hasSearched
                                      });

                                      await Future.delayed(Duration(
                                          milliseconds:
                                              100)); // Small delay to allow state update

                                      setState(() {
                                        transfertype =
                                            TransferTypeController.text;
                                        columnName = ShipmentController.text;
                                        _hasSearched = true;
                                      });
                                      exportenable = true;

                                      await fetchData(
                                          transfertype!, columnName!);

                                      FocusScope.of(context)
                                          .requestFocus(ShipmentIdFocusnode);
                                      print(
                                          "tansfer number type ${TransferTypeController.text}");
                                    }

                                    // Always print the ShipmentController.text, whether empty or not
                                    print("Search clicked with:");
                                    print(
                                        "Shipment No: ${ShipmentController.text}");

                                    postLogData("Inter ORG Transfer",
                                        "${transfertype} ${ShipmentController.text} Search");
                                  },
                                  focusNode: Searchbuttonfocusnode,
                                  icon: Icon(Icons.search, color: Colors.white),
                                  label: Text(
                                    '',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: buttonColor,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              if (exportenable)
                                Padding(
                                  padding: EdgeInsets.only(top: 45),
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      if (ShipmentController.text.isEmpty) {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return AlertDialog(
                                              title:
                                                  Text("Missing Information"),
                                              content: Text(
                                                  "Please fill in all required fields."),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: Text("OK"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        return;
                                      }

                                      await fetchColumnHeaders();
                                      setState(() {
                                        transfertype =
                                            TransferTypeController.text;
                                        columnName = ShipmentController.text;

                                        print(
                                            "tansfer number type ${TransferTypeController.text} $columnName");
                                        _hasSearched =
                                            true; // Set _hasSearched to true again
                                      });
                                      await fetchData(
                                          transfertype!, columnName!);
                                      await fetchDatadetails(
                                        transfertype!,
                                        columnName!,
                                      );
                                      await fetchDatadetails(
                                        transfertype!,
                                        columnName!,
                                      );

                                      fromorgcode = FromOrgCodeController.text;
                                      fromorgname = FromOrgNameController.text;

                                      toorgcode = ToOrgCodeController.text;
                                      toorgname = ToOrgNameController.text;

                                      shipmentno =
                                          ShipmentNumberController.text;
                                      receiptno = ReceiptNumberController.text;

                                      print(
                                          "shipment no $fromorgcode $fromorgname $toorgcode $toorgname");
                                      // Check if the data is empty
                                      if (tableData.isEmpty) {
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

                                      // Convert tableData to a format suitable for export
                                      List<List<dynamic>> convertedData =
                                          tableData.map((map) {
                                        return columnHeaders
                                            .map((header) => map.get(header))
                                            .toList();
                                      }).toList();

// Get column names
                                      List<String> columnNames =
                                          getDisplayedColumns();
                                      await createExcel(
                                          columnNames,
                                          convertedData,
                                          columnName!,
                                          transfertype!,
                                          shipmentno!,
                                          receiptno!,
                                          fromorgcode!,
                                          fromorgname!,
                                          toorgcode!,
                                          toorgname!);

                                      postLogData("Inter ORG Transfer",
                                          "Excel ${transfertype} Export");
                                    },
                                    icon: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: SvgPicture.asset(
                                        'assets/images/excel.svg',
                                        width: 20,
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                    label: Text(
                                      'Export',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: buttonColor,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: Responsive.isDesktop(context) ? 520 : 790,
                            child: !_hasSearched
                                ? Center(
                                    child: Text(
                                      'Kindly use the search button to view results',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  )
                                : ShipmentTablePage(
                                    transfertype: transfertype,
                                    columnName: columnName,
                                    togglePage: widget.togglePage,
                                  ),
                          )
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

  List<shipmentDetail> tableData = [];
  bool isLoading = true;
  String errorMessage = '';
  Future<void> fetchData(
    String transfertype,
    String columnName,
  ) async {
    print("Fetching All Data with:");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String salesloginrole = prefs.getString('salesloginrole') ?? '';
    String saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename') ?? '';
    String salesloginno = (salesloginrole == 'Salesman')
        ? (prefs.getString('salesloginno') ?? '')
        : '';

    print("Salesman No : $salesloginno");

    final IpAddress = await getActiveIpAddress();

    final encodedTransfertype = Uri.encodeComponent(transfertype);
    final encodedColumnName = Uri.encodeComponent(columnName);
    final encodedWarehouse = Uri.encodeComponent(saleslogiOrgwarehousename);

    String apiUrl =
        "$IpAddress/Shipment_detialsView/$encodedTransfertype/$encodedColumnName/$encodedWarehouse/";

    List<shipmentDetail> allData = [];

    print("Encoded URL: $apiUrl");

    try {
      while (apiUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(apiUrl));
        print("Fetching from URL: $apiUrl");

        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
          final jsonResponse = json.decode(decodedBody);

          // ✅ Check for warehouse mismatch even when results are empty
          if (jsonResponse is Map<String, dynamic>) {
            final message = jsonResponse['Message'];
            final results = jsonResponse['results'] ?? [];

            if (results.isEmpty && message != null) {
              await showDialog(
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
                      minWidth: 280, // Minimum width for smaller screens
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
                          Text(
                            message.toString(),
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                elevation: 2,
                              ),
                              onPressed: () {
                                setState(() {
                                  ShipmentController.clear();
                                  _hasSearched = false;
                                  exportenable = false;
                                });
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              },
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

              (context as StatefulElement).state.setState(() {
                isLoading = false;
              });

              return;
            }

            // ✅ Add non-empty results
            allData.addAll((results as List)
                .map((item) => shipmentDetail.fromJson(item))
                .toList());

            // Check for pagination
            apiUrl = jsonResponse['next']?.toString() ?? "";
          } else {
            throw Exception("Unexpected response format.");
          }
        } else {
          throw Exception(
              "Failed to load data, status code: ${response.statusCode}");
        }
      }

      (context as StatefulElement).state.setState(() {
        tableData = allData;
        isLoading = false;
      });
    } catch (e) {
      (context as StatefulElement).state.setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal:
                MediaQuery.of(context).size.width * 0.1, // 10% padding on sides
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
              minWidth: 280, // Minimum width for smaller screens
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
                    "Data Mismatch",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Content
                  Text(
                    'There is No document Num available',
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                      onPressed: () {
                        setState(() {
                          ShipmentController.clear();
                          _hasSearched = false;
                          exportenable = false;
                        });
                        Navigator.of(context, rootNavigator: true).pop();
                      },
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

      // await showDialog(
      //   context: context,
      //   builder: (BuildContext context) => AlertDialog(
      //     title: const Text("Error"),
      //     content: Text(e.toString()),
      //     actions: [
      //       TextButton(
      //         onPressed: () => Navigator.of(context).pop(),
      //         child: const Text("OK"),
      //       ),
      //     ],
      //   ),
      // );

      print("Error fetching data: $e");
    }
  }

  TextEditingController ShipmentNumberController = TextEditingController();
  TextEditingController ReceiptNumberController = TextEditingController();

  TextEditingController ShipmentDateController = TextEditingController();

  TextEditingController FromOrgCodeController = TextEditingController();

  TextEditingController FromOrgNameController = TextEditingController();

  TextEditingController ToOrgCodeController = TextEditingController();

  TextEditingController ToOrgNameController = TextEditingController();
  Future<void> fetchDatadetails(
    String transfertype,
    String columnName,
  ) async {
    print("Fetching All Data...");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String salesloginrole = prefs.getString('salesloginrole') ?? '';
    String saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename') ?? '';
    String salesloginno = (salesloginrole == 'Salesman')
        ? (prefs.getString('salesloginno') ?? '')
        : '';
    print("Salesman No : $salesloginno");

    final IpAddress = await getActiveIpAddress();

    String apiUrl =
        "$IpAddress/Shipment_detialsView/${transfertype}/${columnName}/$saleslogiOrgwarehousename/";
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

          // Check for error message in a 200 response
          if (jsonResponse is Map && jsonResponse.containsKey('error')) {
            String errorMsg = jsonResponse['error'];
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Invalid Warehouse"),
                content: Text(errorMsg),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
            return; // Exit function early
          }

          List<dynamic> results = jsonResponse['results'] ?? [];

          for (var item in results) {
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

          apiUrl = jsonResponse['next']?.toString() ?? "";
        } else {
          throw Exception(
              "Failed to load data, status code: ${response.statusCode}");
        }
      }

      setState(() {
        // You can assign tableData here if needed
        // isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      print("Error fetching data: $e");
    }
  }

  List<String> getDisplayedColumns() {
    return columnHeaders;
  }

  Future<void> createExcel(
      List<String> columnNames,
      List<List<dynamic>> data,
      String columnName,
      String transfertype,
      String shipmentno,
      String receiptno,
      String fromorgcode,
      String fromorgname,
      String toorgcode,
      String toorgname) async {
    try {
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      // Add title text above the table
      final Range titleRange = sheet.getRangeByIndex(1, 1);
      titleRange.setText('Inter ORG Reports');
      titleRange.cellStyle.fontSize = 16;
      titleRange.cellStyle.bold = true;

      // Add transfer type information
      final Range transferTypeRange = sheet.getRangeByIndex(2, 2);
      transferTypeRange.setText('Shipment no: $shipmentno');
      transferTypeRange.cellStyle.fontSize = 12;
      transferTypeRange.cellStyle.italic = true;

      // Add transfer type information
      final Range transferTypeRangereceipt = sheet.getRangeByIndex(2, 3);
      transferTypeRangereceipt.setText('Receipt No: $receiptno');
      transferTypeRangereceipt.cellStyle.fontSize = 12;
      transferTypeRangereceipt.cellStyle.italic = true;

      // Add from org code
      final Range fromOrgCodeRange = sheet.getRangeByIndex(3, 2);
      fromOrgCodeRange.setText('From Org Code: $fromorgcode');
      fromOrgCodeRange.cellStyle.fontSize = 12;
      fromOrgCodeRange.cellStyle.italic = true;

      // Add from org name
      final Range fromOrgNameRange = sheet.getRangeByIndex(3, 3);
      fromOrgNameRange.setText('From Org Name: $fromorgname');
      fromOrgNameRange.cellStyle.fontSize = 12;
      fromOrgNameRange.cellStyle.italic = true;

      // Add to org code
      final Range toOrgCodeRange = sheet.getRangeByIndex(4, 2);
      toOrgCodeRange.setText('To Org Code: $toorgcode');
      toOrgCodeRange.cellStyle.fontSize = 12;
      toOrgCodeRange.cellStyle.italic = true;

      // Add to org name
      final Range toOrgNameRange = sheet.getRangeByIndex(4, 3);
      toOrgNameRange.setText('To Org Name: $toorgname');
      toOrgNameRange.cellStyle.fontSize = 12;
      toOrgNameRange.cellStyle.italic = true;

      // Add empty row for spacing
      sheet.getRangeByIndex(3, 1);

      // Start table from row 4 (leaving space above for title and subtitle)
      int tableStartRow = 6;

      // Add column headers
      for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
        final Range range = sheet.getRangeByIndex(tableStartRow, colIndex + 1);
        range.setText(columnNames[colIndex]);
        range.cellStyle.backColor = '#550A35';
        range.cellStyle.fontColor = '#F5F5F5';
        range.cellStyle.bold = true;
      }

      // Add table data
      for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
        final List<dynamic> rowData = data[rowIndex];
        for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
          final Range range =
              sheet.getRangeByIndex(rowIndex + tableStartRow + 1, colIndex + 1);
          range.setText(rowData[colIndex]?.toString() ?? '');
        }
      }

      // Auto-fit columns for better visibility
      for (int i = 1; i <= columnNames.length; i++) {
        sheet.autoFitColumn(i);
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
          ..setAttribute('download', 'Inter ORG Details ($columnName).xlsx')
          ..click();
      } else {
        final String path = (await getApplicationSupportDirectory()).path;
        final String fileName = Platform.isWindows
            ? '$path\\Excel Inter ORG Details ($columnName).xlsx'
            : '$path/Excel Inter ORG Details ($columnName).xlsx';
        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);
        OpenFile.open(fileName);
      }
    } catch (e) {
      print('Error in createExcel: $e');
    }
  }
}
