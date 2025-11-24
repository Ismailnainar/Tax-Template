import 'dart:io'; // for File
import 'package:aljeflutterapp/Reports/CustomerWise_excelexport.dart';
import 'package:aljeflutterapp/Reports/InvoiceWise_excelexport.dart';
import 'package:aljeflutterapp/Reports/InvoiceWise_excelexport_NET.dart';
import 'package:aljeflutterapp/Reports/newtabledesign.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:path_provider/path_provider.dart'; // for getApplicationDocumentsDirectory
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

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;

class invoicedetialsreports extends StatefulWidget {
  const invoicedetialsreports({super.key});
  @override
  State<invoicedetialsreports> createState() => _invoicedetialsreportsState();
}

class _invoicedetialsreportsState extends State<invoicedetialsreports> {
  final TextEditingController salesmanIdController = TextEditingController();

  List<Map<String, dynamic>> filteredData = [];
  bool _isLoadingData = true;

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  bool Fromdatebool = false;
  bool TodateBool = false;
  bool ParametertypeBool = false;
  bool Parametervaluebool = false;
  bool searchbuttonbool = false;
  bool exportbuttonbool = false;
  bool overallexportbuttonbool = false;

  List<String> typeList = [];
  @override
  void initState() {
    super.initState();
    _loadSalesmanName();
    // fetchInvoicedetailsData();

    postLogData("Report", "Opened");
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
    postLogData("Report", "Closed");
  }

  FocusNode ParametertypeFocusnode = FocusNode();

  FocusNode ParameterExportedFocusnode = FocusNode();
  List<Map<String, dynamic>> invoicedetailstabledata =
      []; // List to store fetched data
  // Future<void> fetchInvoicedetailsData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String salesmanno = prefs.getString('salesloginno') ?? 'Unknown ID';
  //   String salesloginrole = prefs.getString('salesloginrole') ?? 'Unknown ID';
  //   String salesmanstatus =
  //       salesloginrole == 'Salesman' ? '?salesmanno=$salesmanno' : '';

  //   final IpAddress = await getActiveIpAddress();

  //   List<Map<String, dynamic>> allData = []; // To store all fetched data
  //   String? nextUrl = '$IpAddress/Rport_Undelivery_data/$salesmanstatus';
  //   print("nextUrlllllllllllll  $nextUrl");
  //   try {
  //     while (nextUrl != null) {
  //       final response = await http.get(Uri.parse(nextUrl));

  //       if (response.statusCode == 200) {
  //         var decodedData = json.decode(response.body);

  //         if (decodedData is Map<String, dynamic> &&
  //             decodedData.containsKey('results')) {
  //           // Append results to allData
  //           allData.addAll(
  //               List<Map<String, dynamic>>.from(decodedData['results']));

  //           // Get next page URL (could be null)
  //           nextUrl = decodedData['next'];
  //         } else {
  //           print('Invalid response format or missing "results" key.');
  //           break;
  //         }
  //       } else {
  //         throw Exception('Failed to load data from $nextUrl');
  //       }
  //     }

  //     // Update UI after fetching all data
  //     setState(() {
  //       invoicedetailstabledata = allData;
  //       isLoading = false;
  //     });

  //     print('Fetched all pages. Total records: ${allData.length}');
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     print('Error fetching data: $e');
  //   }
  // }

  // Future<void> fetchInvoicedetailsData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String salesmanno = prefs.getString('salesloginno') ?? 'Unknown ID';
  //   String salesloginrole = prefs.getString('salesloginrole') ?? 'Unknown ID';
  //   String salesmanstatus =
  //       salesloginrole == 'Salesman' ? '?salesmanno=$salesmanno' : '';

  //   final IpAddress = await getActiveIpAddress();

  //   List<Map<String, dynamic>> allData = []; // To store all fetched data
  //   String? nextUrl = '$IpAddress/Rport_Undelivery_data/$salesmanstatus';

  //   print("Fetching data from: $nextUrl");

  //   // Show the loading dialog
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         content: Row(
  //           children: [
  //             CircularProgressIndicator(),
  //             SizedBox(width: 20),
  //             Text("Processing... Kindly wait"),
  //           ],
  //         ),
  //       );
  //     },
  //   );

  //   try {
  //     while (nextUrl != null) {
  //       final response = await http.get(Uri.parse(nextUrl));

  //       if (response.statusCode == 200) {
  //         var decodedData = json.decode(response.body);

  //         if (decodedData is Map<String, dynamic> &&
  //             decodedData.containsKey('results')) {
  //           allData.addAll(
  //               List<Map<String, dynamic>>.from(decodedData['results']));
  //           nextUrl = decodedData['next'];
  //         } else {
  //           print('Invalid response format or missing "results" key.');
  //           break;
  //         }
  //       } else {
  //         throw Exception('Failed to load data from $nextUrl');
  //       }
  //     }

  //     setState(() {
  //       invoicedetailstabledata = allData;
  //       isLoading = false;
  //     });

  //     print('Fetched all pages. Total records: ${allData.length}');
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   } finally {
  //     Navigator.of(context).pop(); // Close the loading dialog
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }
  Future<void> fetchInvoicedetailsData(
      String parametertype, String parametervalue, String Status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String salesmanno = prefs.getString('salesloginno') ?? 'Unknown ID';
    String salesloginrole = prefs.getString('salesloginrole') ?? 'Unknown ID';
    String finalparameter = parametertype == 'Undel id'
        ? 'undelid=$parametervalue'
        : (parametertype == 'Customer Number'
            ? 'customerno=$parametervalue'
            : (parametertype == 'Invoice Number'
                ? 'invoiceno=$parametervalue'
                : 'salesmanno=$parametervalue'));
    String salesmanstatus = salesloginrole == 'Salesman'
        ? 'salesmanno=$salesmanno&$finalparameter'
        : '$finalparameter';

    final IpAddress = await getActiveIpAddress();

    // Construct first URL (add ? or & properly)
    String nextUrl =
        '$IpAddress/Rport_Undelivery_data/?status=$Status&$salesmanstatus';

    List<Map<String, dynamic>> allData = [];

    print("Start fetching paginated data... $nextUrl");

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
      while (nextUrl.isNotEmpty && nextUrl != "null") {
        print("Fetching page: $nextUrl");
        final response = await http.get(Uri.parse(nextUrl));

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);

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
        invoicedetailstabledata = allData;
        isLoading = false;
      });

      print("✅ All pages fetched. Total records: ${allData.length}");
      if (allData.length == 0)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No Data Found...'),
            backgroundColor: Colors.red,
          ),
        );
    } catch (e) {
      print("❌ Error while fetching data: $e");
    } finally {
      Navigator.of(context).pop(); // Close loading dialog
    }
  }

  List<Map<String, dynamic>> createdispatchinvoicedetailstabledata =
      []; // List to store fetched data
  Future<void> fetchCreateDispatchInvoicedetailsData(
      String quantity,
      String fromDateFormatted,
      String endDateFormatted,
      String parametertype,
      String parametervalue) async {
    // Show dialog before fetching data
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Processing...Getting data..."),
            ],
          ),
        );
      },
    );

    final IpAddress = await getActiveIpAddress();
    String addparamter = quantity != 'Quantity'
        ? '?from_date=$fromDateFormatted&to_date=$endDateFormatted'
        : '?filter_type=qtywise&from_date=$fromDateFormatted&to_date=$endDateFormatted';
    print("parametertype $parametertype");
    String finalparameter = parametertype == 'Undel id'
        ? 'undel_id'
        : (parametertype == 'Customer Number'
            ? 'customer_no'
            : (parametertype == 'Invoice Number'
                ? 'invoice_no'
                : (parametertype == 'Dispatch Number'
                    ? 'dispatch_id'
                    : 'salesman_no')));
    String parameterss =
        finalparameter.isEmpty ? '' : '&$finalparameter=$parametervalue';

    List<Map<String, dynamic>> allData = [];
    String? nextUrl =
        '$IpAddress/Rport_Create_dispatch/$addparamter$parameterss';
    print("nextUrlaaaa $nextUrl");
    try {
      while (nextUrl != null) {
        final response = await http.get(Uri.parse(nextUrl));

        if (response.statusCode == 200) {
          var decodedData = json.decode(response.body);

          if (decodedData is Map<String, dynamic> &&
              decodedData.containsKey('results')) {
            allData.addAll(
                List<Map<String, dynamic>>.from(decodedData['results']));
            nextUrl = decodedData['next'];
          } else {
            print('Invalid response format or missing "results" key.');
            break;
          }
        } else {
          throw Exception('Failed to load data from $nextUrl');
        }
      }

      // Update UI
      setState(() {
        createdispatchinvoicedetailstabledata = allData;
        isLoading = false;
      });
      if (createdispatchinvoicedetailstabledata.isEmpty)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No data Found...'),
            backgroundColor: Colors.red,
          ),
        );
      print('Fetched all pages. Total records: ${allData.length}');
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    } finally {
      // Close the dialog
      Navigator.of(context).pop();
    }
  }

  List<Map<String, dynamic>> Invoice_Return_TableDatas =
      []; // List to store fetched data
  Future<void> fetch_return_Invoice_Tabledatas(
      String quantity,
      String fromDateFormatted,
      String endDateFormatted,
      String parametertype,
      String parametervalue) async {
    // Show dialog before fetching data
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Processing...Getting data..."),
            ],
          ),
        );
      },
    );

    final IpAddress = await getActiveIpAddress();
    String addparamter = quantity != 'Quantity'
        ? '?from_date=$fromDateFormatted&to_date=$endDateFormatted'
        : '?filter_type=qtywise&from_date=$fromDateFormatted&to_date=$endDateFormatted';
    print("parametertype $parametertype");
    String finalparameter = parametertype == 'Undel id'
        ? 'undel_id'
        : (parametertype == 'Customer Number'
            ? 'customer_no'
            : (parametertype == 'Invoice Number'
                ? 'invoice_no'
                : (parametertype == 'Dispatch Number'
                    ? 'dispatch_id'
                    : 'salesman_no')));
    String parameterss =
        finalparameter.isEmpty ? '' : '&$finalparameter=$parametervalue';

    List<Map<String, dynamic>> allData = [];
    String? nextUrl =
        '$IpAddress/Return_Dispatch_Report_Data/$addparamter$parameterss';
    print("nextUrlaaaa $nextUrl");
    try {
      while (nextUrl != null) {
        final response = await http.get(Uri.parse(nextUrl));

        if (response.statusCode == 200) {
          var decodedData = json.decode(response.body);

          if (decodedData is Map<String, dynamic> &&
              decodedData.containsKey('results')) {
            allData.addAll(
                List<Map<String, dynamic>>.from(decodedData['results']));
            nextUrl = decodedData['next'];
          } else {
            print('Invalid response format or missing "results" key.');
            break;
          }
        } else {
          throw Exception('Failed to load data from $nextUrl');
        }
      }

      // Update UI
      setState(() {
        Invoice_Return_TableDatas = allData;
        isLoading = false;
      });
      if (Invoice_Return_TableDatas.isEmpty)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No data Found...'),
            backgroundColor: Colors.red,
          ),
        );
      print('Fetched all pages. Total records: ${allData.length}');
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    } finally {
      // Close the dialog
      Navigator.of(context).pop();
    }
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
    print('saveloginrole $saveloginrole');

    if (saveloginrole == 'Salesman') {
      ExportedList = [
        "Pending Undelivered Report",
        "Completed Delivery Report",
        "Dispatch Details - Customerwise",
        "Dispatch Details - InvoiceNowise",
        "Invoice Return Report"
      ];
    } else {
      ExportedList = [
        "Overall Undelivered Report",
        "Pending Undelivered Report",
        "Completed Delivery Report",
        "Delivered Inv Details - Qty",
        "Delivered Inv Details - Value",
        "Dispatch Details - Customerwise",
        "Dispatch Details - InvoiceNowise",
        "Dispatch Details - InvoiceNowise(NET AMOUNT)",
        "Invoice Return Report"
      ];
    }
    if (saveloginrole != 'Salesman')
      typeList = getTypeList(ExportedController.text); // ✅ set here
    if (saveloginrole == 'Salesman')
      typeList = SalesmangetTypeList(ExportedController.text); // ✅ set here
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

  TextEditingController InvoiceStatusController = TextEditingController();
  TextEditingController ColumnNameController = TextEditingController();
  TextEditingController ColumnValueController = TextEditingController();
  TextEditingController SearchButtonController = TextEditingController();
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

  FocusNode InvoiceStatusFocusNode = FocusNode();
  FocusNode SalesmanNodFocusNode = FocusNode();
  FocusNode ColumnNameFocusNode = FocusNode();
  FocusNode ColumnValueFocusNode = FocusNode();

  FocusNode FromdateFocusNode = FocusNode();
  FocusNode TodateFocusNode = FocusNode();
  FocusNode SearchButtonFocusNode = FocusNode();

  String? columnnameselectedValue;
  bool _filterEnabledcolumnname = true;
  int? _hoveredIndexcolumnname;
  int? _selectedIndexcolumnname;

  String? columnvalueselectedValue;
  bool _filterEnabledcolumnnvalue = true;
  int? _hoveredIndexcolumnvalue;
  int? _selectedIndexcolumnvalue;
  bool _isLoading = true;

  String? InvoicestatuselectedValue;
  bool _filterEnabledInvoicestatus = true;
  int? _hoveredIndexinvoicestatus;
  int? _selectedIndexInvoicestatus;

  List<String> invoicestatus = ["pending", "ongoing", "finished"];

  List<String> columnHeaders = [];

  Future<void> fetchColumnHeaders(String invoicestatusname) async {
    final IpAddress = await getActiveIpAddress();

    final columnUrl = Uri.parse(
        '$IpAddress/GetUndeliveredDataColumnNameview/$invoicestatusname/');
    print(
        "print the urlllllllll $IpAddress/GetUndeliveredDataColumnNameview/$invoicestatusname/");

    try {
      final response = await http.get(columnUrl);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          throw Exception("Column names list is empty.");
        }

        setState(() {
          columnHeaders = data.cast<String>();
          print("columnname $columnHeaders");
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load column headers: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching column headerssssssssssssssssssss: $e';
        isLoading = false;
      });
      print(errorMessage);
    }
  }

  Future<void> fetchColumnNamesList(String invoicestatus) async {
    final IpAddress = await getActiveIpAddress();

    print("invoce status : $invoicestatus");
    final String url =
        '$IpAddress/GetUndeliveredDataColumnNameview/$invoicestatus/';
    print("print the urlll $url");

    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    // Show processing dialog
    _showProcessingDialog();

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Check if the data is a list and contains elements
        if (data is List && data.isNotEmpty) {
          // Assuming the response is a list of column names
          List<String> tempColumnNames = List<String>.from(data);
          setState(() {
            ColumnNameList = tempColumnNames;
            // isLoading = false;
          });
        } else {
          print('No column names found in the response');
          setState(() {
            // isLoading = false;
          });
        }
      } else {
        print('Error: ${response.statusCode}');
        setState(() {
          // isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching column names: $e');
      setState(() {
        // isLoading = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        // Close the processing dialog
        Navigator.of(context, rootNavigator: true).pop();
        FocusScope.of(context).requestFocus(ColumnNameFocusNode);
      }
    }
  }

  bool _isProcessing = false; // Flag to track if the operation is ongoing
  Future<void> fetchColumnValueList(
      String invoicestatus, String columnanametext) async {
    String columnname = ColumnNameController.text;
    print("columnname :$invoicestatus $columnname  $columnanametext");

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
        var data = json.decode(response.body);

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
      FocusScope.of(context).requestFocus(ColumnValueFocusNode);
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

  Widget _buildInvoiceStatusDropdown() {
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
                          ? screenWidth * 0.12
                          : screenWidth * 0.4,
                      child: invoicestatusDropdown()),
                ],
              ),
            ),
            SizedBox(width: 3),
          ],
        ),
      ),
    );
  }

  Widget invoicestatusDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            int currentIndex =
                invoicestatus.indexOf(InvoiceStatusController.text);
            if (currentIndex < invoicestatus.length - 1) {
              setState(() {
                _selectedIndexInvoicestatus = currentIndex + 1;
                InvoiceStatusController.text =
                    invoicestatus[currentIndex + 1].split(':')[0];
                _filterEnabledcolumnname = false;
              });

              print(
                  "Selected InvoiceStatusController Name: ${InvoiceStatusController.text}");
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            int currentIndex =
                invoicestatus.indexOf(InvoiceStatusController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndexInvoicestatus = currentIndex - 1;
                InvoiceStatusController.text =
                    invoicestatus[currentIndex - 1].split(':')[0];
                _filterEnabledcolumnname = false;
              });
              print("Selected Column Name: ${InvoiceStatusController.text}");
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: InvoiceStatusFocusNode,
          controller: InvoiceStatusController,
          onSubmitted: (String? suggestion) async {
            print(
                "Column Name Controller Value: ${InvoiceStatusController.text}");
            setState(() {
              ColumnNameController.clear();
              ColumnValueController.clear();
            });
            fetchColumnNamesList(InvoiceStatusController.text);
            _fieldFocusChange(
                context, InvoiceStatusFocusNode, ColumnNameFocusNode);
          },
          decoration: InputDecoration(
            labelStyle: DropdownTextStyle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
            ),
            suffixIcon: Icon(Icons.keyboard_arrow_down, size: 18),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            filled: true,
            fillColor: Color.fromARGB(255, 255, 255, 255),
          ),
          style: DropdownTextStyle,
          onChanged: (text) {
            setState(() {
              _filterEnabledcolumnname = true;
              InvoicestatuselectedValue = text.isEmpty ? null : text;
            });
            print("Column Name Changed: $text");
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabledcolumnname && pattern.isNotEmpty) {
            return invoicestatus.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return invoicestatus;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = invoicestatus.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndexinvoicestatus = index),
            onExit: (_) => setState(() => _hoveredIndexinvoicestatus = null),
            child: Container(
              color: _selectedIndexInvoicestatus == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndexInvoicestatus == null &&
                          invoicestatus.indexOf(InvoiceStatusController.text) ==
                              index
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.transparent,
              height: 28,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
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
            constraints: BoxConstraints(maxHeight: 150)),
        onSuggestionSelected: (suggestion) async {
          print("Selected Suggestion: $suggestion");
          setState(() {
            ColumnNameController.clear();
            ColumnValueController.clear();
          });
          fetchColumnNamesList(suggestion);

          setState(() {
            InvoiceStatusController.text = suggestion.split(':')[0];
            InvoicestatuselectedValue = suggestion;
            _filterEnabledcolumnname = false;
            FocusScope.of(context).requestFocus(ColumnNameFocusNode);
          });
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('No Items Found!!!', style: DropdownTextStyle),
        ),
      ),
    );
  }

  Widget _buildColumnNameDropdown() {
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
                          ? screenWidth * 0.12
                          : screenWidth * 0.4,
                      child: ColumnNameDropdown()),
                ],
              ),
            ),
            SizedBox(width: 3),
          ],
        ),
      ),
    );
  }

  Widget ColumnNameDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            int currentIndex =
                ColumnNameList.indexOf(ColumnNameController.text);
            if (currentIndex < ColumnNameList.length - 1) {
              setState(() {
                _selectedIndexcolumnname = currentIndex + 1;
                ColumnNameController.text =
                    ColumnNameList[currentIndex + 1].split(':')[0];
                _filterEnabledcolumnname = false;
              });
              print("Selected Column Name: ${ColumnNameController.text}");
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            int currentIndex =
                ColumnNameList.indexOf(ColumnNameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndexcolumnname = currentIndex - 1;
                ColumnNameController.text =
                    ColumnNameList[currentIndex - 1].split(':')[0];
                _filterEnabledcolumnname = false;
              });
              print("Selected Column Name: ${ColumnNameController.text}");
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: ColumnNameFocusNode,
          controller: ColumnNameController,
          onSubmitted: (String? suggestion) async {
            print("Column Name Controller Value: ${ColumnNameController.text}");
            setState(() {
              ColumnValueController.clear();
            });
            fetchColumnValueList(
                InvoiceStatusController.text, ColumnNameController.text);
            _fieldFocusChange(
                context, ColumnNameFocusNode, ColumnValueFocusNode);
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
            suffixIcon: Icon(Icons.keyboard_arrow_down, size: 18),
          ),
          style: DropdownTextStyle,
          onChanged: (text) {
            setState(() {
              _filterEnabledcolumnname = true;
              columnnameselectedValue = text.isEmpty ? null : text;
            });
            print("Column Name Changed: $text");
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabledcolumnname && pattern.isNotEmpty) {
            return ColumnNameList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return ColumnNameList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = ColumnNameList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndexcolumnname = index),
            onExit: (_) => setState(() => _hoveredIndexcolumnname = null),
            child: Container(
              color: _selectedIndexcolumnname == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndexcolumnname == null &&
                          ColumnNameList.indexOf(ColumnNameController.text) ==
                              index
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.transparent,
              height: 28,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
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
            constraints: BoxConstraints(maxHeight: 150)),
        onSuggestionSelected: (suggestion) async {
          print("Selected Suggestion: $suggestion");
          setState(() {
            ColumnValueController.clear();
          });
          fetchColumnValueList(InvoiceStatusController.text, suggestion);

          setState(() {
            ColumnNameController.text = suggestion.split(':')[0];
            columnnameselectedValue = suggestion;
            _filterEnabledcolumnname = false;
            FocusScope.of(context).requestFocus(ColumnValueFocusNode);
          });
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('No Items Found!!!', style: DropdownTextStyle),
        ),
      ),
    );
  }

  Widget _buildColumnValuesDropdown() {
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
                          ? screenWidth * 0.12
                          : screenWidth * 0.4,
                      child: ColumnValueDropdown()),
                ],
              ),
            ),
            SizedBox(width: 3),
          ],
        ),
      ),
    );
  }

  Widget ColumnValueDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                ColumnvalueList.indexOf(ColumnValueController.text);
            if (currentIndex < ColumnvalueList.length - 1) {
              setState(() {
                _selectedIndexcolumnvalue = currentIndex + 1;
                // Take only the customer number part before the colon
                ColumnValueController.text =
                    ColumnvalueList[currentIndex + 1].split(':')[0];
                _filterEnabledcolumnnvalue = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                ColumnvalueList.indexOf(ColumnValueController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndexcolumnvalue = currentIndex - 1;
                // Take only the customer number part before the colon
                ColumnValueController.text =
                    ColumnvalueList[currentIndex - 1].split(':')[0];
                _filterEnabledcolumnnvalue = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: ColumnValueFocusNode,
          controller: ColumnValueController,
          onSubmitted: (String? suggestion) async {
            _fieldFocusChange(context, ColumnValueFocusNode, FromdateFocusNode);
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
            suffixIcon: Icon(Icons.keyboard_arrow_down, size: 18),
          ),
          style: DropdownTextStyle,
          onChanged: (text) {
            setState(() {
              _filterEnabledcolumnnvalue = true;
              columnvalueselectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabledcolumnnvalue && pattern.isNotEmpty) {
            return ColumnvalueList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return ColumnvalueList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = ColumnvalueList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndexcolumnvalue = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndexcolumnvalue = null;
            }),
            child: Container(
              color: _selectedIndexcolumnvalue == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndexcolumnvalue == null &&
                          ColumnvalueList.indexOf(ColumnValueController.text) ==
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
        onSuggestionSelected: (suggestion) async {
          setState(() {
            // Take only the customer number part before the colon
            ColumnValueController.text = suggestion.split(':')[0];
            columnvalueselectedValue = suggestion;
            _filterEnabledcolumnnvalue = false;

            FocusScope.of(context).requestFocus(FromdateFocusNode);
          });

          // await fetchInvoiceNumbers();
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

  String? invoicestatusname, columnName, columnValue, fromDate, endDate;

  // Add this variable to track if search was clicked
  bool _hasSearched = false;

  List<String> getTypeList(String text) {
    if (text == "Overall Undelivered Report" ||
        text == "Pending Undelivered Report" ||
        text == "Completed Delivery Report") {
      return [
        // "Undel id",
        "Invoice Number",
        "Customer Number",
        "Salesman Number"
      ];
    } else if (text == "Delivered Inv Details - Qty" ||
        text == "Delivered Inv Details - Value" ||
        text == "Invoice Return Report") {
      return [
        // "Undel id",
        "Invoice Number",
        "Dispatch Number",
        "Customer Number",
        "Salesman Number"
      ];
    } else {
      return [
        // "Undel id",

        "Customer Number", "Salesman Number"
      ];
    }
  }

  List<String> SalesmangetTypeList(String text) {
    if (text == "Pending Undelivered Report" ||
        text == "Completed Delivery Report") {
      return ["Undel id", "Invoice Number", "Customer Number"];
    } else {
      return ["Undel id", "Customer Number"];
    }
  }

  bool _filterEnabledtype = true;
  int? _hoveredIndextype;
  int? _selectedIndextype;

  String? TypeSelectedValue;
  FocusNode TypeFocusNode = FocusNode();

  TextEditingController ParameterTypeController = TextEditingController();
  TextEditingController parametertypevalueController = TextEditingController();
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
            int currentIndex = typeList.indexOf(ParameterTypeController.text);
            if (currentIndex < typeList.length - 1) {
              setState(() {
                _selectedIndextype = currentIndex + 1;
                // Take only the customer number part before the colon
                ParameterTypeController.text =
                    typeList[currentIndex + 1].split(':')[0];
                _filterEnabledtype = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = typeList.indexOf(ParameterTypeController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndextype = currentIndex - 1;
                // Take only the customer number part before the colon
                ParameterTypeController.text =
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
          controller: ParameterTypeController,
          onSubmitted: (String? suggestion) async {
            _fieldFocusChange(context, TypeFocusNode, ParametertypeFocusnode);
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
                          typeList.indexOf(ParameterTypeController.text) ==
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
          setState(() {
            _selectedIndextype = typeList.indexOf(suggestion);
            // Take only the customer number part before the colon
            ParameterTypeController.text = suggestion.split(':')[0];
            TypeSelectedValue = suggestion;
            _filterEnabledtype = false;
          });

          _fieldFocusChange(context, TypeFocusNode, ParametertypeFocusnode);
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

  // List<String> ExportedList = [
  //   "Overall Undelivered Report",
  //   "Pending Undelivered Report",
  //   "Completed Delivery Report",
  //   "Delivered Inv Details - Qty",
  //   "Delivered Inv Details - Value",
  //   "Dispatch Details - Customerwise"
  // ];

  List<String> ExportedList = [];

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
                          ? screenWidth * 0.17
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
            Fromdatebool = false;
            TodateBool = false;
            ParametertypeBool = false;
            Parametervaluebool = false;
            searchbuttonbool = false;
            exportbuttonbool = false;
            overallexportbuttonbool = false;
            setState(() {
              _FromdateController.text =
                  DateFormat('dd-MMM-yyyy').format(DateTime.now());
              _EnddateController.text =
                  DateFormat('dd-MMM-yyyy').format(DateTime.now());
              ParameterTypeController.clear();
              parametertypevalueController.clear();
              if (ExportedController.text == 'Overall Undelivered Report' ||
                  ExportedController.text == 'Pending Undelivered Report' ||
                  ExportedController.text == 'Completed Delivery Report') {
                // Fromdatebool = true;
                // TodateBool = true;
                ParametertypeBool = true;
                Parametervaluebool = true;
                // searchbuttonbool = true;
                exportbuttonbool = true;
              } else if (ExportedController.text ==
                      'Delivered Inv Details - Qty' ||
                  ExportedController.text == 'Delivered Inv Details - Value' ||
                  ExportedController.text == 'Invoice Return Report') {
                Fromdatebool = true;
                TodateBool = true;
                ParametertypeBool = true;
                Parametervaluebool = true;
                exportbuttonbool = true;
              } else if (ExportedController.text ==
                  'Dispatch Details - Customerwise') {
                Fromdatebool = true;
                TodateBool = true;
                ParametertypeBool = true;
                Parametervaluebool = true;
                searchbuttonbool = true;
                exportbuttonbool = true;
              } else if (ExportedController.text ==
                  'Dispatch Details - InvoiceNowise') {
                Fromdatebool = true;
                TodateBool = true;
                ParametertypeBool = true;
                Parametervaluebool = true;
                searchbuttonbool = true;
                exportbuttonbool = true;
              } else if (ExportedController.text ==
                  'Dispatch Details - InvoiceNowise(NET AMOUNT)') {
                Fromdatebool = true;
                TodateBool = true;
                ParametertypeBool = true;
                Parametervaluebool = true;
                searchbuttonbool = true;
                exportbuttonbool = true;
              }

              if (saveloginrole != 'Salesman')
                typeList = getTypeList(ExportedController.text); // ✅ set here
              if (saveloginrole == 'Salesman')
                typeList =
                    SalesmangetTypeList(ExportedController.text); // ✅ set here
            });
            _fieldFocusChange(
                context, ExportedFocusNode, ParameterExportedFocusnode);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 7.0, horizontal: 10.0),
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
              height: 26,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                dense: true,
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Tooltip(
                      message: suggestion,
                      child: Text(suggestion, style: TextStyle(fontSize: 11))),
                ),
              ),
            ),
          );
        },
        suggestionsBoxDecoration: const SuggestionsBoxDecoration(
          constraints: BoxConstraints(maxHeight: 240),
        ),
        onSuggestionSelected: (suggestion) {
          setState(() {
            _selectedIndexExported = ExportedList.indexOf(suggestion);
            // Take only the customer number part before the colon
            ExportedController.text = suggestion.split(':')[0];
            ExportedSelectedValue = suggestion;
            _filterEnabledexported = false;
          });
          setState(() {
            _FromdateController.text =
                DateFormat('dd-MMM-yyyy').format(DateTime.now());
            _EnddateController.text =
                DateFormat('dd-MMM-yyyy').format(DateTime.now());
            ParameterTypeController.clear();
            parametertypevalueController.clear();
            Fromdatebool = false;
            TodateBool = false;
            ParametertypeBool = false;
            Parametervaluebool = false;
            searchbuttonbool = false;
            exportbuttonbool = false;
            overallexportbuttonbool = false;
            if (ExportedController.text == 'Overall Undelivered Report' ||
                ExportedController.text == 'Pending Undelivered Report' ||
                ExportedController.text == 'Completed Delivery Report') {
              // Fromdatebool = true;
              // TodateBool = true;
              ParametertypeBool = true;
              Parametervaluebool = true;
              // searchbuttonbool = true;
              exportbuttonbool = true;
            } else if (ExportedController.text ==
                    'Delivered Inv Details - Qty' ||
                ExportedController.text == 'Delivered Inv Details - Value' ||
                ExportedController.text == 'Invoice Return Report') {
              Fromdatebool = true;
              TodateBool = true;
              ParametertypeBool = true;
              Parametervaluebool = true;
              exportbuttonbool = true;
            } else if (ExportedController.text ==
                'Dispatch Details - Customerwise') {
              Fromdatebool = true;
              TodateBool = true;
              ParametertypeBool = true;
              Parametervaluebool = true;
              searchbuttonbool = true;
              exportbuttonbool = true;
            } else if (ExportedController.text ==
                'Dispatch Details - InvoiceNowise') {
              Fromdatebool = true;
              TodateBool = true;
              ParametertypeBool = true;
              Parametervaluebool = true;
              searchbuttonbool = true;
              exportbuttonbool = true;
            } else if (ExportedController.text ==
                'Dispatch Details - InvoiceNowise(NET AMOUNT)') {
              Fromdatebool = true;
              TodateBool = true;
              ParametertypeBool = true;
              Parametervaluebool = true;
              searchbuttonbool = true;
              exportbuttonbool = true;
            }

            if (saveloginrole != 'Salesman')
              typeList = getTypeList(ExportedController.text); // ✅ set here
            if (saveloginrole == 'Salesman')
              typeList =
                  SalesmangetTypeList(ExportedController.text); // ✅ set here
          });

          _fieldFocusChange(
              context, ExportedFocusNode, ParameterExportedFocusnode);
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: TextStyle(fontSize: 11),
          ),
        ),
      ),
    );
  }

  String? salesmanName;
  String? errorMessage;
  Future<String?> fetchSalesmanName(String salesmanNo) async {
    try {
      final IpAddress = await getActiveIpAddress();
      final url =
          Uri.parse("$IpAddress/get-salesman-name/?salesman_no=$salesmanNo");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['salesman_name']; // ✅ Return only the name
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

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
                                  Icons.bar_chart,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Report',
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
                                width: Responsive.isDesktop(context) ? 10 : 0,
                              ),
                              // _buildTextFieldDesktop(
                              //     'Salesman No',
                              //     "${salesloginno}",
                              //     Icons.numbers,
                              //     true,
                              //     SalesmanNodFocusNode,
                              //     ColumnNameFocusNode),
                              // SizedBox(
                              //   width: 10,
                              // ),
                              // Container(
                              //   width: Responsive.isDesktop(context)
                              //       ? MediaQuery.of(context).size.width * 0.12
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
                              //             Text("Invoice Status",
                              //                 style: textboxheading),
                              //             Icon(
                              //               Icons.star,
                              //               size: 8,
                              //               color: Colors.red,
                              //             )
                              //           ],
                              //         ),
                              //         const SizedBox(height: 1),
                              //         Padding(
                              //           padding: const EdgeInsets.only(
                              //               left: 0, bottom: 0),
                              //           child: Container(
                              //               child:
                              //                   _buildInvoiceStatusDropdown()),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(
                              //   width: 10,
                              // ),
                              // Container(
                              //   width: Responsive.isDesktop(context)
                              //       ? MediaQuery.of(context).size.width * 0.12
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
                              //             Text("Column Name ",
                              //                 style: textboxheading),
                              //             Icon(
                              //               Icons.star,
                              //               size: 8,
                              //               color: Colors.red,
                              //             )
                              //           ],
                              //         ),
                              //         const SizedBox(height: 1),
                              //         Padding(
                              //           padding: const EdgeInsets.only(
                              //               left: 0, bottom: 0),
                              //           child: Container(
                              //               child: _buildColumnNameDropdown()),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(
                              //   width: 10,
                              // ),
                              // Container(
                              //   width: Responsive.isDesktop(context)
                              //       ? MediaQuery.of(context).size.width * 0.12
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
                              //             Text("Column Value ",
                              //                 style: textboxheading),
                              //             Icon(
                              //               Icons.star,
                              //               size: 8,
                              //               color: Colors.red,
                              //             )
                              //           ],
                              //         ),
                              //         const SizedBox(height: 1),
                              //         Padding(
                              //           padding: const EdgeInsets.only(
                              //               left: 0, bottom: 0),
                              //           child: Container(
                              //               child:
                              //                   _buildColumnValuesDropdown()),
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
                                    ? screenWidth * 0.17
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
                                                Text("Exported Reports",
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
                                                _buildSearchExportedDropdown()),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              if (Fromdatebool)
                                Container(
                                  width: Responsive.isDesktop(context)
                                      ? MediaQuery.of(context).size.width * 0.1
                                      : MediaQuery.of(context).size.width * 0.4,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Text("From Date ",
                                                style: textboxheading),
                                            Icon(
                                              Icons.star,
                                              size: 8,
                                              color: Colors.red,
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 0, bottom: 0),
                                          child: Container(
                                            height: 32,
                                            child: TextFormField(
                                              controller: _FromdateController,
                                              focusNode: FromdateFocusNode,
                                              onFieldSubmitted: (_) =>
                                                  _fieldFocusChange(
                                                      context,
                                                      FromdateFocusNode,
                                                      TodateFocusNode),

                                              onTap: () => _selectfromDate(
                                                  context), // Open the date picker when tapped
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    Icon(Icons.calendar_month),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(0),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 5.0),
                                              ),
                                              style: commonLabelTextStyle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (Fromdatebool)
                                SizedBox(
                                  width: 10,
                                ),
                              if (TodateBool)
                                Container(
                                  width: Responsive.isDesktop(context)
                                      ? MediaQuery.of(context).size.width * 0.1
                                      : MediaQuery.of(context).size.width * 0.4,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Text("To Date ",
                                                style: textboxheading),
                                            Icon(
                                              Icons.star,
                                              size: 8,
                                              color: Colors.red,
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 0, bottom: 0),
                                          child: Container(
                                            height: 32,
                                            child: TextFormField(
                                              controller: _EnddateController,
                                              focusNode: TodateFocusNode,
                                              onFieldSubmitted: (_) =>
                                                  _fieldFocusChange(
                                                      context,
                                                      TodateFocusNode,
                                                      SearchButtonFocusNode),

                                              readOnly: true,
                                              onTap: () => _selectendDate(
                                                  context), // Open the date picker when tapped
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    Icon(Icons.calendar_month),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(0),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 5.0),
                                              ),
                                              style: commonLabelTextStyle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (TodateBool)
                                SizedBox(
                                  width: 10,
                                ),
                              if (ParametertypeBool)
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
                                          padding:
                                              const EdgeInsets.only(top: 0),
                                          child: Row(
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.list,
                                                      size: 14,
                                                      color: Colors.blue[600]),
                                                  SizedBox(width: 8),
                                                  Text("Parameter Type ",
                                                      style: textboxheading),
                                                  SizedBox(width: 8),
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
                                        const SizedBox(height: 1),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 0, bottom: 0),
                                          child: Container(
                                              child:
                                                  _buildSearchTypeDropdown()),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (ParametertypeBool)
                                SizedBox(
                                  width: 10,
                                ),
                              if (Parametervaluebool)
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
                                            Text("Parameter Type",
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
                                                      decoration:
                                                          InputDecoration(
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                Color.fromARGB(
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
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    58,
                                                                    58,
                                                                    58),
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
                                                          parametertypevalueController,
                                                      focusNode:
                                                          ParametertypeFocusnode,
                                                      // onFieldSubmitted: (_) {
                                                      //   _fieldFocusChange(
                                                      //       context,
                                                      //       ParametertypeFocusnode,
                                                      //       Searchbuttonfocusnode);
                                                      // },
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
                              if (Parametervaluebool)
                                SizedBox(
                                  width: 10,
                                ),
                              if (searchbuttonbool)
                                Padding(
                                  padding: EdgeInsets.only(top: 45),
                                  child: SizedBox(
                                    height: 30,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        DateTime fromDateParsed =
                                            DateFormat('dd-MMM-yyyy').parse(
                                                _FromdateController.text);
                                        DateTime endDateParsed =
                                            DateFormat('dd-MMM-yyyy')
                                                .parse(_EnddateController.text);

                                        if (endDateParsed
                                            .isBefore(fromDateParsed)) {
                                          await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text("Invalid Date"),
                                                content: Text(
                                                    "Kindly check the from date and end date."),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _EnddateController
                                                            .text = DateFormat(
                                                                'dd-MMM-yyyy')
                                                            .format(
                                                                DateTime.now());
                                                        Navigator.of(context)
                                                            .pop();
                                                      });
                                                    },
                                                    child: Text("OK"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else {
                                          setState(() {
                                            _hasSearched =
                                                false; // Reset _hasSearched
                                          });

                                          await Future.delayed(Duration(
                                              milliseconds:
                                                  100)); // Small delay to allow state update

                                          setState(() {
                                            columnName =
                                                ColumnNameController.text;
                                            columnValue =
                                                ColumnValueController.text;
                                            fromDate = _FromdateController.text;
                                            endDate = _EnddateController.text;
                                            _hasSearched =
                                                true; // Set _hasSearched to true again
                                          });

                                          print("Search clicked with:");
                                          print("Column name: $columnName");
                                          print("Column Value: $columnValue");
                                          print("From date: $fromDate");
                                          print("End date: $endDate");
                                        }

                                        postLogData("Report Invoice Filtered",
                                            "Search");
                                      },
                                      icon: Icon(Icons.search,
                                          color: Colors.white),
                                      label: Text(
                                        '',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: buttonColor,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (searchbuttonbool)
                                SizedBox(
                                  width: 10,
                                ),
                              if (exportbuttonbool)
                                Padding(
                                  padding: EdgeInsets.only(top: 45),
                                  child: SizedBox(
                                    height: 30,
                                    child: Tooltip(
                                      message: (ExportedController.text ==
                                                  'Dispatch Details - Customerwise' &&
                                              ExportedController.text ==
                                                  "Dispatch Details - InvoiceNowise")
                                          ? "Dispatch Report"
                                          : ((ExportedController.text ==
                                                  'Overall Undelivered Report')
                                              ? "Overall Undelivered Report"
                                              : ((ExportedController.text ==
                                                      'Delivered Inv Details - Qty')
                                                  ? "Delivered Inv Details - Qty"
                                                  : (ExportedController.text ==
                                                          'Pending Undelivered Report')
                                                      ? "Pending Undelivered Report"
                                                      : (ExportedController
                                                                  .text ==
                                                              'Completed Delivery Report')
                                                          ? "Completed Delivery Report"
                                                          : ExportedController
                                                                      .text ==
                                                                  'Dispatched Inv Details'
                                                              ? "Dispatched Inv Details"
                                                              : "Invoice Return Report")),
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          if (parametertypevalueController.text
                                                  .trim()
                                                  .isEmpty &&
                                              ParameterTypeController.text
                                                  .trim()
                                                  .isNotEmpty) {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text("Warning"),
                                                  content: const Text(
                                                    "Kindly fill both fields before exporting. Export is not allowed when only one field is entered.",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child: const Text("OK"),
                                                      onPressed: () {
                                                        setState(() {
                                                          parametertypevalueController
                                                              .clear();
                                                          ParameterTypeController
                                                              .clear();
                                                        });
                                                        Navigator.of(context)
                                                            .pop(); // close dialog
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else if (parametertypevalueController
                                                  .text
                                                  .trim()
                                                  .isNotEmpty &&
                                              ParameterTypeController.text
                                                  .trim()
                                                  .isEmpty) {
                                            showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text("Warning"),
                                                  content: const Text(
                                                    "Kindly fill both fields before exporting. Export is not allowed when only one field is entered.",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child: const Text("OK"),
                                                      onPressed: () {
                                                        setState(() {
                                                          parametertypevalueController
                                                              .clear();
                                                          ParameterTypeController
                                                              .clear();
                                                        });
                                                        Navigator.of(context)
                                                            .pop(); // close dialog
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else {
                                            if (ExportedController.text ==
                                                'Dispatch Details - Customerwise') {
                                              if (_FromdateController
                                                      .text.isEmpty ||
                                                  _EnddateController
                                                      .text.isEmpty) {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          "Missing Information"),
                                                      content: Text(
                                                          "Please fill in all required fields."),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          child: Text("OK"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                                return;
                                              }

                                              final inputFormat = DateFormat(
                                                  'dd-MMM-yyyy'); // to parse '10-Jul-2025'
                                              final outputFormat = DateFormat(
                                                  'yyyy-MM-dd'); // to format as '2025-07-10'
                                              String fromDateFormatted = '';
                                              String endDateFormatted = '';
                                              DateTime fromDateParsed =
                                                  inputFormat.parse(
                                                      _FromdateController.text);
                                              DateTime endDateParsed =
                                                  inputFormat.parse(
                                                      _EnddateController.text);

                                              fromDateFormatted = outputFormat
                                                  .format(fromDateParsed);
                                              endDateFormatted = outputFormat
                                                  .format(endDateParsed);
                                              if (ParameterTypeController.text
                                                      .trim()
                                                      .isEmpty &&
                                                  parametertypevalueController
                                                      .text
                                                      .trim()
                                                      .isEmpty) {
                                                // ✅ Both empty → allow normal flow
                                                exportGroupedTruckScanDetails(
                                                  context,
                                                  fromDateFormatted,
                                                  endDateFormatted,
                                                  ParameterTypeController.text,
                                                  "", // since both empty, send empty string
                                                );
                                              } else if (ParameterTypeController
                                                      .text
                                                      .trim()
                                                      .isEmpty ||
                                                  parametertypevalueController
                                                      .text
                                                      .trim()
                                                      .isEmpty) {
                                                // ❌ One is empty, one is not → show error
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          "Kindly fill both fields")),
                                                );
                                              } else {
                                                // ✅ Both filled → your existing logic
                                                String sendvalues;
                                                if (ParameterTypeController.text
                                                        .trim() ==
                                                    'Salesman Number') {
                                                  sendvalues =
                                                      (await fetchSalesmanName(
                                                            parametertypevalueController
                                                                .text
                                                                .trim(),
                                                          )) ??
                                                          "";
                                                } else {
                                                  sendvalues =
                                                      parametertypevalueController
                                                          .text
                                                          .trim();
                                                }

                                                print(
                                                    "sendvaluessssssss $sendvalues");

                                                exportGroupedTruckScanDetails(
                                                  context,
                                                  fromDateFormatted,
                                                  endDateFormatted,
                                                  ParameterTypeController.text,
                                                  sendvalues,
                                                );
                                              }

                                              postLogData(
                                                  "Report Invoice Filtered",
                                                  "Export Dispatch Details - Customerwise");
                                            } else if (ExportedController
                                                    .text ==
                                                'Dispatch Details - InvoiceNowise') {
                                              if (_FromdateController
                                                      .text.isEmpty ||
                                                  _EnddateController
                                                      .text.isEmpty) {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          "Missing Information"),
                                                      content: Text(
                                                          "Please fill in all required fields."),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          child: Text("OK"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                                return;
                                              }

                                              final inputFormat = DateFormat(
                                                  'dd-MMM-yyyy'); // to parse '10-Jul-2025'
                                              final outputFormat = DateFormat(
                                                  'yyyy-MM-dd'); // to format as '2025-07-10'
                                              String fromDateFormatted = '';
                                              String endDateFormatted = '';
                                              DateTime fromDateParsed =
                                                  inputFormat.parse(
                                                      _FromdateController.text);
                                              DateTime endDateParsed =
                                                  inputFormat.parse(
                                                      _EnddateController.text);

                                              fromDateFormatted = outputFormat
                                                  .format(fromDateParsed);
                                              endDateFormatted = outputFormat
                                                  .format(endDateParsed);
                                              if (ParameterTypeController.text
                                                      .trim()
                                                      .isEmpty &&
                                                  parametertypevalueController
                                                      .text
                                                      .trim()
                                                      .isEmpty) {
                                                // ✅ Both empty → allow normal flow
                                                InvoiceWiseexportGroupedTruckScanDetails(
                                                  context,
                                                  fromDateFormatted,
                                                  endDateFormatted,
                                                  ParameterTypeController.text,
                                                  "", // since both empty, send empty string
                                                );
                                              } else if (ParameterTypeController
                                                      .text
                                                      .trim()
                                                      .isEmpty ||
                                                  parametertypevalueController
                                                      .text
                                                      .trim()
                                                      .isEmpty) {
                                                // ❌ One is empty, one is not → show error
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          "Kindly fill both fields")),
                                                );
                                              } else {
                                                // ✅ Both filled → your existing logic
                                                String sendvalues;
                                                if (ParameterTypeController.text
                                                        .trim() ==
                                                    'Salesman Number') {
                                                  sendvalues =
                                                      (await fetchSalesmanName(
                                                            parametertypevalueController
                                                                .text
                                                                .trim(),
                                                          )) ??
                                                          "";
                                                } else {
                                                  sendvalues =
                                                      parametertypevalueController
                                                          .text
                                                          .trim();
                                                }

                                                print(
                                                    "sendvaluessssssss $sendvalues");

                                                InvoiceWiseexportGroupedTruckScanDetails(
                                                  context,
                                                  fromDateFormatted,
                                                  endDateFormatted,
                                                  ParameterTypeController.text,
                                                  sendvalues,
                                                );
                                              }

                                              postLogData(
                                                  "Report Invoice Filtered",
                                                  "Export Dispatch Details - InvoiceNowise");
                                            } else if (ExportedController
                                                    .text ==
                                                'Dispatch Details - InvoiceNowise(NET AMOUNT)') {
                                              if (_FromdateController
                                                      .text.isEmpty ||
                                                  _EnddateController
                                                      .text.isEmpty) {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          "Missing Information"),
                                                      content: Text(
                                                          "Please fill in all required fields."),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          child: Text("OK"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                                return;
                                              }

                                              final inputFormat = DateFormat(
                                                  'dd-MMM-yyyy'); // to parse '10-Jul-2025'
                                              final outputFormat = DateFormat(
                                                  'yyyy-MM-dd'); // to format as '2025-07-10'
                                              String fromDateFormatted = '';
                                              String endDateFormatted = '';
                                              DateTime fromDateParsed =
                                                  inputFormat.parse(
                                                      _FromdateController.text);
                                              DateTime endDateParsed =
                                                  inputFormat.parse(
                                                      _EnddateController.text);

                                              fromDateFormatted = outputFormat
                                                  .format(fromDateParsed);
                                              endDateFormatted = outputFormat
                                                  .format(endDateParsed);
                                              if (ParameterTypeController.text
                                                      .trim()
                                                      .isEmpty &&
                                                  parametertypevalueController
                                                      .text
                                                      .trim()
                                                      .isEmpty) {
                                                // ✅ Both empty → allow normal flow
                                                InvoiceWiseexportGroupedTruckScanDetailsNETAMOUNT(
                                                  context,
                                                  fromDateFormatted,
                                                  endDateFormatted,
                                                  ParameterTypeController.text,
                                                  "", // since both empty, send empty string
                                                );
                                              } else if (ParameterTypeController
                                                      .text
                                                      .trim()
                                                      .isEmpty ||
                                                  parametertypevalueController
                                                      .text
                                                      .trim()
                                                      .isEmpty) {
                                                // ❌ One is empty, one is not → show error
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          "Kindly fill both fields")),
                                                );
                                              } else {
                                                // ✅ Both filled → your existing logic
                                                String sendvalues;
                                                if (ParameterTypeController.text
                                                        .trim() ==
                                                    'Salesman Number') {
                                                  sendvalues =
                                                      (await fetchSalesmanName(
                                                            parametertypevalueController
                                                                .text
                                                                .trim(),
                                                          )) ??
                                                          "";
                                                } else {
                                                  sendvalues =
                                                      parametertypevalueController
                                                          .text
                                                          .trim();
                                                }

                                                print(
                                                    "sendvaluessssssss $sendvalues");

                                                InvoiceWiseexportGroupedTruckScanDetailsNETAMOUNT(
                                                  context,
                                                  fromDateFormatted,
                                                  endDateFormatted,
                                                  ParameterTypeController.text,
                                                  sendvalues,
                                                );
                                              }

                                              postLogData(
                                                  "Report Invoice Filtered",
                                                  "Export Dispatch Details - InvoiceNowise(NET AMOUNT)");
                                            } else if (ExportedController
                                                    .text ==
                                                'Overall Undelivered Report') {
                                              String sendvalues;
                                              // if (ParameterTypeController.text
                                              //         .trim() ==
                                              //     'Salesman Number') {
                                              //   sendvalues =
                                              //       (await fetchSalesmanName(
                                              //             parametertypevalueController
                                              //                 .text
                                              //                 .trim(),
                                              //           )) ??
                                              //           "";
                                              // } else {
                                              //   sendvalues =
                                              //       parametertypevalueController
                                              //           .text
                                              //           .trim();
                                              // }
                                              sendvalues =
                                                  parametertypevalueController
                                                      .text
                                                      .trim();

                                              print(
                                                  "sendvaluessssssss $sendvalues");

                                              await fetchInvoicedetailsData(
                                                  ParameterTypeController.text,
                                                  sendvalues,
                                                  'overall');
                                              if (invoicedetailstabledata
                                                  .isNotEmpty) {
                                                List<String> columnHeaders =
                                                    invoicedetailstabledata
                                                        .first.keys
                                                        .toList();
                                                List<List<dynamic>>
                                                    convertedData =
                                                    invoicedetailstabledata
                                                        .map((map) {
                                                  return columnHeaders
                                                      .map((header) =>
                                                          map[header])
                                                      .toList();
                                                }).toList();
                                                // await fetchInvoicedetailsData(
                                                //     ParameterTypeController.text,
                                                //     sendvalues,
                                                //     'overall');
                                                if (invoicedetailstabledata
                                                    .isNotEmpty) {
                                                  List<String> columnHeaders =
                                                      invoicedetailstabledata
                                                          .first.keys
                                                          .toList();
                                                  List<List<dynamic>>
                                                      convertedData =
                                                      invoicedetailstabledata
                                                          .map((map) {
                                                    return columnHeaders
                                                        .map((header) =>
                                                            map[header])
                                                        .toList();
                                                  }).toList();
                                                  await createExcelinvoicedetails(
                                                      columnHeaders,
                                                      convertedData,
                                                      ParameterTypeController
                                                          .text,
                                                      sendvalues,
                                                      'Overall');
                                                  postLogData("Report Invoice",
                                                      "Export Underlivered invoice Report");
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Undelivered invoices exported successfully'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                } else {}
                                              }
                                            } else if (ExportedController
                                                    .text ==
                                                'Pending Undelivered Report') {
                                              String sendvalues;
                                              // if (ParameterTypeController.text
                                              //         .trim() ==
                                              //     'Salesman Number') {
                                              //   sendvalues =
                                              //       (await fetchSalesmanName(
                                              //             parametertypevalueController
                                              //                 .text
                                              //                 .trim(),
                                              //           )) ??
                                              //           "";
                                              // } else {
                                              //   sendvalues =
                                              //       parametertypevalueController
                                              //           .text
                                              //           .trim();
                                              // }
                                              sendvalues =
                                                  parametertypevalueController
                                                      .text
                                                      .trim();

                                              print(
                                                  "sendvaluessssssss $sendvalues");

                                              await fetchInvoicedetailsData(
                                                  ParameterTypeController.text,
                                                  sendvalues,
                                                  'pending');
                                              if (invoicedetailstabledata
                                                  .isNotEmpty) {
                                                List<String> columnHeaders =
                                                    invoicedetailstabledata
                                                        .first.keys
                                                        .toList();
                                                List<List<dynamic>>
                                                    convertedData =
                                                    invoicedetailstabledata
                                                        .map((map) {
                                                  return columnHeaders
                                                      .map((header) =>
                                                          map[header])
                                                      .toList();
                                                }).toList();
                                                // await fetchInvoicedetailsData(
                                                //     ParameterTypeController.text,
                                                //     sendvalues,
                                                //     'pending');
                                                if (invoicedetailstabledata
                                                    .isNotEmpty) {
                                                  List<String> columnHeaders =
                                                      invoicedetailstabledata
                                                          .first.keys
                                                          .toList();
                                                  List<List<dynamic>>
                                                      convertedData =
                                                      invoicedetailstabledata
                                                          .map((map) {
                                                    return columnHeaders
                                                        .map((header) =>
                                                            map[header])
                                                        .toList();
                                                  }).toList();
                                                  await createExcelinvoicedetails(
                                                      columnHeaders,
                                                      convertedData,
                                                      ParameterTypeController
                                                          .text,
                                                      sendvalues,
                                                      'Pending');
                                                  postLogData("Report Invoice",
                                                      "Export Underlivered invoice Report");
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Undelivered invoices exported successfully'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Data Loaded Failed...'),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            } else if (ExportedController
                                                    .text ==
                                                'Completed Delivery Report') {
                                              String sendvalues;
                                              // if (ParameterTypeController.text
                                              //         .trim() ==
                                              //     'Salesman Number') {
                                              //   sendvalues =
                                              //       (await fetchSalesmanName(
                                              //             parametertypevalueController
                                              //                 .text
                                              //                 .trim(),
                                              //           )) ??
                                              //           "";
                                              // } else {
                                              //   sendvalues =
                                              //       parametertypevalueController
                                              //           .text
                                              //           .trim();
                                              // }
                                              sendvalues =
                                                  parametertypevalueController
                                                      .text
                                                      .trim();

                                              print(
                                                  "sendvaluessssssss $sendvalues");

                                              await fetchInvoicedetailsData(
                                                  ParameterTypeController.text,
                                                  sendvalues,
                                                  'completed');
                                              if (invoicedetailstabledata
                                                  .isNotEmpty) {
                                                List<String> columnHeaders =
                                                    invoicedetailstabledata
                                                        .first.keys
                                                        .toList();
                                                List<List<dynamic>>
                                                    convertedData =
                                                    invoicedetailstabledata
                                                        .map((map) {
                                                  return columnHeaders
                                                      .map((header) =>
                                                          map[header])
                                                      .toList();
                                                }).toList();
                                                // await fetchInvoicedetailsData(
                                                //     ParameterTypeController.text,
                                                //     sendvalues,
                                                //     'completed');
                                                if (invoicedetailstabledata
                                                    .isNotEmpty) {
                                                  List<String> columnHeaders =
                                                      invoicedetailstabledata
                                                          .first.keys
                                                          .toList();
                                                  List<List<dynamic>>
                                                      convertedData =
                                                      invoicedetailstabledata
                                                          .map((map) {
                                                    return columnHeaders
                                                        .map((header) =>
                                                            map[header])
                                                        .toList();
                                                  }).toList();
                                                  await createExcelinvoicedetails(
                                                      columnHeaders,
                                                      convertedData,
                                                      ParameterTypeController
                                                          .text,
                                                      sendvalues,
                                                      'Completed');
                                                  postLogData("Report Invoice",
                                                      "Export Underlivered invoice Report");
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Undelivered invoices exported successfully'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Data Loaded Failed...'),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            } else if (ExportedController
                                                    .text ==
                                                'Delivered Inv Details - Qty') {
                                              final inputFormat = DateFormat(
                                                  'dd-MMM-yyyy'); // to parse '10-Jul-2025'
                                              final outputFormat = DateFormat(
                                                  'yyyy-MM-dd'); // to format as '2025-07-10'
                                              String fromDateFormatted = '';
                                              String endDateFormatted = '';
                                              DateTime fromDateParsed =
                                                  inputFormat.parse(
                                                      _FromdateController.text);
                                              DateTime endDateParsed =
                                                  inputFormat.parse(
                                                      _EnddateController.text);

                                              fromDateFormatted = outputFormat
                                                  .format(fromDateParsed);
                                              endDateFormatted = outputFormat
                                                  .format(endDateParsed);

                                              String sendvalues;
                                              // if (ParameterTypeController.text
                                              //         .trim() ==
                                              //     'Salesman Number') {
                                              //   sendvalues =
                                              //       (await fetchSalesmanName(
                                              //             parametertypevalueController
                                              //                 .text
                                              //                 .trim(),
                                              //           )) ??
                                              //           "";
                                              // } else {
                                              sendvalues =
                                                  parametertypevalueController
                                                      .text
                                                      .trim();
                                              // }

                                              print(
                                                  "sendvaluessssssss $sendvalues");

                                              await fetchCreateDispatchInvoicedetailsData(
                                                'Quantity',
                                                fromDateFormatted,
                                                endDateFormatted,
                                                ParameterTypeController.text,
                                                sendvalues,
                                              );
                                              // await fetchCreateDispatchInvoicedetailsData(
                                              //     'Quantity',
                                              //     fromDateFormatted,
                                              //     endDateFormatted,
                                              //     ParameterTypeController.text,
                                              //     parametertypevalueController
                                              //         .text);
                                              if (createdispatchinvoicedetailstabledata
                                                  .isNotEmpty) {
                                                List<String> columnHeaders =
                                                    createdispatchinvoicedetailstabledata
                                                        .first.keys
                                                        .toList();
                                                List<List<dynamic>>
                                                    convertedData =
                                                    createdispatchinvoicedetailstabledata
                                                        .map((map) {
                                                  return columnHeaders
                                                      .map((header) =>
                                                          map[header])
                                                      .toList();
                                                }).toList();
                                                await createExcecreatedispatchlinvoicedetails(
                                                  columnHeaders,
                                                  convertedData,
                                                  fromDateFormatted,
                                                  endDateFormatted,
                                                  ParameterTypeController.text,
                                                  sendvalues,
                                                );
                                                postLogData("Report Invoice",
                                                    "Export Create Dispatch invoice Report");
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Dispatch invoices exported successfully'),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                              }
                                            } else if (ExportedController
                                                    .text ==
                                                'Delivered Inv Details - Value') {
                                              final inputFormat = DateFormat(
                                                  'dd-MMM-yyyy'); // to parse '10-Jul-2025'
                                              final outputFormat = DateFormat(
                                                  'yyyy-MM-dd'); // to format as '2025-07-10'
                                              String fromDateFormatted = '';
                                              String endDateFormatted = '';
                                              DateTime fromDateParsed =
                                                  inputFormat.parse(
                                                      _FromdateController.text);
                                              DateTime endDateParsed =
                                                  inputFormat.parse(
                                                      _EnddateController.text);

                                              fromDateFormatted = outputFormat
                                                  .format(fromDateParsed);
                                              endDateFormatted = outputFormat
                                                  .format(endDateParsed);

                                              String sendvalues;
                                              // if (ParameterTypeController.text
                                              //         .trim() ==
                                              //     'Salesman Number') {
                                              //   sendvalues =
                                              //       (await fetchSalesmanName(
                                              //             parametertypevalueController
                                              //                 .text
                                              //                 .trim(),
                                              //           )) ??
                                              //           "";
                                              // } else {
                                              sendvalues =
                                                  parametertypevalueController
                                                      .text
                                                      .trim();
                                              // }

                                              print(
                                                  "sendvaluessssssss $sendvalues");

                                              await fetchCreateDispatchInvoicedetailsData(
                                                'Values',
                                                fromDateFormatted,
                                                endDateFormatted,
                                                ParameterTypeController.text,
                                                sendvalues,
                                              );

                                              // await fetchCreateDispatchInvoicedetailsData(
                                              //     'Values',
                                              //     fromDateFormatted,
                                              //     endDateFormatted,
                                              //     ParameterTypeController.text,
                                              //     parametertypevalueController
                                              //         .text);
                                              if (createdispatchinvoicedetailstabledata
                                                  .isNotEmpty) {
                                                List<String> columnHeaders =
                                                    createdispatchinvoicedetailstabledata
                                                        .first.keys
                                                        .toList();
                                                List<List<dynamic>>
                                                    convertedData =
                                                    createdispatchinvoicedetailstabledata
                                                        .map((map) {
                                                  return columnHeaders
                                                      .map((header) =>
                                                          map[header])
                                                      .toList();
                                                }).toList();
                                                await createExcecreatedispatchlinvoicedetails(
                                                  columnHeaders,
                                                  convertedData,
                                                  fromDateFormatted,
                                                  endDateFormatted,
                                                  ParameterTypeController.text,
                                                  sendvalues,
                                                );
                                                postLogData("Report Invoice",
                                                    "Export Create Dispatch invoice Report");
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Dispatch invoices exported successfully'),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                              }
                                            } else if (ExportedController
                                                    .text ==
                                                'Invoice Return Report') {
                                              final inputFormat = DateFormat(
                                                  'dd-MMM-yyyy'); // to parse '10-Jul-2025'
                                              final outputFormat = DateFormat(
                                                  'yyyy-MM-dd'); // to format as '2025-07-10'
                                              String fromDateFormatted = '';
                                              String endDateFormatted = '';
                                              DateTime fromDateParsed =
                                                  inputFormat.parse(
                                                      _FromdateController.text);
                                              DateTime endDateParsed =
                                                  inputFormat.parse(
                                                      _EnddateController.text);

                                              fromDateFormatted = outputFormat
                                                  .format(fromDateParsed);
                                              endDateFormatted = outputFormat
                                                  .format(endDateParsed);

                                              String sendvalues;

                                              sendvalues =
                                                  parametertypevalueController
                                                      .text
                                                      .trim();

                                              print(
                                                  "sendvaluessssssss $sendvalues");

                                              await fetch_return_Invoice_Tabledatas(
                                                'Quantity',
                                                fromDateFormatted,
                                                endDateFormatted,
                                                ParameterTypeController.text,
                                                sendvalues,
                                              );

                                              if (Invoice_Return_TableDatas
                                                  .isNotEmpty) {
                                                List<String> columnHeaders =
                                                    Invoice_Return_TableDatas
                                                        .first.keys
                                                        .toList();
                                                List<List<dynamic>>
                                                    convertedData =
                                                    Invoice_Return_TableDatas
                                                        .map((map) {
                                                  return columnHeaders
                                                      .map((header) =>
                                                          map[header])
                                                      .toList();
                                                }).toList();
                                                await createExcel_Invoice_Return_Report(
                                                  columnHeaders,
                                                  convertedData,
                                                  fromDateFormatted,
                                                  endDateFormatted,
                                                  ParameterTypeController.text,
                                                  sendvalues,
                                                );
                                                postLogData("Report Invoice",
                                                    "Invoice Return Report");
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Invoice Return Report exported successfully'),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        },
                                        icon: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
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
                                            borderRadius:
                                                BorderRadius.circular(0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              if (exportbuttonbool)
                                SizedBox(
                                  width: 10,
                                ),

                              if (overallexportbuttonbool)
                                Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 45),
                                      child: SizedBox(
                                        height: 30,
                                        child: PopupMenuButton<String>(
                                          offset: Offset(0,
                                              30), // Adjusted position for the shorter button
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          itemBuilder: (BuildContext context) =>
                                              [
                                            PopupMenuItem(
                                              value: 'ud',
                                              child: SizedBox(
                                                width: 300,
                                                child: Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/images/excel.svg',
                                                      width: 18,
                                                      height: 18,
                                                      color: buttonColor,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Undelivered Invoice Details',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'crq',
                                              child: SizedBox(
                                                width: 300,
                                                child: Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/images/excel.svg',
                                                      width: 18,
                                                      height: 18,
                                                      color: buttonColor,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Delivered Inv Details - Qty',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'crv',
                                              child: SizedBox(
                                                width: 300,
                                                child: Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/images/excel.svg',
                                                      width: 18,
                                                      height: 18,
                                                      color: buttonColor,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Delivered Inv Details - Values',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'dr',
                                              child: SizedBox(
                                                width: 300,
                                                child: Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/images/excel.svg',
                                                      width: 18,
                                                      height: 18,
                                                      color: buttonColor,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Dispatch Details - Customerwise',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],

                                          onSelected: (String value) async {
                                            if (value == 'ud') {
                                              String sendvalues;
                                              // if (ParameterTypeController.text
                                              //         .trim() ==
                                              //     'Salesman Number') {
                                              //   sendvalues =
                                              //       (await fetchSalesmanName(
                                              //             parametertypevalueController
                                              //                 .text
                                              //                 .trim(),
                                              //           )) ??
                                              //           "";
                                              // } else {
                                              //   sendvalues =
                                              //       parametertypevalueController
                                              //           .text
                                              //           .trim();
                                              // }
                                              sendvalues =
                                                  parametertypevalueController
                                                      .text
                                                      .trim();

                                              print(
                                                  "sendvaluessssssss $sendvalues");

                                              await fetchInvoicedetailsData(
                                                  ParameterTypeController.text,
                                                  sendvalues,
                                                  'overall');
                                              if (invoicedetailstabledata
                                                  .isNotEmpty) {
                                                List<String> columnHeaders =
                                                    invoicedetailstabledata
                                                        .first.keys
                                                        .toList();
                                                List<List<dynamic>>
                                                    convertedData =
                                                    invoicedetailstabledata
                                                        .map((map) {
                                                  return columnHeaders
                                                      .map((header) =>
                                                          map[header])
                                                      .toList();
                                                }).toList();
                                                await fetchInvoicedetailsData(
                                                    ParameterTypeController
                                                        .text,
                                                    sendvalues,
                                                    'overall');
                                                if (invoicedetailstabledata
                                                    .isNotEmpty) {
                                                  List<String> columnHeaders =
                                                      invoicedetailstabledata
                                                          .first.keys
                                                          .toList();
                                                  List<List<dynamic>>
                                                      convertedData =
                                                      invoicedetailstabledata
                                                          .map((map) {
                                                    return columnHeaders
                                                        .map((header) =>
                                                            map[header])
                                                        .toList();
                                                  }).toList();
                                                  await createExcelinvoicedetails(
                                                      columnHeaders,
                                                      convertedData,
                                                      ParameterTypeController
                                                          .text,
                                                      sendvalues,
                                                      'Overall');
                                                  postLogData("Report Invoice",
                                                      "Export Underlivered invoice Report");
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Undelivered invoices exported successfully'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Data Loaded Failed...'),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            } else if (value == 'crq') {
                                              final inputFormat = DateFormat(
                                                  'dd-MMM-yyyy'); // to parse '10-Jul-2025'
                                              final outputFormat = DateFormat(
                                                  'yyyy-MM-dd'); // to format as '2025-07-10'
                                              String fromDateFormatted = '';
                                              String endDateFormatted = '';
                                              DateTime fromDateParsed =
                                                  inputFormat.parse(
                                                      _FromdateController.text);
                                              DateTime endDateParsed =
                                                  inputFormat.parse(
                                                      _EnddateController.text);

                                              fromDateFormatted = outputFormat
                                                  .format(fromDateParsed);
                                              endDateFormatted = outputFormat
                                                  .format(endDateParsed);

                                              String sendvalues;
                                              if (ParameterTypeController.text
                                                      .trim() ==
                                                  'Salesman Number') {
                                                sendvalues =
                                                    (await fetchSalesmanName(
                                                          parametertypevalueController
                                                              .text
                                                              .trim(),
                                                        )) ??
                                                        "";
                                              } else {
                                                sendvalues =
                                                    parametertypevalueController
                                                        .text
                                                        .trim();
                                              }

                                              print(
                                                  "sendvaluessssssss $sendvalues");

                                              await fetchCreateDispatchInvoicedetailsData(
                                                'Quantity',
                                                fromDateFormatted,
                                                endDateFormatted,
                                                ParameterTypeController.text,
                                                sendvalues,
                                              );
                                              // await fetchCreateDispatchInvoicedetailsData(
                                              //     'Quantity',
                                              //     fromDateFormatted,
                                              //     endDateFormatted,
                                              //     ParameterTypeController.text,
                                              //     parametertypevalueController
                                              //         .text);
                                              if (createdispatchinvoicedetailstabledata
                                                  .isNotEmpty) {
                                                List<String> columnHeaders =
                                                    createdispatchinvoicedetailstabledata
                                                        .first.keys
                                                        .toList();
                                                List<List<dynamic>>
                                                    convertedData =
                                                    createdispatchinvoicedetailstabledata
                                                        .map((map) {
                                                  return columnHeaders
                                                      .map((header) =>
                                                          map[header])
                                                      .toList();
                                                }).toList();
                                                await createExcecreatedispatchlinvoicedetails(
                                                  columnHeaders,
                                                  convertedData,
                                                  fromDateFormatted,
                                                  endDateFormatted,
                                                  ParameterTypeController.text,
                                                  sendvalues,
                                                );
                                                postLogData("Report Invoice",
                                                    "Export Create Dispatch invoice Report");
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Dispatch invoices exported successfully'),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                              }
                                            } else if (value == 'crv') {
                                              final inputFormat = DateFormat(
                                                  'dd-MMM-yyyy'); // to parse '10-Jul-2025'
                                              final outputFormat = DateFormat(
                                                  'yyyy-MM-dd'); // to format as '2025-07-10'
                                              String fromDateFormatted = '';
                                              String endDateFormatted = '';
                                              DateTime fromDateParsed =
                                                  inputFormat.parse(
                                                      _FromdateController.text);
                                              DateTime endDateParsed =
                                                  inputFormat.parse(
                                                      _EnddateController.text);

                                              fromDateFormatted = outputFormat
                                                  .format(fromDateParsed);
                                              endDateFormatted = outputFormat
                                                  .format(endDateParsed);

                                              String sendvalues;
                                              if (ParameterTypeController.text
                                                      .trim() ==
                                                  'Salesman Number') {
                                                sendvalues =
                                                    (await fetchSalesmanName(
                                                          parametertypevalueController
                                                              .text
                                                              .trim(),
                                                        )) ??
                                                        "";
                                              } else {
                                                sendvalues =
                                                    parametertypevalueController
                                                        .text
                                                        .trim();
                                              }

                                              print(
                                                  "sendvaluessssssss $sendvalues");

                                              await fetchCreateDispatchInvoicedetailsData(
                                                'Values',
                                                fromDateFormatted,
                                                endDateFormatted,
                                                ParameterTypeController.text,
                                                sendvalues,
                                              );

                                              // await fetchCreateDispatchInvoicedetailsData(
                                              //     'Values',
                                              //     fromDateFormatted,
                                              //     endDateFormatted,
                                              //     ParameterTypeController.text,
                                              //     parametertypevalueController
                                              //         .text);
                                              if (createdispatchinvoicedetailstabledata
                                                  .isNotEmpty) {
                                                List<String> columnHeaders =
                                                    createdispatchinvoicedetailstabledata
                                                        .first.keys
                                                        .toList();
                                                List<List<dynamic>>
                                                    convertedData =
                                                    createdispatchinvoicedetailstabledata
                                                        .map((map) {
                                                  return columnHeaders
                                                      .map((header) =>
                                                          map[header])
                                                      .toList();
                                                }).toList();
                                                await createExcecreatedispatchlinvoicedetails(
                                                  columnHeaders,
                                                  convertedData,
                                                  fromDateFormatted,
                                                  endDateFormatted,
                                                  ParameterTypeController.text,
                                                  sendvalues,
                                                );
                                                postLogData("Report Invoice",
                                                    "Export Create Dispatch invoice Report");
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Dispatch invoices exported successfully'),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                              }
                                            } else if (value == 'dr') {
                                              final inputFormat = DateFormat(
                                                  'dd-MMM-yyyy'); // to parse '10-Jul-2025'
                                              final outputFormat = DateFormat(
                                                  'yyyy-MM-dd'); // to format as '2025-07-10'
                                              String fromDateFormatted = '';
                                              String endDateFormatted = '';
                                              DateTime fromDateParsed =
                                                  inputFormat.parse(
                                                      _FromdateController.text);
                                              DateTime endDateParsed =
                                                  inputFormat.parse(
                                                      _EnddateController.text);

                                              fromDateFormatted = outputFormat
                                                  .format(fromDateParsed);
                                              endDateFormatted = outputFormat
                                                  .format(endDateParsed);

                                              if (ParameterTypeController.text
                                                      .trim()
                                                      .isEmpty &&
                                                  parametertypevalueController
                                                      .text
                                                      .trim()
                                                      .isEmpty) {
                                                // ✅ Both empty → allow normal flow
                                                exportGroupedTruckScanDetails(
                                                  context,
                                                  fromDateFormatted,
                                                  endDateFormatted,
                                                  ParameterTypeController.text,
                                                  "", // since both empty, send empty string
                                                );
                                              } else if (ParameterTypeController
                                                      .text
                                                      .trim()
                                                      .isEmpty ||
                                                  parametertypevalueController
                                                      .text
                                                      .trim()
                                                      .isEmpty) {
                                                // ❌ One is empty, one is not → show error
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          "Kindly fill both fields")),
                                                );
                                              } else {
                                                // ✅ Both filled → your existing logic
                                                String sendvalues;
                                                if (ParameterTypeController.text
                                                        .trim() ==
                                                    'Salesman Number') {
                                                  sendvalues =
                                                      (await fetchSalesmanName(
                                                            parametertypevalueController
                                                                .text
                                                                .trim(),
                                                          )) ??
                                                          "";
                                                } else {
                                                  sendvalues =
                                                      parametertypevalueController
                                                          .text
                                                          .trim();
                                                }

                                                print(
                                                    "sendvaluessssssss $sendvalues");

                                                exportGroupedTruckScanDetails(
                                                  context,
                                                  fromDateFormatted,
                                                  endDateFormatted,
                                                  ParameterTypeController.text,
                                                  sendvalues,
                                                );
                                              }
                                            }
                                            postLogData("Report Invoice",
                                                "Export Button");
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 7), // Reduced padding
                                            decoration: BoxDecoration(
                                              color: buttonColor,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/excel.svg',
                                                  width:
                                                      18, // Slightly smaller icon
                                                  height: 18,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                    width:
                                                        6), // Reduced spacing
                                                Text(
                                                  'Export',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize:
                                                        14, // Slightly smaller font
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        2), // Reduced spacing
                                                Icon(
                                                  Icons.arrow_drop_down,
                                                  color: Colors.white,
                                                  size: 18, // Smaller icon
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                              height: 500,
                              child: !_hasSearched
                                  ? Center(
                                      child: Text(
                                        'Kindly use the search button to view results',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    )
                                  : GroupedTruckScanDetails(
                                      fromDate!,
                                      endDate!,
                                      ParameterTypeController.text,
                                      parametertypevalueController.text)
                              // ResponsiveTablePage(
                              //     InvoiceStatusController.text,
                              //     columnName,
                              //     columnValue,
                              //     fromDate,
                              //     endDate,
                              //   ),
                              )

                          //     Container(
                          //   height: 500,
                          //   child: !_hasSearched
                          //       ? Center(
                          //           child: Text(
                          //             'Kindly use the search button to view results',
                          //             style: TextStyle(fontSize: 16),
                          //           ),
                          //         )
                          //       : FutureBuilder<String?>(
                          //           future: () async {
                          //             // ✅ Case 1: both empty → allow normal flow
                          //             if (ParameterTypeController.text
                          //                     .trim()
                          //                     .isEmpty &&
                          //                 parametertypevalueController.text
                          //                     .trim()
                          //                     .isEmpty) {
                          //               return "";
                          //             }

                          //             // ❌ Case 2: one is empty → show error and stop
                          //             if (ParameterTypeController.text
                          //                     .trim()
                          //                     .isEmpty ||
                          //                 parametertypevalueController.text
                          //                     .trim()
                          //                     .isEmpty) {
                          //               ScaffoldMessenger.of(context)
                          //                   .showSnackBar(
                          //                 SnackBar(
                          //                     content: Text(
                          //                         "Kindly fill both fields")),
                          //               );
                          //               return null;
                          //             }

                          //             // ✅ Case 3: both filled
                          //             if (ParameterTypeController.text.trim() ==
                          //                 'Salesman Number') {
                          //               return await fetchSalesmanName(
                          //                 parametertypevalueController.text
                          //                     .trim(),
                          //               );
                          //             } else {
                          //               return parametertypevalueController.text
                          //                   .trim();
                          //             }
                          //           }(),
                          //           builder: (context, snapshot) {
                          //             if (!snapshot.hasData) {
                          //               return SizedBox(); // nothing to show yet
                          //             }

                          //             final sendvalues = snapshot.data ?? "";

                          //             print("sendvaluessssssss $sendvalues");

                          //             return GroupedTruckScanDetails(
                          //               fromDate!,
                          //               endDate!,
                          //               ParameterTypeController.text,
                          //               sendvalues,
                          //             );
                          //           },
                          //         ),
                          // )
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

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateFormat("dd-MMM-yyyy").parse(date);
      return DateFormat("yyyy-MM-dd").format(parsedDate);
    } catch (e) {
      return date; // Return original if parsing fails
    }
  }

  List<RegisterDetail> tableData = [];
  bool isLoading = true;

  Future<void> fetchData(String invoicestatusname, String columnName,
      String columnValue, String fromDate, String endDate) async {
    print("Fetching All Data with:");

    print("invoicestatusname Name: $invoicestatusname");
    print("Column Name: $columnName");
    print("Column Value: $columnValue");
    print("From Date: $fromDate");
    print("End Date: $endDate");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String salesloginrole = prefs.getString('salesloginrole') ?? '';
    String salesloginno = (salesloginrole == 'Salesman')
        ? (prefs.getString('salesloginno') ?? '')
        : '';
    print("Salesman No : $salesloginno");

    String formattedFromDate = formatDate(fromDate);
    String formattedEndDate = formatDate(endDate);

    final IpAddress = await getActiveIpAddress();

    String apiUrl =
        "$IpAddress/InvoiceReportsUndeliveredDataView/$invoicestatusname/$salesloginno/$columnName/$columnValue/$formattedFromDate/$formattedEndDate/";
    List<RegisterDetail> allData = [];

    print("api url lll $apiUrl");

    try {
      while (apiUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(apiUrl));

        print("Fetching from URL: $apiUrl");

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          List<dynamic> results = jsonResponse['results'] ?? [];

          allData.addAll(
              results.map((item) => RegisterDetail.fromJson(item)).toList());

          // Check if there is a next page
          apiUrl = jsonResponse['next'] ?? "";
        } else {
          throw Exception(
              "Failed to load data, status code: ${response.statusCode}");
        }
      }

      setState(() {
        tableData = allData;
        isLoading = false;
        print('tableDataaaaaaaaa $tableData');
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
      print("Error fetching data: $e");
    }
  }

  List<String> getDisplayedColumns() {
    return columnHeaders;
  }

  Future<void> createExcecreatedispatchlinvoicedetails(
    List<String> columnNames,
    List<List<dynamic>> data,
    String Fromdate,
    String enddate,
    String parametertype,
    String parametervalue, {
    String? exportTitle, // nullable optional param
  }) async {
    try {
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];
      final String title = ExportedController.text;

      // Add main heading
      final Range titleRange = sheet.getRangeByIndex(1, 1);
      titleRange.setText(title);
      titleRange.cellStyle.fontSize = 16;
      titleRange.cellStyle.bold = true;
      sheet.getRangeByIndex(1, 1, 1, columnNames.length).merge();

      // Show filter details below heading
      final Range fromDateCell = sheet.getRangeByIndex(3, 1);
      fromDateCell.setText("From Date: $Fromdate");
      fromDateCell.cellStyle.bold = true;
      fromDateCell.cellStyle.fontSize = 12;

      final Range toDateCell = sheet.getRangeByIndex(4, 1);
      toDateCell.setText("To Date: $enddate");
      toDateCell.cellStyle.bold = true;
      toDateCell.cellStyle.fontSize = 12;

      final Range paramTypeCell = sheet.getRangeByIndex(5, 1);
      paramTypeCell.setText("$parametertype : ");
      paramTypeCell.cellStyle.bold = true;
      paramTypeCell.cellStyle.fontSize = 12;

      final Range paramValueCell = sheet.getRangeByIndex(5, 2);
      paramValueCell.setText("$parametervalue");
      paramValueCell.cellStyle.bold = true;
      paramValueCell.cellStyle.fontSize = 12;

      // Today's date & time
      final DateTime now = DateTime.now();
      final DateTime today = DateTime.now();
      final String formattedTime = DateFormat('hh:mm:ss a').format(now);
      final String formattedToday = DateFormat('dd-MMM-yyyy').format(today);
      // ====== Footer: Runtime & Exported Time ======

      final Range runtimeCell = sheet.getRangeByIndex(6, 1);
      runtimeCell.setText("Runtime : $formattedToday -- $formattedTime");
      runtimeCell.cellStyle
        ..italic = true
        ..fontSize = 11
        ..hAlign = HAlignType.left;

      // Leave a row after details, then table headers
      final int headerRowIndex = 7;

      // Add column headers
      for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
        final Range range = sheet.getRangeByIndex(headerRowIndex, colIndex + 1);
        range.setText(columnNames[colIndex]);
        range.cellStyle.backColor = '#E7F3FD';
        range.cellStyle.fontColor = '#000000';
        range.cellStyle.bold = true;
        range.cellStyle.hAlign = HAlignType.left;
        range.cellStyle.borders.all.lineStyle = LineStyle.thin;
        range.cellStyle.borders.all.color = '#000000';
        range.cellStyle.bold = true;
      }

      // Add table data starting from row below headers
      for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
        final List<dynamic> rowData = data[rowIndex];
        for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
          final Range range = sheet.getRangeByIndex(
              headerRowIndex + 1 + rowIndex, colIndex + 1);

          final dynamic cellValue = rowData[colIndex];

          if (cellValue == null || cellValue.toString().isEmpty) {
            range.setText('');
          } else if (cellValue is num) {
            // ✅ set as number
            range.setNumber(cellValue.toDouble());
          } else {
            // ✅ fallback as text
            range.setText(cellValue.toString());
          }
        }
      }

      // ✅ Auto-fit columns based on content
      for (int i = 1; i <= columnNames.length; i++) {
        sheet.autoFitColumn(i);
      }

      final List<int> bytes = workbook.saveAsStream();
      try {
        workbook.dispose();
      } catch (e) {
        print('Error during workbook disposal: $e');
      }

      String formattedDate =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} Time '
          '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';

      if (kIsWeb) {
        AnchorElement(
            href:
                'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
          ..setAttribute(
              'download', 'Dispatch Invoice details($formattedDate).xlsx')
          ..click();
      } else {
        final String path = (await getApplicationSupportDirectory()).path;
        final String fileName = Platform.isWindows
            ? '$path\\Excel Dispatch Invoice details($formattedDate).xlsx'
            : '$path/Excel Dispatch Invoice details($formattedDate).xlsx';
        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);
        OpenFile.open(fileName);
      }
    } catch (e) {
      print('Error in createExcel: $e');
    }
  }

  Future<void> createExcel_Invoice_Return_Report(
    List<String> columnNames,
    List<List<dynamic>> data,
    String Fromdate,
    String enddate,
    String parametertype,
    String parametervalue, {
    String? exportTitle, // nullable optional param
  }) async {
    try {
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];
      final String title = ExportedController.text;

      // Add main heading
      final Range titleRange = sheet.getRangeByIndex(1, 1);
      titleRange.setText(title);
      titleRange.cellStyle.fontSize = 16;
      titleRange.cellStyle.bold = true;
      sheet.getRangeByIndex(1, 1, 1, columnNames.length).merge();

      // Show filter details below heading
      final Range fromDateCell = sheet.getRangeByIndex(3, 1);
      fromDateCell.setText("From Date: $Fromdate");
      fromDateCell.cellStyle.bold = true;
      fromDateCell.cellStyle.fontSize = 12;

      final Range toDateCell = sheet.getRangeByIndex(4, 1);
      toDateCell.setText("To Date: $enddate");
      toDateCell.cellStyle.bold = true;
      toDateCell.cellStyle.fontSize = 12;

      final Range paramTypeCell = sheet.getRangeByIndex(5, 1);
      paramTypeCell.setText("$parametertype : ");
      paramTypeCell.cellStyle.bold = true;
      paramTypeCell.cellStyle.fontSize = 12;

      final Range paramValueCell = sheet.getRangeByIndex(5, 2);
      paramValueCell.setText("$parametervalue");
      paramValueCell.cellStyle.bold = true;
      paramValueCell.cellStyle.fontSize = 12;

      // Today's date & time
      final DateTime now = DateTime.now();
      final DateTime today = DateTime.now();
      final String formattedTime = DateFormat('hh:mm:ss a').format(now);
      final String formattedToday = DateFormat('dd-MMM-yyyy').format(today);
      // ====== Footer: Runtime & Exported Time ======

      final Range runtimeCell = sheet.getRangeByIndex(6, 1);
      runtimeCell.setText("Runtime : $formattedToday -- $formattedTime");
      runtimeCell.cellStyle
        ..italic = true
        ..fontSize = 11
        ..hAlign = HAlignType.left;

      // Leave a row after details, then table headers
      final int headerRowIndex = 7;

      // Add column headers
      for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
        final Range range = sheet.getRangeByIndex(headerRowIndex, colIndex + 1);
        range.setText(columnNames[colIndex]);
        range.cellStyle.backColor = '#E7F3FD';
        range.cellStyle.fontColor = '#000000';
        range.cellStyle.bold = true;
        range.cellStyle.hAlign = HAlignType.left;
        range.cellStyle.borders.all.lineStyle = LineStyle.thin;
        range.cellStyle.borders.all.color = '#000000';
        range.cellStyle.bold = true;
      }

      // Add table data starting from row below headers
      for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
        final List<dynamic> rowData = data[rowIndex];
        for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
          final Range range = sheet.getRangeByIndex(
              headerRowIndex + 1 + rowIndex, colIndex + 1);

          final dynamic cellValue = rowData[colIndex];

          if (cellValue == null || cellValue.toString().isEmpty) {
            range.setText('');
          } else if (cellValue is num) {
            // ✅ set as number
            range.setNumber(cellValue.toDouble());
          } else {
            // ✅ fallback as text
            range.setText(cellValue.toString());
          }
        }
      }

      // ✅ Auto-fit columns based on content
      for (int i = 1; i <= columnNames.length; i++) {
        sheet.autoFitColumn(i);
      }

      final List<int> bytes = workbook.saveAsStream();
      try {
        workbook.dispose();
      } catch (e) {
        print('Error during workbook disposal: $e');
      }

      String formattedDate =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} Time '
          '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';

      if (kIsWeb) {
        AnchorElement(
            href:
                'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
          ..setAttribute(
              'download', 'Invoice Return details($formattedDate).xlsx')
          ..click();
      } else {
        final String path = (await getApplicationSupportDirectory()).path;
        final String fileName = Platform.isWindows
            ? '$path\\Excel Invoice Return details($formattedDate).xlsx'
            : '$path/Excel Invoice Return details($formattedDate).xlsx';
        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);
        OpenFile.open(fileName);
      }
    } catch (e) {
      print('Error in createExcel: $e');
    }
  }

  Future<void> createExcelinvoicedetails(
      List<String> columnNames,
      List<List<dynamic>> data,
      String parametertype,
      String parametervalue,
      String Status) async {
    final Workbook workbook = Workbook();
    try {
      final Worksheet sheet = workbook.worksheets[0];

      // Today's date
      final DateTime today = DateTime.now();
      final String formattedToday = DateFormat('dd-MMM-yyyy').format(today);

      // ====== Main heading ======
      final Range titleRange = sheet.getRangeByIndex(1, 1);
      titleRange.setText(
          '$Status Invoice Report ${Status != 'Completed' ? '(Undelivered Datas)' : ''}');
      titleRange.cellStyle
        ..fontSize = 16
        ..bold = true
        ..hAlign = HAlignType.left;
      sheet.getRangeByIndex(1, 1, 1, columnNames.length).merge();

      // ====== Subheading ======
      final Range subTitleRange = sheet.getRangeByIndex(3, 1);
      subTitleRange.setText(
          'ALJE ${Status != 'Completed' ? 'Undelivered' : 'Delivered'} As On : $formattedToday');
      subTitleRange.cellStyle
        ..fontSize = 12
        ..italic = true
        ..hAlign = HAlignType.left;
      sheet.getRangeByIndex(2, 1, 2, columnNames.length).merge();

      // ====== Parameter Info ======
      final Range paramTypeCell = sheet.getRangeByIndex(4, 1);
      paramTypeCell.setText((parametertype == "Salesman Number")
          ? "Salesman Number : $parametervalue"
          : '${parametertype.isNotEmpty ? "$parametertype :" : ""}  $parametervalue');
      paramTypeCell.cellStyle
        ..bold = true
        ..fontSize = 12;

      // Today's date & time
      final DateTime now = DateTime.now();
      final String formattedTime = DateFormat('hh:mm:ss a').format(now);
      // ====== Footer: Runtime & Exported Time ======

      final Range runtimeCell = sheet.getRangeByIndex(6, 1);
      runtimeCell.setText("Runtime : $formattedToday -- $formattedTime");
      runtimeCell.cellStyle
        ..italic = true
        ..fontSize = 11
        ..hAlign = HAlignType.left;

      // ====== Column Headers at Row 6 ======
      for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
        final Range headerCell = sheet.getRangeByIndex(7, colIndex + 1);
        headerCell.setText(columnNames[colIndex]);
        headerCell.cellStyle
          ..backColor = '#E7F3FD'
          ..fontColor = '#000000'
          ..bold = true
          ..hAlign = HAlignType.left
          ..borders.all.lineStyle = LineStyle.thin
          ..borders.all.color = '#000000';
      }

      // ====== Table Data (start at Row 7) ======
      for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
        final List<dynamic> rowData = data[rowIndex];
        for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
          final Range cell = sheet.getRangeByIndex(rowIndex + 8, colIndex + 1);
          final cellValue = rowData[colIndex];

          if (cellValue == null) {
            cell.setText('');
          } else if (cellValue is num) {
            cell.setNumber(cellValue.toDouble());
            cell.numberFormat = cellValue % 1 == 0 ? '0' : '#,##0.00';
          } else if (cellValue is DateTime) {
            cell.setDateTime(cellValue);
            cell.numberFormat = 'DD-MMM-YYYY';
          } else {
            cell.setText(cellValue.toString());
          }

          cell.cellStyle
            ..hAlign = HAlignType.left
            ..borders.all.lineStyle = LineStyle.thin
            ..borders.all.color = '#000000';
        }
      }

      // Auto-fit columns
      for (int i = 1; i <= columnNames.length; i++) {
        sheet.autoFitColumn(i);
      }

      // ====== Save File ======
      final List<int> bytes = workbook.saveAsStream();
      String timestamp =
          '$formattedToday Time ${today.hour.toString().padLeft(2, '0')}hh-${today.minute.toString().padLeft(2, '0')}mm-${today.second.toString().padLeft(2, '0')}ss';

      if (kIsWeb) {
        final blob = base64.encode(bytes);
        AnchorElement(
          href: 'data:application/octet-stream;charset=utf-16le;base64,$blob',
        )
          ..setAttribute('download',
              '$Status Invoice details ${parametertype.isNotEmpty ? "$parametertype : $parametervalue" : ""}($timestamp).xlsx')
          ..click();
      } else {
        final String path = (await getApplicationSupportDirectory()).path;
        final String fileName = Platform.isWindows
            ? '$path\\Excel $Status Invoice details ${parametertype.isNotEmpty ? "$parametertype : $parametervalue" : ""}($timestamp).xlsx'
            : '$path/Excel $Status Invoice details ${parametertype.isNotEmpty ? "$parametertype : $parametervalue" : ""}($timestamp).xlsx';

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

  //Future<void> createExcelinvoicedetails(
  //     List<String> columnNames, List<List<dynamic>> data) async {
  //   try {
  //     final Workbook workbook = Workbook();
  //     final Worksheet sheet = workbook.worksheets[0];

  //     for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
  //       final Range range = sheet.getRangeByIndex(1, colIndex + 1);
  //       range.setText(columnNames[colIndex]);
  //       range.cellStyle.backColor = '#550A35';
  //       range.cellStyle.fontColor = '#F5F5F5';
  //     }

  //     for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
  //       final List<dynamic> rowData = data[rowIndex];
  //       for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
  //         final Range range = sheet.getRangeByIndex(rowIndex + 2, colIndex + 1);
  //         range.setText(rowData[colIndex].toString());
  //       }
  //     }

  //     final List<int> bytes = workbook.saveAsStream();

  //     try {
  //       workbook.dispose();
  //     } catch (e) {
  //       print('Error during workbook disposal: $e');
  //     }

  //     DateTime now = DateTime.now();
  //     String formattedDate =
  //         '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} Time '
  //         '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';

  //     if (kIsWeb) {
  //       AnchorElement(
  //           href:
  //               'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
  //         ..setAttribute('download', 'Invoice details($formattedDate).xlsx')
  //         ..click();
  //     } else {
  //       final String path = (await getApplicationSupportDirectory()).path;
  //       final String fileName = Platform.isWindows
  //           ? '$path\\Excel Invoice details($formattedDate).xlsx'
  //           : '$path/Excel Invoice details($formattedDate).xlsx';
  //       final File file = File(fileName);
  //       await file.writeAsBytes(bytes, flush: true);
  //       OpenFile.open(fileName);
  //     }
  //   } catch (e) {
  //     print('Error in createExcel: $e');
  //   }
  // }

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
          ..setAttribute('download', 'InvoicePending ($formattedDate).xlsx')
          ..click();
      } else {
        final String path = (await getApplicationSupportDirectory()).path;
        final String fileName = Platform.isWindows
            ? '$path\\Excel InvoicePending ($formattedDate).xlsx'
            : '$path/Excel InvoicePending ($formattedDate).xlsx';
        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);
        OpenFile.open(fileName);
      }
    } catch (e) {
      print('Error in createExcel: $e');
    }
  }
}
