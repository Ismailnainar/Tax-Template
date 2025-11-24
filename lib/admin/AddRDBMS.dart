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

class Add_RDBMSPage extends StatefulWidget {
  final String topbarname;
  final String selectedaddrole;

  const Add_RDBMSPage(
      {Key? key, required this.topbarname, required this.selectedaddrole})
      : super(key: key);

  @override
  State<Add_RDBMSPage> createState() => _Add_RDBMSPageState();
}

class _Add_RDBMSPageState extends State<Add_RDBMSPage> {
  @override
  void initState() {
    super.initState();
    fetchDepartments();

    postLogData("Add ABAC", "Opened");
  }

  @override
  void dispose() {
    super.dispose();
    postLogData("Add ABAC", "Closed");
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
                  Wrap(
                    alignment: WrapAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 2, right: 2),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.81,
                          width: Responsive.isMobile(context)
                              ? MediaQuery.of(context).size.width * 1
                              : MediaQuery.of(context).size.width * 0.27,
                          color: Colors.white,
                          child: DepartmentListScreen(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2, right: 2),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.81,
                          width: Responsive.isMobile(context)
                              ? MediaQuery.of(context).size.width * 1
                              : MediaQuery.of(context).size.width * 0.27,
                          color: Colors.white,
                          child: Dep_RoleListScreen(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2, right: 2),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.81,
                          width: Responsive.isMobile(context)
                              ? MediaQuery.of(context).size.width * 1
                              : MediaQuery.of(context).size.width * 0.27,
                          child: Dep_RoleSubmenuListScreen(),
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

class DepartmentListScreen extends StatefulWidget {
  const DepartmentListScreen({super.key});

  @override
  State<DepartmentListScreen> createState() => _DepartmentListScreenState();
}

class _DepartmentListScreenState extends State<DepartmentListScreen> {
  List<Map<String, dynamic>> departments = [];
  List<TextEditingController> controllers = [];
  List<bool> isEditing = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  // Fetch departments from API
  Future<void> fetchDepartments() async {
    final IpAddress = await getActiveIpAddress();

    final url = "$IpAddress/Departments/";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          departments = List<Map<String, dynamic>>.from(data);
          controllers = List.generate(
              departments.length,
              (index) =>
                  TextEditingController(text: departments[index]['DEP_NAME']));
          isEditing = List.generate(departments.length, (index) => false);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load departments");
      }
    } catch (e) {
      print("Error fetching departments: $e");
    }
  }

  // Add a new department
  Future<void> addDepartment(String newDepartment) async {
    final IpAddress = await getActiveIpAddress();

    final getUrl = "$IpAddress/Departments/";

    try {
      final response = await http.get(Uri.parse(getUrl));
      int newDepId = 1; // Default ID if no departments exist

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          data.sort((a, b) => int.parse(a['DEP_ID'].toString())
              .compareTo(int.parse(b['DEP_ID'].toString())));
          int lastDepId = int.parse(data.last['DEP_ID'].toString());
          newDepId = lastDepId + 1; // Increment ID
        }
      }

      // Post new department
      final postUrl = "$IpAddress/Departments/";
      final postResponse = await http.post(
        Uri.parse(postUrl),
        body: jsonEncode({
          'DEP_ID': newDepId.toString(),
          'DEP_NAME': newDepartment,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (postResponse.statusCode == 201) {
        setState(() {
          departments.add({'DEP_ID': newDepId, 'DEP_NAME': newDepartment});
        });

        successfullyLoginMessage("Department Added Successfully");
        fetchDepartments();
      } else {
        throw Exception("Failed to add department: ${postResponse.body}");
      }
    } catch (e) {
      print("Error adding department: $e");
    }
  }

  // Update a department
  Future<void> updateDepartment(int index, String updatedName) async {
    final IpAddress = await getActiveIpAddress();

    final int depId = int.parse(departments[index]['DEP_ID'].toString());
    final url = "$IpAddress/Departments/$depId/"; // Use DEP_ID for update

    try {
      final response = await http.put(
        Uri.parse(url),
        body: jsonEncode({'DEP_NAME': updatedName}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          departments[index]['DEP_NAME'] = updatedName;
          isEditing[index] = false;
          controllers[index].text = updatedName; // Update controller text
        });

        successfullyLoginMessage("Department Updated Successfully");
        fetchDepartments();
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("Department updated successfully")),
        // );
      } else {
        throw Exception("Failed to update department");
      }
    } catch (e) {
      print("Error updating department: $e");
    }
  }

  void _showAddDialog() {
    final TextEditingController newDepartmentController =
        TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // ✅ Rounded border
        ),
        title: const Text('Add Department'),
        content: TextField(
          controller: newDepartmentController,
          decoration: const InputDecoration(labelText: 'Department Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newDepartment = newDepartmentController.text.trim();
              if (newDepartment.isNotEmpty) {
                addDepartment(newDepartment);
              }
              Navigator.of(context).pop();

              postLogData("Add ABAC (Add Department)",
                  "Added ${newDepartmentController.text}");
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Departments",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _showAddDialog, // Refresh button
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: fetchDepartments, // Refresh button
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: departments.length,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(Icons.business, color: Colors.blue),
                    title: isEditing[index]
                        ? TextField(
                            controller: controllers[index],
                            decoration: const InputDecoration(
                                hintText: 'Edit department name',
                                hintStyle: TextStyle(fontSize: 13)),
                          )
                        : Text(departments[index]['DEP_NAME'],
                            style: const TextStyle(fontSize: 13)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isEditing[index] ? Icons.check : Icons.edit,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            if (isEditing[index]) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Update'),
                                  content: const Text(
                                      'Are you sure you want to update this department?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          isEditing[index] = false;
                                        });

                                        fetchDepartments();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('No',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close dialog before updating
                                        updateDepartment(
                                            index,
                                            controllers[index]
                                                .text); // ✅ Proceed with update
                                      },
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              setState(() {
                                isEditing[index] = true;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> successfullyLoginMessage(Message) async {
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
                '$Message !!',
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}

class Dep_RoleListScreen extends StatefulWidget {
  const Dep_RoleListScreen({super.key});

  @override
  State<Dep_RoleListScreen> createState() => _Dep_RoleListScreenState();
}

class _Dep_RoleListScreenState extends State<Dep_RoleListScreen> {
  List<Map<String, dynamic>> department_role = [];
  List<TextEditingController> controllers = [];
  List<bool> isEditing = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDepartments();
    fetchDepartmentList();
  }

  // Fetch department roles from API
  Future<void> fetchDepartments() async {
    final IpAddress = await getActiveIpAddress();

    final url = "$IpAddress/DepRoles/";
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (!mounted) return; // Prevent calling setState after dispose

        setState(() {
          department_role = List<Map<String, dynamic>>.from(data);
          controllers = department_role
              .map((role) => TextEditingController(text: role['DEP_ROLE_NAME']))
              .toList();
          isEditing = List.filled(department_role.length, false);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load department roles");
      }
    } catch (e) {
      print("Error fetching department roles: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  String? selectedDepId; // Selected Department ID

  // Function to fetch the next DEP_ROLE_ID for a given DEP_ID
  Future<int> getNextDepRoleId(String depId) async {
    final IpAddress = await getActiveIpAddress();
    final int initialDepRoleId = int.parse(depId) * 10 + 1;
    final String url = "$IpAddress/DepRoles/?DEP_ID=$depId";
    print("Fetching next DEP_ROLE_ID from: $url");

    try {
      final response = await http.get(Uri.parse(url));
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print("Fetched DEP_ROLE_ID List: $data");

        final filteredData =
            data.where((item) => item['DEP_ID'].toString() == depId).toList();

        if (filteredData.isNotEmpty) {
          int maxDepRoleId = filteredData
              .map<int>(
                  (item) => int.tryParse(item['DEP_ROLE_ID'].toString()) ?? 0)
              .reduce((a, b) => a > b ? a : b);

          print("Max DEP_ROLE_ID Found: $maxDepRoleId");

          // Convert to string for transformation
          String maxStr = maxDepRoleId.toString();

          if (maxStr.length == 1) {
            // If only one digit, treat it like: 1 → "1" + (1+1) → "12"
            int lastDigit = int.parse(maxStr);
            int newPart = lastDigit + 1;
            return int.parse('${maxStr[0]}$newPart');
          } else {
            String firstDigits = maxStr.substring(0, 1); // first digit(s)
            String lastDigits = maxStr.substring(1); // rest
            int last = int.tryParse(lastDigits) ?? 0;
            int newPart = last + 1;
            String result = '$firstDigits$newPart';
            print("Generated new DEP_ROLE_ID: $result");
            return int.parse(result);
          }
        } else {
          print(
              "No existing roles found for DEP_ID $depId. Starting from initial.");
          return initialDepRoleId;
        }
      } else {
        print("Failed to fetch DEP_ROLE_ID: ${response.body}");
        return initialDepRoleId;
      }
    } catch (e) {
      print("Error fetching DEP_ROLE_ID: $e");
      return initialDepRoleId;
    }
  }

  // Function to add a new department role
  Future<void> addDepartment(String depRoleName) async {
    if (selectedDepId == null || selectedDepId!.isEmpty) {
      print("Error: No department selected.");
      return;
    }

    print("Selected Department ID: $selectedDepId");
    print("Fetching next available DEP_ROLE_ID...");

    int newDepRoleId = await getNextDepRoleId(selectedDepId!);
    print("New DEP_ROLE_ID to be used: $newDepRoleId");
    final IpAddress = await getActiveIpAddress();

    final url = "$IpAddress/DepRoles/";
    final Map<String, dynamic> requestBody = {
      "DEP_ROLE_ID": newDepRoleId.toString(),
      "DEP_ROLE_NAME": depRoleName,
      "DEP_ID": selectedDepId!,
    };

    print("Sending POST request to: $url");
    print("Request Body: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        print("✅ Department role added successfully!");
        successfullyLoginMessage("Saved Successfully ");
        fetchDepartments(); // Refresh data
      } else {
        print("❌ Failed to add department role: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Error adding department role: $e");
    }
  }

  void _showAddDialog() {
    final TextEditingController DepartmentRoleController =
        TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // ✅ Rounded border
        ),
        title: const Text('Add Department Role'),
        content: Container(
          height: 120,
          child: Column(
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      'Select Departments',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    Container(
                        height: 32,
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width * 0.15
                            : MediaQuery.of(context).size.width,
                        child: departmentDropdownList()),
                  ],
                ),
              ),
              TextField(
                controller: DepartmentRoleController,
                decoration: const InputDecoration(
                    labelText: 'Role Name',
                    labelStyle: TextStyle(fontSize: 13)),
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
              final newDepartmentRole = DepartmentRoleController.text.trim();
              if (newDepartmentRole.isNotEmpty && selectedDepId != null) {
                addDepartment(newDepartmentRole);
                Navigator.of(context).pop();
              }
              postLogData("Add ABAC (Add Department Role)",
                  "Added ${DepartmentRoleController.text}");
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  List<String> deprolelist = [];
  Map<String, String> depIdMap = {};
  String? deproleselectedValue;
  bool _filterEnabledDep_role = true;
  int? _selectedIndexDep_role;
  int? _hoveredIndexDep_role;
  TextEditingController departmentcontroller = TextEditingController();

  Future<void> fetchDepartmentList() async {
    final IpAddress = await getActiveIpAddress();

    final String url = "$IpAddress/Departments/";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          deprolelist =
              data.map<String>((item) => item['DEP_NAME'].toString()).toList();
          depIdMap = {
            for (var item in data)
              item['DEP_NAME'].toString(): item['DEP_ID'].toString()
          };
          print("depart role list $deprolelist");
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load departments");
      }
    } catch (e) {
      print("Error fetching department roles: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String Newdeproleid = '';

  Widget departmentDropdownList() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex = deprolelist.indexOf(departmentcontroller.text);
            if (currentIndex < deprolelist.length - 1) {
              setState(() {
                _selectedIndexDep_role = currentIndex + 1;
                // Take only the customer number part before the colon
                departmentcontroller.text =
                    deprolelist[currentIndex + 1].split(':')[0];
                _filterEnabledDep_role = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = deprolelist.indexOf(departmentcontroller.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndexDep_role = currentIndex - 1;
                // Take only the customer number part before the colon
                departmentcontroller.text =
                    deprolelist[currentIndex - 1].split(':')[0];
                _filterEnabledDep_role = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          // focusNode: CustomerSiteFocusNode,
          controller: departmentcontroller,
          onSubmitted: (String? suggestion) async {
            selectedDepId = depIdMap[suggestion!]; // Get corresponding DEP_ID
            print("selectedDepIddddddd selectedDepId $selectedDepId");
            getNextDepRoleId(selectedDepId!);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Color.fromARGB(201, 132, 132, 132), width: 1.0),
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
            setState(() async {
              _filterEnabledDep_role = true;
              deproleselectedValue = text.isEmpty ? null : text;
              selectedDepId = depIdMap[text!]; // Get corresponding DEP_ID
              print("selectedDepId selectedDepId $selectedDepId");
              getNextDepRoleId(selectedDepId!);
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabledDep_role && pattern.isNotEmpty) {
            return deprolelist.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return deprolelist;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = deprolelist.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndexDep_role = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndexDep_role = null;
            }),
            child: Container(
              color: _selectedIndexDep_role == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndexDep_role == null &&
                          deprolelist.indexOf(departmentcontroller.text) ==
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
          setState(() async {
            // // Take only the customer number part before the colon
            departmentcontroller.text = suggestion.split(':')[0];
            deproleselectedValue = suggestion;
            _filterEnabledDep_role = false;
            selectedDepId = depIdMap[suggestion!]; // Get corresponding DEP_ID
            print("selectedDepId selectedDepIdddddddddd $selectedDepId");
            getNextDepRoleId(selectedDepId!);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Department Roles",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _showAddDialog();
                fetchDepartmentList();
              }),
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: fetchDepartments),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: department_role.length,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(Icons.business, color: Colors.blue),
                    title: isEditing[index]
                        ? TextField(
                            controller: controllers[index],
                            decoration: const InputDecoration(
                                hintText: 'Edit department name',
                                hintStyle: TextStyle(fontSize: 13)),
                          )
                        : Text(department_role[index]['DEP_ROLE_NAME'],
                            style: const TextStyle(fontSize: 13)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // IconButton(
                        //   icon: Icon(
                        //       isEditing[index] ? Icons.check : Icons.edit,
                        //       color: Colors.green),
                        //   onPressed: () {
                        //     if (isEditing[index]) {
                        //       showDialog(
                        //         context: context,
                        //         barrierDismissible: false,
                        //         builder: (context) => AlertDialog(
                        //           title: const Text('Confirm Update'),
                        //           content: const Text(
                        //               'Are you sure you want to update this department?'),
                        //           actions: [
                        //             TextButton(
                        //               onPressed: () =>
                        //                   Navigator.of(context).pop(),
                        //               child: const Text('No',
                        //                   style: TextStyle(color: Colors.red)),
                        //             ),
                        //             ElevatedButton(
                        //               onPressed: () {
                        //                 Navigator.of(context).pop();
                        //                 updateDepartment(
                        //                     index, controllers[index].text);
                        //               },
                        //               child: const Text('Yes'),
                        //             ),
                        //           ],
                        //         ),
                        //       );
                        //     } else {
                        //       setState(() => isEditing[index] = true);
                        //     }
                        //   },
                        // ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> successfullyLoginMessage(Message) async {
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
                '$Message !!',
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}

class Dep_RoleSubmenuListScreen extends StatefulWidget {
  const Dep_RoleSubmenuListScreen({super.key});

  @override
  State<Dep_RoleSubmenuListScreen> createState() =>
      _Dep_RoleSubmenuListScreenState();
}

class _Dep_RoleSubmenuListScreenState extends State<Dep_RoleSubmenuListScreen> {
  List<Map<String, dynamic>> department_role = [];
  List<Map<String, dynamic>> department_role_submenu = [];
  List<TextEditingController> controllers = [];
  List<bool> isEditing = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDepartments();
    fetchDepartmentList();
  }

  Future<void> fetchDepartments() async {
    final IpAddress = await getActiveIpAddress();

    final url = "$IpAddress/DepRoleForms/";
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        String cleanedResponse = response.body.replaceAll("\n", " ");
        final List<dynamic> data = jsonDecode(cleanedResponse);

        if (!mounted) return;

        print("Fetched Data: $data");

        setState(() {
          department_role = data
              .map<Map<String, dynamic>>((role) => {
                    "SUBMENU": (role["SUBMENU"] ?? "Unnamed Department")
                        .toString()
                        .trim(),
                  })
              .toList();

          controllers = department_role
              .map((role) => TextEditingController(text: role['SUBMENU']))
              .toList();

          isEditing = List.filled(department_role.length, false);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load department roles");
      }
    } catch (e) {
      print("Error fetching department roles: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  String? selectedDepId; // Selected Department ID
  String? selectedDepRoleId;

  // Function to fetch the next DEP_ROLE_ID for a given DEP_ID
  Future<int> getNextDepRolesubmenuId(String deproleId) async {
    final IpAddress = await getActiveIpAddress();

    int initialDepRoleId = int.parse(deproleId) * 10 + 1;
    final String url = "$IpAddress/DepRoleForms/?DEP_ROLE_ID=$deproleId";
    print("Fetching next DEP_ROLE_ID from: $url");

    try {
      final response = await http.get(Uri.parse(url));
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print("Fetched DEP_ROLE_ID List: $data");

        // Filter data to include only entries matching the given DEP_ID
        final filteredData = data
            .where((item) => item['DEP_ROLE_ID'].toString() == deproleId)
            .toList();

        if (filteredData.isNotEmpty) {
          int maxDepRoleId = filteredData
              .map<int>(
                  (item) => int.tryParse(item['SUBMENU_ID'].toString()) ?? 0)
              .reduce((a, b) => a > b ? a : b);

          print("Max DEP_ROLE_ID Found: $maxDepRoleId");
          return maxDepRoleId + 1;
        } else {
          print(
              "No existing roles found for DEP_ID $deproleId. Starting from 1.");
          return initialDepRoleId; // Start from 1 if no roles exist
        }
      } else {
        print("Failed to fetch DEP_ROLE_ID: ${response.body}");
        return initialDepRoleId; // Default to 1 if request fails
      }
    } catch (e) {
      print("Error fetching DEP_ROLE_ID: $e");
      return initialDepRoleId;
    }
  }

  // Function to add a new department role
  Future<void> addDepartment(String depRolesubmenuName) async {
    if (selectedDepId == null || selectedDepId!.isEmpty) {
      print("Error: No department selected.");
      return;
    }

    print("Selected Department ID: $selectedDepId");
    print("Fetching next available DEP_ROLE_ID...");

    int newDeprolesubmenuid = await getNextDepRolesubmenuId(selectedDepRoleId!);
    print(
        "New DEP_ROLE_ID to be used: $selectedDepRoleId  $newDeprolesubmenuid");

    final IpAddress = await getActiveIpAddress();

    final url = "$IpAddress/DepRoleForms/";
    final Map<String, dynamic> requestBody = {
      "DEP_ID": selectedDepId,
      "DEP_ROLE_ID": selectedDepRoleId,
      "SUBMENU_ID": newDeprolesubmenuid.toString(),
      "SUBMENU": depRolesubmenuName
    };

    print("Sending POST request to: $url");
    print("Request Body: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        print("✅ Department role added successfully!");
        successfullyLoginMessage("Saved Successfully ");
        fetchDepartments(); // Refresh data
      } else {
        print("❌ Failed to add department role: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Error adding department role: $e");
    }
  }

  void _showAddDialog() {
    final TextEditingController DepartmentRoleSubmenuController =
        TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // ✅ Rounded border
        ),
        title: const Text('Add Department Role'),
        content: Container(
          height: 200,
          child: Column(
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      'Select Departments',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    Container(
                        height: 32,
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width * 0.15
                            : MediaQuery.of(context).size.width,
                        child: departmentDropdownList()),
                  ],
                ),
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      'Select Departments role',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    Container(
                        height: 32,
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width * 0.15
                            : MediaQuery.of(context).size.width,
                        child: departmentroleDropdownList()),
                  ],
                ),
              ),
              TextField(
                controller: DepartmentRoleSubmenuController,
                decoration: const InputDecoration(
                    labelText: 'Role Name', hintStyle: TextStyle(fontSize: 13)),
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
              final newDepartmentRolesubmenu =
                  DepartmentRoleSubmenuController.text.trim();
              if (newDepartmentRolesubmenu.isNotEmpty &&
                  selectedDepId != null) {
                addDepartment(newDepartmentRolesubmenu);
                Navigator.of(context).pop();
                fetchDepartments();
                fetchDepartments();

                postLogData("Add ABAC (Add Role Subforms)",
                    "Added ${DepartmentRoleSubmenuController.text}");
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String Newdeproleid = '';
  List<String> deprolelist = [];
  Map<String, String> depIdMap = {};
  String? deproleselectedValue;
  bool _filterEnabledDep_role = true;
  int? _selectedIndexDep_role;
  int? _hoveredIndexDep_role;
  TextEditingController departmentcontroller = TextEditingController();

  Future<void> fetchDepartmentList() async {
    final IpAddress = await getActiveIpAddress();

    final String url = "$IpAddress/Departments/";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          deprolelist =
              data.map<String>((item) => item['DEP_NAME'].toString()).toList();
          depIdMap = {
            for (var item in data)
              item['DEP_NAME'].toString(): item['DEP_ID'].toString()
          };
          print("depart role list $deprolelist");
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load departments");
      }
    } catch (e) {
      print("Error fetching department roles: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget departmentDropdownList() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex = deprolelist.indexOf(departmentcontroller.text);
            if (currentIndex < deprolelist.length - 1) {
              setState(() {
                _selectedIndexDep_role = currentIndex + 1;
                // Take only the customer number part before the colon
                departmentcontroller.text =
                    deprolelist[currentIndex + 1].split(':')[0];
                _filterEnabledDep_role = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = deprolelist.indexOf(departmentcontroller.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndexDep_role = currentIndex - 1;
                // Take only the customer number part before the colon
                departmentcontroller.text =
                    deprolelist[currentIndex - 1].split(':')[0];
                _filterEnabledDep_role = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          // focusNode: CustomerSiteFocusNode,
          controller: departmentcontroller,
          onSubmitted: (String? suggestion) async {
            selectedDepId = depIdMap[suggestion!]; // Get corresponding DEP_ID
            print("selectedDepIddddddd selectedDepId $selectedDepId");
            // await getNextDepRoleId(selectedDepId!);
            await fetchDepartmenroletList(int.parse(selectedDepId!));
            setState(() {
              departmentSubmenucontroller.clear();
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Color.fromARGB(201, 132, 132, 132), width: 1.0),
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
            setState(() async {
              _filterEnabledDep_role = true;
              deproleselectedValue = text.isEmpty ? null : text;
              selectedDepId = depIdMap[text!]; // Get corresponding DEP_ID
              print("selectedDepId selectedDepId $selectedDepId");
              // await getNextDepRoleId(selectedDepId!);
              await fetchDepartmenroletList(int.parse(selectedDepId!));
              setState(() {
                departmentSubmenucontroller.clear();
              });
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabledDep_role && pattern.isNotEmpty) {
            return deprolelist.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return deprolelist;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = deprolelist.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndexDep_role = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndexDep_role = null;
            }),
            child: Container(
              color: _selectedIndexDep_role == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndexDep_role == null &&
                          deprolelist.indexOf(departmentcontroller.text) ==
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
          setState(() async {
            // // Take only the customer number part before the colon
            departmentcontroller.text = suggestion.split(':')[0];
            deproleselectedValue = suggestion;
            _filterEnabledDep_role = false;
            selectedDepId = depIdMap[suggestion!]; // Get corresponding DEP_ID
            print("selectedDepId selectedDepIdddddddddd $selectedDepId");
            // await getNextDepRoleId(selectedDepId!);
            await fetchDepartmenroletList(int.parse(selectedDepId!));
            setState(() {
              departmentSubmenucontroller.clear();
            });
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

  List<String> deprolesubmenulist = [];
  Map<String, String> depIdsubmenuMap = {};
  String? deprolesubmenuselectedValue;
  bool _filterEnabledDep_role_submenu = true;
  int? _selectedIndexDep_role_submenu;
  int? _hoveredIndexDep_role_submenu;
  TextEditingController departmentSubmenucontroller = TextEditingController();

  Future<void> fetchDepartmenroletList(int selectedDepId) async {
    final IpAddress = await getActiveIpAddress();

    final String url = "$IpAddress/DepRoles/";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Debug: Print the full data to check its structure
        print("Full data from API: $data");

        // Ensure DEP_ID comparison is done correctly (convert to int if needed)
        final filteredData = data.where((item) {
          var depId = item['DEP_ID'];
          if (depId is String) {
            depId = int.tryParse(depId); // Convert string DEP_ID to int
          }
          return depId == selectedDepId;
        }).toList();

        print("Filtered Data: $filteredData for selectedDepId: $selectedDepId");

        // Check if any data is found after filtering
        if (filteredData.isEmpty) {
          print("No roles found for DEP_ID: $selectedDepId");
        }

        setState(() {
          deprolesubmenulist = filteredData
              .map<String>((item) => item['DEP_ROLE_NAME'].toString())
              .toList();

          depIdsubmenuMap = {
            for (var item in filteredData)
              item['DEP_ROLE_NAME'].toString(): item['DEP_ROLE_ID'].toString()
          };

          print("Final Role List: $deprolesubmenulist");
          isLoading = false;
        });
      } else {
        throw Exception(
            "Failed to load department roles. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching department roles: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget departmentroleDropdownList() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                deprolesubmenulist.indexOf(departmentSubmenucontroller.text);
            if (currentIndex < deprolesubmenulist.length - 1) {
              setState(() {
                _selectedIndexDep_role_submenu = currentIndex + 1;
                // Take only the customer number part before the colon
                departmentSubmenucontroller.text =
                    deprolesubmenulist[currentIndex + 1].split(':')[0];
                _filterEnabledDep_role_submenu = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                deprolesubmenulist.indexOf(departmentSubmenucontroller.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndexDep_role_submenu = currentIndex - 1;
                // Take only the customer number part before the colon
                departmentSubmenucontroller.text =
                    deprolesubmenulist[currentIndex - 1].split(':')[0];
                _filterEnabledDep_role_submenu = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          // focusNode: CustomerSiteFocusNode,
          controller: departmentSubmenucontroller,
          onSubmitted: (String? suggestion) async {
            selectedDepRoleId =
                depIdsubmenuMap[suggestion!]; // Get corresponding DEP_ID
            print("selectedDepRoleIddddddd selectedDepId $selectedDepRoleId");
            // getNextDepRoleId(selectedDepId!);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Color.fromARGB(201, 132, 132, 132), width: 1.0),
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
            setState(() async {
              _filterEnabledDep_role_submenu = true;
              deprolesubmenuselectedValue = text.isEmpty ? null : text;
              selectedDepRoleId =
                  depIdsubmenuMap[text!]; // Get corresponding DEP_ID
              print("selectedDepRoleId selectedDepId $selectedDepRoleId");
              // getNextDepRoleId(selectedDepId!);
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabledDep_role_submenu && pattern.isNotEmpty) {
            return deprolesubmenulist.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return deprolesubmenulist;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = deprolesubmenulist.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndexDep_role_submenu = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndexDep_role_submenu = null;
            }),
            child: Container(
              color: _selectedIndexDep_role_submenu == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndexDep_role_submenu == null &&
                          deprolesubmenulist
                                  .indexOf(departmentSubmenucontroller.text) ==
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
          setState(() async {
            // // Take only the customer number part before the colon
            departmentSubmenucontroller.text = suggestion.split(':')[0];
            deprolesubmenuselectedValue = suggestion;
            _filterEnabledDep_role_submenu = false;
            selectedDepRoleId =
                depIdsubmenuMap[suggestion!]; // Get corresponding DEP_ID
            print(
                "selectedDepRoleId selectedDepIdddddddddd $selectedDepRoleId");
            // getNextDepRoleId(selectedDepId!);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Roles Subforms",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _showAddDialog();
                fetchDepartmentList();
              }),
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: fetchDepartments),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: department_role.length,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(Icons.business, color: Colors.blue),
                    title: isEditing[index]
                        ? TextField(
                            controller: controllers[index],
                            decoration: const InputDecoration(
                              hintText: 'Edit department name',
                              hintStyle: const TextStyle(fontSize: 13),
                            ),
                          )
                        : Text(
                            department_role[index]['SUBMENU'] ??
                                "Unnamed Department",
                            style: const TextStyle(fontSize: 13),
                          ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> successfullyLoginMessage(Message) async {
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
                '$Message !!',
                style: TextStyle(fontSize: 13, color: Colors.black),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}
