import 'dart:math';
import 'dart:convert';
import 'package:aljeflutterapp/cacheupdate.date/services/version_service.dart';
import 'package:http/http.dart' as http;
import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:aljeflutterapp/main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  bool _isSecondRowVisible = false;

  @override
  void initState() {
    super.initState();
    fetchLiveStageCount();
    sendInsertUpdateRequest();
    _loadSalesmanName();
    _fetchDispatchData();
    // Salesman
    fetchPendingInvoiceCount();
    fetchCustomerCount();
    fetchComepletedDispatch();
    fetchOnProgressDispatch();
    //Manager
    fetchWarehouseDispatch();
    fetchPendingPickCount();
    fetchLiveStagingInvoiceTypes();
    fetchDisRequestCount();
    fetchDeliveredCount();
    fetchInterORGCount();
    fetchReturnInvoiceCount();
    // Pickman
    fetchPendingPickPickmanCount();
    fetchCompletePickCount();
    fetchStageReturnCount();
    postLogData("Dashboard", "Opened");
  }

  Future<void> sendInsertUpdateRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginnoStr = prefs.getString('salesloginno');
    String? saveloginnameStr = prefs.getString('saveloginname');

    String? saleslogiOrgidStr = prefs.getString('saleslogiOrgid');
    String? saleslogiOrgwarehousenameStr =
        prefs.getString('saleslogiOrgwarehousename');

    final IpAddress = await getActiveIpAddress();
    String apiUrl = "$IpAddress/check_Insert_update_Status/";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "warehouse": "$saleslogiOrgidStr",
          "orgid": "$saleslogiOrgwarehousenameStr",
          "empid": "$salesloginnoStr",
          "empname": "$saveloginnameStr",
          "version": Version
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print(data["message"] ?? "Success");
      } else {
        final error = jsonDecode(response.body);
        // print("Error: ${error["error"] ?? "Unknown error"}");
      }
    } catch (e) {
      print("Request failed: $e");
    }
  }

  // For Dispatch

  int Pending_Invoice_count = 0;
  int customerCount = 0;
  int complete_dispatch_count = 0;
  int On_progress_dispatch_count = 0;

  // For Manager

  int dispatch_count_manager = 0;
  int pending_pick_count = 0;
  int livestage_count = 0;
  int DisReq_count = 0;
  int Delivered_count = 0;
  int InterORG_count = 0;
  int ReturnInvoice_count = 0;

// For Pickman

  int pending_pickman_count = 0;
  int complete_pick_count = 0;
  int StageReturn_Count = 0;

  bool isLoading = true;

  Future<void> fetchPendingInvoiceCount() async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/get_pending_invoice/$saveloginno/';
    // print("pending invoice url $url");
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          Pending_Invoice_count = data['pendingInvoice_count'] ??
              '0'; // Adjust based on your API response structure
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load customer count');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCustomerCount() async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/get_undelivered_customer_count/$saveloginname/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          customerCount = data['customer_count'] ??
              '0'; // Adjust based on your API response structure
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load customer count');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchComepletedDispatch() async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/get_completed_dispatches/$saveloginname/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          complete_dispatch_count = data['unscanned_invoice_count'] ??
              '0'; // Adjust based on your API response structure
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load customer count');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchOnProgressDispatch() async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/get_on_progress_dispatch/$saveloginname/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          On_progress_dispatch_count = data['scanned_invoice_count'] ??
              '0'; // Adjust based on your API response structure
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load customer count');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchWarehouseDispatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename');

    final IpAddress = await getActiveIpAddress();

    final url =
        '$IpAddress/get_dispatch_warehousecount/$saleslogiOrgwarehousename/';
    // print("dispatch cound for manager $url");
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          dispatch_count_manager = data['dispatch_invoice_count'] ??
              '0'; // Adjust based on your API response structure
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load customer count');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchPendingPickCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename');

    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/get_Pending_pick/$saleslogiOrgwarehousename/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pending_pick_count = data['count'] ?? 0; // Use null-aware operator
          isLoading = false;
        });
      } else {
        // Handle response errors
        throw Exception(
            'Failed to load pending pick count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false; // Ensure loading state is updated
      });
    }
  }

  Future<void> fetchLiveStagingInvoiceTypes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename');

    final IpAddress = await getActiveIpAddress();

    final url =
        Uri.parse('$IpAddress/LivestageCountView/$saleslogiOrgwarehousename/');
    // print("load url $IpAddress/LivestageCountView/$saleslogiOrgwarehousename/");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          livestage_count = data['invoice_count'] ?? 0; // safely assign as int
        });
      } else {
        setState(() {
          livestage_count = 0; // 0 means error
        });
      }
    } catch (e) {
      setState(() {
        livestage_count = 0; // 0 means error
      });
      print('Error: $e');
    }
  }

  List<Map<String, dynamic>> allData = [];

  int LoadmanliveStageCount = 0; // ✅ Count variable
  Future<void> fetchLiveStageCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename') ?? '';
    final IpAddress = await getActiveIpAddress();
    final String url =
        '$IpAddress/NewCombined_livestage_report/?warehousename=$saleslogiOrgwarehousename&status=on_livestage_stage';

    bool hasNextPage = true;
    String? nextPageUrl = url;

    // print("Fetching live staging count from: $url");

    try {
      while (hasNextPage && nextPageUrl != null) {
        final response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes);
          final Map<String, dynamic> responseData = json.decode(decodedBody);

          if (responseData.containsKey('results')) {
            final List<Map<String, dynamic>> currentPageData =
                List<Map<String, dynamic>>.from(responseData['results']);

            // ✅ Just count rows that match your condition
            for (var item in currentPageData) {
              if (item['PHYSICAL_WAREHOUSE']?.toString() ==
                      saleslogiOrgwarehousename &&
                  item['FLAG']?.toString() != "R" &&
                  item['truckstatus'] == true) {
                LoadmanliveStageCount++;
              }
            }

            nextPageUrl = responseData['next'];
            hasNextPage = nextPageUrl != null;
          } else {
            throw Exception('No results key found in the response');
          }
        } else {
          throw Exception('Failed to load data from server');
        }
      }

      // print("✅ Live Stage Count: $LoadmanliveStageCount");
    } catch (e) {
      print('Error fetching live stage count: $e');
    }
  }

  Future<void> fetchDisRequestCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename');
    final IpAddress = await getActiveIpAddress();

    if (saleslogiOrgwarehousename == null ||
        saleslogiOrgwarehousename.isEmpty) {
      setState(() {
        DisReq_count = 0;
      });
      // print('Warehouse name not found in SharedPreferences');
      return;
    }
    final url =
        Uri.parse('$IpAddress/get_disreq_count/$saleslogiOrgwarehousename/');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          DisReq_count = data['DisReq_count'] ?? 0;
        });
      } else {
        setState(() {
          DisReq_count = 0;
        });
        // print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        DisReq_count = 0;
      });
      print('Request failed: $e');
    }
  }

  Future<void> fetchDeliveredCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename');

    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/get_delivered_count/$saleslogiOrgwarehousename/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          Delivered_count = data['delivered_invoice_count'] ??
              '0'; // Adjust based on your API response structure
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load customer count');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchInterORGCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename');
    final IpAddress = await getActiveIpAddress();

    final url =
        '$IpAddress/get_InterORG_count/?WAREHOUSE_NAME=$saleslogiOrgwarehousename';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          InterORG_count = data['InterORG_count'] ??
              '0'; // Adjust based on your API response structure
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load customer count');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchReturnInvoiceCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename');

    final IpAddress = await getActiveIpAddress();

    final url =
        '$IpAddress/get_ReturnInvoice_count/$saleslogiOrgwarehousename/';
    // print(" returnnvlice $url");
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ReturnInvoice_count = data['ReturnInvoice_count'] ??
              '0'; // Adjust based on your API response structure
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load customer count');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchPendingPickPickmanCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saveloginname = prefs.getString('saveloginname');

    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/get_Pending_pickman_count/$saveloginname/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pending_pickman_count =
              data['pending_pick_count'] ?? 0; // Use null-aware operator
          isLoading = false;
        });
      } else {
        // Handle response errors
        throw Exception(
            'Failed to load pending pick count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false; // Ensure loading state is updated
      });
    }
  }

  Future<void> fetchCompletePickCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saveloginname = prefs.getString('saveloginname');

    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/get_pickComplete_count/$saveloginname/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          complete_pick_count =
              data['pickComplete_count'] ?? 0; // Use null-aware operator
          isLoading = false;
        });
      } else {
        // Handle response errors
        throw Exception(
            'Failed to load pending pick count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false; // Ensure loading state is updated
      });
    }
  }

  Future<void> fetchStageReturnCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saveloginname = prefs.getString('saveloginname');

    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/get_stageReturn_count/$saveloginname/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          StageReturn_Count =
              data['stagereturn_count'] ?? 0; // Use null-aware operator
          isLoading = false;
        });
      } else {
        // Handle response errors
        throw Exception(
            'Failed to load pending pick count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false; // Ensure loading state is updated
      });
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
    postLogData("Dashboard", "Closed");
  }

  String? saveloginname = '';
  String? saveloginno = '';
  String? saveloginrole = '';
  String? commersialrole = '';
  String? commersialname = '';
  String? saveloginOrgId = '';
  TextEditingController totalDispatchCountController = TextEditingController();
  TextEditingController PendingdispatchController = TextEditingController();

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
      saveloginno = prefs.getString('salesloginno') ?? 'Unknown Salesman';
      saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
      saveloginOrgId = prefs.getString('saleslogiOrgid') ?? 'Unknown Salesman';
      commersialrole =
          prefs.getString('commersialrole') ?? 'Unknown commersialrole';
      commersialname =
          prefs.getString('commersialname') ?? 'Unknown commersialname';
    });
  }

  Future<void> _fetchDispatchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginnoStr = prefs.getString('salesloginno');

    if (salesloginnoStr == null || salesloginnoStr.isEmpty) {
      // print("Salesman number not found in SharedPreferences");
      return;
    }

    double salesloginno = double.parse(salesloginnoStr);

    final IpAddress = await getActiveIpAddress();

    String url = '$IpAddress/Create_Dispatch/';
    int totalCount = 0;

    while (url.isNotEmpty) {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['results'] != null && data['results'].isNotEmpty) {
          List filteredRows = data['results'].where((row) {
            double rowsalesloginno =
                double.tryParse(row['SALESMAN_NO'].toString()) ?? 0.0;
            return rowsalesloginno == salesloginno;
          }).toList();

          totalCount += filteredRows.length;
        }

        url = data['next'] ?? '';
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        break;
      }
    }

    setState(() {
      totalDispatchCountController.text = totalCount.toString();
      PendingdispatchController.text = totalCount.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Responsive.isMobile(context)
                    ? Wrap(
                        alignment: WrapAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      AssetImage("assets/images/user.png"),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  // Ensures the Column can take remaining space
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        commersialrole == "Sales Supervisor"
                                            ? commersialname ?? 'Loading...'
                                            : saveloginname ?? 'Loading...',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                        maxLines: 2, // Adjust as needed
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        commersialrole == "Sales Supervisor"
                                            ? commersialrole ?? 'Loading...'
                                            : saveloginrole ?? 'Loading...',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Row(
                              children: [
                                Icon(Icons.dashboard,
                                    size: 28, color: Colors.blue),
                                SizedBox(width: 10),
                                Text(
                                  'Dashboard',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // User Profile Section
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.dashboard,
                                  size: 28, color: Colors.blue),
                              SizedBox(width: 10),
                              Text(
                                'Dashboard',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ],
                          ),
                          // User Profile Section
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      AssetImage("assets/images/user.png"),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      commersialrole == "Sales Supervisor"
                                          ? commersialname ?? 'Loading...'
                                          : saveloginname ?? 'Loading...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      commersialrole == "Sales Supervisor"
                                          ? commersialrole ?? 'Loading...'
                                          : saveloginrole ?? 'Loading...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
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

              // Main Content
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: Responsive.isMobile(context) ? 2 : 7,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.2,
                      children: [
                        // Cards for Salesman Role
                        if (saveloginrole == "Salesman") ...[
                          _buildStatCard(
                            Pending_Invoice_count.toString(),
                            'Pending Invoice',
                            Icons.pending,
                            Colors.blue[100]!,
                            Colors.blue,
                          ),
                          _buildStatCard(
                            On_progress_dispatch_count.toString(),
                            'On Progress Dispatch',
                            Icons.local_shipping,
                            Colors.orange[100]!,
                            Colors.orange,
                          ),
                          _buildStatCard(
                            complete_dispatch_count.toString(),
                            'Completed Dispatch',
                            Icons.check_circle,
                            Colors.green[100]!,
                            Colors.green,
                          ),
                          _buildStatCard(
                            customerCount.toString(),
                            'No. Of Customers',
                            Icons.person,
                            Colors.purple[100]!,
                            Colors.purple,
                          ),
                          _buildStatCard(
                            '0',
                            'Coming Soon',
                            Icons.announcement,
                            Colors.red[100]!,
                            Colors.red,
                          ),
                          _buildStatCard(
                            '0',
                            'Coming Soon',
                            Icons.announcement,
                            Colors.teal[100]!,
                            Colors.teal,
                          ),
                          _buildStatCard(
                            '0',
                            'Coming Soon',
                            Icons.announcement,
                            Colors.indigo[100]!,
                            Colors.indigo,
                          ),
                        ],

                        // Cards for WHR SuperUser Role
                        if (saveloginrole == "WHR SuperUser") ...[
                          _buildStatCard(
                            dispatch_count_manager.toString(),
                            'On Progress Dispatch',
                            Icons.pending,
                            Colors.blue[100]!,
                            Colors.blue,
                          ),
                          _buildStatCard(
                            pending_pick_count.toString(),
                            'Pending Pick', // Corrected spelling from "Picking Pich"
                            Icons.local_shipping,
                            Colors.orange[100]!,
                            Colors.orange,
                          ),
                          _buildStatCard(
                            LoadmanliveStageCount.toString(),
                            'Live Stage',
                            Icons.storage,
                            Colors.green[100]!,
                            Colors.green,
                          ),
                          _buildStatCard(
                            DisReq_count.toString(),
                            'Delivery Request',
                            Icons.check_circle,
                            Colors.purple[100]!,
                            Colors.purple,
                          ),
                          _buildStatCard(
                            Delivered_count.toString(),
                            'Delivered',
                            Icons.delivery_dining,
                            Colors.red[100]!,
                            Colors.red,
                          ),
                          _buildStatCard(
                            InterORG_count.toString(),
                            'Inter ORG',
                            Icons.integration_instructions,
                            Colors.teal[100]!,
                            Colors.teal,
                          ),
                          _buildStatCard(
                            ReturnInvoice_count.toString(),
                            'Return Invoice',
                            Icons.keyboard_return,
                            Colors.indigo[100]!,
                            Colors.indigo,
                          ),
                        ],

                        if (saveloginrole == "Pickup") ...[
                          _buildStatCard(
                            pending_pickman_count.toString(),
                            'Pending Pick',
                            Icons.pending,
                            Colors.blue[100]!,
                            Colors.blue,
                          ),
                          _buildStatCard(
                            complete_pick_count.toString(),
                            'Pick Completed', // Corrected spelling from "Picking Pich"
                            Icons.local_shipping,
                            Colors.orange[100]!,
                            Colors.orange,
                          ),
                          _buildStatCard(
                            StageReturn_Count.toString(),
                            ' Stage Return',
                            Icons.check_circle,
                            Colors.green[100]!,
                            Colors.green,
                          ),
                          _buildStatCard(
                            '0',
                            'Coming Soon',
                            Icons.announcement,
                            Colors.purple[100]!,
                            Colors.purple,
                          ),
                          _buildStatCard(
                            '0',
                            'Coming Soon',
                            Icons.announcement,
                            Colors.red[100]!,
                            Colors.red,
                          ),
                          _buildStatCard(
                            '0',
                            'Coming Soon',
                            Icons.announcement,
                            Colors.teal[100]!,
                            Colors.teal,
                          ),
                          _buildStatCard(
                            '0',
                            'Coming Soon',
                            Icons.announcement,
                            Colors.indigo[100]!,
                            Colors.indigo,
                          ),
                        ],

                        if (saveloginrole == "Load") ...[
                          _buildStatCard(
                            LoadmanliveStageCount.toString(),
                            'On Stage',
                            Icons.pending,
                            Colors.blue[100]!,
                            Colors.blue,
                          ),
                          _buildStatCard(
                            DisReq_count.toString(),
                            'Delivery Req', // Corrected spelling from "Picking Pich"
                            Icons.local_shipping,
                            Colors.orange[100]!,
                            Colors.orange,
                          ),
                          _buildStatCard(
                            '0',
                            'Coming Soon',
                            Icons.announcement,
                            Colors.green[100]!,
                            Colors.green,
                          ),
                          _buildStatCard(
                            '0',
                            'Coming Soon',
                            Icons.announcement,
                            Colors.purple[100]!,
                            Colors.purple,
                          ),
                          _buildStatCard(
                            '0',
                            'Coming Soon',
                            Icons.announcement,
                            Colors.red[100]!,
                            Colors.red,
                          ),
                          _buildStatCard(
                            '0',
                            'Coming Soon',
                            Icons.announcement,
                            Colors.teal[100]!,
                            Colors.teal,
                          ),
                          _buildStatCard(
                            '0',
                            'Coming Soon',
                            Icons.announcement,
                            Colors.indigo[100]!,
                            Colors.indigo,
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 30),

                    // Charts Section
                    if (!Responsive.isMobile(context))
                      if (saveloginrole != "admin")
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 10,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildRoleBasedText(saveloginrole!),
                                    SizedBox(height: 20),
                                    SizedBox(
                                      height: 300,
                                      child:
                                          buildRoleBasedChart(saveloginrole!),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 10,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Product Distribution',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 300,
                                            width: 500,
                                            child: PieChartPage(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                    if (saveloginrole == "admin")
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 100.0),
                              child: Text(
                                'Coming Soon...',
                                style:
                                    TextStyle(fontSize: 20, color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      )

                    // Recent Dispatches Table
                    // SizedBox(height: 30),
                    // Container(
                    //   padding: EdgeInsets.all(20),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(15),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.grey.withOpacity(0.1),
                    //         spreadRadius: 1,
                    //         blurRadius: 10,
                    //         offset: Offset(0, 1),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text(
                    //         'Recent Dispatches',
                    //         style: TextStyle(
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //       SizedBox(height: 20),
                    //       _buildTable(),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRoleBasedChart(String saveloginrole) {
    // print('saveloginrole: $saveloginrole');

    switch (saveloginrole.toLowerCase()) {
      case "salesman":
        return SizedBox(
          height: 300,
          child: WeeklyDispatchChart(),
        );
      case "whr superuser":
        // print('Rendering WeeklyDeliveredChart for WHR SuperUser');
        return SizedBox(
          height: 300,
          child: WeeklyDeliveredChart(),
        );
      //Uncomment and test if needed
      case "pickup":
        return SizedBox(
          height: 300,
          child: WeeklyPickChart(),
        );
      default:
        // print('Rendering default WeeklyDispatchChart');
        return SizedBox(
          height: 300,
          child: WeeklyDispatchChart(),
        );
    }
  }

  Widget buildRoleBasedText(String saveloginrole) {
    // print('saveloginrole: $saveloginrole');

    switch (saveloginrole.toLowerCase()) {
      case "salesman":
        return Text(
          'Dispatch Overview',
          style: TextStyle(fontSize: 14),
        );
      case "whr superuser":
        // print('Rendering WeeklyDeliveredChart for WHR SuperUser');
        return Text(
          'Delivered Overview',
          style: TextStyle(fontSize: 14),
        );
      //Uncomment and test if needed
      case "pickup":
        return Text(
          'Picked Overview',
          style: TextStyle(fontSize: 14),
        );
      default:
        // print('Rendering default WeeklyDispatchChart');
        return Text(
          'Dispatch Overview',
          style: TextStyle(fontSize: 14),
        );
    }
  }

  Widget _buildStatCard(String count, String label, IconData icon,
      Color bgColor, Color iconColor) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            SizedBox(height: 10),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Function to build the line chart
  Widget buildLineChart() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.circle, size: 14, color: Colors.purple),
              const SizedBox(width: 10),
              const Text(
                'Current Month: ₹ 2,00,000',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 101, 101, 101),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Mon');
                          case 1:
                            return const Text('Tue');
                          case 2:
                            return const Text('Wed');
                          case 3:
                            return const Text('Thu');
                          case 4:
                            return const Text('Fri');
                          case 5:
                            return const Text('Sat');
                          case 6:
                            return const Text('Sun');
                          default:
                            return const Text('');
                        }
                      },
                      interval: 1,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        return Text('${value.toInt()}k');
                      },
                      interval: 50,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(color: Colors.grey),
                    left: BorderSide(color: Colors.grey),
                    right: BorderSide(color: Colors.transparent),
                    top: BorderSide(color: Colors.transparent),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 100),
                      FlSpot(1, 150),
                      FlSpot(2, 80),
                      FlSpot(3, 300),
                      FlSpot(4, 100),
                      FlSpot(5, 200),
                      FlSpot(6, 250),
                    ],
                    isCurved: true,
                    color: Colors.purple,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(5, (i) {
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.blue,
            value: 60,
            title: '60%',
            radius: 60,
            titleStyle: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.green,
            value: 50,
            title: '50%',
            radius: 60,
            titleStyle: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.orange,
            value: 40,
            title: '40%',
            radius: 60,
            titleStyle: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          );
        case 3:
          return PieChartSectionData(
            color: Colors.red,
            value: 30,
            title: '30%',
            radius: 60,
            titleStyle: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          );
        case 4:
          return PieChartSectionData(
            color: Colors.yellow,
            value: 20,
            title: '20%',
            radius: 60,
            titleStyle: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          );
        default:
          throw Error();
      }
    });
  }

  List<Map<String, dynamic>> tableData = [
    {
      'id': 1,
      "ProductName": "Cooler",
      'Quantity': '150',
    },
    {
      'id': 2,
      "ProductName": "Air Conditioner",
      'Quantity': '500',
    },
    {
      'id': 3,
      "ProductName": "Refrigerator",
      'Quantity': '10',
    },
    {
      'id': 4,
      "ProductName": "Television",
      'Quantity': '200',
    },
    {
      'id': 5,
      "ProductName": "Washing Machine",
      'Quantity': '55',
    },
  ];

  Widget _buildTable() {
    double screenHeight = MediaQuery.of(context).size.height;

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
                height:
                    !Responsive.isMobile(context) ? screenHeight * 0.7 : 400,
                width: !Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width * 0.9
                    : MediaQuery.of(context).size.width * 1.4,
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _verticalScrollController,
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 10, top: 13, bottom: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                  height:
                                      !Responsive.isMobile(context) ? 25 : 30,
                                  decoration: TableHeaderColor,
                                  child: Center(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.category,
                                            size: 15,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(width: 5),
                                          Text("S.No",
                                              textAlign: TextAlign.center,
                                              style: commonLabelTextStyle),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      !Responsive.isMobile(context) ? 25 : 30,
                                  decoration: TableHeaderColor,
                                  child: Center(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.category,
                                            size: 15,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(width: 5),
                                          Text("Product Name",
                                              textAlign: TextAlign.center,
                                              style: commonLabelTextStyle),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height:
                                      !Responsive.isMobile(context) ? 25 : 30,
                                  decoration: TableHeaderColor,
                                  child: Center(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.print,
                                            size: 15,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(width: 5),
                                          Text("Quantity",
                                              textAlign: TextAlign.center,
                                              style: commonLabelTextStyle),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (tableData.isNotEmpty)
                          ...tableData.map((data) {
                            var sno = data['id'].toString();
                            var ProductName = data['ProductName'].toString();
                            var Quantity = data['Quantity'].toString();
                            bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                            Color? rowColor = isEvenRow
                                ? Color.fromARGB(224, 255, 255, 255)
                                : Color.fromARGB(224, 255, 255, 255);

                            return GestureDetector(
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10, bottom: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
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
                                        child: Center(
                                          child: Text(sno,
                                              textAlign: TextAlign.center,
                                              style: TableRowTextStyle),
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
                                        child: Center(
                                          child: Text(ProductName,
                                              textAlign: TextAlign.center,
                                              style: TableRowTextStyle),
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
                                        child: Center(
                                          child: Text(Quantity,
                                              textAlign: TextAlign.center,
                                              style: TableRowTextStyle),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList()
                      ],
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
}

class PieChartPage extends StatefulWidget {
  @override
  _PieChartPageState createState() => _PieChartPageState();
}

class _PieChartPageState extends State<PieChartPage> {
  List<dynamic> topProducts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    pieColors = _generateColors(5);
    fetchTopProducts();
  }

  // Fetch data from the URL
  Future<void> fetchTopProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginrole = prefs.getString('salesloginrole');
    String? salesloginnoStr = prefs.getString('salesloginno');
    String? saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename');

    String finalrole = salesloginrole == "WHR SuperUser"
        ? 'whrsuperuser&warehouse_name=$saleslogiOrgwarehousename'
        : 'salesman&employee_id=$salesloginnoStr';

    final IpAddress = await getActiveIpAddress();

    final url = Uri.parse('$IpAddress/top_product/?filterstatus=$finalrole');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        topProducts = json.decode(response.body);
        isLoading = false;
      });
    } else {
      // If empty or error, show default purple circle
      setState(() {
        topProducts = [];
        isLoading = false;
      });
    }
  }

  List<PieChartSectionData> showingSections() {
    if (topProducts.isEmpty) {
      return [
        PieChartSectionData(
          color: const Color.fromARGB(178, 155, 39, 176),
          value: 100,
          title: 'Coming Soon',
          radius: 60,
          titleStyle: TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ];
    }

    return List.generate(topProducts.length, (i) {
      var product = topProducts[i];
      // Convert INVENTORY_ITEM_ID to a string explicitly to avoid type errors
      var productName = product['INVENTORY_ITEM_ID'].toString() ?? 'Unknown';
      var dispatchedQty = product['total_dispatched_qty'];

      return PieChartSectionData(
        color: _getColorForIndex(i), // Function to assign colors
        value: dispatchedQty,
        title:
            '${dispatchedQty}', // Display just the number, no percentage sign
        radius: 60,
        titleStyle: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    });
  }

  // Assign different colors to the PieChart sections
  // Color _getColorForIndex(int index) {
  //   switch (index) {
  //     case 0:
  //       return Colors.green;
  //     case 1:
  //       return Colors.blue;
  //     case 2:
  //       return Colors.orange;
  //     case 3:
  //       return Colors.red;
  //     case 4:
  //       return Colors.yellow;
  //     default:
  //       return Colors.grey;
  //   }
  // }

  final Random _random = Random();
  late List<Color> pieColors; // not final if you want to regenerate later

  Color _getRandomColor() => Color.fromARGB(
      255, _random.nextInt(256), _random.nextInt(256), _random.nextInt(256));

  List<Color> _generateColors(int count) =>
      List<Color>.generate(count, (_) => _getRandomColor());

  // Use this function in your pie chart code
  Color _getColorForIndex(int index) {
    return index < pieColors.length ? pieColors[index] : _getRandomColor();
  }

  // Example: regenerate new colors on button press
  void _regenerateColors() {
    setState(() {
      pieColors = _generateColors(5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : !Responsive.isMobile(context)
              ? Row(
                  children: [
                    SizedBox(width: 50),
                    // The chart inside the grey container
                    SizedBox(
                      height: 300,
                      width: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 1,
                          centerSpaceRadius: 60,
                          sections: showingSections(),
                        ),
                      ),
                    ),
                    SizedBox(width: 50),
                    if (!Responsive.isMobile(context))
                      Container(
                        child: Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: topProducts.map((product) {
                              // Convert INVENTORY_ITEM_ID to a string explicitly
                              var productName =
                                  product['INVENTORY_ITEM_ID'].toString() ??
                                      'Unknown';
                              return Column(
                                children: [
                                  Tooltip(
                                    message: productName,
                                    child: Indicator(
                                      color: _getColorForIndex(
                                          topProducts.indexOf(product)),
                                      text: productName,
                                      isSquare: true,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                  ],
                )
              : Wrap(
                  alignment: WrapAlignment.start,
                  children: [
                    SizedBox(width: 50),
                    // The chart inside the grey container
                    SizedBox(
                      height: 300,
                      width: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 1,
                          centerSpaceRadius: 60,
                          sections: showingSections(),
                        ),
                      ),
                    ),
                    SizedBox(width: 50),
                    Container(
                      child: Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: topProducts.map((product) {
                            // Convert INVENTORY_ITEM_ID to a string explicitly
                            var productName =
                                product['INVENTORY_ITEM_ID'].toString() ??
                                    'Unknown';
                            return Column(
                              children: [
                                Indicator(
                                  color: _getColorForIndex(
                                      topProducts.indexOf(product)),
                                  text: productName,
                                  isSquare: true,
                                ),
                                SizedBox(height: 10),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;

  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    required this.isSquare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 16),
        )
      ],
    );
  }
}

class WeeklyDispatchChart extends StatefulWidget {
  @override
  State<WeeklyDispatchChart> createState() => _WeeklyDispatchChartState();
}

class _WeeklyDispatchChartState extends State<WeeklyDispatchChart> {
  String? saveloginname = '';

  // Fetch weekly dispatch data from API
  Future<List<FlSpot>> fetchWeeklyDispatches() async {
    final IpAddress = await getActiveIpAddress();

    final response = await http
        .get(Uri.parse('$IpAddress/weekly_dispatches/$saveloginname/'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> dispatches = data['weekly_dispatches'];
      return List.generate(dispatches.length, (i) {
        return FlSpot(i.toDouble(), dispatches[i].toDouble());
      });
    } else {
      throw Exception('Failed to load dispatch data');
    }
  }

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSalesmanName();
    fetchWeeklyDispatches();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FlSpot>>(
      future: fetchWeeklyDispatches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final chartData = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text('Sun');
                              case 1:
                                return const Text('Mon');
                              case 2:
                                return const Text('Tue');
                              case 3:
                                return const Text('Wed');
                              case 4:
                                return const Text('Thu');
                              case 5:
                                return const Text('Fri');
                              case 6:
                                return const Text('Sat');
                              default:
                                return const Text('');
                            }
                          },
                          interval: 1,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) =>
                              Text('${value.toInt()}'),
                          interval: 10,
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        bottom: BorderSide(color: Colors.grey),
                        left: BorderSide(color: Colors.grey),
                        right: BorderSide(color: Colors.transparent),
                        top: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WeeklyDeliveredChart extends StatefulWidget {
  @override
  State<WeeklyDeliveredChart> createState() => WeeklyDeliveredChartState();
}

class WeeklyDeliveredChartState extends State<WeeklyDeliveredChart> {
  String? saveloginname = '';
  String? saleslogiOrgwarehousename = '';

  // Fetch weekly delivered data from API
  Future<List<FlSpot>> fetchWeeklyDelivered() async {
    final IpAddress = await getActiveIpAddress();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename') ?? 'Unknown Warehouse';

    final response = await http.get(
        Uri.parse('$IpAddress/weekly_delivered/$saleslogiOrgwarehousename/'));

    // print("chanrt url $IpAddress/weekly_delivered/$saleslogiOrgwarehousename/");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> delivered = data['weekly_delivered_invoices'];
      return List.generate(delivered.length, (i) {
        return FlSpot(i.toDouble(), delivered[i].toDouble());
      });
    } else {
      throw Exception('Failed to load dispatch data');
    }
  }

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
      saleslogiOrgwarehousename =
          prefs.getString('saleslogiOrgwarehousename') ?? 'Unknown Warehouse';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSalesmanName();
    fetchWeeklyDelivered();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FlSpot>>(
      future: fetchWeeklyDelivered(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final chartData = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text('Sun');
                              case 1:
                                return const Text('Mon');
                              case 2:
                                return const Text('Tue');
                              case 3:
                                return const Text('Wed');
                              case 4:
                                return const Text('Thu');
                              case 5:
                                return const Text('Fri');
                              case 6:
                                return const Text('Sat');
                              default:
                                return const Text('');
                            }
                          },
                          interval: 1,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) =>
                              Text('${value.toInt()}'),
                          interval: 10,
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        bottom: BorderSide(color: Colors.grey),
                        left: BorderSide(color: Colors.grey),
                        right: BorderSide(color: Colors.transparent),
                        top: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData,
                        isCurved: true,
                        color: Colors.pink,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WeeklyPickChart extends StatefulWidget {
  @override
  State<WeeklyPickChart> createState() => WeeklyPickChartState();
}

class WeeklyPickChartState extends State<WeeklyPickChart> {
  String? saveloginname = '';
  String? saleslogiOrgwarehousename = '';

  // Fetch weekly delivered data from API
  Future<List<FlSpot>> fetchWeeklyPickReq() async {
    final IpAddress = await getActiveIpAddress();

    final response =
        await http.get(Uri.parse('$IpAddress/weekly_picked/$saveloginname/'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> picked = data['weekly_picked'];
      return List.generate(picked.length, (i) {
        return FlSpot(i.toDouble(), picked[i].toDouble());
      });
    } else {
      throw Exception('Failed to load dispatch data');
    }
  }

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
      saleslogiOrgwarehousename =
          prefs.getString('saleslogiOrgwarehousename') ?? 'Unknown Warehouse';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSalesmanName();
    fetchWeeklyPickReq();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FlSpot>>(
      future: fetchWeeklyPickReq(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final chartData = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text('Sun');
                              case 1:
                                return const Text('Mon');
                              case 2:
                                return const Text('Tue');
                              case 3:
                                return const Text('Wed');
                              case 4:
                                return const Text('Thu');
                              case 5:
                                return const Text('Fri');
                              case 6:
                                return const Text('Sat');
                              default:
                                return const Text('');
                            }
                          },
                          interval: 1,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) =>
                              Text('${value.toInt()}'),
                          interval: 10,
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        bottom: BorderSide(color: Colors.grey),
                        left: BorderSide(color: Colors.grey),
                        right: BorderSide(color: Colors.transparent),
                        top: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData,
                        isCurved: true,
                        color: Colors.purple,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
