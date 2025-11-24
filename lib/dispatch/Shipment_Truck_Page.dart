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

class Shipment_Truck_page extends StatefulWidget {
  final Function togglePage;

  final String shipmentid;

  Shipment_Truck_page(
    this.togglePage,
    this.shipmentid,
  );

  @override
  State<Shipment_Truck_page> createState() => _Shipment_Truck_pageState();
}

class _Shipment_Truck_pageState extends State<Shipment_Truck_page> {
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
                          _fieldFocusChange(
                              context, fromfocusnode, tofocusnode);
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
                            color: Color.fromARGB(255, 73, 72, 72),
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> filteredData = [];

  TextEditingController ShipmentnumberController = TextEditingController();

  TextEditingController OnlyshipmentidrController = TextEditingController();

  TextEditingController ShipmentIdController = TextEditingController();
  TextEditingController TransporterController = TextEditingController();
  TextEditingController DriverMobileNoController = TextEditingController();
  TextEditingController DriverController = TextEditingController();
  TextEditingController VehicleNoController = TextEditingController();
  TextEditingController TruckDimentionController = TextEditingController();
  TextEditingController LoadingChargeController = TextEditingController();
  TextEditingController TransportChargeController = TextEditingController();
  TextEditingController MISCController = TextEditingController();

  TextEditingController RemarkCOntroller = TextEditingController();
  TextEditingController deliverAddressController = TextEditingController();

  TextEditingController NoOfItemsController = TextEditingController();
  TextEditingController TotalProgressQtyController = TextEditingController();

  TextEditingController FromOrgCodeController = TextEditingController();
  TextEditingController FromOrgNameController = TextEditingController();

  TextEditingController ToOrgCodeController = TextEditingController();
  TextEditingController ToOrgNameController = TextEditingController();

  FocusNode shipmentidfocusnode = FocusNode();

  FocusNode shipmentnumfocusnode = FocusNode();
  FocusNode receiptnumfocusnode = FocusNode();

  FocusNode transportorfocusnode = FocusNode();

  FocusNode driverfocusnode = FocusNode();
  FocusNode drivermobilenofocusnode = FocusNode();
  FocusNode Vehiclenofocusnode = FocusNode();
  FocusNode truckdimfocusnode = FocusNode();
  FocusNode loadingchargefocusnode = FocusNode();
  FocusNode transportchargefocusnode = FocusNode();
  FocusNode miscchargefocusnode = FocusNode();
  FocusNode DeliveryaAddressfocusnode = FocusNode();
  FocusNode savebuttonfocusnode = FocusNode();

  bool _isLoadingData = false;

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

// Add these at your widget's state level
  late List<TextEditingController> _progressControllers;
  late List<TextEditingController> _receivedControllers;
  late List<FocusNode> _progressFocusNodes;

  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _progressControllers = [];
    _receivedControllers = [];
    _progressFocusNodes = [];
    // FetchLastShipmentNo();
    fetchAccessControl();
    _loadSalesmanName();

    print('shipment id ${ShipmentnumberController.text}');

    filteredData = List.from(tableData);

    postLogData("Inter ORG Trucking", "Opened");
  }

  Future<void> FetchLastShipmentNo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno');

    final IpAddress = await getActiveIpAddress();
    final url = '$IpAddress/Shipment_dispatchNo/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String shipmentid = data['Shipment_Id']?.toString() ?? '';
        String token = data['TOCKEN']?.toString() ?? 'No Token found';

        setState(() {
          // Update UI if needed
        });

        print('dispatch idd: $shipmentid  token: $token');

        await saveToSharedPreferences(shipmentid, token);
      } else {
        // Handle non-200 response
        ShipmentIdController.text = "INO_ERR";
      }
    } catch (e) {
      // Handle any exception
      ShipmentIdController.text = "INO_EXC";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    postLogData("General Dispatch", "Closed");
    _progressControllers.forEach((c) => c.dispose());
    _receivedControllers.forEach((c) => c.dispose());
    _progressFocusNodes.forEach((f) => f.dispose());
    super.dispose();
  }

  bool isLoading = true;

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

  Future<void> loadTableData(
      String SaveTransfertype, String shipmentHeaderId) async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final List<Map<String, dynamic>> data =
          await fetchTableData(SaveTransfertype, shipmentHeaderId);

      loadTabledhipmentData(SaveTransfertype, shipmentHeaderId);
      setState(() {
        tableData = data;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      // Handle error
      print('Error loading data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTableData(
      String SaveTransfertype, String shipmentHeaderId) async {
    final IpAddress = await getActiveIpAddress();

    final response = await http.get(
      Uri.parse(
          '$IpAddress/GET_Shipment_Interorg/$SaveTransfertype/$shipmentHeaderId/'),
    );
    print(
        "urlll get $IpAddress/GET_Shipment_Interorg/$SaveTransfertype/$shipmentHeaderId/");
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      // Explicitly cast each item to Map<String, dynamic> and add fields
      return data.map<Map<String, dynamic>>((dynamic item) {
        Map<String, dynamic> typedItem = Map<String, dynamic>.from(item);
        return {
          ...typedItem,
          'progressQty': 0, // Initialize progress quantity
          'sno': data.indexOf(item) + 1, // Add serial number
        };
      }).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  final TextEditingController shipmentNumberController =
      TextEditingController();
  final TextEditingController TowarehouseNameController =
      TextEditingController();
  final TextEditingController receiptNumController = TextEditingController();

  Future<void> loadTabledhipmentData(
      String saveTransfertype, String shipmentHeaderId) async {
    try {
      final data = await fetchTableData(saveTransfertype, shipmentHeaderId);

      if (data.isNotEmpty) {
        // Since all rows have the same SHIPMENT_NUM and RECEIPT_NUM,
        // assign controllers from the first row
        TowarehouseNameController.text = data[0]['ATTRIBUTE6'] ?? '';
        shipmentNumberController.text = data[0]['SHIPMENT_NUM'] ?? '';
        receiptNumController.text = data[0]['RECEIPT_NUM'] ?? '';
      }

      setState(() {
        tableData = data;
      });
    } catch (e) {
      print('Error loading shipment data: $e');
      // Handle error (show snackbar, etc.)
    }
  }

// Add this to your widget's state
  List<Map<String, dynamic>> enteredProgressValues = [];
  Set<String> fromOrgCodes = {}; // To track unique organization codes
  Set<String> fromOrg1Name = {}; // To track unique organization codes
  Set<String> ToOrgCodes = {}; // To track unique organization codes
  Set<String> ToOrgNames = {}; // To track unique organization codes

// Add this method to collect progress values
  _collectProgressValues() {
    enteredProgressValues = [];
    for (int i = 0; i < tableData.length; i++) {
      if (i < _progressControllers.length) {
        String fromOrgCode = tableData[i]['FROM_ORGN_CODE']?.toString() ?? '';
        fromOrgCodes.add(fromOrgCode);
        String fromOrgname = tableData[i]['FROM_ORGN_NAME']?.toString() ?? '';
        fromOrg1Name.add(fromOrgname);
        String ToOrgCode = tableData[i]['TO_ORGN_CODE']?.toString() ?? '';
        ToOrgCodes.add(ToOrgCode);
        String ToOrgName = tableData[i]['TO_ORGN_NAME']?.toString() ?? '';
        ToOrgNames.add(ToOrgName);
        final progressText = _progressControllers[i].text;
        final progress = int.tryParse(progressText) ?? 0;
        if (progress > 0) {
          // Only include items with progress entered
          enteredProgressValues.add({
            // 'itemId': tableData[i]['ITEM_ID']?.toString() ?? '',
            // 'description': tableData[i]['DESCRIPTION']?.toString() ?? '',
            // 'qty_shiped': tableData[i]['QUANTITY_SHIPPED']?.toString() ?? '',
            // 'qty_recevied': tableData[i]['QUANTITY_RECEIVED']?.toString() ?? '',
            'shipment_header_id':
                tableData[i]['SHIPMENT_HEADER_ID']?.toString() ?? '',
            'shipment_line_id':
                tableData[i]['SHIPMENT_LINE_ID']?.toString() ?? '',
            'line_num': tableData[i]['LINE_NUM']?.toString() ?? '',
            'creation_date': tableData[i]['CREATION_DATE']?.toString() ?? '',
            'created_by': tableData[i]['CREATED_BY']?.toString() ?? '',
            'from_organization_id':
                tableData[i]['FROM_ORGN_ID']?.toString() ?? '',
            'from_organization_code':
                tableData[i]['FROM_ORGN_CODE']?.toString() ?? '',
            'from_organization_name':
                tableData[i]['FROM_ORGN_NAME']?.toString() ?? '',

            'shipment_num': tableData[i]['SHIPMENT_NUM']?.toString() ?? '',
            'receipt_num': tableData[i]['RECEIPT_NUM']?.toString() ?? '',
            'shipped_date': tableData[i]['SHIPPED_DATE']?.toString() ?? '',
            'to_orgn_id': tableData[i]['TO_ORGN_ID']?.toString() ?? '',
            'to_orgn_code': tableData[i]['TO_ORGN_CODE']?.toString() ?? '',
            'to_orgn_name': tableData[i]['TO_ORGN_NAME']?.toString() ?? '',
            'quantity_shipped':
                tableData[i]['SYS_QUANTITY_SHIPPED']?.toString() ?? '0',
            'quantity_received':
                tableData[i]['PHY_QUANTITY_SHIPPED']?.toString() ?? '0',
            'unit_of_measure':
                tableData[i]['UNIT_OF_MEASURE']?.toString() ?? '',
            'item_id': tableData[i]['ITEM_ID']?.toString() ?? '',
            'item_code': tableData[i]['ITEM_CODE']?.toString() ?? '',

            'description': tableData[i]['DESCRIPTION']?.toString() ?? '',
            'franchise': tableData[i]['FRANCHISE']?.toString() ?? '',
            'family': tableData[i]['FAMILY']?.toString() ?? '',
            'class': tableData[i]['CLASS']?.toString() ?? '',
            'subclass': tableData[i]['SUBCLASS']?.toString() ?? '',
            'shipment_line_status_code':
                tableData[i]['SHIPMENT_LINE_STATUS_CODE']?.toString() ?? '',
            'progressQty': progress,
            'receivedQty': int.tryParse(_receivedControllers[i].text) ?? 0,
          });
        }
        print(
            "enteredProgressValues enteredProgressValues $enteredProgressValues");

        // After processing all data, check for unique from_organization_code
        if (fromOrgCodes.length == 1) {
          FromOrgCodeController.text = fromOrgCodes.first;

          FromOrgNameController.text = fromOrg1Name.first;

          ToOrgCodeController.text = ToOrgCodes.first;
          ToOrgNameController.text = ToOrgNames.first;
        } else {
          // Optional: Handle if multiple different org codes exist
          print("Warning: Multiple different from_organization_codes found.");
        }
        print("FromOrgCodeControllerrrr ${FromOrgCodeController.text}");
      }
    }
  }

// Add this widget after your table in the build method
  Widget _buildDetailsButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          _collectProgressValues();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Entered Progress Details"),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: enteredProgressValues.length,
                  itemBuilder: (context, index) {
                    final item = enteredProgressValues[index];
                    return ListTile(
                      title: Text(item['description']),
                      subtitle: Text("Item ID: ${item['item_code']}"),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Progress: ${item['progressQty']}"),
                          Text("Received: ${item['receivedQty']}"),
                        ],
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close"),
                ),
              ],
            ),
          );
        },
        child: Text("Show Details"),
      ),
    );
  }

// Add this to your state class
  bool _showShippedQuantities = false;

  Widget _buildTable() {
    List<Map<String, dynamic>> processedData = tableData.isNotEmpty
        ? tableData.map((item) {
            return {
              ...item,
              'sno': tableData.indexOf(item) + 1,
              'progressQty': item['progressQty'] ?? 0,
              // Store original received quantity when checkbox is unchecked
              'originalReceivedQty': item['PHY_QUANTITY_SHIPPED'] ?? 0,
            };
          }).toList()
        : [];

    // Ensure controllers are properly initialized
    if (_progressControllers.length != processedData.length ||
        _receivedControllers.length != processedData.length ||
        _progressFocusNodes.length != processedData.length) {
      _initializeControllers();
    }
    return Container(
      height: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.5
          : MediaQuery.of(context).size.width * 0.15,
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
                    height: Responsive.isMobile(context)
                        ? MediaQuery.of(context).size.width * 0.5
                        : MediaQuery.of(context).size.width * 0.15,
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: _verticalScrollController,
                      child: SingleChildScrollView(
                        controller: _verticalScrollController,
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10.0, right: 10, top: 7, bottom: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // S.No Column (narrower)
                                Container(
                                  width: 60,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: TableHeaderColor,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.format_list_numbered,
                                          size: 15,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 5),
                                        Text("S.No",
                                            style: commonLabelTextStyle),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 60,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: TableHeaderColor,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.numbers,
                                          size: 15,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 5),
                                        Text("Ln.N",
                                            style: commonLabelTextStyle),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 190,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: TableHeaderColor,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.numbers,
                                          size: 15,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 5),
                                        Text("Item Code",
                                            style: commonLabelTextStyle),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 330,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: TableHeaderColor,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.code,
                                          size: 15,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 5),
                                        Text("Description",
                                            style: commonLabelTextStyle),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 110,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: TableHeaderColor,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.details_outlined,
                                          size: 15,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 5),
                                        Text("Sys.Qty.Shp",
                                            style: commonLabelTextStyle),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 110,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: TableHeaderColor,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.production_quantity_limits,
                                          size: 15,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 5),
                                        Text("Sys.Qty.Rec",
                                            style: commonLabelTextStyle),
                                      ],
                                    ),
                                  ),
                                ),

                                Container(
                                  width: 110,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: TableHeaderColor,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.production_quantity_limits,
                                          size: 15,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 5),
                                        Text("Phy.Qty.Shp",
                                            style: commonLabelTextStyle),
                                      ],
                                    ),
                                  ),
                                ),

                                Container(
                                  width: 110,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: TableHeaderColor,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.production_quantity_limits,
                                          size: 15,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 5),
                                        Text("Phy.Qty.Rec",
                                            style: commonLabelTextStyle),
                                      ],
                                    ),
                                  ),
                                ),

                                // Modified Qty.Dis column with checkbox
                                Container(
                                  width: 120,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: TableHeaderColor,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Checkbox(
                                          value: _showShippedQuantities,
                                          onChanged: (value) {
                                            setState(() {
                                              _showShippedQuantities =
                                                  value ?? false;
                                              // Update all rows based on checkbox state
                                              for (int i = 0;
                                                  i < processedData.length;
                                                  i++) {
                                                final shippedQty = int.tryParse(
                                                        processedData[i][
                                                                    'SYS_QUANTITY_SHIPPED']
                                                                ?.toString() ??
                                                            '0') ??
                                                    0;
                                                final originalReceivedQty =
                                                    processedData[i][
                                                            'originalReceivedQty'] ??
                                                        0;
                                                final currentReceivedQty =
                                                    int.tryParse(processedData[
                                                                        i][
                                                                    'PHY_QUANTITY_SHIPPED']
                                                                ?.toString() ??
                                                            '0') ??
                                                        0;
                                                final discrepancyQty =
                                                    shippedQty -
                                                        currentReceivedQty;

                                                // Update controllers and data
                                                _progressControllers[i].text =
                                                    _showShippedQuantities
                                                        ? discrepancyQty
                                                            .toString()
                                                        : '0';
                                                processedData[i]
                                                        ['progressQty'] =
                                                    _showShippedQuantities
                                                        ? discrepancyQty
                                                        : 0;

                                                // Toggle between 0 and original received quantity
                                                // processedData[i][
                                                //         'PHY_QUANTITY_SHIPPED'] =
                                                //     _showShippedQuantities
                                                //         ? 0
                                                //         : originalReceivedQty;

                                                // Update received controller
                                                _receivedControllers[i].text =
                                                    _showShippedQuantities
                                                        ? (processedData[i][
                                                                'SYS_QUANTITY_SHIPPED']
                                                            .toString()) // When checkbox is checked, show 0 in received column
                                                        : (processedData[i][
                                                                'PHY_QUANTITY_SHIPPED']
                                                            .toString()); // When unchecked, show actual received quantity
                                              }
                                              _updateSummaryControllers();
                                            });
                                          },
                                        ),
                                        SizedBox(width: 5),
                                        Text("Qty.Dis",
                                            style: commonLabelTextStyle),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isLoadingData)
                            Padding(
                              padding: const EdgeInsets.only(top: 100.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (processedData.isNotEmpty)
                            ...processedData.asMap().entries.map((entry) {
                              final rowIndex = entry.key;
                              final data = entry.value;

                              final sno = data['sno'].toString();
                              final fromorgcode =
                                  data['FROM_ORGN_CODE'].toString();
                              final lineno = data['LINE_NUM'].toString();
                              final toorgcode = data['TO_ORGN_CODE'].toString();
                              final itemId = data['ITEM_CODE'].toString();
                              final description =
                                  data['DESCRIPTION'].toString();
                              final qtyShipped =
                                  data['SYS_QUANTITY_SHIPPED'].toString();

                              final sysqtyReceived =
                                  data['SYS_QUANTITY_RECEIVED'].toString();

                              final phyqtyshipped =
                                  (data['PHY_QUANTITY_SHIPPED'] ?? 0)
                                      .toString();
                              final phyqtyReceived =
                                  (data['PHY_QUANTITY_RECEIVED'] ?? 0)
                                      .toString();

                              final isEvenRow = rowIndex % 2 == 0;
                              final rowColor = isEvenRow
                                  ? Color.fromARGB(224, 255, 255, 255)
                                  : Color.fromARGB(224, 240, 240, 240);

                              return GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).requestFocus(
                                      _progressFocusNodes[rowIndex]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // S.No Column
                                      Container(
                                        width: 60,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Center(
                                          child: SelectableText(
                                            sno,
                                            textAlign: TextAlign.center,
                                            style: TableRowTextStyle,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 60,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Center(
                                          child: SelectableText(
                                            lineno,
                                            textAlign: TextAlign.center,
                                            style: TableRowTextStyle,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 190,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Center(
                                          child: SelectableText(
                                            itemId,
                                            textAlign: TextAlign.center,
                                            style: TableRowTextStyle,
                                          ),
                                        ),
                                      ),
                                      Tooltip(
                                        message: description,
                                        child: Container(
                                          width: 330,
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
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: SelectableText(
                                                description,
                                                style: TableRowTextStyle,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 110,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Center(
                                          child: SelectableText(
                                            qtyShipped,
                                            textAlign: TextAlign.center,
                                            style: TableRowTextStyle,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 110,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Center(
                                          child: SelectableText(
                                            sysqtyReceived,
                                            textAlign: TextAlign.center,
                                            style: TableRowTextStyle,
                                          ),
                                        ),
                                      ),

                                      Container(
                                        width: 110,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Center(
                                          child: SelectableText(
                                            phyqtyshipped,
                                            textAlign: TextAlign.center,
                                            style: TableRowTextStyle,
                                          ),
                                        ),
                                      ),

                                      Container(
                                        width: 110,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Center(
                                          child: SelectableText(
                                            phyqtyReceived,
                                            textAlign: TextAlign.center,
                                            style: TableRowTextStyle,
                                          ),
                                        ),
                                      ),

                                      // Container(
                                      //   width: 150,
                                      //   height: 30,
                                      //   decoration: BoxDecoration(
                                      //     color: rowColor,
                                      //     border: Border.all(
                                      //       color: Color.fromARGB(
                                      //           255, 226, 225, 225),
                                      //     ),
                                      //   ),
                                      //   child: Center(
                                      //     child: SelectableText(
                                      //       rowIndex <
                                      //               _receivedControllers.length
                                      //           ? _receivedControllers[rowIndex]
                                      //               .text
                                      //           : '0',
                                      //       style: TableRowTextStyle,
                                      //     ),
                                      //   ),
                                      // ),

                                      Container(
                                        width: 120,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Center(
                                          child: AbsorbPointer(
                                            absorbing:
                                                _showShippedQuantities, // Disable interaction when checkbox is unchecked
                                            child: TextField(
                                              // focusNode: !_showShippedQuantities
                                              //     ? _progressFocusNodes[
                                              //         rowIndex]
                                              //     : null, // Only enable focus when checkbox is checked
                                              // controller: _progressControllers[
                                              //     rowIndex],
                                              // keyboardType:
                                              //     TextInputType.number,

                                              focusNode: !_showShippedQuantities
                                                  ? _progressFocusNodes[
                                                      rowIndex]
                                                  : null,
                                              controller: _progressControllers[
                                                  rowIndex],
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(
                                                        r'[0-9]')), // Only allow digits 0-9
                                              ],
                                              textAlign: TextAlign.center,
                                              style: TableRowTextStyle.copyWith(
                                                color: !_showShippedQuantities
                                                    ? Colors.black
                                                    : const Color.fromARGB(
                                                        255,
                                                        75,
                                                        75,
                                                        75), // Grey out text when disabled
                                              ),
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.zero,
                                                isDense: true,
                                                hintText: '0',
                                                hintStyle:
                                                    TableRowTextStyle.copyWith(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              readOnly:
                                                  _showShippedQuantities, // Make read-only when checkbox is unchecked
                                              onChanged: (value) async {
                                                final shipped =
                                                    int.tryParse(qtyShipped) ??
                                                        0;
                                                final progress =
                                                    int.tryParse(value) ?? 0;
                                                final originalReceived = int.tryParse(
                                                        data['PHY_QUANTITY_SHIPPED']
                                                                ?.toString() ??
                                                            '0') ??
                                                    0;

                                                // Calculate new received quantity
                                                final newReceived =
                                                    originalReceived + progress;

                                                final qtyShippeddd = double.tryParse(
                                                        data['SYS_QUANTITY_SHIPPED']
                                                                ?.toString() ??
                                                            "0") ??
                                                    0;
                                                final phyqtyshippeddds =
                                                    double.tryParse(
                                                            data['PHY_QUANTITY_SHIPPED']
                                                                    ?.toString() ??
                                                                "0") ??
                                                        0;

                                                final allowedqty =
                                                    qtyShippeddd -
                                                        phyqtyshippeddds;

                                                if (newReceived > shipped) {
                                                  bool? shouldContinue =
                                                      await showDialog<bool>(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      title: Text(
                                                          "Quantity Exceeded"),
                                                      content: Text(
                                                          "You entered quantity is greater than the shipment quantity (${allowedqty})."),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  false),
                                                          child: Text("OK"),
                                                        ),
                                                      ],
                                                    ),
                                                  );

                                                  if (shouldContinue == null ||
                                                      !shouldContinue) {
                                                    final adjustedProgress =
                                                        shipped -
                                                            originalReceived;
                                                    _progressControllers[
                                                                rowIndex]
                                                            .text =
                                                        adjustedProgress
                                                            .toString();
                                                    _receivedControllers[
                                                                rowIndex]
                                                            .text =
                                                        shipped.toString();
                                                    data['progressQty'] =
                                                        adjustedProgress;
                                                    data['PHY_QUANTITY_SHIPPED'] =
                                                        shipped;

                                                    // Update summary controllers
                                                    _updateSummaryControllers();
                                                    setState(() {});
                                                    return;
                                                  }
                                                }

                                                // Update normally if within limits
                                                _receivedControllers[rowIndex]
                                                        .text =
                                                    newReceived.toString();
                                                data['progressQty'] = progress;
                                                data['PHY_QUANTITY_SHIPPED'] =
                                                    newReceived;

                                                // Update summary controllers
                                                _updateSummaryControllers();
                                                setState(() {});
                                              },
                                              onSubmitted: (value) {
                                                final nextIndex =
                                                    (rowIndex + 1) %
                                                        processedData.length;
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        _progressFocusNodes[
                                                            nextIndex]);
                                              },
                                            ),
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
                  _horizontalScrollController.animateTo(
                    _horizontalScrollController.offset - 100,
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
                  _horizontalScrollController.animateTo(
                    _horizontalScrollController.offset + 100,
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

  _updateSummaryControllers() {
    try {
      // Update item count
      NoOfItemsController.text = tableData.length.toString();
      debugPrint('Total items: ${tableData.length}');

      // Calculate total progress quantity from controllers
      int totalProgress = 0;

      debugPrint('Calculating progress quantities from controllers:');
      for (int i = 0; i < _progressControllers.length; i++) {
        if (i < tableData.length) {
          // Get progress value from controller
          final progressText = _progressControllers[i].text;
          final progress = int.tryParse(progressText) ?? 0;

          // Update the data model to keep in sync
          tableData[i]['progressQty'] = progress;

          debugPrint('- Row $i: $progress (from controller: "$progressText")');
          totalProgress += progress;
        }
      }

      // Update the total controller
      if (mounted) {
        TotalProgressQtyController.text = totalProgress.toString();
        debugPrint('TOTAL PROGRESS CALCULATED: $totalProgress');
      }
    } catch (e) {
      debugPrint('Error in _updateSummaryControllers: $e');
      if (mounted) {
        TotalProgressQtyController.text = '0';
      }
    }
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
    _progressControllers = [];
    _receivedControllers = [];
    _progressFocusNodes = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lableRoleIDList = prefs.getString('departmentid');
    String? salesloginnoStr = prefs.getString('salesloginno');
    String? SaveShipmentid = prefs.getString('SaveShipmentid');

    String? SaveTransfertype = prefs.getString('SaveTransfertype');

    ShipmentnumberController.text = SaveShipmentid.toString();

    print('shipmentttttt id ${ShipmentnumberController.text}');
    await loadTableData(SaveTransfertype.toString(), SaveShipmentid.toString());
    _progressControllers = [];
    _receivedControllers = [];
    _progressFocusNodes = [];
    await _initializeControllers();
    await _updateSummaryControllers();

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

  _initializeControllers() {
    // Dispose existing controllers if any
    for (var controller in _progressControllers) {
      controller.dispose();
    }
    for (var controller in _receivedControllers) {
      controller.dispose();
    }
    for (var node in _progressFocusNodes) {
      node.dispose();
    }

    // Initialize new controllers
    _progressControllers = tableData.map((data) {
      return TextEditingController(text: (data['progressQty'] ?? 0).toString());
    }).toList();

    _receivedControllers = tableData.map((data) {
      return TextEditingController(
          text: (data['PHY_QUANTITY_SHIPPED'] ?? 0).toString());
    }).toList();

    _progressFocusNodes =
        List.generate(tableData.length, (index) => FocusNode());
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
                                  Icons.fire_truck,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Inter ORG Trucking',
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
                                          fontSize: 17,
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
                                //     'Inter ORG Dispatch ID',
                                //     ShipmentIdController,
                                //     Icons.numbers,
                                //     true,
                                //     Icons.star,
                                //     Colors.red,
                                //     shipmentidfocusnode,
                                //     transportorfocusnode),
                                SizedBox(
                                    width:
                                        Responsive.isDesktop(context) ? 0 : 10),

                                _buildTextFieldDesktop(
                                    'Shipment Num',
                                    shipmentNumberController,
                                    Icons.numbers,
                                    true,
                                    Icons.star,
                                    Colors.red,
                                    shipmentnumfocusnode,
                                    transportorfocusnode),
                                SizedBox(
                                    width:
                                        Responsive.isDesktop(context) ? 0 : 10),
                                _buildTextFieldDesktop(
                                    'Receipt Num',
                                    receiptNumController,
                                    Icons.numbers,
                                    true,
                                    Icons.star,
                                    Colors.red,
                                    receiptnumfocusnode,
                                    transportorfocusnode),
                                SizedBox(
                                    width:
                                        Responsive.isDesktop(context) ? 0 : 10),

                                _buildTextFieldDesktop(
                                    'Transporter Name',
                                    TransporterController,
                                    Icons.shop,
                                    false,
                                    Icons.star,
                                    Colors.red,
                                    transportorfocusnode,
                                    driverfocusnode),
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
                                    driverfocusnode,
                                    drivermobilenofocusnode),
                                _buildTextFieldDesktop(
                                    'Driver MobileNo',
                                    DriverMobileNoController,
                                    Icons.drive_file_rename_outline,
                                    false,
                                    Icons.star,
                                    Colors.red,
                                    drivermobilenofocusnode,
                                    Vehiclenofocusnode),
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
                                    Vehiclenofocusnode,
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
                                    DeliveryaAddressfocusnode),

                                SizedBox(
                                    width:
                                        Responsive.isDesktop(context) ? 0 : 10),
                                _buildTextFieldDesktop(
                                    'Remarks',
                                    RemarkCOntroller,
                                    Icons.miscellaneous_services,
                                    false,
                                    Icons.star,
                                    Colors.transparent,
                                    DeliveryaAddressfocusnode,
                                    DeliveryaAddressfocusnode),
                                // Container(
                                //   width: Responsive.isDesktop(context)
                                //       ? screenWidth * 0.15
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
                                //             Icon(
                                //               Icons.star,
                                //               size: 8,
                                //               color: Colors.red,
                                //             )
                                //           ],
                                //         ),
                                //         const SizedBox(height: 6),
                                //         Padding(
                                //           padding: const EdgeInsets.only(
                                //               left: 0, bottom: 0),
                                //           child: Row(
                                //             children: [
                                //               Container(
                                //                   // height: 32,
                                //                   // width: Responsive.isDesktop(context)
                                //                   //     ? screenWidth * 0.086
                                //                   //     : 130,

                                //                   width: Responsive.isDesktop(
                                //                           context)
                                //                       ? screenWidth * 0.15
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
                                //                             // focusNode:
                                //                             //     Deliverydatefocusnode,
                                //                             // onFieldSubmitted: (_) =>
                                //                             //     _fieldFocusChange(
                                //                             //         context,
                                //                             //         Deliverydatefocusnode,
                                //                             //         delivera),
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
                                //                                 deliverAddressController,
                                //                             focusNode:
                                //                                 DeliveryaAddressfocusnode,
                                //                             style: TextStyle(
                                //                               color: Color
                                //                                   .fromARGB(
                                //                                       255,
                                //                                       73,
                                //                                       72,
                                //                                       72),
                                //                               fontSize: 15,
                                //                             ),
                                //                             onChanged: (value) {
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
                                //                               style: TextStyle(
                                //                                 fontSize: 12,
                                //                                 color:
                                //                                     Colors.grey,
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
                              ],
                            )),
                        Padding(
                          padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 30 : 10),
                          child: Text("Shipment Dispatch Items",
                              style: topheadingbold),
                        ),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        if (Responsive.isDesktop(context))
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10, left: 35, right: 35),
                            child: Container(
                              height: Responsive.isMobile(context)
                                  ? MediaQuery.of(context).size.height * 1
                                  : MediaQuery.of(context).size.height * 0.32,
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
                                                      NoOfItemsController,
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
                                                      TotalProgressQtyController,
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
                          height: 20,
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
                                        await _collectProgressValues();
                                        _collectProgressValues();

                                        if (!validateFields()) {
                                          // If any field is empty, show the validation dialog
                                          showValidationDialog(context);
                                        } else {
                                          showInvoiceDialog(context, true,
                                              enteredProgressValues);
                                        }

                                        postLogData("Inter ORG Trucking",
                                            "Transfer Dispatch Print Preview opened");
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
                                          'Transfer Dispatch Slip',
                                          style: commonWhiteStyle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Container(
                                    decoration:
                                        BoxDecoration(color: buttonColor),
                                    height: 30,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        DriverMobileNoController.clear();
                                        DriverController.clear();
                                        VehicleNoController.clear();
                                        TruckDimentionController.clear();
                                        LoadingChargeController.clear();
                                        MISCController.clear();
                                        RemarkCOntroller.clear();
                                        TransportChargeController.clear();

                                        widget.togglePage();

                                        postLogData("Inter ORG Trucking",
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
                            : Wrap(
                                alignment: WrapAlignment.center,
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: buttonColor),
                                      height: 30,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          await _collectProgressValues();
                                          _collectProgressValues();

                                          if (!validateFields()) {
                                            // If any field is empty, show the validation dialog
                                            showValidationDialog(context);
                                          } else {
                                            showInvoiceDialog(context, true,
                                                enteredProgressValues);
                                          }
                                          postLogData("Inter ORG Trucking",
                                              "Transfer Dispatch Print Preview opened");
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
                                            'Transfer Dispatch Slip',
                                            style: commonWhiteStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration:
                                        BoxDecoration(color: buttonColor),
                                    height: 30,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        DriverMobileNoController.clear();
                                        DriverController.clear();
                                        VehicleNoController.clear();
                                        TruckDimentionController.clear();
                                        LoadingChargeController.clear();
                                        MISCController.clear();
                                        RemarkCOntroller.clear();
                                        TransportChargeController.clear();

                                        widget.togglePage();

                                        postLogData("Inter ORG Trucking",
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
                              ),
                        SizedBox(
                          height: 10,
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

  bool validateFields() {
    String transportorname =
        TransporterController.text.isNotEmpty ? TransporterController.text : '';
    String deliveryaddress = deliverAddressController.text.isNotEmpty
        ? deliverAddressController.text
        : 'null';

    String drivermobileno = DriverMobileNoController.text.isNotEmpty
        ? DriverMobileNoController.text
        : '';
    String driverid =
        DriverController.text.isNotEmpty ? DriverController.text : '';
    String vehicleNo =
        VehicleNoController.text.isNotEmpty ? VehicleNoController.text : '';

    // Check if any fields are empty
    return transportorname.isNotEmpty &&
        drivermobileno.isNotEmpty &&
        driverid.isNotEmpty &&
        vehicleNo.isNotEmpty &&
        enteredProgressValues.isNotEmpty;
  }

  void showInvoiceDialog(
    BuildContext context,
    bool buttonname,
    List<Map<String, dynamic>> enteredProgressValues,
  ) {
    print(
        "enteredProgressValues enteredProgressValuesnnnnnnnnnnnnnnnnnn $enteredProgressValues");
    double _calculateSendQtyTotal(
        List<Map<String, dynamic>> enteredProgressValues) {
      double totalSendQty = 0.0;
      for (var row in enteredProgressValues) {
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
                                    ? 'Transfer Receipt'
                                    : 'Preview Generate Dipatch Print',
                                style: TextStyle(
                                  fontSize: 14,
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
                              // Column(
                              //   crossAxisAlignment: CrossAxisAlignment.end,
                              //   children: [
                              //     Text('123 Restaurant St, City Name',
                              //         style: TextStyle(
                              //             fontSize: 12, color: Colors.grey)),
                              //     Text('Phone: +91 12345 67890',
                              //         style: TextStyle(
                              //             fontSize: 12, color: Colors.grey)),
                              //     Text('Website: www.aljeflutterapp.com',
                              //         style: TextStyle(
                              //             fontSize: 12, color: Colors.grey)),
                              //   ],
                              // ),
                            ],
                          ),
                          SizedBox(height: 5),

                          // Invoice Details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Shipment No: ${ShipmentnumberController.text}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[600]),
                              ),
                              Text(
                                DateFormat('dd-MMM-yyyy')
                                    .format(DateTime.now())
                                    .toUpperCase(), // Convert month to uppercase
                                style: TextStyle(
                                  fontSize: 13,
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
                                  'Transportor Name: ',
                                  TransporterController.text,
                                  'Vehicle No: ',
                                  VehicleNoController.text,
                                ),
                                _buildDetailRow(
                                  'Driver Name: ',
                                  DriverController.text,
                                  'Driver MobileNo: ',
                                  DriverMobileNoController.text,
                                ),
                                // _buildDetailRow(
                                //   'Delivery Address: ',
                                //   deliverAddressController.text,
                                //   '',
                                //   '',
                                // ),
                                _buildDetailRow(
                                  'From Org Code: ',
                                  FromOrgCodeController.text,
                                  'From Org Name: ',
                                  FromOrgNameController.text,
                                ),
                                _buildDetailRow(
                                  'To Org Code: ',
                                  ToOrgCodeController.text,
                                  'To Org Name: ',
                                  ToOrgNameController.text,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),

                          Text(
                            'Dispatch Items:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[700]),
                          ),
                          SizedBox(height: 12),

                          // Display the table
                          SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Container(
                              height: 300,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 1.5),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: IntrinsicHeight(
                                // Ensures the height matches PrintPreviewTable's height
                                child: PrintPreviewTable(
                                    enteredProgressValues:
                                        enteredProgressValues),
                              ),
                            ),
                          ),
                          SizedBox(height: 7),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Total Qty: ${TotalProgressQtyController.text}',
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

// Helper function to truncate value2
  String _truncateText(String text) {
    const int maxChars = 10; // Number of characters to show
    if (text.length > maxChars) {
      int halfLength = maxChars ~/ 2; // Display half the max characters
      return '${text.substring(0, halfLength)}...';
    }
    return text;
  }

  // String InterORGdeliveryId = '';
  // String token = '';

  // Future<void> fetchTokenwithCusid() async {
  //   final IpAddress = await getActiveIpAddress();

  //   try {
  //     // Send a GET request to fetch the CSRF token from the server
  //     final response =
  //         await http.get(Uri.parse('$IpAddress/Shipment_generate-token/'));

  //     if (response.statusCode == 200) {
  //       // Parse the JSON response to extract the new CSRF token and message
  //       var data = jsonDecode(response.body);

  //       String InterORGdeliveryId = data['Shipment_Id']?.toString() ?? '';
  //       //  int.tryParse(data['Shipment_Id'].toString()) ??
  //       //     0; // Safe conversion
  //       String token = data['Tocken'] ?? 'No Token found';

  //       String saveInterORGdeliveryId = InterORGdeliveryId.toString();

  //       await saveToSharedPreferences(saveInterORGdeliveryId, token);

  //       setState(() {
  //         // Only update state variables here
  //       });

  //       print(
  //           'deliveryyyyy  $InterORGdeliveryId  $saveInterORGdeliveryId  $token');
  //     } else {
  //       setState(() {
  //         // Message = 'Failed to fetch data. Status code: ${response.statusCode}';
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       // Message = 'Error: $e';
  //     });
  //   }
  // }

  Future<void> fetchTokenwithCusid() async {
    final ipAddress = await getActiveIpAddress();

    try {
      final response = await http.get(
        Uri.parse('$ipAddress/Shipment_Id_Generate/'),
      );
      print("urlssss $ipAddress/Shipment_Id_Generate/");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Shipment_Id (always string in backend)
        String interORGdeliveryId = data['Shipment_Id']?.toString() ?? '';

        // Tocken (can be int or string → force convert to string safely)
        String token = data['Tocken']?.toString() ?? 'No Token found';

        setState(() {
          // Update UI if needed
        });

        print('dispatch idd: $interORGdeliveryId  token: $token');

        await saveToSharedPreferences(interORGdeliveryId, token);
      } else {
        await FetchLastShipmentNo();
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      await FetchLastShipmentNo();
      print('Error: $e');
    }
  }

  Future<void> saveToSharedPreferences(String lastCusID, String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('Unique_Inter_ORG_id', lastCusID);
    await prefs.setString('Unique_Inter_ORG_token', token);
  }

  _launchUrl(BuildContext context) async {
    List<String> productDetails = [];
    String onlyshipmentid = ShipmentnumberController.text.toString();
    int snoCounter = 1; // Initialize the sequence number counter

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? Unique_Inter_ORG_id = prefs.getString('Unique_Inter_ORG_id') ?? '';

    // Filter, format, and merge only data where receivedQty != 0
    List<Map<String, dynamic>> mergeTableData(
        List<Map<String, dynamic>> enteredProgressValues) {
      List<Map<String, dynamic>> mergedList = [];
      print("enteredProgressValuessss swssdfsdfsdfsdf  $enteredProgressValues");
      for (var item in enteredProgressValues) {
        int receivedQty =
            int.tryParse(item['receivedQty']?.toString() ?? '0') ?? 0;

        if (receivedQty != 0) {
          mergedList.add({
            'sno': snoCounter++,
            'from_organization_code': item['from_organization_code'],
            'from_organization_name': item['from_organization_name'],
            'to_orgn_code': item['to_orgn_code'],
            'to_orgn_name': item['to_orgn_name'],
            'item_code': item['item_code'],
            'description': item['description'],
            'progressQty': item['progressQty'],
          });
        }
      }

      return mergedList;
    }

    // Call function with your actual data
    List<Map<String, dynamic>> mergedData =
        mergeTableData(enteredProgressValues);

    for (var data in mergedData) {
      String formattedProduct =
          "{${data['sno']}|${data['from_organization_code']}|${data['from_organization_name']}|${data['to_orgn_code']}|${data['to_orgn_name']}|${data['item_code']}|${data['description']}|${data['progressQty']}}";
      productDetails.add(formattedProduct);
    }

    String productDetailsString = productDetails.join(',');
    print("productDetailsString: $productDetailsString");
    DateTime today = DateTime.now();
    String formattedDate = DateFormat('dd-MMM-yyyy').format(today);

    String shipmentid =
        ShipmentIdController.text.isNotEmpty ? ShipmentIdController.text : '';

    String shipmentnum = ShipmentnumberController.text.isNotEmpty
        ? ShipmentnumberController.text
        : '';

    String receiptnum =
        receiptNumController.text.isNotEmpty ? receiptNumController.text : '';
    String totalqty = TotalProgressQtyController.text.isNotEmpty
        ? TotalProgressQtyController.text
        : 'null';

    String transpotorname = TransporterController.text.isNotEmpty
        ? TransporterController.text
        : 'null';

    String vehicleNo =
        VehicleNoController.text.isNotEmpty ? VehicleNoController.text : 'null';
    String remarks =
        RemarkCOntroller.text.isNotEmpty ? RemarkCOntroller.text : 'null';
    String driverName =
        DriverController.text.isNotEmpty ? DriverController.text : 'null';

    String drivermobileNo = DriverMobileNoController.text.isNotEmpty
        ? DriverMobileNoController.text
        : 'null';

    String deliveryaddress = deliverAddressController.text.isNotEmpty
        ? deliverAddressController.text
        : 'null';

    final IpAddress = await getActiveOracleIpAddress();

    String dynamicUrl =
        '$IpAddress/Generate_Shipment_dispatch_print$parameterdivided$shipmentnum$parameterdivided$receiptnum$parameterdivided$Unique_Inter_ORG_id$parameterdivided$transpotorname$parameterdivided$vehicleNo$parameterdivided$driverName$parameterdivided$drivermobileNo$parameterdivided$formattedDate$parameterdivided$remarks$parameterdivided$totalqty$parameterdivided$productDetailsString$parameterdivided';

    print('urlllllllllll : $dynamicUrl');

    if (await canLaunch(dynamicUrl)) {
      await launch(
        dynamicUrl,
        enableJavaScript: true,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $dynamicUrl')),
      );
    }
  }

  Future<void> updateShipmentQuantity(String SaveTransfertype,
      String shipmentid, int shipmentliniid, int receiveedqty) async {
    int qty = receiveedqty;
    String responseMessage = "Press the button to update quantity.";
    print(
        "Perss the button to update quantity. $shipmentid $shipmentliniid $receiveedqty");

    final IpAddress = await getActiveIpAddress();

    final url = Uri.parse('$IpAddress/update_Phy_quantity_Shipped_interOrg/');
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      "TRANSFER_TYPE": SaveTransfertype,
      "SHIPMENT_NUM": "$shipmentid",
      "SHIPMENT_LINE_ID": shipmentliniid,
      "qty_recent": receiveedqty
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          responseMessage = "Success: ${responseData["message"]}\n"
              "Old Qty: ${responseData["old_qty"]}, "
              "Added Qty: ${responseData["added_qty"]}, "
              "New Qty: ${responseData["new_qty"]}";
        });
      } else {
        setState(() {
          // print("Error ${response.statusCode}: ${response.body}");
          responseMessage = "Error ${response.statusCode}: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        print("Exception: $e");
        responseMessage = "Exception: $e";
      });
    }
  }

  Future<void> insertInterORGData(
      String shipmentid, int shipmentlineid, int qty) async {
    final IpAddress = await getActiveIpAddress();

    final String url =
        '$IpAddress/insert_Inter_ORG_data/$shipmentid/$shipmentlineid/$qty/';
    print("inter org tem table url $url");
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // print('Data inserted successfully: ${response.body}');
      } else {
        print('Failed to insert data. Status Code: ${response.statusCode}');
        // print('Response Body: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> updateOracleShipmentQuantity(String SaveTransfertype,
      String shipmentid, int shipmentlineid, int receivedqty) async {
    String responseMessage = "Press the button to update quantity.";
    print(responseMessage);

    final TestingOracleIpAddress = await getActiveOracleIpAddress();

    final url = Uri.parse(
        '$TestingOracleIpAddress/UPDATE_Oracle_quantity_received_interOrg/$SaveTransfertype/$shipmentid/$shipmentlineid/$receivedqty/');

    try {
      final response = await http.put(url); // <-- Use PUT instead of POST

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          responseMessage = "Success: ${responseData["message"]}\n"
              "Old Qty: ${responseData["old_qty"]}, "
              "Added Qty: ${responseData["added_qty"]}, "
              "New Qty: ${responseData["new_qty"]}";
        });
      } else {
        setState(() {
          // print("Error ${response.statusCode}: ${response.body}");
          responseMessage = "Error ${response.statusCode}: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        print("Exception: $e");
        responseMessage = "Exception: $e";
      });
    }
  }

// Helper function
  String _formatDate(dynamic date) {
    try {
      if (date != null && date.toString().isNotEmpty) {
        return DateFormat("yyyy-MM-dd").format(DateTime.parse(date.toString()));
      }
    } catch (e) {
      // log or ignore
    }
    return DateFormat("yyyy-MM-dd").format(DateTime.now());
  }

  Future<void> postTruck_scan() async {
    await fetchTokenwithCusid();
    bool savesuccess = false;
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/Shiment_Dispatch/';
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? salesloginno = prefs.getString('salesloginno') ?? '';
    String? saveloginname = prefs.getString('saveloginname') ?? '';
    String? Unique_Inter_ORG_id = prefs.getString('Unique_Inter_ORG_id') ?? '';

    String? saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename') ?? '';
    String? SaveTransfertype = prefs.getString('SaveTransfertype') ?? '';

    print('enteredProgressValues $enteredProgressValues');
    try {
      String onlyshipmentid = ShipmentIdController.text.toString();
      String shipmentid =
          ShipmentIdController.text.isNotEmpty ? ShipmentIdController.text : '';

      String transportorname = TransporterController.text.isNotEmpty
          ? TransporterController.text
          : 'null';
      String drivermobileno = DriverMobileNoController.text.isNotEmpty
          ? DriverMobileNoController.text
          : 'null';
      String drivername =
          DriverController.text.isNotEmpty ? DriverController.text : 'null';
      String vehicleNo = VehicleNoController.text.isNotEmpty
          ? VehicleNoController.text
          : 'null';
      String truckDimension = TruckDimentionController.text.isNotEmpty
          ? TruckDimentionController.text
          : 'null';

      int loadingCharge = int.tryParse(LoadingChargeController.text) ?? 0;
      String remarks =
          RemarkCOntroller.text.isNotEmpty ? RemarkCOntroller.text : 'null';
      int miscCharge = int.tryParse(MISCController.text) ?? 0;
      int transportCharge = int.tryParse(TransportChargeController.text) ?? 0;

      String deliveryaddress = deliverAddressController.text.isNotEmpty
          ? deliverAddressController.text
          : 'null';

      String shipmentno = ShipmentIdController.text.isNotEmpty
          ? ShipmentIdController.text
          : 'null';

      String towarehousename = TowarehouseNameController.text.isNotEmpty
          ? TowarehouseNameController.text
          : 'null';

      for (int i = 0; i < enteredProgressValues.length; i++) {
        var row = enteredProgressValues[i];
        String shipment_num = '';
        if (SaveTransfertype == "Receipt Number")
          shipment_num = row['receipt_num'].toString();
        if (SaveTransfertype == "Shipment Number")
          shipment_num = row['shipment_num'].toString();
        int shipmentliniid = int.parse(row['shipment_line_id'].toString());
        int receiveedqty = int.parse(row['receivedQty'].toString());
        int progressQty = int.parse(row['progressQty'].toString());

        print(
            "shipmentiddddddddddd $remarks  $shipment_num $shipmentliniid $progressQty");

        // await updateOracleShipmentQuantity(
        //     SaveTransfertype, shipment_num, shipmentliniid, progressQty);

        // Properly format the creation_date (use today's date if missing)
        String formattedCreationDate = '';
        if (row['creation_date'] != null &&
            row['creation_date'].toString().isNotEmpty) {
          try {
            DateTime parsedDate = DateTime.parse(row['creation_date']);
            formattedCreationDate = DateFormat("yyyy-MM-dd").format(parsedDate);
          } catch (e) {
            // fallback to now if parsing fails
            formattedCreationDate =
                DateFormat("yyyy-MM-dd").format(DateTime.now());
          }
        } else {
          formattedCreationDate =
              DateFormat("yyyy-MM-dd").format(DateTime.now());
        }

        // Format current datetime for dispatch creation date
        String formattedDeliveryDate =
            DateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(DateTime.now());
        String formattedShippedDate = _formatDate(row['shipped_date']);
        int shipmentIdInt =
            int.tryParse(onlyshipmentid.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

        print(
            'shipment id $shipmentIdInt  shipment date $formattedCreationDate  ');

        Map<String, dynamic> createDispatchData = {
          "shipment_id": Unique_Inter_ORG_id,
          "warehouse_name": saleslogiOrgwarehousename.isNotEmpty
              ? saleslogiOrgwarehousename
              : 'Unknown',
          "to_warehouse_name": towarehousename,
          "salesmanno": salesloginno.isNotEmpty ? salesloginno : 'Unknown',
          "salesmanname": saveloginname.isNotEmpty ? saveloginname : 'Unknown',
          "date": formattedDeliveryDate,
          "transporter_name": transportorname,
          "driver_name": drivername,
          "driver_mobileno": drivermobileno,
          "vehicle_no": vehicleNo,
          "truck_dimension": truckDimension,
          "loading_charges": loadingCharge,
          "transport_charges": transportCharge,
          "misc_charges": miscCharge,
          "deliveryaddress": deliveryaddress,
          "shipment_header_id": row['shipment_header_id']?.toString() ?? '0',
          "shipment_line_id": row['shipment_line_id']?.toString() ?? '0',
          "line_num": row['line_num']?.toString() ?? '0',
          "creation_date": formattedCreationDate,
          "created_by": row['created_by']?.toString() ?? '0',
          "organization_id": row['from_organization_id']?.toString() ?? '0',
          "organization_code": row['from_organization_code']?.toString() ?? '0',
          "organization_name": row['from_organization_name']?.toString() ?? '0',
          "shipment_num": row['shipment_num']?.toString() ?? '0',
          "receipt_num": row['receipt_num']?.toString() ?? '0',
          "shipped_date": formattedShippedDate,
          "to_orgn_id": row['to_orgn_id']?.toString() ?? '0',
          "to_orgn_code": row['to_orgn_code']?.toString() ?? '0',
          "to_orgn_name": row['to_orgn_name']?.toString() ?? '0',
          "quantity_shipped": row['quantity_shipped']?.toString() ?? '0',
          "quantity_received":
              int.tryParse(row['quantity_received']?.toString() ?? '') ?? 0,
          "unit_of_measure": row['unit_of_measure']?.toString() ?? '0',
          "item_id": row['item_code']?.toString() ?? '0',
          "item_code": row['item_code']?.toString() ?? '0',
          "description": row['description']?.toString() ?? '0',
          "franchise": row['franchise']?.toString() ?? '0',
          "family": row['family']?.toString() ?? '0',
          "class_field": row['class']?.toString() ?? '0',
          "subclass": row['subclass']?.toString() ?? '0',
          "shipment_line_status_code":
              row['shipment_line_status_code']?.toString() ?? '0',
          "quantity_progress": row['progressQty']?.toString() ?? '0',
          "quantity_received_actual": row['receivedQty']?.toString() ?? '0',
          "active_status": 'Not Recevied',
          "remarks": remarks
        };

        // Post to API
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(createDispatchData),
        );

        if (response.statusCode == 201) {
          await updateShipmentQuantity(
              SaveTransfertype, shipment_num, shipmentliniid, progressQty);

          await insertInterORGData(
              Unique_Inter_ORG_id, shipmentliniid, progressQty);
          setState(() {
            savesuccess = true;
          });
          print('✅ Dispatch created successfully for row $i');
        } else {
          setState(() {
            savesuccess = false;
          });
          print(
              '❌ Failed to create dispatch for row $i. Status: ${response.statusCode}');
          // print('Response: ${response.body}');
        }
      }

      postLogData("Inter ORG Trucking",
          "Transfer Dispatch Saved ${enteredProgressValues.length} Items with ${TotalProgressQtyController.text} Quantities with InterORG Dispatch Id: ${shipmentno}");
    } catch (e) {
      setState(() {
        savesuccess = false;
      });
      print('⚠️ Error occurred while posting dispatch data: $e');
    } finally {
      print('savesuccess status: $savesuccess');
      if (savesuccess == true) {
        await _launchUrl(context);

        // Clear UI fields after all rows processed
        TransporterController.clear();
        DriverMobileNoController.clear();
        DriverController.clear();
        VehicleNoController.clear();
        TruckDimentionController.clear();
        LoadingChargeController.clear();
        MISCController.clear();
        TransportChargeController.clear();
        deliverAddressController.clear();
        tableData.clear();
        enteredProgressValues.clear();
      }
    }
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
                  onPressed: () async {
                    // Show the dialog while processing
                    showDialog(
                      context: context,
                      barrierDismissible: false, // Prevent dismissing manually
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
                      // Perform your tasks inside try block
                      // await fetchTokenwithCusid();

                      await postTruck_scan();
                      if (context.mounted) {
                        Navigator.pop(
                            context); // Close the "Processing..." dialog
                      }
                      await successfullysavednMessage();
                      if (context.mounted) {
                        Navigator.pop(
                            context); // Close the "Processing..." dialog
                      }
                    } catch (error) {
                      print("Error occurred: $error");

                      if (context.mounted) {
                        // Show error dialog if something goes wrong
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
                      // Always close the loading dialog once processing is complete
                      if (context.mounted) {
                        Navigator.pop(
                            context); // Close the "Processing..." dialog
                      }
                    }

                    // Optionally log the action
                    postLogData("Shipment Dispatch", "Save Dispatch");
                  },
                  child: Text("Yes"),
                ),
                SizedBox(
                  width: 8,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Closes the dialog
                  },
                  child: Text("No"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> successfullysavednMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginrole = prefs.getString('salesloginrole');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Row(
            children: [
              IconButton(
                icon:
                    const Icon(Icons.check_circle_rounded, color: Colors.green),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                'Successfully Saved !!',
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
            ],
          ),
        );
      },
    );
    if (context.mounted) {
      Navigator.pop(context); // Close the "Processing..." dialog
    }
    await widget.togglePage();
  }
}

class PrintPreviewTable extends StatefulWidget {
  final List<Map<String, dynamic>> enteredProgressValues;

  const PrintPreviewTable({Key? key, required this.enteredProgressValues})
      : super(key: key);

  @override
  _PrintPreviewTableState createState() => _PrintPreviewTableState();
}

class _PrintPreviewTableState extends State<PrintPreviewTable> {
  late List<TextEditingController> _progressControllers;
  late List<TextEditingController> _receivedControllers;
  late List<FocusNode> _progressFocusNodes;
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeControllers(widget.enteredProgressValues.length);
  }

  void _initializeControllers(int length) {
    _progressControllers =
        List.generate(length, (index) => TextEditingController(text: '0'));
    _receivedControllers =
        List.generate(length, (index) => TextEditingController(text: '0'));
    _progressFocusNodes = List.generate(length, (index) => FocusNode());

    for (int i = 0; i < length; i++) {
      final item = widget.enteredProgressValues[i];
      _progressControllers[i].text = item['progressQty']?.toString() ?? '0';
      _receivedControllers[i].text = item['receivedQty']?.toString() ?? '0';
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    for (var controller in _progressControllers) {
      controller.dispose();
    }
    for (var controller in _receivedControllers) {
      controller.dispose();
    }
    for (var node in _progressFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTableData = widget.enteredProgressValues.where((data) {
      var shippedQty = data['quantity_shipped'];
      return shippedQty != null && shippedQty != 0;
    }).toList();

    final totalWidth = 50.0 + // S.No
        120.0 +
        // 120.0 +
        // 100.0 + // Item ID
        MediaQuery.of(context).size.width * 0.25 + // Description
        120.0 + // Shipped Qty
        100.0; // Received

    return SizedBox(
      // height: MediaQuery.of(context).size.height * 0.3,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalWidth,
              child: Column(
                children: [
                  // Table Header
                  Container(
                    width: totalWidth,
                    height: 30,
                    child: Row(
                      children: [
                        _buildTableHeader("S.No", 50),
                        // _buildTableHeader("From.Org.Id", 100),
                        // _buildTableHeader("To.Org.Id", 120),
                        _buildTableHeader("Item Code", 120),
                        _buildTableHeader("Description",
                            MediaQuery.of(context).size.width * 0.25),
                        _buildTableHeader("Qty.shipped", 100),
                        _buildTableHeader("Qty.Dispatched", 120),
                      ],
                    ),
                  ),
                  // Table Body
                  SizedBox(
                    width: totalWidth,
                    height: (MediaQuery.of(context).size.height * 0.5) - 30,
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (int index = 0;
                            index < filteredTableData.length;
                            index++)
                          _buildTableRow(filteredTableData[index], index),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> data, int index) {
    final rowColor = index % 2 == 0
        ? Color.fromARGB(224, 255, 255, 255)
        : Color.fromARGB(224, 240, 240, 240);

    return GestureDetector(
      onTap: () =>
          FocusScope.of(context).requestFocus(_progressFocusNodes[index]),
      child: Container(
        color: rowColor,
        height: 30,
        child: Row(
          children: [
            _buildTableCell((index + 1).toString(), 50),
            // _buildTableCell(data['from_organization_id'].toString(), 100),
            // _buildTableCell(data['to_orgn_id'].toString(), 120),
            _buildTableCell(data['item_code'].toString(), 120),
            _buildTableCell(data['description'].toString(),
                MediaQuery.of(context).size.width * 0.25),
            _buildTableCell(data['quantity_shipped'].toString(), 100),
            // Progress Qty
            SizedBox(
              width: 120,
              height: 30,
              child: TextField(
                focusNode: _progressFocusNodes[index],
                controller: _progressControllers[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onChanged: (value) {
                  final shipped =
                      int.tryParse(data['quantity_shipped'].toString()) ?? 0;
                  final progress = int.tryParse(value) ?? 0;
                  final originalReceived =
                      int.tryParse(_receivedControllers[index].text) ?? 0;
                  final newReceived = originalReceived + progress;

                  final qtyShippeddd = double.tryParse(
                          data['SYS_QUANTITY_SHIPPED']?.toString() ?? "0") ??
                      0;
                  final phyqtyshippeddds = double.tryParse(
                          data['PHY_QUANTITY_SHIPPED']?.toString() ?? "0") ??
                      0;

                  final allowedqty = qtyShippeddd - phyqtyshippeddds;

                  if (newReceived > shipped) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Quantity Exceeded"),
                        content: Text(
                            "Received quantity cannot exceed shipped quantity ($allowedqty)"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("OK"),
                          ),
                        ],
                      ),
                    );
                    _progressControllers[index].text = '0';
                    _receivedControllers[index].text =
                        originalReceived.toString();
                    return;
                  }
                  _receivedControllers[index].text = newReceived.toString();
                  setState(() {});
                },
                onSubmitted: (value) {
                  final nextIndex =
                      (index + 1) % widget.enteredProgressValues.length;
                  FocusScope.of(context)
                      .requestFocus(_progressFocusNodes[nextIndex]);
                },
              ),
            ),
            // Received Qty
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String title, double width) {
    return Container(
      width: width,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, double width) {
    return Container(
      width: width,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
