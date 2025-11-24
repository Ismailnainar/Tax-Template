import 'dart:async';
import 'dart:typed_data'; // for Uint8List
import 'dart:io'; // for File
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
import 'package:url_launcher/url_launcher.dart';

class Generatepicking extends StatefulWidget {
  final String pagename;

  Generatepicking(this.pagename);

  @override
  State<Generatepicking> createState() => _GeneratepickingState();
}

class _GeneratepickingState extends State<Generatepicking> {
  bool _isLoading = true;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  String _formatDate(String dateString) {
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('dd-MMM-yyyy').format(parsedDate).toUpperCase();
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildTextFieldDesktop(
    String label,
    String value,
    IconData icon,
    bool readOnly,
  ) {
    String formattedValue = label == 'Delivery Date' && value.isNotEmpty
        ? _formatDate(value) // Call the _formatDate function
        : value;
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
                                    ? Color.fromARGB(255, 240, 239,
                                        239) // Change fill color when readOnly is true
                                    : Color.fromARGB(255, 250, 250,
                                        250), // Default color when not readOnly
                              ),
                              controller:
                                  TextEditingController(text: formattedValue),
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

  List<Map<String, dynamic>> tableData = [];

  Timer? _timer;
  @override
  void initState() {
    super.initState();
    // _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
    //   fetchLastPickNo(); // Fetch serial number every 10 sec
    // });
    _updatecount();
    _updatesendqty();
    _loadSalesmanName();
    fetchAccessControl();
    fetchRegionAndWarehouse();
    fetchStaffList();
    fetchDataReqnO();
    fetchLastPickNo();
    print('pagenmae ${widget.pagename}');

    // Initialize controllers and focus nodes for each row
    tableData.forEach((row) {
      _controllers.add(TextEditingController(text: "0"));
      _focusNodes.add(FocusNode());
    });

    postLogData("Generate Picking", "Opened");
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    // Dispose of controllers, focus nodes, and cancel the timer
    _controllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((focusNode) => focusNode.dispose());

    postLogData("Generate Picking", "Closed");
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

  List<double> columnWidths = [100, 80, 120, 450, 130, 120, 140, 100];

  Widget _buildTable() {
    (widget.pagename == 'Re-Dispatch' ? isChecked = true : isChecked = false);

    if (widget.pagename == 'Re-Dispatch')
      setState(() {
        isChecked = true; // Update the state
        for (int i = 0; i < tableData.length; i++) {
          double disreqQty =
              double.tryParse(_removeDecimalIf(tableData[i]['disreqqty'])) ??
                  0.0;
          if (isChecked) {
            _controllers[i].text = disreqQty.toString();
            tableData[i]['sendqty'] = disreqQty.toString(); // Update sendqty

            _updatesendqty();
          } else {
            _controllers[i].text = ""; // Clear text
            tableData[i]['sendqty'] = ""; // Clear sendqty if unchecked
            totalSendqtyController.text = '0';
          }
        }
      });
    double screenHeight = MediaQuery.of(context).size.height;
    double widthFactor = Responsive.isDesktop(context) ? 0.79 : 1.7;
    double heightFactor =
        Responsive.isDesktop(context) ? screenHeight * 0.3 : 250;
    double rowHeight = Responsive.isDesktop(context) ? 25 : 30;

    List<Map<String, dynamic>> headers = [
      {"icon": Icons.receipt_long, "text": "Invoice.No"},
      {"icon": Icons.format_list_numbered, "text": "I.lineNo"},
      {"icon": Icons.qr_code, "text": "Item Code"},
      {"icon": Icons.info_outline, "text": "Item Description"},
      {"icon": Icons.inventory, "text": "Qty.Invoiced"},
      {"icon": Icons.add_shopping_cart, "text": "Qty.Req"},
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
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(header['icon'],
                                            size: 15, color: Colors.blue),
                                        SizedBox(width: 2),
                                        Text(header['text'],
                                            style: commonLabelTextStyle,
                                            textAlign: TextAlign.center),
                                        if (header['text'] == "Qty.Picking")
                                          if (header['text'] == "Qty.Picking")
                                            StatefulBuilder(builder:
                                                (BuildContext context,
                                                    StateSetter setState) {
                                              return Tooltip(
                                                message: "Select All",
                                                child: Transform.scale(
                                                  scale:
                                                      0.6, // Adjust the scale factor to make the checkbox smaller
                                                  child: Checkbox(
                                                    value: isChecked,
                                                    onChanged: (value) {
                                                      if (widget.pagename !=
                                                          'Re-Dispatch')
                                                        setState(() {
                                                          isChecked =
                                                              value!; // Update the state
                                                          for (int i = 0;
                                                              i <
                                                                  tableData
                                                                      .length;
                                                              i++) {
                                                            double disreqQty =
                                                                double.tryParse(_removeDecimalIf(
                                                                        tableData[i]
                                                                            [
                                                                            'disreqqty'])) ??
                                                                    0.0;
                                                            if (isChecked) {
                                                              _controllers[i]
                                                                      .text =
                                                                  disreqQty
                                                                      .toString();
                                                              tableData[i][
                                                                      'sendqty'] =
                                                                  disreqQty
                                                                      .toString(); // Update sendqty

                                                              _updatesendqty();
                                                            } else {
                                                              _controllers[i]
                                                                      .text =
                                                                  ""; // Clear text
                                                              tableData[i][
                                                                      'sendqty'] =
                                                                  ""; // Clear sendqty if unchecked
                                                              totalSendqtyController
                                                                  .text = '0';
                                                            }
                                                          }
                                                        });
                                                    },
                                                  ),
                                                ),
                                              );
                                            })
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          if (_isLoading)
                            Padding(
                              padding: const EdgeInsets.only(top: 60.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (tableData.isNotEmpty)
                            ...tableData.asMap().entries.map((entry) {
                              int index = entry.key;
                              var data = entry.value;
                              return _buildRow(index, data);
                            }).toList()
                          else
                            Padding(
                              padding: const EdgeInsets.only(top: 60.0),
                              child: Text("No data available."),
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

    if (double.parse(data['disreqqty'] ?? '0') == 0) {
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
            _buildDataCell(data['invoiceno'] ?? '', rowColor,
                width: columnWidths[0]),
            _buildDataCell(data['id'] ?? '', rowColor, width: columnWidths[1]),
            _buildDataCell(data['itemcode'] ?? '', rowColor,
                width: columnWidths[2]),
            _buildDataCell(data['itemdetails'] ?? '', rowColor,
                width: columnWidths[3]),
            _buildDataCell(data['invoiceQty'] ?? '', rowColor,
                width: columnWidths[4]),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: 120,
                height: 30,
                decoration: BoxDecoration(
                  color: rowColor,
                  border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Tooltip(
                        message: "Total Dispatch Request Qty",
                        child: Text(
                          data['totaldisreqqty'].toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 128, 34),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "-",
                        textAlign: TextAlign.center,
                        style: TableRowTextStyle,
                      ),
                      SizedBox(width: 10),
                      Tooltip(
                        message: "Pending Dispatch",
                        child: Text(
                          data['disreqqty'].toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromARGB(255, 147, 0, 0),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildTextFieldCell(index, data['disreqqty'] ?? '', rowColor,
                width: columnWidths[6]),
            _buildDataCell(data['status'], rowColor, width: columnWidths[7]),
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

            // Text(
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
          padding: const EdgeInsets.only(bottom: 15),
          child: TextField(
            readOnly: (widget.pagename == 'Re-Dispatch') ? true : false,
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
                                            fontSize: 13, color: Colors.black),
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
                  style: TextStyle(fontSize: 13, color: Colors.black),
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
    // Use the getTotalFinalAmt function to update the total amount
    NoofitemController.text = getcount(tableData).toStringAsFixed(0);
    print("NoofitemController amountttt ${NoofitemController.text}");
  }

  int getcount(List<Map<String, dynamic>> tableData) {
    return tableData.length;
  }

  void _updatesendqty() {
    double totalSendQuantity = 0.0;

    for (int i = 0; i < _controllers.length; i++) {
      double enteredQty = double.tryParse(_controllers[i].text) ?? 0.0;
      tableData[i]['sendqty'] = enteredQty.toString(); // Update tableData

      totalSendQuantity += enteredQty; // Calculate total
    }

    totalSendqtyController.text = _removeDecimalIfWhole(
        totalSendQuantity.toString()); // Format and assign
    print("Total send quantity: ${totalSendqtyController.text}");
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

// Function to get the total send quantity (called during initialization or manual updates)
  double gettotalsendqty(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['sendqty'] ?? '0') ?? 0.0;
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

  TextEditingController _SalesmanNoController = TextEditingController();
  TextEditingController _SalesmanNameController = TextEditingController();

  TextEditingController _InvoiceNumberController = TextEditingController();
  TextEditingController _ReqnoController = TextEditingController();
  TextEditingController _PicknoController = TextEditingController();
  TextEditingController _DateController = TextEditingController();
  TextEditingController _CusidController = TextEditingController();
  TextEditingController _CussiteController = TextEditingController();

  TextEditingController _DeliveryDateController = TextEditingController();
  TextEditingController _CustomerNameController = TextEditingController();
  TextEditingController _RegionController = TextEditingController();

  TextEditingController _WarehousenameNameController = TextEditingController();
  TextEditingController _CustomerNumberController = TextEditingController();

  TextEditingController _Org_idController = TextEditingController();
  TextEditingController _Org_nameController = TextEditingController();
  TextEditingController _Salesman_idmeController = TextEditingController();
  TextEditingController Salesman_channelController = TextEditingController();
  TextEditingController IdController = TextEditingController();

  Future<void> fetchRegionAndWarehouse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';
    await _loadSalesmanName();

    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/Physical_Warehouse/';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Find the entry for the given ORGANIZATION_ID
        final result = data['results'].firstWhere(
          (item) => item['ORGANIZATION_ID'] == saleslogiOrgid,
          orElse: () => null,
        );

        if (result != null) {
          // Update the controllers with fetched values
          setState(() {
            _RegionController.text = result['REGION_NAME'];
            _WarehousenameNameController.text = result['WAREHOUSE_NAME'];
          });
        } else {
          // Clear the controllers if no match is found
          setState(() {
            _RegionController.text = '';
            _WarehousenameNameController.text = '';
          });
        }
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> fetchDataReqnO() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename') ?? '';

    String? returnid = prefs.getString('returnredispatch');
    String? reqedid = prefs.getString('reqno');
    String? reqno = widget.pagename == 'Re-Dispatch' ? returnid : reqedid;

    final IpAddress = await getActiveIpAddress();
    String urlpathname = widget.pagename == 'Re-Dispatch'
        ? 'Filtered_Returndispatch'
        : 'filtered_dispatchrequest';

    final response = await http.get(Uri.parse(
        '$IpAddress/$urlpathname/$reqno/$saleslogiOrgwarehousename/'));
    print(
        "URL DATASDATASDATASDATAS: $IpAddress/$urlpathname/$reqno/$saleslogiOrgwarehousename/");
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
      // final responseData = json.decode(decodedBody);

      final List<dynamic> responseData =
          json.decode(decodedBody); // Ensure this is a list

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
        _DeliveryDateController.text = data['DELIVERY_DATE']?.toString() ?? '';
        _CustomerNameController.text = data['CUSTOMER_NAME']?.toString() ?? '';

        _CustomerNumberController.text =
            data['CUSTOMER_NUMBER']?.toString() ?? '';
        // _RegionController.text = data['ORG_NAME']?.toString() ?? '';
        // _WarehousenameNameController.text =
        //     data['TO_WAREHOUSE']?.toString() ?? '';

        _SalesmanNoController.text = data['SALESMAN_NO']?.toString() ?? '';
        _SalesmanNameController.text = data['SALESMAN_NAME']?.toString() ?? '';
        _Salesman_idmeController.text = data['SALESREP_ID']?.toString() ?? '';
        Salesman_channelController.text =
            data['SALES_CHANNEL']?.toString() ?? '';

        _Org_idController.text = data['ORG_ID']?.toString() ?? '';
        _Org_nameController.text = data['ORG_NAME']?.toString() ?? '';

        // Clear the existing table data and populate with new data
        tableData = [];

        if (data['TABLE_DETAILS'] != null) {
          for (var item in data['TABLE_DETAILS']) {
            tableData.add({
              'Row_id': item['ID']?.toString() ?? '',
              'id': item['LINE_NUMBER']?.toString() ?? '',
              'undel_id': (item['UNDEL_ID'] == null ||
                      item['UNDEL_ID'].toString().isEmpty)
                  ? '0'
                  : item['UNDEL_ID'].toString(),

              'invoiceno': item['INVOICE_NUMBER']?.toString() ?? '',

              'itemcode': item['INVENTORY_ITEM_ID']?.toString() ?? '',
              'itemdetails': item['ITEM_DESCRIPTION']?.toString() ?? '',
              'customer_trx_id': item['CUSTOMER_TRX_ID']?.toString() ?? '',
              'customer_trx_line_id':
                  item['CUSTOMER_TRX_LINE_ID']?.toString() ??
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
          print("tabledataaaaaa $tableData");
          _initializeControllers(); // Initialize controllers based on tableData length
        }
      });
    } else {
      print('Failed to load dispatch request details: ${response.statusCode}');
    }
  }

  Future<void> fetchLastPickNo() async {
    final IpAddress = await getActiveIpAddress();
    final url = '$IpAddress/Generate_Picking_PickId/'; // Ensure URL is correct

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String lastPickId = data['PICK_ID']?.toString() ?? '';

        if (lastPickId.isNotEmpty) {
          // Use RegExp to extract parts from PICK_ID like PICKID:25040876
          RegExp regExp = RegExp(r'^PICKID:(\d{2})(\d{2})(\d+)$');
          Match? match = regExp.firstMatch(lastPickId);

          if (match != null) {
            String year = match.group(1)!; // e.g., '25'
            String month = match.group(2)!; // e.g., '04'
            int lastNumber = int.parse(match.group(3)!); // e.g., 87

            int newNumber = lastNumber + 1;
            String newNumberStr =
                newNumber.toString().padLeft(4, '0'); // zero-padded

            String newPickId =
                'PICKID:$year$month$newNumberStr'; // e.g., PICKID:25040988
            _PicknoController.text = newPickId;
          } else {
            _PicknoController.text =
                lastPickId; // fallback if format doesn’t match
          }
        } else {
          _PicknoController.text = "PICKID:00000001"; // fallback default
        }
      } else {
        _PicknoController.text = "PICKID_ERR_${response.statusCode}";
      }
    } catch (e) {
      _PicknoController.text = "PICKID_EXC";
      print('Exception fetching PICK_ID: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool previewbutton = true;
  @override
  Widget build(BuildContext context) {
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
                  Container(
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
                                  Icons.fact_check,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Generate Picking',
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

                Padding(
                  padding: const EdgeInsets.only(
                      left: 5, right: 5, top: 5, bottom: 5),
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
                                _buildTextFieldDesktop(
                                    'Pick ID',
                                    "${_PicknoController.text}",
                                    Icons.numbers,
                                    true),
                                SizedBox(
                                  width: 10,
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
                                    'Delivery Date',
                                    _DeliveryDateController.text,
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
                                                fontSize: 16,
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
                                              fontSize: 16,
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
                                            0.05),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: Responsive.isDesktop(context)
                                          ? MediaQuery.of(context).size.width *
                                              0.10
                                          : MediaQuery.of(context).size.width *
                                              0.3,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 0),
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
                                        //   bool allFilled = true;

                                        //   for (int i = 0;
                                        //       i < _controllers.length;
                                        //       i++) {
                                        //     if (_controllers[i].text.isEmpty) {
                                        //       allFilled = false;
                                        //       break;
                                        //     }
                                        //   }

                                        //   if (_AssignedStaffController
                                        //       .text.isNotEmpty) {
                                        //     // Show confirmation dialog before proceeding

                                        //     // showDialog(
                                        //     //   context: context,
                                        //     //   builder: (BuildContext context) {
                                        //     //     return AlertDialog(
                                        //     //       title: Row(
                                        //     //         mainAxisAlignment:
                                        //     //             MainAxisAlignment
                                        //     //                 .spaceBetween,
                                        //     //         children: [
                                        //     //           Row(
                                        //     //             children: [
                                        //     //               Icon(Icons.delete,
                                        //     //                   size: 18),
                                        //     //               SizedBox(
                                        //     //                 width: 4,
                                        //     //               ),
                                        //     //               Text('Confirm Assign',
                                        //     //                   style: TextStyle(
                                        //     //                       fontWeight:
                                        //     //                           FontWeight
                                        //     //                               .bold,
                                        //     //                       fontSize: 17)),
                                        //     //             ],
                                        //     //           ),
                                        //     //         ],
                                        //     //       ),
                                        //     //       content: Column(
                                        //     //         crossAxisAlignment:
                                        //     //             CrossAxisAlignment.start,
                                        //     //         mainAxisSize:
                                        //     //             MainAxisSize.min,
                                        //     //         children: [
                                        //     //           Text(
                                        //     //             'Are you sure you want to assign this dispatch?',
                                        //     //             style: TextStyle(
                                        //     //                 fontSize: 15),
                                        //     //           ),
                                        //     //         ],
                                        //     //       ),
                                        //     //       actions: <Widget>[
                                        //     //         TextButton(
                                        //     //           onPressed: () {
                                        //     //             // Close the dialog if "No" is pressed
                                        //     //             Navigator.of(context)
                                        //     //                 .pop();
                                        //     //           },
                                        //     //           child: const Text('No'),
                                        //     //         ),
                                        //     //         TextButton(
                                        //     //           onPressed: () async {
                                        //     //             // Perform actions if "Yes" is pressed
                                        //     //             await postDispatchRequest();
                                        //     //             await fetchLastPickNo();
                                        //     //             setState(() {
                                        //     //               _ReqnoController
                                        //     //                   .clear();
                                        //     //               _WarehousenameNameController
                                        //     //                   .clear();
                                        //     //               _RegionController
                                        //     //                   .clear();
                                        //     //               _CustomerNameController
                                        //     //                   .clear();
                                        //     //               _CusidController
                                        //     //                   .clear();
                                        //     //               _CussiteController
                                        //     //                   .clear();
                                        //     //               tableData.clear();
                                        //     //               _AssignedStaffController
                                        //     //                   .clear();
                                        //     //               SharedPrefs
                                        //     //                   .clearreqnoAll();
                                        //     //             });
                                        //     //             // Close the dialog

                                        //     //             Navigator.of(context)
                                        //     //                 .pop();

                                        //     //             await Navigator
                                        //     //                 .pushReplacement(
                                        //     //               context,
                                        //     //               MaterialPageRoute(
                                        //     //                 builder: (context) =>
                                        //     //                     MainSidebar(
                                        //     //                         enabledItems:
                                        //     //                             accessControl,
                                        //     //                         initialPageIndex:
                                        //     //                             2),
                                        //     //               ),
                                        //     //             );

                                        //     //             // Navigator.pushReplacement(
                                        //     //             //   context,
                                        //     //             //   MaterialPageRoute(
                                        //     //             //     builder: (context) =>
                                        //     //             //         MainSidebar(
                                        //     //             //             enabledItems:
                                        //     //             //                 accessControl,
                                        //     //             //             initialPageIndex:
                                        //     //             //                 2), // Navigate to MainSidebar
                                        //     //             //   ),
                                        //     //             // );
                                        //     //             // fetchAccessControl();
                                        //     //           },
                                        //     //           child: const Text('Yes'),
                                        //     //         ),
                                        //     //       ],
                                        //     //     );
                                        //     //   },
                                        //     // );

                                        //     showInvoiceDialog(
                                        //         context,
                                        //         true,
                                        //         tableData,
                                        //         _PicknoController,
                                        //         _ReqnoController,
                                        //         _WarehousenameNameController,
                                        //         _RegionController,
                                        //         _CustomerNumberController,
                                        //         _CustomerNameController,
                                        //         _CussiteController);
                                        //   } else if (!allFilled) {
                                        //     checkpickQty();
                                        //   } else {
                                        //     checkpickman();
                                        //   }
                                        // },
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
                                                  "Kindly enter a qty..!!",
                                                  style: textBoxstyle,
                                                ),
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
                                                .text ==
                                            "") {
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
                                                    Text(
                                                      'Warning',
                                                      style: TextStyle(
                                                          fontSize: 13),
                                                    ),
                                                  ],
                                                ),
                                                content: const Text(
                                                  "Kindly select a pickman..!!",
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ),
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
                                                .text.isNotEmpty ||
                                            allFilled) {
                                          // Show confirmation dialog before proceeding

                                          showInvoiceDialog(
                                              context,
                                              true,
                                              tableData,
                                              _PicknoController,
                                              _ReqnoController,
                                              _WarehousenameNameController,
                                              _RegionController,
                                              _CustomerNumberController,
                                              _CustomerNameController,
                                              _CussiteController);
                                        } else if (!allFilled) {
                                          checkpickQty();
                                        } else {
                                          checkpickman();
                                        }

                                        postLogData("Generate Picking",
                                            "Assign Preview Open");
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
                                          'Assign',
                                          style: commonWhiteStyle,
                                        ),
                                      ),
                                    )),
                                SizedBox(
                                  width:
                                      Responsive.isDesktop(context) ? 15 : 15,
                                ),
//                                 Container(
//                                     height: 35,
//                                     decoration:
//                                         BoxDecoration(color: buttonColor),
//                                     child: ElevatedButton(
//                                       onPressed: () async {
//                                         bool allFilled =
//                                             true; // Assume all fields are filled initially

// // Loop through the controllers to check if any field is empty
//                                         for (int i = 0;
//                                             i < _controllers.length;
//                                             i++) {
//                                           if (_controllers[i].text.isNotEmpty) {
//                                             allFilled =
//                                                 false; // At least one field is filled, so we do not need to show the dialog
//                                             break; // Exit the loop as soon as we find a non-empty field
//                                           }
//                                         }

// // If all fields are empty, show the dialog
//                                         if (allFilled) {
//                                           showDialog(
//                                             context: context,
//                                             builder: (BuildContext context) {
//                                               return AlertDialog(
//                                                 title: Row(
//                                                   children: [
//                                                     const Icon(
//                                                       Icons.warning,
//                                                       color: Colors.yellow,
//                                                     ),
//                                                     SizedBox(width: 2),
//                                                     Text('Warning'),
//                                                   ],
//                                                 ),
//                                                 content: const Text(
//                                                     "Kindly fill all the fields."),
//                                                 actions: [
//                                                   TextButton(
//                                                     onPressed: () {
//                                                       Navigator.of(context)
//                                                           .pop(); // Close the dialog
//                                                     },
//                                                     child: const Text("OK"),
//                                                   ),
//                                                 ],
//                                               );
//                                             },
//                                           );
//                                         } else if (_AssignedStaffController
//                                                 .text.isNotEmpty ||
//                                             allFilled) {
//                                           // Show confirmation dialog before proceeding

//                                           showInvoiceDialog(
//                                               context,
//                                               false,
//                                               tableData,
//                                               _PicknoController,
//                                               _ReqnoController,
//                                               _WarehousenameNameController,
//                                               _RegionController,
//                                               _CustomerNumberController,
//                                               _CustomerNameController,
//                                               _CussiteController);
//                                         } else if (!allFilled) {
//                                           checkpickQty();
//                                         } else {
//                                           checkpickman();
//                                         }
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                         ),
//                                         minimumSize: const Size(45.0, 31.0),
//                                         backgroundColor: Colors.transparent,
//                                         shadowColor: Colors.transparent,
//                                       ),
//                                       child: Padding(
//                                         padding: const EdgeInsets.only(
//                                             top: 5,
//                                             bottom: 5,
//                                             left: 8,
//                                             right: 8),
//                                         child: const Text(
//                                           'Print Pick Slip',
//                                           style: TextStyle(
//                                               fontSize: 16,
//                                               color: Colors.white),
//                                         ),
//                                       ),
                                // )),
                                SizedBox(
                                  width:
                                      Responsive.isDesktop(context) ? 15 : 15,
                                ),
                                Container(
                                  height: 35,
                                  decoration: BoxDecoration(color: buttonColor),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (widget.pagename == 'Re-Dispatch') {
                                        await Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MainSidebar(
                                                enabledItems: accessControl,
                                                initialPageIndex: 11),
                                          ),
                                        );
                                      } else {
                                        await Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MainSidebar(
                                                enabledItems: accessControl,
                                                initialPageIndex: 2),
                                          ),
                                        );
                                      }
                                      // await Navigator.pushReplacement(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => MainSidebar(
                                      //         enabledItems: accessControl,
                                      //         initialPageIndex: 2),
                                      //   ),
                                      // );

                                      postLogData("Generate Picking", "Clear");
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
                                        'Close',
                                        style: commonWhiteStyle,
                                      ),
                                    ),
                                  ),
                                )
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
                    fontSize: 13,
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
                    fontSize: 13,
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
                'Are you sure you want to assign this dispatch?',
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

  String token = '';
  Future<void> fetchTokenwithCusid() async {
    final IpAddress = await getActiveIpAddress();

    try {
      // Send a GET request to fetch the CSRF token from the server
      final response =
          await http.get(Uri.parse('$IpAddress/Pick_generate-token/'));

      if (response.statusCode == 200) {
        // Parse the JSON response to extract the new CSRF token and message
        var data = jsonDecode(response.body);

        // Pickid =
        //     int.tryParse(data['PICK_ID'].toString()) ?? 0; // Safe conversion

        String Pickid = data['PICK_ID']?.toString() ?? '';

        token = data['TOCKEN'] ?? 'No Token found';

        String savepickid = Pickid.toString(); // Convert int to String

        setState(() {
          // Only update state variables here
        });

        print('pickiddddd $Pickid  $savepickid  $token');

        // Save values after setState
        await saveToSharedPreferences(savepickid, token);
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

  TextEditingController SavedPickIdController = TextEditingController();
  Future<void> postDispatchRequest() async {
    final IpAddress = await getActiveIpAddress();
    bool savesuccess = false;

    final url = '$IpAddress/Dispatch_request/';
    await fetchRegionAndWarehouse();

    // await fetchLastPickNo();
    // await fetchTokenwithCusid();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno') ?? '';
    String? saveloginname = prefs.getString('saveloginname') ?? '';

    String? saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';

    String? uniqulastreqno = prefs.getString('uniqulastreqno');

    try {
      String reqno = _ReqnoController.text.toString();
      // String pickno =
      //     _PicknoController.text.isNotEmpty ? _PicknoController.text : '';
      String assignpcikman = _AssignedStaffController.text.isNotEmpty
          ? _AssignedStaffController.text
          : '';
      String warehouse = _WarehousenameNameController.text.isNotEmpty
          ? _WarehousenameNameController.text
          : '';
      String org_name =
          _Org_nameController.text.isNotEmpty ? _Org_nameController.text : '';

      String reqSalesmanNo = _SalesmanNoController.text.isNotEmpty
          ? _SalesmanNoController.text
          : '';
      String reqSalesmanName = _SalesmanNameController.text.isNotEmpty
          ? _SalesmanNameController.text
          : '';

      String cusname = _CustomerNameController.text.isNotEmpty
          ? _CustomerNameController.text
          : '';
      String cusno = _CustomerNumberController.text.isNotEmpty
          ? _CustomerNumberController.text
          : '0';
      String cussite =
          _CussiteController.text.isNotEmpty ? _CussiteController.text : '0';
      print("tableDataaaa $tableData");

      postLogData("Generate Picking",
          "Assigned ${totalSendqtyController.text} Quantity to $assignpcikman with Pickid $uniqulastreqno");

      // Iterate through each row in tableData and create dispatch data for each row
      for (int i = 0; i < tableData.length; i++) {
        var row = tableData[i]; // Use 'i' to access the correct row
        var disreqQty = double.tryParse(_controllers[i].text) ?? 0.0;
        var customer_trx_line_id =
            double.tryParse(row['customer_trx_line_id']?.toString() ?? '0') ??
                0.0;

        var customer_trx_id =
            double.tryParse(row['customer_trx_id']?.toString() ?? '0') ?? 0.0;

        var undel_id = int.tryParse(row['undel_id']?.toString() ?? '0') ?? 0;

        String rowid = row['Row_id']?.toString() ?? "0";
        double dispatchedQty =
            (double.tryParse(row['disreqqty']?.toString() ?? '0') ?? 0.0) -
                disreqQty;

        DateTime now = DateTime.now();
        // Format it to YYYY-MM-DD'T'HH:mm:ss'
        String Date = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);
        // String Date = DateFormat('yyyy-MM-dd').format(DateTime.now());

        if (disreqQty > 0) {
          Map<String, dynamic> createDispatchData = {
            "PICK_ID": uniqulastreqno,
            "REQ_ID": reqno,
            "DATE": Date,
            "ASSIGN_PICKMAN": assignpcikman,
            "PHYSICAL_WAREHOUSE": warehouse,
            "ORG_ID": saleslogiOrgid.isNotEmpty ? saleslogiOrgid : 'Unknown',
            "ORG_NAME": org_name,
            "SALESMAN_NO": reqSalesmanNo,
            "SALESMAN_NAME": reqSalesmanName,
            "MANAGER_NO": salesloginno.isNotEmpty ? salesloginno : 0,
            "MANAGER_NAME":
                saveloginname.isNotEmpty ? saveloginname : 'Unknown',
            "CUSTOMER_NUMBER": cusno,
            "CUSTOMER_NAME": cusname,
            "CUSTOMER_SITE_ID": cussite,
            "INVOICE_DATE": Date,
            "INVOICE_NUMBER": row['invoiceno']?.toString() ?? '0',
            "LINE_NUMBER": row['id']?.toString() ?? '0',
            "INVENTORY_ITEM_ID": row['itemcode']?.toString() ?? '0',
            "CUSTOMER_TRX_ID": row['customer_trx_id']?.toString() ?? '0',
            "CUSTOMER_TRX_LINE_ID":
                row['customer_trx_line_id']?.toString() ?? '0',
            "ITEM_DESCRIPTION": row['itemdetails']?.toString() ?? '0',
            "TOT_QUANTITY": row['invoiceQty']?.toString() ?? '0',
            "DISPATCHED_QTY": row['disreqqty']?.toString() ?? '0',
            "BALANCE_QTY": row['balanceqty']?.toString() ?? '0',
            "PICKED_QTY": disreqQty.toString(),
            "AMOUNT": row['amount']?.toString() ?? '0',
            "ITEM_COST": row['item_cost']?.toString() ?? '0',
            "STATUS": "pending",
            "CREATION_DATE": Date,
            "CREATED_BY": saveloginname.isNotEmpty ? saveloginname : 'Unknown',
            "CREATED_IP": "null",
            "CREATED_MAC": "null",
            "LAST_UPDATE_DATE": Date,
            "LAST_UPDATED_BY": "null",
            "LAST_UPDATE_IP": "null",
            "FLAG": 'A',
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
            setState(() {
              savesuccess = true;
            });
            // Update the dispatched quantity for the current row
            updateDispatchBalance(reqno, "$undel_id", "$dispatchedQty");
            // await updateDispatchedQty(rowid, dispatchedQty.toString());

            print(
                'Dispatch created successfully for Line Number: ${row['id']?.toString()}');
          } else {
            print(
                'Failed to create dispatch for Line Number: ${row['id']?.toString()}. Status code: ${response.statusCode}');
            // print('Response body: ${response.body}');
          }
        }
      }
    } catch (e) {
      setState(() {
        savesuccess = false;
      });
      print('Error occurred while posting dispatch data: $e');
    } finally {
      await prefs.remove('csrf_token');
      await prefs.remove('uniqulastreqno');
      if (savesuccess) {
        await _launchUrl(context);
      }
    }
  }

  // Future<void> updateDispatchRequest() async {
  //   try {
  //     String reqno = _ReqnoController.text.trim();
  //     final IpAddress = await getActiveIpAddress();
  //     String cusno = _CustomerNumberController.text.trim().isNotEmpty
  //         ? _CustomerNumberController.text.trim()
  //         : '0';
  //     String cussite = _CussiteController.text.trim().isNotEmpty
  //         ? _CussiteController.text.trim()
  //         : '0';

  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String salesloginno = prefs.getString('salesloginno') ?? '0';
  //     String saveloginname = prefs.getString('saveloginname') ?? 'Unknown';
  //     String uniqulastreqno = prefs.getString('uniqulastreqno') ?? '0';
  //     String returnid = prefs.getString('returnredispatch') ?? '0';

  //     String assignpickman = _AssignedStaffController.text.trim();

  //     DateTime now = DateTime.now();
  //     String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

  //     if (tableData.isEmpty) {
  //       print("⚠️ No table data available to update.");
  //       return;
  //     }

  //     print('📤 Sending tableData with ${tableData.length} rows:');
  //     print(jsonEncode(tableData));

  //     // Create a list to store all the futures
  //     List<Future> futures = [];

  //     for (int i = 0; i < tableData.length; i++) {
  //       try {
  //         var row = tableData[i];

  //         // Get disreqQty from tableData directly instead of controllers
  //         double disreqQty =
  //             double.tryParse(row['disreqqty']?.toString() ?? '0') ?? 0;

  //         if (disreqQty <= 0) {
  //           print("⚠️ Row $i skipped because disreqQty is 0.");
  //           continue;
  //         }

  //         String invoiceno = row['invoiceno']?.toString() ?? '0';
  //         String itemcode = row['itemcode']?.toString() ?? '0';

  //         final url = Uri.parse(
  //           '$IpAddress/update-dispatch/$reqno/$cusno/$cussite/$invoiceno/$itemcode/',
  //         );

  //         final Map<String, dynamic> bodyData = {
  //           'PICK_ID': uniqulastreqno,
  //           'ASSIGN_PICKMAN': assignpickman,
  //           "MANAGER_NO": salesloginno,
  //           "MANAGER_NAME": saveloginname,
  //           'qty': disreqQty,
  //           'DATE': formattedDate,
  //         };

  //         print('\n📤 Preparing update for Row $i:');
  //         print('Item: ${row['itemdetails']}');
  //         print('Invoice: $invoiceno');
  //         print('Item Code: $itemcode');
  //         print('Quantity: $disreqQty');
  //         print('URL: $url');
  //         print('Data: $bodyData');

  //         // Add the HTTP request to the futures list
  //         futures.add(http
  //             .post(
  //           url,
  //           headers: {'Content-Type': 'application/json'},
  //           body: jsonEncode(bodyData),
  //         )
  //             .then((response) async {
  //           if (response.statusCode == 200) {
  //             final result = jsonDecode(response.body);
  //             print('✅ Row $i  $disreqQty updated successfully: $result');
  //             return result;
  //           } else {
  //             print('❌ Row $i failed. Status: ${response.statusCode}');
  //             print('Response body: ${response.body}');
  //             throw Exception('Failed to update row $i');
  //           }
  //         }).catchError((e) {
  //           print('❌ Error in row $i: $e');
  //           return null;
  //         }));
  //       } catch (e) {
  //         print('❌ Exception while preparing row $i: $e');
  //       }
  //     }

  //     // Wait for all requests to complete
  //     print('\n⏳ Waiting for all requests to complete...');
  //     await updateReassignStatus(returnid);
  //     await Future.wait(futures);
  //     print('🎉 All requests completed!');
  //   } catch (e) {
  //     print('❌ Global exception in updateDispatchRequest: $e');
  //   }
  // }
  Future<void> updateDispatchRequest() async {
    bool savesucces = false;
    try {
      String reqno = _ReqnoController.text.trim();
      final IpAddress = await getActiveIpAddress();

      String cusno = _CustomerNumberController.text.trim().isNotEmpty
          ? _CustomerNumberController.text.trim()
          : '0';
      String cussite = _CussiteController.text.trim().isNotEmpty
          ? _CussiteController.text.trim()
          : '0';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String salesloginno = prefs.getString('salesloginno') ?? '0';
      String saveloginname = prefs.getString('saveloginname') ?? 'Unknown';
      String uniqulastreqno = prefs.getString('uniqulastreqno') ?? '0';
      String returnid = prefs.getString('returnredispatch') ?? '0';

      String assignpickman = _AssignedStaffController.text.trim();

      DateTime now = DateTime.now();
      String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

      if (tableData.isEmpty) {
        print("⚠️ No table data available to update.");
        return;
      }

      print('📤 Sending tableData with ${tableData.length} rows:');
      print(jsonEncode(tableData));

      // Optional: update reassign status once before starting the updates
      await updateReassignStatus(returnid);

      postLogData("Generate Picking",
          "Return Re-Assigned ${totalSendqtyController.text} Quantity to $assignpickman with Pickid $uniqulastreqno");
      for (int i = 0; i < tableData.length; i++) {
        try {
          var row = tableData[i];

          double disreqQty =
              double.tryParse(row['disreqqty']?.toString() ?? '0') ?? 0;

          if (disreqQty <= 0) {
            print("⚠️ Row $i skipped because disreqQty is 0.");
            continue;
          }

          String invoiceno = row['invoiceno']?.toString() ?? '0';
          String itemcode = row['itemcode']?.toString() ?? '0';

          final url = Uri.parse('$IpAddress/update-dispatch/');

          final Map<String, dynamic> bodyData = {
            'REQ_ID': reqno,
            'CUSTOMER_NUMBER': int.tryParse(cusno) ?? 0,
            'CUSTOMER_SITE_ID': int.tryParse(cussite) ?? 0,
            'INVOICE_NUMBER': invoiceno,
            'INVENTORY_ITEM_ID': itemcode,
            'PICK_ID': uniqulastreqno,
            'ASSIGN_PICKMAN': assignpickman,
            'MANAGER_NO': salesloginno,
            'MANAGER_NAME': saveloginname,
            'qty': disreqQty,
            'DATE': formattedDate,
          };

          print('\n📤 Preparing update for Row $i:');
          print('Item: ${row['itemdetails']}');
          print('Invoice: $invoiceno');
          print('Item Code: $itemcode');
          print('Quantity: $disreqQty');
          print('URL: $url');
          print('Body: $bodyData');

          final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(bodyData),
          );
          if (response.statusCode == 200) {
            setState(() {
              savesucces = true;
            });
            final result = jsonDecode(response.body);
            print('✅ Row $i  $disreqQty updated successfully: $result');
          } else {
            setState(() {
              savesucces = false;
            });
            print('❌ Row $i failed. Status: ${response.statusCode}');
            print('Response body: ${response.body}');
            throw Exception('Failed to update row $i');
          }
        } catch (e) {
          setState(() {
            savesucces = false;
          });
          print('❌ Exception in row $i: $e');
          break; // You can use `continue;` instead if you want to skip and go to next
        }
      }

      print('🎉 All sequential requests completed!');
    } catch (e) {
      setState(() {
        savesucces = false;
      });
      print('❌ Global exception in updateDispatchRequest: $e');
    } finally {
      if (savesucces) {
        await _launchUrl(context);
      }
    }
  }

  Future<void> updateReassignStatus(
    String returnid,
  ) async {
    final IpAddress = await getActiveIpAddress();
    final String apiUrl = '$IpAddress/update_reassign_status/$returnid/';
    String reassignStatus = 'Re-Assign-Finished';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'RE_ASSIGN_STATUS': reassignStatus,
        }),
      );

      if (response.statusCode == 200) {
        print('Success: ${jsonDecode(response.body)['message']}');
      } else {
        print('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  TextEditingController deliverAddressController = TextEditingController();
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
        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
        final List<dynamic> data = json.decode(decodedBody);
        if (data.isNotEmpty) {
          final firstItem = data[0];
          setState(() {
            deliverAddressController.text = firstItem['DELIVERYADDRESS'] ?? '';

            print(
                "deliverAddressController : ${deliverAddressController.text}  ");
          });
        } else {
          // Handle empty data
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No data found for the given details.')),
          );
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching details: $e')),
      );
    }
  }

  _launchUrl(BuildContext context) async {
    String reqno =
        _ReqnoController.text.isNotEmpty ? _ReqnoController.text : '';

    await fetchDispatchDetails(reqno);
    List<String> productDetails = [];
    int snoCounter = 1; // Initialize the sequence number counter

    List<Map<String, dynamic>> mergeTableData(
        List<Map<String, dynamic>> tableData) {
      Map<String, Map<String, dynamic>> mergedData = {};

      for (var item in tableData) {
        String key =
            '${item['invoiceno']}-${item['itemcode']}-${item['itemdetails']}';
        if (mergedData.containsKey(key)) {
// If already exists, add the sendqty
          mergedData[key]!['sendqty'] +=
              int.tryParse(item['sendqty']?.toString() ?? '0') ?? 0;
        } else {
// Add a new entry
          mergedData[key] = {
            'sno': 0, // Temporary placeholder for sno
            'invoiceno': item['invoiceno'],
            'itemcode': item['itemcode'],
            'itemdetails': item['itemdetails'],
            'sendqty': int.tryParse(item['sendqty']?.toString() ?? '0') ?? 0,
          };
        }
      }

// Convert the merged map back to a list
      return mergedData.values.toList();
    }

// Preprocess the table data before rendering
    List<Map<String, dynamic>> mergedData = mergeTableData(tableData);

    for (var data in mergedData) {
// Only process rows where sendqty > 0
      if (data['sendqty'] > 0) {
// Assign a continuous sno value
        data['sno'] = snoCounter++;
// Access each product's details and format as "productName-qtyX-action"
        String formattedProduct =
            "{${data['sno']}|${data['invoiceno']}|${data['itemcode']}|${data['itemdetails']}|${data['sendqty']}}";
        productDetails.add(formattedProduct);
      }
    }

// Join product details into a single string with ',' separator
    String productDetailsString = productDetails.join(',');

    DateTime today = DateTime.now();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uniqulastpcikno = prefs.getString('uniqulastreqno');
// Format the date
    String formattedDate = DateFormat('dd-MMM-yyyy').format(today);

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
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Could not launch $dynamicUrl')),
//       );
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

  Future<void> updateDispatchBalance(
    String reqid,
    String undelid,
    String dispatchQty,
  ) async {
    final IpAddress = await getActiveIpAddress(); // your existing IP function

    final url = Uri.parse("$IpAddress/update-dispatch-balance/");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "reqid": reqid,
          "undelid": undelid,
          "dispatch_qty": dispatchQty,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("Update Success: $data");

        // Optional: Show message in UI
        // Fluttertoast.showToast(msg: "Updated Successfully");
      } else {
        print("Error: ${response.body}");
        // Fluttertoast.showToast(msg: "Update Failed");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }
  // Future<void> updateDispatchedQty(String id, String dispatchedQty) async {
  //   final IpAddress = await getActiveIpAddress();

  //   final String url =
  //       '$IpAddress/Create_Dispatch/$id/'; // Assuming id is in the URL

  //   try {
  //     // Prepare the body of the PUT request
  //     Map<String, dynamic> body = {
  //       "DISPATCHED_BY_MANAGER":
  //           dispatchedQty, // Key must match the field name in the Django model
  //     };

  //     // Make the PUT request
  //     final response = await http.put(
  //       Uri.parse(url),
  //       headers: {"Content-Type": "application/json"},
  //       body: json.encode(body),
  //     );

  //     if (response.statusCode == 200) {
  //       // If the server returned a 200 OK response, the update was successful
  //       print("Dispatched quantity updated successfully for ID: $id");
  //     } else {
  //       // If the server did not return a 200 OK response, throw an error
  //       print("Failed to update dispatched quantity. Error: ");
  //     }
  //   } catch (e) {
  //     // Handle errors like network issues, invalid URL, etc.
  //     print("An error occurred while updating dispatched quantity: $e");
  //   }
  // }

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

    String pickno = '${pickNoController.text}';
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
            scrollDirection: Axis.horizontal,
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
                                'Pick Slip',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[800],
                                ),
                              ),
                              if (buttonname)
                                Container(
                                    height: 35,
                                    decoration:
                                        BoxDecoration(color: buttonColor),
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
                                                    Text(
                                                      'Warning',
                                                      style: textBoxstyle,
                                                    ),
                                                  ],
                                                ),
                                                content: const Text(
                                                    "Kindly fill all the fields.",
                                                    style: textBoxstyle),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); // Close the dialog
                                                    },
                                                    child: const Text("OK",
                                                        style: textBoxstyle),
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
                                                            style:
                                                                textBoxstyle),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                content: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Are you sure you want to assign this dispatch?',
                                                      style: textBoxstyle,
                                                    ),
                                                  ],
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      // Close the dialog if "No" is pressed
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('No'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      showDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            false, // Prevent dismissing the dialog manually
                                                        builder: (BuildContext
                                                            context) {
                                                          return const AlertDialog(
                                                            content: Row(
                                                              children: [
                                                                CircularProgressIndicator(
                                                                    color: Colors
                                                                        .blue),
                                                                SizedBox(
                                                                    width: 20),
                                                                Text(
                                                                  "Processing...",
                                                                  style:
                                                                      textBoxstyle,
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      );
                                                      try {
                                                        await fetchTokenwithCusid();
                                                        // Perform actions if "Yes" is pressed
                                                        if (widget.pagename ==
                                                            'Re-Dispatch') {
                                                          await updateDispatchRequest();
                                                        } else {
                                                          await postDispatchRequest();
                                                        }

                                                        setState(() {
                                                          _ReqnoController
                                                              .clear();
                                                          _WarehousenameNameController
                                                              .clear();
                                                          _RegionController
                                                              .clear();
                                                          _CustomerNameController
                                                              .clear();
                                                          _CusidController
                                                              .clear();
                                                          _CussiteController
                                                              .clear();
                                                          tableData.clear();
                                                          _AssignedStaffController
                                                              .clear();
                                                          SharedPrefs
                                                              .clearreqnoAll();

                                                          SharedPrefs
                                                              .cleartockandreqno();
                                                        });
                                                        // Close the dialog

                                                        Navigator.of(context)
                                                            .pop();

                                                        if (widget.pagename ==
                                                            'Re-Dispatch') {
                                                          await Navigator
                                                              .pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  MainSidebar(
                                                                      enabledItems:
                                                                          accessControl,
                                                                      initialPageIndex:
                                                                          11),
                                                            ),
                                                          );
                                                        } else {
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
                                                        }
                                                      } catch (error) {
                                                        // Handle errors appropriately
                                                        print(
                                                            "Error occurred: $error");
                                                      }

                                                      postLogData(
                                                          "Generate Picking",
                                                          "Assign");
                                                    },
                                                    child: const Text('Yes',
                                                        style: textBoxstyle),
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
                                          'Assign',
                                          style: commonWhiteStyle,
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
                                  // Text(
                                  //   'aljeflutterapp',
                                  //   style: TextStyle(
                                  //     fontSize: 18,
                                  //     fontWeight: FontWeight.bold,
                                  //     color: Colors.blueGrey[800],
                                  //   ),
                                  // ),
                                  // Text('123 Restaurant St, City Name',
                                  //     style: TextStyle(
                                  //         fontSize: 12, color: Colors.grey)),
                                  // Text('Phone: +91 12345 67890',
                                  //     style: TextStyle(
                                  //         fontSize: 12, color: Colors.grey)),
                                  // Text('Website: www.aljeflutterapp.com',
                                  //     style: TextStyle(
                                  //         fontSize: 12, color: Colors.grey)),
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
                                'Pick ID: ${pickno}',
                                style: TextStyle(
                                    fontSize: 13,
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
                                  color: Colors.grey.withOpacity(0.5),
                                  width: 1),
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
                          // Container(
                          //     height: 35,
                          //     decoration: BoxDecoration(color: buttonColor),
                          //     child: ElevatedButton(
                          //       onPressed: () async {
                          //         // await _savePdf();
                          //         _captureAndSavePdf();
                          //       },
                          //       style: ElevatedButton.styleFrom(
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(8),
                          //         ),
                          //         minimumSize: const Size(45.0, 31.0),
                          //         backgroundColor: Colors.transparent,
                          //         shadowColor: Colors.transparent,
                          //       ),
                          //       child: Padding(
                          //         padding: const EdgeInsets.only(
                          //             top: 5, bottom: 5, left: 8, right: 8),
                          //         child: const Text(
                          //           'Print',
                          //           style: TextStyle(
                          //               fontSize: 16, color: Colors.white),
                          //         ),
                          //       ),
                          //     )),
                          // SizedBox(
                          //   width: 20,
                          // ),
                          // Container(
                          //     height: 35,
                          //     decoration: BoxDecoration(color: buttonColor),
                          //     child: ElevatedButton(
                          //       onPressed: () async {
                          //         // await _savePdf();
                          //         _captureAndSavePdf();
                          //       },
                          //       style: ElevatedButton.styleFrom(
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(8),
                          //         ),
                          //         minimumSize: const Size(45.0, 31.0),
                          //         backgroundColor: Colors.transparent,
                          //         shadowColor: Colors.transparent,
                          //       ),
                          //       child: Padding(
                          //         padding: const EdgeInsets.only(
                          //             top: 5, bottom: 5, left: 8, right: 8),
                          //         child: const Text(
                          //           'Generate Pdf',
                          //           style: TextStyle(
                          //               fontSize: 16, color: Colors.white),
                          //         ),
                          //       ),
                          //     )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
                _buildTableHeader("Inv.No", 100),
                _buildTableHeader("In.LN", 50),
                _buildTableHeader("I.Code", 100),
                _buildTableHeader(
                    "I.Description",
                    Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.12
                        : MediaQuery.of(context).size.width * 0.60),
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
                        _buildTableRow(invNo, 100),
                        _buildTableRow(lineno, 50),
                        _buildTableRow(itemcode, 100),
                        _buildTableRow(
                            itemdetails,
                            Responsive.isDesktop(context)
                                ? MediaQuery.of(context).size.width * 0.12
                                : MediaQuery.of(context).size.width * 0.60),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: width,
          height: 25,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13, // Correct way to set font size
                ),
                overflow: TextOverflow.ellipsis, // Prevent overflow
              ),
            ),
          ],
        ),
      ),
    );
  }
}
