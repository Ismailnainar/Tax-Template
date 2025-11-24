import 'dart:convert';

import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:aljeflutterapp/components/constaints.dart';
import 'package:aljeflutterapp/dispatch/GeneratePickman.dart';
import 'package:aljeflutterapp/dispatch/NewGenerateDispatch.dart';
import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class ViewCompleteDipatch extends StatefulWidget {
  final Function togglePage;

  ViewCompleteDipatch(this.togglePage);
  @override
  State<ViewCompleteDipatch> createState() => _ViewCompleteDipatchState();
}

class _ViewCompleteDipatchState extends State<ViewCompleteDipatch> {
  final TextEditingController SearchReqNoController = TextEditingController();
  final TextEditingController salesmanIdController = TextEditingController();

  List<Map<String, dynamic>> filteredData = [];
  bool _isLoadingData = true;

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  DateTime? _selectedDate;
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
    await fetchDispatchData();
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
    await fetchDispatchData();
  }

  List<Map<String, dynamic>> allTableData = [];
  void _filterDataByDate() {
    setState(() {
      // Convert input controller text format (dd-MMM-yyyy) to DateTime
      DateTime fromDate =
          DateFormat('dd-MMM-yyyy').parse(_FromdateController.text.trim());
      DateTime toDate =
          DateFormat('dd-MMM-yyyy').parse(_EnddateController.text.trim());

      // Filter data
      filteredData = filteredData.where((item) {
        // Convert the date field from dd.MM.yyyy to DateTime
        DateTime itemDate = DateFormat('dd.MM.yyyy').parse(item['date']);

        // Compare date range
        return itemDate.isAtSameMomentAs(fromDate) ||
            itemDate.isAtSameMomentAs(toDate) ||
            (itemDate.isAfter(fromDate) && itemDate.isBefore(toDate));
      }).toList();

      print("after filteredTableData $filteredData");
    });
  }

  void Checkstatus() {
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
                  'Kindly select the From and To Date',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
            ],
          ),
          actions: [
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
              child: Text('Ok',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await Future.wait([
      fetchAccessControl(),
      _loadSalesmanName(),
      fetchDispatchData(),
    ]);

    postLogData("Complete Dispatch", "Opened");
    filteredData = List.from(tableData); // Initialize with all data
    setState(() {}); // Trigger a rebuild after data is loaded
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();

    postLogData("Complete Dispatch", "Opened");
  }

  List<bool> accessControl = [];

  Future<void> fetchAccessControl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginnoStr = prefs.getString('salesloginno');
    final String uniqueId = salesloginnoStr.toString();

    final IpAddress = await getActiveIpAddress();

    String apiUrl = '$IpAddress/User_member_details/';
    bool userFound = false;

    try {
      // Loop through each page until the user with uniqueId is found or no more pages are left
      while (apiUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          // Decode the JSON response
          final data = json.decode(response.body);

          // Find the user with the matching unique_id on the current page
          var user = (data['results'] as List<dynamic>).firstWhere(
            (u) => u['EMPLOYEE_ID'] == uniqueId,
            orElse: () => null,
          );

          if (user != null) {
            userFound = true;

            // Check if access_control is not null and is a Map
            var accessControlMap = user['acess_control'];
            if (accessControlMap != null && accessControlMap is Map) {
              // Convert access_control Map to a list of bools
              List<bool> accessControlList = [];

              // Iterate through the values of the access control map
              for (var value in accessControlMap.values) {
                // Ensure that we only process boolean values
                accessControlList
                    .add(value is bool ? value : value.toString() == 'true');
              }

              // Set the access control list to a state variable if needed
              setState(() {
                accessControl =
                    accessControlList; // Assuming accessControl is defined as List<bool>
              });

              print('Access Control List: $accessControl');
            } else {
              print('Access control data is not available for user $uniqueId.');
            }
            return; // Exit once the user is found and processed
          }

          // Update apiUrl to the next page, or set to empty if no more pages
          apiUrl = data['next'] ?? '';
        } else {
          print('Failed to load user details: ${response.statusCode}');
          return;
        }
      }

      if (!userFound) {
        print('User with unique_id $uniqueId not found in any page.');
      }
    } catch (error) {
      print('Error: $error');
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
  }

  void _searchreqno() {
    String searchId = SearchReqNoController.text.trim();

    // Perform the filtering
    setState(() {
      filteredData =
          tableData.where((data) => data['reqno'].contains(searchId)).toList();
    });
  }

  void _search() {
    String searchId = salesmanIdController.text.trim();

    // Perform the filtering
    setState(() {
      filteredData = tableData
          .where((data) => data['salesman'].contains(searchId))
          .toList();
    });
  }

  bool _isSecondRowVisible = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Dispatch Creation"),
      //   centerTitle: true,
      // ),
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
                                  Icons.check_box,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Completed Dispatch View',
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
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, top: 10.0),
                              child: Row(
                                children: [
                                  // From Date Picker
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 180
                                        : 130,
                                    height: 30,
                                    child: TextField(
                                      controller: _FromdateController,
                                      readOnly: true,
                                      onTap: () => _selectfromDate(
                                          context), // Open the date picker when tapped
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.calendar_month),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(0),
                                        ),
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 5.0),
                                      ),
                                      style: commonLabelTextStyle,
                                    ),
                                  ),
                                  SizedBox(width: 10),

                                  // To Date Picker
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 180
                                        : 130,
                                    height: 30,
                                    child: TextField(
                                      controller: _EnddateController,
                                      readOnly: true,
                                      onTap: () => _selectendDate(
                                          context), // Open the date picker when tapped
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.calendar_month),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(0),
                                        ),
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 5.0),
                                      ),
                                      style: commonLabelTextStyle,
                                    ),
                                  ),
                                  SizedBox(width: 10),

                                  // Search Button
                                  Container(
                                    height: 32,
                                    decoration:
                                        BoxDecoration(color: buttonColor),
                                    child: ElevatedButton.icon(
                                        icon: Icon(Icons.search,
                                            color: Colors.white),
                                        onPressed: () async {
                                          if (_FromdateController
                                                  .text.isEmpty ||
                                              _EnddateController.text.isEmpty) {
                                            Checkstatus();
                                          } else {
                                            DateTime? fromDate =
                                                DateFormat('dd-MMM-yyyy').parse(
                                                    _FromdateController.text);
                                            DateTime? endDate =
                                                DateFormat('dd-MMM-yyyy').parse(
                                                    _EnddateController.text);

                                            if (endDate.isBefore(fromDate)) {
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
                                                                .format(DateTime
                                                                    .now());
                                                            Navigator.of(
                                                                    context)
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
                                              // await fetchDispatchData();
                                              _filterDataByDate();
                                            }
                                          }

                                          postLogData(
                                              "Completed Dispatch", "Search");
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
                                        label: Text(
                                          'Search',
                                          style: TextStyle(color: Colors.white),
                                        )),
                                  ),

                                  SizedBox(width: 10),
                                  Container(
                                    height: 32,
                                    decoration:
                                        BoxDecoration(color: buttonColor),
                                    child: ElevatedButton(
                                        onPressed: () async {
                                          await fetchDispatchData();
                                          _FromdateController.text =
                                              DateFormat('dd-MMM-yyyy')
                                                  .format(DateTime.now());
                                          _EnddateController.text =
                                              DateFormat('dd-MMM-yyyy')
                                                  .format(DateTime.now());

                                          postLogData(
                                              "Completed Dispatch", "Clear");
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
                                        child: Text(
                                          'Clear',
                                          style: commonWhiteStyle,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: Responsive.isDesktop(context) ? 0 : 15,
                          ),

                          if (Responsive.isDesktop(context))
                            Row(
                              children: [
                                if (saveloginrole != null) ...[
                                  if (saveloginrole == "Salesman" ||
                                      saveloginrole == "Sales Supervisor" ||
                                      commersialrole ==
                                          "Retail Sales Supervisor")
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16, left: 16, bottom: 10),
                                      child: Text("Salesman No",
                                          style: topheadingbold),
                                    ),
                                  if (saveloginrole == "Salesman" ||
                                      saveloginrole == "Sales Supervisor" ||
                                      commersialrole ==
                                          "Retail Sales Supervisor")
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16, left: 5, bottom: 10),
                                      child: Text(
                                        ' - $salesloginno',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 200
                                        : 150,
                                    height: 33,
                                    color: Colors.grey[200],
                                    child: TextFormField(
                                      controller: SearchReqNoController,
                                      onChanged: (value) {
                                        setState(() {
                                          _searchreqno();
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Enter Request No',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.zero,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 10.0),
                                        filled: true,
                                        fillColor:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                      style: textBoxstyle,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  if (saveloginrole == "WHR SuperUser")
                                    Container(
                                      width: Responsive.isDesktop(context)
                                          ? 200
                                          : 150,
                                      height: 33,
                                      color: Colors.grey[200],
                                      child: TextFormField(
                                        controller: salesmanIdController,
                                        onChanged: (value) {
                                          setState(() {
                                            _search();
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Enter Salesman No',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.zero,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10.0,
                                                  horizontal: 10.0),
                                          filled: true,
                                          fillColor: Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        style: textBoxstyle,
                                      ),
                                    ),
                                  if (saveloginrole == "WHR SuperUser")
                                    const SizedBox(width: 10),
                                  if (saveloginrole == "WHR SuperUser")
                                    Container(
                                      decoration:
                                          BoxDecoration(color: buttonColor),
                                      height: 30,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            salesmanIdController.clear();
                                            filteredData = List.from(tableData);
                                          });

                                          postLogData(
                                              "Completed Dispatch", "Clear");
                                          // print("Refresh button pressed");
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
                                            'Clear',
                                            style: commonWhiteStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius:
                                                              3, // Adjust the size of the bullet
                                                          backgroundColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  23,
                                                                  122,
                                                                  5), // Bullet color
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                8), // Space between bullet and text
                                                        Text(
                                                          'Dispatch Request',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    23,
                                                                    122,
                                                                    5),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                            radius:
                                                                3, // Adjust the size of the bullet
                                                            backgroundColor:
                                                                Color.fromARGB(
                                                                    255,
                                                                    200,
                                                                    10,
                                                                    10)),
                                                        SizedBox(
                                                            width:
                                                                8), // Space between bullet and text
                                                        Text(
                                                          'Dispatch Assigned',
                                                          style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      200,
                                                                      10,
                                                                      10)),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                            radius:
                                                                3, // Adjust the size of the bullet
                                                            backgroundColor:
                                                                Color.fromARGB(
                                                                    255,
                                                                    176,
                                                                    9,
                                                                    179)),
                                                        SizedBox(
                                                            width:
                                                                8), // Space between bullet and text
                                                        Text(
                                                          'Dispatch Picked',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    176,
                                                                    9,
                                                                    179),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius:
                                                              3, // Adjust the size of the bullet
                                                          backgroundColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  45,
                                                                  13,
                                                                  163),
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                8), // Space between bullet and text
                                                        Text(
                                                          'Stage Completed',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    45,
                                                                    13,
                                                                    163),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                            radius:
                                                                3, // Adjust the size of the bullet

                                                            backgroundColor:
                                                                Color.fromARGB(
                                                                    255,
                                                                    184,
                                                                    128,
                                                                    7)),
                                                        SizedBox(
                                                            width:
                                                                8), // Space between bullet and text
                                                        Text(
                                                          'Return Qty',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    184,
                                                                    128,
                                                                    7),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                              ],
                            ),

                          if (!Responsive.isDesktop(context))
                            Wrap(
                              children: [
                                if (saveloginrole != null) ...[
                                  if (saveloginrole == "Salesman" ||
                                      saveloginrole == "Sales Supervisor" ||
                                      commersialrole ==
                                          "Retail Sales Supervisor")
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16, left: 16, bottom: 10),
                                      child: Text("Salesman No",
                                          style: topheadingbold),
                                    ),
                                  if (saveloginrole == "Salesman" ||
                                      saveloginrole == "Sales Supervisor" ||
                                      commersialrole ==
                                          "Retail Sales Supervisor")
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16, left: 5, bottom: 10),
                                      child: Text(
                                        ' - $salesloginno',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 200
                                        : 150,
                                    height: 33,
                                    color: Colors.grey[200],
                                    child: TextFormField(
                                      controller: SearchReqNoController,
                                      onChanged: (value) {
                                        setState(() {
                                          _searchreqno();
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Enter Request No',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.zero,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 10.0),
                                        filled: true,
                                        fillColor:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                      style: textBoxstyle,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  if (saveloginrole == "WHR SuperUser")
                                    Container(
                                      width: Responsive.isDesktop(context)
                                          ? 200
                                          : 150,
                                      height: 33,
                                      color: Colors.grey[200],
                                      child: TextFormField(
                                        controller: salesmanIdController,
                                        onChanged: (value) {
                                          setState(() {
                                            _search();
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Enter Salesman No',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.zero,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10.0,
                                                  horizontal: 10.0),
                                          filled: true,
                                          fillColor: Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        style: textBoxstyle,
                                      ),
                                    ),
                                  if (saveloginrole == "WHR SuperUser")
                                    const SizedBox(width: 10),
                                  if (saveloginrole == "WHR SuperUser")
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: Responsive.isMobile(context)
                                              ? 15
                                              : 0,
                                          top: Responsive.isMobile(context)
                                              ? 15
                                              : 0),
                                      child: Container(
                                        decoration:
                                            BoxDecoration(color: buttonColor),
                                        height: 30,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              salesmanIdController.clear();
                                              filteredData =
                                                  List.from(tableData);
                                            });

                                            postLogData(
                                                "Completed Dispatch", "Clear");
                                            // print("Refresh button pressed");
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
                                              'Clear',
                                              style: commonWhiteStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  Spacer(),
                                ]
                              ],
                            ),

                          SizedBox(
                            height: 10,
                          ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.start,
                          //   children: [
                          //     if (saveloginrole != "Salesman" &&
                          //         commersialrole != "Sales Supervisor") ...[
                          //       SizedBox(
                          //         width: 20,
                          //       ),
                          //       Container(
                          //         width:
                          //             Responsive.isDesktop(context) ? 200 : 150,
                          //         height: 33,
                          //         color: Colors.grey[200],
                          //         child: TextFormField(
                          //           controller: salesmanIdController,
                          //           onChanged: (value) {
                          //             setState(() {
                          //               _search();
                          //             });
                          //           },
                          //           decoration: InputDecoration(
                          //             hintText: 'Enter Salesman No',
                          //             border: OutlineInputBorder(
                          //               borderRadius: BorderRadius.zero,
                          //             ),
                          //             contentPadding:
                          //                 const EdgeInsets.symmetric(
                          //                     vertical: 10.0, horizontal: 10.0),
                          //             filled: true,
                          //             fillColor:
                          //                 Color.fromARGB(255, 255, 255, 255),
                          //           ),
                          //           style: textBoxstyle,
                          //         ),
                          //       ),
                          //       // const SizedBox(width: 10),
                          //       // Container(
                          //       //   height: 35,
                          //       //   decoration: BoxDecoration(color: buttonColor),
                          //       //   child: Padding(
                          //       //     padding: const EdgeInsets.only(
                          //       //         left: 5, right: 5, top: 3, bottom: 3),
                          //       //     child: ElevatedButton(
                          //       //       onPressed: () {
                          //       //         _search();
                          //       //         print("Search button pressed");
                          //       //       },
                          //       //       style: ElevatedButton.styleFrom(
                          //       //           shape: RoundedRectangleBorder(
                          //       //             borderRadius: BorderRadius.circular(8),
                          //       //           ),
                          //       //           backgroundColor: buttonColor),
                          //       //       child: const Text(
                          //       //         "Search",
                          //       //         style: TextStyle(
                          //       //             color: Colors.white, fontSize: 17),
                          //       //       ),
                          //       //     ),
                          //       //   ),
                          //       // ),
                          //       const SizedBox(width: 10),

                          //       Container(
                          //         decoration: BoxDecoration(color: buttonColor),
                          //         height: 30,
                          //         child: ElevatedButton(
                          //           onPressed: () {
                          //             setState(() {
                          //               salesmanIdController.clear();
                          //               filteredData = List.from(tableData);
                          //             });

                          //             postLogData(
                          //                 "Completed Dispatch", "Clear");
                          //             print("Refresh button pressed");
                          //           },
                          //           style: ElevatedButton.styleFrom(
                          //             shape: RoundedRectangleBorder(
                          //               borderRadius: BorderRadius.circular(8),
                          //             ),
                          //             minimumSize: const Size(45.0, 20.0),
                          //             backgroundColor: Colors.transparent,
                          //             shadowColor: Colors.transparent,
                          //           ),
                          //           child: Padding(
                          //             padding: const EdgeInsets.only(
                          //                 top: 0, bottom: 0, left: 8, right: 8),
                          //             child: const Text(
                          //               'Clear',
                          //               style: commonWhiteStyle,
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //       Spacer(),
                          //       // if (Responsive.isDesktop(context))
                          //       //   Row(
                          //       //     mainAxisAlignment: MainAxisAlignment.start,
                          //       //     children: [
                          //       //       Column(
                          //       //         crossAxisAlignment:
                          //       //             CrossAxisAlignment.start,
                          //       //         children: [
                          //       //           Row(
                          //       //             mainAxisAlignment:
                          //       //                 MainAxisAlignment.start,
                          //       //             children: [
                          //       //               Column(
                          //       //                 crossAxisAlignment:
                          //       //                     CrossAxisAlignment.start,
                          //       //                 children: [
                          //       //                   Row(
                          //       //                     children: [
                          //       //                       CircleAvatar(
                          //       //                         radius:
                          //       //                             3, // Adjust the size of the bullet
                          //       //                         backgroundColor:
                          //       //                             Color.fromARGB(
                          //       //                                 255,
                          //       //                                 23,
                          //       //                                 122,
                          //       //                                 5), // Bullet color
                          //       //                       ),
                          //       //                       SizedBox(
                          //       //                           width:
                          //       //                               8), // Space between bullet and text
                          //       //                       Text(
                          //       //                         'Dispatch Request',
                          //       //                         style: TextStyle(
                          //       //                           fontSize: 11,
                          //       //                           fontWeight:
                          //       //                               FontWeight.bold,
                          //       //                           color: Color.fromARGB(
                          //       //                               255, 23, 122, 5),
                          //       //                         ),
                          //       //                       ),
                          //       //                     ],
                          //       //                   ),
                          //       //                   Row(
                          //       //                     children: [
                          //       //                       CircleAvatar(
                          //       //                           radius:
                          //       //                               3, // Adjust the size of the bullet
                          //       //                           backgroundColor:
                          //       //                               Color.fromARGB(255,
                          //       //                                   200, 10, 10)),
                          //       //                       SizedBox(
                          //       //                           width:
                          //       //                               8), // Space between bullet and text
                          //       //                       Text(
                          //       //                         'Dispatch Assigned',
                          //       //                         style: TextStyle(
                          //       //                             fontSize: 11,
                          //       //                             fontWeight:
                          //       //                                 FontWeight.bold,
                          //       //                             color: Color.fromARGB(
                          //       //                                 255,
                          //       //                                 200,
                          //       //                                 10,
                          //       //                                 10)),
                          //       //                       ),
                          //       //                     ],
                          //       //                   ),
                          //       //                   const Row(
                          //       //                     children: [
                          //       //                       CircleAvatar(
                          //       //                         radius:
                          //       //                             3, // Adjust the size of the bullet
                          //       //                         backgroundColor:
                          //       //                             Color.fromARGB(
                          //       //                                 255, 176, 9, 179),
                          //       //                       ),
                          //       //                       const SizedBox(
                          //       //                           width:
                          //       //                               8), // Space between bullet and text
                          //       //                       Text(
                          //       //                         'Dispatch Picked',
                          //       //                         style: TextStyle(
                          //       //                           fontSize: 11,
                          //       //                           fontWeight:
                          //       //                               FontWeight.bold,
                          //       //                           color: Color.fromARGB(
                          //       //                               255, 176, 9, 179),
                          //       //                         ),
                          //       //                       ),
                          //       //                     ],
                          //       //                   ),
                          //       //                   Row(
                          //       //                     children: [
                          //       //                       CircleAvatar(
                          //       //                         radius:
                          //       //                             3, // Adjust the size of the bullet
                          //       //                         backgroundColor:
                          //       //                             Color.fromARGB(
                          //       //                                 255, 45, 13, 163),
                          //       //                       ),
                          //       //                       SizedBox(
                          //       //                           width:
                          //       //                               8), // Space between bullet and text
                          //       //                       Text(
                          //       //                         'Stage Completed',
                          //       //                         style: TextStyle(
                          //       //                           fontSize: 11,
                          //       //                           fontWeight:
                          //       //                               FontWeight.bold,
                          //       //                           color: Color.fromARGB(
                          //       //                               255, 45, 13, 163),
                          //       //                         ),
                          //       //                       ),
                          //       //                     ],
                          //       //                   ),
                          //       //                   Row(
                          //       //                     children: [
                          //       //                       CircleAvatar(
                          //       //                         radius:
                          //       //                             3, // Adjust the size of the bullet
                          //       //                         backgroundColor:
                          //       //                             Color.fromARGB(
                          //       //                                 255, 184, 128, 7),
                          //       //                       ),
                          //       //                       SizedBox(
                          //       //                           width:
                          //       //                               8), // Space between bullet and text
                          //       //                       Text(
                          //       //                         'Return Qty',
                          //       //                         style: TextStyle(
                          //       //                           fontSize: 11,
                          //       //                           fontWeight:
                          //       //                               FontWeight.bold,
                          //       //                           color: Color.fromARGB(
                          //       //                               255, 184, 128, 7),
                          //       //                         ),
                          //       //                       ),
                          //       //                     ],
                          //       //                   ),
                          //       //                 ],
                          //       //               ),
                          //       //             ],
                          //       //           ),
                          //       //         ],
                          //       //       ),
                          //       //     ],
                          //       //   ),
                          //     ],
                          //   ],
                          // ),
                          // if (!Responsive.isDesktop(context))
                          //   Row(
                          //     mainAxisAlignment: MainAxisAlignment.end,
                          //     children: [
                          //       Column(
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: [
                          //           Row(
                          //             mainAxisAlignment: MainAxisAlignment.start,
                          //             children: [
                          //               Column(
                          //                 crossAxisAlignment:
                          //                     CrossAxisAlignment.start,
                          //                 children: [
                          //                   Row(
                          //                     children: [
                          //                       CircleAvatar(
                          //                         radius:
                          //                             3, // Adjust the size of the bullet
                          //                         backgroundColor: Color.fromARGB(
                          //                             255,
                          //                             23,
                          //                             122,
                          //                             5), // Bullet color
                          //                       ),
                          //                       SizedBox(
                          //                           width:
                          //                               8), // Space between bullet and text
                          //                       Text(
                          //                         'Dispatch Request',
                          //                         style: TextStyle(
                          //                           fontSize: 11,
                          //                           fontWeight: FontWeight.bold,
                          //                           color: Color.fromARGB(
                          //                               255, 23, 122, 5),
                          //                         ),
                          //                       ),
                          //                     ],
                          //                   ),
                          //                   Row(
                          //                     children: [
                          //                       CircleAvatar(
                          //                           radius:
                          //                               3, // Adjust the size of the bullet
                          //                           backgroundColor:
                          //                               Color.fromARGB(
                          //                                   255, 200, 10, 10)),
                          //                       SizedBox(
                          //                           width:
                          //                               8), // Space between bullet and text
                          //                       Text(
                          //                         'Dispatch Assigned',
                          //                         style: TextStyle(
                          //                             fontSize: 11,
                          //                             fontWeight: FontWeight.bold,
                          //                             color: Color.fromARGB(
                          //                                 255, 200, 10, 10)),
                          //                       ),
                          //                     ],
                          //                   ),
                          //                   const Row(
                          //                     children: [
                          //                       CircleAvatar(
                          //                         radius:
                          //                             3, // Adjust the size of the bullet
                          //                         backgroundColor: Color.fromARGB(
                          //                             255, 176, 9, 179),
                          //                       ),
                          //                       const SizedBox(
                          //                           width:
                          //                               8), // Space between bullet and text
                          //                       Text(
                          //                         'Dispatch Picked',
                          //                         style: TextStyle(
                          //                           fontSize: 11,
                          //                           fontWeight: FontWeight.bold,
                          //                           color: Color.fromARGB(
                          //                               255, 176, 9, 179),
                          //                         ),
                          //                       ),
                          //                     ],
                          //                   ),
                          //                   Row(
                          //                     children: [
                          //                       CircleAvatar(
                          //                         radius:
                          //                             3, // Adjust the size of the bullet
                          //                         backgroundColor: Color.fromARGB(
                          //                             255, 45, 13, 163),
                          //                       ),
                          //                       SizedBox(
                          //                           width:
                          //                               8), // Space between bullet and text
                          //                       Text(
                          //                         'Stage Completed',
                          //                         style: TextStyle(
                          //                           fontSize: 11,
                          //                           fontWeight: FontWeight.bold,
                          //                           color: Color.fromARGB(
                          //                               255, 45, 13, 163),
                          //                         ),
                          //                       ),
                          //                     ],
                          //                   ),
                          //                 ],
                          //               ),
                          //             ],
                          //           ),
                          //         ],
                          //       ),
                          //     ],
                          //   ),

                          _buildTable()
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

  List<Map<String, dynamic>> tableData = [];

  // Future<void> fetchDispatchData() async {
  //   final url = Uri.parse('$IpAddress/Create_Dispatch/');
  //   try {
  //     final response = await http.get(url);
  //     // print('Response status: ${response.statusCode}');
  //     // print('Response body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final results = data['results'] as List?;

  //       if (results == null || results.isEmpty) {
  //         print('No results found');
  //         return; // No data to process
  //       }

  //       Map<String, Map<String, dynamic>> groupedData = {};

  //       for (var item in results) {
  //         String reqno = item['REQ_ID'];
  //         String salesmanId = item['SALESMAN_NO'].toString().split('.')[0];

  //         if (!groupedData.containsKey(reqno)) {
  //           groupedData[reqno] = {
  //             'id': item['id'],
  //             'salesman': salesmanId,
  //             'reqno': reqno,
  //             'salesmanName': item['SALESMAN_NAME'],
  //             'cusno': item['CUSTOMER_NUMBER'],
  //             'cusname': item['CUSTOMER_NAME'],
  //             'cussite': item['CUSTOMER_SITE_ID'],
  //             'total': double.parse(item['DISPATCHED_QTY'].toString()),
  //             'date': item['INVOICE_DATE'],
  //           };
  //         } else {
  //           groupedData[reqno]!['total'] +=
  //               double.parse(item['DISPATCHED_QTY'].toString());
  //         }
  //       }

  //       setState(() {
  //         tableData = groupedData.values.map((item) {
  //           return {
  //             'id': item['id'],
  //             'salesman': item['salesman'],
  //             'salesmanName': item['salesmanName'],
  //             'reqno': item['reqno'],
  //             'cusno': item['cusno'],
  //             'cusname': item['cusname'],
  //             'cussite': item['cussite'],
  //             'total': item['total'].toString(),
  //             'date':
  //                 DateFormat('dd.MM.yyyy').format(DateTime.parse(item['date'])),
  //           };
  //         }).toList();

  //         filteredData = List.from(tableData);
  //       });
  //       _filter();
  //     } else {
  //       print('Failed to load data: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   } finally {
  //     setState(() {
  //       _isLoadingData = false;
  //     });
  //   }
  // }

  Future<void> fetchDispatchData() async {
    final IpAddress = await getActiveIpAddress();

    String? nextPageUrl = '$IpAddress/Create_Dispatch/';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgid = prefs.getString('saleslogiOrgwarehousename') ?? '';
    String? salesloginrole = prefs.getString('salesloginrole') ?? '';
    String? salesloginno = prefs.getString('salesloginno') ?? '';
    Map<String, Map<String, dynamic>> groupedData = {};

    try {
      while (nextPageUrl != null && nextPageUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final results = data['results'] as List?;
          nextPageUrl =
              data['next']; // Update nextPageUrl to the next page link

          if (results == null || results.isEmpty) {
            print('No results found on this page.');
            continue; // Move to the next page if there are no results on the current one
          }

          // Process each item in the current page
          for (var item in results) {
            if (item['PHYSICAL_WAREHOUSE'] == saleslogiOrgid &&
                (salesloginrole == "WHR SuperUser"
                    ? true
                    : item['SALESMAN_NO'] == salesloginno)) {
              // print(
              //     "organisation id of the active salesman: ${item['ORG_ID']} and $saleslogiOrgid");
              String reqno = item['REQ_ID'];
              String salesmanId = item['SALESMAN_NO'].toString().split('.')[0];

              if (!groupedData.containsKey(reqno)) {
                groupedData[reqno] = {
                  'id': item['id'],
                  'salesman': salesmanId,
                  'reqno': reqno,
                  'salesmanName': item['SALESMAN_NAME'],
                  'cusno': item['CUSTOMER_NUMBER'],
                  'cusname': item['CUSTOMER_NAME'],
                  'cussite': item['CUSTOMER_SITE_ID'],
                  'dis_qty_total':
                      double.parse(item['DISPATCHED_QTY'].toString()),
                  'dis_mangerQty_total':
                      double.parse(item['DISPATCHED_BY_MANAGER'].toString()),
                  'date': formatDate(item['INVOICE_DATE']),
                  'balance_qty': double.parse(
                          item['DISPATCHED_QTY'].toString()) -
                      double.parse(item['DISPATCHED_BY_MANAGER']
                          .toString()), // Calculate balance_qty on first entry
                };
              } else {
                // Update totals for existing reqno
                groupedData[reqno]!['dis_qty_total'] +=
                    double.parse(item['DISPATCHED_QTY'].toString());
                groupedData[reqno]!['dis_mangerQty_total'] +=
                    double.parse(item['DISPATCHED_BY_MANAGER'].toString());

                // Recalculate balance_qty after updating totals
                groupedData[reqno]!['balance_qty'] =
                    groupedData[reqno]!['dis_qty_total'] -
                        groupedData[reqno]!['dis_mangerQty_total'];
              }
            }
          }
        } else {
          print('Failed to load data from page: ${response.statusCode}');
          break;
        }
      }

      // Convert groupedData to a list and format date
      setState(() {
        tableData = groupedData.values.map((item) {
          return {
            'id': item['id'],
            'salesman': item['salesman'],
            'salesmanName': item['salesmanName'],
            'reqno': item['reqno'],
            'cusno': item['cusno'],
            'cusname': item['cusname'],
            'cussite': item['cussite'],
            'dis_qty_total': item['dis_qty_total'].toString(),
            'dis_mangerQty_total': item['dis_mangerQty_total'].toString(),
            'balance_qty': item['balance_qty'].toString(),
            'date': item['date'],
          };
        }).toList();

        filteredData = List.from(tableData);
      });

      // Fetch additional data after setting state
      await fetchPreviousLoadCount();
      await fetchPickedScanQty();
      await fetchPickedScanQty();
      await fetchreturnCode();

      // Print tableData
      // print('Table Data:');
      // tableData.forEach((row) => print(row));

      // // Print filteredData
      // // print('Filtered Data:');
      // filteredData.forEach((row) => print(row));

      _filter(); // Apply any additional filtering if needed
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoadingData = false;
      });
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

  bool _isLoading = true;
  Future<void> fetchPreviousLoadCount() async {
    for (int i = 0; i < filteredData.length; i++) {
      // Extract `reqno` for the current entry in `filteredData`
      String reqno = filteredData[i]['reqno'].toString();

      final IpAddress = await getActiveIpAddress();

      try {
        // API URL for fetching truck scan data
        final truckScanUrl = '$IpAddress/Truck_scan/?REQ_ID=$reqno';
        // print("Fetching data from: $truckScanUrl");

        int totalCount = 0; // Total count of matching truck loads
        String? nextPageUrl = truckScanUrl; // Initial page URL for pagination

        // Indicate loading state
        setState(() {
          _isLoading = true;
        });

        // Loop through paginated results until all pages are processed
        while (nextPageUrl != null) {
          final response = await http.get(Uri.parse(nextPageUrl));

          if (response.statusCode == 200) {
            final Map<String, dynamic> responseData =
                json.decode(response.body);

            // Process `results` only if present in response
            if (responseData.containsKey('results')) {
              final List<dynamic> results = responseData['results'];

              // Count entries where `REQ_NO` matches the current `reqno`
              totalCount += results
                  .where((item) => item['REQ_ID'].toString() == reqno)
                  .length;
            }

            // Update `nextPageUrl` for further pagination
            nextPageUrl = responseData['next'];
          } else {
            throw Exception('Failed to fetch data: ${response.statusCode}');
          }
        }

        // Update `previous_truck_qty` in `filteredData`
        setState(() {
          filteredData[i]['previous_truck_qty'] = totalCount;
          // print('Updated previous_truck_qty for reqno $reqno: $totalCount');
        });
      } catch (e) {
        // Log any errors encountered
        // print('Error fetching data for reqno $reqno: $e');
      } finally {
        // Reset loading state after processing
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> fetchPickedScanQty() async {
    for (int i = 0; i < filteredData.length; i++) {
      // Extract REQ_ID as a string
      String reqno = filteredData[i]['reqno'].toString();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? saleslogiOrgid =
          prefs.getString('saleslogiOrgwarehousename') ?? '';

      final IpAddress = await getActiveIpAddress();

      try {
        // API URL for the filtered live stage report
        final String initialUrl =
            '$IpAddress/CompletedDispatchFilteredLivestageView/$reqno/';

        // Variables to handle paginated data
        bool hasNextPage = true;
        String? nextPageUrl = initialUrl;
        double totalPickedQty = 0;

        // Show a loading indicator
        (context as Element).markNeedsBuild();

        // Paginated API request logic
        while (hasNextPage && nextPageUrl != null) {
          final response = await http.get(Uri.parse(nextPageUrl));

          if (response.statusCode == 200) {
            final Map<String, dynamic> responseData =
                json.decode(response.body);

            // Check if the response contains results and process them
            if (responseData.containsKey('results')) {
              final List<dynamic> results = responseData['results'];

              // Calculate the total PICKED_QTY for this REQ_ID
              for (var item in results) {
                if (item['REQ_ID'].toString() == reqno) {
                  if (item['PHYSICAL_WAREHOUSE']?.toString() ==
                      saleslogiOrgid) {
                    totalPickedQty +=
                        double.tryParse(item['PICKED_QTY'].toString()) ?? 0;
                  }
                }
              }
            }

            // Check for the next page
            nextPageUrl = responseData['next'];
            hasNextPage = nextPageUrl != null;
          } else {
            throw Exception('Failed to fetch data from $nextPageUrl');
          }
        }

        // Save the totalPickedQty into filteredData
        filteredData[i]['picked_qty'] = totalPickedQty;

        // print('Updated picked_qtyyyyyyyyyyy for reqno $reqno: $totalPickedQty');
      } catch (e) {
        print('Error fetching data for reqno $reqno: $e');
      } finally {
        // Hide loading indicator
        (context as Element).markNeedsBuild();
      }
    }
  }

  Future<void> fetchreturnCode() async {
    for (int i = 0; i < filteredData.length; i++) {
      // Extract the necessary fields for the API request
      String reqno = filteredData[i]['reqno'].toString();
      String cusno = filteredData[i]['cusno'].toString();
      String cussite = filteredData[i]['cussite'].toString();

      final IpAddress = await getActiveIpAddress();

      try {
        // API URL for fetching the filtered return data
        final url = '$IpAddress/filteredreturnView/$reqno/$cusno/$cussite/';

        setState(() {
          _isLoading = true;
        });

        // Send a GET request to the API
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          // Parse the response data
          final Map<String, dynamic> responseData = json.decode(response.body);

          // If the response contains the 'total_count' field, update filteredData
          if (responseData.containsKey('total_count')) {
            // Assign the 'total_count' to the return_qty field
            setState(() {
              filteredData[i]['return_qty'] = responseData['total_count'];
              // print(
              //     'Updated return_qty for reqnoooooooooooooooooooooo $reqno: ${responseData['total_count']}');
            });
          } else {
            print('Error: No "total_count" in the response for reqno: $reqno');
          }
        } else {
          throw Exception('Failed to fetch data from $url');
        }
      } catch (e) {
        // Handle errors
        // print(
        //     'Error fetching data for reqno: $reqno, cusno: $cusno, cussite: $cussite: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filter() {
    if (saveloginrole == 'Salesman') {
      String? salesmanId = salesloginno;

      setState(() {
        filteredData =
            tableData.where((data) => data['salesman'] == salesmanId).toList();
      });
    } else {
      setState(() {
        filteredData = List.from(tableData);
      });
    }
  }

  Widget _buildTable() {
    double screenHeight = MediaQuery.of(context).size.height;

    // Helper function to create table headers
    Widget _tableHeader(String text, IconData icon, {double? width}) {
      return Container(
        width: width,
        height: Responsive.isDesktop(context) ? 25 : 30,
        decoration: TableHeaderColor,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 15, color: Colors.blue),
              SizedBox(width: 2),
              Expanded(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: commonLabelTextStyle,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Helper function to create table rows
    Widget _tableRow(String data, Color? rowColor,
        {double? width, String? tooltipMessage}) {
      return Container(
        width: width,
        height: 30,
        decoration: BoxDecoration(
          color: rowColor,
          border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
        ),
        child: tooltipMessage != null
            ? Tooltip(
                message: tooltipMessage,
                child: SelectableText(
                  data,
                  textAlign: TextAlign.left,
                  style: TableRowTextStyle,
                  showCursor: false,
                  cursorColor: Colors.blue,
                  cursorWidth: 2.0,
                  toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
                ),
              )
            : SelectableText(
                data,
                textAlign: TextAlign.left,
                style: TableRowTextStyle,
                showCursor: false,
                cursorColor: Colors.blue,
                cursorWidth: 2.0,
                toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
              ),
      );
    }

    // Define column widths
    final columnWidths = {
      'sno': 70.0,
      'reqno': 100.0,
      'salesman': 100.0,
      'date': 100.0,
      'cusno': 90.0,
      'cusname': 420.0,
      'cussite': 80.0,
      'status': 220.0,
      'actions': 130.0,
    };

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
                    Responsive.isDesktop(context) ? screenHeight * 0.68 : 400,
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.85
                    : MediaQuery.of(context).size.width * 3,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _tableHeader("S.No", Icons.format_list_numbered,
                            width: columnWidths['sno']),
                        _tableHeader("Req No", Icons.print,
                            width: columnWidths['reqno']),
                        if (saveloginrole == 'supervisor' ||
                            saveloginrole == 'manager')
                          _tableHeader("Sals No", Icons.print,
                              width: columnWidths['salesman']),
                        _tableHeader("Date", Icons.calendar_today,
                            width: columnWidths['date']),
                        _tableHeader("Cus No", Icons.category,
                            width: columnWidths['cusno']),
                        _tableHeader("Cus Name", Icons.person,
                            width: columnWidths['cusname']),
                        _tableHeader("Site No", Icons.location_on,
                            width: columnWidths['cussite']),
                        _tableHeader("Status", Icons.list,
                            width: columnWidths['status']),
                        _tableHeader("Actions", Icons.call_to_action,
                            width: columnWidths['actions']),
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
                  else if (filteredData.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: filteredData
                              .where((data) {
                                var dis_qty_total = double.tryParse(
                                        data['dis_qty_total'].toString()) ??
                                    0;
                                var previous_truck_qty = double.tryParse(
                                        data['previous_truck_qty']
                                            .toString()) ??
                                    0;
                                return dis_qty_total == previous_truck_qty;
                              })
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                                int index = entry.key;
                                var data = entry.value;

                                String sNo = (index + 1).toString();
                                String salesman = data['salesman'].toString();
                                String salesmanName =
                                    data['salesmanName'].toString();
                                String tablereqno =
                                    "${data['reqno'].toString()}";
                                String reqno = data['reqno'].toString();
                                String date = data['date'].toString();
                                String previous_truck_qty =
                                    data['previous_truck_qty'].toString();
                                String cusno = data['cusno'].toString();
                                String cusname = data['cusname'].toString();
                                String cussite = data['cussite'].toString();
                                String dis_qty_total = int.parse(double.parse(
                                            data['dis_qty_total'].toString())
                                        .toStringAsFixed(0))
                                    .toString();
                                String dis_mangerQty_total =
                                    data['dis_mangerQty_total'].toString();
                                String balance_qty = int.parse(double.parse(
                                            data['balance_qty'].toString())
                                        .toStringAsFixed(0))
                                    .toString();
                                String picked_qty =
                                    data['picked_qty'].toString();
                                String returnQty =
                                    data['return_qty'].toString();

                                double pickedQtyDouble =
                                    double.tryParse(picked_qty) ?? 0.0;
                                String finalpickqty = int.parse(
                                        double.parse(pickedQtyDouble.toString())
                                            .toStringAsFixed(0))
                                    .toString();

                                bool isEvenRow =
                                    filteredData.indexOf(data) % 2 == 0;
                                Color? rowColor = isEvenRow
                                    ? Color.fromARGB(224, 255, 255, 255)
                                    : Color.fromARGB(224, 255, 255, 255);

                                return GestureDetector(
                                  onTap: () {
                                    widget.togglePage(reqno, false);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        _tableRow(sNo, rowColor,
                                            width: columnWidths['sno']),
                                        _tableRow(tablereqno, rowColor,
                                            width: columnWidths['reqno']),
                                        if (saveloginrole == 'supervisor' ||
                                            saveloginrole == 'manager')
                                          _tableRow(salesman, rowColor,
                                              width: columnWidths['salesman'],
                                              tooltipMessage: salesmanName),
                                        _tableRow(date, rowColor,
                                            width: columnWidths['date']),
                                        _tableRow(cusno, rowColor,
                                            width: columnWidths['cusno']),
                                        _tableRow(cusname, rowColor,
                                            width: columnWidths['cusname']),
                                        _tableRow(cussite, rowColor,
                                            width: columnWidths['cussite']),
                                        Container(
                                          width: columnWidths['status'],
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225)),
                                          ),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Tooltip(
                                                  message: "Dispatch Request",
                                                  child: Text(dis_qty_total,
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 37, 139, 4),
                                                        fontSize: 14,
                                                      )),
                                                ),
                                                SizedBox(width: 5),
                                                Text("-",
                                                    style: TableRowTextStyle),
                                                SizedBox(width: 5),
                                                Tooltip(
                                                  message: "Dispatch Assigned",
                                                  child: Text(balance_qty,
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 225, 19, 19),
                                                        fontSize: 14,
                                                      )),
                                                ),
                                                SizedBox(width: 5),
                                                Text("-",
                                                    style: TableRowTextStyle),
                                                SizedBox(width: 5),
                                                Tooltip(
                                                  message: "Dispatch Picked",
                                                  child: Text(finalpickqty,
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 176, 9, 179),
                                                        fontSize: 14,
                                                      )),
                                                ),
                                                SizedBox(width: 5),
                                                Text("-",
                                                    style: TableRowTextStyle),
                                                SizedBox(width: 5),
                                                Tooltip(
                                                  message: "Stage Completed",
                                                  child: Text(
                                                      previous_truck_qty,
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 45, 13, 163),
                                                        fontSize: 14,
                                                      )),
                                                ),
                                                SizedBox(width: 5),
                                                Text("-",
                                                    style: TableRowTextStyle),
                                                SizedBox(width: 5),
                                                Tooltip(
                                                  message: "Return Qty",
                                                  child: Text(returnQty,
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 184, 128, 7),
                                                        fontSize: 14,
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: columnWidths['actions'],
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 0.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                    decoration: BoxDecoration(
                                                        color: buttonColor),
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          barrierDismissible:
                                                              false,
                                                          builder: (context) {
                                                            return Dialog(
                                                              child: Container(
                                                                color: Colors
                                                                    .grey[200],
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.8,
                                                                child: viewdialogbox(
                                                                    reqno:
                                                                        '$reqno'),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                        savereqno(reqno);
                                                        postLogData(
                                                            "Completed Dispatch",
                                                            "View");
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        minimumSize: const Size(
                                                            45.0, 20.0),
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        shadowColor:
                                                            Colors.transparent,
                                                      ),
                                                      child: Responsive
                                                              .isDesktop(
                                                                  context)
                                                          ? Text('View',
                                                              style:
                                                                  commonWhiteStyle)
                                                          : Icon(
                                                              Icons
                                                                  .remove_red_eye_outlined,
                                                              size: 12,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                    ))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 100.0),
                      child: Text("No completed dispatch available"),
                    ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildTable() {
  //   double screenHeight = MediaQuery.of(context).size.height;

  //   // Helper function to create table headers
  //   Widget _tableHeader(String text, IconData icon) {
  //     return Flexible(
  //       child: Container(
  //         height: Responsive.isDesktop(context) ? 25 : 30,
  //         decoration: TableHeaderColor,
  //         child: Center(
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             children: [
  //               Icon(icon, size: 15, color: Colors.blue),
  //               SizedBox(width: 2),
  //               Text(text,
  //                   textAlign: TextAlign.center, style: commonLabelTextStyle),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   }

  //   // Helper function to create table headers
  //   Widget _tableSNoHeader(String text, IconData icon) {
  //     return Flexible(
  //       child: Container(
  //         width: 70,
  //         height: Responsive.isDesktop(context) ? 25 : 30,
  //         decoration: TableHeaderColor,
  //         child: Center(
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             children: [
  //               Icon(icon, size: 15, color: Colors.blue),
  //               SizedBox(width: 2),
  //               Text(text,
  //                   textAlign: TextAlign.center, style: commonLabelTextStyle),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   }

  //   // Helper function to create table headers
  //   Widget _tableCusNameHeader(String text, IconData icon) {
  //     return SingleChildScrollView(
  //       child: Container(
  //         width: 250,
  //         height: Responsive.isDesktop(context) ? 25 : 30,
  //         decoration: TableHeaderColor,
  //         child: Center(
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             children: [
  //               Icon(icon, size: 15, color: Colors.blue),
  //               SizedBox(width: 2),
  //               Text(text,
  //                   textAlign: TextAlign.center, style: commonLabelTextStyle),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   }

  //   // Helper function to create table headers
  //   Widget _tableCussiteHeader(String text, IconData icon) {
  //     return SingleChildScrollView(
  //       child: Container(
  //         width: 100,
  //         height: Responsive.isDesktop(context) ? 25 : 30,
  //         decoration: TableHeaderColor,
  //         child: Center(
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             children: [
  //               Icon(icon, size: 15, color: Colors.blue),
  //               SizedBox(width: 2),
  //               Text(text,
  //                   textAlign: TextAlign.center, style: commonLabelTextStyle),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   }

  //   // Helper function to create table rows
  //   Widget _tableRow(String data, Color? rowColor, {String? tooltipMessage}) {
  //     return Flexible(
  //       child: Container(
  //         height: 30,
  //         decoration: BoxDecoration(
  //           color: rowColor,
  //           border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
  //         ),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             Center(
  //               child: tooltipMessage != null
  //                   ? Tooltip(
  //                       message: tooltipMessage,
  //                       child: Text(data,
  //                           textAlign: TextAlign.center,
  //                           style: TableRowTextStyle),
  //                     )
  //                   : Text(data,
  //                       textAlign: TextAlign.center, style: TableRowTextStyle),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }

  //   Widget _tableSNoRow(String data, Color? rowColor,
  //       {String? tooltipMessage}) {
  //     return Flexible(
  //       child: Container(
  //         width: 70,
  //         height: 30,
  //         decoration: BoxDecoration(
  //           color: rowColor,
  //           border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
  //         ),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             Center(
  //               child: tooltipMessage != null
  //                   ? Tooltip(
  //                       message: tooltipMessage,
  //                       child: SelectableText(
  //                         data,
  //                         textAlign: TextAlign.left,
  //                         style: TableRowTextStyle,
  //                         showCursor: false,
  //                         // overflow: TextOverflow.ellipsis,
  //                         cursorColor: Colors.blue,
  //                         cursorWidth: 2.0,
  //                         toolbarOptions:
  //                             ToolbarOptions(copy: true, selectAll: true),
  //                         onTap: () {
  //                           // Optional: Handle single tap if needed
  //                         },
  //                       ),
  //                       //  Text(data,
  //                       // textAlign: TextAlign.center,
  //                       // style: TableRowTextStyle),
  //                     )
  //                   : SelectableText(
  //                       data,
  //                       textAlign: TextAlign.left,
  //                       style: TableRowTextStyle,
  //                       showCursor: false,
  //                       // overflow: TextOverflow.ellipsis,
  //                       cursorColor: Colors.blue,
  //                       cursorWidth: 2.0,
  //                       toolbarOptions:
  //                           ToolbarOptions(copy: true, selectAll: true),
  //                       onTap: () {
  //                         // Optional: Handle single tap if needed
  //                       },
  //                     ),
  //               // Text(data,
  //               //     textAlign: TextAlign.center, style: TableRowTextStyle),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }

  //   Widget _tableCusNameRow(String data, Color? rowColor,
  //       {String? tooltipMessage}) {
  //     return Container(
  //       width: 250, // Set a fixed width for the column
  //       height: 30, // Adjust row height as needed
  //       decoration: BoxDecoration(
  //         color: rowColor,
  //         border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
  //       ),
  //       child: Center(
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             Flexible(
  //               child: tooltipMessage != null
  //                   ? Tooltip(
  //                       message: tooltipMessage,
  //                       child:
  //                           // Text(
  //                           //   data,
  //                           //   maxLines: 1, // Restrict to a single line
  //                           //   overflow: TextOverflow
  //                           //       .ellipsis, // Add ellipsis for overflow
  //                           //   textAlign: TextAlign.center,
  //                           //   style: TableRowTextStyle,
  //                           // ),
  //                           SelectableText(
  //                         data,
  //                         textAlign: TextAlign.left,
  //                         style: TableRowTextStyle,
  //                         showCursor: false,
  //                         // overflow: TextOverflow.ellipsis,
  //                         cursorColor: Colors.blue,
  //                         cursorWidth: 2.0,
  //                         toolbarOptions:
  //                             ToolbarOptions(copy: true, selectAll: true),
  //                         onTap: () {
  //                           // Optional: Handle single tap if needed
  //                         },
  //                       ),
  //                       //  Text(data,
  //                       // textAlign: TextAlign.center,
  //                       // style: TableRowTextStyle),
  //                     )
  //                   : SelectableText(
  //                       data,
  //                       textAlign: TextAlign.left,
  //                       style: TableRowTextStyle,
  //                       showCursor: false,
  //                       // overflow: TextOverflow.ellipsis,
  //                       cursorColor: Colors.blue,
  //                       cursorWidth: 2.0,
  //                       toolbarOptions:
  //                           ToolbarOptions(copy: true, selectAll: true),
  //                       onTap: () {
  //                         // Optional: Handle single tap if needed
  //                       },
  //                     ),
  //               // Text(data,
  //               //     textAlign: TextAlign.center, style: TableRowTextStyle),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }

  //   Widget _tableCussiteRow(String data, Color? rowColor,
  //       {String? tooltipMessage}) {
  //     return Container(
  //       width: 100, // Set a fixed width for the column
  //       height: 30, // Adjust row height as needed
  //       decoration: BoxDecoration(
  //         color: rowColor,
  //         border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
  //       ),
  //       child: Center(
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             Flexible(
  //               child: tooltipMessage != null
  //                   ? Tooltip(
  //                       message: tooltipMessage,
  //                       child:
  //                           // Text(
  //                           //   data,
  //                           //   maxLines: 1, // Restrict to a single line
  //                           //   overflow: TextOverflow
  //                           //       .ellipsis, // Add ellipsis for overflow
  //                           //   textAlign: TextAlign.center,
  //                           //   style: TableRowTextStyle,
  //                           // ),
  //                           SelectableText(
  //                         data,
  //                         textAlign: TextAlign.left,
  //                         style: TableRowTextStyle,
  //                         showCursor: false,
  //                         // overflow: TextOverflow.ellipsis,
  //                         cursorColor: Colors.blue,
  //                         cursorWidth: 2.0,
  //                         toolbarOptions:
  //                             ToolbarOptions(copy: true, selectAll: true),
  //                         onTap: () {
  //                           // Optional: Handle single tap if needed
  //                         },
  //                       ),
  //                       //  Text(data,
  //                       // textAlign: TextAlign.center,
  //                       // style: TableRowTextStyle),
  //                     )
  //                   : SelectableText(
  //                       data,
  //                       textAlign: TextAlign.left,
  //                       style: TableRowTextStyle,
  //                       showCursor: false,
  //                       // overflow: TextOverflow.ellipsis,
  //                       cursorColor: Colors.blue,
  //                       cursorWidth: 2.0,
  //                       toolbarOptions:
  //                           ToolbarOptions(copy: true, selectAll: true),
  //                       onTap: () {
  //                         // Optional: Handle single tap if needed
  //                       },
  //                     ),
  //               // Text(data,
  //               //     textAlign: TextAlign.center, style: TableRowTextStyle),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }

  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     child: Scrollbar(
  //       thumbVisibility: true,
  //       controller: _horizontalScrollController,
  //       child: SingleChildScrollView(
  //         controller: _horizontalScrollController,
  //         scrollDirection: Axis.horizontal,
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Container(
  //               color: Colors.white,
  //               height:
  //                   Responsive.isDesktop(context) ? screenHeight * 0.68 : 400,
  //               width: Responsive.isDesktop(context)
  //                   ? MediaQuery.of(context).size.width * 0.85
  //                   : MediaQuery.of(context).size.width * 3,
  //               child: Column(children: [
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(
  //                       horizontal: 10, vertical: 13),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       _tableSNoHeader("S.No", Icons.format_list_numbered),
  //                       _tableHeader("Req No", Icons.print),
  //                       if (saveloginrole == 'supervisor' ||
  //                           saveloginrole == 'manager')
  //                         _tableHeader("Salesman No", Icons.print),
  //                       _tableHeader("Date", Icons.calendar_today),
  //                       _tableHeader("Customer No", Icons.category),
  //                       _tableCusNameHeader("Cus Name", Icons.person),
  //                       _tableCussiteHeader("Site No", Icons.location_on),
  //                       _tableHeader("Status", Icons.list),
  //                       _tableHeader("Actions", Icons.call_to_action),
  //                     ],
  //                   ),
  //                 ),
  //                 if (_isLoadingData)
  //                   Padding(
  //                     padding: const EdgeInsets.only(top: 100.0),
  //                     child: Center(
  //                       child: CircularProgressIndicator(),
  //                     ),
  //                   )
  //                 else if (filteredData.isNotEmpty)
  //                   Expanded(
  //                     // Ensure that the content inside scrolls
  //                     child: SingleChildScrollView(
  //                       scrollDirection: Axis.vertical,
  //                       child: Column(
  //                           children: filteredData
  //                               .where((data) {
  //                                 // Parse total to a double and check if it's greater than 0
  //                                 var dis_qty_total = double.tryParse(
  //                                         data['dis_qty_total'].toString()) ??
  //                                     0;
  //                                 var previous_truck_qty = double.tryParse(
  //                                         data['previous_truck_qty']
  //                                             .toString()) ??
  //                                     0;
  //                                 return dis_qty_total == previous_truck_qty;
  //                               })
  //                               .toList()
  //                               .asMap()
  //                               .entries
  //                               .map((entry) {
  //                                 // Convert to list and use asMap
  //                                 int index = entry.key;
  //                                 var data = entry.value;

  //                                 String sNo = (index + 1).toString(); // S.No
  //                                 String salesman = data['salesman'].toString();
  //                                 String salesmanName =
  //                                     data['salesmanName'].toString();

  //                                 String tablereqno =
  //                                     "${data['reqno'].toString()}";
  //                                 String reqno = data['reqno'].toString();
  //                                 String date = data['date'].toString();

  //                                 // Split the input date string

  //                                 String previous_truck_qty =
  //                                     data['previous_truck_qty'].toString();

  //                                 // Check if the parts are valid

  //                                 String cusno = data['cusno'].toString();
  //                                 String cusname = data['cusname'].toString();
  //                                 String cussite = data['cussite'].toString();
  //                                 // String dis_qty_total =
  //                                 //     data['dis_qty_total'].toString();
  //                                 String dis_qty_total = int.parse(double.parse(
  //                                             data['dis_qty_total'].toString())
  //                                         .toStringAsFixed(0))
  //                                     .toString();
  //                                 String dis_mangerQty_total =
  //                                     data['dis_mangerQty_total'].toString();
  //                                 // String balance_qty =
  //                                 //     data['balance_qty'].toString();

  //                                 String balance_qty = int.parse(double.parse(
  //                                             data['balance_qty'].toString())
  //                                         .toStringAsFixed(0))
  //                                     .toString();
  //                                 String picked_qty =
  //                                     data['picked_qty'].toString();
  //                                 String returnQty =
  //                                     data['return_qty'].toString();

  //                                 double pickedQtyDouble =
  //                                     double.tryParse(picked_qty) ?? 0.0;
  //                                 String finalpickqty = int.parse(double.parse(
  //                                             pickedQtyDouble.toString())
  //                                         .toStringAsFixed(0))
  //                                     .toString();

  //                                 bool isEvenRow =
  //                                     filteredData.indexOf(data) % 2 == 0;
  //                                 Color? rowColor = isEvenRow
  //                                     ? Color.fromARGB(224, 255, 255, 255)
  //                                     : Color.fromARGB(224, 255, 255, 255);

  //                                 return GestureDetector(
  //                                   onTap: () {
  //                                     // Navigator.pushReplacement(
  //                                     //   context,
  //                                     //   MaterialPageRoute(
  //                                     //     builder: (context) => MainSidebar(
  //                                     //       initialPageIndex: 16,
  //                                     //       enabledItems: accessControl,
  //                                     //     ), // Navigate to MainSidebar
  //                                     //   ),
  //                                     // );
  //                                     widget.togglePage(reqno, false);
  //                                   },
  //                                   child: Padding(
  //                                     padding: const EdgeInsets.symmetric(
  //                                       horizontal: 10,
  //                                     ),
  //                                     child: Row(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.center,
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.center,
  //                                       children: [
  //                                         _tableSNoRow(sNo, rowColor),
  //                                         _tableRow(tablereqno, rowColor),

  //                                         if (saveloginrole == 'supervisor' ||
  //                                             saveloginrole == 'manager')
  //                                           _tableRow(salesman, rowColor,
  //                                               tooltipMessage:
  //                                                   salesmanName), // Pass the tooltip message

  //                                         _tableRow(date, rowColor),
  //                                         _tableRow(cusno, rowColor),
  //                                         _tableCusNameRow(cusname, rowColor),
  //                                         _tableCussiteRow(cussite, rowColor),

  //                                         Flexible(
  //                                           child: Container(
  //                                             height: 30,
  //                                             width:
  //                                                 Responsive.isDesktop(context)
  //                                                     ? MediaQuery.of(context)
  //                                                         .size
  //                                                         .width
  //                                                     : MediaQuery.of(context)
  //                                                             .size
  //                                                             .width *
  //                                                         1,
  //                                             decoration: BoxDecoration(
  //                                               color: rowColor,
  //                                               border: Border.all(
  //                                                   color: Color.fromARGB(
  //                                                       255, 226, 225, 225)),
  //                                             ),
  //                                             child: Row(
  //                                               mainAxisAlignment:
  //                                                   MainAxisAlignment.start,
  //                                               children: [
  //                                                 Center(
  //                                                   child:
  //                                                       SingleChildScrollView(
  //                                                     scrollDirection:
  //                                                         Axis.horizontal,
  //                                                     child: Row(
  //                                                       mainAxisAlignment:
  //                                                           MainAxisAlignment
  //                                                               .start,
  //                                                       children: [
  //                                                         Tooltip(
  //                                                           message:
  //                                                               "Dispatch Request",
  //                                                           child: Text(
  //                                                               dis_qty_total,
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .center,
  //                                                               style:
  //                                                                   TextStyle(
  //                                                                 color: Color
  //                                                                     .fromARGB(
  //                                                                         255,
  //                                                                         37,
  //                                                                         139,
  //                                                                         4),
  //                                                                 fontSize: 14,
  //                                                               )),
  //                                                         ),
  //                                                         SizedBox(
  //                                                           width: 5,
  //                                                         ),
  //                                                         Text("-",
  //                                                             textAlign:
  //                                                                 TextAlign
  //                                                                     .center,
  //                                                             style:
  //                                                                 TableRowTextStyle),
  //                                                         SizedBox(
  //                                                           width: 5,
  //                                                         ),
  //                                                         Tooltip(
  //                                                           message:
  //                                                               "Dispatch Assigned",
  //                                                           child: Text(
  //                                                               balance_qty,
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .center,
  //                                                               style:
  //                                                                   TextStyle(
  //                                                                 color: Color
  //                                                                     .fromARGB(
  //                                                                         255,
  //                                                                         225,
  //                                                                         19,
  //                                                                         19),
  //                                                                 fontSize: 14,
  //                                                               )),
  //                                                         ),
  //                                                         SizedBox(
  //                                                           width: 5,
  //                                                         ),
  //                                                         Text("-",
  //                                                             textAlign:
  //                                                                 TextAlign
  //                                                                     .center,
  //                                                             style:
  //                                                                 TableRowTextStyle),
  //                                                         SizedBox(
  //                                                           width: 5,
  //                                                         ),
  //                                                         Tooltip(
  //                                                           message:
  //                                                               "Dispatch Picked",
  //                                                           child: Text(
  //                                                               finalpickqty,
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .center,
  //                                                               style:
  //                                                                   TextStyle(
  //                                                                 color: Color
  //                                                                     .fromARGB(
  //                                                                         255,
  //                                                                         176,
  //                                                                         9,
  //                                                                         179),
  //                                                                 fontSize: 14,
  //                                                               )),
  //                                                         ),
  //                                                         SizedBox(
  //                                                           width: 5,
  //                                                         ),
  //                                                         Text("-",
  //                                                             textAlign:
  //                                                                 TextAlign
  //                                                                     .center,
  //                                                             style:
  //                                                                 TableRowTextStyle),
  //                                                         SizedBox(
  //                                                           width: 5,
  //                                                         ),
  //                                                         Tooltip(
  //                                                           message:
  //                                                               "Stage Completed",
  //                                                           child: Text(
  //                                                               previous_truck_qty,
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .center,
  //                                                               style:
  //                                                                   TextStyle(
  //                                                                 color: Color
  //                                                                     .fromARGB(
  //                                                                         255,
  //                                                                         45,
  //                                                                         13,
  //                                                                         163),
  //                                                                 fontSize: 14,
  //                                                               )),
  //                                                         ),
  //                                                         SizedBox(
  //                                                           width: 5,
  //                                                         ),
  //                                                         Text("-",
  //                                                             textAlign:
  //                                                                 TextAlign
  //                                                                     .center,
  //                                                             style:
  //                                                                 TableRowTextStyle),
  //                                                         SizedBox(
  //                                                           width: 5,
  //                                                         ),
  //                                                         Tooltip(
  //                                                           message:
  //                                                               "Return Qty",
  //                                                           child: Text(
  //                                                               returnQty,
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .center,
  //                                                               style:
  //                                                                   TextStyle(
  //                                                                 color: Color
  //                                                                     .fromARGB(
  //                                                                         255,
  //                                                                         184,
  //                                                                         128,
  //                                                                         7),
  //                                                                 fontSize: 14,
  //                                                               )),
  //                                                         ),
  //                                                       ],
  //                                                     ),
  //                                                   ),
  //                                                 ),
  //                                               ],
  //                                             ),
  //                                           ),
  //                                         ),
  //                                         // _tableRow(
  //                                         //     "$dis_qty_total - $dis_mangerQty_total - $balance_qty",
  //                                         //     rowColor),
  //                                         Flexible(
  //                                           child: Container(
  //                                             height: MediaQuery.of(context)
  //                                                     .size
  //                                                     .height *
  //                                                 .042,
  //                                             decoration: BoxDecoration(
  //                                               color: rowColor,
  //                                               border: Border.all(
  //                                                 color: Color.fromARGB(
  //                                                     255, 226, 225, 225),
  //                                               ),
  //                                             ),
  //                                             child: Padding(
  //                                               padding: const EdgeInsets.only(
  //                                                   bottom: 0.0),
  //                                               child: Row(
  //                                                 mainAxisAlignment:
  //                                                     MainAxisAlignment.start,
  //                                                 children: [
  //                                                   Container(
  //                                                     decoration: BoxDecoration(
  //                                                         color: buttonColor),
  //                                                     child: ElevatedButton(
  //                                                       onPressed: () {
  //                                                         showDialog(
  //                                                           context: context,
  //                                                           barrierDismissible:
  //                                                               false,
  //                                                           builder: (context) {
  //                                                             return Dialog(
  //                                                               child:
  //                                                                   Container(
  //                                                                 color: Colors
  //                                                                         .grey[
  //                                                                     200],
  //                                                                 width: MediaQuery.of(
  //                                                                             context)
  //                                                                         .size
  //                                                                         .width *
  //                                                                     0.7,
  //                                                                 child:
  //                                                                     viewdialogbox(
  //                                                                   reqno:
  //                                                                       '$reqno',
  //                                                                 ),
  //                                                               ),
  //                                                             );
  //                                                           },
  //                                                         );
  //                                                         savereqno(reqno);

  //                                                         postLogData(
  //                                                             "Completed Dispatch",
  //                                                             "View");
  //                                                       },
  //                                                       style: ElevatedButton
  //                                                           .styleFrom(
  //                                                         shape:
  //                                                             RoundedRectangleBorder(
  //                                                           borderRadius:
  //                                                               BorderRadius
  //                                                                   .circular(
  //                                                                       8),
  //                                                         ),
  //                                                         minimumSize:
  //                                                             const Size(
  //                                                                 45.0, 20.0),
  //                                                         backgroundColor:
  //                                                             Colors
  //                                                                 .transparent,
  //                                                         shadowColor: Colors
  //                                                             .transparent,
  //                                                       ),
  //                                                       child: Responsive
  //                                                               .isDesktop(
  //                                                                   context)
  //                                                           ? Text('View',
  //                                                               style:
  //                                                                   commonWhiteStyle)
  //                                                           : Icon(
  //                                                               Icons
  //                                                                   .remove_red_eye_outlined,
  //                                                               size: 12,
  //                                                               color: Colors
  //                                                                   .white,
  //                                                             ),
  //                                                     ),
  //                                                   )
  //                                                 ],
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 );
  //                               })
  //                               .toList()),
  //                     ),
  //                   )
  //                 else
  //                   Padding(
  //                     padding: const EdgeInsets.only(top: 100.0),
  //                     child: Text("No completed dispatch available"),
  //                   ),
  //               ]),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<void> savereqno(String dispaatch_requestno) async {
    await SharedPrefs.dispaatch_requestno(dispaatch_requestno);
  }
}

class viewdialogbox extends StatefulWidget {
  final String reqno;
  // final String date;
  // final String cussite;
  // final String cusId;
  // final String customerName;

  viewdialogbox({
    super.key,
    required this.reqno,
    // required this.date,
    // required this.cussite,
    // required this.cusId,
    // required this.customerName,
  });

  @override
  State<viewdialogbox> createState() => _viewdialogboxState();
}

class _viewdialogboxState extends State<viewdialogbox> {
  bool _isLoading = true;

  final ScrollController _horizontalScrollController2 = ScrollController();
  final ScrollController _verticalScrollController2 = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController2.dispose();
    _verticalScrollController2.dispose();
    super.dispose();
  }

  Widget _buildTextFieldDesktop(
    String label,
    String value,
    bool readOnly, // New parameter to control read-only state
  ) {
    String formattedValue = label == 'Date' && value.isNotEmpty
        ? _formatDate(value) // Call the _formatDate function
        : value;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: Responsive.isDesktop(context) ? screenWidth * 0.15 : screenWidth,
      child: Padding(
        padding: const EdgeInsets.only(left: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 0),
            Row(
              children: [
                Text(label, style: textboxheading),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 0, bottom: 0),
              child: Row(
                children: [
                  Container(
                    height: 34,
                    width: Responsive.isDesktop(context)
                        ? screenWidth * 0.14
                        : screenWidth * 0.5,
                    child: MouseRegion(
                      onEnter: (event) {
                        // You can perform any action when mouse enters, like logging the value.
                      },
                      onExit: (event) {
                        // Perform any action when the mouse leaves the TextField area.
                      },
                      cursor: SystemMouseCursors.click,
                      child: Tooltip(
                        message: value,
                        child: TextField(
                            readOnly: readOnly, // Set readOnly state
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
                              filled: true,
                              fillColor: readOnly
                                  ? Color.fromARGB(255, 234, 234,
                                      234) // Change fill color when readOnly is true
                                  : Color.fromARGB(255, 250, 250,
                                      250), // Default color when not readOnly
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0,
                              ),
                            ),
                            controller:
                                TextEditingController(text: formattedValue),
                            style: textBoxstyle),
                      ),
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

  String _formatDate(String dateString) {
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('dd-MMM-yyyy').format(parsedDate).toUpperCase();
    } catch (e) {
      return dateString;
    }
  }

  List<Map<String, dynamic>> _dispatchData = [];

  Future<String> _fetchDispatchId(String itemCode) async {
    final reqid = widget.reqno;
    final cusno = _CusidController.text;
    final cussite = _CussiteController.text;

    final IpAddress = await getActiveIpAddress();

    final response = await http.get(
      Uri.parse(
        '$IpAddress/GetFilteredTruckDetailsView/$reqid/$cusno/$cussite/$itemCode/',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        return data[0]['DISPATCH_ID'] ?? 'N/A';
      }
    }
    return 'N/A';
  }

  List<Map<String, dynamic>> createtableData = [];

  TextEditingController _totalController = TextEditingController();
  TextEditingController _DateController = TextEditingController();
  TextEditingController _CusidController = TextEditingController();
  TextEditingController _CussiteController = TextEditingController();
  TextEditingController _CustomerNameController = TextEditingController();
  TextEditingController _RegionController = TextEditingController();
  TextEditingController _WarehousenameNameController = TextEditingController();

  Widget _viewbuildTable() {
    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight = Responsive.isDesktop(context) ? 30 : 30;

    List<Map<String, dynamic>> sortedTableData = List.from(createtableData);
    sortedTableData.sort((a, b) =>
        int.parse(a['id'].toString()).compareTo(int.parse(b['id'].toString())));

    List<Map<String, dynamic>> tableHeaders = [
      {'icon': Icons.receipt, 'label': 'Invoice No'},
      {'icon': Icons.category, 'label': 'L.No'},
      {'icon': Icons.code, 'label': 'Item Code'},
      {'icon': Icons.details, 'label': 'Item Description'},
      {'icon': Icons.check, 'label': 'Qty.Inv'},
      {'icon': Icons.list, 'label': 'Qty.Req'},
      {'icon': Icons.production_quantity_limits, 'label': 'Picked'},
      {'icon': Icons.fire_truck_rounded, 'label': 'Deliver'},
      {'icon': Icons.fire_truck_rounded, 'label': 'Returned'},
      // {'icon': Icons.check_circle, 'label': 'Status'},
    ];

    List<double> columnWidths = [100, 60, 120, 350, 80, 100, 80, 80, 80, 100];

    // Build Header Cells
    Widget _buildHeaderCell(Map<String, dynamic> header, double width) {
      return Container(
        height: containerHeight,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(header['icon'], size: 15, color: Colors.blue),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                header['label'],
                textAlign: TextAlign.start,
                style: commonLabelTextStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    // Build Data Cells
    Widget _buildDataCell(String? value, double width, String Message) {
      return Container(
        height: 50,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: const Color.fromARGB(255, 226, 225, 225)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Tooltip(
              message: Message,
              child: SelectableText(
                value ?? 'N/A',
                textAlign: TextAlign.left,
                style: TableRowTextStyle,
                showCursor: false,
              ),
            ),
          ),
        ),
      );
    }

    return Stack(children: [
      ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(Colors.grey[600]),
          thumbVisibility: MaterialStateProperty.all(true),
          thickness: MaterialStateProperty.all(8),
          radius: const Radius.circular(10),
        ),
        child: Scrollbar(
          thumbVisibility: true,
          controller: _horizontalScrollController2,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _horizontalScrollController2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: tableHeaders.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> header = entry.value;
                    return _buildHeaderCell(header, columnWidths[index]);
                  }).toList(),
                ),
                const SizedBox(height: 5),
                // Data rows
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: _isLoading
                          ? [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 60.0, left: 450),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            ]
                          : (sortedTableData.isNotEmpty
                              ? sortedTableData.map((data) {
                                  _fetchDispatchId(data['itemcode']);

                                  String dispatchId = 'N/A'; // Default value
                                  var dispatchInfo = _dispatchData.firstWhere(
                                    (dispatch) =>
                                        dispatch['ITEM_CODE'] ==
                                        data['itemcode'],
                                    orElse: () =>
                                        {}, // Return an empty map if no match is found
                                  );

                                  // print('dispatchInfo: $dispatchInfo');

                                  if (dispatchInfo.isNotEmpty) {
                                    _fetchDispatchId(data['itemcode']);
                                    dispatchId = dispatchInfo['DISPATCH_ID'] ??
                                        'N/A'; // Assign ITEM_CODE if found
                                    print('DispatchId:$dispatchId');
                                  } else {
                                    print('No matching dispatch found.');
                                  }

                                  return GestureDetector(
                                    onTap: () {},
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        _buildDataCell(
                                            data['invoiceno']?.toString(),
                                            columnWidths[0],
                                            ''),
                                        _buildDataCell(data['id']?.toString(),
                                            columnWidths[1], ''),
                                        _buildDataCell(
                                            data['itemcode']?.toString(),
                                            columnWidths[2],
                                            ''),
                                        _buildDataCell(
                                            data['itemdetails']?.toString(),
                                            columnWidths[3],
                                            ''),
                                        _buildDataCell(
                                            data['invoiceqty']?.toString(),
                                            columnWidths[4],
                                            ''),
                                        Container(
                                          height: 50,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            border: Border.all(
                                                color: const Color.fromARGB(
                                                    255, 226, 225, 225)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Tooltip(
                                                message: 'Asigned Qty',
                                                child: Text(
                                                  data['itemqty']?.toString() ??
                                                      'N/A',
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 0, 128, 34),
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text("-",
                                                  style: TableRowTextStyle),
                                              const SizedBox(width: 10),
                                              Tooltip(
                                                message: 'Balance Asigned Qty',
                                                child: Text(
                                                  data['balitemqty']
                                                          ?.toString() ??
                                                      'N/A',
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 147, 0, 0),
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _buildDataCell(
                                            data['total_picked_qty']
                                                ?.toString(),
                                            columnWidths[6],
                                            'Picked Qty'),
                                        _buildDataCell(
                                            data['total_truck_qty']?.toString(),
                                            columnWidths[7],
                                            'Delivered Qty'),
                                        _buildDataCell(
                                            data['total_return_qty']
                                                ?.toString(),
                                            columnWidths[8],
                                            'Returned Qty'),
                                        // _buildDataCell(
                                        //     data['status']?.toString(),
                                        //     columnWidths[9],
                                        //     ''),
                                      ],
                                    ),
                                  );
                                }).toList()
                              : [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 60.0),
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
                _horizontalScrollController2.animateTo(
                  _horizontalScrollController2.offset -
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
                _horizontalScrollController2.animateTo(
                  _horizontalScrollController2.offset +
                      100, // Adjust scroll amount
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    fetchAccessControl();
    fetchDataReqnO();
    _loadSalesmanName();
    // _updateTotal();
    fetchDispatchDetails();
  }

  Future<void> fetchDispatchDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgwarehousename =
        prefs.getString('saleslogiOrgwarehousename') ?? '';

    String? reqno = prefs.getString('reqno');

    final IpAddress = await getActiveIpAddress();

    final response = await http.get(Uri.parse(
        '$IpAddress/filtered_dispatchrequest/$reqno/$saleslogiOrgwarehousename/'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        var tableDetails = data[0]['TABLE_DETAILS'];

        double totalQty = 0.0;
        for (var item in tableDetails) {
          totalQty += item['DISPATCHED_QTY'];
        }

        setState(() {
          _totalController.text = totalQty.toString();
          // print("total amount of the dispatchqty : ${_CusidController.text}");
        });
      }
    } else {
      throw Exception('Failed to load dispatch details');
    }
    setState(() {
      _isLoading = false;
    });
  }

  List<bool> accessControl = [];

  TextEditingController _DeliveryateController = TextEditingController();
  Future<void> fetchAccessControl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginnoStr = prefs.getString('salesloginno');
    final String uniqueId = salesloginnoStr.toString();

    final IpAddress = await getActiveIpAddress();

    String apiUrl = '$IpAddress/User_member_details/';
    bool userFound = false;

    try {
      // Loop through each page until the user with uniqueId is found or no more pages are left
      while (apiUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          // Decode the JSON response
          final data = json.decode(response.body);

          // Find the user with the matching unique_id on the current page
          var user = (data['results'] as List<dynamic>).firstWhere(
            (u) => u['unique_id'] == uniqueId,
            orElse: () => null,
          );

          if (user != null) {
            userFound = true;

            // Check if access_control is not null and is a Map
            var accessControlMap = user['acess_control'];
            if (accessControlMap != null && accessControlMap is Map) {
              // Convert access_control Map to a list of bools
              List<bool> accessControlList = [];

              // Iterate through the values of the access control map
              for (var value in accessControlMap.values) {
                // Ensure that we only process boolean values
                accessControlList
                    .add(value is bool ? value : value.toString() == 'true');
              }

              // Set the access control list to a state variable if needed
              setState(() {
                accessControl =
                    accessControlList; // Assuming accessControl is defined as List<bool>
              });

              print('Access Control List: $accessControl');
            } else {
              print('Access control data is not available for user $uniqueId.');
            }
            return; // Exit once the user is found and processed
          }

          // Update apiUrl to the next page, or set to empty if no more pages
          apiUrl = data['next'] ?? '';
        } else {
          print('Failed to load user details: ${response.statusCode}');
          return;
        }
      }

      if (!userFound) {
        print('User with unique_id $uniqueId not found in any page.');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  bool generatepickingbuttonenable = false;
  Map<int, Map<String, dynamic>> groupedData = {}; // For grouping data

  // Future<void> fetchDataReqnO() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? saleslogiOrgwarehousename =
  //       prefs.getString('saleslogiOrgwarehousename') ?? '';

  //   final IpAddress = await getActiveIpAddress();

  //   final url = Uri.parse(
  //       '$IpAddress/filtered_dispatchrequest/${widget.reqno}/$saleslogiOrgwarehousename/');
  //   try {
  //     final response = await http.get(url);

  //     // Logging the request URL
  //     print("URL DATAS: $url");

  //     // Clear previous data
  //     createtableData = [];

  //     if (response.statusCode == 200) {
  //       // Decode the JSON response
  //       final List<dynamic> responseData = json.decode(response.body);

  //       // Ensure there's at least one record
  //       if (responseData.isNotEmpty) {
  //         final data = responseData[0]; // Use the first record

  //         // Update controllers with the fetched data
  //         setState(() {
  //           _DateController.text = data['INVOICE_DATE']?.toString() ?? '';

  //           _DeliveryateController.text =
  //               data['DELIVERY_DATE']?.toString() ?? '';
  //           _CusidController.text = data['CUSTOMER_NUMBER']?.toString() ?? '';
  //           _CussiteController.text =
  //               data['CUSTOMER_SITE_ID']?.toString() ?? '';
  //           _CustomerNameController.text = data['CUSTOMER_NAME'] ?? '';
  //           _RegionController.text = data['ORG_NAME'] ?? '';
  //           _WarehousenameNameController.text = data['TO_WAREHOUSE'] ?? '';
  //           print("Warehouse details: ${_WarehousenameNameController.text}");

  //           // Process table data
  //           if (data['TABLE_DETAILS'] != null) {
  //             bool allRowsFinished = true;

  //             for (var item in data['TABLE_DETAILS']) {
  //               // Ensure all numeric fields are parsed correctly
  //               var dispatchedQty = int.tryParse(
  //                       item['DISPATCHED_BY_MANAGER']?.toString() ?? '0') ??
  //                   0;
  //               var totalQty =
  //                   int.tryParse(item['TOT_QUANTITY']?.toString() ?? '0') ?? 0;

  //               // Determine status based on the dispatched quantity
  //               var status = dispatchedQty == 0 ? 'Finished' : 'Pending';

  //               // Add the item to the table data
  //               createtableData.add({
  //                 'id': item['LINE_NUMBER']?.toString() ?? '',
  //                 'invoiceno': item['INVOICE_NUMBER']?.toString() ?? '',
  //                 'itemcode': item['INVENTORY_ITEM_ID']?.toString() ?? '',
  //                 'itemdetails': item['ITEM_DESCRIPTION']?.toString() ?? '',
  //                 'invoiceqty': totalQty.toString(),
  //                 'itemqty': item['DISPATCHED_QTY']?.toString() ?? '0',
  //                 'balitemqty':
  //                     item['DISPATCHED_BY_MANAGER']?.toString() ?? '0',
  //                 'status': status,
  //               });

  //               // Check if all rows are finished
  //               if (status != 'Finished') {
  //                 allRowsFinished = false;
  //               }
  //             }

  //             // Enable or disable the generate picking button
  //             generatepickingbuttonenable = allRowsFinished;
  //           }

  //           // Group data by REQ_ID and calculate totals
  //           int reqno = data['REQ_ID'];
  //           if (!groupedData.containsKey(reqno)) {
  //             groupedData[reqno] = {
  //               'id': data['LINE_NUMBER']?.toString() ?? '',
  //               'invoiceno': data['INVOICE_NUMBER']?.toString() ?? '',
  //               'itemcode': data['INVENTORY_ITEM_ID']?.toString() ?? '',
  //               'itemdetails': data['ITEM_DESCRIPTION']?.toString() ?? '',
  //               'invoiceqty': data['TOT_QUANTITY']?.toString() ?? '',
  //               'itemqty': data['DISPATCHED_QTY']?.toString() ?? '',
  //               'status': data['status']?.toString() ?? '',
  //               'total': 0.0,
  //             };
  //           }

  //           // Update totals for the grouped data
  //           groupedData[reqno]!['total'] = 0.0;
  //           for (var item in createtableData) {
  //             groupedData[reqno]!['total'] +=
  //                 double.tryParse(item['invoiceqty'] ?? '0') ?? 0.0;
  //           }

  //           print("Grouped data: $groupedData");
  //         });
  //       } else {
  //         print("No data found for the request.");
  //       }
  //     } else {
  //       print(
  //           'Failed to load dispatch request details. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error occurred: $e');
  //   }
  // }

  Future<void> fetchDataReqnO() async {
    try {
      // Initialize SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final saleslogiOrgwarehousename =
          prefs.getString('saleslogiOrgwarehousename') ?? '';

      // Get IP address
      final ipAddress = await getActiveIpAddress();
      if (ipAddress!.isEmpty) {
        throw Exception('IP address is not available');
      }

      // Build URL
      final url = Uri.parse(
          '$ipAddress/filtered_dispatchrequest/${widget.reqno}/$saleslogiOrgwarehousename/');
      print("URL DATAS: $url");

      // Make HTTP request
      final response = await http.get(url).timeout(const Duration(seconds: 30));

      // Clear previous data
      createtableData = [];

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load data: Status code ${response.statusCode}');
      }

      // Parse response
      final responseData = json.decode(response.body) as List<dynamic>;
      if (responseData.isEmpty) {
        print("No data found for the request.");
        return;
      }

      // Process first record
      final data = responseData[0] as Map<String, dynamic>;
      await _updateControllersWithData(data);

      // Process table details
      if (data['TABLE_DETAILS'] != null) {
        await _processTableDetails(data);
      }

      // Group data by REQ_ID
      _groupDataByReqId(data);
    } catch (e) {
      print('Error in fetchDataReqnO: $e');
      // Consider showing an error message to the user
    }
  }

  Future<void> _updateControllersWithData(Map<String, dynamic> data) async {
    setState(() {
      _DateController.text = data['INVOICE_DATE']?.toString() ?? '';
      _DeliveryateController.text = data['DELIVERY_DATE']?.toString() ?? '';
      _CusidController.text = data['CUSTOMER_NUMBER']?.toString() ?? '';
      _CussiteController.text = data['CUSTOMER_SITE_ID']?.toString() ?? '';
      _CustomerNameController.text = data['CUSTOMER_NAME']?.toString() ?? '';
      _RegionController.text = data['ORG_NAME']?.toString() ?? '';
      _WarehousenameNameController.text =
          data['TO_WAREHOUSE']?.toString() ?? '';
      print("Warehouse details: ${_WarehousenameNameController.text}");
    });
  }

  Future<void> _processTableDetails(Map<String, dynamic> data) async {
    final tableDetails = data['TABLE_DETAILS'] as List<dynamic>;
    bool allRowsFinished = true;

    for (var item in tableDetails.cast<Map<String, dynamic>>()) {
      final dispatchedQty =
          int.tryParse(item['DISPATCHED_BY_MANAGER']?.toString() ?? '0') ?? 0;
      final totalQty =
          int.tryParse(item['TOT_QUANTITY']?.toString() ?? '0') ?? 0;
      final status = dispatchedQty == 0 ? 'Finished' : 'Pending';

      if (status != 'Finished') {
        allRowsFinished = false;
      }

      final additionalData = await fetchPickedAndTruckQty(
        customerNumber: data['CUSTOMER_NUMBER']?.toString() ?? '',
        customerSiteId: data['CUSTOMER_SITE_ID']?.toString() ?? '',
        inventoryItemId: item['INVENTORY_ITEM_ID']?.toString() ?? '',
      );

      createtableData.add({
        'id': item['LINE_NUMBER']?.toString() ?? '',
        'invoiceno': item['INVOICE_NUMBER']?.toString() ?? '',
        'itemcode': item['INVENTORY_ITEM_ID']?.toString() ?? '',
        'itemdetails': item['ITEM_DESCRIPTION']?.toString() ?? '',
        'invoiceqty': totalQty.toString(),
        'itemqty': item['DISPATCHED_QTY']?.toString() ?? '0',
        'balitemqty': item['DISPATCHED_BY_MANAGER']?.toString() ?? '0',
        'total_picked_qty': additionalData['total_picked_qty'].toString(),
        'total_truck_qty': additionalData['total_truck_qty'].toString(),
        'total_return_qty': additionalData['total_return_qty'].toString(),
        'status': status,
      });
    }

    setState(() {
      generatepickingbuttonenable = allRowsFinished;
    });
  }

  void _groupDataByReqId(Map<String, dynamic> data) {
    final reqno = data['REQ_ID'] as int;
    if (!groupedData.containsKey(reqno)) {
      groupedData[reqno] = {
        'id': data['LINE_NUMBER']?.toString() ?? '',
        'invoiceno': data['INVOICE_NUMBER']?.toString() ?? '',
        'itemcode': data['INVENTORY_ITEM_ID']?.toString() ?? '',
        'itemdetails': data['ITEM_DESCRIPTION']?.toString() ?? '',
        'invoiceqty': data['TOT_QUANTITY']?.toString() ?? '',
        'itemqty': data['DISPATCHED_QTY']?.toString() ?? '',
        'status': data['status']?.toString() ?? '',
        'total': 0.0,
      };
    }

    // Calculate total
    double total = 0.0;
    for (var item in createtableData) {
      total += double.tryParse(item['invoiceqty'] ?? '0') ?? 0.0;
    }
    groupedData[reqno]!['total'] = total;

    print("Grouped data: $groupedData");
  }

  Future<Map<String, dynamic>> fetchPickedAndTruckQty({
    required String customerNumber,
    required String customerSiteId,
    required String inventoryItemId,
  }) async {
    try {
      final ipAddress = await getActiveIpAddress();
      if (ipAddress!.isEmpty) {
        throw Exception('IP address is not available');
      }

      final url = Uri.parse(
          '$ipAddress/picked_and_truck_count_view/?req_id=${widget.reqno}'
          '&customer_number=$customerNumber'
          '&customer_site_id=$customerSiteId'
          '&inventory_item_id=$inventoryItemId');

      print("Checking Picked & Truck QTY URL: $url");
      final response = await http.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return {
          'total_picked_qty': data['total_picked_qty']?.toString() ?? '0',
          'total_truck_qty': data['total_truck_qty']?.toString() ?? '0',
          'total_return_qty': data['total_return_qty']?.toString() ?? '0',
        };
      } else {
        throw Exception('Failed with status code ${response.statusCode}');
      }
    } catch (e) {
      print("Error in fetchPickedAndTruckQty: $e");
      return {'total_picked_qty': '0', 'total_truck_qty': '0'};
    }
  }

// Function to update the total item quantity based on createtableData
  void _updateTotal() {
    double totalSendQuantity = 0.0;

    for (int i = 0; i < createtableData.length; i++) {
      // Parse the 'itemqty' from createtableData and calculate the total
      double enteredQty =
          double.tryParse(createtableData[i]['itemqty']?.toString() ?? '0') ??
              0.0;
      totalSendQuantity += enteredQty; // Add to the total send quantity
    }

    // Print or return the calculated total (for display, logging, etc.)
    print("Total send quantity: ${totalSendQuantity.toStringAsFixed(2)}");
  }

// Function to get the total send quantity from table data
  double gettotalsendqty(List<Map<String, dynamic>> createtableData) {
    double totalQuantity = 0.0;
    for (var data in createtableData) {
      // Calculate the total for 'itemqty' in createtableData
      double quantity =
          double.tryParse(data['itemqty']?.toString() ?? '0') ?? 0.0;
      totalQuantity += quantity;
    }
    return totalQuantity; // Return the total calculated quantity
  }

  String? salesloginrole = '';
  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      salesloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
            width: Responsive.isDesktop(context)
                ? screenWidth * 0.6
                : screenWidth * 0.9,
            height: 650,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("View Dispatch Request Details",
                            style: topheadingbold),
                        Tooltip(
                          message: 'Close',
                          child: IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        runSpacing: 5,
                        children: [
                          _buildTextFieldDesktop(
                              'Dis.Req No', "${widget.reqno}", true),
                          _buildTextFieldDesktop('Physical Warehouse',
                              _WarehousenameNameController.text, true),
                          _buildTextFieldDesktop(
                              'Region', _RegionController.text, true),
                          _buildTextFieldDesktop(
                              'Date', _DateController.text, true),
                          _buildTextFieldDesktop(
                              'Customer No', _CusidController.text, true),
                          _buildTextFieldDesktop('Customer Name',
                              _CustomerNameController.text, true),
                          _buildTextFieldDesktop(
                              'Customer Site', _CussiteController.text, true),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius:
                                                    3, // Adjust the size of the bullet
                                                backgroundColor: Color.fromARGB(
                                                    255,
                                                    23,
                                                    122,
                                                    5), // Bullet color
                                              ),
                                              SizedBox(
                                                  width:
                                                      8), // Space between bullet and text
                                              Text(
                                                'Total Dispatch Request Qty',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 23, 122, 5),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                  radius:
                                                      3, // Adjust the size of the bullet
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 200, 10, 10)),
                                              SizedBox(
                                                  width:
                                                      8), // Space between bullet and text
                                              Text(
                                                'Balance Dispatch Request Qty',
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
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Stack(
                              children: [
                                Container(
                                  height: 240,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: _viewbuildTable(),
                                ),

                                // Scroll Indicator Row at the Bottom
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Responsive.isDesktop(context)
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Padding(
                                    //   padding: EdgeInsets.only(
                                    //       top: 50,
                                    //       left: MediaQuery.of(context).size.width * 0.03),
                                    //   child: Row(
                                    //     mainAxisAlignment: MainAxisAlignment.start,
                                    //     children: [
                                    //       if (salesloginrole == 'supervisor' ||
                                    //           salesloginrole == 'manager')
                                    //         Container(
                                    //           width: 180,
                                    //           decoration: BoxDecoration(color: buttonColor),
                                    //           child: ElevatedButton(
                                    //             onPressed: () {
                                    //               Navigator.pop(context);
                                    //               widget.togglePage();
                                    //               // Navigator.pushReplacement(
                                    //               //   context,
                                    //               //   MaterialPageRoute(
                                    //               //     builder: (context) => MainSidebar(
                                    //               //         initialPageIndex:
                                    //               //             3), // Navigate to MainSidebar
                                    //               //   ),
                                    //               // );
                                    //             },
                                    //             style: ElevatedButton.styleFrom(
                                    //               shape: RoundedRectangleBorder(
                                    //                 borderRadius: BorderRadius.circular(8),
                                    //               ),
                                    //               backgroundColor: buttonColor,
                                    //               minimumSize: const Size(
                                    //                   45.0, 40.0), // Set width and height
                                    //             ),
                                    //             child: Padding(
                                    //               padding: const EdgeInsets.all(0),
                                    //               child: const Text(
                                    //                 'Generate Picking',
                                    //                 style: TextStyle(
                                    //                     color: Colors.white, fontSize: 17),
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ),
                                    //     ],
                                    //   ),
                                    // ),

                                    // Right Side - Total Send Qty Section
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.02),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10,
                                                right: Responsive.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.05
                                                    : 0),
                                            child: _buildTextFieldDesktop(
                                                "Total Order Req",
                                                _totalController.text,
                                                true),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Wrap(
                                  alignment: WrapAlignment.start,
                                  children: [
                                    // Right Side - Total Send Qty Section
                                    _buildTextFieldDesktop("Total Order Req",
                                        _totalController.text, true),
                                    // Padding(
                                    //   padding: EdgeInsets.only(
                                    //       top: 50,
                                    //       left: MediaQuery.of(context).size.width * 0.03),
                                    //   child: Row(
                                    //     mainAxisAlignment: MainAxisAlignment.start,
                                    //     children: [
                                    //       Container(
                                    //         width: 180,
                                    //         decoration: BoxDecoration(color: buttonColor),
                                    //         child: ElevatedButton(
                                    //           onPressed: () {
                                    //             Navigator.pushReplacement(
                                    //               context,
                                    //               MaterialPageRoute(
                                    //                 builder: (context) => MainSidebar(
                                    //                     enabledItems: accessControl,
                                    //                     initialPageIndex:
                                    //                         3), // Navigate to MainSidebar
                                    //               ),
                                    //             );
                                    //           },
                                    //           style: ElevatedButton.styleFrom(
                                    //             shape: RoundedRectangleBorder(
                                    //               borderRadius: BorderRadius.circular(8),
                                    //             ),
                                    //             backgroundColor: buttonColor,
                                    //             minimumSize: const Size(
                                    //                 45.0, 40.0), // Set width and height
                                    //           ),
                                    //           child: Padding(
                                    //             padding: const EdgeInsets.all(0),
                                    //             child: const Text(
                                    //               'Generate Picking',
                                    //               style: TextStyle(color: Colors.white),
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ]),
            )));
  }
}
