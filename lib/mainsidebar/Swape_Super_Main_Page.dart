import 'dart:async';
import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:aljeflutterapp/main.dart';
import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:aljeflutterapp/welcomedashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For parsing JSON
// import 'package:aljeflutterapp/welcomedashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Swape_WHR_Superuser extends StatefulWidget {
  const Swape_WHR_Superuser({super.key});

  @override
  State<Swape_WHR_Superuser> createState() => _Swape_WHR_SuperuserState();
}

class _Swape_WHR_SuperuserState extends State<Swape_WHR_Superuser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode loginButtonFocusNode = FocusNode();

  FocusNode regionFocusNode = FocusNode();
  FocusNode warehousenameFocusnode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    fetchOrgIds();
    super.initState();
  }

  bool _obscureText = true;

  bool isProcessing = false; // Track if login is in progress

  Future<void> _validateAndLogin() async {
    final empNameOriginal = WHRSuperUserNameController.text.trim();
    final WHRSuperUserNo = WHRSuperUserNodropdownController.text.trim();
    final orgId = _Org_iddropdownController.text.trim();
    const defaultRole = 'WHR SuperUser';
    final warehousename = warehouseController.text.trim();

    await saveloginname(empNameOriginal);
    await salesloginno(WHRSuperUserNo!);
    await salesloginrole(defaultRole);
    await saleslogiOrgid(orgId);
    await saleslogiOrgwarehousename(warehousename);

    await fetchAccessControl(); // Optional
    successfullyLoginMessage(defaultRole);
  }

  Future<void> salesloginrole(String salesloginrole) async {
    await SharedPrefs.salesloginrole(salesloginrole);
  }

  Future<void> salesloginno(String salesloginno) async {
    await SharedPrefs.salesloginno(salesloginno);
  }

  Future<void> saveloginname(String saveloginname) async {
    await SharedPrefs.saveloginname(saveloginname);
  }

  Future<void> saleslogiOrgid(String saleslogiOrgid) async {
    await SharedPrefs.saleslogiOrgid(saleslogiOrgid);
  }

  Future<void> successfullyLoginMessage(String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saveloginname = prefs.getString('saveloginname');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Container(
            width: MediaQuery.of(context).size.width * 0.3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'WHR SuperUser  "$saveloginname" Login Successfully !!',
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

    await Future.delayed(const Duration(seconds: 3));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => splashscreen(),
      ),
    );
  }

  void showErrorMessage(String mesage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.warning, color: Colors.yellow),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                mesage,
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> accessControl = [];
  Future<List<String>> fetchAccessControl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lableRoleIDList = prefs.getString('departmentid');
    String? salesloginnoStr = prefs.getString('commersialno');

    final IpAddress = await getActiveIpAddress();

    final String url =
        "$IpAddress/New_Updated_get_submenu_depid_list/$lableRoleIDList/$salesloginnoStr/";
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

  // Function to handle container click
  Future<void> _onContainerClick() async {
    {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Check if WHRSuperUser name is saved in SharedPreferences
      String? saveloginname = prefs.getString('saveloginname');
      bool isLoggedIn = saveloginname != null && saveloginname.isNotEmpty;

      // Navigate to MainSidebar if logged in, otherwise go to login page
      navigateBasedOnRole(context, isLoggedIn);
    }
  }

  void navigateBasedOnRole(BuildContext context, bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (isLoggedIn) {
      String? role = prefs.getString('salesloginrole'); // Fetch the role
      {
        // If the role is WHRSuperUser, navigate to MainSidebar
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainSidebar(enabledItems: accessControl),
          ),
        );
      }
    }
  }

  String? selectedValue;
  FocusNode RoleFocus = FocusNode();

  String? org_idselectedValue;
  FocusNode org_idFocus = FocusNode();
  int? _org_idselectedIndex;
  bool _org_idfilterEnabled = true;
  int? _org_idhoveredIndex;

  List<String> Org_idList = [];
  final _Org_iddropdownController = TextEditingController();

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
                  '${item['ORGANIZATION_ID']} - ${item['WAREHOUSE_NAME']} ( ${item['REGION_NAME']} )',
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

  Widget Org_idDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
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
            setState(() {
              org_idselectedValue = suggestion;
              _Org_iddropdownController.text =
                  suggestion!.split(' - ')[0]; // Set only the first part
              _org_idfilterEnabled = false;
              setState(() {
                WHRSuperUserNodropdownController.clear();
                WHRSuperUserNameController.clear();
              });
              fetchRegionAndWarehouse();
              fetchWHRSuperUserdetails();
            });
          },
          controller: _Org_iddropdownController,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.group,
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
              fetchWHRSuperUserdetails();
              setState(() {
                WHRSuperUserNodropdownController.clear();
                WHRSuperUserNameController.clear();
              });
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
          setState(() {
            _Org_iddropdownController.text = suggestion.split(' - ')[0];
            org_idselectedValue = suggestion.split(' - ')[0];
            _org_idfilterEnabled = false;
            fetchRegionAndWarehouse();
            setState(() {
              WHRSuperUserNodropdownController.clear();
              WHRSuperUserNameController.clear();
            });
            fetchWHRSuperUserdetails();
          });
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

  String? WHRSuperUserNoselectedValue;
  FocusNode WHRSuperUserNoFocus = FocusNode();
  int? WHRSuperUserNoselectedIndex;
  bool WHRSuperUserNofilterEnabled = true;
  int? WHRSuperUserNohoveredIndex;
  final WHRSuperUserNodropdownController = TextEditingController();

  List<String> WHRSuperUserNo_list = [];

  bool isLoading = false;
  String error = '';
  Future<void> fetchWHRSuperUserdetails() async {
    print("Entered fetchWHRSuperUserdetails()");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String Org_id = _Org_iddropdownController.text;
    setState(() {
      isLoading = true;
      error = '';
    });

    // Get org ID from the dropdown (assumes format: '101 - Western Region')
    String orgId = _Org_iddropdownController.text.split(' - ')[0].trim();

    final IpAddress = await getActiveIpAddress();

    final url = Uri.parse('$IpAddress/Get-whr-superusers/$Org_id/');
    print("Fetching salesmen from: $url");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          // Filter by ORG_ID (which comes as double like 101.0, so compare as string)
          List<String> filteredList = data
              .where((item) => item['ORG_ID'].toString().split('.')[0] == orgId)
              .map<String>((item) {
                String WHRSuperUserNo = item['WHR_SuperUser_NO'] ?? '';
                String fullName = item['EMPLOYEE_FULL_NAME'] ?? '';
                return '$WHRSuperUserNo - $fullName';
              })
              .toSet() // Remove duplicates
              .toList();

          if (filteredList.isEmpty) {
            // Show dialog box if no data is found
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("No Data"),
                  content: Text("There is no data under this warehouse."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _Org_iddropdownController.clear();
                          warehouseController.clear();
                          regionController.clear();
                          WHRSuperUserNo_list = [];
                        });
                      },
                      child: Text("OK"),
                    ),
                  ],
                );
              },
            );
          } else {
            // Populate the WHRSuperUserNo_list with all salesmen
            setState(() {
              WHRSuperUserNo_list = filteredList;
            });
            print("Filtered WHRSuperUser List: $WHRSuperUserNo_list");
          }

          // setState(() {
          //   WHRSuperUserNo_list = filteredList;
          // });
          // print("Filtered WHRSuperUser list: $filteredList");
        } else {
          setState(() {
            error = 'Invalid data format from API.';
          });
          print("Invalid data format from API");
        }
      } else {
        setState(() {
          error = 'Failed to load data. Status code: ${response.statusCode}';
        });
        print("HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        error = 'Error occurred: $e';
      });
      print("Exception: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> FetchWHRSuperUserName() async {
    final IpAddress = await getActiveIpAddress();

    String WHRSuperUserNo =
        WHRSuperUserNodropdownController.text.split(' - ')[0].trim();
    final baseUrl = '$IpAddress/User_member_details/';
    String? nextPageUrl = baseUrl;

    try {
      Map<String, dynamic>? WHRSuperUserData;

      while (nextPageUrl != null) {
        final response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // Find the entry for the given EMPLOYEE_ID
          final result = data['results'].firstWhere(
            (item) => item['EMPLOYEE_ID'] == WHRSuperUserNo,
            orElse: () => null,
          );

          if (result != null) {
            WHRSuperUserData = result;
            break; // Exit the loop once the WHRSuperUser is found
          }

          // Update the next page URL
          nextPageUrl = data['next'];
        } else {
          throw Exception(
              'Failed to load data. Status code: ${response.statusCode}');
        }
      }

      if (WHRSuperUserData != null) {
        // Update the controllers with fetched values
        setState(() {
          WHRSuperUserNameController.text = WHRSuperUserData?['EMP_NAME'];
          _emailController.text = WHRSuperUserData?['EMP_USERNAME'];
          _passwordController.text = WHRSuperUserData?['EMP_PASSWORD'];
        });
      } else {
        // Clear the controllers if no match is found
        setState(() {
          regionController.text = '';
          warehouseController.text = '';
        });
        print('No data found for EMPLOYEE_ID: $WHRSuperUserNo');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Widget WHRSuperUserNoDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex = WHRSuperUserNo_list.indexWhere((item) =>
                item.split(' - ')[0] == WHRSuperUserNodropdownController.text);
            if (currentIndex < WHRSuperUserNo_list.length - 1) {
              setState(() {
                WHRSuperUserNoselectedIndex = currentIndex + 1;
                WHRSuperUserNodropdownController.text =
                    WHRSuperUserNo_list[currentIndex + 1].split(' - ')[0];
                WHRSuperUserNofilterEnabled = false;
                // FetchWHRSuperUserName();
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = WHRSuperUserNo_list.indexWhere((item) =>
                item.split(' - ')[0] == WHRSuperUserNodropdownController.text);
            if (currentIndex > 0) {
              setState(() {
                setState(() {
                  int index =
                      (currentIndex ?? 1) - 1; // use 1 if currentIndex is null
                  WHRSuperUserNoselectedIndex = index;

                  String selectedValue = WHRSuperUserNo_list[index];

                  List<String> parts = selectedValue.split(' - ');
                  WHRSuperUserNodropdownController.text =
                      parts.isNotEmpty ? parts[0].trim() : '';
                  WHRSuperUserNameController.text =
                      parts.length > 1 ? parts[1].trim() : '';

                  WHRSuperUserNofilterEnabled = false;

                  // FetchWHRSuperUserName();
                });
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: WHRSuperUserNoFocus,
          onSubmitted: (String? suggestion) async {
            if (suggestion == null || !suggestion.contains(' - ')) {
              print("Invalid suggestion format");
              return;
            }

            // Split into parts
            List<String> parts = suggestion.split(' - ');
            String WHRSuperUserNo = parts[0].trim();
            String WHRSuperUserName =
                parts.sublist(1).join(' - ').trim(); // In case name has hyphens

            setState(() {
              WHRSuperUserNoselectedValue = suggestion;
              WHRSuperUserNodropdownController.text = WHRSuperUserNo;
              WHRSuperUserNameController.text = WHRSuperUserName;
              WHRSuperUserNofilterEnabled = false;
            });

            // If this function fetches additional info, you can call it here
            // await FetchWHRSuperUserName();
          },
          controller: WHRSuperUserNodropdownController,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.group,
              size: 18,
              color: const Color.fromARGB(255, 67, 67, 67),
            ),
            labelText: 'Select WHR SuperUser No',
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
              WHRSuperUserNofilterEnabled = true;
              WHRSuperUserNoselectedValue = text.isEmpty ? null : text;
              // FetchWHRSuperUserName();
            });
          },
        ),
        suggestionsCallback: (pattern) {
          return WHRSuperUserNo_list;
        },
        itemBuilder: (context, suggestion) {
          final index = WHRSuperUserNo_list.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              WHRSuperUserNohoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              WHRSuperUserNohoveredIndex = null;
            }),
            child: Container(
              color: WHRSuperUserNoselectedIndex == index
                  ? Colors.white
                  : WHRSuperUserNoselectedIndex == null &&
                          WHRSuperUserNo_list.indexWhere((item) =>
                                  item.split(' - ')[0] ==
                                  WHRSuperUserNodropdownController.text) ==
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
          setState(() {
            // Split the suggestion string into number and name parts
            List<String> parts = suggestion.split(' - ');

            // Defensive coding to handle unexpected input format
            String WHRSuperUserNo = parts.isNotEmpty ? parts[0].trim() : '';
            String WHRSuperUserName = parts.length > 1 ? parts[1].trim() : '';

            // Set controllers and values
            WHRSuperUserNodropdownController.text = WHRSuperUserNo;
            WHRSuperUserNameController.text = WHRSuperUserName;
            WHRSuperUserNoselectedValue = WHRSuperUserNo;
            WHRSuperUserNofilterEnabled = false;

            // Call any method if needed
            // FetchWHRSuperUserName(); // Only if this function is required after selection
          });
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

  final TextEditingController WHRSuperUserNameController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double formWidth =
        screenWidth > 900 ? screenWidth * 0.5 : screenWidth * 0.9;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: formWidth,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Title
                Text(
                  'WHR SuperUser Loginin',
                  style: TextStyle(
                    fontSize: screenWidth > 600 ? 28 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 20),

                LayoutBuilder(
                  builder: (context, constraints) {
                    int fieldsPerRow = constraints.maxWidth > 900
                        ? 3
                        : constraints.maxWidth > 600
                            ? 2
                            : 1;

                    return Column(
                      children: [
                        _buildResponsiveRow(
                            fieldsPerRow,
                            [
                              _buildDropdownField(Org_idDropdown()),
                              _buildTextField(
                                  'Warehouse Name',
                                  Icons.location_on,
                                  warehouseController,
                                  warehousenameFocusnode),
                            ],
                            constraints.maxWidth),
                        _buildResponsiveRow(
                            fieldsPerRow,
                            [
                              _buildTextField('Region', Icons.map,
                                  regionController, regionFocusNode),
                              _buildDropdownField(WHRSuperUserNoDropdown()),
                              _buildTextField('WHRSuperUser Name', Icons.person,
                                  WHRSuperUserNameController, null),
                            ],
                            constraints.maxWidth),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 30),

                /// Login Button (Full width)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    focusNode: loginButtonFocusNode,
                    onPressed: isProcessing ? null : _validateAndLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.blue,
                    ),
                    child: isProcessing
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Go',
                            style: TextStyle(
                                fontSize: screenWidth > 600 ? 18 : 16,
                                color: Colors.white),
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

  Future<void> saleslogiOrgwarehousename(
      String saleslogiOrgwarehousename) async {
    await SharedPrefs.saleslogiOrgwarehousename(saleslogiOrgwarehousename);
  }

  /// Builds a responsive row with [fieldsPerRow] count
  /// Builds a responsive row with [fieldsPerRow] count
  Widget _buildResponsiveRow(
      int fieldsPerRow, List<Widget> fields, double maxWidth) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: fields.map((field) {
          return SizedBox(
            width: (1 / fieldsPerRow) *
                (maxWidth * 0.9), // Use maxWidth from LayoutBuilder
            child: field,
          );
        }).toList(),
      ),
    );
  }

  /// Creates a dropdown field inside a container with shadow
  Widget _buildDropdownField(Widget dropdown) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: dropdown,
    );
  }

  /// Creates a text input field with given parameters
  Widget _buildTextField(String label, IconData icon,
      TextEditingController controller, FocusNode? focusNode) {
    return TextFormField(
      readOnly: true,
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }
}
