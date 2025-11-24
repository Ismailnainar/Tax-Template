import 'dart:convert';
import 'dart:ui';

import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data'; // for Uint8List
import 'dart:io'; // for File
import 'package:path_provider/path_provider.dart'; // for getApplicationDocumentsDirectory
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';

class MasterProductCodeUPdate extends StatefulWidget {
  const MasterProductCodeUPdate({super.key});

  @override
  State<MasterProductCodeUPdate> createState() =>
      _MasterProductCodeUPdateState();
}

class _MasterProductCodeUPdateState extends State<MasterProductCodeUPdate> {
  @override
  void initState() {
    super.initState();
    _loadSalesmanName();

    postLogData("Update ProductCode", "Opened");
  }

  @override
  void dispose() {
    postLogData("Update ProductCode", "Closed");
    super.dispose();
  }

  String? saveloginname = '';

  String? saveloginrole = '';
  String? salesloginno = '';

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
      saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
      salesloginno = prefs.getString('salesloginno') ?? 'Unknown ID';
    });
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget _buildTextFieldDesktop(
      String label,
      TextEditingController value,
      IconData icon,
      bool readonly,
      FocusNode fromfocusnode,
      FocusNode tofocusnode) {
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
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 5.0,
                              horizontal: 10.0,
                            ),
                          ),
                          controller: value,
                          style: TextStyle(
                              color: Color.fromARGB(255, 73, 72, 72),
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
    );
  }

  TextEditingController ItemcodeController = TextEditingController();

  TextEditingController ItemDescriptionsController = TextEditingController();

  TextEditingController OldProductCodeController = TextEditingController();

  TextEditingController NewProductCodeController = TextEditingController();
  FocusNode itemcodeFocusNode = FocusNode();
  FocusNode ItemdescriptionFocusNode = FocusNode();
  FocusNode savebuttonFocusNode = FocusNode();

  FocusNode NewProductCodeFocusNode = FocusNode();

  FocusNode oldProductcodeFocusnode = FocusNode();

  FocusNode changeproductcodebuttonfocusnode = FocusNode();

  List<String> _parseOldProductCode(String oldProductCodeRaw) {
    // Remove braces and split the string
    oldProductCodeRaw = oldProductCodeRaw.replaceAll(RegExp(r'[{}\"]'), '');
    return oldProductCodeRaw.split(',').map((e) => e.trim()).toList();
  }

  void _onSearchPressed(String itemcode) async {
    final IpAddress = await getActiveIpAddress();

    // String itemCode = ItemcodeController.text.trim();
    // Build the URL
    String url = '$IpAddress/updatedfilteredProductcodeGetView/$itemcode/';
    print("print the url : $url");

    try {
      // Make the HTTP GET request
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the response
        final data = json.decode(response.body);

        if (data is List && data.isNotEmpty) {
          // Extract the description
          String description =
              data[0]['DESCRIPTION'] ?? 'No description available';
          String productcode =
              data[0]['CUT_PRODUCT_CODE'] ?? 'No description available';

          // Extract and parse OLD_PRODUCT_CODE
          String oldProductCodeRaw = data[0]['OLD_PRODUCT_CODE'] ?? '';
          List<String> oldProductCodes =
              _parseOldProductCode(oldProductCodeRaw);

          // Create the filtered table data
          List<Map<String, String>> filteredTableData =
              oldProductCodes.map((code) => {'productcode': code}).toList();

          setState(() {
            ItemDescriptionsController.text = description;
            OldProductCodeController.text = productcode;
            filteredData = filteredTableData;
            print("filtered table datasssssssssss $filteredTableData");
          });
        } else {
          _showDialog("Warning", 'There is no item details found');
        }
      } else if (response.statusCode == 404) {
        final responseData = json.decode(response.body);
        if (responseData['detail'] == 'This product is a bypass product.') {
          _showDialog("Warning", 'This itemcode is a bypass product');
        } else {
          _showDialog(
              "Warning", 'No item code found matching the provided ITEM_CODE.');
        }
      } else {
        _showDialog(
            "Error", 'An unexpected error occurred. Please try again later.');
      }
    } catch (e) {
      _showDialog("Error",
          'Failed to connect to the server. Check your network connection.');
    }
  }

  void _showDialog(String heading, String message) {
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
                setState(() {
                  ItemcodeController.clear();

                  ItemDescriptionsController.clear();

                  OldProductCodeController.clear();

                  NewProductCodeController.clear();

                  filteredData = [];
                  FocusScope.of(context).requestFocus(itemcodeFocusNode);
                });
                filteredData = [];
                FocusScope.of(context).requestFocus(itemcodeFocusNode);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return Scaffold(
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
                                  Icons.qr_code_scanner,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Update ProductCode',
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
                                        saveloginrole ?? 'Loading...',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: const Color.fromARGB(
                                                255, 68, 67, 67)),
                                      ),
                                    ),
                                  ],
                                ),
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
                  padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                  child: Container(
                    height: screenheight * 0.84,
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
                        children: [
                          Row(
                            children: [
                              if (saveloginrole == 'salesman') ...[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 16, left: 16, bottom: 10),
                                  child: Text("Salesman No",
                                      style: topheadingbold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 16, left: 5, bottom: 10),
                                  child: Text(
                                    ' - $salesloginno',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ]
                            ],
                          ),
                          Wrap(
                            alignment: WrapAlignment.start,
                            runSpacing: 1,
                            children: [
                              _buildTextFieldDesktop(
                                  'Item Code',
                                  ItemcodeController,
                                  Icons.numbers,
                                  false,
                                  itemcodeFocusNode,
                                  savebuttonFocusNode),
                              SizedBox(
                                width: 10,
                              ),
                              Tooltip(
                                message: '',
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 46.0),
                                  child: Container(
                                    decoration:
                                        BoxDecoration(color: buttonColor),
                                    height: 30,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        print(
                                            "itemcode ${ItemcodeController.text}");

                                        // Check if item code is empty
                                        if (ItemcodeController.text.isEmpty) {
                                          _showDialog("Warning",
                                              'Kindly fill all the fields');
                                          return;
                                        } else {
                                          _onSearchPressed(
                                              ItemcodeController.text);
                                          _fieldFocusChange(
                                            context,
                                            savebuttonFocusNode,
                                            NewProductCodeFocusNode,
                                          );
                                        }
                                      },
                                      focusNode: savebuttonFocusNode,
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
                                            top: 0,
                                            bottom: 0,
                                            left: 8,
                                            right: 8),
                                        child: Icon(
                                          Icons.search,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: Responsive.isDesktop(context)
                                    ? screenWidth * 0.2
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
                                          Text('Item Description',
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
                                                    ? screenWidth * 0.2
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
                                                        ItemdescriptionFocusNode,
                                                    onFieldSubmitted: (_) =>
                                                        _fieldFocusChange(
                                                            context,
                                                            ItemdescriptionFocusNode,
                                                            ItemdescriptionFocusNode),
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
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        vertical: 5.0,
                                                        horizontal: 10.0,
                                                      ),
                                                    ),
                                                    controller:
                                                        ItemDescriptionsController,
                                                    style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 73, 72, 72),
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
                              SizedBox(
                                width: 10,
                              ),
                              _buildTextFieldDesktop(
                                  'Exist ProductCode',
                                  OldProductCodeController,
                                  Icons.numbers,
                                  false,
                                  oldProductcodeFocusnode,
                                  NewProductCodeFocusNode),
                              SizedBox(
                                width: 10,
                              ),
                              _buildTextFieldDesktop(
                                  'New ProductCode',
                                  NewProductCodeController,
                                  Icons.numbers,
                                  false,
                                  NewProductCodeFocusNode,
                                  changeproductcodebuttonfocusnode),
                              SizedBox(
                                width: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 46.0),
                                child: Container(
                                  decoration: BoxDecoration(color: buttonColor),
                                  height: 30,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (ItemcodeController.text.isEmpty &&
                                          NewProductCodeController
                                              .text.isEmpty) {
                                        _showDialog("Warning",
                                            "Kindly fill all the feilds");
                                      } else {
                                        _updateProductCode();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      minimumSize: const Size(45.0, 20.0),
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 0, bottom: 0, left: 8, right: 8),
                                      child: const Text(
                                        'Update',
                                        style: commonWhiteStyle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                              height: screenheight * 0.67, child: _buildTable())
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

  bool isLoading = false;
  String responseMessage = "";
  void _updateProductCode() async {
    String itemcode = ItemcodeController.text.trim();
    String newProductCode = NewProductCodeController.text.trim();
    print("Product code: $newProductCode $itemcode");
    final IpAddress = await getActiveIpAddress();

    final url =
        Uri.parse('$IpAddress/update-product-code/$itemcode/$newProductCode/');
    setState(() {
      isLoading = true;
      responseMessage = "";
    });

    try {
      final response = await http.put(url); // Use PUT method instead of GET

      if (response.statusCode == 200) {
        // Parse the response body to get the message
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('message')) {
          setState(() async {
            await showUpdateSuccessDialog(context);
            responseMessage = responseBody['message']; // Success message
            setState(() {
              ItemcodeController.clear();

              ItemDescriptionsController.clear();

              OldProductCodeController.clear();

              NewProductCodeController.clear();

              filteredData = [];
              FocusScope.of(context).requestFocus(itemcodeFocusNode);
            });
          });
        } else {
          setState(() {
            responseMessage =
                "Failed to update product code."; // Fallback message
          });
        }
      } else {
        // Handle failed response
        setState(() {
          responseMessage =
              "Failed to update product. Status code: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        responseMessage = "Error occurred: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  showUpdateSuccessDialog(BuildContext context) {
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
                'Update Successful!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Your changes have been successfully saved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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

  List<Map<String, dynamic>> filteredData = [];
  bool _isLoading = false;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  Widget _buildTable() {
    // Preprocess tableData to consolidate entries with the same REQ_ID

    return Container(
      width: MediaQuery.of(context).size.width,
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
                color: Colors.white,
                height: MediaQuery.of(context).size.height * 0.7,
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.8
                    : MediaQuery.of(context).size.width * 1,
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _verticalScrollController,
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    child: Column(
                      children: [
                        // Table Header
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _tableHeader("S.No", Icons.format_list_numbered),
                              _tableHeader("Product Code", Icons.print),
                            ],
                          ),
                        ),
                        // Loading Indicator or Table Rows
                        if (_isLoading)
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (filteredData.isNotEmpty)
                          ...filteredData.asMap().entries.map((entry) {
                            int index = entry.key;
                            var data = entry.value;

                            String sNo = (index + 1).toString();

                            String productcode = data['productcode'].toString();

                            bool isEvenRow = index % 2 == 0;
                            Color rowColor = isEvenRow
                                ? Color.fromARGB(224, 255, 255, 255)
                                : Color.fromARGB(224, 255, 255, 255);

                            return GestureDetector(
                              onDoubleTap: () async {},
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 3),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        height: 30,
                                        width: Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.2
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Text(sNo,
                                            textAlign: TextAlign.start,
                                            style: TableRowTextStyle),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 30,
                                        width: Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.2
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Text(productcode,
                                            textAlign: TextAlign.start,
                                            style: TableRowTextStyle),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList()
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Text("No product available in staging"),
                          ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableHeader(String text, IconData icon) {
    return Flexible(
      child: Container(
        width: Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.2
            : MediaQuery.of(context).size.width * 0.8,
        height: Responsive.isDesktop(context) ? 25 : 30,
        decoration: TableHeaderColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align to the start
          crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
          children: [
            Icon(icon, size: 15, color: Colors.blue),
            SizedBox(width: 2),
            Expanded(
              // Ensures the text adjusts properly
              child: Text(
                text,
                textAlign: TextAlign.left, // Align text to the start (left)
                style: commonLabelTextStyle,
                overflow: TextOverflow.ellipsis, // Prevent overflow
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableRow(String data, Color? rowColor, {String? tooltipMessage}) {
    return Flexible(
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: rowColor,
          border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align to the start
          crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
          children: [
            Expanded(
              // Ensures the text adjusts properly
              child: tooltipMessage != null
                  ? Tooltip(
                      message: tooltipMessage,
                      child: SelectableText(
                        data,
                        textAlign: TextAlign.left,
                        style: commonLabelTextStyle,
                        showCursor: false,
                        // overflow: TextOverflow.ellipsis,
                        cursorColor: Colors.blue,
                        cursorWidth: 2.0,
                        toolbarOptions:
                            ToolbarOptions(copy: true, selectAll: true),
                        onTap: () {
                          // Optional: Handle single tap if needed
                        },
                      ),

                      // Text(
                      //   data,
                      //   textAlign: TextAlign.left, // Align text to the start
                      //   style: TableRowTextStyle,
                      //   overflow: TextOverflow.ellipsis,
                      // ),
                    )
                  : SelectableText(
                      data,
                      textAlign: TextAlign.left,
                      style: commonLabelTextStyle,
                      showCursor: false,
                      // overflow: TextOverflow.ellipsis,
                      cursorColor: Colors.blue,
                      cursorWidth: 2.0,
                      toolbarOptions:
                          ToolbarOptions(copy: true, selectAll: true),
                      onTap: () {
                        // Optional: Handle single tap if needed
                      },
                    ),
              //  Text(
              //     data,
              //     textAlign: TextAlign.left, // Align text to the start
              //     style: TableRowTextStyle,
              //     overflow: TextOverflow.ellipsis,
              //   ),
            ),
          ],
        ),
      ),
    );
  }
}
