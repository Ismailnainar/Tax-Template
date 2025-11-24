import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:pdf/widgets.dart' as pw;
import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenerateDispatch extends StatefulWidget {
  final Function togglePage;

  final String reqno;
  final String pickno;
  final String cusno;
  final String cusname;
  final String cussite;
  final String pickedqty;

  GenerateDispatch(this.togglePage, this.reqno, this.pickno, this.cusno,
      this.cusname, this.cussite, this.pickedqty);

  @override
  State<GenerateDispatch> createState() => _GenerateDispatchState();
}

class _GenerateDispatchState extends State<GenerateDispatch> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  Widget _buildTextFieldDesktop(
      String label,
      TextEditingController controller,
      IconData icon,
      bool readonly,
      IconData staricon,
      Color starticoncolor,
      FocusNode fromfocusnode,
      FocusNode tofocusnode) {
    double screenWidth = MediaQuery.of(context).size.width;
    String message = controller.text;

    return Container(
      width: Responsive.isDesktop(context)
          ? screenWidth * 0.12
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
                    staricon,
                    size: 8,
                    color: starticoncolor,
                  )
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 0, bottom: 0),
              child: Row(
                children: [
                  Container(
                    height: 32,
                    width: Responsive.isDesktop(context)
                        ? screenWidth * 0.115
                        : screenWidth * 0.4,
                    child: TextFormField(
                      readOnly: readonly,
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
                            ? Color.fromARGB(255, 234, 234, 234)
                            : Color.fromARGB(255, 250, 250, 250),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 10.0,
                        ),
                      ),
                      controller: controller,
                      focusNode: fromfocusnode,
                      // Only move focus when the user submits the field by pressing Enter
                      onFieldSubmitted: (_) {
                        _fieldFocusChange(context, fromfocusnode, tofocusnode);
                      },
                      keyboardType: (label == "Driver MobileNo" ||
                              label == "Loading Charges" ||
                              label == "Transport Charges" ||
                              label == "Misc Charges")
                          ? TextInputType.number
                          : TextInputType.text,
                      inputFormatters: () {
                        if (label == "Driver MobileNo" ||
                            label == "Loading Charges" ||
                            label == "Transport Charges" ||
                            label == "Misc Charges") {
                          return [FilteringTextInputFormatter.digitsOnly];
                        } else if (label == "Transporter Name" ||
                            label == "Driver Name" ||
                            label == "Vehicle No" ||
                            label == "Remarks" ||
                            label == "Delivery Address") {
                          // Disallow specific characters for "Truck load"
                          return [
                            FilteringTextInputFormatter.deny(
                              RegExp(r'[{}#‡|=&*^$@!\(\)\+]+'),
                              replacementString: '',
                            )
                          ];
                        } else {
                          return null;
                        }
                      }(),
                      style: TextStyle(
                          color: Color.fromARGB(255, 73, 72, 72), fontSize: 13),
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

  List<Map<String, dynamic>> tableData = []; // Initialize empty tableData

  List<Map<String, dynamic>> filteredData = [];

  List<String> AssignedstaffList = ["Ram", "Naveen", 'Mano'];
  String? assignedstaffselectedValue;
  bool _filterEnabledassignedstaff = true;
  int? _hoveredIndexAssignedStaff;
  int? _selectedIndexAssignedStaff;
  TextEditingController _AssignedStaffController = TextEditingController();
  TextEditingController NoofitemController = TextEditingController(text: '0');
  TextEditingController totalSendqtyController =
      TextEditingController(text: '0');

  TextEditingController Dispatch_idController = TextEditingController();
  TextEditingController ReqNoController = TextEditingController();
  TextEditingController WarehouseController = TextEditingController();

  TextEditingController OrgIdController = TextEditingController();
  TextEditingController RegionController = TextEditingController();

  TextEditingController StaffController = TextEditingController();
  TextEditingController CustomerNoController = TextEditingController();
  TextEditingController CustomerNameController = TextEditingController();
  TextEditingController CustomerSiteController = TextEditingController();
  TextEditingController VendorController = TextEditingController();
  TextEditingController DriverMobileNoController = TextEditingController();
  TextEditingController DriverController = TextEditingController();
  TextEditingController VehicleNoController = TextEditingController();
  TextEditingController TruckDimentionController = TextEditingController();
  TextEditingController LoadingChargeController = TextEditingController();
  TextEditingController TransportChargeController = TextEditingController();
  TextEditingController MISCController = TextEditingController();
  TextEditingController RemarksController = TextEditingController();
  TextEditingController PickidContrller = TextEditingController();

  final TextEditingController SalesmanNoController = TextEditingController();
  final TextEditingController SalesmanNameController = TextEditingController();
  final TextEditingController ManagerNoController = TextEditingController();
  final TextEditingController ManagerNameController = TextEditingController();
  final TextEditingController PickManNoController = TextEditingController();
  final TextEditingController PickManNameAController = TextEditingController();

  final TextEditingController PickidController = TextEditingController();

  FocusNode dispatchidfocusnode = FocusNode();
  FocusNode reqnofocusnode = FocusNode();
  FocusNode warehousefocusnode = FocusNode();
  FocusNode regionfocusnode = FocusNode();

  FocusNode customernofocusnode = FocusNode();
  FocusNode customernamefocusnode = FocusNode();
  FocusNode customersitefocusnode = FocusNode();
  FocusNode vendorfocusnode = FocusNode();
  FocusNode vendorsitefocusnode = FocusNode();
  FocusNode driverfocusnode = FocusNode();
  FocusNode vehiclenofocusnode = FocusNode();
  FocusNode truckdimfocusnode = FocusNode();
  FocusNode loadingchargefocusnode = FocusNode();
  FocusNode transportchargefocusnode = FocusNode();
  FocusNode miscchargefocusnode = FocusNode();
  FocusNode remarksfocusnode = FocusNode();

  FocusNode salesmanremarksfocusnode = FocusNode();

  FocusNode Deliverydatefocusnode = FocusNode();
  FocusNode savebuttonfocusnode = FocusNode();

  bool _isLoadingData = false;

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Timer? _timer;
  @override
  void initState() {
    super.initState();
    fetchAccessControl();
    _loadSalesmanName();
    // _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
    //   FetchLastDipatchNo(); // Fetch serial number every 10 sec
    // });
    fetchWarehouseDetails();
    CustomerNoController.text =
        widget.cusno; // Initialize the controller's text here
    CustomerNameController.text = widget.cusname;
    CustomerSiteController.text = widget.cussite;

    ReqNoController.text = widget.reqno;
    PickidContrller.text = widget.pickno;
    filteredData = List.from(tableData);
    print("reqqqqqqqqqqqqqqqqqqqqqqqnooooooooooooooo ${widget.reqno}");
    fetchDispatchData();

    postLogData("General Dispatch", "Opened");
    fetchDispatchDetails();
    deliverAddressController.addListener(() {
      setState(() {
        currentLength = deliverAddressController.text.length;
      });
    });
  }

  @override
  void dispose() {
    postLogData("General Dispatch", "Closed");
    super.dispose();
  }

  bool isLoading = true;

  Future<void> fetchCustomerDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? salesloginno = prefs.getString('salesloginno');
    String? salesloginno = '2006622';
    final IpAddress = await getActiveIpAddress();

    final String url =
        '$IpAddress/loginsalesmanwarehousedetails/?salesman_no=$salesloginno/';
    String customerNumber = CustomerNoController.text;
    String? nextPageUrl = url;
    try {
      final response = await http.get(Uri.parse(url));

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

              // CustomeridController.text = entry['customer_id'].toString() ?? '';
              CustomerSiteController.text =
                  entry['customer_site_id'].toString() ?? '';
              // CustomersitechannelController.text =
              //     entry['customer_site_channel'].toString() ?? '';
            });

            // Print the values to verify
            // print('Customer Name: ${CustomerNameController.text}');
            // print('Customer Site ID: ${CustomersiteidController.text}');
            break; // Exit the loop after finding the customer
          }
        }
      } else {
        print('Failed to fetch customer details');
      }
    } catch (e) {
      print('Error fetching customer details: $e');
    }
  }

  Future<void> fetchDispatchData() async {
    setState(() {
      _isLoadingData = true;
    });
    String disreqno =
        Dispatch_idController.text.isNotEmpty ? Dispatch_idController.text : '';
    String disReqNoValue =
        disreqno.split('_').last; // Extract value after last underscore

    // Constructing the URL for the API request

    final IpAddress = await getActiveIpAddress();

    final String url =
        '$IpAddress/filteredToGetGenerateDispatchView/${widget.reqno}/${widget.cusno}/${widget.cussite}/';
    print("URL for the generate scan truck man: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        // Check if the response is a list (as per the response pattern provided)
        if (responseData is List) {
          int sno = 1;

          setState(() {
            double totalSendQty = 0; // Initialize the totalSendQty variable

            var filteredItems = responseData
                .where((item) =>
                    item['pick_id'] == widget.pickno &&
                    item['SCAN_STATUS']?.toString() == 'Request for Delivery')
                .toList();

            tableData = filteredItems.map((item) {
              double sendQty = 0.0;
              try {
                // Parse Send_qty safely (if possible)
                sendQty = double.tryParse(item['Send_qty'].toString()) ?? 0.0;
              } catch (e) {
                print("Error parsing Send_qty: $e");
              }

              // Add sendQty to totalSendQty
              totalSendQty += sendQty;
              double disReqQty =
                  double.tryParse(item['DisReq_Qty'].toString()) ?? 0.0;
              double balanceQty = disReqQty - sendQty;

              return {
                'sno': sno++,

                'id': item['id'],
                'invoiceno': item['invoice_no'],
                'pick_id': item['pick_id'],
                'salesman_no': item['salesman_no'],
                'salesman_name': item['salesman_name'],
                'manager_no': item['manager_no'],
                'manager_name': item['manager_name'],
                'pickman_no': item['pickman_no'],
                'pickman_name': item['pickman_name'],
                'loadman_no': item['loadman_no'],
                'loadman_name': item['loadman_name'],
                'Customer_trx_id': item['Customer_trx_id'],
                'Customer_trx_line_id': item['Customer_trx_line_id'],
                'itemcode': item['Item_code'],
                'line_no': item['line_no'],
                'itemdetails': item['Item_detailas'],
                'disreqqty': disReqQty.toStringAsFixed(0),
                'balanceqty':
                    balanceQty.toStringAsFixed(0), // Format to 2 decimal places
                'sendqty': sendQty.toString(), // Ensure sendQty is a string
                "Product_code": item['Product_code'],
                "Serial_No": item['Serial_No'],
                "Udel_id": item['Udel_id'],
              };
            }).toList();

            // if (tableData.isEmpty) {
            //   // Show dialog when no data found
            //   WidgetsBinding.instance.addPostFrameCallback((_) {
            //     showDialog(
            //       context: context,
            //       barrierDismissible: false, // User must tap "OK"
            //       builder: (ctx) => Dialog(
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(20),
            //         ),
            //         child: SizedBox(
            //           width: 400, // 👈 Fixed width
            //           child: Padding(
            //             padding: const EdgeInsets.all(20),
            //             child: Column(
            //               mainAxisSize: MainAxisSize.min,
            //               children: [
            //                 // Top Icon
            //                 Container(
            //                   decoration: BoxDecoration(
            //                     color: Colors.red.shade100,
            //                     shape: BoxShape.circle,
            //                   ),
            //                   padding: const EdgeInsets.all(15),
            //                   child: Icon(
            //                     Icons.error_outline,
            //                     color: Colors.red.shade700,
            //                     size: 40,
            //                   ),
            //                 ),
            //                 const SizedBox(height: 15),

            //                 // Title
            //                 Text(
            //                   "No Data Found",
            //                   style: TextStyle(
            //                     fontSize: 20,
            //                     fontWeight: FontWeight.bold,
            //                     color: Colors.red.shade700,
            //                   ),
            //                   textAlign: TextAlign.center,
            //                 ),
            //                 const SizedBox(height: 10),

            //                 // Message
            //                 const Text(
            //                   "This request is not eligible for the Quick billing process.\n\n"
            //                   "Note: This Req No is already processed with Pickman and Loadman.",
            //                   textAlign: TextAlign.center,
            //                   style: TextStyle(
            //                     fontSize: 15,
            //                     height: 1.5, // better line spacing
            //                     color: Colors.black87,
            //                     fontWeight: FontWeight.w500, // medium weight
            //                     letterSpacing: 0.3, // improves readability
            //                   ),
            //                 ),
            //                 const SizedBox(height: 20),

            //                 // Action Button
            //                 SizedBox(
            //                   width: double.infinity,
            //                   child: ElevatedButton(
            //                     style: ElevatedButton.styleFrom(
            //                       backgroundColor: Colors.red.shade700,
            //                       foregroundColor: Colors.white,
            //                       shape: RoundedRectangleBorder(
            //                         borderRadius: BorderRadius.circular(12),
            //                       ),
            //                       padding:
            //                           const EdgeInsets.symmetric(vertical: 14),
            //                     ),
            //                     onPressed: () {
            //                       Navigator.pushReplacement(
            //                         context,
            //                         MaterialPageRoute(
            //                           builder: (context) => MainSidebar(
            //                               enabledItems: accessControl,
            //                               initialPageIndex: 102),
            //                         ),
            //                       );
            //                     },
            //                     child: const Text(
            //                       "OK",
            //                       style: TextStyle(
            //                           fontSize: 16,
            //                           fontWeight: FontWeight.bold),
            //                     ),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //     );
            //   });
            // }

            // else

            {
              var firstItem = responseData[0];
              SalesmanNoController.text =
                  firstItem['salesman_no']?.toString() ?? '';
              SalesmanNameController.text =
                  firstItem['salesman_name']?.toString() ?? '';
              ManagerNoController.text =
                  firstItem['manager_no']?.toString() ?? '';
              ManagerNameController.text =
                  firstItem['manager_name']?.toString() ?? '';
              PickidController.text = firstItem['pick_id']?.toString() ?? '';
              PickManNoController.text =
                  firstItem['pickman_no']?.toString() ?? '';
              PickManNameAController.text =
                  firstItem['pickman_name']?.toString() ?? '';
            }
            filteredData = List.from(tableData);

            // print("filteredtabledaaaaaaaa $filteredData");

            NoofitemController.text = tableData.length.toString();
            totalSendqtyController.text = totalSendQty.toString();
          });

          // print("Filtered table data: $filteredData");
        } else {
          print("Error: Response data is not a list.");
        }
      } else {
        throw Exception('Failed to load dispatch data');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Widget _buildAssignedStaffDropdown() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: Row(
        children: [
          SizedBox(width: 3),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Container(
                    height: 27,
                    width: Responsive.isDesktop(context)
                        ? screenWidth * 0.08
                        : 150,
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
            prefixIcon: Icon(
              Icons.house_siding,
              size: 12,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            filled: true,
            fillColor: Colors.grey[100],
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
                    style: DropdownTextStyle,
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
            _AssignedStaffController.text = suggestion;
            assignedstaffselectedValue = suggestion;
            _filterEnabledassignedstaff = false;
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

  Widget _buildDataCell(String text, Color rowColor,
      {bool isDescription = false}) {
    double columnWidth = isDescription
        ? (Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.20
            : 200) // Larger width for "Item Description"
        : (Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.2
            : 100);

    return Flexible(
      child: Container(
        height: 30,
        width: columnWidth,
        decoration: BoxDecoration(
          color: rowColor,
          border: Border.all(
            color: Color.fromARGB(255, 226, 225, 225),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection:
              Axis.horizontal, // Allow horizontal scrolling if necessary
          child: Text(
            text,
            textAlign: TextAlign.left,
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    // Preprocess the tableData to merge rows with the same itemcode and itemdetails
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
            'sno': item['sno'],
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
    double screenHeight = MediaQuery.of(context).size.height;

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
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.75
                        : MediaQuery.of(context).size.width * 1.8,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: _verticalScrollController,
                      child: SingleChildScrollView(
                        controller: _verticalScrollController,
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10.0, right: 10, top: 13, bottom: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    width: 75,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.format_list_numbered,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text("S.No",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    width: 200,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.numbers,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text("Invoice.No",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    width: 150,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.code,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                    Responsive.isDesktop(
                                                            context)
                                                        ? "Item Code"
                                                        : "ItemCode",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: TableHeaderColor,
                                  child: Center(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.details_outlined,
                                                size: 15,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                  Responsive.isDesktop(context)
                                                      ? "Item Description"
                                                      : "Item Desc",
                                                  textAlign: TextAlign.center,
                                                  style: commonLabelTextStyle),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .production_quantity_limits,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text("Qty.Ordered",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
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
                          if (_isLoadingData)
                            Padding(
                              padding: const EdgeInsets.only(top: 100.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (mergedData.isNotEmpty)
                            ...mergedData.map((data) {
                              var sno = data['sno'].toString();
                              var invoiceno = data['invoiceno'].toString();
                              var itemcode = data['itemcode'].toString();

                              var itemdetails = data['itemdetails'].toString();
                              var sendqty = data['sendqty'] != null
                                  ? data['sendqty'].toString()
                                  : 'N/A'; // Default to 'N/A' if null

                              bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                              Color? rowColor = isEvenRow
                                  ? Color.fromARGB(224, 255, 255, 255)
                                  : Color.fromARGB(224, 255, 255, 255);

                              return GestureDetector(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10.0,
                                    right: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          width: 75,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SelectableText(
                                                sno,
                                                textAlign: TextAlign.left,
                                                style: TableRowTextStyle,
                                                showCursor: false,
                                                // overflow: TextOverflow.ellipsis,
                                                cursorColor: Colors.blue,
                                                cursorWidth: 2.0,
                                                toolbarOptions: ToolbarOptions(
                                                    copy: true,
                                                    selectAll: true),
                                                onTap: () {
                                                  // Optional: Handle single tap if needed
                                                },
                                              ),
                                              // Text(invoiceno,
                                              //     textAlign: TextAlign.center,
                                              //     style: TableRowTextStyle),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          width: 200,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SelectableText(
                                                invoiceno,
                                                textAlign: TextAlign.left,
                                                style: TableRowTextStyle,
                                                showCursor: false,
                                                // overflow: TextOverflow.ellipsis,
                                                cursorColor: Colors.blue,
                                                cursorWidth: 2.0,
                                                toolbarOptions: ToolbarOptions(
                                                    copy: true,
                                                    selectAll: true),
                                                onTap: () {
                                                  // Optional: Handle single tap if needed
                                                },
                                              ),
                                              // Text(line_id,
                                              //     textAlign: TextAlign.center,
                                              //     style: TableRowTextStyle),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          width: 150,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis
                                                .horizontal, // Changed to horizontal
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SelectableText(
                                                  itemcode,
                                                  textAlign: TextAlign.left,
                                                  style: TableRowTextStyle,
                                                  showCursor: false,
                                                  cursorColor: Colors.blue,
                                                  cursorWidth: 2.0,
                                                  toolbarOptions:
                                                      ToolbarOptions(
                                                    copy: true,
                                                    selectAll: true,
                                                  ),
                                                  onTap: () {
                                                    // Optional: Handle single tap if needed
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Tooltip(
                                        message: itemdetails,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SelectableText(
                                                  itemdetails,
                                                  textAlign: TextAlign.left,
                                                  style: TableRowTextStyle,
                                                  showCursor: false,
                                                  // overflow: TextOverflow.ellipsis,
                                                  cursorColor: Colors.blue,
                                                  cursorWidth: 2.0,
                                                  toolbarOptions:
                                                      ToolbarOptions(
                                                          copy: true,
                                                          selectAll: true),
                                                  onTap: () {
                                                    // Optional: Handle single tap if needed
                                                  },
                                                ),
                                                // Text(itemdetails,
                                                //     textAlign: TextAlign.center,
                                                //     style: TableRowTextStyle),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SelectableText(
                                                sendqty,
                                                textAlign: TextAlign.left,
                                                style: TableRowTextStyle,
                                                showCursor: false,
                                                // overflow: TextOverflow.ellipsis,
                                                cursorColor: Colors.blue,
                                                cursorWidth: 2.0,
                                                toolbarOptions: ToolbarOptions(
                                                    copy: true,
                                                    selectAll: true),
                                                onTap: () {
                                                  // Optional: Handle single tap if needed
                                                },
                                              ),
                                              // Text(invoiceQty,
                                              //     textAlign: TextAlign.center,
                                              //     style: TableRowTextStyle),
                                            ],
                                          ),
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
                              child: Text("No data available."),
                            ),
                        ]),
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
    Color? rowColor = isEvenRow
        ? Color.fromARGB(224, 255, 255, 255)
        : Color.fromARGB(224, 255, 255, 255);

    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataCell(data['sno'].toString(), rowColor),
            _buildDataCell(data['invoiceno'].toString(), rowColor),
            _buildDataCell(data['itemcode'].toString(), rowColor),
            _buildDataCell(data['itemdetails'].toString(), rowColor,
                isDescription: true), // Pass isDescription = true
            _buildDataCell(data['sendqty'].toString(), rowColor),
          ],
        ),
      ),
    );
  }

  int getcount(List<Map<String, dynamic>> tableData) {
    return tableData.length;
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

  bool _isLoading = true;
  TextEditingController TockenController = TextEditingController();

  Future<void> FetchLastDipatchNo() async {
    print("Error Skiped Dispatch Id called");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno');

    final IpAddress = await getActiveIpAddress();
    final url = '$IpAddress/Delivery_Id_View/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String lastDeliveryId = data['DELIVERY_ID']?.toString() ?? '';

        if (lastDeliveryId.isNotEmpty) {
          // Example format: DL2510610
          RegExp regExp = RegExp(r'^([A-Z]{2})(\d{2})(\d{2})(\d+)$');
          Match? match = regExp.firstMatch(lastDeliveryId);

          if (match != null) {
            String variable = match.group(1)!; // 'DL'
            String year = match.group(2)!; // '25'
            String month = match.group(3)!; // '10'
            String digits = match.group(4)!; // '610'

            // Generate tocken value (digits part)
            String tocken = digits;

            // You can now use these values as needed
            // Example: set to your controllers
            Dispatch_idController.text = '$variable$year$month$tocken';
            TockenController.text =
                tocken; // if you have a controller for token

            await saveToSharedPreferences(
                "${Dispatch_idController.text}", "${TockenController.text}");
          } else {
            // Fallback if the format does not match
            Dispatch_idController.text = lastDeliveryId;
            TockenController.text = '';
          }
        } else {
          // If no delivery ID returned, create a new default one
          final now = DateTime.now();
          String variable = 'DL';
          String year = now.year.toString().substring(2);
          String month = now.month.toString().padLeft(2, '0');
          String digits = '001';
          String newDeliveryId = '$variable$year$month$digits';

          Dispatch_idController.text = newDeliveryId;
          TockenController.text = digits;
        }
      } else {
        // Handle non-200 status code
        Dispatch_idController.text = "DELVID_ERR";
        TockenController.text = '';
      }
    } catch (e) {
      // Handle network or JSON parsing errors
      Dispatch_idController.text = "DELVID_EXC";
      TockenController.text = '';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int currentLength = 0;
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
                                  Icons.auto_fix_high,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Generate Dispatch',
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
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors
                          .white, // You can adjust the background color here
                      border: Border.all(
                        color: Colors.grey[400]!, // Border color
                        width: 1.0, // Border width
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(
                                left: Responsive.isDesktop(context) ? 30 : 10,
                                bottom: 0),
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              runSpacing: 0,
                              children: [
                                // _buildTextFieldDesktop(
                                //     'Dispatch ID',
                                //     Dispatch_idController,
                                //     Icons.numbers,
                                //     true,
                                //     Icons.star,
                                //     Colors.red,
                                //     dispatchidfocusnode,
                                //     reqnofocusnode),
                                // SizedBox(
                                //     width:
                                //         Responsive.isDesktop(context) ? 0 : 10),
                                _buildTextFieldDesktop(
                                    'DispatchReq No',
                                    ReqNoController,
                                    Icons.request_page,
                                    true,
                                    Icons.star,
                                    Colors.red,
                                    reqnofocusnode,
                                    warehousefocusnode),
                                _buildTextFieldDesktop(
                                    'Physical Warehouse',
                                    WarehouseController,
                                    Icons.warehouse,
                                    true,
                                    Icons.star,
                                    Colors.red,
                                    warehousefocusnode,
                                    regionfocusnode),
                                _buildTextFieldDesktop(
                                    'Region',
                                    RegionController,
                                    Icons.location_city,
                                    true,
                                    Icons.star,
                                    Colors.red,
                                    regionfocusnode,
                                    customernofocusnode),
                                SizedBox(
                                    width:
                                        Responsive.isDesktop(context) ? 0 : 10),
                                _buildTextFieldDesktop(
                                    'Customer No',
                                    CustomerNoController,
                                    Icons.no_accounts,
                                    true,
                                    Icons.star,
                                    Colors.red,
                                    customernofocusnode,
                                    customernamefocusnode),

                                _buildTextFieldDesktop(
                                    'Customer Name',
                                    CustomerNameController,
                                    Icons.perm_identity,
                                    true,
                                    Icons.star,
                                    Colors.red,
                                    customernamefocusnode,
                                    customersitefocusnode),
                                SizedBox(
                                    width:
                                        Responsive.isDesktop(context) ? 0 : 10),
                                _buildTextFieldDesktop(
                                    'Customer Site',
                                    CustomerSiteController,
                                    Icons.sixteen_mp_outlined,
                                    true,
                                    Icons.star,
                                    Colors.red,
                                    customersitefocusnode,
                                    vendorfocusnode),
                                _buildTextFieldDesktop(
                                    'Transporter Name',
                                    VendorController,
                                    Icons.shop,
                                    false,
                                    Icons.star,
                                    Colors.red,
                                    vendorfocusnode,
                                    vendorsitefocusnode),
                                SizedBox(
                                    width:
                                        Responsive.isDesktop(context) ? 0 : 10),
                                _buildTextFieldDesktop(
                                    'Driver Name',
                                    DriverController,
                                    Icons.shop,
                                    false,
                                    Icons.star,
                                    Colors.red,
                                    vendorsitefocusnode,
                                    driverfocusnode),
                                _buildTextFieldDesktop(
                                    'Driver MobileNo',
                                    DriverMobileNoController,
                                    Icons.drive_file_rename_outline,
                                    false,
                                    Icons.star,
                                    Colors.red,
                                    driverfocusnode,
                                    vehiclenofocusnode),
                                SizedBox(
                                    width:
                                        Responsive.isDesktop(context) ? 0 : 10),
                                _buildTextFieldDesktop(
                                    'Vehicle No',
                                    VehicleNoController,
                                    Icons.drive_eta,
                                    false,
                                    Icons.star,
                                    Colors.red,
                                    vehiclenofocusnode,
                                    truckdimfocusnode),
                                _buildTextFieldDesktop(
                                    'Truck Dimension:Ft',
                                    TruckDimentionController,
                                    Icons.drive_eta,
                                    false,
                                    Icons.star,
                                    Colors.transparent,
                                    truckdimfocusnode,
                                    loadingchargefocusnode),
                                SizedBox(
                                    width:
                                        Responsive.isDesktop(context) ? 0 : 10),
                                _buildTextFieldDesktop(
                                    'Loading Charges',
                                    LoadingChargeController,
                                    Icons.monetization_on,
                                    false,
                                    Icons.star,
                                    Colors.transparent,
                                    loadingchargefocusnode,
                                    transportchargefocusnode),
                                _buildTextFieldDesktop(
                                    'Transport Charges',
                                    TransportChargeController,
                                    Icons.local_shipping,
                                    false,
                                    Icons.star,
                                    Colors.transparent,
                                    transportchargefocusnode,
                                    miscchargefocusnode),
                                SizedBox(
                                    width:
                                        Responsive.isDesktop(context) ? 0 : 10),
                                _buildTextFieldDesktop(
                                    'Misc Charges',
                                    MISCController,
                                    Icons.miscellaneous_services,
                                    false,
                                    Icons.star,
                                    Colors.transparent,
                                    miscchargefocusnode,
                                    remarksfocusnode),
                                _buildTextFieldDesktop(
                                    'Remarks',
                                    RemarksController,
                                    Icons.miscellaneous_services,
                                    false,
                                    Icons.star,
                                    Colors.transparent,
                                    remarksfocusnode,
                                    savebuttonfocusnode),
                                SizedBox(
                                    width:
                                        Responsive.isDesktop(context) ? 0 : 10),
                                _buildTextFieldDesktop(
                                    'Salesman Remarks',
                                    salesmanRemarksController,
                                    Icons.miscellaneous_services,
                                    true,
                                    Icons.star,
                                    Colors.transparent,
                                    salesmanremarksfocusnode,
                                    savebuttonfocusnode),
                                _buildTextFieldDesktop(
                                    'Delivery Date',
                                    DeliveryDateController,
                                    Icons.miscellaneous_services,
                                    true,
                                    Icons.star,
                                    Colors.transparent,
                                    Deliverydatefocusnode,
                                    savebuttonfocusnode),
                                SizedBox(
                                    width:
                                        Responsive.isDesktop(context) ? 0 : 10),
                                Container(
                                  width: Responsive.isDesktop(context)
                                      ? screenWidth * 0.15
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
                                            Text('Delivery Address',
                                                style: textboxheading),
                                            Icon(
                                              Icons.star,
                                              size: 8,
                                              color: Colors.red,
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 0, bottom: 0),
                                          child: Row(
                                            children: [
                                              Container(
                                                  // height: 32,
                                                  // width: Responsive.isDesktop(context)
                                                  //     ? screenWidth * 0.086
                                                  //     : 130,

                                                  width: Responsive.isDesktop(
                                                          context)
                                                      ? screenWidth * 0.15
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
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          TextFormField(
                                                            // focusNode:
                                                            //     Deliverydatefocusnode,
                                                            // onFieldSubmitted: (_) =>
                                                            //     _fieldFocusChange(
                                                            //         context,
                                                            //         Deliverydatefocusnode,
                                                            //         delivera),
                                                            maxLength:
                                                                250, // Limits input to 250 characters
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
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                vertical: 5.0,
                                                                horizontal:
                                                                    10.0,
                                                              ),
                                                              counterText:
                                                                  '', // Hides the default counter text
                                                            ),
                                                            controller:
                                                                deliverAddressController,
                                                            style: TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      73,
                                                                      72,
                                                                      72),
                                                              fontSize: 15,
                                                            ),
                                                            onChanged: (value) {
                                                              setState(() {
                                                                currentLength =
                                                                    value
                                                                        .length;
                                                              });
                                                            },
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 5.0),
                                                            child: Text(
                                                              '$currentLength/250',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Container(
                                //   width: Responsive.isDesktop(context)
                                //       ? MediaQuery.of(context).size.width * 0.26
                                //       : MediaQuery.of(context).size.width * 0.4,
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
                                //             Icon(
                                //               Icons.star,
                                //               size: 8,
                                //               color: Colors.red,
                                //             )
                                //           ],
                                //         ),
                                //         const SizedBox(height: 10),
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
                                //                       ? MediaQuery.of(context)
                                //                               .size
                                //                               .width *
                                //                           0.23
                                //                       : MediaQuery.of(context)
                                //                               .size
                                //                               .width *
                                //                           0.4,
                                //                   child: MouseRegion(
                                //                     onEnter: (event) {
                                //                       // You can perform any action when mouse enters, like logging the value.
                                //                     },
                                //                     onExit: (event) {
                                //                       // Perform any action when the mouse leaves the TextField area.
                                //                     },
                                //                     cursor: SystemMouseCursors
                                //                         .click, // Changes the cursor to indicate interaction
                                //                     child: TextFormField(
                                //                       // focusNode:
                                //                       //     deliveryaddressFocusNode,
                                //                       // onFieldSubmitted: (_) =>
                                //                       // _fieldFocusChange(
                                //                       //     context,
                                //                       //     de,
                                //                       //     InvoiceFocusNode),
                                //                       decoration:
                                //                           InputDecoration(
                                //                         enabledBorder:
                                //                             OutlineInputBorder(
                                //                           borderSide:
                                //                               BorderSide(
                                //                             color:
                                //                                 Color.fromARGB(
                                //                                     201,
                                //                                     132,
                                //                                     132,
                                //                                     132),
                                //                             width: 1.0,
                                //                           ),
                                //                         ),
                                //                         focusedBorder:
                                //                             OutlineInputBorder(
                                //                           borderSide:
                                //                               BorderSide(
                                //                             color:
                                //                                 Color.fromARGB(
                                //                                     255,
                                //                                     58,
                                //                                     58,
                                //                                     58),
                                //                             width: 1.0,
                                //                           ),
                                //                         ),
                                //                         contentPadding:
                                //                             const EdgeInsets
                                //                                 .symmetric(
                                //                           vertical: 5.0,
                                //                           horizontal: 10.0,
                                //                         ),
                                //                       ),
                                //                       controller:
                                //                           deliverAddressController,
                                //                       style: TextStyle(
                                //                           color: Color.fromARGB(
                                //                               255, 73, 72, 72),
                                //                           fontSize: 15),
                                //                       // onEditingComplete: () => _fieldFocusChange(
                                //                       //     context, fromFocusNode, toFocusNode),
                                //                     ),
                                //                   )),
                                //             ],
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),

                                // _buildTextFieldDesktop(
                                //     'Delivery Address',
                                //     deliverAddressController,
                                //     Icons.miscellaneous_services,
                                //     true,
                                //     Icons.star,
                                //     Colors.transparent,
                                //     remarksfocusnode,
                                //     savebuttonfocusnode),
                              ],
                            )),
                        // SizedBox(
                        //   height: 15,
                        // ),

                        Padding(
                          padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 30 : 10),
                          child: Text("Dispatch Items", style: topheadingbold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        if (Responsive.isDesktop(context))
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 15, left: 35, right: 35),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors
                                    .white, // You can adjust the background color here
                                border: Border.all(
                                  color: Colors.grey[400]!, // Border color
                                  width: 1.0, // Border width
                                ),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: _buildTable(),
                              ),
                            ),
                          ),
                        if (!Responsive.isDesktop(context))
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 15,
                            ),
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
                                  left:
                                      MediaQuery.of(context).size.width * 0.03),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? MediaQuery.of(context).size.width *
                                            0.09
                                        : MediaQuery.of(context).size.width *
                                            0.4,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 20),
                                          Row(
                                            children: const [
                                              Text("No. Of Send Item",
                                                  style: textboxheading),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0, bottom: 0),
                                            child: Container(
                                              height: 30,
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.09
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.4,
                                              child: TextField(
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
                                                    filled: true,
                                                    fillColor: Color.fromARGB(
                                                        255, 250, 250, 250),
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

                            // Right Side - Total Send Qty Section
                            Padding(
                              padding: EdgeInsets.only(
                                  right:
                                      MediaQuery.of(context).size.width * 0.03),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
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
                                          const SizedBox(height: 20),
                                          Row(
                                            children: const [
                                              Text("Total Send Qty",
                                                  style: textboxheading),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0, bottom: 0),
                                            child: Container(
                                              height: 30,
                                              width:
                                                  Responsive.isDesktop(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.09
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.3,
                                              child: TextField(
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
                                                    filled: true,
                                                    fillColor: Color.fromARGB(
                                                        255, 250, 250, 250),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 10.0,
                                                    ),
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
                          height: 30,
                        ),
                        (Responsive.isDesktop(context))
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 45,
                                  ),
                                  Container(
                                    decoration:
                                        BoxDecoration(color: buttonColor),
                                    height: 30,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (!validateFields()) {
                                          // If any field is empty, show the validation dialog
                                          showValidationDialog(context);
                                        } else {
                                          showInvoiceDialog(
                                              context, true, tableData);
                                        }
                                        postLogData("General Dispatch",
                                            "Generate Preview to save");
                                      },
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
                                        child: const Text(
                                          'Gen Dispatch Slip',
                                          style: commonWhiteStyle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  // Container(
                                  //     decoration:
                                  //         BoxDecoration(color: buttonColor),
                                  //     height: 30,
                                  //     child: ElevatedButton(
                                  //       onPressed: () {
                                  //         if (!validateFields()) {
                                  //           // If any field is empty, show the validation dialog
                                  //           showValidationDialog(context);
                                  //         } else {
                                  //           showInvoiceDialog(
                                  //               context, false, tableData);
                                  //         }
                                  //       },
                                  //       style: ElevatedButton.styleFrom(
                                  //         shape: RoundedRectangleBorder(
                                  //           borderRadius:
                                  //               BorderRadius.circular(8),
                                  //         ),
                                  //         minimumSize: const Size(45.0,
                                  //             31.0), // Set width and height
                                  //         backgroundColor: Colors
                                  //             .transparent, // Make background transparent to show gradient
                                  //         shadowColor: Colors
                                  //             .transparent, // Disable shadow to preserve gradient
                                  //       ),
                                  //       child: Padding(
                                  //         padding: const EdgeInsets.only(
                                  //             top: 5,
                                  //             bottom: 5,
                                  //             left: 8,
                                  //             right: 8),
                                  //         child: const Text(
                                  //           'Preview',
                                  //           style: TextStyle(
                                  //               fontSize: 16,
                                  //               color: Colors.white),
                                  //         ),
                                  //       ),
                                  //     )),
                                  // SizedBox(
                                  //   width: 15,
                                  // ),
                                  Container(
                                    decoration:
                                        BoxDecoration(color: buttonColor),
                                    height: 30,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Dispatch_idController.clear();
                                        ReqNoController.clear();
                                        WarehouseController.clear();
                                        OrgIdController.clear();
                                        CustomerNoController.clear();
                                        CustomerNameController.clear();
                                        CustomerSiteController.clear();
                                        StaffController.clear();
                                        VendorController.clear();
                                        DriverMobileNoController.clear();
                                        DriverController.clear();
                                        VehicleNoController.clear();
                                        TruckDimentionController.clear();
                                        LoadingChargeController.clear();
                                        MISCController.clear();
                                        TransportChargeController.clear();
                                        RemarksController.clear();

                                        fetchWarehouseDetails();
                                        // Navigator.pushReplacement(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) => MainSidebar(
                                        //         enabledItems: accessControl,
                                        //         initialPageIndex: 4),
                                        //   ),
                                        // );
                                        widget.togglePage();

                                        postLogData("General Dispatch",
                                            "Cancel Dispatch");
                                      },
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
                                        child: const Text(
                                          'Cancel Dispatch',
                                          style: commonWhiteStyle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration:
                                          BoxDecoration(color: buttonColor),
                                      height: 30,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (!validateFields()) {
                                            // If any field is empty, show the validation dialog
                                            showValidationDialog(context);
                                          } else {
                                            showInvoiceDialog(
                                                context, true, tableData);
                                          }
                                        },
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
                                          child: const Text(
                                            'Gen Dispatch Slip',
                                            style: commonWhiteStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    // Container(
                                    //     decoration:
                                    //         BoxDecoration(color: buttonColor),
                                    //     height: 30,
                                    //     child: ElevatedButton(
                                    //       onPressed: () {
                                    //         if (!validateFields()) {
                                    //           // If any field is empty, show the validation dialog
                                    //           showValidationDialog(context);
                                    //         } else {
                                    //           showInvoiceDialog(
                                    //               context, false, tableData);
                                    //         }
                                    //       },
                                    //       style: ElevatedButton.styleFrom(
                                    //         shape: RoundedRectangleBorder(
                                    //           borderRadius:
                                    //               BorderRadius.circular(8),
                                    //         ),
                                    //         minimumSize: const Size(45.0,
                                    //             31.0), // Set width and height
                                    //         backgroundColor: Colors
                                    //             .transparent, // Make background transparent to show gradient
                                    //         shadowColor: Colors
                                    //             .transparent, // Disable shadow to preserve gradient
                                    //       ),
                                    //       child: Padding(
                                    //         padding: const EdgeInsets.only(
                                    //             top: 5,
                                    //             bottom: 5,
                                    //             left: 8,
                                    //             right: 8),
                                    //         child: const Text(
                                    //           'Preview',
                                    //           style: TextStyle(
                                    //               fontSize: 16,
                                    //               color: Colors.white),
                                    //         ),
                                    //       ),
                                    //     )),
                                    // SizedBox(height: 15),
                                    Container(
                                      decoration:
                                          BoxDecoration(color: buttonColor),
                                      height: 30,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Dispatch_idController.clear();
                                          ReqNoController.clear();
                                          WarehouseController.clear();
                                          OrgIdController.clear();
                                          CustomerNoController.clear();
                                          CustomerNameController.clear();
                                          CustomerSiteController.clear();
                                          StaffController.clear();
                                          VendorController.clear();
                                          DriverMobileNoController.clear();
                                          DriverController.clear();
                                          VehicleNoController.clear();
                                          TruckDimentionController.clear();
                                          LoadingChargeController.clear();
                                          MISCController.clear();
                                          TransportChargeController.clear();
                                          RemarksController.clear();

                                          fetchWarehouseDetails();
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MainSidebar(
                                                  enabledItems: accessControl,
                                                  initialPageIndex: 104),
                                            ),
                                          );
                                        },
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
                                          child: const Text(
                                            'Cancel Dispatch',
                                            style: commonWhiteStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
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

  void showInvoiceDialog(
    BuildContext context,
    bool buttonname,
    List<Map<String, dynamic>> tableData,
  ) {
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: 595,
                    height: 900,
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
                                buttonname
                                    ? 'Delivery Receipt'
                                    : 'Preview Generate Dipatch Print',
                                style: TextStyle(
                                  fontSize: 13,
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
                                        successfullyLoginMessage();
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
                                          'Gen Dispatch',
                                          style: commonWhiteStyle,
                                        ),
                                      ),
                                    )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset('assets/images/logo.jpg', height: 50),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Text('123 Restaurant St, City Name',
                                  //     style: TextStyle(
                                  //         fontSize: 11, color: Colors.grey)),
                                  // Text('Phone: +91 12345 67890',
                                  //     style: TextStyle(
                                  //         fontSize: 11, color: Colors.grey)),
                                  // Text('Website: www.aljeflutterapp.com',
                                  //     style: TextStyle(
                                  //         fontSize: 11, color: Colors.grey)),
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
                                'Delivery No: ${Dispatch_idController.text}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[600]),
                              ),
                              Text(
                                DateFormat('dd-MMM-yyyy')
                                    .format(DateTime.now())
                                    .toUpperCase(), // Convert month to uppercase
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey[600],
                                ),
                              )
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
                                  'Region: ',
                                  RegionController.text,
                                  'Customer No: ',
                                  CustomerNoController.text,
                                ),
                                _buildDetailRow(
                                  'Transporter Name: ',
                                  VendorController.text,
                                  'Customer Name: ',
                                  CustomerNameController.text,
                                ),
                                _buildDetailRow(
                                  'Vehicle No: ',
                                  VehicleNoController.text,
                                  'Customer Site: ',
                                  CustomerSiteController.text,
                                ),
                                _buildDetailRow(
                                  'Driver Name: ',
                                  DriverController.text,
                                  '',
                                  '',
                                ),
                                _buildDetailRow(
                                  'Driver Mobile No: ',
                                  DriverMobileNoController.text,
                                  '',
                                  '',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),

                          Text(
                            'Dispatch Items:',
                            style: TextStyle(
                                fontSize: 13,
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
                          Text(
                            'Thank you for your business!',
                            style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Colors.blueGrey[700]),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Authorized Signature: __________',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              Text('Customer Signature: __________',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          Divider(thickness: 1),
                          SizedBox(height: 8),
                          Text(
                            'Contact us: support@aljeflutterapp.com',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          // SizedBox(height: 8),
                          // Text(
                          //   'Follow us on social media for updates!',
                          //   style: TextStyle(fontSize: 12, color: Colors.grey),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(10),
                //   child: Container(
                //     width: 595,
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.end,
                //       children: [
                //         Container(
                //             height: 35,
                //             decoration: BoxDecoration(color: buttonColor),
                //             child: ElevatedButton(
                //               onPressed: () async {
                //                 // await _savePdf();
                //                 _captureAndSavePdf();
                //               },
                //               style: ElevatedButton.styleFrom(
                //                 shape: RoundedRectangleBorder(
                //                   borderRadius: BorderRadius.circular(8),
                //                 ),
                //                 minimumSize: const Size(45.0, 31.0),
                //                 backgroundColor: Colors.transparent,
                //                 shadowColor: Colors.transparent,
                //               ),
                //               child: Padding(
                //                 padding: const EdgeInsets.only(
                //                     top: 5, bottom: 5, left: 8, right: 8),
                //                 child: const Text(
                //                   'Print',
                //                   style: TextStyle(
                //                       fontSize: 16, color: Colors.white),
                //                 ),
                //               ),
                //             )),
                //         SizedBox(
                //           width: 20,
                //         ),
                //         Container(
                //             height: 35,
                //             decoration: BoxDecoration(color: buttonColor),
                //             child: ElevatedButton(
                //               onPressed: () async {
                //                 // await _savePdf();
                //                 _captureAndSavePdf();
                //               },
                //               style: ElevatedButton.styleFrom(
                //                 shape: RoundedRectangleBorder(
                //                   borderRadius: BorderRadius.circular(8),
                //                 ),
                //                 minimumSize: const Size(45.0, 31.0),
                //                 backgroundColor: Colors.transparent,
                //                 shadowColor: Colors.transparent,
                //               ),
                //               child: Padding(
                //                 padding: const EdgeInsets.only(
                //                     top: 5, bottom: 5, left: 8, right: 8),
                //                 child: const Text(
                //                   'Generate Pdf',
                //                   style: TextStyle(
                //                       fontSize: 16, color: Colors.white),
                //                 ),
                //               ),
                //             )),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

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
                fontSize: 12,
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
                  fontSize: 12,
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

// Helper function to truncate value2
  String _truncateText(String text) {
    const int maxChars = 10; // Number of characters to show
    if (text.length > maxChars) {
      int halfLength = maxChars ~/ 2; // Display half the max characters
      return '${text.substring(0, halfLength)}...';
    }
    return text;
  }

  void showValidationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: const Text('Validation Error'),
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

  bool validateFields() {
    String cusid =
        CustomerNoController.text.isNotEmpty ? CustomerNoController.text : '0';
    String? cusname = CustomerNameController.text.isNotEmpty
        ? CustomerNameController.text
        : null;
    String cusno =
        CustomerNoController.text.isNotEmpty ? CustomerNoController.text : '0';
    String cussite = CustomerSiteController.text.isNotEmpty
        ? CustomerSiteController.text
        : '0';

    String vendor =
        VendorController.text.isNotEmpty ? VendorController.text : '';
    String drivermobileno = DriverMobileNoController.text.isNotEmpty
        ? DriverMobileNoController.text
        : '';
    String driverid =
        DriverController.text.isNotEmpty ? DriverController.text : '';
    String vehicleNo =
        VehicleNoController.text.isNotEmpty ? VehicleNoController.text : '';

    // Check if any fields are empty
    return cusid.isNotEmpty &&
        cusname != null &&
        cusno.isNotEmpty &&
        cussite.isNotEmpty &&
        vendor.isNotEmpty &&
        drivermobileno.isNotEmpty &&
        driverid.isNotEmpty &&
        vehicleNo.isNotEmpty;
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

  TextEditingController deliverAddressController = TextEditingController();

  TextEditingController salesmanRemarksController = TextEditingController();

  TextEditingController DeliveryDateController = TextEditingController(
      text: DateFormat('dd-MMM-yyyy').format(DateTime.now()));

  Future<void> fetchDispatchDetails() async {
    String reqno = ReqNoController.text;
    String cusno = CustomerNoController.text;

    String cussite = CustomerSiteController.text.toString();

    final IpAddress = await getActiveIpAddress();

    final url =
        '$IpAddress/FilteredCreateDispatchView/${ReqNoController.text}/$cusno/$cussite/';
    print("urlllllllllllllll : $url");
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
        final List<dynamic> data = json.decode(decodedBody);
        if (data.isNotEmpty) {
          final firstItem = data[0];
          setState(() {
            salesmanRemarksController.text = firstItem['REMARKS'] ?? 'null';
            deliverAddressController.text =
                firstItem['DELIVERYADDRESS'] ?? 'null';

            // Parse and format the DELIVERY_DATE
            String deliveryDateRaw = firstItem['DELIVERY_DATE'] ?? '';
            if (deliveryDateRaw.isNotEmpty) {
              try {
                DateTime deliveryDate = DateTime.parse(deliveryDateRaw);
                String formattedDate =
                    DateFormat('dd-MMM-yyyy').format(deliveryDate);
                DeliveryDateController.text = formattedDate;
              } catch (e) {
                print("Error parsing delivery date: $e");
                DeliveryDateController.text = 'Invalid date';
              }
            } else {
              DeliveryDateController.text = 'No date provided';
            }

            print(
                "RemarksController : ${salesmanRemarksController.text}   deliverAddressController  : ${deliverAddressController.text} delivery data ${DeliveryDateController.text}");
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

  Future<void> fetchTokenwithCusid() async {
    final ipAddress = await getActiveIpAddress();

    try {
      final response = await http.get(
        Uri.parse('$ipAddress/Deliver_Id_Generate/'),
      );
      print("urlssss $ipAddress/Deliver_Id_Generate/");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        String deliveryId = data['DELIVERY_ID']?.toString() ?? '';
        String token = data['TOCKEN']?.toString() ?? 'No Token found';

        setState(() {
          // Update UI if needed
        });

        print('dispatch idd: $deliveryId  token: $token');

        await saveToSharedPreferences(deliveryId, token);
      } else {
        print(
            'Faileddddddddddddddd to fetch data. Status code: ${response.statusCode}');

        await FetchLastDipatchNo();
      }
    } catch (e) {
      print('Error: $e');

      await FetchLastDipatchNo();
    }
  }

  Future<void> saveToSharedPreferences(String lastCusID, String token) async {
    print('Saved tocked to the shared pegerence $token');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('Unique_deliver_id', lastCusID);
    await prefs.setString('Unique_deliver_id_token', token);
  }

  Future<void> DeleteTocked() async {
    print('delete tocked to the shared pegerence ');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('Unique_deliver_id');
    await prefs.remove('Unique_deliver_id_token');
  }

  String? Unique_deliver_id;
  Future<void> postTruck_scan() async {
    await fetchTokenwithCusid();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final salesloginno = prefs.getString('salesloginno') ?? '';
    final saveloginname = prefs.getString('saveloginname') ?? '';
    final saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';

    Unique_deliver_id = prefs.getString('Unique_deliver_id');

    final IpAddress = await getActiveIpAddress();
    final url = Uri.parse("$IpAddress/truck_scan_view/");
    final formattedDate =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now());
    final parsedDate =
        DateFormat("dd-MMM-yyyy").parse(DeliveryDateController.text);
    final formattedDeliveryDate =
        DateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(parsedDate);

    final header = {
      "DISPATCH_ID": Unique_deliver_id,
      "REQ_ID": ReqNoController.text,
      "DATE": formattedDate,
      "PHYSICAL_WAREHOUSE": WarehouseController.text,
      "ORG_ID": saleslogiOrgid,
      "ORG_NAME": RegionController.text,
      "STAFF_NO": salesloginno,
      "STAFF_NAME": saveloginname,
      "CUSTOMER_NUMBER": widget.cusno,
      "CUSTOMER_NAME": widget.cusname,
      "CUSTOMER_SITE_ID": widget.cussite,
      "TRANSPORTER_NAME": VendorController.text,
      "DRIVER_NAME": DriverController.text,
      "DRIVER_MOBILENO": int.tryParse(DriverMobileNoController.text) ?? 0,
      "VEHICLE_NO": VehicleNoController.text,
      "TRUCK_DIMENSION": TruckDimentionController.text,
      "LOADING_CHARGES": int.tryParse(LoadingChargeController.text) ?? 0,
      "TRANSPORT_CHARGES": int.tryParse(TransportChargeController.text) ?? 0,
      "MISC_CHARGES": int.tryParse(MISCController.text) ?? 0,
      "DELIVERYADDRESS": deliverAddressController.text,
      "SALESMANREMARKS": salesmanRemarksController.text,
      "REMARKS": RemarksController.text,
      "CREATION_DATE": formattedDate,
      "CREATED_BY": saveloginname,
      "CREATED_IP": 'null',
      "CREATED_MAC": 'null',
      "LAST_UPDATE_DATE": formattedDate,
      "LAST_UPDATED_BY": 'null',
      "LAST_UPDATE_IP": 'null',
      "FLAG": 'A',
      "DELIVERY_DATE": formattedDeliveryDate,
    };

    final payload = {
      ...header,
      "tabledata": tableData,
    };

    print("tabledataaaaa: ${tableData}");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) {
      print("Generate Dispatch Success: ${response.body}");

      final responseData = jsonDecode(response.body);

      // Extract message and find delivery ID in it
      final message = responseData['message'] ?? '';
      final undelSummary = responseData['undel_summary'];

      // Example message: "DL2532 truck scan rows inserted successfully"
      final regex =
          RegExp(r'^(DL\d+)\b'); // Match DL followed by numbers at start
      final match = regex.firstMatch(message);

      if (match != null) {
        final extractedDeliveryId = match.group(1); // e.g. "DL2532"
        print("Extracted Delivery ID: $extractedDeliveryId");
        print("Unique_deliver_id: $Unique_deliver_id");

        if (extractedDeliveryId == Unique_deliver_id) {
          print("✅ Delivery ID matches! Proceeding...");
          await _launchUrl(context);
          await _launchUrldetailed(context);
        } else {
          print("❌ Delivery ID mismatch. Skipping launch.");
        }

        // Optionally, continue with posting truck header
        await postTruck_Header_scan(Unique_deliver_id!);
      } else {
        print("⚠️ Could not extract Delivery ID from message.");
      }

      // for (var row in tableData) {
      //   // print("tableeeee datasssss $tableData");
      //   var sendQty =
      //       int.tryParse(row['sendqty'].toString()) ?? 0; // Ensure integer
      //   var Udel_id =
      //       int.tryParse(row['Udel_id'].toString()) ?? 0; // Ensure integer

      //   print('sendddddqty:$sendQty');
      //   print('Udel_id:$Udel_id');

      //   await updateQuantity(Udel_id, sendQty);
      // }
      await processTableData(tableData);

      Dispatch_idController.clear();
      ReqNoController.clear();
      WarehouseController.clear();
      OrgIdController.clear();
      CustomerNoController.clear();
      CustomerNameController.clear();
      CustomerSiteController.clear();
      StaffController.clear();
      VendorController.clear();
      DriverMobileNoController.clear();
      DriverController.clear();
      VehicleNoController.clear();
      TruckDimentionController.clear();
      LoadingChargeController.clear();
      MISCController.clear();
      TransportChargeController.clear();
      RemarksController.clear();

      // Clear the table data
      tableData.clear();
      filteredData.clear();
      await fetchWarehouseDetails();
      await DeleteTocked();

      postLogData(
          "General Dispatch", "Generate Dispatch Saved $Unique_deliver_id");
    } else {
      print("Error ${response.statusCode}");
    }
  }

// ✅ Corrected and optimized version
  Future<void> processTableData(List<Map<String, dynamic>> tableData) async {
    // Step 1: Create a map to accumulate total sendqty per Udel_id
    Map<int, int> quantityMap = {};

    for (var row in tableData) {
      int sendQty = int.tryParse(row['sendqty'].toString()) ?? 0;
      int udelId = int.tryParse(row['Udel_id'].toString()) ?? 0;

      // Skip invalid IDs
      if (udelId == 0) continue;

      // Accumulate sendQty for same Udel_id
      quantityMap[udelId] = (quantityMap[udelId] ?? 0) + sendQty;
    }

    // Step 2: Loop through the combined data and call updateQuantity once per Udel_id
    for (var entry in quantityMap.entries) {
      int udelId = entry.key;
      int totalSendQty = entry.value;

      print('🟢 Final Udel_id: $udelId');
      print('🟢 Total sendqty: $totalSendQty');

      await updateQuantity(udelId, totalSendQty);
      // await insertDispatchData(deliveryId, udelId, totalSendQty);
      // await updateOracleQuantityPersistent(udelId, totalSendQty);
    }
  }

  Future<void> postTruck_Header_scan(String deliveryId) async {
    final IpAddress = await getActiveIpAddress();
    final url = Uri.parse("$IpAddress/insert_delivery_header/");
    final formattedDate =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now());
    final parsedDate =
        DateFormat("dd-MMM-yyyy").parse(DeliveryDateController.text);
    final formattedDeliveryDate =
        DateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(parsedDate);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final salesloginno = prefs.getString('salesloginno') ?? '';
    final saveloginname = prefs.getString('saveloginname') ?? '';
    final saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';

    final header = {
      "DISPATCH_ID": deliveryId,
      "REQ_ID": ReqNoController.text,
      "DATE": formattedDate,
      "PHYSICAL_WAREHOUSE": WarehouseController.text,
      "ORG_ID": saleslogiOrgid,
      "ORG_NAME": RegionController.text,
      "STAFF_NO": salesloginno,
      "STAFF_NAME": saveloginname,
      "CUSTOMER_NUMBER": widget.cusno,
      "CUSTOMER_NAME": widget.cusname,
      "CUSTOMER_SITE_ID": widget.cussite,
      "TRANSPORTER_NAME": VendorController.text,
      "DRIVER_NAME": DriverController.text,
      "DRIVER_MOBILENO": int.tryParse(DriverMobileNoController.text) ?? 0,
      "VEHICLE_NO": VehicleNoController.text,
      "TRUCK_DIMENSION": TruckDimentionController.text,
      "LOADING_CHARGES": int.tryParse(LoadingChargeController.text) ?? 0,
      "TRANSPORT_CHARGES": int.tryParse(TransportChargeController.text) ?? 0,
      "MISC_CHARGES": int.tryParse(MISCController.text) ?? 0,
      "DELIVERYADDRESS": deliverAddressController.text,
      "SALESMANREMARKS": salesmanRemarksController.text,
      "REMARKS": RemarksController.text,
      "CREATION_DATE": formattedDate,
      "CREATED_BY": saveloginname,
      "CREATED_IP": 'null',
      "CREATED_MAC": 'null',
      "LAST_UPDATE_DATE": formattedDate,
      "LAST_UPDATED_BY": 'null',
      "LAST_UPDATE_IP": 'null',
      "FLAG": 'A',
      "DELIVERY_DATE": formattedDeliveryDate,
    };

    final payload = {
      ...header,
      "tabledata": tableData,
    };

    print("Payload: ${jsonEncode(payload)}");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) {
      print("Success: ");
    } else {
      print("Error ${response.statusCode}: ${response.body}");
    }
  }

  Future<void> updatecreatedispatch() async {
    final IpAddress = await getActiveIpAddress();
    // print("tabledatassssss $tableData");
    for (var record in tableData) {
      final reqid = widget.reqno;
      final cusno = widget.cusno;
      final cussite = widget.cussite;

      final invoiceno = record['invoiceno'];
      final itemcode = record['itemcode'];
      final truckSendQty = record['sendqty'];

      if (reqid != null &&
          cusno != null &&
          cussite != null &&
          itemcode != null &&
          truckSendQty != null) {
        final getUrl = Uri.parse(
            '$IpAddress/GetidCreateDispatchView$parameterdivided$reqid$parameterdivided$cusno$parameterdivided$cussite$parameterdivided$invoiceno$parameterdivided$itemcode$parameterdivided');
        print(
            "geturlsss $IpAddress/GetidCreateDispatchView$parameterdivided$reqid$parameterdivided$cusno$parameterdivided$cussite$parameterdivided$invoiceno$parameterdivided$itemcode$parameterdivided");
        final headers = {"Content-Type": "application/json"};
        String url =
            '$IpAddress/update_createdispatch_qty/'; // Replace with your URL

        try {
          final getResponse = await http.get(getUrl, headers: headers);

          if (getResponse.statusCode == 200) {
            final List<dynamic> records = json.decode(getResponse.body);

            if (records.isNotEmpty) {
              final existingRecord = records[0];
              final id = existingRecord['id'];
              final int existingQty = existingRecord['truck_scan_qty'] ??
                  0; // Current quantity from DB
              print("get id and existingqty $id   $existingQty");
              final int newQty = truckSendQty is int
                  ? truckSendQty
                  : int.tryParse(truckSendQty.toString()) ?? 0;

              if (id != null) {
                // Calculate the updated quantity (subtract the sent quantity)
                final updatedQty = newQty;
                print('updatedQtyyyy $updatedQty');

                try {
                  final response = await http.post(
                    Uri.parse(url),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'id': id,
                      'qty': updatedQty, // Send updated quantity
                    }),
                  );

                  if (response.statusCode == 200) {
                    final responseData = jsonDecode(response.body);
                    if (responseData['status'] == 'success') {
                      print(
                          'Quantity updated successfully for item: $itemcode');
                    } else {
                      print('Error: ${responseData['message']}');
                    }
                  } else {
                    print('Server Error: ${response.statusCode}');
                  }
                } catch (e) {
                  print('Error sending request: $e');
                }
              } else {
                print('❌ ID not found in the fetched record.');
              }
            } else {
              print(
                  '❌ No existing record found to update for ITEM_CODE: $itemcode');
            }
          } else {
            print(
                '❌ Failed to fetch record. Status: ${getResponse.statusCode}');
          }
        } catch (e) {
          print('❌ Exception occurred: $e');
        }
      } else {
        print('❌ Invalid data for REQ_ID: $reqid, ITEM_CODE: $itemcode');
      }
    }

    print("✅ Update process completed for all items.");
  }

  // Future<void> updatecreatedispatch() async {
  //   print("table data for updating qty: $tableData");
  //   final IpAddress = await getActiveIpAddress();

  //   for (var record in tableData) {
  //     final reqid = widget.reqno;
  //     final cusno = widget.cusno;
  //     final cussite = widget.cussite;
  //     final itemcode = record['itemcode'];
  //     final truckSendQty = record['sendqty'];

  //     if (reqid != null &&
  //         cusno != null &&
  //         cussite != null &&
  //         itemcode != null &&
  //         truckSendQty != null) {
  //       final getUrl = Uri.parse(
  //           '$IpAddress/GetidCreateDispatchView/$reqid/$cusno/$cussite/$itemcode/');
  //       final headers = {"Content-Type": "application/json"};

  //       print(
  //           "Fetching record for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno, CUSTOMER_SITE_ID: $cussite, ITEM_CODE: $itemcode from $getUrl");

  //       try {
  //         final getResponse = await http.get(getUrl, headers: headers);

  //         if (getResponse.statusCode == 200) {
  //           final List<dynamic> records = json.decode(getResponse.body);

  //           if (records.isNotEmpty) {
  //             final existingRecord = records[0];
  //             final id = existingRecord['id'];
  //             final existingTruckScanQty =
  //                 existingRecord['TRUCK_SCAN_QTY'] ?? 0;

  //             if (id != null) {
  //               // Parse both to int/double (depending on your backend model)
  //               final int existingQty = existingTruckScanQty is int
  //                   ? existingTruckScanQty
  //                   : int.tryParse(existingTruckScanQty.toString()) ?? 0;

  //               final int newQty = truckSendQty is int
  //                   ? truckSendQty
  //                   : int.tryParse(truckSendQty.toString()) ?? 0;

  //               final int updatedQty = existingQty - newQty;

  //               final updateUrl = Uri.parse('$IpAddress/Create_Dispatch/$id/');
  //               final updateBody = json.encode({
  //                 "TRUCK_SCAN_QTY": updatedQty,
  //               });

  //               final putResponse = await http.put(
  //                 updateUrl,
  //                 headers: headers,
  //                 body: updateBody,
  //               );

  //               if (putResponse.statusCode == 200) {
  //                 print(
  //                     'Updated TRUCK_SCAN_QTY to $updatedQty for ID: $id (Existing: $existingQty + New: $newQty)');
  //               } else {
  //                 print(
  //                     'Failed to update TRUCK_SCAN_QTY for ID: $id. Status code: ${putResponse.statusCode}');
  //               }
  //             } else {
  //               print(
  //                   'ID not found in record for REQ_ID: $reqid, ITEM_CODE: $itemcode');
  //             }
  //           } else {
  //             print(
  //                 'No record found for REQ_ID: $reqid, CUSTOMER_NUMBER: $cusno, CUSTOMER_SITE_ID: $cussite, ITEM_CODE: $itemcode');
  //           }
  //         } else {
  //           print(
  //               'Failed to fetch record. Status: ${getResponse.statusCode}, URL: $getUrl');
  //         }
  //       } catch (e) {
  //         print('Error occurred: $e');
  //       }
  //     } else {
  //       print('Invalid data: REQ_ID: $reqid, ITEM_CODE: $itemcode');
  //     }
  //   }
  // }

  Future<void> updateQuantity(int UndelId, int qty) async {
    final IpAddress = await getActiveIpAddress();

    String url = '$IpAddress/update-qty/$UndelId/$qty/';

    print('Calling updateQuantity for UndelId: $UndelId, qty: $qty');
    print('Request URL: $url');

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print("✅ QTY updated successfully for UndelId $UndelId");
      } else {
        print("❌ Error in Update qty: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Exception: $e");
    }
  }

  // Future<void> updateOracleQuantity(int UndelId, int qty) async {
  //   final TestingOracleIpAddress = await getActiveOracleIpAddress();
  //   print('new:$TestingOracleIpAddress');
  //   String url = '$TestingOracleIpAddress/update-qty/$UndelId/$qty/';

  //   print('Calling updateOracleQuantity for UndelId: $UndelId, qty: $qty');
  //   print('Request URL OracleTable : $url');

  //   try {
  //     final response = await http.put(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     print('Response Status Code Oracle: ${response.statusCode}');
  //     print('Response Body Oracle: ${response.body}');

  //     if (response.statusCode == 200) {
  //       print("✅ QTY updatedOracle successfully for UndelId $UndelId");
  //     } else {
  //       print("❌ Error in UpdateOracle qty: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("⚠️ Exception Oracle: $e");
  //   }
  // }

  final httpClient = http.Client();

  // Future<void> updateOracleQuantityPersistent(int undelId, int qty) async {
  //   final oracleIp = await getActiveOracleIpAddress();
  //   final url = '$oracleIp/update-qty/$undelId/$qty/';

  //   print("ORACLE urllllll $url");
  //   try {
  //     final oracleIp = await getActiveOracleIpAddress();
  //     final url = '$oracleIp/update-qty/$undelId/$qty/';

  //     print("urllllll $url");
  //     final uri = Uri.parse(url);

  //     final response = await httpClient.put(
  //       uri,
  //       headers: {'Content-Type': 'application/json'},
  //     ).timeout(const Duration(seconds: 20));

  //     if (response.statusCode == 200) {
  //       print("✅ Persistent QTY update successful for $undelId");
  //     } else {
  //       print(
  //           "❌ Persistent update failed: ${response.statusCode} - ${response.body}");
  //     }
  //   } catch (e) {
  //     print("⚠️ Persistent Client Error: $e");
  //   }
  // }

  Future<void> updateOracleQuantityPersistent(int undelId, int qty) async {
    final oracleIp = await getActiveOracleIpAddress();
    final baseUrl = oracleIp!.replaceAll(RegExp(r"/$"), "");
    final url = '$baseUrl/update-qty/$undelId/$qty/';
    print("📡 before try Requesting URL: $url");
    try {
      final oracleIp = await getActiveOracleIpAddress();

      final baseUrl = oracleIp?.replaceAll(RegExp(r"/$"), "");

      final url = '$baseUrl/update-qty/$undelId/$qty/';
      print("📡 Requesting URL: $url");

      final uri = Uri.parse(url);

      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15)); // Increased timeout for testing

      print("📦 Response Code: ${response.statusCode}");
      print("📨 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ Persistent QTY update successful for $undelId");
      } else {
        print(
            "❌ Persistent update failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("⚠️ Persistent Client Error: $e");
    }
  }

  Future<void> postTransactionDetails() async {
    final ipAddress = await getActiveIpAddress();
    final url = '$ipAddress/add_transaction_detail/';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Unique_deliver_id = prefs.getString('Unique_deliver_id');
    String? saveloginname = prefs.getString('saveloginname') ?? '';

    DateTime now = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

    try {
      // Aggregate tableData by itemCode
      Map<String, Map<String, dynamic>> aggregatedData = {};

      for (var row in tableData) {
        var itemCode = row['itemcode']?.toString() ?? 'UNKNOWN';
        var sendQty = int.tryParse(row['sendqty']?.toString() ?? '0') ?? 0;

        if (!aggregatedData.containsKey(itemCode)) {
          aggregatedData[itemCode] = {
            "UNDEL_ID": int.tryParse(row['Udel_id']?.toString() ?? '0') ?? 0,
            "CUSTOMER_TRX_ID":
                int.tryParse(row['Customer_trx_id']?.toString() ?? '0') ?? 0,
            "CUSTOMER_TRX_LINE_ID":
                int.tryParse(row['Customer_trx_line_id']?.toString() ?? '0') ??
                    0,
            "ITEM_ID": itemCode,
            "LINE_NO": int.tryParse(row['line_no']?.toString() ?? '0') ?? 0,
            "QTY": sendQty,
          };
        } else {
          aggregatedData[itemCode]!["QTY"] += sendQty;
        }
      }

      for (var entry in aggregatedData.entries) {
        var itemCode = entry.key;
        var data = entry.value;

        var summedQty = data["QTY"] ?? 0;
        var finalSummedQty = -summedQty; // Send as int, not string

        Map<String, dynamic> createDispatchData = {
          "UNDEL_ID":
              data["UNDEL_ID"], // Use valid int if needed or remove if optional
          "TRANSACTION_DATE": formattedDate,
          "CUSTOMER_TRX_ID": data["CUSTOMER_TRX_ID"],
          "CUSTOMER_TRX_LINE_ID": data["CUSTOMER_TRX_LINE_ID"],
          "ITEM_ID": itemCode,
          "LINE_NO": data["LINE_NO"],
          "QTY": finalSummedQty,
          "SOURCE": "Truck Delivery dispatch",
          "TRANSACTION_TYPE": "OUTBOUND",
          "DISPATCH_ID": Unique_deliver_id,
          "REFERENCE1": "",
          "REFERENCE2": "",
          "REFERENCE3": "",
          "REFERENCE4": "",
          "CREATED_BY": saveloginname.isNotEmpty ? saveloginname : 'Unknown',
          "CREATED_IP": "",
          "CREATED_MAC": "",
          "LAST_UPDATED_BY":
              saveloginname.isNotEmpty ? saveloginname : 'Unknown',
          "LAST_UPDATE_IP": "",
          "LAST_UPDATE_MAC": "",
          "CREATION_DATE": formattedDate,
          "LAST_UPDATE_DATE": formattedDate,
          "FLAG": "A"
        };

        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(createDispatchData),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('✅ Posted successfully: $itemCode → $finalSummedQty');
        } else {
          print('❌ Failed for $itemCode: ${response.statusCode}');
          print(response.body);
        }
      }
    } catch (e) {
      print('❗ Error posting transaction: $e');
    }
  }

  // Future<void> postTransactionDetails() async {
  //   final IpAddress = await getActiveIpAddress();

  //   final url = '$IpAddress/TransactionDetail/';

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? saveloginname = prefs.getString('saveloginname') ?? '';

  //   DateTime now = DateTime.now();
  //   String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

  //   try {
  //     String reqno = ReqNoController.text.toString();
  //     // String disreqno = Dispatch_idController.text.isNotEmpty
  //     //     ? Dispatch_idController.text
  //     //     : '';
  //     // String disReqNoValue =
  //     //     disreqno.split('_').last; // Get the value after the last underscore

  //     // Aggregate tableData by itemCode
  //     Map<String, Map<String, dynamic>> aggregatedData = {};

  //     for (var row in tableData) {
  //       var itemCode = row['itemcode']?.toString() ?? '0';
  //       var sendQty = int.tryParse(row['sendqty']?.toString() ?? '0') ?? 0;

  //       if (!aggregatedData.containsKey(itemCode)) {
  //         aggregatedData[itemCode] = {
  //           "CUSTOMER_TRX_ID":
  //               double.tryParse(row['Customer_trx_id']?.toString() ?? '0') ??
  //                   0.0,
  //           "CUSTOMER_TRX_LINE_ID": double.tryParse(
  //                   row['Customer_trx_line_id']?.toString() ?? '0') ??
  //               0.0,
  //           "ITEM_ID":
  //               double.tryParse(row['itemcode']?.toString() ?? '0') ?? 0.0,
  //           "LINE_NO":
  //               double.tryParse(row['line_no']?.toString() ?? '0') ?? 0.0,
  //           "QTY": sendQty,
  //         };
  //       } else {
  //         aggregatedData[itemCode]!["QTY"] += sendQty;
  //       }
  //     }

  //     // Create and send POST requests for each unique itemCode
  //     for (var entry in aggregatedData.entries) {
  //       var itemCode = entry.key;
  //       var data = entry.value;

  //       var summedQty = data["QTY"] ?? 0;
  //       var finalSummedQty = (-summedQty).toStringAsFixed(0);

  //       print("final qty of the tablde item code $finalSummedQty");

  //       Map<String, dynamic> createDispatchData = {
  //         "TRANSACTION_DATE": formattedDate,
  //         "CUSTOMER_TRX_ID": data["CUSTOMER_TRX_ID"],
  //         "CUSTOMER_TRX_LINE_ID": data["CUSTOMER_TRX_LINE_ID"],
  //         "ITEM_ID": itemCode,
  //         "LINE_NO": data["LINE_NO"],
  //         "QTY": finalSummedQty,
  //         "SOURCE": 'Truck Delivery dispatch',
  //         "TRANSACTION_TYPE": 'OUTBOUND',
  //         "DISPATCH_ID": deliveryId,
  //         "CREATION_DATE": formattedDate,
  //         "CREATED_BY": saveloginname.isNotEmpty ? saveloginname : 'Unknown',
  //         "LAST_UPDATE_DATE": formattedDate,
  //         "FLAG": 'N'
  //       };

  //       final response = await http.post(
  //         Uri.parse(url),
  //         headers: {
  //           'Content-Type': 'application/json',
  //         },
  //         body: jsonEncode(createDispatchData),
  //       );

  //       if (response.statusCode == 201) {
  //         print(
  //             'Dispatch created successfully for Item Code: $itemCode with Quantity: $finalSummedQty');
  //       } else {
  //         print(
  //             'Failed to create dispatch for Item Code: $itemCode. Status code: ${response.statusCode}');
  //         // print('Response body: ${response.body}');
  //       }
  //     }
  //   } catch (e) {
  //     print('Error occurred while posting dispatch data: $e');
  //   }
  // }

  List<Map<String, dynamic>> DeletetableData = [];

  Future<void> DeleteDispatchData() async {
    // Get the dispatch ID if it's not empty
    // String disreqno =
    //     Dispatch_idController.text.isNotEmpty ? Dispatch_idController.text : '';
    // String disReqNoValue =
    //     disreqno.split('_').last; // Extract value after last underscore

    // Construct the URL with the required parameters

    final IpAddress = await getActiveIpAddress();

    final String url =
        '$IpAddress/filteredToGetGenerateDispatchView/${widget.reqno}/${widget.cusno}/${widget.cussite}/';
    print("ToGetGenerateDispatchView  scan truck man: $url");

    try {
      // Perform the HTTP GET request
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Decode the response body
        final List<dynamic> responseData = json.decode(response.body);

        // Check if the response data is a list
        if (responseData is List) {
          // ✅ Filter based on pick_id and SCAN_STATUS
          final filteredList = responseData.where((item) =>
              item['pick_id'].toString() == widget.pickno &&
              item['SCAN_STATUS']?.toString() == "Request for Delivery");
          setState(() {
            DeletetableData = filteredList.map((item) {
              return {
                'id': item['id'],
                'dispatch_id': item['dispatch_id'],
                'req_no': item['req_no'],
                'pick_id': item['pick_id'],
                'invoice_no': item['invoice_no'],
                'Customer_no': item['Customer_no'],
                'Customer_name': item['Customer_name'],
                'Customer_Site': item['Customer_Site'],
                'Item_code': item['Item_code'],
                'Item_detailas': item['Item_detailas'],
                'DisReq_Qty': item['DisReq_Qty'],
                'Send_qty': item['Send_qty'],
                'Product_code': item['Product_code'],
                'Serial_No': item['Serial_No'],
              };
            }).toList();
          });

          print("DeletetableData table data: $DeletetableData");

          // Loop through each item and delete the data based on 'id'
          for (var item in DeletetableData) {
            await deleteData(item['id']);
          }
        } else {
          print("Error: Expected a list, but the response is not a list.");
        }
      } else {
        throw Exception('Failed to load dispatch data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> insertDispatchData(
      String dispatchId, int undelId, int qty) async {
    final IpAddress = await getActiveIpAddress();

    final String url = '$IpAddress/insert_dispatch/$dispatchId/$undelId/$qty/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Data inserted successfully: ${response.body}');
      } else {
        print('Failed to insert data. Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> deleteData(int id) async {
    final IpAddress = await getActiveIpAddress();

    print("Id for delted  $id");
    final url = Uri.parse('$IpAddress/ToGetGenerateDispatchView/$id/');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 204) {
        print('Item deleted successfully.');
      } else {
        print('Failed to delete item. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  // _launchUrldetailed(
  //   BuildContext context,
  //   String dispatchNo,
  // ) async {
  //   await fetchPickmanData(dispatchNo);
  //   if (viewtableData.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('No data available to send.')),
  //     );
  //     return;
  //   }

  //   final item = viewtableData.first;

  //   String formattedDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());
  //   String? baseUrl =
  //       await getActiveOracleIpAddress(); // Example: http://192.168.0.10:8000

  //   // print("viewtableDataaaa $viewtableData");
  //   // Encode product list
  //   String productsParam = viewtableData.map((data) {
  //     return '{${viewtableData.indexOf(data) + 1}|${data['INVOICE_NO']}|${data['ITEM_CODE']}|${data['ITEM_DETAILS']}|${data['PRODUCT_CODE']}|${data['SERIAL_NO']}}';
  //   }).join('');

  //   // print("productsParam $productsParam");

  //   String url = Uri.parse('$baseUrl/Generate_dispatch_details_print/').replace(
  //     queryParameters: {
  //       "deliveryno": dispatchNo,
  //       "region": item['PHYSICAL_WAREHOUSE'] ?? '',
  //       "transportor_Name": item['TRANSPORTER_NAME'] ?? '',
  //       "pickid": item['PICK_ID'] ?? '',
  //       "pickmanname": item['PICKMAN_NAME'] ?? '',
  //       "vehicleNo": item['VEHICLE_NO'] ?? '',
  //       "driverName": item['DRIVER_NAME'] ?? '',
  //       "driverMobileNo": item['DRIVER_MOBILENO'] ?? '',
  //       "date": formatDate(item['DATE']),
  //       "customerNo": item['CUSTOMER_NUMBER'] ?? '',
  //       "customername": item['CUSTOMER_NAME'] ?? '',
  //       "customersite": item['CUSTOMER_SITE_ID'] ?? '',
  //       "deliveryaddress": item['DELIVERYADDRESS'] ?? '',
  //       "remmarks": item['REMARKS'] ?? '',
  //       'salesmanremmarks': item['SALESMANREMARKS'] ?? '',
  //       "itemtotalqty": viewtableData
  //           .fold(
  //               0,
  //               (sum, item) =>
  //                   sum +
  //                   (int.tryParse(item['TRUCK_SEND_QTY']?.toString() ?? '0') ??
  //                       0))
  //           .toString(),
  //       "products_param": productsParam,
  //     },
  //   ).toString();

  //   if (await canLaunch(url)) {
  //     await launch(url); // this opens in new window on web
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Could not launch URL')),
  //     );
  //   }
  // }

  _launchUrldetailed(
    BuildContext context,
  ) async {
    if (tableData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No data available to send.')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? Unique_deliver_id = prefs.getString('Unique_deliver_id');
    final item = tableData.first;

    String formattedDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    String? baseUrl =
        await getActiveOracleIpAddress(); // Example: http://192.168.0.10:8000

    // Encode product list
    String productsParam = tableData.map((data) {
      return '{${tableData.indexOf(data) + 1}|${data['invoiceno']}|${data['itemcode']}|${data['itemdetails']}|${data['Product_code']}|${data['Serial_No']}}';
    }).join('');

    String url = Uri.parse('$baseUrl/Generate_dispatch_details_print/').replace(
      queryParameters: {
        'deliveryno': Unique_deliver_id,
        'region':
            WarehouseController.text.isNotEmpty ? WarehouseController.text : '',
        'transportor_Name':
            VendorController.text.isNotEmpty ? VendorController.text : 'null',
        'pickid': PickidContrller.text.isNotEmpty ? PickidContrller.text : '',
        'pickmanname': PickManNameAController.text.isNotEmpty
            ? PickManNameAController.text
            : 'null',
        'vehicleNo': VehicleNoController.text.isNotEmpty
            ? VehicleNoController.text
            : 'null',
        'driverName':
            DriverController.text.isNotEmpty ? DriverController.text : 'null',
        'driverMobileNo': DriverMobileNoController.text.isNotEmpty
            ? DriverMobileNoController.text
            : 'null',
        'date': formattedDate,
        'customerNo': widget.cusno,
        'customername': widget.cusname,
        'customersite': widget.cussite,
        'deliveryaddress': deliverAddressController.text.isNotEmpty
            ? deliverAddressController.text
            : 'null',
        'remmarks':
            RemarksController.text.isNotEmpty ? RemarksController.text : 'null',
        'salesmanremmarks': salesmanRemarksController.text.isNotEmpty
            ? salesmanRemarksController.text
            : 'null',
        'itemtotalqty': totalSendqtyController.text.isNotEmpty
            ? totalSendqtyController.text
            : 'null',
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

  List<Map<String, dynamic>> viewtableData = [];

  Future<void> fetchPickmanData(String dispatchno) async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/filtedshippingproductdetails/$dispatchno/';
    print("Fetching data from URL: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // print('Response body: ${response.body}');

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

  // _launchUrl(
  //   BuildContext context,
  //   String dispatchNo,
  // ) async {
  //   await fetchPickmanData(dispatchNo);
  //   List<String> productDetails = [];
  //   int snoCounter = 1;
  //   if (viewtableData.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('No data available to send.')),
  //     );
  //     return;
  //   }

  //   final item = viewtableData.first;

  //   String formattedDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());
  //   List<Map<String, dynamic>> mergeTableData(
  //       List<Map<String, dynamic>> viewtableData) {
  //     Map<String, Map<String, dynamic>> mergedData = {};

  //     for (var item in viewtableData) {
  //       String key =
  //           '${item['INVOICE_NO']}-${item['ITEM_CODE']}-${item['ITEM_DETAILS']}';
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
  //           'sendqty': currentQty,
  //         };
  //       }
  //     }

  //     return mergedData.values.toList();
  //   }

  //   // Preprocess the table data before rendering
  //   List<Map<String, dynamic>> mergedData = mergeTableData(viewtableData);

  //   for (var data in mergedData) {
  //     String formattedProduct =
  //         "{${data['sno']}|${data['invoiceno']}|${data['itemcode']}|${data['itemdetails']}|${data['sendqty']}}";
  //     productDetails.add(formattedProduct);
  //   }

  //   String productDetailsString = productDetails.join('');

  //   // print("productDetailsString  $productDetailsString");

  //   final ipAddress = await getActiveOracleIpAddress();

  //   String url = Uri.parse('$ipAddress/Generate_dispatch_print/').replace(
  //     queryParameters: {
  //       "deliveryno": dispatchNo,
  //       "region": item['PHYSICAL_WAREHOUSE'] ?? '',
  //       "transportor_Name": item['TRANSPORTER_NAME'] ?? '',
  //       "pickid": item['PICK_ID'] ?? '',
  //       "pickmanname": item['PICKMAN_NAME'] ?? '',
  //       "vehicleNo": item['VEHICLE_NO'] ?? '',
  //       "driverName": item['DRIVER_NAME'] ?? '',
  //       "driverMobileNo": item['DRIVER_MOBILENO'] ?? '',
  //       "date": formatDate(item['DATE']),
  //       "customerNo": item['CUSTOMER_NUMBER'] ?? '',
  //       "customername": item['CUSTOMER_NAME'] ?? '',
  //       "customersite": item['CUSTOMER_SITE_ID'] ?? '',
  //       "deliveryaddress": item['DELIVERYADDRESS'] ?? '',
  //       "remmarks": item['REMARKS'] ?? '',
  //       'salesmanremmarks': item['SALESMANREMARKS'] ?? '',
  //       "itemtotalqty": viewtableData
  //           .fold(
  //               0,
  //               (sum, item) =>
  //                   sum +
  //                   (int.tryParse(item['TRUCK_SEND_QTY']?.toString() ?? '0') ??
  //                       0))
  //           .toString(),
  //       "products_param": productDetailsString,
  //     },
  //   ).toString();

  //   if (await canLaunch(url)) {
  //     await launch(url); // this opens in new window on web
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Could not launch URL')),
  //     );
  //   }
  // }

  _launchUrl(
    BuildContext context,
  ) async {
    List<String> productDetails = [];
    int snoCounter = 1; // Initialize the sequence number counter
    print("tableDataaaaaaaaaaaaaaaa $tableData");
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
            'sno': snoCounter++,
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? Unique_deliver_id = prefs.getString('Unique_deliver_id');

// Preprocess the table data before rendering
    List<Map<String, dynamic>> mergedData = mergeTableData(tableData);

    for (var data in mergedData) {
// Access each product's details and format as "productName-qtyX-action"
      String formattedProduct =
          "{${data['sno']}|${data['invoiceno']}|${data['itemcode']}|${data['itemdetails']}|${data['sendqty']}}";
      productDetails.add(formattedProduct);
    }
    String formattedDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());

    String? baseUrl =
        await getActiveOracleIpAddress(); // Example: http://192.168.0.10:8000

// Join product details into a single string
    String productDetailsString = productDetails.join('');
    print("productDetailsStringaaaa $productDetailsString");
    DateTime today = DateTime.now();
    String url = Uri.parse('$baseUrl/Generate_dispatch_print/').replace(
      queryParameters: {
        'deliveryno': Unique_deliver_id,
        'region':
            WarehouseController.text.isNotEmpty ? WarehouseController.text : '',
        'transportor_Name':
            VendorController.text.isNotEmpty ? VendorController.text : 'null',
        'pickid': PickidContrller.text.isNotEmpty ? PickidContrller.text : '',
        'pickmanname': PickManNameAController.text.isNotEmpty
            ? PickManNameAController.text
            : 'null',
        'vehicleNo': VehicleNoController.text.isNotEmpty
            ? VehicleNoController.text
            : 'null',
        'driverName':
            DriverController.text.isNotEmpty ? DriverController.text : 'null',
        'driverMobileNo': DriverMobileNoController.text.isNotEmpty
            ? DriverMobileNoController.text
            : 'null',
        'date': formattedDate,
        'customerNo': widget.cusno,
        'customername': widget.cusname,
        'customersite': widget.cussite,
        'deliveryaddress': deliverAddressController.text.isNotEmpty
            ? deliverAddressController.text
            : 'null',
        'remmarks':
            RemarksController.text.isNotEmpty ? RemarksController.text : 'null',
        'salesmanremmarks': salesmanRemarksController.text.isNotEmpty
            ? salesmanRemarksController.text
            : 'null',
        'itemtotalqty': totalSendqtyController.text.isNotEmpty
            ? totalSendqtyController.text
            : 'null',
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

  successfullyLoginMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Confirm this Dispatch ?',
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Closes the dialog
                  },
                  child: Text("No"),
                ),
                SizedBox(
                  width: 8,
                ),
                TextButton(
                  // onPressed: () async {
                  //   await postTruck_scan();
                  //   await Navigator.pushReplacement(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => MainSidebar(
                  //           enabledItems: accessControl, initialPageIndex: 4),
                  //     ),
                  //   );
                  // },

                  onPressed: () async {
                    // Show the dialog while processing
                    showDialog(
                      context: context,
                      barrierDismissible:
                          false, // Prevent dismissing the dialog manually
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

                    try {
                      // await fetchTokenwithCusid();

                      // Perform the save operation
                      await postTruck_scan();

                      // await postTransactionDetails();

                      Navigator.pop(context);
                      // Call the togglePage function
                      await widget.togglePage();
                      await SharedPrefs.cleartockandreqno();

                      // If everything succeeds, close the dialog
                      if (context.mounted) {
                        Navigator.pop(context); // Close the dialog
                      }
                    } catch (error) {
                      // Handle errors appropriately
                      print("Error occurred: $error");

                      // Optionally show an error message to the user
                      if (context.mounted) {
                        Navigator.pop(
                            context); // Close the dialog before showing an error message
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Error"),
                              content: Text("An error occurred: $error"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context); // Close the error dialog
                                  },
                                  child: Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    } finally {
                      // Ensure the dialog is closed even if there’s an error
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },

                  child: Text("Yes"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class PrintPreviewContainer extends StatelessWidget {
  final List<Map<String, dynamic>> tableData;

  PrintPreviewContainer({required this.tableData});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: IntrinsicHeight(
        // Ensures the height matches PrintPreviewTable's height
        child: PrintPreviewTable(tableData: tableData),
      ),
    );
  }
}

class PrintPreviewTable extends StatelessWidget {
  final List<Map<String, dynamic>> tableData;

  PrintPreviewTable({required this.tableData});

  @override
  Widget build(BuildContext context) {
    final filteredTableData = tableData.where((data) {
      var sendQty = data['sendqty'];
      return sendQty != null &&
          sendQty != 0 &&
          sendQty.toString().trim().isNotEmpty;
    }).toList();

    List<Map<String, dynamic>> mergeTableData(
        List<Map<String, dynamic>> filteredTableData) {
      Map<String, Map<String, dynamic>> mergedData = {};

      for (var item in filteredTableData) {
        String key =
            '${item['invoiceno']}-${item['itemcode']}-${item['itemdetails']}';
        if (mergedData.containsKey(key)) {
          // If already exists, add the sendqty
          mergedData[key]!['sendqty'] +=
              int.tryParse(item['sendqty']?.toString() ?? '0') ?? 0;
        } else {
          // Add a new entry
          mergedData[key] = {
            'sno': item['sno'],
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
    List<Map<String, dynamic>> mergedData = mergeTableData(filteredTableData);

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
                _buildTableHeader("S.No", 50),
                _buildTableHeader("Inv.No", 100),
                _buildTableHeader("I.Code", 100),
                _buildTableHeader(
                    "I.Details", MediaQuery.of(context).size.width * 0.12),
                _buildTableHeader("Qty", 100),
              ],
            ),
          ),
          // Scrollable Table Body
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical, // Enable vertical scrolling
              child: Column(
                children: mergedData.map((data) {
                  String lineno = data['sno'].toString();
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
                            MediaQuery.of(context).size.width * 0.12),
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13), // Prevent overflow
        ),
      ),
    );
  }
}
