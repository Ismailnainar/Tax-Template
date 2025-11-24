import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Add_Supervisor_access extends StatefulWidget {
  final String topbarname;
  final String selectedaddrole;

  const Add_Supervisor_access(
      {Key? key, required this.topbarname, required this.selectedaddrole})
      : super(key: key);

  @override
  State<Add_Supervisor_access> createState() => _Add_Supervisor_accessState();
}

class _Add_Supervisor_accessState extends State<Add_Supervisor_access> {
  @override
  void initState() {
    super.initState();
    fetchDepartments();

    postLogData("Add Supervisor Access", "Opened");
  }

  @override
  void dispose() {
    super.dispose();
    postLogData("Add Supervisor Access", "Closed");
  }

  List<String> departments = [];
  bool isLoading = true;
  void fetchDepartments() async {
    final IpAddress = await getActiveIpAddress();

    final url = "$IpAddress/Departments/";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          departments = data.map((e) => e['DEP_NAME'].toString()).toList();

          print("fetching departments: $departments");
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load departments");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching departments: $e");
    }
  }

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.all(const Color.fromARGB(
                199, 0, 0, 0)), // Set scrollbar color to always black
            trackColor:
                MaterialStateProperty.all(Colors.grey[300]), // Track color
            trackVisibility: MaterialStateProperty.all(true),
            thumbVisibility: MaterialStateProperty.all(
                true), // Ensure thumb is always visible
            thickness: MaterialStateProperty.all(6), // Scrollbar thickness
            radius: Radius.circular(10), // Rounded scrollbar edges
          ),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true, // Ensure it's always visible
            trackVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!Responsive.isMobile(context))
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey[400]!,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(width: 15),
                                Icon(Icons.person_pin_circle, size: 28),
                                SizedBox(width: 10),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    widget.topbarname,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Image.asset(
                                  "assets/images/user.png",
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      saveloginname ??
                                          'Loading...', // Display loaded name or fallback to 'Loading...'
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      saveloginrole ?? 'Loading....',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: const Color.fromARGB(
                                              255, 83, 82, 82)),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.arrow_drop_down_outlined,
                                  size: 27,
                                ),
                                const SizedBox(width: 30),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 5),
                  Wrap(
                    alignment: WrapAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 2, right: 2),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.81,
                          width: Responsive.isMobile(context)
                              ? MediaQuery.of(context).size.width * 1
                              : MediaQuery.of(context).size.width * 0.80,
                          color: Colors.white,
                          child: Add_supervisorAccess(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Add_supervisorAccess extends StatefulWidget {
  const Add_supervisorAccess({super.key});

  @override
  State<Add_supervisorAccess> createState() => _Add_supervisorAccessState();
}

class _Add_supervisorAccessState extends State<Add_supervisorAccess> {
  List<Map<String, dynamic>> departments = [];
  List<TextEditingController> controllers = [];
  List<Map<String, dynamic>> salesmanAccess = [];
  List<bool> isEditing = [];

  TextEditingController SupervisorNoController = TextEditingController();
  TextEditingController SupervisorNameController = TextEditingController();

  TextEditingController SalesmanNoController = TextEditingController();
  TextEditingController SalesmanNameController = TextEditingController();

  TextEditingController OrgIdController = TextEditingController();
  TextEditingController SalesrepIdController = TextEditingController();

  TextEditingController WarehouseCOntroller = TextEditingController();
  TextEditingController RegionNameController = TextEditingController();

  String? selectedSupervisorId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchsalessupervisordetials();
    // fetchSalesmenList();
  }

  Future<void> fetchsalessupervisordetials() async {
    final IpAddress = await getActiveIpAddress();
    String url = "$IpAddress/User_member_details/";
    List<Map<String, dynamic>> allSupervisors = [];

    try {
      while (url.isNotEmpty) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];
          final filtered = results
              .where((item) => item['EMP_ROLE'] == "Sales Supervisor")
              .map<Map<String, dynamic>>((item) => {
                    'EMP_NAME': item['EMP_NAME'],
                    'EMPLOYEE_ID': item['EMPLOYEE_ID'],
                  })
              .toList();

          allSupervisors.addAll(filtered);

          url = data['next'] ?? '';
        } else {
          throw Exception("Failed to load data from $url");
        }
      }

      setState(() {
        departments = allSupervisors;
        controllers = List.generate(
          departments.length,
          (index) =>
              TextEditingController(text: departments[index]['EMP_NAME']),
        );
        isEditing = List.generate(departments.length, (index) => false);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching departments: $e");
    }
  }

  Future<void> toggleSupervisorSelection(String supervisorId) async {
    if (selectedSupervisorId == supervisorId) {
      // If already selected, deselect and clear salesman
      setState(() {
        selectedSupervisorId = null;
        salesmanAccess = [];
      });
    } else {
      // Select new supervisor and fetch salesman
      setState(() {
        selectedSupervisorId = supervisorId;
        salesmanAccess = [];
      });

      final IpAddress = await getActiveIpAddress();

      final url = '$IpAddress/get_salesmen/$supervisorId/';

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final salesmen = data['salesmen'] as List;
          final formatted = salesmen
              .map((item) => {
                    'EMP_NAME': item['SALESMAN_NAME'],
                    'EMPLOYEE_ID': item['SALESMAN_NO'].toString(),
                  })
              .toList();

          setState(() {
            salesmanAccess = formatted;
          });
        } else {
          throw Exception("Failed to load salesmen");
        }
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  List<Map<String, dynamic>> salesmenList = []; // API result

  Future<void> fetchSalesmenList(String Supervisorno) async {
    try {
      final IpAddress = await getActiveIpAddress();
      String endpoint = Supervisorno.isNotEmpty
          ? 'get_salesmen_excluding_negative3/$Supervisorno/'
          : 'get_unassigned_supervisors/';
      final response = await http.get(Uri.parse('$IpAddress/$endpoint'));
      print("responseeeeee $IpAddress/$endpoint");
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);

        if (decodedData.containsKey('salesmen')) {
          final List<dynamic> salesmenData = decodedData['salesmen'];

          salesmenList = List<Map<String, dynamic>>.from(
            salesmenData.map((e) => Map<String, dynamic>.from(e)),
          );
          print("salesmenListsssss $salesmenList");
        } else {
          print("Key 'salesmen' not found in response.");
        }
      } else {
        print("Failed to fetch salesmen. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _showAddDialog(String Adddetails) {
    final TextEditingController DepartmentRoleController =
        TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // ✅ Rounded border
        ),
        title: const Text('Add Salesman Access'),
        content: Container(
          height: 330,
          child: Column(
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Container(
                        height: 32,
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width * 0.15
                            : MediaQuery.of(context).size.width,
                        child: departmentDropdownList(Adddetails)),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                height: 32,
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.15
                    : MediaQuery.of(context).size.width,
                child: TextField(
                  readOnly: true,
                  controller: SalesmanNameController,
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: '$Adddetails Name',
                    labelStyle: TextStyle(fontSize: 13),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                height: 32,
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.15
                    : MediaQuery.of(context).size.width,
                child: TextField(
                  readOnly: true,
                  controller: SalesrepIdController,
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Salesrep Id',
                    labelStyle: TextStyle(fontSize: 13),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                height: 32,
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.15
                    : MediaQuery.of(context).size.width,
                child: TextField(
                  readOnly: true,
                  controller: WarehouseCOntroller,
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Warehouse Name',
                    labelStyle: TextStyle(fontSize: 13),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                height: 32,
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.15
                    : MediaQuery.of(context).size.width,
                child: TextField(
                  readOnly: true,
                  controller: OrgIdController,
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Org Id',
                    labelStyle: TextStyle(fontSize: 13),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                height: 32,
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.15
                    : MediaQuery.of(context).size.width,
                child: TextField(
                  readOnly: true,
                  controller: RegionNameController,
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Region Name',
                    labelStyle: TextStyle(fontSize: 13),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              sendDataToDjango(Adddetails);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String? selectedDepId; // Selected Department ID

  String? deproleselectedValue;
  bool _filterEnabledDep_role = true;
  int? _selectedIndexDep_role;
  int? _hoveredIndexDep_role;

  Map<String, dynamic>? selectedSalesman;
  Widget departmentDropdownList(String insertdetails) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          int currentIndex = salesmenList.indexWhere(
            (item) => item['SALESREP_NUMBER'] == SalesmanNoController.text,
          );

          if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
              currentIndex < salesmenList.length - 1) {
            setState(() {
              _selectedIndexDep_role = currentIndex + 1;
              final selected = salesmenList[_selectedIndexDep_role!];
              updateSalesmanDetails(selected, insertdetails);
            });
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
              currentIndex > 0) {
            setState(() {
              _selectedIndexDep_role = currentIndex - 1;
              final selected = salesmenList[_selectedIndexDep_role!];
              updateSalesmanDetails(selected, insertdetails);
            });
          }
        }
      },
      child: TypeAheadFormField<Map<String, dynamic>>(
        textFieldConfiguration: TextFieldConfiguration(
          controller: SalesmanNoController,
          style: TextStyle(fontSize: 13),
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(201, 132, 132, 132))),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: EdgeInsets.only(bottom: 10, left: 5),
            labelText: "$insertdetails No",
            labelStyle: TextStyle(fontSize: 13),
            suffixIcon: Icon(Icons.keyboard_arrow_down, size: 18),
          ),
          onChanged: (text) {
            setState(() {
              _filterEnabledDep_role = true;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabledDep_role && pattern.isNotEmpty) {
            return salesmenList
                .where((item) => item['SALESREP_NUMBER']
                    .toLowerCase()
                    .contains(pattern.toLowerCase()))
                .toList();
          } else {
            return salesmenList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = salesmenList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndexDep_role = index),
            onExit: (_) => setState(() => _hoveredIndexDep_role = null),
            child: Container(
              color: _selectedIndexDep_role == index
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.transparent,
              height: 28,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                dense: true,
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    suggestion['SALESREP_NUMBER'],
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
          );
        },
        suggestionsBoxDecoration: const SuggestionsBoxDecoration(
            constraints: BoxConstraints(maxHeight: 150)),
        onSuggestionSelected: (suggestion) {
          setState(() {
            _selectedIndexDep_role = salesmenList.indexOf(suggestion);
            updateSalesmanDetails(suggestion, insertdetails);
          });
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('No Items Found!!!', style: TextStyle(fontSize: 13)),
        ),
      ),
    );
  }

  void updateSalesmanDetails(
      Map<String, dynamic> selected, String insertdetails) {
    SalesmanNoController.text = selected['SALESREP_NUMBER'];
    SalesmanNameController.text = selected['NAME'];
    SalesrepIdController.text = selected['SALESREP_ID'].toString();
    OrgIdController.text = selected['ORG_ID'].toString();
    WarehouseCOntroller.text = selected['ORG_NAME'] ?? '';
    RegionNameController.text = selected['REGION_NAME'] ?? '';
    _filterEnabledDep_role = false;

    // 👇 Print selected details to console
    print("Selected Salesman:");
    print("SALESREP_NUMBER: ${selected['SALESREP_NUMBER']}");
    print("NAME: ${selected['NAME']}");
    print("SALESREP_ID: ${selected['SALESREP_ID']}");
    print("ORG_ID: ${selected['ORG_ID']}");
    print("ORG_NAME (Warehouse): ${selected['ORG_NAME']}");
    print("REGION_NAME: ${selected['REGION_NAME']}");
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Success'),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Data inserted successfully!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                // Clear all fields after successful submission
                WarehouseCOntroller.clear();
                OrgIdController.clear();
                RegionNameController.clear();
                SalesrepIdController.clear();
                SalesmanNoController.clear();
                SalesmanNameController.clear();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> sendDataToDjango(String adddetails) async {
    // Validate all fields
    if (WarehouseCOntroller.text.isEmpty ||
        OrgIdController.text.isEmpty ||
        RegionNameController.text.isEmpty ||
        SalesrepIdController.text.isEmpty ||
        SalesmanNoController.text.isEmpty ||
        SalesmanNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    String supervisorno = adddetails == 'Supervisor'
        ? SalesmanNoController.text
        : SupervisorNoController.text;

    String supervisorname = adddetails == 'Supervisor'
        ? SalesmanNameController.text
        : SupervisorNameController.text;

    try {
      final IpAddress = await getActiveIpAddress();
      String baseUrl = "$IpAddress/add_supervisor_access/";
      final Uri uri = Uri.parse("$baseUrl"
          "?physical_warehouse=${WarehouseCOntroller.text}"
          "&org_id=${OrgIdController.text}"
          "&org_name=${RegionNameController.text}"
          "&supervisor_no=${supervisorno}"
          "&supervisor_name=${supervisorname}"
          "&salesrep_id=${SalesrepIdController.text}"
          "&salesman_no=${SalesmanNoController.text}"
          "&salesman_name=${SalesmanNameController.text}");
      print("datassss $baseUrl"
          "?physical_warehouse=${WarehouseCOntroller.text}"
          "&org_id=${OrgIdController.text}"
          "&org_name=${RegionNameController.text}"
          "&supervisor_no=${supervisorno}"
          "&supervisor_name=${supervisorname}"
          "&salesrep_id=${SalesrepIdController.text}"
          "&salesman_no=${SalesmanNoController.text}"
          "&salesman_name=${SalesmanNameController.text}");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        print("✅ Data inserted successfully");
        print(response.body);

        Navigator.of(context).pop();
        await _showSuccessDialog(); // Show success dialog
        await toggleSupervisorSelection(SupervisorNoController.text);
      } else {
        print("❌ Failed to insert data: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supervisor & Salesman Access",
            style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchsalessupervisordetials,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Supervisor List
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Supervisor List",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () async {
                                // Step 1: Clear all controllers
                                setState(() {
                                  SalesmanNoController.clear();
                                  SalesmanNameController.clear();
                                  SalesrepIdController.clear();
                                  WarehouseCOntroller.clear();
                                  RegionNameController.clear();
                                  OrgIdController.clear();
                                });

                                // Step 2: Fetch the salesmen list
                                await fetchSalesmenList('');

                                // Step 3: Check if list is empty
                                if (salesmenList.isEmpty) {
                                  // Show message to user
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('No Supervisors Found'),
                                        content: Text(
                                            'Kindly add the supervisor in the "Add Employee" section before assigning access permissions..'),
                                        actions: [
                                          TextButton(
                                            child: Text('OK'),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  // Step 4: Show add dialog
                                  _showAddDialog('Supervisor');
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: departments.length,
                          itemBuilder: (context, index) {
                            final supervisor = departments[index];
                            isSelected = selectedSupervisorId ==
                                supervisor['EMPLOYEE_ID'];

                            return Card(
                              color: isSelected
                                  ? Colors.blue.shade100
                                  : Colors.white,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              elevation: 3,
                              child: ListTile(
                                leading: const Icon(Icons.business,
                                    color: Colors.blue),
                                title: Tooltip(
                                  message: supervisor['EMPLOYEE_ID'].toString(),
                                  child: Text(
                                    supervisor['EMP_NAME'].toString(),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    SupervisorNoController.text =
                                        supervisor['EMPLOYEE_ID'].toString();
                                    SupervisorNameController.text =
                                        supervisor['EMP_NAME'].toString();
                                  });
                                  print(
                                      "supervisor name ${SupervisorNameController.text} ${SupervisorNoController.text}");
                                  toggleSupervisorSelection(
                                      supervisor['EMPLOYEE_ID']);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(width: 1, color: Colors.grey[300]),

                // Salesman Access
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Salesman Access",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            if (!salesmanAccess.isEmpty)
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () async {
                                  setState(() {
                                    SalesmanNoController.clear();
                                    SalesmanNameController.clear();
                                    SalesrepIdController.clear();
                                    WarehouseCOntroller.clear();
                                    RegionNameController.clear();
                                    OrgIdController.clear();
                                  });
                                  await fetchSalesmenList(
                                      SupervisorNoController.text);
                                  _showAddDialog('Salesman');
                                }, // Refresh button
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: salesmanAccess.isEmpty
                            ? const Center(
                                child: Text(
                                  "No salesman access data available.",
                                  style: TextStyle(fontSize: 13),
                                ),
                              )
                            : ListView.builder(
                                itemCount: salesmanAccess.length,
                                itemBuilder: (context, index) {
                                  final salesman = salesmanAccess[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    elevation: 3,
                                    child: ListTile(
                                      leading: const Icon(Icons.person,
                                          color: Colors.green),
                                      title: Tooltip(
                                        message:
                                            salesman['EMPLOYEE_ID'].toString(),
                                        child: Text(
                                          salesman['EMP_NAME'].toString(),
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
