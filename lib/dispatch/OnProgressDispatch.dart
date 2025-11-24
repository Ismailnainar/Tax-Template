import 'dart:typed_data'; // for Uint8List
import 'dart:io'; // for File
import 'package:aljeflutterapp/components/constaints.dart';
import 'package:path_provider/path_provider.dart'; // for getApplicationDocumentsDirectory
import 'package:pdf/widgets.dart' as pw;
import 'dart:ui';
import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';

class OnProgressDispatch extends StatefulWidget {
  final Function togglePage;
  final Function EdittogglePage;

  const OnProgressDispatch(this.togglePage, this.EdittogglePage, {super.key});
  @override
  State<OnProgressDispatch> createState() => _OnProgressDispatchState();
}

class _OnProgressDispatchState extends State<OnProgressDispatch> {
  final TextEditingController SearchReqNoController = TextEditingController();
  final TextEditingController salesmanIdController = TextEditingController();

  List<Map<String, dynamic>> filteredData = [];
  bool _isLoadingData = true;

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSalesmanName();
    fetchDispatchData();

    postLogData("On Progress Dispatch", "Opened");
    filteredData = List.from(tableData); // Initialize with all data
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();

    postLogData("On Progress Dispatch", "Closed");
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

  List<Map<String, dynamic>> allData = [];

  // void _filterDataByDate() {
  //   final selectedFromDateStr = _FromdateController.text.trim();
  //   final selectedEndDateStr = _EnddateController.text.trim();

  //   // User input format: 02-Jun-2025
  //   DateFormat inputDateFormat = DateFormat('dd-MMM-yyyy');

  //   // Data date format from API/list: 02.06.2025
  //   DateFormat dataDateFormat = DateFormat('dd.MM.yyyy');

  //   if (selectedFromDateStr.isNotEmpty && selectedEndDateStr.isNotEmpty) {
  //     try {
  //       // Parse the input date strings correctly
  //       DateTime selectedFromDate = inputDateFormat.parse(selectedFromDateStr);
  //       DateTime selectedEndDate = inputDateFormat.parse(selectedEndDateStr);

  //       setState(() {
  //         filteredData = allData.where((entry) {
  //           try {
  //             DateTime entryDate = dataDateFormat.parse(entry['date']);
  //             return entryDate
  //                     .isAfter(selectedFromDate.subtract(Duration(days: 1))) &&
  //                 entryDate.isBefore(selectedEndDate.add(Duration(days: 1)));
  //           } catch (e) {
  //             print("Error parsing entry date: ${entry['date']} - $e");
  //             return false;
  //           }
  //         }).toList();

  //         print("Filtered Data: $filteredData");
  //       });
  //     } catch (e) {
  //       print("❌ Error parsing selected input dates: $e");
  //       setState(() {
  //         filteredData = List.from(allData); // fallback to show all data
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       filteredData = List.from(allData); // show all if empty
  //       print("ℹ️ No date range selected, showing all data.");
  //     });
  //   }
  // }

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
                                  Icons.shopping_cart_checkout,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'On Progress Dispatch View',
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
                                                  fontSize: 16,
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
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                              "Onprogress Dispatch", "Search");
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
                                  if (Responsive.isDesktop(context))
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
                                                        CrossAxisAlignment
                                                            .start,
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
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color
                                                                  .fromARGB(
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
                                                                  Color
                                                                      .fromARGB(
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
                                                                  Color
                                                                      .fromARGB(
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
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color
                                                                  .fromARGB(
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
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color
                                                                  .fromARGB(
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
                                                                  Color
                                                                      .fromARGB(
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
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color
                                                                  .fromARGB(
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
                                  if (Responsive.isDesktop(context))
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
                                                        CrossAxisAlignment
                                                            .start,
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
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color
                                                                  .fromARGB(
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
                                                                  Color
                                                                      .fromARGB(
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
                                                                  Color
                                                                      .fromARGB(
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
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color
                                                                  .fromARGB(
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
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color
                                                                  .fromARGB(
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
                                                                  Color
                                                                      .fromARGB(
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
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color
                                                                  .fromARGB(
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
                          SizedBox(
                            height: 20,
                          ),
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

  Map<String, Map<String, dynamic>> groupedData = {};

  Future<void> fetchDispatchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgid = prefs.getString('saleslogiOrgwarehousename') ?? '';
    String? salesloginno = prefs.getString('salesloginno') ?? '';
    String? salesloginrole = prefs.getString('salesloginrole') ?? '';
    final IpAddress = await getActiveIpAddress();
    String? nextPageUrl = '$IpAddress/Create_Dispatch/';

    // print(
    //     'Response body $nextPageUrl. $saleslogiOrgid $salesloginno  $salesloginrole');

    try {
      while (nextPageUrl != null && nextPageUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(nextPageUrl));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final results = data['results'] as List?;
          nextPageUrl = data['next'];

          if (results == null || results.isEmpty) {
            print('No results found on this page.');
            continue;
          }

          for (var item in results) {
            if (item['PHYSICAL_WAREHOUSE'] == saleslogiOrgid &&
                item['FLAG'] != "D" &&
                (salesloginrole == "WHR SuperUser"
                    ? true
                    : item['SALESMAN_NO'] == salesloginno)) {
              String reqno = item['REQ_ID'];
              String salesmanId = item['SALESMAN_NO'].toString().split('.')[0];

              if (!groupedData.containsKey(reqno)) {
                groupedData[reqno] = {
                  'id': item['id'],
                  'salesman': salesmanId,
                  'reqno': reqno,
                  'commercialNo': item['COMMERCIAL_NO'],
                  'commercialName': item['COMMERCIAL_NAME'],
                  'salesmanName': item['SALESMAN_NAME'],
                  'cusno': item['CUSTOMER_NUMBER'],
                  'cusname': item['CUSTOMER_NAME'],
                  'cussite': item['CUSTOMER_SITE_ID'],
                  'dis_qty_total':
                      double.parse(item['DISPATCHED_QTY'].toString()),
                  'dis_mangerQty_total':
                      double.parse(item['DISPATCHED_BY_MANAGER'].toString()),
                  'date': item['INVOICE_DATE'],
                  'balance_qty': double.parse(
                          item['DISPATCHED_QTY'].toString()) -
                      double.parse(item['DISPATCHED_BY_MANAGER'].toString()),
                };
              } else {
                groupedData[reqno]!['dis_qty_total'] +=
                    double.parse(item['DISPATCHED_QTY'].toString());
                groupedData[reqno]!['dis_mangerQty_total'] +=
                    double.parse(item['DISPATCHED_BY_MANAGER'].toString());
                groupedData[reqno]!['balance_qty'] =
                    groupedData[reqno]!['dis_qty_total'] -
                        groupedData[reqno]!['dis_mangerQty_total'];
              }
            }
          }
        } else {
          // print('Failed to load data from page: ${response.statusCode}');
          break;
        }
      }

      // Prepare data outside setState
      final List<Map<String, dynamic>> tempTableData =
          groupedData.values.map((item) {
        return {
          'id': item['id'],
          'salesman': item['salesman'],
          'salesmanName': item['salesmanName'],
          'commercialNo': item['commercialNo'],
          'commercialName': item['commercialName'],
          'reqno': item['reqno'],
          'cusno': item['cusno'],
          'cusname': item['cusname'],
          'cussite': item['cussite'],
          'dis_qty_total': item['dis_qty_total'].toString(),
          'dis_mangerQty_total': item['dis_mangerQty_total'].toString(),
          'balance_qty': item['balance_qty'].toString(),
          'date': DateFormat('dd.MM.yyyy').format(DateTime.parse(item['date'])),
        };
      }).toList();

      // Update UI state synchronously
      setState(() {
        tableData = tempTableData;
        filteredData = List.from(tableData);
      });

      // Await async functions AFTER setState
      await fetchPreviousLoadCount();
      await fetchPickedScanQty();
      await fetchreturnCode();

      // Print logs
      // print('Table Data:');
      for (var row in tableData) {
        // print(row);
      }

      // print('Filtered Data:');
      for (var row in filteredData) {
        // print(row);
      }

      _filter(); // Apply filters
    } catch (e) {
      // print('Errorrrrrrrrrrrrrrrrrrr fetching data: $e');
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  bool _isLoading = true;
  Future<void> fetchPreviousLoadCount() async {
    for (int i = 0; i < filteredData.length; i++) {
      String reqno = filteredData[i]['reqno'].toString();
      final IpAddress = await getActiveIpAddress();
      final truckScanUrl = '$IpAddress/Truck_scan/?REQ_ID=$reqno';

      int totalCount = 0;
      bool hasNextPage = true;
      String? nextPageUrl = truckScanUrl;

      setState(() {
        _isLoading = true;
      });

      try {
        while (hasNextPage && nextPageUrl != null) {
          final response = await http.get(Uri.parse(nextPageUrl));

          if (response.statusCode == 200) {
            final Map<String, dynamic> responseData =
                json.decode(response.body);

            // Count items in the current page's results
            if (responseData.containsKey('results')) {
              totalCount += (responseData['results'] as List).length;
            }

            // Move to the next page
            nextPageUrl = responseData['next'];
            hasNextPage = nextPageUrl != null;
          } else {
            throw Exception('Failed to fetch data from $nextPageUrl');
          }
        }

        // Set the correct count
        setState(() {
          filteredData[i]['previous_truck_qty'] = totalCount;
          // print('Updated previous_truck_qty for reqno $reqno: $totalCount');
        });
      } catch (e) {
        print('Error fetching data for reqno: $reqno: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
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
        // print('urlllllllllllllllll $url');
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
        print(
            'Error fetching data for reqno: $reqno, cusno: $cusno, cussite: $cussite: $e');
      } finally {
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
    Widget _tableHeader(String text, IconData icon, {double width = 100}) {
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
        {double width = 100, String? tooltipMessage}) {
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
                  style: TableRowTextStyle,
                  showCursor: false,
                  toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
                ),
              )
            : SelectableText(
                data,
                style: TableRowTextStyle,
                showCursor: false,
                toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
              ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.white,
                    height: Responsive.isDesktop(context)
                        ? screenHeight * 0.7
                        : 400,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Header Row
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 13),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _tableHeader("S.No", Icons.format_list_numbered,
                                    width: 70),
                                _tableHeader("Req No", Icons.print, width: 100),
                                if (saveloginrole == 'Supervisor' ||
                                    saveloginrole == 'WHR SuperUser')
                                  _tableHeader("Salesman No", Icons.print,
                                      width: 100),
                                _tableHeader("Supervisor", Icons.print,
                                    width: 100),
                                _tableHeader("Date", Icons.calendar_today,
                                    width: 100),
                                _tableHeader("Cust No", Icons.category,
                                    width: 90),
                                _tableHeader("Cus Name", Icons.person,
                                    width: 380),
                                _tableHeader("Site No", Icons.location_on,
                                    width: 80),
                                _tableHeader("Status", Icons.list, width: 180),
                                _tableHeader("Actions", Icons.call_to_action,
                                    width: 130),
                              ],
                            ),
                          ),

                          // Data Rows
                          if (_isLoadingData)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 100.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                            )
                          else if (filteredData.isNotEmpty)
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: filteredData
                                      .where((data) {
                                        var dis_qty_total = double.tryParse(
                                                data['dis_qty_total']
                                                    .toString()) ??
                                            0;
                                        var previous_truck_qty =
                                            double.tryParse(
                                                    data['previous_truck_qty']
                                                        .toString()) ??
                                                0;
                                        return dis_qty_total !=
                                            previous_truck_qty;
                                      })
                                      .toList()
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                        int index = entry.key;
                                        var data = entry.value;

                                        String sNo = (index + 1).toString();
                                        String salesman =
                                            data['salesman'].toString();
                                        String salesmanName =
                                            data['salesmanName'].toString();
                                        String commercialName =
                                            data['commercialName'].toString();
                                        String commercialNo =
                                            data['commercialNo'].toString();
                                        String tablereqno =
                                            data['reqno'].toString();
                                        String reqno = data['reqno'].toString();
                                        String date = data['date'].toString();
                                        String returnQty =
                                            data['return_qty'].toString();
                                        String previous_truck_qty =
                                            data['previous_truck_qty']
                                                .toString();
                                        String cusno = data['cusno'].toString();
                                        String cusname =
                                            data['cusname'].toString();
                                        String cussite =
                                            data['cussite'].toString();
                                        String dis_qty_total = int.parse(
                                                double.parse(
                                                        data['dis_qty_total']
                                                            .toString())
                                                    .toStringAsFixed(0))
                                            .toString();
                                        String balance_qty = int.parse(
                                                double.parse(data['balance_qty']
                                                        .toString())
                                                    .toStringAsFixed(0))
                                            .toString();
                                        String picked_qty =
                                            data['picked_qty'].toString();
                                        double pickedQtyDouble =
                                            double.tryParse(picked_qty) ?? 0.0;
                                        String finalpickqty = int.parse(
                                                double.parse(pickedQtyDouble
                                                        .toString())
                                                    .toStringAsFixed(0))
                                            .toString();

                                        bool isEvenRow =
                                            filteredData.indexOf(data) % 2 == 0;
                                        Color rowColor = isEvenRow
                                            ? Color.fromARGB(224, 255, 255, 255)
                                            : Color.fromARGB(
                                                224, 255, 255, 255);

                                        // Format date
                                        String formattedDate = "Invalid date";
                                        List<String> parts = date.split('.');
                                        if (parts.length == 3) {
                                          try {
                                            DateTime dateTime = DateTime(
                                              int.parse(parts[2]),
                                              int.parse(parts[1]),
                                              int.parse(parts[0]),
                                            );
                                            formattedDate =
                                                DateFormat('dd-MMM-yyyy')
                                                    .format(dateTime)
                                                    .toUpperCase();
                                          } catch (e) {
                                            print("Error parsing date: $e");
                                          }
                                        }

                                        return GestureDetector(
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _tableRow(sNo, rowColor,
                                                    width: 70),
                                                _tableRow(tablereqno, rowColor,
                                                    width: 100),
                                                if (saveloginrole ==
                                                        'Supervisor' ||
                                                    saveloginrole ==
                                                        'WHR SuperUser')
                                                  _tableRow(salesman, rowColor,
                                                      width: 100,
                                                      tooltipMessage:
                                                          salesmanName),
                                                _tableRow(
                                                    commercialNo, rowColor,
                                                    width: 100,
                                                    tooltipMessage:
                                                        commercialName),
                                                _tableRow(
                                                    formattedDate, rowColor,
                                                    width: 100),
                                                _tableRow(cusno, rowColor,
                                                    width: 80),
                                                _tableRow(cusname, rowColor,
                                                    width: 380),
                                                _tableRow(cussite, rowColor,
                                                    width: 90),

                                                // Status Column
                                                Container(
                                                  width: 180,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: rowColor,
                                                    border: Border.all(
                                                        color: Color.fromARGB(
                                                            255,
                                                            226,
                                                            225,
                                                            225)),
                                                  ),
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Tooltip(
                                                          message:
                                                              "Dispatch Request",
                                                          child: Text(
                                                              dis_qty_total,
                                                              style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        37,
                                                                        139,
                                                                        4),
                                                                fontSize: 14,
                                                              )),
                                                        ),
                                                        SizedBox(width: 3),
                                                        Text("-",
                                                            style:
                                                                TableRowTextStyle),
                                                        SizedBox(width: 3),
                                                        Tooltip(
                                                          message:
                                                              "Dispatch Assigned",
                                                          child: Text(
                                                              balance_qty,
                                                              style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        225,
                                                                        19,
                                                                        19),
                                                                fontSize: 14,
                                                              )),
                                                        ),
                                                        SizedBox(width: 3),
                                                        Text("-",
                                                            style:
                                                                TableRowTextStyle),
                                                        SizedBox(width: 3),
                                                        Tooltip(
                                                          message:
                                                              "Dispatch Picked",
                                                          child: Text(
                                                              finalpickqty,
                                                              style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        176,
                                                                        9,
                                                                        179),
                                                                fontSize: 14,
                                                              )),
                                                        ),
                                                        SizedBox(width: 3),
                                                        Text("-",
                                                            style:
                                                                TableRowTextStyle),
                                                        SizedBox(width: 3),
                                                        Tooltip(
                                                          message:
                                                              "Stage Completed",
                                                          child: Text(
                                                              previous_truck_qty,
                                                              style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        45,
                                                                        13,
                                                                        163),
                                                                fontSize: 14,
                                                              )),
                                                        ),
                                                        SizedBox(width: 3),
                                                        Text("-",
                                                            style:
                                                                TableRowTextStyle),
                                                        SizedBox(width: 3),
                                                        Tooltip(
                                                          message: "Return Qty",
                                                          child: Text(returnQty,
                                                              style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        184,
                                                                        128,
                                                                        7),
                                                                fontSize: 14,
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                // Actions Column
                                                Container(
                                                  height: 30,
                                                  width: 130,
                                                  decoration: BoxDecoration(
                                                    color: rowColor,
                                                    border: Border.all(
                                                        color: Color.fromARGB(
                                                            255,
                                                            226,
                                                            225,
                                                            225)),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                color:
                                                                    buttonColor),
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  false,
                                                              builder:
                                                                  (context) {
                                                                return Dialog(
                                                                  child:
                                                                      Container(
                                                                    color: Colors
                                                                            .grey[
                                                                        200],
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.8,
                                                                    child:
                                                                        viewdialogbox(
                                                                      reqno:
                                                                          '$reqno',
                                                                      togglePage:
                                                                          widget
                                                                              .togglePage,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                            savereqno(reqno);
                                                            postLogData(
                                                                "OnProgress Dispatch DetailsView Pop-up",
                                                                "Opened");
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            minimumSize:
                                                                const Size(
                                                                    45.0, 20.0),
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            shadowColor: Colors
                                                                .transparent,
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
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ),
                                                      if (balance_qty == "0" &&
                                                          finalpickqty == "0" &&
                                                          previous_truck_qty ==
                                                              "0" &&
                                                          saveloginrole ==
                                                              'Salesman')
                                                        Tooltip(
                                                          message: 'Edit',
                                                          child: IconButton(
                                                            onPressed: () {
                                                              widget
                                                                  .EdittogglePage(
                                                                      reqno,
                                                                      true);
                                                            },
                                                            icon: Icon(
                                                                Icons.edit,
                                                                size: 18),
                                                          ),
                                                        ),
                                                    ],
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
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text("No req found.."),
                            ),
                        ]),
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
                icon: Icon(Icons.arrow_left_outlined,
                    color: Colors.blueAccent, size: 30),
                onPressed: () {
                  _horizontalScrollController.animateTo(
                    _horizontalScrollController.offset - 100,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_right_outlined,
                    color: Colors.blueAccent, size: 30),
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
  final Function togglePage;

  viewdialogbox({
    super.key,
    required this.reqno,
    // required this.date,
    // required this.cussite,
    // required this.cusId,
    // required this.customerName,
    required this.togglePage,
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
    postLogData("Dispatch Request DetailsView Pop-up", "Closed");
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
                              // hintText: label,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              filled: true,
                              fillColor: readOnly
                                  ? Color.fromARGB(255, 240, 240, 240)
                                  : Color.fromARGB(255, 255, 255, 255),
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

  List<Map<String, dynamic>> createtableData = [];

  TextEditingController _totalController = TextEditingController();

  TextEditingController _DateController = TextEditingController();

  TextEditingController _DeliveryateController = TextEditingController();
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
      {'icon': Icons.check, 'label': 'Qty. Inv'},
      {'icon': Icons.list, 'label': 'Qty.Req'},
      {'icon': Icons.production_quantity_limits, 'label': 'Picked'},
      {'icon': Icons.fire_truck_rounded, 'label': 'Deliver'},
      {'icon': Icons.fire_truck_rounded, 'label': 'Return'},
      // {'icon': Icons.check_circle, 'label': 'Status'},
    ];

    // Define fixed widths for each column
    List<double> columnWidths = [100, 60, 120, 350, 80, 100, 80, 80, 80, 100];

    Widget _buildHeaderCell(Map<String, dynamic> header, double width) {
      return Container(
        height: containerHeight,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Row(
          children: [
            Icon(header['icon'], size: 15, color: Colors.blue),
            const SizedBox(width: 5),
            Text(
              header['label'],
              textAlign: TextAlign.start,
              style: commonLabelTextStyle,
            ),
          ],
        ),
      );
    }

    Widget _buildDataCell(String value, double width, String Message) {
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
                value,
                textAlign: TextAlign.start,
                style: TableRowTextStyle,
                showCursor: false,
                // overflow: TextOverflow.ellipsis,
                cursorColor: Colors.blue,
                cursorWidth: 2.0,
                toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
                onTap: () {
                  // Optional: Handle single tap if needed
                },
              ),
            ),

            // Text(
            //   value,
            //   textAlign: TextAlign.start,
            //   style: TableRowTextStyle,
            //   overflow: TextOverflow.ellipsis,
            // ),
          ),
        ),
      );
    }

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tableHeaders.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> header = entry.value;
                  return _buildHeaderCell(header, columnWidths[index]);
                }).toList(),
              ),
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
                            child: Center(child: CircularProgressIndicator()),
                          )
                        ]
                      : (sortedTableData.isNotEmpty
                          ? sortedTableData.map((data) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildDataCell(data['invoiceno']!.toString(),
                                      columnWidths[0], ''),
                                  _buildDataCell(data['id']!.toString(),
                                      columnWidths[1], ''),
                                  _buildDataCell(data['itemcode']!.toString(),
                                      columnWidths[2], ''),
                                  _buildDataCell(
                                      data['itemdetails']!.toString(),
                                      columnWidths[3],
                                      ''),
                                  _buildDataCell(data['invoiceqty']!.toString(),
                                      columnWidths[4], ''),
                                  Container(
                                    height: 50,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 226, 225, 225)),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Tooltip(
                                            message: 'Asigned Qty',
                                            child: Text(
                                              data['itemqty'].toString(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 0, 128, 34),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "-",
                                            textAlign: TextAlign.center,
                                            style: TableRowTextStyle,
                                          ),
                                          SizedBox(width: 10),
                                          Tooltip(
                                            message: 'Balance Asigned Qty',
                                            child: Text(
                                              data['balitemqty'].toString(),
                                              textAlign: TextAlign.center,
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
                                  ),
                                  _buildDataCell(
                                      data['total_picked_qty']!.toString(),
                                      columnWidths[6],
                                      'Picked Qty'),
                                  _buildDataCell(
                                      data['total_truck_qty']!.toString(),
                                      columnWidths[7],
                                      'Delivered Qty'),
                                  _buildDataCell(
                                      data['total_return_qty']!.toString(),
                                      columnWidths[8],
                                      'Returned Qty'),
                                  // _buildDataCell(data['status']!.toString(),
                                  //     columnWidths[9], ''),
                                ],
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
    );
  }

  bool generatepickingbuttonenable = false;
  @override
  void initState() {
    super.initState();
    fetchAccessControl();
    generatepickingbuttonenable = false;
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
          print("total amount of the dispatchqty : ${_CusidController.text}");
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
      // print("URL DATAS: $url");

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

      // print("Checking Picked & Truck QTY URL: $url");
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
    String date = _formatDate(_DateController.text);

    String deliverydate = _formatDate(_DeliveryateController.text);
    int index = 0; // Example index

    double dis_qty_total =
        double.parse(groupedData[index]?['dis_qty_total']?.toString() ?? '0');
    double balance_qty =
        double.parse(groupedData[index]?['balance_qty']?.toString() ?? '0');

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
                      if (!Responsive.isMobile(context))
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("View Dispatch Request Details",
                                style: topheadingbold),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Tooltip(
                                    message: 'Close',
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.cancel,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      if (Responsive.isMobile(context))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Tooltip(
                                      message: 'Close',
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.cancel,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Text("View Dispatch Request Details",
                                style: topheadingbold),
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
                            Container(
                              width: Responsive.isDesktop(context)
                                  ? screenWidth * 0.09
                                  : screenWidth,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 0),
                                    Row(
                                      children: [
                                        Text('Date', style: textboxheading),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0, bottom: 0),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 34,
                                            width: Responsive.isDesktop(context)
                                                ? screenWidth * 0.08
                                                : screenWidth * 0.5,
                                            child: MouseRegion(
                                              onEnter: (event) {
                                                // You can perform any action when mouse enters, like logging the value.
                                              },
                                              onExit: (event) {
                                                // Perform any action when the mouse leaves the TextField area.
                                              },
                                              cursor: SystemMouseCursors.click,
                                              child: TextField(
                                                  readOnly:
                                                      true, // Set readOnly state
                                                  decoration: InputDecoration(
                                                      // hintText: label,
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.zero,
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              vertical: 10.0,
                                                              horizontal: 10.0),
                                                      filled: true,
                                                      fillColor: Color.fromARGB(
                                                          255, 240, 240, 240)),
                                                  controller:
                                                      TextEditingController(
                                                          text: date),
                                                  style: textBoxstyle),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: Responsive.isDesktop(context)
                                  ? screenWidth * 0.09
                                  : screenWidth,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 0),
                                    Row(
                                      children: [
                                        Text('Delivery Date',
                                            style: textboxheading),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0, bottom: 0),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 34,
                                            width: Responsive.isDesktop(context)
                                                ? screenWidth * 0.08
                                                : screenWidth * 0.5,
                                            child: MouseRegion(
                                              onEnter: (event) {
                                                // You can perform any action when mouse enters, like logging the value.
                                              },
                                              onExit: (event) {
                                                // Perform any action when the mouse leaves the TextField area.
                                              },
                                              cursor: SystemMouseCursors.click,
                                              child: TextField(
                                                  readOnly:
                                                      true, // Set readOnly state
                                                  decoration: InputDecoration(
                                                      // hintText: label,
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.zero,
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              vertical: 10.0,
                                                              horizontal: 10.0),
                                                      filled: true,
                                                      fillColor: Color.fromARGB(
                                                          255, 240, 240, 240)),
                                                  controller:
                                                      TextEditingController(
                                                          text: deliverydate),
                                                  style: textBoxstyle),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // _buildTextFieldDesktop('Date', _DateController.text, true),
                            _buildTextFieldDesktop(
                                'Customer No', _CusidController.text, true),
                            _buildTextFieldDesktop('Customer Name',
                                _CustomerNameController.text, true),
                            _buildTextFieldDesktop(
                                'Customer Site', _CussiteController.text, true),
                            if (generatepickingbuttonenable == false)
                              if (salesloginrole == 'Supervisor' ||
                                  salesloginrole == 'WHR SuperUser')
                                Padding(
                                    padding: const EdgeInsets.only(top: 33.0),
                                    child:
                                        // Container(
                                        // child: (dis_qty_total == balance_qty)
                                        //     ? Container(
                                        //         width: 180,
                                        //         color: Colors.green,
                                        //         child: Text(
                                        //           'Pick Request Completed..!!!',
                                        //           style: TextStyle(
                                        //               fontSize: 17, color: Colors.white),
                                        //         ),
                                        //       )
                                        //   :
                                        Container(
                                      width: 180,
                                      decoration:
                                          BoxDecoration(color: buttonColor),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Action for the "Generate Picking" button
                                          print(
                                              'Generate Picking button clicked');
                                          Navigator.pop(context);
                                          widget.togglePage();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          backgroundColor: buttonColor,
                                          minimumSize: const Size(45.0, 40.0),
                                        ),
                                        child: const Text(
                                          'Generate Picking',
                                          style: commonWhiteStyle,
                                        ),
                                      ),
                                    )),
                            if (generatepickingbuttonenable == true)
                              if (salesloginrole == 'Supervisor' ||
                                  salesloginrole == 'WHR SuperUser')
                                Padding(
                                    padding: const EdgeInsets.only(top: 33.0),
                                    child:
                                        // Container(
                                        // child: (dis_qty_total == balance_qty)
                                        //     ? Container(
                                        //         width: 180,
                                        //         color: Colors.green,
                                        //         child: Text(
                                        //           'Pick Request Completed..!!!',
                                        //           style: TextStyle(
                                        //               fontSize: 17, color: Colors.white),
                                        //         ),
                                        //       )
                                        //   :
                                        Container(
                                      width: 200,
                                      decoration:
                                          BoxDecoration(color: Colors.green),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          // // Action for the "Generate Picking" button
                                          // print('Generate Picking button clicked');
                                          // Navigator.pop(context);
                                          // widget.togglePage();
                                          // showInvoiceDialog(
                                          //     context,
                                          //     false,
                                          //     tableData,
                                          //     _PicknoController,
                                          //     _ReqnoController,
                                          //     _WarehousenameNameController,
                                          //     _RegionController,
                                          //     _CustomerNumberController,
                                          //     _CustomerNameController,
                                          //     _CussiteController);
                                          // await fetchPickmanData(widget.reqno);
                                          // showDialog(
                                          //   context: context,
                                          //   barrierDismissible: false,
                                          //   builder: (BuildContext context) {
                                          //     return pending_pickmandetailsdialogbox(
                                          //         context, widget.reqno);
                                          //   },
                                          // );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          backgroundColor: Colors.green,
                                          minimumSize: const Size(45.0, 40.0),
                                        ),
                                        child: const Text(
                                          'Pick Req Completed',
                                          style: commonWhiteStyle,
                                        ),
                                      ),
                                    )),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                    child: ScrollbarTheme(
                                      data: ScrollbarThemeData(
                                        thumbColor: MaterialStateProperty.all(
                                            Colors.grey[600]),
                                        thumbVisibility:
                                            MaterialStateProperty.all(true),
                                        thickness: MaterialStateProperty.all(8),
                                        radius: const Radius.circular(10),
                                      ),
                                      child: Scrollbar(
                                        controller:
                                            _horizontalScrollController2,
                                        child: SingleChildScrollView(
                                          controller:
                                              _horizontalScrollController2,
                                          scrollDirection: Axis.horizontal,
                                          child: _viewbuildTable(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0, // Adjust position as needed
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                            _horizontalScrollController2
                                                .animateTo(
                                              _horizontalScrollController2
                                                      .offset -
                                                  100, // Adjust scroll amount
                                              duration:
                                                  Duration(milliseconds: 300),
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
                                            _horizontalScrollController2
                                                .animateTo(
                                              _horizontalScrollController2
                                                      .offset +
                                                  100, // Adjust scroll amount
                                              duration:
                                                  Duration(milliseconds: 300),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
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
                                                  left: Responsive.isDesktop(
                                                          context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.01
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
                    ]))));
  }

  Widget pending_pickmandetailsdialogbox(BuildContext context, String reqNo) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      child: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            width: Responsive.isDesktop(context) ? screenWidth * 0.6 : 600,
            height: Responsive.isDesktop(context) ? 560 : 500,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Staging Pop-Up",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.cancel))
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runSpacing: 5,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Container(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Viewtabledata(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tableHeader(String text, IconData icon) {
    return Flexible(
      child: Container(
        height: Responsive.isDesktop(context) ? 25 : 30,
        decoration: TableHeaderColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align to the start
          crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
          children: [
            Icon(icon, size: 15, color: Colors.blue),
            SizedBox(width: 2),
            Expanded(
              // Ensures the text adjusts properly
              child: Text(
                text,
                textAlign: TextAlign.left, // Align text to the start (left)
                style: commonLabelTextStyle,
                overflow: TextOverflow.ellipsis, // Prevent overflow
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableRow(String data, Color? rowColor, {String? tooltipMessage}) {
    return Flexible(
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: rowColor,
          border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align to the start
          crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
          children: [
            Expanded(
              // Ensures the text adjusts properly
              child: tooltipMessage != null
                  ? Tooltip(
                      message: tooltipMessage,
                      child: Text(
                        data,
                        textAlign: TextAlign.left, // Align text to the start
                        style: TableRowTextStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : Text(
                      data,
                      textAlign: TextAlign.left, // Align text to the start
                      style: TableRowTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  List<Map<String, dynamic>> viewtableData = [];

  Future<void> fetchPickmanData(String reqno) async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/filteredfinishedpickman/$reqno/Finished/';
    print("Fetching data from URL: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');

        // Decode the JSON response as a List
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          setState(() {
            // Safely cast the list to List<Map<String, dynamic>>
            viewtableData = List<Map<String, dynamic>>.from(data);
            _isLoading = false;

            // // Assigning the first item's data to controllers
            // customerNoController.text =
            //     viewtableData[0]['CUSTOMER_NUMBER']?.toString() ?? 'N/A';
            // customerNameController.text =
            //     viewtableData[0]['CUSTOMER_NAME']?.toString() ?? 'N/A';
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          throw Exception('No data found in the response');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception(
            'Failed to load data. Server responded with status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (e is http.ClientException) {
        print('Network error: $e');
      } else if (e is FormatException) {
        print('Invalid JSON format: $e');
      } else {
        print('Unknown error: $e');
      }

      print('Error fetching data: $e');
    }
  }

  Widget Viewtabledata() {
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
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width * 0.55,
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _verticalScrollController,
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    child: Column(
                      children: [
                        // Table Header
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 13),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _tableHeader("S.No", Icons.format_list_numbered),
                              _tableHeader("Pick Id", Icons.countertops),
                              _tableHeader("Item Description", Icons.print),
                              // _tableHeader(
                              //     "Qty.Dispatch", Icons.account_circle),
                              _tableHeader("Qty.Staged", Icons.person),
                              // _tableHeader("Qty.Bal", Icons.list),
                            ],
                          ),
                        ),
                        // Loading Indicator or Table Rows
                        if (_isLoading)
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (viewtableData.isNotEmpty)
                          ...viewtableData.asMap().entries.map((entry) {
                            int index = entry.key;
                            var data = entry.value;

                            String sNo = (index + 1).toString();

                            String getpickid = data['PICK_ID'].toString();
                            String pickid = 'PickId_$getpickid';
                            String pickmanname = data['ASS_PICKMAN'].toString();
                            String dispatchqty =
                                "${data['DISPATCHED_QTY'].toString()}";
                            String pickedqty = data['PICKED_QTY'].toString();

                            double dispatchQtyDouble =
                                double.tryParse(dispatchqty) ?? 0.0;
                            double pickedQtyDouble =
                                double.tryParse(pickedqty) ?? 0.0;

                            String item_descrption =
                                data['ITEM_DESCRIPTION'].toString();
// Perform the calculation
                            String finalpickqty = pickedQtyDouble.toString();
                            String finaldisreqty = dispatchQtyDouble.toString();
                            double balanceQtyDouble =
                                dispatchQtyDouble - pickedQtyDouble;

// If you want the balance as a string:
                            String balanceqty = balanceQtyDouble.toString();

                            bool isEvenRow = index % 2 == 0;
                            Color rowColor = isEvenRow
                                ? Color.fromARGB(224, 255, 255, 255)
                                : Color.fromARGB(224, 255, 255, 255);

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: GestureDetector(
                                onTap: () {
                                  // Show Dialog on Row Click
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _tableRow(sNo, rowColor),

                                    Expanded(
                                      child: Container(
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .start, // Aligns items to the start
                                          crossAxisAlignment: CrossAxisAlignment
                                              .center, // Center vertically
                                          children: [
                                            Expanded(
                                                child: Tooltip(
                                              message: pickmanname,
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Text(
                                                  pickid,
                                                  textAlign: TextAlign
                                                      .left, // Align text to the start
                                                  style: TableRowTextStyle,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            )),
                                          ],
                                        ),
                                      ),
                                    ),
                                    _tableRow(item_descrption, rowColor),
                                    _tableRow(finalpickqty, rowColor),
                                    // _tableRow(balanceqty, rowColor),
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

  void showInvoiceDialog(
      BuildContext context,
      bool buttonname,
      List<Map<String, dynamic>> tableData,
      TextEditingController pickNoController,
      TextEditingController reqNoController,
      TextEditingController warehouseNameController,
      TextEditingController regionController,
      TextEditingController customerNumberController,
      TextEditingController customerNameController,
      TextEditingController cussiteController) {
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

    String pickno = '${pickNoController.text}';
    String getCurrentTime() {
      final DateTime now = DateTime.now();
      final DateFormat timeFormat = DateFormat('h:mm:ss a'); // 12-hour format
      return timeFormat
          .format(now); // Formats the time as 3:57:10 PM or 3:57:10 AM
    }

    String getCurrentDate() {
      final DateTime now = DateTime.now();
      final DateFormat dateFormat = DateFormat('dd-MMM-yyyy');
      return dateFormat.format(now); // Formats the date as 19-NOV-2024
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
                Container(
                  width: 595,
                  height: 842,
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
                              'Pick Man Print',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[800],
                              ),
                            ),
//                             if (buttonname)
//                               Container(
//                                   height: 35,
//                                   decoration: BoxDecoration(color: buttonColor),
//                                   child: ElevatedButton(
//                                     onPressed: () async {
//                                       bool allFilled =
//                                           true; // Assume all fields are filled initially

// // Loop through the controllers to check if any field is empty
//                                       for (int i = 0;
//                                           i < _controllers.length;
//                                           i++) {
//                                         if (_controllers[i].text.isNotEmpty) {
//                                           allFilled =
//                                               false; // At least one field is filled, so we do not need to show the dialog
//                                           break; // Exit the loop as soon as we find a non-empty field
//                                         }
//                                       }

// // If all fields are empty, show the dialog
//                                       if (allFilled) {
//                                         showDialog(
//                                           context: context,
//                                           builder: (BuildContext context) {
//                                             return AlertDialog(
//                                               title: Row(
//                                                 children: [
//                                                   const Icon(
//                                                     Icons.warning,
//                                                     color: Colors.yellow,
//                                                   ),
//                                                   SizedBox(width: 2),
//                                                   Text('Warning'),
//                                                 ],
//                                               ),
//                                               content: const Text(
//                                                   "Kindly fill all the fields."),
//                                               actions: [
//                                                 TextButton(
//                                                   onPressed: () {
//                                                     Navigator.of(context)
//                                                         .pop(); // Close the dialog
//                                                   },
//                                                   child: const Text("OK"),
//                                                 ),
//                                               ],
//                                             );
//                                           },
//                                         );
//                                       } else if (_AssignedStaffController
//                                           .text.isNotEmpty) {
//                                         // Show confirmation dialog before proceeding
//                                         showDialog(
//                                           context: context,
//                                           builder: (BuildContext context) {
//                                             return AlertDialog(
//                                               title: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Row(
//                                                     children: [
//                                                       Icon(Icons.delete,
//                                                           size: 18),
//                                                       SizedBox(
//                                                         width: 4,
//                                                       ),
//                                                       Text('Confirm Assign',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                               fontSize: 17)),
//                                                     ],
//                                                   ),
//                                                 ],
//                                               ),
//                                               content: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 children: [
//                                                   Text(
//                                                     'Are you sure you want to Assigned the Dispatch Quantity?',
//                                                     style:
//                                                         TextStyle(fontSize: 15),
//                                                   ),
//                                                 ],
//                                               ),
//                                               actions: <Widget>[
//                                                 TextButton(
//                                                   onPressed: () {
//                                                     // Close the dialog if "No" is pressed
//                                                     Navigator.of(context).pop();
//                                                   },
//                                                   child: const Text('No'),
//                                                 ),
//                                                 TextButton(
//                                                   onPressed: () async {
//                                                     // Perform actions if "Yes" is pressed
//                                                     await postDispatchRequest();
//                                                     await fetchLastPickNo();
//                                                     setState(() {
//                                                       _ReqnoController.clear();
//                                                       _WarehousenameNameController
//                                                           .clear();
//                                                       _RegionController.clear();
//                                                       _CustomerNameController
//                                                           .clear();
//                                                       _CusidController.clear();
//                                                       _CussiteController
//                                                           .clear();
//                                                       tableData.clear();
//                                                       _AssignedStaffController
//                                                           .clear();
//                                                       SharedPrefs
//                                                           .clearreqnoAll();
//                                                     });
//                                                     // Close the dialog

//                                                     Navigator.of(context).pop();

//                                                     await Navigator
//                                                         .pushReplacement(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             MainSidebar(
//                                                                 enabledItems:
//                                                                     accessControl,
//                                                                 initialPageIndex:
//                                                                     2),
//                                                       ),
//                                                     );

//                                                     // Navigator.pushReplacement(
//                                                     //   context,
//                                                     //   MaterialPageRoute(
//                                                     //     builder: (context) =>
//                                                     //         MainSidebar(
//                                                     //             enabledItems:
//                                                     //                 accessControl,
//                                                     //             initialPageIndex:
//                                                     //                 2), // Navigate to MainSidebar
//                                                     //   ),
//                                                     // );
//                                                     // fetchAccessControl();
//                                                   },
//                                                   child: const Text('Yes'),
//                                                 ),
//                                               ],
//                                             );
//                                           },
//                                         );
//                                       } else if (!allFilled) {
//                                         checkpickQty();
//                                       } else {
//                                         checkpickman();
//                                       }
//                                     },
//                                     style: ElevatedButton.styleFrom(
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       minimumSize: const Size(
//                                           45.0, 31.0), // Set width and height
//                                       backgroundColor: Colors
//                                           .transparent, // Make background transparent to show gradient
//                                       shadowColor: Colors
//                                           .transparent, // Disable shadow to preserve gradient
//                                     ),
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(
//                                           top: 5, bottom: 5, left: 8, right: 8),
//                                       child: const Text(
//                                         'Assign',
//                                         style: TextStyle(
//                                             fontSize: 16, color: Colors.white),
//                                       ),
//                                     ),
//                                   )),
                          ],
                        ),
                        SizedBox(height: 5),
                        // Header with Company Information
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset('assets/images/logo.jpg', height: 50),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Text(
                                //   'aljeflutterapp',
                                //   style: TextStyle(
                                //     fontSize: 18,
                                //     fontWeight: FontWeight.bold,
                                //     color: Colors.blueGrey[800],
                                //   ),
                                // ),
                                Text('123 Restaurant St, City Name',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                Text('Phone: +91 12345 67890',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                Text('Website: www.aljeflutterapp.com',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
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
                              'Pick ID: ${pickno}',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[600]),
                            ),
                            // Text(
                            //   'Date: 20-Nov-2024',
                            //   style: TextStyle(
                            //       fontSize: 13, color: Colors.blueGrey[600]),
                            // ),
                          ],
                        ),
                        SizedBox(height: 5),

                        // Customer Information Section
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.5), width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: EdgeInsets.only(
                              left: 12, right: 12, top: 10, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                'Dis. Req ID: ',
                                reqNoController.text,
                                'Customer No: ',
                                customerNumberController.text,
                              ),
                              _buildDetailRow(
                                'Physical Warehouse: ',
                                warehouseNameController.text,
                                'Customer Name: ',
                                customerNameController.text,
                              ),
                              _buildDetailRow(
                                'Region: ',
                                regionController.text,
                                'Customer Site:',
                                cussiteController.text,
                              ),
                              _buildDetailRow(
                                'Pick Man: ',
                                cussiteController.text,
                                // _AssignedStaffController.text,
                                '',
                                '',
                              ),
                              _buildDetailRow(
                                'Date : ',
                                getCurrentDate() + ' ' + getCurrentTime(),
                                '',
                                '',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),

                        Text(
                          'Picked Items:',
                          style: TextStyle(
                              fontSize: 14,
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
                        // Text(
                        //   'Thank you for your business!',
                        //   style: TextStyle(
                        //       fontSize: 13,
                        //       fontStyle: FontStyle.italic,
                        //       color: Colors.blueGrey[700]),
                        // ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Authorized Signature: __________',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            Text('Pickman Signature: __________',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        Divider(thickness: 1),
                        // SizedBox(height: 8),
                        // Text(
                        //   'Contact us: support@aljeflutterapp.com',
                        //   style: TextStyle(fontSize: 12, color: Colors.grey),
                        // ),
                        // SizedBox(height: 8),
                        // Text(
                        //   'Follow us on social media for updates!',
                        //   style: TextStyle(fontSize: 12, color: Colors.grey),
                        // ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    width: 595,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Container(
                        //     height: 35,
                        //     decoration: BoxDecoration(color: buttonColor),
                        //     child: ElevatedButton(
                        //       onPressed: () async {
                        //         // await _savePdf();
                        //         _captureAndSavePdf();
                        //       },
                        //       style: ElevatedButton.styleFrom(
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(8),
                        //         ),
                        //         minimumSize: const Size(45.0, 31.0),
                        //         backgroundColor: Colors.transparent,
                        //         shadowColor: Colors.transparent,
                        //       ),
                        //       child: Padding(
                        //         padding: const EdgeInsets.only(
                        //             top: 5, bottom: 5, left: 8, right: 8),
                        //         child: const Text(
                        //           'Print',
                        //           style: TextStyle(
                        //               fontSize: 16, color: Colors.white),
                        //         ),
                        //       ),
                        //     )),
                        // SizedBox(
                        //   width: 20,
                        // ),
                        // Container(
                        //     height: 35,
                        //     decoration: BoxDecoration(color: buttonColor),
                        //     child: ElevatedButton(
                        //       onPressed: () async {
                        //         // await _savePdf();
                        //         _captureAndSavePdf();
                        //       },
                        //       style: ElevatedButton.styleFrom(
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(8),
                        //         ),
                        //         minimumSize: const Size(45.0, 31.0),
                        //         backgroundColor: Colors.transparent,
                        //         shadowColor: Colors.transparent,
                        //       ),
                        //       child: Padding(
                        //         padding: const EdgeInsets.only(
                        //             top: 5, bottom: 5, left: 8, right: 8),
                        //         child: const Text(
                        //           'Generate Pdf',
                        //           style: TextStyle(
                        //               fontSize: 16, color: Colors.white),
                        //         ),
                        //       ),
                        //     )),
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
}

class PrintPreviewTable extends StatelessWidget {
  final List<Map<String, dynamic>> tableData;

  PrintPreviewTable({required this.tableData});

  @override
  Widget build(BuildContext context) {
    // Filter the tableData to exclude rows with empty or zero 'sendqty'
    final filteredData = tableData.where((data) {
      final sendQty = data['sendqty'];
      return sendQty != null &&
          sendQty.toString().isNotEmpty &&
          double.tryParse(sendQty.toString()) != 0;
    }).toList();

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
                _buildTableHeader("In.LN", 50),
                _buildTableHeader("Inv.No", 100),
                _buildTableHeader("I.Code", 100),
                _buildTableHeader(
                    "I.Details", MediaQuery.of(context).size.width * 0.15),
                _buildTableHeader("Qty", 100),
              ],
            ),
          ),
          // Scrollable Table Body
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical, // Enable vertical scrolling
              child: Column(
                children: filteredData.map((data) {
                  String lineno = data['id'].toString();
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
                            MediaQuery.of(context).size.width * 0.15),
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
          style: TextStyle(fontWeight: FontWeight.bold),
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
          overflow: TextOverflow.ellipsis, // Prevent overflow
        ),
      ),
    );
  }
}
