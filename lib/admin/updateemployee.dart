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

class Updateemployee extends StatefulWidget {
  final String topbarname;
  final String selectedaddrole;

  const Updateemployee(
      {Key? key, required this.topbarname, required this.selectedaddrole})
      : super(key: key);

  @override
  State<Updateemployee> createState() => _UpdateemployeeState();
}

class _UpdateemployeeState extends State<Updateemployee> {
  final _idController = TextEditingController();
  final EmployeeNoController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  List<Map<String, dynamic>> _userDataList = [];
  List<Map<String, dynamic>> filteredData = [];
  Set<int> _selectedOptionIndices = {}; // Set for multiple selections

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    postLogData("Search Employee", "Opened");
    _loadSalesmanName();
    _fetchUserData();
    fetchOrgIds();
    fetchDepartments();
    fetchDepRoles();
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  bool isProcessing = false;
  Future<void> fetchEmployeeData(String employeeNumber) async {
    if (employeeNumber.isEmpty) {
      return;
    }
    final IpAddress = await getActiveIpAddress();

    try {
      // Make GET request to the API with employee_number as a query parameter
      final response = await http.get(Uri.parse(
          '$IpAddress/employee-details/get_employee/?employee_number=$employeeNumber'));

      if (response.statusCode == 200) {
        // Parse the response data
        var data = json.decode(response.body);

        // Update the text fields with the fetched data
        setState(() {
          _nameController.text = data['FULL_NAME'] ?? '';
          _emailController.text = data['EMAIL_ADDRESS'] ?? 'not available';
          _usernameController.text = data['EMPLOYEE_NUMBER'] ?? '';
          _passwordController.text = '1234';
        });
      } else {
        // Handle errors or no data found
        _showWarning('Employee not found');
      }
    } catch (e) {
      // Handle connection errors or API call failure
      _showWarning('Error: $e');
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
    postLogData("Search Employee", "Closed");
  }

  bool isLoading = true;
  int currentPage = 1;

  Future<void> _fetchUserData() async {
    final IpAddress = await getActiveIpAddress();

    String apiUrl = '$IpAddress/User_member_details/';

    String url = apiUrl;
    bool hasNextPage = true;
    List<Map<String, dynamic>> filteredData = [];

    while (hasNextPage) {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List results = data['results'];

        // Filter results where FLAG = 'Y' and map them
        filteredData.addAll(
          results.where((user) => user['FLAG'] == 'Y').map((user) {
            // Safely check for 'access_control' and handle null values
            String accessControl = '';

            return {
              'id': user['id'].toString(),
              'EMPLOYEE_ID': user['EMPLOYEE_ID'],
              'EMP_NAME': user['EMP_NAME'],
              'EMP_ROLE': user['EMP_ROLE'],
              'EMP_USERNAME': user['EMP_USERNAME'],
              'EMP_PASSWORD': user['EMP_PASSWORD'],
              'EMP_MAIL': user['EMP_MAIL'],
              'ORG_ID': user['ORG_ID'],
              'ORG_NAME': user['ORG_NAME'],
              'PHYSICAL_WAREHOUSE': user['PHYSICAL_WAREHOUSE'],
              'acess_control': accessControl,
            };
          }).toList(),
        );

        // Check if there is a next page
        if (data['next'] != null) {
          url = data['next']; // Update URL for the next page
        } else {
          hasNextPage = false;
        }
      } else {
        throw Exception('Failed to load user data');
      }
    }

    // Append the filtered data to the user data list
    setState(() {
      _userDataList.addAll(filteredData);
      isLoading = false; // Update loading state
    });
  }

  void _showWarning(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: Colors.white,
              content: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.warning, color: Colors.yellow),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  Text(
                    message,
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    EmployeeNoController.text = '';
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Ok'),
                ),
              ],
            ));
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

  Future<void> fetchdetailstoupdate() async {
    final IpAddress = await getActiveIpAddress();

    String apiUrl = '$IpAddress/User_member_details/';

    String url = apiUrl;
    bool hasNextPage = true;
    String employee_id = EmployeeNoController.text;
    List<Map<String, dynamic>> filteredData = [];

    while (hasNextPage) {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List results = data['results'];

        // Filter results where FLAG = 'Y' and map them
        filteredData.addAll(
          results
              .where((user) =>
                  user['FLAG'] == 'Y' && user['EMPLOYEE_ID'] == employee_id)
              .map((user) {
            // Safely check for 'access_control' and handle null values
            String accessControl = '';
            _idController.text = user['id'].toString();
            _nameController.text = user['EMP_NAME'];

            _emailController.text = user['EMP_MAIL'];

            _Org_iddropdownController.text = user['ORG_ID'];
            _roledropdownController.text = user['EMP_ROLE'];

            regionController.text = user['ORG_NAME'];

            warehouseController.text = user['PHYSICAL_WAREHOUSE'];

            _usernameController.text = user['EMP_USERNAME'];

            _passwordController.text = user['EMP_PASSWORD'];

            return {
              'id': user['id'].toString(),
              'EMPLOYEE_ID': user['EMPLOYEE_ID'],
              'EMP_NAME': user['EMP_NAME'],
              'EMP_ROLE': user['EMP_ROLE'],
              'EMP_USERNAME': user['EMP_USERNAME'],
              'EMP_PASSWORD': user['EMP_PASSWORD'],
              'EMP_MAIL': user['EMP_MAIL'],
              'ORG_ID': user['ORG_ID'],
              'ORG_NAME': user['ORG_NAME'],
              'PHYSICAL_WAREHOUSE': user['PHYSICAL_WAREHOUSE'],
              'acess_control': accessControl,
            };
          }).toList(),
        );

        // Check if there is a next page
        if (data['next'] != null) {
          url = data['next']; // Update URL for the next page
        } else {
          hasNextPage = false;
        }
      } else {
        throw Exception('Failed to load user data');
      }
    }

    // Append the filtered data to the user data list
    setState(() {
      _userDataList.addAll(filteredData);
      isLoading = false; // Update loading state
    });
  }

  Future<void> fetchEmployeeAccessControlData(String employeeno) async {
    final IpAddress = await getActiveIpAddress();

    final String url = '$IpAddress/get_SearchEmployee_data/$employeeno/';
    print("Fetching data from URL: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Clear existing data
        selectedDepartments.clear();
        selectedAccessByRole.clear();
        selectedDepartmentRoles.clear();
        selectedRoles.clear();
        accessMap.clear();

        // ✅ Parsing departments
        if (data.containsKey('selected_departments')) {
          List<dynamic> departments = data['selected_departments'];
          selectedDepartments = departments.map((e) => e.toString()).toSet();
        }

        // ✅ Parsing department roles
        if (data.containsKey('selected_departments_wise_roles')) {
          Map<String, dynamic> rolesMap =
              data['selected_departments_wise_roles'];

          rolesMap.forEach((dept, roles) {
            selectedDepartmentRoles[dept] = List<String>.from(roles);
            selectedRoles.addAll(List<String>.from(roles)); // Add roles to set
          });
        }

        // ✅ Parsing role ID wise submenus
        if (data.containsKey('selected_role_id_wise_submenus')) {
          Map<String, dynamic> submenusMap =
              data['selected_role_id_wise_submenus'];

          submenusMap.forEach((roleId, submenus) {
            accessMap[roleId] = List<String>.from(submenus);
            selectedAccessByRole[roleId] = Set<String>.from(submenus);
          });
        }

        print("\n✅ Selected Departments: $selectedDepartments");
        print("\n✅ Selected Roles: $selectedRoles");
        print("\n✅ Access Map: $accessMap");

        setState(() {}); // Update the UI

        // Fetch the dependent roles with access
        // fetchDepRoleForms(selectedRoles);
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void fetchDepRoleForms(Set<String> selectedRoleNames) async {
    final IpAddress = await getActiveIpAddress();

    final url = "$IpAddress/DepRoleForms/";
    print("Fetching DepRoleForms from: $url");

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          accessMap.clear();
          selectedAccessByRole.clear();
          selectedRoleIds.clear();

          // Map selected roles to role IDs
          selectedRoleIds = selectedRoleNames
              .map((role) {
                var matched = depRoles
                    .firstWhere(
                      (r) => r["DEP_ROLE_NAME"] == role,
                      orElse: () => {"DEP_ROLE_ID": ""},
                    )["DEP_ROLE_ID"]
                    .toString();
                return matched;
              })
              .where((id) => id.isNotEmpty)
              .toSet();

          // Build accessMap with enabled permissions only
          for (var item in data) {
            String roleId = item['DEP_ROLE_ID'].toString();
            String submenu = item['SUBMENU'].toString();

            if (selectedRoleIds.contains(roleId)) {
              accessMap.putIfAbsent(roleId, () => []).add(submenu);
              selectedAccessByRole.putIfAbsent(roleId, () => {}).add(submenu);
            }
          }
        });
      } else {
        throw Exception("Failed to load access data");
      }
    } catch (e) {
      print("Error fetching access data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
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
                            Icon(Icons.person_add, size: 28),
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 2, right: 2),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.84,
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 20),
                              _buildTextFields(),
                              const SizedBox(height: 10),
                              Divider(),
                              const SizedBox(height: 10),
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade300,
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Wrap(
                                      spacing: 16, // Space between columns
                                      runSpacing:
                                          16, // Space between rows when wrapped
                                      children: [
                                        // In the build method
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width >
                                                  600
                                              ? MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      4 -
                                                  20
                                              : double.infinity,
                                          child: _buildSelectionPanel(
                                              "Select Departments",
                                              departments,
                                              selectedDepartments,
                                              onSelect: onDepartmentSelected,
                                              context: context),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width >
                                                  600
                                              ? MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      4 -
                                                  20
                                              : double.infinity,
                                          child: _buildRolesSelectionPanel(
                                              context: context),
                                        ),

                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width >
                                                  600
                                              ? MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      4 -
                                                  20
                                              : double.infinity,
                                          child: _buildAccessSelectionPanel(
                                              context),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          height: 40,
                                          width: 110,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              if (EmployeeNoController
                                                      .text.isEmpty ||
                                                  _nameController
                                                      .text.isEmpty ||
                                                  _usernameController
                                                      .text.isEmpty ||
                                                  _passwordController
                                                      .text.isEmpty ||
                                                  _Org_iddropdownController
                                                      .text.isEmpty ||
                                                  regionController
                                                      .text.isEmpty ||
                                                  warehouseController
                                                      .text.isEmpty ||
                                                  _emailController
                                                      .text.isEmpty) {
                                                // Show a dialog if any field is empty
                                                await showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: Row(
                                                      children: const [
                                                        Icon(Icons.warning,
                                                            color:
                                                                Colors.yellow),
                                                        SizedBox(width: 8),
                                                        Text('Warning'),
                                                      ],
                                                    ),
                                                    content: const Text(
                                                        'Kindly fill in all the fields'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text('OK'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                setState(() {
                                                  _isSaving =
                                                      false; // Reset saving state
                                                });
                                                return;
                                              }

                                              // ✅ Show confirmation dialog with progress loader
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (BuildContext context) {
                                                  bool isLoading =
                                                      false; // local state for loader

                                                  return StatefulBuilder(
                                                    builder: (context,
                                                        setStateDialog) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            "Confirmation"),
                                                        content: const Text(
                                                            "Do you want to update this employee details?"),
                                                        actions: [
                                                          // No Button
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context); // Close the dialog
                                                            },
                                                            child: const Text(
                                                                "No"),
                                                          ),
                                                          // Yes Button
                                                          TextButton(
                                                            onPressed: isLoading
                                                                ? null
                                                                : () async {
                                                                    setStateDialog(
                                                                        () {
                                                                      isLoading =
                                                                          true; // show loader
                                                                    });

                                                                    try {
                                                                      print(
                                                                          "Data Updated successfully");

                                                                      await sendEmployeeData();

                                                                      await _UpdateData(
                                                                        _idController
                                                                            .text,
                                                                        EmployeeNoController
                                                                            .text,
                                                                        _nameController
                                                                            .text,
                                                                        _usernameController
                                                                            .text,
                                                                        '1234',
                                                                        _roledropdownController
                                                                            .text,
                                                                        _Org_iddropdownController
                                                                            .text,
                                                                        regionController
                                                                            .text,
                                                                        warehouseController
                                                                            .text,
                                                                        _emailController
                                                                            .text,
                                                                      );

                                                                      // ✅ Clear and refresh
                                                                      _userDataList =
                                                                          [];
                                                                      filteredData =
                                                                          [];
                                                                      await _clearFields();
                                                                      await _fetchUserData();

                                                                      Navigator.pop(
                                                                          context); // Close dialog after success
                                                                    } catch (error) {
                                                                      print(
                                                                          "An error occurred: $error");
                                                                      // keep dialog open but reset loader
                                                                      setStateDialog(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });
                                                                    }
                                                                  },
                                                            child: isLoading
                                                                ? const SizedBox(
                                                                    width: 20,
                                                                    height: 20,
                                                                    child: CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            2),
                                                                  )
                                                                : const Text(
                                                                    "Yes"),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              );

                                              postLogData("Search Employee",
                                                  "Updated Employee ${EmployeeNoController.text}");
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              minimumSize: const Size(100, 50),
                                            ),
                                            child: isProcessing
                                                ? CircularProgressIndicator(
                                                    color: Colors
                                                        .white) // Show loading indicator
                                                : Text(
                                                    'Update',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Container(
                                            height: 40,
                                            width: 100,
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                _clearFields();

                                                postLogData(
                                                    "Search Employee", "Clear");
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                minimumSize:
                                                    const Size(100, 40),
                                              ),
                                              child: isProcessing
                                                  ? CircularProgressIndicator(
                                                      color: Colors
                                                          .white) // Show loading indicator
                                                  : Text(
                                                      'Clear',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              _buildDataTable(),
                            ],
                          ),
                        ),
                      ),
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

  List<Map<String, dynamic>> depRoles = []; // Stores Department Roles Data

  List<String> departments = [];
  List<String> roles = [];
  Set<String> selectedDepartments = {};
  Set<String> selectedRoles = {};
  Map<String, Set<String>> selectedAccessByRole = {};
  Map<String, List<String>> selectedDepartmentRoles =
      {}; // DEP_NAME -> Roles List
  Map<String, String?> selectedRolesByDepartment = {};

  Map<String, String> departmentMap = {}; // Department Name -> DEP_ID
  Map<String, List<String>> rolesMap = {}; // DEP_ID -> List of Role Names
  Map<String, List<Map<String, String>>> depRoleMap =
      {}; // DEP_ID -> List of Role Maps (DEP_ROLE_ID & NAME)
  Map<String, List<String>> accessMap = {}; // DEP_ROLE_ID -> List of Submenus

  /// **Fetch Departments**
  void fetchDepartments() async {
    final IpAddress = await getActiveIpAddress();

    final url = "$IpAddress/Departments/";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          departments = data.map((e) => e['DEP_NAME'].toString()).toList();
          departmentMap = {
            for (var e in data) e['DEP_NAME']: e['DEP_ID'].toString()
          };
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

  /// **Fetch Department Roles**
  void fetchDepRoles() async {
    final IpAddress = await getActiveIpAddress();

    final url = "$IpAddress/DepRoles/";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          depRoles = List<Map<String, dynamic>>.from(data);

          rolesMap.clear();
          depRoleMap.clear();
          for (var role in depRoles) {
            String depId = role['DEP_ID'].toString();
            String roleName = role['DEP_ROLE_NAME'].toString();
            String depRoleId = role['DEP_ROLE_ID'].toString();

            // Store role names by department ID
            rolesMap.putIfAbsent(depId, () => []).add(roleName);
            depRoleMap
                .putIfAbsent(depId, () => [])
                .add({"DEP_ROLE_ID": depRoleId, "DEP_ROLE_NAME": roleName});
          }
        });
      } else {
        throw Exception("Failed to load roles");
      }
    } catch (e) {
      print("Error fetching roles: $e");
    }
  }

  Set<String> selectedRoleIds = {};

  // void fetchDepRoleForms(Set<String> selectedRoleNames) async {
  //   final url = "$IpAddress/DepRoleForms/";
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     if (response.statusCode == 200) {
  //       List<dynamic> data = jsonDecode(response.body);

  //       setState(() {
  //         accessMap.clear();
  //         selectedAccessByRole.clear(); // ✅ Reset before updating

  //         selectedRoleIds = selectedRoleNames
  //             .map((role) {
  //               return depRoles
  //                   .firstWhere(
  //                     (r) => r["DEP_ROLE_NAME"] == role,
  //                     orElse: () => {"DEP_ROLE_ID": ""},
  //                   )["DEP_ROLE_ID"]
  //                   .toString();
  //             })
  //             .where((id) => id.isNotEmpty)
  //             .toSet();

  //         for (var item in data) {
  //           String roleId = item['DEP_ROLE_ID'].toString();
  //           String submenu = item['SUBMENU'].toString();

  //           if (selectedRoleIds.contains(roleId)) {
  //             accessMap.putIfAbsent(roleId, () => []).add(submenu);
  //             selectedAccessByRole.putIfAbsent(roleId, () => {}).add(submenu);
  //           }
  //         }
  //       });
  //     } else {
  //       throw Exception("Failed to load access data");
  //     }
  //   } catch (e) {
  //     print("Error fetching access data: $e");
  //   }
  // }

  void onDepartmentSelected(String department, bool isSelected) {
    setState(() {
      String depId = departmentMap[department] ?? '';

      if (isSelected) {
        selectedDepartments.add(department);
        selectedDepartmentRoles[department] = depRoleMap[depId]
                ?.map((e) => e['DEP_ROLE_NAME'].toString())
                .toList() ??
            [];
      } else {
        selectedDepartments.remove(department);
        selectedDepartmentRoles.remove(department);

        // Remove deselected department's roles from selectedRoles
        selectedRoles.removeWhere((role) =>
            depRoleMap[depId]?.any((r) => r['DEP_ROLE_NAME'] == role) ?? false);
      }
    });
  }

  Widget _buildSelectionPanel(
      String title, List<String> options, Set<String> selectedOptions,
      {void Function(String, bool)? onSelect, required BuildContext context}) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warehouse,
                size: 18,
              ),
              SizedBox(
                width: 5,
              ),
              Text(title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(color: Colors.grey),
          Column(
            children: options.map((option) {
              return CheckboxListTile(
                title: Text(
                  option,
                  style: TextStyle(fontSize: 13),
                ),
                value: selectedOptions.contains(option),
                onChanged: (bool? value) {
                  if (_isAnyFieldEmpty()) {
                    // ✅ Ensure context is passed correctly
                    _showMessageBox(context);
                  } else {
                    if (onSelect != null) {
                      onSelect(option, value ?? false);
                    }
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesSelectionPanel({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.supervisor_account, size: 18),
              SizedBox(width: 5),
              Text("Select Roles",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(color: Colors.grey),
          ...selectedDepartments.map((department) {
            String? depId = departmentMap[department];
            List<String>? roles = rolesMap[depId];

            if (roles != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$department:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Column(
                    children: roles.map((role) {
                      return CheckboxListTile(
                        title: Text(
                          role,
                          style: TextStyle(fontSize: 13),
                        ),
                        value: selectedRoles.contains(role),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value ?? false) {
                              // Remove previously selected role from the same department
                              selectedRoles.removeWhere((selectedRole) =>
                                  rolesMap[depId]?.contains(selectedRole) ??
                                  false);

                              // Add the new selected role
                              selectedRoles.add(role);
                            } else {
                              selectedRoles.remove(role);
                            }
                          });

                          // Fetch access based on selected roles
                          fetchDepRoleForms(selectedRoles);
                        },
                      );
                    }).toList(),
                  ),
                ],
              );
            } else {
              return SizedBox.shrink();
            }
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAccessSelectionPanel(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.file_copy,
                size: 18,
              ),
              SizedBox(
                width: 5,
              ),
              Text("Select Access",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: selectedDepartments.map((department) {
              String? depId = departmentMap[department];
              List<Map<String, String>>? depRoles = depRoleMap[depId];

              if (depRoles != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: depRoles.map((role) {
                        String roleId = role["DEP_ROLE_ID"]!;
                        String roleName = role["DEP_ROLE_NAME"]!;
                        List<String>? permissions = accessMap[roleId];

                        if (permissions != null &&
                            selectedRoles.contains(roleName)) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(color: Colors.grey),
                              Text("$department - $roleName:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              Column(
                                children: permissions.map((permission) {
                                  return CheckboxListTile(
                                    title: Text(
                                      permission,
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    value: selectedAccessByRole[roleId]
                                            ?.contains(permission) ??
                                        false, // ✅ Use selectedAccessByRole
                                    onChanged: (bool? value) {
                                      if (_isAnyFieldEmpty()) {
                                        _showMessageBox(context);
                                      } else {
                                        setState(() {
                                          if (value ?? false) {
                                            selectedAccessByRole
                                                .putIfAbsent(roleId, () => {})
                                                .add(permission);
                                          } else {
                                            selectedAccessByRole[roleId]
                                                ?.remove(permission);
                                          }
                                        });
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      }).toList(),
                    ),
                  ],
                );
              } else {
                return SizedBox.shrink();
              }
            }).toList(),
          ),
        ],
      ),
    );
  }

  void saveUserAccess() async {
    List<Map<String, dynamic>> payloadList = [];

    for (var department in selectedDepartments) {
      String? depId = departmentMap[department];

      if (depId == null) {
        print("Invalid department: $department");
        continue;
      }

      for (var role in selectedRoles) {
        var roleData = depRoles.firstWhere(
          (r) => r["DEP_ROLE_NAME"] == role && r["DEP_ID"] == depId,
          orElse: () => {},
        );

        String? roleId = roleData["DEP_ROLE_ID"]?.toString();

        if (roleId == null || roleId.isEmpty) {
          print("Invalid role: $role in department: $department");
          continue;
        }

        Set<String>? selectedAccessForRole = selectedAccessByRole[roleId];
        if (selectedAccessForRole == null || selectedAccessForRole.isEmpty) {
          print("No access selected for role: $role");
          continue;
        }

        for (var access in selectedAccessForRole) {
          var payload = {
            'DEP_ID': depId,
            'DEP_ROLE_ID': roleId,
            'EMP_ID': EmployeeNoController.text.trim(), // Ensure trimmed values
            'SUBMENU': access,
            'STATUS': '1', // Send boolean instead of string
          };

          payloadList.add(payload);
        }
      }
    }

    if (payloadList.isEmpty) {
      print("No valid data to save.");
      return;
    }

    print("Payload List: $payloadList");
    final IpAddress = await getActiveIpAddress();

    final url = "$IpAddress/SaveUserDepAccess/";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payloadList), // Send list directly
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        print("User access saved successfully.");
        _clearFields();
      } else {
        print("Failed to save user access: ${response.body}");
      }
    } catch (e) {
      print("Error while saving user access: $e");
    }
  }

  bool _isAnyFieldEmpty() {
    return EmployeeNoController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _Org_iddropdownController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        warehouseController.text.isEmpty ||
        regionController.text.isEmpty;
  }

  void _showMessageBox(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.yellow,
              ),
              Text(
                "Incomplete Details",
                style: TextStyle(fontSize: 19),
              ),
            ],
          ),
          content: Text(
              "Kindly fill the all information before selecting an option."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  final TextEditingController Organisation_Idcontroller =
      TextEditingController();
  Future<String?> fetchOrganisationId(String employeeNo) async {
    final IpAddress = await getActiveIpAddress();

    try {
      final response = await http.get(
        Uri.parse("$IpAddress/salesmanvalidemployee/$employeeNo"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['org_ids'] != null && data['org_ids'].isNotEmpty) {
          return data['org_ids'][0].toString();
        }
      }
    } catch (e) {
      print("Error fetching organisation ID: $e");
    }

    return null; // Return null if org_id is not found
  }

  // Function to show an error dialog
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Invalid Salesman"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                setState(() {
                  EmployeeNoController.clear();
                  _nameController.clear();
                  _emailController.clear();
                  _roledropdownController.clear();
                  _usernameController.clear();
                  _passwordController.clear();
                  _Org_iddropdownController.clear();
                  regionController.clear();
                  warehouseController.clear();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ✅ Function to show success dialog
  void SuucessfullyResetpassword(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Success",
            style: TextStyle(fontSize: 13),
          ),
          content: const Text(
            "Password Reset Successfully",
            style: TextStyle(fontSize: 13),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await fetchdetailstoupdate();
                await fetchEmployeeAccessControlData(EmployeeNoController.text);
              },
              child: const Text(
                "Ok",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isQuickBillEnabled = false;

  loadAccessStatus() async {
    await fetchSwapewhrSuperuserStatus();
    setState(() {}); // refresh UI after getting API result
  }

  Future<bool> fetchSwapewhrSuperuserStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String superuserno = EmployeeNoController.text.trim();

      final ipAddress = await getActiveIpAddress();
      final url =
          Uri.parse("$ipAddress/Get_employee_access_type/$superuserno/");

      // print("API URL: $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // print("API RESPONSE = $jsonData");

        // Check status and data format
        if (jsonData["status"] == "success" &&
            jsonData["data"] != null &&
            jsonData["data"] is List &&
            jsonData["data"].isNotEmpty) {
          final data = jsonData["data"][0];

          // get enable_status safely
          String enableStatus =
              (data["enable_status"] ?? "").toString().toLowerCase();

          // convert to bool
          _isQuickBillEnabled = (enableStatus == "true");

          // print("_isQuickBillEnabled = $_isQuickBillEnabled");

          return _isQuickBillEnabled;
        } else {
          print("NO DATA or INVALID DATA structure");
        }
      }

      // if failed
      _isQuickBillEnabled = false;
      return false;
    } catch (e) {
      print("Errorrrrrrrr fetching WHR Superuser: $e");
      _isQuickBillEnabled = false;
      return false;
    }
  }

  Future<bool> updateEmployeeAccess({
    required bool enableStatus,
  }) async {
    try {
      final String employeeId = EmployeeNoController.text.trim();
      final String employeeName = _nameController.text.trim();

      if (employeeId.isEmpty) {
        // print("⚠ Employee ID is empty!");
        return false;
      }

      String statusString = enableStatus ? "true" : "false";

      final ipAddress = await getActiveIpAddress();
      final url = Uri.parse("$ipAddress/Update_employee_access/");

      final Map<String, dynamic> body = {
        "employee_id": employeeId,
        "enable_status": statusString,
      };

      // print("🔍 Sending Request to: $url");
      // print("🔍 Body: $body");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      // print("🔍 Status Code: ${response.statusCode}");
      // print("🔍 Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result["status"] == "success") {
          successfullyLoginMessage(employeeId, employeeName);
          return true;
        }
      }

      return false;
    } catch (e) {
      print("❌ Error updating employee access: $e");
      return false;
    }
  }

  Future<void> successfullyLoginMessage(
      String employeeid, String employeename) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Container(
            width: MediaQuery.of(context).size.width * 0.35,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Enable Swape WHR SuperUser for\n\n$employeeid - $employeename',
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context);
  }

  // Boolean function that returns the current state
  bool isQuickBillEnabled() {
    return _isQuickBillEnabled;
  }

  void _toggleQuickBill() async {
    // Temporary new value before saving
    final bool newStatus = !_isQuickBillEnabled;

    // Call API
    bool success = await updateEmployeeAccess(enableStatus: newStatus);

    if (success) {
      // Update UI only if backend updated successfully
      setState(() {
        _isQuickBillEnabled = newStatus;
      });
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update WHR SuperUser access ")),
      );
    }
  }

  FocusNode Searchbutton = FocusNode();
  Widget _buildTextFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Column(
            children: [
              Wrap(
                runSpacing: 20,
                children: [
                  // _buildTextField(
                  //   EmployeeNoController,
                  //   'Employeeeeeeeee No',
                  //   false,
                  //   onSubmitted: (value) {
                  //     if (value.isNotEmpty) {
                  //       fetchEmployeeData(EmployeeNoController
                  //           .text); // Fetch employee details
                  //       FocusScope.of(context).requestFocus(RoleFocus);
                  //     } else {
                  //       _showWarning('Kindly enter a valid Employee No.');
                  //     }
                  //   },
                  //   // Adding the search icon
                  //   suffixIcon: Tooltip(
                  //     message: 'Search Employee',
                  //     child: IconButton(
                  //       icon: Icon(Icons.search), // Search icon
                  //       onPressed: () {
                  //         String employeeNo = EmployeeNoController.text;
                  //         if (employeeNo.isNotEmpty) {
                  //           fetchEmployeeData(
                  //               employeeNo); // Call search function on icon press
                  //           FocusScope.of(context).requestFocus(RoleFocus);
                  //         } else {
                  //           _showWarning('Kindly enter a valid Employee No.');
                  //         }
                  //       },
                  //     ),
                  //   ),
                  // ),

                  _buildTextField(
                    EmployeeNoController,
                    'Employee No',
                    _isEditing ? true : false,
                    onSubmitted: (value) {
                      if (EmployeeNoController.text.isNotEmpty) {
                        // Check if Employee No already exists in the user data list
                        print("user datas $_userDataList");
                        bool exists = _userDataList.any((user) =>
                            user['EMPLOYEE_ID'] == EmployeeNoController.text);

                        if (exists) {
                          fetchEmployeeData(EmployeeNoController.text);
                          FocusScope.of(context).requestFocus(Searchbutton);
                          fetchEmployeeData(EmployeeNoController.text);
                          fetchEmployeeData(EmployeeNoController.text);
                        }
                      } else {
                        _showWarning('Kindly enter a valid Employee No.');
                      }
                    },
                    suffixIcon: Tooltip(
                      message: 'Search Employee',
                      child: IconButton(
                        focusNode: Searchbutton,
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          // String employeeNo = EmployeeNoController.text;

                          // bool exists = _userDataList.any((user) =>
                          //     user['EMPLOYEE_ID'] == EmployeeNoController.text);

                          // if (exists) {
                          //   // Show error message if the employee already exists
                          //   showErrorDialog(
                          //       'Employee already exists in the table.');
                          //   return;
                          // } else if (employeeNo.isNotEmpty) {
                          //   fetchEmployeeData(
                          //       employeeNo); // Call search function on icon press
                          //   FocusScope.of(context).requestFocus(org_idFocus);
                          // } else {
                          //   _showWarning('Kindly enter a valid Employee No.');
                          // }

                          await postLogData("Search Employee", "Search");
                          await fetchdetailstoupdate();
                          await fetchEmployeeAccessControlData(
                              "${EmployeeNoController.text}");
                          await fetchSwapewhrSuperuserStatus();
                          setState(
                              () {}); // refresh UI after getting API result
                          print("_isQuickBillEnabled $_isQuickBillEnabled");
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildTextField(_nameController, 'Employee Name',
                      _isEditing ? true : true),
                  const SizedBox(width: 10),
                  _buildTextField(_emailController, 'Email Address',
                      _isEditing ? true : true),
                  const SizedBox(width: 10),
                  // _buildTextField(_Org_iddropdownController, 'Org_Id',
                  //     _isEditing ? true : true),
                  Container(
                      height: 40,
                      width: 200,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade100,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Org_idDropdown()),
                  const SizedBox(width: 10),
                  _buildTextField(
                      regionController, 'Region', _isEditing ? true : true),
                  const SizedBox(width: 10),

                  _buildTextField(warehouseController, 'Warehouse Name',
                      _isEditing ? true : true),
                  const SizedBox(width: 10),

                  _buildTextField(_usernameController, 'Username',
                      _isEditing ? false : true),
                  const SizedBox(width: 10),
                  _buildTextField(
                    _passwordController,
                    'Password',
                    _isEditing ? false : true,
                  ),

                  SizedBox(width: 10),
                  if (_roledropdownController.text == 'WHR SuperUser')
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 246, 246, 246),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black),
                      ),
                      width: 200,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 8, left: 10, right: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  (MediaQuery.of(context).size.width > 600
                                      ? 0.07
                                      : 0.35),
                              child: Wrap(
                                children: [
                                  Text(
                                    'Swape WHR Superuser',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 5),

                            // Toggle Button
                            GestureDetector(
                              onTap: _toggleQuickBill,
                              child: Center(
                                child: Container(
                                  width: 60,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _isQuickBillEnabled
                                        ? Colors.green
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 3,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // Sliding Circle
                                      AnimatedAlign(
                                        duration: Duration(milliseconds: 300),
                                        alignment: _isQuickBillEnabled
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Container(
                                          margin: EdgeInsets.all(3),
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 3,
                                                offset: Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            _isQuickBillEnabled
                                                ? Icons.check
                                                : Icons.close,
                                            color: _isQuickBillEnabled
                                                ? Colors.green
                                                : Colors.red,
                                            size: 14,
                                          ),
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

                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await _UpdateData(
                        _idController.text,
                        EmployeeNoController.text,
                        _nameController.text,
                        _usernameController.text,
                        '1234',
                        _roledropdownController.text,
                        _Org_iddropdownController.text,
                        regionController.text,
                        warehouseController.text,
                        _emailController.text,
                      );

                      // ✅ Clear data
                      _userDataList = [];
                      filteredData = [];

                      // ✅ Call the dialog after the functions finish
                      SuucessfullyResetpassword(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      minimumSize: const Size(100, 40),
                    ),
                    child: Text(
                      'Reset',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildTextField(
                EmployeeNoController,
                'Employee No',
                false,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    fetchEmployeeData(
                        EmployeeNoController.text); // Fetch employee details
                    FocusScope.of(context).requestFocus(org_idFocus);
                  } else {
                    _showWarning('Kindly enter a valid Employee No.');
                  }
                },
                // Adding the search icon
                suffixIcon: Tooltip(
                  message: 'Search Employeeeeeee',
                  child: IconButton(
                    icon: Icon(Icons.search), // Search icon
                    onPressed: () {
                      // String employeeNo = EmployeeNoController.text;

                      // bool exists = _userDataList.any((user) =>
                      //     user['EMPLOYEE_ID'] == EmployeeNoController.text);

                      // if (exists) {
                      //   // Show error message if the employee already exists
                      //   showErrorDialog(
                      //       'Employee already exists in the table.');
                      //   return;
                      // } else if (employeeNo.isNotEmpty) {
                      //   fetchEmployeeData(
                      //       employeeNo); // Call search function on icon press
                      //   FocusScope.of(context).requestFocus(org_idFocus);
                      // } else {
                      //   _showWarning('Kindly enter a valid Employee No.');
                      // }

                      postLogData("Search Employee", "Search");
                      fetchdetailstoupdate();
                      fetchEmployeeAccessControlData(
                          "${EmployeeNoController.text}");
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField(_nameController, 'Employee Name', true),
              const SizedBox(height: 10),
              _buildTextField(_emailController, 'Email Address', true),
              const SizedBox(height: 10),
              _buildTextField(_Org_iddropdownController, 'Org_id', true),
              const SizedBox(height: 10),
              _buildTextField(regionController, 'Region', true),
              const SizedBox(height: 10),
              _buildTextField(warehouseController, 'Warehouse Name', true),
              const SizedBox(height: 10),
              _buildTextField(_usernameController, 'Username', true),
              const SizedBox(height: 10),
              _buildTextField(
                _passwordController,
                'Password',
                true,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await _UpdateData(
                    _idController.text,
                    EmployeeNoController.text,
                    _nameController.text,
                    _usernameController.text,
                    '1234',
                    _roledropdownController.text,
                    _Org_iddropdownController.text,
                    regionController.text,
                    warehouseController.text,
                    _emailController.text,
                  );

                  // ✅ Clear data
                  _userDataList = [];
                  filteredData = [];

                  // ✅ Call the dialog after the functions finish
                  SuucessfullyResetpassword(context);

                  postLogData("Search Employee", "Reset Password");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  minimumSize: const Size(100, 40),
                ),
                child: Text(
                  'Reset',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          );
        }
      },
    );
  }

  List<String> RoleList = [
    'Salesman',
    'Sales Supervisor',
    'Manager',
    'Pickup',
    'Supervisor',
    'Load'
  ];
  List<String> Org_idList = [];

  Future<void> fetchOrgIds() async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/Physical_Warehouse/';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          Org_idList = List<String>.from(
            data['results'].map(
              (item) =>
                  '${item['ORGANIZATION_ID']} - ${item['WAREHOUSE_NAME']}',
            ),
          );
        });
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  String? selectedValue;
  FocusNode RoleFocus = FocusNode();
  int? _selectedIndex;
  bool _filterEnabled = true;
  int? _hoveredIndex;
  String? org_idselectedValue;
  FocusNode org_idFocus = FocusNode();
  int? _org_idselectedIndex;
  bool _org_idfilterEnabled = true;
  int? _org_idhoveredIndex;

  final _roledropdownController = TextEditingController();

  final _Org_iddropdownController = TextEditingController();

  final TextEditingController regionController = TextEditingController();
  final TextEditingController warehouseController = TextEditingController();

  Future<void> fetchRegionAndWarehouse() async {
    String orgId = _Org_iddropdownController.text.split(' - ')[0].trim();

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
            regionController.text = result['REGION_NAME'];
            warehouseController.text = result['WAREHOUSE_NAME'];
          });
        } else {
          // Clear the controllers if no match is found
          setState(() {
            regionController.text = '';
            warehouseController.text = '';
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

  Widget roleDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent && !_isEditing) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex = RoleList.indexOf(_roledropdownController.text);
            if (currentIndex < RoleList.length - 1) {
              setState(() {
                _selectedIndex = currentIndex + 1;
                _roledropdownController.text = RoleList[currentIndex + 1];
                _filterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = RoleList.indexOf(_roledropdownController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndex = currentIndex - 1;
                _roledropdownController.text = RoleList[currentIndex - 1];
                _filterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: RoleFocus,
          // enabled: !_isEditing, // Disable the dropdown when _isEditing is true
          onSubmitted: (String? suggestion) async {
            if (!_isEditing) {
              setState(() {
                selectedValue = suggestion;
                _roledropdownController.text = suggestion!;
                _filterEnabled = false;
                _fieldFocusChange(context, RoleFocus, org_idFocus);
              });
            }
          },
          controller: _roledropdownController,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.group,
              size: 18,
              color: const Color.fromARGB(255, 67, 67, 67),
            ),
            labelText: 'Select Role',
            labelStyle: commonLabelTextStyle.copyWith(
              color: const Color.fromARGB(255, 67, 67, 67),
            ),
            suffixIcon: Icon(
              Icons.keyboard_arrow_down_sharp,
              size: 18,
              color: const Color.fromARGB(255, 67, 67, 67),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 7.0,
            ),
          ),
          style: DropdownTextStyle,
          onChanged: (text) {
            if (!_isEditing) {
              setState(() {
                _filterEnabled = true;
                selectedValue = text.isEmpty ? null : text;

                _fieldFocusChange(context, RoleFocus, org_idFocus);
              });
            }
          },
        ),
        suggestionsCallback: (pattern) {
          return RoleList;
        },
        itemBuilder: (context, suggestion) {
          final index = RoleList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndex = null;
            }),
            child: Container(
              color: _selectedIndex == index
                  ? Colors.white
                  : _selectedIndex == null &&
                          RoleList.indexOf(_roledropdownController.text) ==
                              index
                      ? Colors.white
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
          if (!_isEditing) {
            setState(() {
              _roledropdownController.text = suggestion;
              selectedValue = suggestion;
              _filterEnabled = false;
              // FocusScope.of(context).requestFocus(_ProductNameFocus);
            });
          }
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget Org_idDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent && !_isEditing) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex = Org_idList.indexWhere((item) =>
                item.split(' - ')[0] == _Org_iddropdownController.text);
            if (currentIndex < Org_idList.length - 1) {
              setState(() {
                _org_idselectedIndex = currentIndex + 1;
                _Org_iddropdownController.text =
                    Org_idList[currentIndex + 1].split(' - ')[0];
                _org_idfilterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = Org_idList.indexWhere((item) =>
                item.split(' - ')[0] == _Org_iddropdownController.text);
            if (currentIndex > 0) {
              setState(() {
                _org_idselectedIndex = currentIndex - 1;
                _Org_iddropdownController.text =
                    Org_idList[currentIndex - 1].split(' - ')[0];
                _org_idfilterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: org_idFocus,
          onSubmitted: (String? suggestion) async {
            if (!_isEditing) {
              setState(() {
                org_idselectedValue = suggestion;
                _Org_iddropdownController.text =
                    suggestion!.split(' - ')[0]; // Set only the first part
                _org_idfilterEnabled = false;
                fetchRegionAndWarehouse();
              });
            }
          },
          controller: _Org_iddropdownController,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.business,
              size: 18,
              color: const Color.fromARGB(255, 67, 67, 67),
            ),
            labelText: 'Select Org_id',
            labelStyle: commonLabelTextStyle.copyWith(
              color: const Color.fromARGB(255, 67, 67, 67),
            ),
            suffixIcon: Icon(
              Icons.keyboard_arrow_down_sharp,
              size: 18,
              color: const Color.fromARGB(255, 67, 67, 67),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 7.0,
            ),
          ),
          style: DropdownTextStyle,
          onChanged: (text) {
            setState(() {
              _org_idfilterEnabled = true;
              org_idselectedValue = text.isEmpty ? null : text;
              fetchRegionAndWarehouse();
            });
          },
        ),
        suggestionsCallback: (pattern) {
          return Org_idList;
        },
        itemBuilder: (context, suggestion) {
          final index = Org_idList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _org_idhoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _org_idhoveredIndex = null;
            }),
            child: Container(
              color: _org_idselectedIndex == index
                  ? Colors.white
                  : _org_idselectedIndex == null &&
                          Org_idList.indexWhere((item) =>
                                  item.split(' - ')[0] ==
                                  _Org_iddropdownController.text) ==
                              index
                      ? Colors.white
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
          if (!_isEditing) {
            setState(() {
              _Org_iddropdownController.text = suggestion.split(' - ')[0];
              org_idselectedValue = suggestion.split(' - ')[0];
              _org_idfilterEnabled = false;
              fetchRegionAndWarehouse();
            });
          }
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  bool _isSaving = false; // Add this variable to track the saving state

  Future<void> _saveData(
      String uniqueId,
      String name,
      String username,
      String password,
      List<String> roles, // Change from String to List<String>
      String accessControl,
      String orgid,
      String region,
      String warehousename,
      String email) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true; // Indicate that saving is in progress
    });

    DateTime now = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

    final Map<String, String> accessControlMapping = {
      "Manager":
          '{Dashboard:true,Create Dispatch:false,Dispatch Request:true,Generate Picking:false,Pick Scan List:false,Pickup Man:false,Truck Scan:false,Generate Dispatch:false}',
      "Salesman":
          '{Dashboard:true,Create Dispatch:true,Dispatch Request:true,Pick Scan List:false,Truck Scan:false,Pickup Man:false,Generate Picking:false,Generate Dispatch:false}',
      "Sales Supervisor":
          '{Dashboard:true,Create Dispatch:true,Dispatch Request:true,Pick Scan List:false,Truck Scan:false,Pickup Man:false,Generate Picking:false,Generate Dispatch:false}',
      "Pickup":
          '{Dashboard:true,Create Dispatch:false,Dispatch Request:false,Pick Scan List:true,Truck Scan:false,Pickup Man:false,Generate Picking:false,Generate Dispatch:false}',
      "Supervisor":
          '{Dashboard:true,Create Dispatch:false,Dispatch Request:true,Pick Scan List:false,Truck Scan:false,Pickup Man:false,Generate Picking:false,Generate Dispatch:false}',
      "Load":
          '{Dashboard:true,Create Dispatch:false,Dispatch Request:false,Pick Scan List:false,Truck Scan:true,Pickup Man:false,Generate Picking:false,Generate Dispatch:false}',
    };
    final IpAddress = await getActiveIpAddress();

    final Uri url = Uri.parse('$IpAddress/User_member_details/');

    try {
      for (String role in roles) {
        // <-- Loop through each role
        String totalAccessControl = accessControlMapping[role] ?? "unknown";

        final Map<String, dynamic> requestBody = {
          "PHYSICAL_WAREHOUSE": warehousename,
          "ORG_ID": orgid,
          "ORG_NAME": region,
          "EMPLOYEE_ID": uniqueId,
          "EMP_NAME": name,
          "EMP_MAIL": email,
          "EMP_ROLE": role, // <-- Send one role per request
          "EMP_USERNAME": username,
          "EMP_PASSWORD": password,
          "CREATION_DATE": formattedDate,
          "CREATED_BY": saveloginname,
          "CREATED_IP": "null",
          "CREATED_MAC": "null",
          "LAST_UPDATE_DATE": formattedDate,
          "LAST_UPDATED_BY": "null",
          "LAST_UPDATE_IP": "null",
          "FLAG": "Y",
          "EMP_ACCESS_CONTROL": totalAccessControl
        };

        final http.Response response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 201) {
          print('User with role $role created successfully!');
        } else {
          print(
              'Failed to create user for role $role. Status: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }

      Successfullydeleted(context, "Successfully Saved");
    } catch (error) {
      print('An error occurred while saving data: $error');
    } finally {
      setState(() {
        _isSaving = false; // Reset saving state
      });
    }
  }

  Future<void> sendEmployeeData() async {
    final String empId = EmployeeNoController.text.trim();

    if (empId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Employee ID')),
      );
      return;
    }
    final IpAddress = await getActiveIpAddress();

    final String url = '$IpAddress/update_employee/$empId/';
    print('selectedRoles:  $empId ${selectedRoles.join(', ')}');
    _roledropdownController.text = '${selectedRoles.join(', ')}';
    updateEmpRole(empId, '${selectedRoles.join(', ')}');
    try {
      setState(() => isLoading = true);

      // ✅ Convert `Set<String>` to `List<String>` before encoding
      Map<String, List<String>> requestBody = selectedAccessByRole.map(
        (key, value) => MapEntry(key, value.toList()),
      );

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Success: ${responseData['message']}')),
        // );
        Navigator.of(context).pop(); // Close the current dialog

// Schedule the success message to show after current frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Successfullydeleted(context, "Updated Successfully");
        });
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed: ${response.statusCode}')),
        // );
        print('Failed response: ${response.body}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error: $e')),
      // );
      print('Exception: $e');
    }
  }

  Future<void> updateEmpRole(String employeeId, String empRole) async {
    final IpAddress = await getActiveIpAddress();

    String apiUrl = '$IpAddress/update-role/';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employee_id': employeeId,
          'emp_role': empRole,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Success: ${data['message']}');
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
    }
  }

  _clearFields() {
    // print(
    //     "selected departmensts $selectedDepartments  $selectedDepartmentRoles      $selectedAccessByRole   $selectedRoles   $selectedRoleIds   $accessMap");

    // sendEmployeeData();
    EmployeeNoController.clear();
    _nameController.clear();
    _usernameController.clear();
    _passwordController.clear();
    _emailController.clear();

    _emailController.clear();

    _Org_iddropdownController.clear();

    regionController.clear();

    warehouseController.clear();
    _roledropdownController.clear();
    _selectedOptionIndices = {0}; // Reset options if applicable
    selectedRoles.clear();
    selectedDepartments.clear();
    selectedAccessByRole.clear();
  }

  // Future<void> _UpdateData(
  //     String id,
  //     String uniqueId,
  //     String name,
  //     String username,
  //     String password,
  //     String role,
  //     String orgid,
  //     String region,
  //     String warehousename,
  //     String email) async {
  //   print(
  //       "orgranisation id ${orgid} $region   ${_Org_iddropdownController.text}");
  //   // Prevent multiple requests
  //   if (_isSaving) return;

  //   setState(() {
  //     _isSaving = true; // Indicate that saving is in progress
  //   });

  //   DateTime now = DateTime.now();
  //   // Format it to YYYY-MM-DD'T'HH:mm:ss'
  //   String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

  //   // URL for the API with the specific ID
  //   print("put id : $id");
  //   final IpAddress = await getActiveIpAddress();
  //   String password = '1234';
  //   String encodedPassword = base64.encode(utf8.encode(password));

  //   // int Id = IDController;
  //   final url = Uri.parse('$IpAddress/User_member_details/$id/');

  //   // Create the body of the PUT request
  //   final body = jsonEncode({
  //     "PHYSICAL_WAREHOUSE": warehousename,
  //     "ORG_ID": orgid,
  //     "ORG_NAME": region,
  //     "EMPLOYEE_ID": uniqueId,
  //     "EMP_NAME": name,
  //     "EMP_MAIL": email,
  //     "EMP_ROLE": role,
  //     "EMP_USERNAME": username,
  //     "EMP_PASSWORD": encodedPassword,
  //     "LAST_UPDATE_DATE": formattedDate,
  //     "LAST_UPDATED_BY": "null",
  //     "LAST_UPDATE_IP": "null",
  //     "FLAG": "Y",
  //   });

  //   try {
  //     // Send the PUT request
  //     final response = await http.put(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json', // Set the request headers
  //       },
  //       body: body,
  //     );

  //     // Check if the response was successful
  //     if (response.statusCode == 200) {
  //       print('User updated successfully!');
  //     } else {
  //       print('Failed to update user. Status code: ${response.statusCode}');
  //       // print('Response body: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error occurred: $e');
  //   } finally {
  //     setState(() {
  //       _isSaving = false; // Reset saving state
  //     });
  //   }

  //   _fetchUserData();
  // }

  Future<void> _UpdateData(
    String id,
    String uniqueId,
    String name,
    String username,
    String password,
    String role,
    String orgid,
    String region,
    String warehousename,
    String email,
  ) async {
    print('roleeeeeeeeee $role');
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final ipAddress =
          await getActiveIpAddress(); // e.g., http://192.168.10.110:8005
      final url = Uri.parse('$ipAddress/update-User_managemnet/$id/');

      DateTime now = DateTime.now();
      String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

      // Encode the password
      String encodedPassword = base64Encode(utf8.encode(password));

      final body = jsonEncode({
        "PHYSICAL_WAREHOUSE": warehousename,
        "ORG_ID": orgid,
        "ORG_NAME": region,
        "EMPLOYEE_ID": uniqueId,
        "EMP_NAME": name,
        "EMP_MAIL": email,
        "EMP_ROLE": role,
        "EMP_USERNAME": username,
        "EMP_PASSWORD": encodedPassword,
        "LAST_UPDATE_DATE": formattedDate,
        "LAST_UPDATED_BY": "null",
        "LAST_UPDATE_IP": "null",
        "FLAG": "Y",
      });

      print('🔗 PUT to: $url');
      print('📦 Body: $body');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('📬 Response status: ${response.statusCode}');
      print('📬 Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ User updated successfully!');
      } else {
        print('❌ Failed to update user. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception during update: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
      _fetchUserData();
    }
  }

  // Future<void> _UpdateData(
  //     String id,
  //     String uniqueId,
  //     String name,
  //     String username,
  //     String password,
  //     String role,
  //     String orgid,
  //     String region,
  //     String warehousename,
  //     String email) async {
  //   if (_isSaving) return;

  //   setState(() {
  //     _isSaving = true;
  //   });

  //   DateTime now = DateTime.now();
  //   String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);
  //   final IpAddress = await getActiveIpAddress();
  //   String plainPassword = '1234';
  //   // ✅ Base64 encode the password
  //   String encodedPassword =
  //       base64Encode(utf8.encode(plainPassword)); // or plainPassword
  //   final url = Uri.parse('$IpAddress/UpdateUser_member_detailsView/$id/');
  //   print('$IpAddress/UpdateUser_member_detailsView/$id/   $encodedPassword');
  //   final body = jsonEncode({
  //     "PHYSICAL_WAREHOUSE": warehousename,
  //     "ORG_ID": orgid,
  //     "ORG_NAME": region,
  //     "EMPLOYEE_ID": uniqueId,
  //     "EMP_NAME": name,
  //     "EMP_MAIL": email,
  //     "EMP_ROLE": role,
  //     "EMP_USERNAME": username,
  //     "EMP_PASSWORD": encodedPassword,
  //     "LAST_UPDATE_DATE": formattedDate,
  //     "LAST_UPDATED_BY": "null",
  //     "LAST_UPDATE_IP": "null",
  //     "FLAG": "Y",
  //   });

  //   try {
  //     final response = await http.put(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: body,
  //     );

  //     if (response.statusCode == 200) {
  //       print('User updated successfully!');
  //     } else {
  //       print('Failed to update user. Status code: ${response.statusCode}');
  //       // print('Response body: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error occurred: $e');
  //   } finally {
  //     setState(() {
  //       _isSaving = false;
  //     });
  //   }

  //   _fetchUserData();
  // }

  Future<void> _deleteData(String Id) async {
    final IpAddress = await getActiveIpAddress();

    // URL for the API with the specific ID
    final url = Uri.parse('$IpAddress/User_member_details/$Id/');
    DateTime now = DateTime.now();
    // Format it to YYYY-MM-DD'T'HH:mm:ss'
    String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

    try {
      // JSON body with the updated FLAG value
      final Map<String, dynamic> data = {
        "LAST_UPDATE_DATE": formattedDate,
        "LAST_UPDATED_BY": saveloginname,
        "FLAG": "D", // Update FLAG to "N"
      };

      // Send the PUT request with the updated data
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json', // Set the request headers
        },
        body: json.encode(data), // Encode the data as JSON
      );

      // Check if the response was successful
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Success: 200 OK or 204 No Content
        print('FLAG updated to "N" successfully!');
        // You can refresh data here if needed, e.g.:
        // fetchEmployeeNo();
        // _fetchUserData();
      } else {
        print('Failed to update FLAG. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void Successfullydeleted(BuildContext context, String contentmessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text(contentmessage),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: Text("Ok", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool readOnly, {
    void Function(String)? onSubmitted,
    Widget? suffixIcon,
  }) {
    bool isPasswordField = label == 'Password';

    return Container(
      height: 40,
      width: MediaQuery.of(context).size.width *
          (MediaQuery.of(context).size.width > 600 ? 0.15 : 0.7),
      child: TextField(
        controller: controller,
        obscureText: isPasswordField, // Hide text if it's a password field
        readOnly: readOnly,
        onSubmitted: onSubmitted, keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // Restrict to digits only
        ],
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              color: Color.fromARGB(255, 67, 67, 67), fontSize: 13),
          suffixIcon: suffixIcon,
          prefixIcon: Icon(
            label == 'Employee No'
                ? Icons.badge
                : label == 'Warehouse Name'
                    ? Icons.warehouse
                    : label == 'Region'
                        ? Icons.public
                        : label == 'Employee Name'
                            ? Icons.person
                            : label == 'Username'
                                ? Icons.account_circle
                                : label == 'Role'
                                    ? Icons.work
                                    : label == 'Email Address'
                                        ? Icons.email
                                        : label == 'Password'
                                            ? Icons.lock
                                            : Icons
                                                .info_outline, // fallback icon
            color: const Color.fromARGB(255, 67, 67, 67),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.green),
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  bool _isEditing = false;
  int? _editingIndex;

  int? _selectedRowIndex;
  int IDController = 0;
  void _populateFields(Map<String, dynamic> data) {
    setState(() {
      print("_userDataList ${data['id']}  $IDController");
      print('dataaaaaa $data  ');

      IDController = int.tryParse(data['id'] ?? '0') ?? 0;
      EmployeeNoController.text = data['EMPLOYEE_ID'] ?? '';
      _nameController.text = data['EMP_NAME'] ?? '';
      _roledropdownController.text = data['EMP_ROLE'] ?? '';
      _usernameController.text = data['EMP_USERNAME'] ?? '';
      _passwordController.text = data['EMP_PASSWORD'] ?? '';

      _emailController.text = data['EMP_MAIL'] ?? '';
      _Org_iddropdownController.text = data['ORG_ID'] ?? '';
      regionController.text = data['ORG_NAME'] ?? '';
      warehouseController.text = data['PHYSICAL_WAREHOUSE'] ?? '';

      _isEditing = true;
    });
  }

  Widget _buildDataTable() {
    double screenWidth = MediaQuery.of(context).size.width;

    // Determine if the layout should be stacked (mobile-friendly)
    bool isSmallScreen = screenWidth < 600; // Adjust threshold as needed

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row (Only for larger screens)
          if (!isSmallScreen)
            Container(
              color: Colors.blueAccent.shade100,
              child: Row(
                children: [
                  _buildTableHeaderCell('Employee No', flex: 1),
                  _buildTableHeaderCell('Name', flex: 2),
                  _buildTableHeaderCell('Role', flex: 1),
                  _buildTableHeaderCell('Username', flex: 1),
                  // _buildTableHeaderCell('Password', flex: 1),
                  // _buildTableHeaderCell('Action', flex: 1),
                ],
              ),
            ),
          // Scrollable Table Body
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: SingleChildScrollView(
              child: Column(
                children: _userDataList.asMap().entries.map((entry) {
                  int index = entry.key;
                  var data = entry.value;
                  bool isEven = index % 2 == 0;
                  return isSmallScreen
                      ? _buildStackedRow(data, isEven)
                      : _buildTableRow(
                          data, isEven, index); // Pass the index here
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Stacked Row (For Small Screens)
  Widget _buildStackedRow(Map<String, dynamic> data, bool isEven) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEven ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStackedRowItem('EMPLOYEE_ID', data['EMPLOYEE_ID'] ?? ''),
          _buildStackedRowItem('EMP_NAME', data['EMP_NAME'] ?? ''),
          _buildStackedRowItem('EMP_ROLE', data['EMP_ROLE'] ?? ''),
          _buildStackedRowItem('EMP_USERNAME', data['EMP_USERNAME'] ?? ''),
          _buildStackedRowItem('EMP_PASSWORD', data['EMP_PASSWORD'] ?? ''),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     Tooltip(
          //       message: 'Edit',
          //       child: IconButton(
          //         icon: Icon(Icons.edit, color: Colors.blueAccent.shade700),
          //         onPressed: () {
          //           _populateFields(data);
          //         },
          //       ),
          //     ),
          //     if (data['EMP_ROLE'] != 'admin')
          //       Tooltip(
          //         message: '${data['EMP_ROLE']}  Deleeeeete',
          //         child: IconButton(
          //           icon: Icon(Icons.delete, color: Colors.redAccent),
          //           onPressed: () {
          //             postLogData("Add WMS Employee", "Delete");
          //             _showDeleteConfirmationDialog(context, data['id']);
          //           },
          //         ),
          //       ),
          //   ],
          // ),
        ],
      ),
    );
  }

// Row for Larger Screens
  Widget _buildTableRow(Map<String, dynamic> data, bool isEven, int index) {
    return Container(
      color: isEven ? Colors.white : Colors.grey.shade50,
      child: Row(
        children: [
          _buildTableCell(data['EMPLOYEE_ID'] ?? '', flex: 1),
          _buildTableCell(data['EMP_NAME'] ?? '', flex: 2),
          _buildTableCell(data['EMP_ROLE'] ?? '', flex: 1),
          _buildTableCell(data['EMP_USERNAME'] ?? '', flex: 1),
          // _buildTableCell(data['EMP_PASSWORD'] ?? '', flex: 1),
          // _buildActionCell(flex: 1, index: index, data: data),
        ],
      ),
    );
  }

// Stacked Row Item
  Widget _buildStackedRowItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value ?? '',
              style: TextStyle(color: Colors.black87, fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

// Header cell design
  Widget _buildTableHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 186, 208, 244),
          border: Border(
            bottom:
                BorderSide(color: Color.fromARGB(255, 156, 191, 248), width: 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

// Body cell design with overflow handling
  Widget _buildTableCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color.fromARGB(255, 74, 70, 70),
              width: 1,
            ),
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft, // Align text to the start
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis, // Prevent overflow
            maxLines: 1, // Restrict to a single line
          ),
        ),
      ),
    );
  }

// Action cell design with icon buttons
  Widget _buildActionCell(
      {int flex = 1, required int index, required Map<String, dynamic> data}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.5, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: const Color.fromARGB(255, 74, 70, 70), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Tooltip(
              message: 'Edit',
              child: IconButton(
                icon: Icon(Icons.edit, color: Colors.blueAccent.shade700),
                onPressed: () {
                  _populateFields(data);
                },
              ),
            ),
            if (data['EMP_ROLE'] != 'admin')
              Tooltip(
                message: '${data['EMP_ROLE']}  Deleeeeete',
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, data['id']);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Role"),
          content: Text("Are you sure you want to delete this role?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog (No action)
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () async {
                // Perform the deletion action
                _idController.text = id;
                print("idcontroller : ${_idController.text}");
                await _deleteData(_idController.text);

                // Remove the item from the list immediately
                setState(() {
                  _userDataList = [];
                  filteredData = [];
                  _fetchUserData();
                });

                postLogData("Add WMS Employee", "Delete");

                // Close the dialog after deleting
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Success"),
                      content: Text("Deleted Successfully !!"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                          },
                          child:
                              Text("Ok", style: TextStyle(color: Colors.green)),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

void _showUpdateConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Success"),
        content: Text("Update Successfully !!"),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
            },
            child: Text("Ok", style: TextStyle(color: Colors.green)),
          ),
        ],
      );
    },
  );
}
