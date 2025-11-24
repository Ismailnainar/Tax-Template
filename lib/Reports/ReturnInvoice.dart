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
import 'package:url_launcher/url_launcher.dart';

class Return_invoice extends StatefulWidget {
  const Return_invoice({super.key});

  @override
  State<Return_invoice> createState() => _Return_invoiceState();
}

class _Return_invoiceState extends State<Return_invoice> {
  bool _isSecondRowVisible = false;
  int currentLength = 0;
  bool _isLoading = true;
  List<String> CustomerNameList = [];

  List<String> SalesmmanList = [];

  List<String> CustomeSiteList = [];
  TextEditingController TotalInvoiveCountController = TextEditingController();
  List<String> InvoiceNoList = [];
  String? cusnameselectedValue;
  bool _filterEnabledcusname = true;
  int? _hoveredIndexcusname;
  int? _selectedIndexcusname;
  String? cussiteselectedValue;
  bool _filterEnabledcussite = true;
  int? _hoveredIndexcussite;
  int? _selectedIndexcussite;

  String? salemannoselectedValue;
  bool _filterEnabledsalesmanno = true;
  int? _hoveredIndexcusno;
  int? _selectedIndexsalesmanno;

  TextEditingController SalesmanNoController = TextEditingController();
  TextEditingController CustomerNoController = TextEditingController();
  TextEditingController CustomeridController = TextEditingController();
  TextEditingController CustomerNameController = TextEditingController();
  TextEditingController CustomersiteidController = TextEditingController();
  TextEditingController CustomersitechannelController = TextEditingController();

  TextEditingController _remarkController = TextEditingController();

  FocusNode SalesmanNoFocusNode = FocusNode();
  FocusNode CustomerNoFocusNode = FocusNode();
  FocusNode CustomerNameFocusNode = FocusNode();
  FocusNode CustomerSiteFocusNode = FocusNode();
  FocusNode SiteAddressFocusNode = FocusNode();
  FocusNode InvoiceFocusNode = FocusNode();

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  final ScrollController _horizontalScrollController2 = ScrollController();
  final ScrollController _verticalScrollController2 = ScrollController();
  String? saveloginname = '';

  String? saveloginrole = '';

  String? saveloginOrgId = '';

  String? commersialrole = '';

  String? commersialname = '';

  @override
  List<bool> checkboxStates = [];

  void initState() {
    super.initState();
    // _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
    //   fetchLastRequestNo(); // Fetch serial number every 10 sec
    // });
    _loadSalesmanName();
    checkboxStates = List<bool>.filled(createtableData.length, false);
    // fetchSalesmanList();

    fetchCustomerNumbers();
    // // Initialize controllers and focus nodes for each rows
    // createtableData.forEach((row) {
    //   _controllers.add(TextEditingController(text: "0"));
    //   _focusNodes.add(FocusNode());
    // });
    postLogData("Return Invoice", "Opened");
  }

  bool isomvoiceLoading = false;
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

  TextEditingController InvoiceReturnIdController = TextEditingController();

  Future<void> fetchLastINvoiceReturnid() async {
    final IpAddress = await getActiveIpAddress();
    final url = '$IpAddress/Invoice_ReturnID_Lastid/'; // Ensure URL is correct

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String lastInvoicereturnId =
            data['INVOICE_RETURN_ID']?.toString() ?? '';

        if (lastInvoicereturnId.isNotEmpty) {
          // Use RegExp to extract parts from PICK_ID like InvoicereturnId:25040876
          RegExp regExp = RegExp(r'^INVR:(\d{2})(\d{2})(\d+)$');
          Match? match = regExp.firstMatch(lastInvoicereturnId);

          if (match != null) {
            String year = match.group(1)!; // e.g., '25'
            String month = match.group(2)!; // e.g., '04'
            int lastNumber = int.parse(match.group(3)!); // e.g., 87

            int newNumber = lastNumber + 1;
            String newNumberStr =
                newNumber.toString().padLeft(4, '0'); // zero-padded

            String newInvoicereturnId =
                'INVR:$year$month$newNumberStr'; // e.g., InvoicereturnId:25040988
            InvoiceReturnIdController.text = newInvoicereturnId;
          } else {
            InvoiceReturnIdController.text =
                lastInvoicereturnId; // fallback if format doesn’t match
          }
        } else {
          InvoiceReturnIdController.text = "INVR:00000001"; // fallback default
        }
      } else {
        InvoiceReturnIdController.text = "INVR_ERR_${response.statusCode}";
      }
    } catch (e) {
      InvoiceReturnIdController.text = "INVR_EXC";
      print('Exception fetching INVR_ID: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String token = '';
  Future<void> fetchTokenwithInvoiceReturnId() async {
    final IpAddress = await getActiveIpAddress();

    try {
      // Send a GET request to fetch the CSRF token from the server
      final response = await http
          .get(Uri.parse('$IpAddress/Invoice_Return_id_generate-token/'));

      if (response.statusCode == 200) {
        // Parse the JSON response to extract the new CSRF token and message
        var data = jsonDecode(response.body);

        // InvoicereturnId =
        //     int.tryParse(data['PICK_ID'].toString()) ?? 0; // Safe conversion

        String InvoicereturnId = data['INVOICE_RETURN_ID']?.toString() ?? '';

        token = data['TOCKEN'] ?? 'No Token found';

        String saveInvoicereturnId =
            InvoicereturnId.toString(); // Convert int to String

        setState(() {
          // Only update state variables here
        });

        print(
            'Invoice retunr id  $InvoicereturnId  $saveInvoicereturnId  $token');

        // Save values after setState
        await saveToSharedPreferences(saveInvoicereturnId, token);
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

  bool isLoading = true;
  Future<void> fetchCustomerNumbers() async {
    CustomerNameList = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? salesloginno = SalesmanNoController.text;
    String? saleslogiOrgid = prefs.getString('saleslogiOrgid');
    String? saleswarehouselogins = prefs.getString('saleslogiOrgwarehousename');

    final IpAddress = await getActiveIpAddress();

    final String initialUrl =
        '$IpAddress/Invocie_Return_CustomerNamelist/$saleswarehouselogins/';
    String? nextPageUrl = initialUrl;
    print("salesno : $salesloginno");
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

          var data = json.decode(decodedBody);

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

  Future<List<String>> fetchSalesmanList() async {
    final IpAddress = await getActiveIpAddress();
    String salesrep;

    // if (commersialrole == "Sales Supervisor") {
    //   salesrep = '3';
    // } else if (commersialrole == "Retail Sales Supervisor") {
    //   salesrep = '-3';
    // } else {
    //   salesrep = '5';
    // }

    String customerNumber = CustomerNoController.text;
    String customersite = CustomersiteidController.text;

    final url = Uri.parse(
        '$IpAddress/get-salesmanNo_List/?customer_no=$customerNumber&customer_site_id=$customersite');
    print(
        'salesrep Urlsss $IpAddress/get-salesman/?customer_no=$customerNumber&customer_site_id=$customersite');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes); // <- fix here
      final List<dynamic> data = jsonDecode(decodedBody);
      // Extract SALESMAN_NAME into a list
      // SalesmmanList =
      //     data.map((item) => item['SALESMAN_NO'].toString()).toList();

      SalesmmanList = data.map((item) {
        String number = item['SALESMAN_NO'].toString();
        String name = item['EMPLOYEE_FULL_NAME'].toString();
        return name.isNotEmpty ? "$number : $name" : number;
      }).toList();
      print("SalesmmanList $SalesmmanList");
      return SalesmmanList;
    } else {
      throw Exception('Failed to load salesman data');
    }
  }

  Future<void> fetchInvoiceNumbers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = SalesmanNoController.text.trim();
    String customerNumber = CustomerNoController.text;
    String customersite = CustomersiteidController.text;

    final IpAddress = await getActiveIpAddress();

    final String initialUrl =
        '$IpAddress/invoice/$salesloginno/$customerNumber/$customersite/';
    String? nextPageUrl = initialUrl;
    print('initialUrlinitialUrlinitialUrlinitialUrl: ${initialUrl} ');
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

          if (data['results'] != null && data['results'].isNotEmpty) {
            for (var result in data['results']) {
              if (result['invoice_number'] != null) {
                tempInvoiceNumbers.add(result['invoice_number']);
              }
            }
          }

          nextPageUrl = data['next'];
        } else {
          print('Error: ${response.statusCode} ');
          break;
        }
      }

      setState(() {
        InvoiceNoList = tempInvoiceNumbers;
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

  Future<void> fetchCustomerDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = SalesmanNoController.text;
    String? saleslogiOrgid = prefs.getString('saleslogiOrgid');
    String? saleswarehouselogins = prefs.getString('saleslogiOrgwarehousename');

    final IpAddress = await getActiveIpAddress();

    String baseUrl =
        '$IpAddress/Invocie_Return_CustomerNamelist/$saleswarehouselogins/';
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
              // print('Customer Name: ${CustomerNameController.text}');
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
    String? saleswarehouselogins = prefs.getString('saleslogiOrgwarehousename');

    String? salesloginno = SalesmanNoController.text;
    String customerno = CustomerNoController.text;
    String customername = CustomerNameController.text;

    final IpAddress = await getActiveIpAddress();

    final String initialUrl =
        '$IpAddress/Invoice_Return_CustomerSiteIDList/$saleswarehouselogins/$customerno/';
    String? nextPageUrl = initialUrl;
    print("customersite url $initialUrl");
    setState(() {
      isomvoiceLoading = true; // Show progress indicator
      // Show processing dialog
      _showProcessingDialog();
    });
    try {
      List<String> tempCustomerDetails = [];

      while (nextPageUrl != null) {
        var response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          if (data['results'] != null && data['results'] is List) {
            for (var result in data['results']) {
              // Extract site_use_id and ensure it's treated as a String
              String? customerSiteno = result['site_use_id']?.toString();

              // Check if customerSiteno is not null
              if (customerSiteno != null && customerSiteno.isNotEmpty) {
                tempCustomerDetails.add(customerSiteno);
              }
            }
          }

          // Update nextPageUrl for pagination
          nextPageUrl = data['next']?.toString();
        } else {
          print('Error: ${response.statusCode}');
          break;
        }
      }

      setState(() {
        CustomeSiteList = tempCustomerDetails;
        isLoading = false;
        print("CustomeSiteList list : $CustomeSiteList");
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

            InvoiceNoList = [];
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
          InvoiceNoList = [];
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

  Widget _buildsalesmannoDropdown() {
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
                          ? screenWidth * 0.15
                          : screenWidth * 0.4,
                      child: SalesmanNoDropdown()),
                ],
              ),
            ),
            SizedBox(width: 3),
          ],
        ),
      ),
    );
  }

  Widget SalesmanNoDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex = SalesmmanList.indexOf(SalesmanNoController.text);
            if (currentIndex < SalesmmanList.length - 1) {
              setState(() {
                _selectedIndexsalesmanno = currentIndex + 1;
                // Take only the customer number part before the colon
                SalesmanNoController.text =
                    SalesmmanList[currentIndex + 1].split(':')[0];
                _filterEnabledsalesmanno = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = SalesmmanList.indexOf(SalesmanNoController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndexsalesmanno = currentIndex - 1;
                // Take only the customer number part before the colon
                SalesmanNoController.text =
                    SalesmmanList[currentIndex - 1].split(':')[0];
                _filterEnabledsalesmanno = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: SalesmanNoFocusNode,
          controller: SalesmanNoController,
          onSubmitted: (String? suggestion) async {
            // // InvoiceNoController.clear();

            // // CustomersiteidController..clear();
            // // await fetchInvoiceNumbers();
            // // _fieldFocusChange(
            // //     context, CustomerNoFocusNode, CustomerNameFocusNode);
            // CustomerNameList = [];
            // _handleSalesmanNoChange(suggestion!);
            createtableData = [];
            InvoiceNoController.clear();

            InvoiceNoList = [];
            await fetchInvoiceNumbers();

            if (InvoiceNoList.isEmpty) {
              invoiceavailabilitycheck();
            } else {
              // invoictotalcount();
              totalinvoicecountbool = true;
            }
            _fieldFocusChange(context, SalesmanNoFocusNode, InvoiceFocusNode);
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
              _filterEnabledsalesmanno = true;
              cussiteselectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabledsalesmanno && pattern.isNotEmpty) {
            return SalesmmanList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return SalesmmanList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = SalesmmanList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndexcusname = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndexcusname = null;
            }),
            child: Container(
              color: _selectedIndexsalesmanno == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndexsalesmanno == null &&
                          SalesmmanList.indexOf(SalesmanNoController.text) ==
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
                  child: Tooltip(
                      message: suggestion,
                      child: Text(suggestion, style: TextStyle(fontSize: 13))),
                ),
              ),
            ),
          );
        },
        suggestionsBoxDecoration: const SuggestionsBoxDecoration(
          constraints: BoxConstraints(maxHeight: 150),
        ),
        onSuggestionSelected: (suggestion) async {
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
          // // CustomersiteidController..clear();
          // _handleSalesmanNoChange(suggestion);
          setState(() {
            // Take only the customer number part before the colon
            createtableData = [];
            SalesmanNoController.text = suggestion.split(':')[0];
            salemannoselectedValue = suggestion;
            _filterEnabledsalesmanno = false;

            FocusScope.of(context).requestFocus(InvoiceFocusNode);
            InvoiceNoController.clear();
          });
          InvoiceNoList = [];

          await fetchInvoiceNumbers();

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

  bool totalinvoicecountbool = false;
  // Handle customer name change
  void _handleCustomerNameChange(String newCustomer) {
    // Check if tableData has any data
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
                          createtableData = [];
                          CustomerNoController.text = newCustomer.split(':')[0];
                          cussiteselectedValue = newCustomer;
                          _filterEnabledcusname = false;

                          // Fetch operations for the new customer
                          fetchCustomerDetails();
                          fetchCustomerSiteNumbers();
                          // fetchInvoiceNumbers();
                          CustomersiteidController.clear();
                          SalesmanNoController.clear();
                          SalesmmanList = [];
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
        createtableData = [];
        // Update selected customer value and text field controller
        CustomerNoController.text = newCustomer.split(':')[0];
        cussiteselectedValue = newCustomer;
        _filterEnabledcusname = false;

        // Perform necessary fetch operations
        fetchCustomerDetails();
        fetchCustomerSiteNumbers();
        // fetchInvoiceNumbers();

        CustomersiteidController.clear();
        SalesmanNoController.clear();
        SalesmmanList = [];
        InvoiceNoController.clear();
        totalinvoicecountbool = false;
      });
    }
  }

  // Handle customer name change
  void _handleSalesmanNoChange(String newCustomer) {
    // Check if tableData has any data
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
                      'Changing the Salesman will clear the current dispatch details. Are you sure you want to proceed?',
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
                          SalesmanNoController.text = newCustomer.split(':')[0];
                          salemannoselectedValue = newCustomer;
                          _filterEnabledsalesmanno = false;

                          // Fetch operations for the new customer
                          fetchCustomerDetails();
                          fetchCustomerSiteNumbers();
                          // fetchInvoiceNumbers();
                          CustomerNoController.clear();
                          FocusScope.of(context)
                              .requestFocus(CustomerNoFocusNode);
                          CustomerNameController.clear();
                          CustomersiteidController.clear();
                        });

                        CustomerNoController.clear();
                        CustomerNameController.clear();
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
        SalesmanNoController.text = newCustomer.split(':')[0];
        salemannoselectedValue = newCustomer;
        _filterEnabledsalesmanno = false;

        fetchCustomerNumbers();
        fetchCustomerNumbers();
        // Perform necessary fetch operations
        fetchCustomerDetails();
        fetchCustomerSiteNumbers();
        // fetchInvoiceNumbers();
        FocusScope.of(context).requestFocus(CustomerNoFocusNode);
        CustomerNoController.clear();

        CustomerNameController.clear();
        CustomersiteidController.clear();
        InvoiceNoController.clear();
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
            setState(() {
              createtableData = [];
              InvoiceNoController.clear();
            });
            await fetchSalesmanList();
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
            createtableData = [];
            FocusScope.of(context).requestFocus(CustomerNameFocusNode);
            InvoiceNoController.clear();
          });
          InvoiceNoList = [];

          await fetchSalesmanList();

          // if (InvoiceNoList.isEmpty) {
          //   invoiceavailabilitycheck();
          // } else {
          //   // invoictotalcount();

          //   totalinvoicecountbool = true;
          // }
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
                SalesmanNoController.clear();

                CustomeSiteList = [];
                InvoiceNoList = [];
                SalesmmanList = [];

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

  String? selectedValue;
  bool _filterEnabled = true;
  int? _hoveredIndex;
  int? _selectedIndex;
  TextEditingController InvoiceNoController = TextEditingController();

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
                        ? screenWidth * 0.1
                        : screenWidth * 0.4,
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
            int currentIndex =
                sortedInvoiceNoList.indexOf(InvoiceNoController.text);
            if (currentIndex < sortedInvoiceNoList.length - 1) {
              setState(() {
                _selectedIndex = currentIndex + 1;
                InvoiceNoController.text =
                    sortedInvoiceNoList[currentIndex + 1];
                _filterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                sortedInvoiceNoList.indexOf(InvoiceNoController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndex = currentIndex - 1;
                InvoiceNoController.text =
                    sortedInvoiceNoList[currentIndex - 1];
                _filterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: InvoiceFocusNode,
          controller: InvoiceNoController,
          decoration: InputDecoration(
            // hintText: label,
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
            InvoiceNoController.text = suggestion;
            selectedValue = suggestion;
            _filterEnabled = false;
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
                                  Icons.assignment_returned,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Return Invoice',
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
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? MediaQuery.of(context).size.width *
                                            0.15
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
                                                    Text("Salesman No ",
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
                                                    _buildsalesmannoDropdown()),
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
                                        ? MediaQuery.of(context).size.width *
                                            0.11
                                        : MediaQuery.of(context).size.width *
                                            0.45,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Icon(Icons.receipt_long,
                                                  size: 14,
                                                  color: Colors.blue[600]),
                                              SizedBox(width: 8),
                                              Text("Invoice No",
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
                                                    _buildInvoiceNoDropdown()),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 35),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: buttonColor),
                                      height: 30,
                                      child: ElevatedButton(
                                        onPressed: _isProcessing
                                            ? null
                                            : handleGoButtonClick,
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
                                              left: 2,
                                              right: 8),
                                          child: const Text(
                                            'Go',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white),
                                          ),
                                        ),
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
                          // Assuming createtableData and checkboxStates are defined in your state class
                          // Container(
                          //   color: Colors.black,
                          //   child: SingleChildScrollView(
                          //     child: Column(
                          //       children: [
                          //         for (int index = 0;
                          //             index < createtableData.length;
                          //             index++)
                          //           Row(
                          //             children: [
                          //               Checkbox(
                          //                 value: checkboxStates[index],
                          //                 onChanged: (bool? value) {
                          //                   setState(() {
                          //                     checkboxStates[index] =
                          //                         value ?? false;
                          //                   });
                          //                 },
                          //               ),
                          //               Text(
                          //                 'For Select a ${createtableData[index]['itemdetails']}',
                          //                 style: TextStyle(
                          //                     color: Colors
                          //                         .white), // Change text color for visibility
                          //               ),
                          //             ],
                          //           ),
                          //       ],
                          //     ),
                          //   ),
                          // ),

                          Padding(
                            padding: EdgeInsets.only(
                                top: Responsive.isDesktop(context)
                                    ? MediaQuery.of(context).size.width * 0.01
                                    : 15,
                                left: 20,
                                right: 0),
                            child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.63,
                                child: _buildTable()),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 10, bottom: 5),
                                child: Container(
                                  height: 35,
                                  decoration: BoxDecoration(color: buttonColor),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (CustomerNoController.text.isEmpty ||
                                          CustomerNameController.text.isEmpty ||
                                          CustomersiteidController
                                              .text.isEmpty ||
                                          InvoiceNoController.text.isEmpty) {
                                        searchallfeild();
                                      } else {
                                        showInvoiceCancellationDialog(context);
                                        // _submitForm();
                                      }
                                      // showDialog(
                                      //   context: context,
                                      //   builder: (BuildContext context) {
                                      //     return AlertDialog(
                                      //       title: Text('Confirmation'),
                                      //       content: Text(
                                      //           'Are you sure you want to submit the table data?'),
                                      //       actions: [
                                      //         TextButton(
                                      //           onPressed: () {
                                      //             // Close the dialog
                                      //             Navigator.of(context).pop();
                                      //           },
                                      //           child: Text('No'),
                                      //         ),
                                      //         TextButton(
                                      //           onPressed: () {
                                      //             // Close the dialog first
                                      //             Navigator.of(context).pop();

                                      //             // Then run async code
                                      //             Future.delayed(Duration.zero,
                                      //                 () async {
                                      //               await _submitForm();
                                      //               setState(() {
                                      //                 CustomerNoController.clear();
                                      //                 CustomerNameController
                                      //                     .clear();
                                      //                 CustomersiteidController
                                      //                     .clear();
                                      //                 InvoiceNoController.clear();
                                      //                 createtableData = [];
                                      //                 totalinvoicecountbool = false;
                                      //               });
                                      //               print('Submitted Table Data:');
                                      //             });
                                      //           },
                                      //           child: Text('Yes'),
                                      //         ),
                                      //       ],
                                      //     );
                                      //   },
                                      // );
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
                                        'Return',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              // Padding(
                              //   padding: EdgeInsets.only(left: 10, bottom: 5),
                              //   child: Container(
                              //     height: 35,
                              //     decoration: BoxDecoration(color: buttonColor),
                              //     child: ElevatedButton(
                              //       onPressed: () {
                              //         if (CustomerNoController.text.isEmpty ||
                              //             CustomerNameController.text.isEmpty ||
                              //             CustomersiteidController
                              //                 .text.isEmpty ||
                              //             InvoiceNoController.text.isEmpty) {
                              //           searchallfeild();
                              //         } else {
                              //           showInvoiceCancellationDialogallinvoice(
                              //               context);
                              //         }
                              //       },
                              //       style: ElevatedButton.styleFrom(
                              //         shape: RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.circular(8),
                              //         ),
                              //         minimumSize: const Size(
                              //             45.0, 31.0), // Set width and height
                              //         backgroundColor: Colors
                              //             .transparent, // Make background transparent to show gradient
                              //         shadowColor: Colors
                              //             .transparent, // Disable shadow to preserve gradient
                              //       ),
                              //       child: Padding(
                              //         padding: const EdgeInsets.only(
                              //             top: 5, bottom: 5, left: 8, right: 8),
                              //         child: const Text(
                              //           'Return Invoice',
                              //           style: TextStyle(
                              //               fontSize: 14, color: Colors.white),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
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
          Icon(icon, size: 16, color: Colors.grey.shade600),
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
                    fontSize: 12,
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

  Widget _buildRemarkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            Icon(Icons.comment, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(
              'Remarks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Text field with decoration
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _remarkController,
            maxLines: 4,
            minLines: 3,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(12),
              border: InputBorder.none,
              hintText: 'Enter your remarks here...',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              // Handle text submission if needed
            },
          ),
        ),
      ],
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
                              'Successfully Returned',
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
                              'Your action has been returned successfully.',
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
                                    SalesmanNoController.clear();
                                    CustomerNoController.clear();
                                    CustomerNameController.clear();
                                    CustomersiteidController.clear();
                                    InvoiceNoController.clear();
                                    createtableData = [];
                                    totalinvoicecountbool = false;
                                    selectAllChecked = false;
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

  void showInvoiceCancellationDialogallinvoice(BuildContext context) {
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
                            'Invoice Returned',
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
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
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
                              const SizedBox(height: 14),

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
                                    const Divider(
                                        height: 16, color: Colors.grey),
                                    _buildDetailItem(
                                      icon: Icons.badge_outlined,
                                      label: 'Customer Name',
                                      value: CustomerNameController.text,
                                    ),
                                    const Divider(
                                        height: 16, color: Colors.grey),
                                    _buildDetailItem(
                                      icon: Icons.location_on_outlined,
                                      label: 'Site ID',
                                      value: CustomersiteidController.text,
                                    ),
                                    const Divider(
                                        height: 16, color: Colors.grey),
                                    _buildDetailItem(
                                      icon: Icons.receipt_outlined,
                                      label: 'Invoice No',
                                      value: InvoiceNoController.text,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildRemarkSection(),
                              const SizedBox(height: 10),

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
                                    const SizedBox(width: 10),
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

                            const SizedBox(height: 15),

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
                                      print(
                                          "Cancel confirmation button clicked");

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
                                      'Confirm Return',
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

  bool confirmIsLoading = false;

  Future<void> _onPressed() async {
    print("_confirmisLoadingaa $confirmIsLoading");
    setState(() => confirmIsLoading = true);

    print("_confirmisLoadinga111111111a $confirmIsLoading");
    try {
      print("Return confirmation button clicked");
      await _submitForm();
    } catch (e) {
      print("Exception: $e");
    } finally {
      if (mounted) {
        setState(() => confirmIsLoading = false);
      }
      print("_confirmisLoadingaa2222222222 $confirmIsLoading");
    }
  }

  void showInvoiceCancellationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool isCancelled = false;
        bool confirmIsLoading = false; // local state

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _onPressed() async {
              setState(() => confirmIsLoading = true);

              try {
                print("Return confirmation button clicked");
                await _submitForm(); // your API call
                // After success, you can close dialog if needed:
                // Navigator.pop(context);
              } catch (e) {
                print("Exception: $e");
              } finally {
                setState(() => confirmIsLoading = false);
              }
            }

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
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔴 Header
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
                          children: const [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.white, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Invoice Return',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 🔴 Content
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isCancelled) ...[
                                const Text(
                                  'You are about to Return this invoice. Please review the details below:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // 🔴 Example details card (replace with your real controllers)
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
                                      const Divider(
                                          height: 16, color: Colors.grey),
                                      _buildDetailItem(
                                        icon: Icons.badge_outlined,
                                        label: 'Customer Name',
                                        value: CustomerNameController.text,
                                      ),
                                      const Divider(
                                          height: 16, color: Colors.grey),
                                      _buildDetailItem(
                                        icon: Icons.location_on_outlined,
                                        label: 'Site ID',
                                        value: CustomersiteidController.text,
                                      ),
                                      const Divider(
                                          height: 16, color: Colors.grey),
                                      _buildDetailItem(
                                        icon: Icons.receipt_outlined,
                                        label: 'Invoice No',
                                        value: InvoiceNoController.text,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildRemarkSection(),
                                const SizedBox(height: 10),

                                // 🔴 Warning message
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
                                      const SizedBox(width: 10),
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

                              const SizedBox(height: 15),

                              // 🔴 Buttons
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
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                      onPressed:
                                          confirmIsLoading ? null : _onPressed,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade700,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: confirmIsLoading
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  "Processing...",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const Text(
                                              'Confirm Return',
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
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool isChecked = false; // State variable to manage checkbox value

  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];
  List<Map<String, dynamic>> createtableData = [];

  Future<void> fetchInvoiceDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = SalesmanNoController.text;
    String customerNumber = CustomerNoController.text;
    String invocieno = InvoiceNoController.text;
    final IpAddress = await getActiveIpAddress();

    final String initialUrl =
        '$IpAddress/invoicedetails/?salesman_no=$salesloginno&customer_number=$customerNumber&invoice_number=$invocieno';
    String? nextPageUrl = initialUrl;
    print("Invoice details URL: $nextPageUrl");

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
                // print("Invalid quantity: $invoiceqty");
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
                  // print("No balance dispatch data found.");
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
                  'itemcode': result['item_code'],
                  'itemdetails': result['description'],
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
        } else {
          // print(
          //     'Error fetching invoice details: ${response.statusCode} - ${response.body}');
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

  bool _isProcessing = false;
  Future<void> handleGoButtonClick() async {
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

        if (context.mounted) {
          isChecked = false;

          // Close the processing dialog
          Navigator.pop(context);
        }

        postLogData("Return Invoice Search Button", "Opened");
      } catch (e) {
        // Handle errors gracefully
        print('Error occurred while fetching invoice details: $e');
      } finally {
        // Reset the processing flag
        if (mounted) {
          setState(() {
            _isProcessing = false;
            // totalamountcontroller.text = '0'; // Reset total amount field
          });
        }
      }
    } else {
      // checkinvoice(); // Handle the case when the invoice number is empty
    }
  }

  List<Map<String, dynamic>> tableData = [];
  List<bool> deletedRows = [];
  List<bool> editedRows = [];
  List<bool> editingRows = []; // Track which row is currently being edited
  List<TextEditingController> balanceQtyControllers = [];
  FocusNode? _currentFocusNode;
  FocusNode focus = FocusNode();

// Add this global key for your form if you want to validate before submit
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool selectAllChecked = false;

  Widget _buildTable() {
    // Initialize controllers and flags
    if (createtableData != null) {
      if (balanceQtyControllers.length != createtableData!.length) {
        balanceQtyControllers = createtableData!.map((item) {
          final initialBalance = item['0']?.toString() ?? '0';
          return TextEditingController(text: initialBalance);
        }).toList();

        // Initialize focus nodes for each row
        _focusNodes =
            List.generate(createtableData!.length, (index) => FocusNode());

        // Initialize checkbox states
        checkboxStates = List<bool>.filled(createtableData!.length, false);
      }

      if (deletedRows.length != createtableData!.length) {
        deletedRows = List<bool>.filled(createtableData!.length, false);
      }
      if (editedRows.length != createtableData!.length) {
        editedRows = List<bool>.filled(createtableData!.length, false);
      }
      if (editingRows.length != createtableData!.length) {
        editingRows = List<bool>.filled(createtableData!.length, false);
      }
    }

    // Prepare table data
    List<Map<String, dynamic>> tableData = createtableData == null
        ? []
        : List<Map<String, dynamic>>.from(createtableData!);

    // Sort by ID
    if (tableData.isNotEmpty) {
      tableData.sort((a, b) => int.parse(a['id'].toString())
          .compareTo(int.parse(b['id'].toString())));
    }

    // Table configuration - Add checkbox column
    final headers = [
      {'label': 'Select', 'key': 'checkbox'},
      {'label': 'ID', 'key': 'id'},
      {'label': 'Item Code', 'key': 'itemcode'},
      {'label': 'Item Description', 'key': 'itemdetails'},
      {'label': 'Invoice Qty', 'key': 'invoiceqty'},
      {'label': 'Pending Dis Qty', 'key': 'dispatched_qty'},
      {'label': 'Inv Return Qty', 'key': '0'},
      {'label': 'Action', 'key': 'action'},
    ];

    Map<String, double> columnWidths = {
      'checkbox': 40,
      'id': 80,
      'itemcode': 130,
      'itemdetails': 480,
      'invoiceqty': 140,
      'dispatched_qty': 140,
      '0': 140,
      'action': 120,
    };

    // Helper widgets with reduced height
    Widget _buildHeaderCell(String label, double width) {
      if (label == 'Select') {
        return Container(
          width: width,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Center(
            child: Checkbox(
              value: selectAllChecked,
              onChanged: (bool? value) {
                setState(() {
                  selectAllChecked = value ?? false;
                  checkboxStates = List<bool>.filled(
                      checkboxStates.length, selectAllChecked);
                  deletedRows =
                      List<bool>.filled(deletedRows.length, selectAllChecked);
                });
              },
            ),
          ),
        );
      }

      return Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    Widget _buildDataCell(String? value, bool isEvenRow, int index) {
      final isDeleted = index < deletedRows.length && deletedRows[index];
      final isEditing = index < editingRows.length && editingRows[index];

      return Container(
        height: 40,
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDeleted
              ? Colors.red[100]
              : isEditing
                  ? Colors.green[100]
                  : (isEvenRow ? Color(0xFFE0FFFFFF) : Colors.white),
          border: Border.all(color: Color(0xFFE2E1E1)),
        ),
        child: Text(
          value ?? '',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isDeleted ? Colors.red : Colors.black,
            decoration: isDeleted ? TextDecoration.lineThrough : null,
          ),
        ),
      );
    }

    Widget _buildCheckboxCell(bool isEvenRow, int index) {
      final isDeleted = index < deletedRows.length && deletedRows[index];

      return Container(
        height: 40,
        padding: EdgeInsets.symmetric(vertical: 0),
        decoration: BoxDecoration(
          color: isDeleted
              ? Colors.red[100]
              : (isEvenRow ? Color(0xFFE0FFFFFF) : Colors.white),
          border: Border.all(color: Color(0xFFE2E1E1)),
        ),
        child: Checkbox(
          value: checkboxStates[index],
          onChanged: (bool? value) {
            setState(() {
              checkboxStates[index] = value ?? false;
              deletedRows[index] = value ?? false;

              // Update select all checkbox if needed
              if (!value! && selectAllChecked) {
                selectAllChecked = false;
              } else if (value && checkboxStates.every((state) => state)) {
                selectAllChecked = true;
              }
            });
          },
        ),
      );
    }

    Widget _buildEditableCell(
        TextEditingController controller, bool isEvenRow, int index) {
      final isDeleted = index < deletedRows.length && deletedRows[index];
      final isEditing = index < editingRows.length && editingRows[index];

      return Container(
        height: 40,
        padding: EdgeInsets.symmetric(vertical: 0),
        decoration: BoxDecoration(
          color: isChecked
              ? Colors.red[100]
              : isDeleted
                  ? Colors.red[100]
                  : (isEvenRow ? Color(0xFFE0FFFFFF) : Colors.white),
          border: Border.all(color: Color(0xFFE2E1E1)),
        ),
        child: TextFormField(
          focusNode: _focusNodes[index],
          controller: controller,
          enabled: !isDeleted,
          textAlign: TextAlign.center,
          textInputAction: index < _focusNodes.length - 1
              ? TextInputAction.next
              : TextInputAction.done,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          style: TextStyle(
            color: isDeleted ? Colors.red : Colors.black,
            decoration: isDeleted ? TextDecoration.lineThrough : null,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) async {
            final enteredQty = int.tryParse(value) ?? 0;
            final dispatchedQty = int.tryParse(
                    createtableData![index]['dispatched_qty']?.toString() ??
                        '0') ??
                0;

            if (enteredQty > dispatchedQty) {
              bool? shouldProceed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Quantity Exceeded'),
                  content: Text(
                      'You entered $enteredQty which exceeds dispatched quantity ($dispatchedQty).'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );

              if (shouldProceed ?? false) {
                controller.text = dispatchedQty.toString();
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );

                _saveEditedBalanceQty(index, dispatchedQty.toString());
              }
            } else {
              _saveEditedBalanceQty(index, value);
            }

            // Move focus to next field if available
            // if (index < _focusNodes.length - 1) {
            //   FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            // } else {
            FocusScope.of(context).unfocus();
            // }

            setState(() => editingRows[index] = false);
          },
          onFieldSubmitted: (value) async {
            final enteredQty = int.tryParse(value) ?? 0;
            final dispatchedQty = int.tryParse(
                    createtableData![index]['dispatched_qty']?.toString() ??
                        '0') ??
                0;

            if (enteredQty > dispatchedQty) {
              bool? shouldProceed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Quantity Exceeded'),
                  content: Text(
                      'You entered $enteredQty which exceeds dispatched quantity ($dispatchedQty).'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );

              if (shouldProceed ?? false) {
                controller.text = dispatchedQty.toString();
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );

                _saveEditedBalanceQty(index, dispatchedQty.toString());
              }
            } else {
              _saveEditedBalanceQty(index, value);
            }

            // Move focus to next field if available
            if (index < _focusNodes.length - 1) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            } else {
              FocusScope.of(context).unfocus();
            }

            setState(() => editingRows[index] = false);
          },
          onTap: () {
            setState(() {
              editingRows[index] = true;
            });
          },
        ),
      );
    }

    Widget _buildActionCell(bool isEvenRow, int index) {
      final isDeleted = index < deletedRows.length && deletedRows[index];
      final isEditing = index < editingRows.length && editingRows[index];

      return Container(
        height: 40,
        padding: EdgeInsets.symmetric(vertical: 0),
        decoration: BoxDecoration(
          color: isDeleted
              ? Colors.red[100]
              : isEditing
                  ? Colors.green[100]
                  : (isEvenRow ? Color(0xFFE0FFFFFF) : Colors.white),
          border: Border.all(color: Color(0xFFE2E1E1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.edit, size: 18),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              color: isDeleted
                  ? Colors.grey
                  : isEditing
                      ? Colors.green
                      : Colors.blue,
              onPressed: isDeleted ? null : () => _editRow(index),
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 18),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              color: isDeleted ? Colors.grey : Colors.red,
              onPressed: () => _deleteRow(index),
            ),
          ],
        ),
      );
    }

    double totalTableWidth = columnWidths.values.reduce((a, b) => a + b);

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: totalTableWidth,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: headers.map((header) {
                    final key = header['key']!;
                    return SizedBox(
                      width: columnWidths[key],
                      child: _buildHeaderCell(
                          header['label']!, columnWidths[key]!),
                    );
                  }).toList(),
                ),
                if (tableData.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("No data available"),
                  )
                else
                  ...tableData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return Row(
                      children: headers.map((header) {
                        final key = header['key']!;
                        final width = columnWidths[key]!;

                        if (key == 'action') {
                          return SizedBox(
                            width: width,
                            child: _buildActionCell(index.isEven, index),
                          );
                        } else if (key == 'checkbox') {
                          return SizedBox(
                            width: width,
                            child: _buildCheckboxCell(index.isEven, index),
                          );
                        } else if (key == '0') {
                          return SizedBox(
                            width: width,
                            child: _buildEditableCell(
                                balanceQtyControllers[index],
                                index.isEven,
                                index),
                          );
                        } else {
                          return SizedBox(
                            width: width,
                            child: _buildDataCell(
                                data[key]?.toString(), index.isEven, index),
                          );
                        }
                      }).toList(),
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteRow(int index) {
    setState(() {
      deletedRows[index] = true;
      editingRows[index] = false;
      balanceQtyControllers[index].text = '0';
      createtableData![index]['0'] = 0;
      createtableData![index]['deleted'] = true;
      createtableData![index]['edited'] = false;
    });
  }

  void _editRow(int index) {
    setState(() {
      editedRows[index] = true;
      editingRows[index] = false;
      createtableData![index]['edited'] = true;
      createtableData![index]['deleted'] = false;
      Future.delayed(Duration(milliseconds: 100), () {
        FocusScope.of(context).requestFocus(focus);
      });
    });
  }

  void _saveEditedBalanceQty(int index, String value) {
    setState(() {
      final newValue = int.tryParse(value) ?? 0;
      createtableData![index]['0'] = newValue;
      balanceQtyControllers[index].text = newValue.toString();
      editedRows[index] = true;
      editingRows[index] = false;
      createtableData![index]['edited'] = true;
      createtableData![index]['deleted'] = false;

      // Optional: Print for debugging
      print('Saved value $newValue for row $index');
    });
  }

  Future<void> postReturnInvoiceUndelivered(String cusno, String cussite,
      String invoiceno, int undel_id, int returnqty, String status) async {
    final IpAddress = await getActiveIpAddress();

    final String url = '$IpAddress/Update_Return_Invoice_Undelivered/';

    final Map<String, dynamic> requestBody = {
      "customerno": cusno,
      "customersite": cussite,
      "invoiceno": invoiceno,
      "undel_id": undel_id,
      "return_qty": returnqty,
      "flagstatus": status
    };
    print("requestBody $requestBody");
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(true);
        final data = jsonDecode(response.body);
        print("✅ Success: ${data['message']}");
        showCancellationSuccessDialog(context);
      } else {
        print("❌ Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❗ Exception: $e");
    }
  }

  // _submitForm() {
  //   // Create a new list to store the processed data
  //   List<Map<String, dynamic>> newTableData = [];

  //   // Process each row in createtableData
  //   for (int i = 0; i < createtableData!.length; i++) {
  //     final row = createtableData![i];

  //     // Create a new row with all required fields
  //     Map<String, dynamic> newRow = {
  //       'id': row['id'],
  //       'undel_id': row['undel_id'],
  //       'customer_trx_id': row['customer_trx_id'],
  //       'customer_trx_line_id': row['customer_trx_line_id'],
  //       'itemcode': row['itemcode'],
  //       'itemdetails': row['itemdetails'],
  //       'invoiceqty': row['invoiceqty'],
  //       'dispatched_qty': row['dispatched_qty'],
  //       'balanceqty': row['0'],
  //       'status': deletedRows[i]
  //           ? 'DELETED'
  //           : editedRows[i]
  //               ? 'EDITED'
  //               : 'UNCHANGED'
  //     };

  //     // Add the new row to newTableData
  //     newTableData.add(newRow);
  //   }
  //   for (int i = 0; i < newTableData!.length; i++) {
  //     final row = newTableData![i];
  //     int undelid = int.parse(row['undel_id'].toString().split('.')[0]);
  //     int balanceqty = int.parse(row['balanceqty'].toString().split('.')[0]);
  //     String status = row['status']?.toString().toLowerCase() ?? '';
  //     postReturnInvoiceUndelivered(
  //         CustomerNoController.text,
  //         CustomersiteidController.text,
  //         InvoiceNoController.text,
  //         undelid,
  //         balanceqty,
  //         status);
  //     print(
  //         'newTableDataaaaaaaaaaaaaaaaaaaaa: ${CustomerNoController.text} ${CustomersiteidController.text} ${InvoiceNoController.text} $undelid $balanceqty $status');
  //   }
  //   // // Print the newTableData in the desired format
  //   // StringBuffer output = StringBuffer();
  //   // output.writeln('Submitted Table Data:');
  //   // output.writeln('----------------------------------------');

  //   // for (int i = 0; i < newTableData.length; i++) {
  //   //   final row = newTableData[i];
  //   //   output.writeln('Row ${i + 1}:');
  //   //   output.writeln('  ID: ${row['id']}');
  //   //   output.writeln('  Item Code: ${row['itemcode']}');
  //   //   output.writeln('  Description: ${row['itemdetails']}');
  //   //   output.writeln('  Invoice Qty: ${row['invoiceqty']}');
  //   //   output.writeln('  Dispatched Qty: ${row['dispatched_qty']}');
  //   //   output.writeln('  Balance Qty: ${row['balanceqty']}');
  //   //   output.writeln('  Status: ${row['status']}');
  //   //   output.writeln('----------------------------------------');
  //   // }

  //   // // Now you can use the output string as needed (print, save, etc.)
  //   // print(output.toString());

  //   // Alternatively, you can also directly print the newTableData list

  //   print(
  //       'newTableData: $newTableData ${CustomerNoController.text} ${CustomersiteidController.text} ${CustomerNoController.text}');
  // }

  List<Map<String, dynamic>> returnhistory = [];
  // _submitForm() async {
  //   // Check if createtableData is not null
  //   if (createtableData == null || createtableData!.isEmpty) {
  //     print('createtableData is null or empty');
  //     return;
  //   }

  //   List<Map<String, dynamic>> newTableData = [];

  //   for (int i = 0; i < createtableData!.length; i++) {
  //     final row = createtableData![i];

  //     // Use safe parsing with null checks and default values
  //     var undelIdStr = row['undel_id']?.toString();
  //     var balanceQtyStr =
  //         row['0']?.toString(); // assuming balanceqty is from key '0'

  //     int undelid = 0;
  //     int balanceqty = 0;

  //     try {
  //       undelid = undelIdStr != null ? int.parse(undelIdStr.split('.')[0]) : 0;
  //     } catch (e) {
  //       print('Invalid undel_id at row $i: $undelIdStr');
  //     }

  //     try {
  //       balanceqty =
  //           balanceQtyStr != null ? int.parse(balanceQtyStr.split('.')[0]) : 0;
  //     } catch (e) {
  //       print('Invalid balanceqty at row $i: $balanceQtyStr');
  //     }

  //     String status = 'UNCHANGED';
  //     if (deletedRows.length > i && deletedRows[i] == true) {
  //       status = 'DELETED';
  //       balanceqty = row['dispatched_qty'];
  //     } else if (editedRows.length > i && editedRows[i] == true) {
  //       status = 'EDITED';
  //       balanceqty = row['0'];
  //     }

  //     Map<String, dynamic> newRow = {
  //       'id': row['id'],
  //       'undel_id': row['undel_id'],
  //       'customer_trx_id': row['customer_trx_id'],
  //       'customer_trx_line_id': row['customer_trx_line_id'],
  //       'itemcode': row['itemcode'],
  //       'itemdetails': row['itemdetails'],
  //       'invoiceqty': row['invoiceqty'],
  //       'dispatched_qty': row['dispatched_qty'],
  //       'balanceqty': balanceqty,
  //       'status': status,
  //     };

  //     newTableData.add(newRow);

  //     // // // Call the API/post method safely
  //     // postReturnInvoiceUndelivered(
  //     //   CustomerNoController.text,
  //     //   CustomersiteidController.text,
  //     //   InvoiceNoController.text,
  //     //   undelid,
  //     //   balanceqty,
  //     //   status.toLowerCase(),
  //     // );

  //     // Add to returnhistory only if status is not UNCHANGED
  //     if (status != 'UNCHANGED') {
  //       returnhistory.add(newRow);
  //     }

  //     // ✅ Send only once after building the returnhistory list
  //     if (returnhistory.isNotEmpty) {
  //       await sendInvoiceReturnData(returnhistory);
  //     } else {
  //       print("ℹ️ No changed rows to send.");
  //     }

  //     print('Processed Row $i: $undelid, $balanceqty, $status');
  //   }

  //   print('Final returnhistory: $returnhistory');
  //   print('Final newTableData: $newTableData');
  // }
  _submitForm() async {
    if (createtableData == null || createtableData!.isEmpty) {
      print('createtableData is null or empty');
      return;
    }
    await fetchTokenwithInvoiceReturnId();

    List<Map<String, dynamic>> newTableData = [];
    List<Map<String, dynamic>> returnhistory = []; // fresh list

    for (int i = 0; i < createtableData!.length; i++) {
      final row = createtableData![i];

      var undelIdStr = row['undel_id']?.toString();
      var balanceQtyStr =
          row['0']?.toString(); // assuming balanceqty from key '0'

      int undelid = 0;
      int balanceqty = 0;

      try {
        undelid = undelIdStr != null ? int.parse(undelIdStr.split('.')[0]) : 0;
      } catch (e) {
        print('Invalid undel_id at row $i: $undelIdStr');
      }

      try {
        balanceqty =
            balanceQtyStr != null ? int.parse(balanceQtyStr.split('.')[0]) : 0;
      } catch (e) {
        print('Invalid balanceqty at row $i: $balanceQtyStr');
      }

      String status = 'UNCHANGED';
      if (deletedRows.length > i && deletedRows[i] == true) {
        status = 'DELETED';
        balanceqty = safeToInt(row['dispatched_qty']);
      } else if (editedRows.length > i && editedRows[i] == true) {
        status = 'EDITED';
        balanceqty = safeToInt(row['0']);
      }

      // ✅ Skip rows with balanceqty == 0
      if (balanceqty == 0) {
        print("⚠️ Skipping row $i because balanceqty = 0");
        continue;
      }

      Map<String, dynamic> newRow = {
        'id': safeToInt(row['id']),
        'undel_id': safeToInt(row['undel_id']),
        'customer_trx_id': safeToInt(row['customer_trx_id']),
        'customer_trx_line_id': safeToInt(row['customer_trx_line_id']),
        'itemcode': row['itemcode']?.toString() ?? '',
        'itemdetails': row['itemdetails']?.toString() ?? '',
        'invoiceqty': safeToInt(row['invoiceqty']),
        'dispatched_qty': safeToInt(row['dispatched_qty']),
        'balanceqty': balanceqty,
        'status': status,
      };

      newTableData.add(newRow);

      // Call the API safely for each row
      postReturnInvoiceUndelivered(
        CustomerNoController.text,
        CustomersiteidController.text,
        InvoiceNoController.text,
        undelid,
        balanceqty,
        status.toLowerCase(),
      );

      if (status != 'UNCHANGED') {
        returnhistory.add(newRow);
      }

      print('Processed Row $i: $undelid, $balanceqty, $status');
    }

    print('Final returnhistory: $returnhistory');
    print('Final newTableData: $newTableData');

    // ✅ Only continue if returnhistory has valid rows
    if (returnhistory.isEmpty) {
      print("ℹ️ No changed rows to send. Exiting.");
      return;
    }

    await sendInvoiceReturnData(
      returnhistory,
      returnhistory.first['undel_id'] ?? 0,
    );
    _launchUrl(context, returnhistory);
  }

  /// ✅ Safe int parser: handles "974294.0", double, int, or string
  int safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value.split('.')[0]) ?? 0;
    }
    return 0;
  }

  Future<void> sendInvoiceReturnData(
      List<Map<String, dynamic>> returnhistory, int undelid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, int> totalsByUndelid = {};

    for (var row in returnhistory) {
      String undelid = row['undel_id'].toString();
      int qty = int.tryParse(row['balanceqty'].toString()) ?? 0;

      if (totalsByUndelid.containsKey(undelid)) {
        totalsByUndelid[undelid] = totalsByUndelid[undelid]! + qty;
      } else {
        totalsByUndelid[undelid] = qty;
      }
    }

    // Convert to string format
    String resultString = totalsByUndelid.entries
        .map((e) => "UndelID: ${e.key}, TotalQty: ${e.value}")
        .join(" | ");

    String saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename') ?? 'Unknown Warehouse';
    String orgIdString = prefs.getString('saleslogiOrgid') ?? '0';
    String salesloginnoString = prefs.getString('salesloginno') ?? '0';
    String saveloginname = prefs.getString('saveloginname') ?? 'Unknown Name';

    String? uniqulastreqno = prefs.getString('uniqulastreqno');

    // ✅ Safe parsing of integers
    int orgId = int.tryParse(orgIdString) ?? 0;
    int managerNo = int.tryParse(salesloginnoString) ?? 0;
    final IpAddress = await getActiveIpAddress();

    final url = Uri.parse('$IpAddress/save-invoice-return/');
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    String remarks =
        _remarkController.text.isNotEmpty ? _remarkController.text : 'null';
    for (var item in returnhistory) {
      final Map<String, dynamic> requestData = {
        "INVOICE_RETURN_ID": uniqulastreqno,
        "DATE": formattedDate,
        "ORG_ID": orgId,
        "ORG_NAME": saleslogiOrgwarehousename,
        "MANAGER_NO": managerNo,
        "MANAGER_NAME": saveloginname,
        "SALESMANO_NO": SalesmanNoController.text.trim(),
        "CUSTOMER_NUMBER": safeToInt(CustomerNoController.text.trim()),
        "CUSTOMER_NAME": CustomerNameController.text.trim(),
        "CUSTOMER_SITE_ID": safeToInt(CustomersiteidController.text.trim()),
        "INVOICE_NUMBER": InvoiceNoController.text.trim(),
        "CUSTOMER_TRX_ID": safeToInt(item['customer_trx_id']),
        "CUSTOMER_TRX_LINE_ID": safeToInt(item['customer_trx_line_id']),
        "LINE_NUMBER": safeToInt(item['id']),
        "ITEM_CODE": item['itemcode'].toString(),
        "UNDEL_ID": safeToInt(item['undel_id']),
        "ITEM_DESCRIPTION": item['itemdetails'].toString(),
        "TOT_QUANTITY": safeToInt(item['invoiceqty']),
        "DISPATCHED_QTY": safeToInt(item['dispatched_qty']),
        "RETURNED_QTY": safeToInt(item['balanceqty']),
        "FLAG_STATUS": item['status'].toString(),
        "REMARKS": remarks.toString(),
      };

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );

        if (response.statusCode == 201) {
          print('✅ Data inserted for item ${item['itemcode']}');
          postLogData(
              "Return Invoice Saved", "Invoice Returned list $resultString ");
          print('Response: ${response.body}');
        } else {
          print(
              '❌ Failed to insert item ${item['itemcode']}. Status: ${response.statusCode}');
          print('Response: ${response.body}');
          postLogData(
              "Return Invoice Saved", "Failed to insert item  $resultString ");
        }
      } catch (e) {
        print('❗ Error sending item ${item['itemcode']}: $e');
        postLogData(
            "Return Invoice Saved", "Error sending item  $resultString ");
      }
    }
  }

  _launchUrl(
      BuildContext context, List<Map<String, dynamic>> returnhistory) async {
    List<String> productDetails = [];
    int snoCounter = 1;

    print("tableDataaaaaaaaaaaaaaaa $returnhistory");

    // Function to merge table data
    List<Map<String, dynamic>> mergeTableData(
        List<Map<String, dynamic>> returnhistory) {
      Map<String, Map<String, dynamic>> mergedData = {};

      for (var item in returnhistory) {
        String key = '${item['itemcode']}-${item['itemdetails']}';
        int qty = int.tryParse(item['balanceqty']?.toString() ?? '0') ?? 0;

        if (mergedData.containsKey(key)) {
          mergedData[key]!['balanceqty'] += qty;
        } else {
          mergedData[key] = {
            'sno': snoCounter++,
            'itemcode': item['itemcode'],
            'itemdetails': item['itemdetails'],
            'balanceqty': qty,
          };
        }
      }

      return mergedData.values.toList();
    }

    // Merge data
    List<Map<String, dynamic>> mergedData = mergeTableData(returnhistory);

    // Total balance quantity
    int totalBalanceQty = 0;

    for (var data in mergedData) {
      int qty = int.tryParse(data['balanceqty'].toString()) ?? 0;
      totalBalanceQty += qty;

      String formattedProduct =
          "{${data['sno']}|x|${data['itemcode']}|${data['itemdetails']}|${data['balanceqty']}}";
      productDetails.add(formattedProduct);
    }

    // Join into one product string
    String productDetailsString = productDetails.join(',');

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? uniqulastreqno = prefs.getString('uniqulastreqno');

    String saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename') ?? 'Unknown Warehouse';
    String orgIdString = prefs.getString('saleslogiOrgid') ?? '0';
    String salesloginnoString = prefs.getString('salesloginno') ?? '0';
    String saveloginname = prefs.getString('saveloginname') ?? 'Unknown Name';

    int orgId = int.tryParse(orgIdString) ?? 0;

    String remarks =
        _remarkController.text.isNotEmpty ? _remarkController.text : 'null';

    String salesmano = SalesmanNoController.text.isNotEmpty
        ? SalesmanNoController.text
        : 'null';
    String customerno = CustomerNoController.text.isNotEmpty
        ? CustomerNoController.text
        : 'null';
    String customername = CustomerNameController.text.isNotEmpty
        ? CustomerNameController.text
        : 'null';
    String customersite = CustomersiteidController.text.isNotEmpty
        ? CustomersiteidController.text
        : 'null';
    String invoiceno =
        InvoiceNoController.text.isNotEmpty ? InvoiceNoController.text : 'null';
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Get the base IP
    final IpAddress = await getActiveIpAddress();

    // 🔗 Final dynamic URL with total qty
    // String dynamicUrl =
    //     '$IpAddress/Return_invoice_print/$uniqulastreqno/$remarks/$salesloginnoString/$saveloginname/$orgId/$formattedDate/$salesmano/$customerno/$customername/$customersite/$invoiceno/$totalBalanceQty/$productDetailsString/';

    // print('urlllllllllll : $dynamicUrl');

    // // Launch the URL
    // if (await canLaunch(dynamicUrl)) {
    //   await launch(dynamicUrl, enableJavaScript: true);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Could not launch $dynamicUrl')),
    //   );
    // }

    final ipAddress = await getActiveOracleIpAddress();

    // ✅ Build proper URL with queryParameters
    final Uri url = Uri.parse('$ipAddress/Return_invoice_print/').replace(
      queryParameters: {
        "uniqulastreqno": uniqulastreqno.toString(),
        "remarks": remarks.toString(),
        "superuserno": salesloginnoString.toString(),
        "superusername": saveloginname.toString(),
        "orgid": orgId.toString(),
        "date": formattedDate.toString(),
        "salesmano": salesmano.toString(),
        "customerNo": customerno.toString(),
        "customername": customername.toString(),
        "customersite": customersite.toString(),
        "invoiceno": invoiceno.toString(),
        "itemtotalqty": totalBalanceQty.toString(),
        "products_param": productDetailsString.toString()
      },
    );

    print('urlllllllllll : $url');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in balanceQtyControllers) {
      controller.dispose();
    }

    postLogData("Return Invoice", "Closed");
    _currentFocusNode?.dispose();
    super.dispose();
  }
}
