import 'dart:async';
import 'dart:convert';

import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/components/constaints.dart';
import 'package:http/http.dart' as http;
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PickedView extends StatefulWidget {
  final Function togglePage;

  PickedView(this.togglePage);

  @override
  State<PickedView> createState() => _PickedViewState();
}

class _PickedViewState extends State<PickedView> {
  final TextEditingController salesmanIdController = TextEditingController();

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadSalesmanName();
    FetchAssignedDatas();

    postLogData("Completed Scan", "Opened");
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();

    postLogData("Completed Scan", "Closed");
    super.dispose();
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

  int currentPagecount = 0;
  final int itemsPerPage = 20;

// This method will get the data for the current page
  List<Map<String, dynamic>> get paginatedData {
    int startIndex = currentPagecount * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;

    // Ensure we don't exceed the available data length
    if (startIndex >= filteredData.length) {
      return []; // No data for the current page
    }

    return filteredData.sublist(
      startIndex,
      endIndex > filteredData.length ? filteredData.length : endIndex,
    );
  }

// Navigate to the next page
  void _nextPage() {
    if ((currentPagecount + 1) * itemsPerPage < filteredData.length) {
      setState(() {
        currentPagecount++;
      });
    }
  }

// Navigate to the previous page
  void _previousPage() {
    if (currentPagecount > 0) {
      setState(() {
        currentPagecount--;
      });
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
                                Image.asset(
                                  'assets/images/barcode.png',
                                  height: 25,
                                  width: 25,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Completed Scan View',
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
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // SizedBox(
                                //   width: 10,
                                // ),
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                    child: Container(
                      height: screenheight * 0.80,
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
                            if (Responsive.isDesktop(context))
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              alignment: WrapAlignment.start,
                                              // mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 10,
                                                      right: Responsive
                                                              .isMobile(context)
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.5
                                                          : 0),
                                                  child: SizedBox(
                                                    width: 180,
                                                    height: 33,
                                                    child: TextField(
                                                      controller:
                                                          searchpickidController,
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText:
                                                            'Enter Pickid',
                                                        border:
                                                            OutlineInputBorder(),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10),
                                                      ),
                                                      onChanged: (value) =>
                                                          searchreqno(),
                                                      style: textBoxstyle,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 30),
                                                GestureDetector(
                                                  onTap: () => _selectfromDate(
                                                      context), // Open the date picker when tapped
                                                  child: Container(
                                                    height: 32,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 0,
                                                            horizontal: 20),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: Color.fromARGB(
                                                          255, 195, 228, 255),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .calendar_today,
                                                            color: Colors.blue,
                                                            size: 14),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          _FromdateController
                                                                  .text.isEmpty
                                                              ? DateFormat(
                                                                      'dd-MMM-yyyy')
                                                                  .format(
                                                                      DateTime
                                                                          .now())
                                                              : _FromdateController
                                                                  .text, // Display the selected date
                                                          style: TextStyle(
                                                              fontSize: 13),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 16),
                                                GestureDetector(
                                                  onTap: () => _selectendDate(
                                                      context), // Open the date picker when tapped
                                                  child: Container(
                                                    height: 32,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 0,
                                                            horizontal: 20),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: Color.fromARGB(
                                                          255, 195, 228, 255),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .calendar_today,
                                                            color: Colors.blue,
                                                            size: 14),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          _EnddateController
                                                                  .text.isEmpty
                                                              ? DateFormat(
                                                                      'dd-MMM-yyyy')
                                                                  .format(
                                                                      DateTime
                                                                          .now())
                                                              : _EnddateController
                                                                  .text, // Display the selected date
                                                          style: TextStyle(
                                                              fontSize: 13),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 16),
                                                Container(
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                      color: buttonColor),
                                                  child: ElevatedButton(
                                                      onPressed: () async {
                                                        // if (_FromdateController
                                                        //         .text.isEmpty ||
                                                        //     _EnddateController
                                                        //         .text.isEmpty) {
                                                        //   Checkstatus();
                                                        // } else {
                                                        //   await FetchAssignedDatas();
                                                        //   await _filterDataByDate();
                                                        // }
                                                        if (_FromdateController
                                                                .text.isEmpty ||
                                                            _EnddateController
                                                                .text.isEmpty) {
                                                          Checkstatus();
                                                        } else {
                                                          DateTime? fromDate =
                                                              DateFormat(
                                                                      'dd-MMM-yyyy')
                                                                  .parse(
                                                                      _FromdateController
                                                                          .text);
                                                          DateTime? endDate = DateFormat(
                                                                  'dd-MMM-yyyy')
                                                              .parse(
                                                                  _EnddateController
                                                                      .text);

                                                          if (endDate.isBefore(
                                                              fromDate)) {
                                                            await showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      "Invalid Date"),
                                                                  content: Text(
                                                                      "Kindly check the from date and end date"),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          _EnddateController.text =
                                                                              DateFormat('dd-MMM-yyyy').format(DateTime.now());
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        });
                                                                      },
                                                                      child: Text(
                                                                          "OK"),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          } else {
                                                            await FetchAssignedDatas();
                                                            _filterDataByDate();
                                                          }
                                                        }

                                                        postLogData(
                                                            "Picked View",
                                                            "Search");
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
                                                      child: Text('Search',
                                                          style:
                                                              commonWhiteStyle)),
                                                ),
                                                SizedBox(width: 16),
                                                Container(
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                      color: buttonColor),
                                                  child: ElevatedButton(
                                                      onPressed: () async {
                                                        await FetchAssignedDatas();
                                                        _FromdateController
                                                            .clear();
                                                        _EnddateController
                                                            .clear();
                                                        setState(() {
                                                          searchpickidController
                                                              .clear();
                                                        });

                                                        postLogData(
                                                            "Picked View",
                                                            "Clear");
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
                                                      child: Text(
                                                        'Clear',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: Responsive.isDesktop(context)
                                            ? 620
                                            : 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
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
                                                    'Scanned Qty (Picked Qty)',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                          Color.fromARGB(255,
                                                              200, 10, 10)),
                                                  SizedBox(
                                                      width:
                                                          8), // Space between bullet and text

                                                  Text(
                                                    ' Pending Scan Qty',
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
                                ),
                              ),
                            if (!Responsive.isDesktop(context))
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: screenWidth,
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    runSpacing: 3,
                                    // mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            bottom: 10,
                                            right: Responsive.isMobile(context)
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5
                                                : 0),
                                        child: SizedBox(
                                          width: screenWidth * 0.4,
                                          height: 33,
                                          child: TextField(
                                            controller: searchpickidController,
                                            decoration: const InputDecoration(
                                              hintText: 'Enter Pickid',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 10),
                                            ),
                                            onChanged: (value) => searchreqno(),
                                            style: textBoxstyle,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 30),
                                      GestureDetector(
                                        onTap: () => _selectfromDate(
                                            context), // Open the date picker when tapped
                                        child: Container(
                                          height: 32,
                                          width: screenWidth * 0.4,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 20),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Color.fromARGB(
                                                255, 195, 228, 255),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(Icons.calendar_today,
                                                  color: Colors.blue, size: 14),
                                              SizedBox(width: 10),
                                              Text(
                                                _FromdateController.text.isEmpty
                                                    ? DateFormat('dd-MMM-yyyy')
                                                        .format(DateTime.now())
                                                    : _FromdateController
                                                        .text, // Display the selected date
                                                style: TextStyle(fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      GestureDetector(
                                        onTap: () => _selectendDate(
                                            context), // Open the date picker when tapped
                                        child: Container(
                                          height: 32,
                                          width: screenWidth * 0.4,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 20),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Color.fromARGB(
                                                255, 195, 228, 255),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(Icons.calendar_today,
                                                  color: Colors.blue, size: 14),
                                              SizedBox(width: 10),
                                              Text(
                                                _EnddateController.text.isEmpty
                                                    ? DateFormat('dd-MMM-yyyy')
                                                        .format(DateTime.now())
                                                    : _EnddateController
                                                        .text, // Display the selected date
                                                style: TextStyle(fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10),
                                        child: Container(
                                          height: 32,
                                          decoration:
                                              BoxDecoration(color: buttonColor),
                                          child: ElevatedButton(
                                              onPressed: () async {
                                                // if (_FromdateController
                                                //         .text.isEmpty ||
                                                //     _EnddateController
                                                //         .text.isEmpty) {
                                                //   Checkstatus();
                                                // } else {
                                                //   await FetchAssignedDatas();
                                                //   await _filterDataByDate();
                                                // }
                                                if (_FromdateController
                                                        .text.isEmpty ||
                                                    _EnddateController
                                                        .text.isEmpty) {
                                                  Checkstatus();
                                                } else {
                                                  DateTime? fromDate =
                                                      DateFormat('dd-MMM-yyyy')
                                                          .parse(
                                                              _FromdateController
                                                                  .text);
                                                  DateTime? endDate =
                                                      DateFormat('dd-MMM-yyyy')
                                                          .parse(
                                                              _EnddateController
                                                                  .text);

                                                  if (endDate
                                                      .isBefore(fromDate)) {
                                                    await showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              "Invalid Date"),
                                                          content: Text(
                                                              "Kindly check the from date and end date"),
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
                                                    await FetchAssignedDatas();
                                                    _filterDataByDate();
                                                  }
                                                }

                                                postLogData(
                                                    "Picked View", "Search");
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                minimumSize:
                                                    const Size(45.0, 20.0),
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor: Colors.transparent,
                                              ),
                                              child: Text('Search',
                                                  style: commonWhiteStyle)),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10),
                                        child: Container(
                                          height: 32,
                                          decoration:
                                              BoxDecoration(color: buttonColor),
                                          child: ElevatedButton(
                                              onPressed: () async {
                                                await FetchAssignedDatas();
                                                _FromdateController.clear();
                                                _EnddateController.clear();
                                                setState(() {
                                                  searchpickidController
                                                      .clear();
                                                });

                                                postLogData(
                                                    "Picked View", "Clear");
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                minimumSize:
                                                    const Size(45.0, 20.0),
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor: Colors.transparent,
                                              ),
                                              child: Text(
                                                'Clear',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                children: [
                                  Container(child: buildTable()),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     InkWell(
                //       onTap: () {
                //         _previousPage();
                //       },
                //       child: Container(
                //         padding: EdgeInsets.all(4),
                //         decoration: BoxDecoration(
                //           color: Colors.blue,
                //           shape: BoxShape.circle,
                //           boxShadow: [
                //             BoxShadow(
                //               color: Colors.black26,
                //               blurRadius: 4,
                //               offset: Offset(2, 2),
                //             ),
                //           ],
                //         ),
                //         child: Icon(
                //           Icons.arrow_back,
                //           color: Colors.white,
                //           size: 15,
                //         ),
                //       ),
                //     ),
                //     SizedBox(width: 10),
                //     InkWell(
                //       onTap: () {
                //         _nextPage();
                //       },
                //       child: Container(
                //         padding: EdgeInsets.all(4),
                //         decoration: BoxDecoration(
                //           color: Colors.blue,
                //           shape: BoxShape.circle,
                //           boxShadow: [
                //             BoxShadow(
                //               color: Colors.black26,
                //               blurRadius: 4,
                //               offset: Offset(2, 2),
                //             ),
                //           ],
                //         ),
                //         child: Icon(
                //           Icons.arrow_forward,
                //           color: Colors.white,
                //           size: 15,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                const SizedBox(height: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> OrginaltableData = [];
  List<Map<String, dynamic>> filteredData = [];
  double totalQty = 0.0;
  double totalPickedQty = 0.0;
  double totalScannedQty = 0.0;
  double totalBalanceQty = 0.0;

  // Future<void> FetchAssignedDatas() async {
  //   int currentPage = 1;
  //   bool isLastPage = false;
  //   Map<String, Map<String, dynamic>> uniqueData = {};
  //   DateFormat dateFormat = DateFormat('dd-MMM-yyyy');

  //   try {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     final IpAddress = await getActiveIpAddress();

  //     // Fetching paginated data
  //     while (!isLastPage) {
  //       final url = Uri.parse('$IpAddress/Dispatch_request/?page=$currentPage');
  //       final response = await http.get(url);

  //       if (response.statusCode == 200) {
  //         final data = jsonDecode(response.body);
  //         final results = data['results'] as List?;
  //         final nextPageUrl = data['next'];

  //         // If no results, exit the loop
  //         if (results == null || results.isEmpty) {
  //           print('No results found');
  //           break;
  //         }

  //         // Processing each item in the result
  //         for (var item in results) {
  //           String pickname = item['ASSIGN_PICKMAN'].toString();
  //           String pickId = item['PICK_ID'].toString();

  //           String reqid = item['REQ_ID'].toString();
  //           String formattedDate =
  //               dateFormat.format(DateTime.parse(item['DATE']));
  //           String status = item['STATUS'].toString();

  //           double invoiceQty =
  //               double.tryParse(item['TOT_QUANTITY'].toString()) ?? 0.0;
  //           double pickedQty =
  //               double.tryParse(item['PICKED_QTY'].toString()) ?? 0.0;
  //           double scanned_qty =
  //               double.tryParse(item['SCANNED_QTY'].toString()) ?? 0.0;
  //           String flag = item['FLAG'].toString();

  //           double balance_qty = pickedQty - scanned_qty;

  //           // Add to totals
  //           totalQty += invoiceQty;
  //           totalPickedQty += pickedQty;
  //           totalScannedQty += scanned_qty;
  //           totalBalanceQty = totalPickedQty - totalScannedQty;
  //           String uniqueKey = '$pickId-$reqid';
  //           // Check if the pickId already exists in uniqueData
  //           if (uniqueData.containsKey(uniqueKey)) {
  //             // Update quantities for the existing entry
  //             uniqueData[uniqueKey]!['des_id'] += invoiceQty;
  //             uniqueData[uniqueKey]!['total'] += pickedQty;
  //             uniqueData[uniqueKey]!['scanned_qty'] += scanned_qty;
  //             uniqueData[uniqueKey]!['balance_qty'] += balance_qty;

  //             // Update the overall status based on the current item's status
  //             if (status == 'pending') {
  //               uniqueData[uniqueKey]!['status'] = 'pending';
  //             } else if (uniqueData[uniqueKey]!['status'] != 'pending' &&
  //                 status == 'Finished') {
  //               uniqueData[uniqueKey]!['status'] = 'Finished';
  //             }
  //           } else {
  //             // Create a new entry for the unique pick_id
  //             uniqueData[uniqueKey] = {
  //               'id': item['id'],
  //               'pickMan_Name': pickname,
  //               'pick_id': pickId,
  //               'reqid': reqid,
  //               'date': formattedDate,
  //               'des_id': invoiceQty,
  //               'total': pickedQty,
  //               'balance_qty': balance_qty,
  //               'scanned_qty': scanned_qty,
  //               'flag': flag,
  //               'status': status,
  //             };
  //           }
  //         }

  //         // Move to the next page if it exists
  //         if (nextPageUrl != null) {
  //           currentPage++;
  //         } else {
  //           isLastPage = true;
  //         }
  //       } else {
  //         print('Failed to load data: ${response.statusCode}');
  //         break;
  //       }
  //     }

  //     // Filter data to only include rows with balance_qty == 0
  //     final filteredResults = uniqueData.values
  //         .where(
  //             (entry) => entry['balance_qty'] == 0.0 && entry['flag'] != 'OU')
  //         .toList();

  //     setState(() {
  //       tableData = filteredResults;
  //       OrginaltableData = filteredResults;
  //       filteredData = List.from(tableData);
  //       _isLoading = false;
  //     });

  //     // print('Filtered Data: $filteredData');
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> FetchAssignedDatas() async {
    try {
      setState(() {
        _isLoading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';

      final IpAddress = await getActiveIpAddress();

      // ✅ Direct API call with pickman + status
      final url = Uri.parse(
          '$IpAddress/Get-Pickman_dispatch-request/?pickman=$saveloginname&status=pickmancomplete');

      print("URL: $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final results = (data['data'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        if (results == null || results.isEmpty) {
          print('No results found');
          setState(() {
            tableData = [];
            OrginaltableData = [];
            filteredData = [];
            _isLoading = false;
          });
          return;
        }

        // ✅ No need for grouping/aggregation here, backend already did it
        setState(() {
          tableData = results;
          OrginaltableData = results;
          filteredData = List.from(tableData);
          _isLoading = false;
        });

        print("Fetched ${results.length} records");
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  TextEditingController searchpickidController = TextEditingController();

  void searchreqno() {
    String searchText = searchpickidController.text.trim().toLowerCase();
    print("searchpickidControlleraaaaaaaa ${searchpickidController.text}");
    setState(() {
      tableData = OrginaltableData.where((item) {
        String reqno = item['pick_id']?.toString().toLowerCase() ?? '';

        // Check if the search text is contained anywhere in the reqno string
        return searchText.isEmpty || reqno.contains(searchText);
      }).toList();
      filteredData = tableData;
    });
  }

  _filterDataByDate() {
    final selectedFromDateStr = _FromdateController.text.trim();
    final selectedEndDateStr = _EnddateController.text.trim();

    if (selectedFromDateStr.isNotEmpty && selectedEndDateStr.isNotEmpty) {
      // Use the consistent date format "dd-MMM-yyyy"
      DateFormat dateFormat = DateFormat('dd-MMM-yyyy');

      try {
        // Parse the selected dates from the text controllers
        DateTime selectedFromDate = dateFormat.parse(selectedFromDateStr);
        DateTime selectedEndDate = dateFormat.parse(selectedEndDateStr);

        // Debugging: Print the parsed dates
        // print("Parsed From Date: $selectedFromDate");
        // print("Parsed To Date: $selectedEndDate");

        setState(() {
          // Filter the data based on the date range
          filteredData = filteredData.where((entry) {
            // Parse the entry's date field
            try {
              DateTime entryDate = dateFormat.parse(entry['date']);
              // print("Checking entry date: $entryDate");

              // Check if the entry date is within the range (inclusive)
              return entryDate
                      .isAfter(selectedFromDate.subtract(Duration(days: 1))) &&
                  entryDate.isBefore(selectedEndDate.add(Duration(days: 1)));
            } catch (e) {
              print("Error parsing entry date: ${entry['date']} - $e");
              return false; // Exclude invalid date entries
            }
          }).toList();

          // Debugging: Print the filtered data
          // print("Filtered Data: $filteredData");
        });
      } catch (e) {
        // Handle parsing errors
        print("Error parsing selected dates: $e");
        setState(() {
          filteredData = List.from(filteredData); // Reset to all data on error
        });
      }
    } else {
      setState(() {
        // Show all data if no valid date range is selected
        filteredData = List.from(filteredData);
        print("No date range selected, showing all data.");
      });
    }
  }

  Future<void> savepickno(String Pickman_pickno) async {
    await SharedPrefs.pickman_Pickno(Pickman_pickno);
  }

  Future<void> savereqno(String Pickman_ReqNo) async {
    await SharedPrefs.dispaatch_requestno(Pickman_ReqNo);
  }

  Widget buildTable() {
    double screenHeight = MediaQuery.of(context).size.height;
    int serialNumber = 1;

    return Responsive.isDesktop(context)
        ? _buildDesktopTable()
        : _buildMobileCards();
  }

  Widget _buildDesktopTable() {
    double screenHeight = MediaQuery.of(context).size.height;
    int serialNumber = 1;
    return Container(
      child: Scrollbar(
        thumbVisibility: true,
        controller: _horizontalScrollController,
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                height:
                    Responsive.isDesktop(context) ? screenHeight * 0.7 : 400,
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.85
                    : MediaQuery.of(context).size.width * 2,
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _verticalScrollController,
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10, top: 13, bottom: 5.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Container(
                                width: 80,
                                height: Responsive.isDesktop(context) ? 25 : 30,
                                decoration: TableHeaderColor,
                                child: Center(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.numbers,
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
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: Responsive.isDesktop(context) ? 25 : 30,
                                decoration: TableHeaderColor,
                                child: Center(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.assignment_turned_in,
                                              size: 15,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 5),
                                            Text("Pick Id",
                                                textAlign: TextAlign.center,
                                                style: commonLabelTextStyle),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: Responsive.isDesktop(context) ? 25 : 30,
                                decoration: TableHeaderColor,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.date_range,
                                              size: 15,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 5),
                                            Text("Date",
                                                textAlign: TextAlign.center,
                                                style: commonLabelTextStyle),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: Responsive.isDesktop(context) ? 25 : 30,
                                decoration: TableHeaderColor,
                                child: Center(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.file_copy,
                                              size: 15,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                                Responsive.isDesktop(context)
                                                    ? "Qty.Invoice"
                                                    : "Qty.Invoi",
                                                textAlign: TextAlign.center,
                                                style: commonLabelTextStyle),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: Responsive.isDesktop(context) ? 25 : 30,
                                decoration: TableHeaderColor,
                                child: Center(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.shopping_cart,
                                              size: 15,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                                Responsive.isDesktop(context)
                                                    ? "Qty.Requested "
                                                    : "Qry.Req",
                                                textAlign: TextAlign.center,
                                                style: commonLabelTextStyle),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: Responsive.isDesktop(context) ? 25 : 30,
                                decoration: TableHeaderColor,
                                child: Center(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.done_all,
                                              size: 15,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 3),
                                            Text("Qty.Picked",
                                                textAlign: TextAlign.center,
                                                style: commonLabelTextStyle),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: Responsive.isDesktop(context) ? 25 : 30,
                                decoration: TableHeaderColor,
                                child: Center(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.disabled_visible_sharp,
                                              size: 15,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 5),
                                            Text("Actions",
                                                textAlign: TextAlign.center,
                                                style: commonLabelTextStyle),
                                          ],
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
                      if (_isLoading)
                        Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (filteredData.isNotEmpty)
                        ...filteredData.asMap().entries.where((entry) {
                          var data = entry.value;
                          return data['pickMan_Name'] == saveloginname;
                        }).map((entry) {
                          int index = entry.key;
                          var data = entry.value;
                          // Start serial number counter

                          // Assign continuous serial number to filtered data
                          String sNo = serialNumber.toString();
                          serialNumber++; // Increment serial number for each matching entry
                          var reqid = data['reqid'].toString();

                          var pick_id = data['pick_id'].toString();
                          var pickMan_name = data['pickMan_Name'].toString();

                          var date = data['date'].toString();

                          var des_id =
                              double.tryParse(data['des_id'].toString())
                                      ?.toInt()
                                      .toString() ??
                                  data['des_id'].toString();
                          var total = double.tryParse(data['total'].toString())
                                  ?.toInt()
                                  .toString() ??
                              data['total'].toString();

                          var scanned_qty =
                              double.tryParse(data['scanned_qty'].toString())
                                      ?.toInt()
                                      .toString() ??
                                  data['scanned_qty'].toString();
                          var balance_qty =
                              double.tryParse(data['balance_qty'].toString())
                                      ?.toInt()
                                      .toString() ??
                                  data['balance_qty'].toString();

                          var status = data['status'].toString();
                          bool isEvenRow = index % 2 == 0;
                          Color? rowColor = isEvenRow
                              ? Color.fromARGB(224, 255, 255, 255)
                              : Color.fromARGB(224, 255, 255, 255);

                          return GestureDetector(
                            onTap: () {},
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10.0, right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Container(
                                      height: 30,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        color: rowColor,
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 226, 225, 225),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SelectableText(
                                            sNo,
                                            textAlign: TextAlign.center,
                                            style: commonLabelTextStyle,
                                            showCursor: false,
                                            // overflow: TextOverflow.ellipsis,
                                            cursorColor: Colors.blue,
                                            cursorWidth: 2.0,
                                            toolbarOptions: ToolbarOptions(
                                                copy: true, selectAll: true),
                                            onTap: () {
                                              // Optional: Handle single tap if needed
                                            },
                                          ),
                                          // Text(sNo,
                                          //     textAlign: TextAlign.center,
                                          //     style: TableRowTextStyle),
                                        ],
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
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SelectableText(
                                            "$pick_id",
                                            textAlign: TextAlign.center,
                                            style: commonLabelTextStyle,
                                            showCursor: false,
                                            // overflow: TextOverflow.ellipsis,
                                            cursorColor: Colors.blue,
                                            cursorWidth: 2.0,
                                            toolbarOptions: ToolbarOptions(
                                                copy: true, selectAll: true),
                                            onTap: () {
                                              // Optional: Handle single tap if needed
                                            },
                                          ),

                                          // Text("PickId_$pick_id",
                                          //     textAlign: TextAlign.center,
                                          //     style: TableRowTextStyle),
                                        ],
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
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SelectableText(
                                            date,
                                            textAlign: TextAlign.center,
                                            style: commonLabelTextStyle,
                                            showCursor: false,
                                            // overflow: TextOverflow.ellipsis,
                                            cursorColor: Colors.blue,
                                            cursorWidth: 2.0,
                                            toolbarOptions: ToolbarOptions(
                                                copy: true, selectAll: true),
                                            onTap: () {
                                              // Optional: Handle single tap if needed
                                            },
                                          ),
                                          // Text(date,
                                          //     textAlign: TextAlign.center,
                                          //     style: TableRowTextStyle),
                                        ],
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
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SelectableText(
                                            des_id,
                                            textAlign: TextAlign.center,
                                            style: TableRowTextStyle,
                                            showCursor: false,
                                            // overflow: TextOverflow.ellipsis,
                                            cursorColor: Colors.blue,
                                            cursorWidth: 2.0,
                                            toolbarOptions: ToolbarOptions(
                                                copy: true, selectAll: true),
                                            onTap: () {
                                              // Optional: Handle single tap if needed
                                            },
                                          ),
                                          // Text(des_id,
                                          //     textAlign: TextAlign.center,
                                          //     style: TableRowTextStyle),
                                        ],
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
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SelectableText(
                                            total,
                                            textAlign: TextAlign.center,
                                            style: TableRowTextStyle,
                                            showCursor: false,
                                            // overflow: TextOverflow.ellipsis,
                                            cursorColor: Colors.blue,
                                            cursorWidth: 2.0,
                                            toolbarOptions: ToolbarOptions(
                                                copy: true, selectAll: true),
                                            onTap: () {
                                              // Optional: Handle single tap if needed
                                            },
                                          ),
                                          // Text(total,
                                          //     textAlign: TextAlign.center,
                                          //     style: TableRowTextStyle),
                                        ],
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
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Tooltip(
                                            message: "Scanned Qty (Picked Qty)",
                                            child: Text("$scanned_qty",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 3, 145, 50),
                                                  fontSize: 13,
                                                )),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text("-",
                                              textAlign: TextAlign.center,
                                              style: TableRowTextStyle),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Tooltip(
                                            message: "Pending Scan Qty",
                                            child: Text("$balance_qty",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 204, 22, 22),
                                                  fontSize: 13,
                                                )),
                                          ),
                                        ],
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
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: 0.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: status == "Finished"
                                                      ? Colors.green
                                                      : buttonColor),
                                              child: ElevatedButton(
                                                  onPressed: () async {
                                                    widget.togglePage();
                                                    // Navigator.pushReplacement(
                                                    //   context,
                                                    //   MaterialPageRoute(
                                                    //     builder: (context) =>
                                                    //         MainSidebar(
                                                    //             initialPageIndex:
                                                    //                 5), // Navigate to MainSidebar
                                                    //   ),
                                                    // );

                                                    savepickno(pick_id);

                                                    savereqno(reqid);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    minimumSize:
                                                        const Size(45.0, 20.0),
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    shadowColor:
                                                        Colors.transparent,
                                                  ),
                                                  child: Responsive.isDesktop(
                                                          context)
                                                      ? Text(
                                                          status == "Finished"
                                                              ? "View Details"
                                                              : 'View',
                                                          style:
                                                              commonWhiteStyle,
                                                        )
                                                      : Icon(
                                                          status == "Finished"
                                                              ? Icons.check
                                                              : Icons
                                                                  .remove_red_eye_outlined,
                                                          size: 12,
                                                          color: Colors.white,
                                                        )),
                                            )
                                          ],
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
                          child: Text(
                              "Kindly choose date to view Picked details.."),
                        ),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCards() {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
        ),
        padding: EdgeInsets.only(bottom: 16), // optional for spacing at bottom
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : filteredData.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child:
                          Text("Kindly choose date to view Picked details.."),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: filteredData
                          .where(
                              (data) => data['pickMan_Name'] == saveloginname)
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;
                        var data = entry.value;

                        String sNo = (index + 1).toString();
                        var reqid = data['reqid'].toString();
                        var pick_id = data['pick_id'].toString();
                        var date = data['date'].toString();
                        var des_id = double.tryParse(data['des_id'].toString())
                                ?.toInt()
                                .toString() ??
                            data['des_id'].toString();
                        var total = double.tryParse(data['total'].toString())
                                ?.toInt()
                                .toString() ??
                            data['total'].toString();
                        var scanned_qty =
                            double.tryParse(data['scanned_qty'].toString())
                                    ?.toInt()
                                    .toString() ??
                                data['scanned_qty'].toString();
                        var balance_qty =
                            double.tryParse(data['balance_qty'].toString())
                                    ?.toInt()
                                    .toString() ??
                                data['balance_qty'].toString();
                        var status = data['status'].toString();

                        return Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Card(
                            elevation: 2.0,
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text("S.No: $sNo",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Flexible(
                                        child: Text("Pick ID: $pick_id",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text("Date: $date"),
                                  SizedBox(height: 8),
                                  Text("Invoice Qty: $des_id"),
                                  SizedBox(height: 8),
                                  Text("Requested Qty: $total"),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text("Picked : ",
                                          style:
                                              TextStyle(color: Colors.green)),
                                      Text(scanned_qty,
                                          style:
                                              TextStyle(color: Colors.green)),
                                      Spacer(),
                                      Text("Pending Scan: ",
                                          style: TextStyle(color: Colors.red)),
                                      Text(balance_qty,
                                          style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: status == "Finished"
                                            ? Colors.green
                                            : buttonColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () {
                                        widget.togglePage();
                                        savepickno(pick_id);
                                        savereqno(reqid);
                                      },
                                      child: Text(
                                        status == "Finished"
                                            ? "View Details"
                                            : 'View',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
      ),
    );
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
}

class PickManViewReport extends StatefulWidget {
  const PickManViewReport({super.key});

  @override
  State<PickManViewReport> createState() => _PickManViewReportState();
}

class _PickManViewReportState extends State<PickManViewReport> {
  bool _isLoading2 = true;

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  Widget _buildTextFieldDesktop(
    String label,
    String value,
    IconData icon,
    bool readOnly,
  ) {
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
                if (!readOnly)
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
                            readOnly: readOnly,
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
                            controller: TextEditingController(text: value),
                            style: TextStyle(
                                color: Color.fromARGB(255, 73, 72, 72),
                                fontSize: 13),
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

  List<Map<String, dynamic>> tableData = [];

  Widget _buildTable() {
    if (Responsive.isMobile(context)) {
      return _buildMobileCardView();
    } else {
      return _buildDesktopTableView();
    }
  }

  Widget _buildDesktopTableView() {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
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
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 1
                        : MediaQuery.of(context).size.width * 4,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: _verticalScrollController,
                      child: SingleChildScrollView(
                        controller: _verticalScrollController,
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10.0, right: 10, top: 13, bottom: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.numbers,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text("Invoice.No",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  width: 80,
                                  decoration: TableHeaderColor,
                                  child: Center(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.category,
                                                size: 15,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(width: 5),
                                              Text("I.L.No",
                                                  textAlign: TextAlign.center,
                                                  style: commonLabelTextStyle),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.code,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text("Item Code",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: Responsive.isDesktop(context)
                                      ? 550
                                      : MediaQuery.of(context).size.width * 0.6,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: TableHeaderColor,
                                  child: Center(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.details_outlined,
                                                size: 15,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(width: 5),
                                              Text("Item Description",
                                                  textAlign: TextAlign.center,
                                                  style: commonLabelTextStyle),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .production_quantity_limits,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text("Qty.Invoice",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.local_shipping,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text("Qty.Picked",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.qr_code_scanner,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text("Qty.Scanned",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text("Status",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.visibility,
                                            size: 15,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(width: 5),
                                          Text("Scan",
                                              textAlign: TextAlign.center,
                                              style: commonLabelTextStyle),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isLoading2)
                            Padding(
                              padding: const EdgeInsets.only(top: 100.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (tableData.isNotEmpty)
                            ...tableData.map((data) {
                              var id = data['id'].toString();
                              var invoiceno = data['invoiceno'].toString();
                              var itemcode = data['itemcode'].toString();
                              var itemdetails = data['itemdetails'].toString();
                              var invoiceQty = data['invoiceQty'].toString();
                              var scannedqty = data['scannedqty'].toString();

                              var status = data['status'].toString();

                              var Scanned_qty = data['Scanned_qty'].toString();
                              var BalScanned_Qty =
                                  data['BalScanned_Qty'].toString();

                              bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                              Color? rowColor = isEvenRow
                                  ? Color.fromARGB(224, 255, 255, 255)
                                  : Color.fromARGB(224, 255, 255, 255);

                              return GestureDetector(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10.0,
                                    right: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(invoiceno,
                                                  textAlign: TextAlign.center,
                                                  style: TableRowTextStyle),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 30,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 226, 225, 225),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(id,
                                                textAlign: TextAlign.center,
                                                style: TableRowTextStyle),
                                          ],
                                        ),
                                      ),
                                      Flexible(
                                        child: Tooltip(
                                          message: itemcode,
                                          child: Container(
                                            height: 30,
                                            width: double
                                                .infinity, // Allow the container to expand fully
                                            decoration: BoxDecoration(
                                              color: rowColor,
                                              border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    itemcode,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    textAlign: TextAlign.start,
                                                    style: TableRowTextStyle,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Tooltip(
                                        message: itemdetails,
                                        child: Container(
                                          height: 30,
                                          width: Responsive.isDesktop(context)
                                              ? 550
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  itemdetails,
                                                  textAlign: TextAlign.center,
                                                  style: TableRowTextStyle,
                                                  overflow: TextOverflow
                                                      .visible, // This ensures that the text will not be clipped
                                                ),
                                              ],
                                            ),
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
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(invoiceQty,
                                                  textAlign: TextAlign.center,
                                                  style: TableRowTextStyle),
                                            ],
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
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(scannedqty,
                                                  textAlign: TextAlign.center,
                                                  style: TableRowTextStyle),
                                            ],
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
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Tooltip(
                                                message:
                                                    "Scanned Qty (Picked Qty)",
                                                child: Text(Scanned_qty,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 23, 122, 5))),
                                              ),
                                              SizedBox(width: 10),
                                              const Text("-",
                                                  textAlign: TextAlign.center,
                                                  style: TableRowTextStyle),
                                              SizedBox(width: 10),
                                              Tooltip(
                                                message: "Balance Qty to Scan",
                                                child: Text(
                                                  // Use a conditional to format the value
                                                  double.parse(BalScanned_Qty)
                                                          .toStringAsFixed(1)
                                                          .endsWith('.0')
                                                      ? int.parse(double.parse(
                                                                  BalScanned_Qty)
                                                              .toStringAsFixed(
                                                                  0))
                                                          .toString()
                                                      : BalScanned_Qty,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 200, 10, 10),
                                                  ),
                                                ),
                                              ),
                                            ],
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
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(status,
                                                  textAlign: TextAlign.center,
                                                  style: TableRowTextStyle),
                                            ],
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
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: status == "Finished"
                                                        ? Colors.green
                                                        : buttonColor,
                                                  ),
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      // Your onPressed logic here

                                                      String reqno =
                                                          _ReqnoController.text
                                                              .toString();
                                                      String pickno =
                                                          _PicknoController.text
                                                                  .isNotEmpty
                                                              ? _PicknoController
                                                                  .text
                                                              : '';

                                                      // String invoiceno =
                                                      //     _InvoiceNumberController
                                                      //             .text
                                                      //             .isNotEmpty
                                                      //         ? _InvoiceNumberController
                                                      //             .text
                                                      //         : '';

                                                      await showDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            false,
                                                        builder: (BuildContext
                                                            context) {
                                                          return Dialog(
                                                            child: Container(
                                                              color: Colors
                                                                  .grey[100],
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.8,
                                                              child: Stack(
                                                                children: [
                                                                  Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.8,
                                                                    child: ReportCustomerDetailsDialog(
                                                                        reqno:
                                                                            reqno,
                                                                        pickno:
                                                                            pickno,
                                                                        invoiceno:
                                                                            '$invoiceno',
                                                                        itemcode:
                                                                            '$itemcode',
                                                                        itemdetails:
                                                                            itemdetails),
                                                                  ),
                                                                  Positioned(
                                                                    top: 10,
                                                                    right: 10,
                                                                    child:
                                                                        IconButton(
                                                                      icon: Icon(
                                                                          Icons
                                                                              .cancel,
                                                                          color:
                                                                              Colors.red),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop(); // Close the dialog
                                                                      },
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );

                                                      await fetchDataPicknO();

                                                      postLogData(
                                                          "Picked View Pop-Up (View)",
                                                          "Opened");
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: status ==
                                                              "Finished"
                                                          ? Colors.green
                                                          : Colors.transparent,
                                                      shadowColor:
                                                          Colors.transparent,
                                                      minimumSize:
                                                          Size(45.0, 31.0),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    child: status == "Finished"
                                                        ? Text('View Info',
                                                            style:
                                                                commonWhiteStyle)
                                                        : Responsive.isDesktop(
                                                                context)
                                                            ? Text('View Info',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white))
                                                            : Icon(
                                                                Icons
                                                                    .qr_code_scanner,
                                                                size: 15,
                                                                color: Colors
                                                                    .white),
                                                  ),
                                                )
                                              ],
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
        SizedBox(
          height: 10,
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
                  _horizontalScrollController.animateTo(
                    _horizontalScrollController.offset -
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
                  _horizontalScrollController.animateTo(
                    _horizontalScrollController.offset +
                        100, // Adjust scroll amount
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

  Widget _buildMobileCardView() {
    return Column(
      children: [
        _isLoading2
            ? Center(child: CircularProgressIndicator())
            : tableData.isEmpty
                ? Center(
                    child: Text("No data available.",
                        style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    padding: EdgeInsets.all(12),
                    physics:
                        NeverScrollableScrollPhysics(), // Disable ListView scrolling
                    shrinkWrap:
                        true, // Allow ListView to take only the space it needs
                    itemCount: tableData.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final data = tableData[index];
                      final status = data['status'].toString();
                      final isFinished = status == "Finished";

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with status indicator
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isFinished
                                    ? Colors.green[50]
                                    : Colors.blue[50],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isFinished
                                        ? Icons.check_circle
                                        : Icons.pending,
                                    color:
                                        isFinished ? Colors.green : Colors.blue,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Invoice #${data['invoiceno']}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isFinished
                                          ? Colors.green
                                          : Colors.blue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Item details
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildMobileDetailRow(
                                    icon: Icons.code,
                                    label: "Item Code",
                                    value: data['itemcode'],
                                  ),
                                  SizedBox(height: 8),
                                  _buildMobileDetailRow(
                                    icon: Icons.description,
                                    label: "Description",
                                    value: data['itemdetails'],
                                    maxLines: 2,
                                  ),
                                  Divider(
                                      height: 24,
                                      thickness: 1,
                                      color: Colors.grey[200]),

                                  // Quantity row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildQuantityChip(
                                        "Invoice Qty",
                                        data['invoiceQty'],
                                        Colors.blue[100]!,
                                      ),
                                      _buildQuantityChip(
                                        "Picked Qty",
                                        data['scannedqty'],
                                        Colors.orange[100]!,
                                      ),
                                      _buildQuantityChip(
                                        "Scanned Qty",
                                        data['Scanned_qty'],
                                        Colors.green[100]!,
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 16),
                                  // Balance quantity
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.red.shade100),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.warning,
                                            color: Colors.red, size: 16),
                                        SizedBox(width: 8),
                                        Text(
                                          "Balance: ${data['BalScanned_Qty']}",
                                          style: TextStyle(
                                            color: Colors.red[800],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Action button
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: Icon(
                                    isFinished
                                        ? Icons.visibility
                                        : Icons.qr_code_scanner,
                                    size: 20,
                                  ),
                                  label: Text(isFinished
                                      ? "VIEW DETAILS"
                                      : "SCAN ITEM"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isFinished
                                        ? Colors.green
                                        : Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () async {
                                    // Your existing dialog logic
                                    String reqno =
                                        _ReqnoController.text.toString();
                                    String pickno =
                                        _PicknoController.text.isNotEmpty
                                            ? _PicknoController.text
                                            : '';
                                    // String invoiceno =
                                    //     _InvoiceNumberController.text.isNotEmpty
                                    //         ? _InvoiceNumberController.text
                                    //         : '';

                                    var invoiceno =
                                        data['invoiceno'].toString();

                                    await showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxHeight: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.8,
                                          ),
                                          child: Stack(
                                            children: [
                                              ReportCustomerDetailsDialog(
                                                  reqno: reqno,
                                                  pickno: pickno,
                                                  invoiceno: invoiceno,
                                                  itemcode: data['itemcode']
                                                      .toString(),
                                                  itemdetails:
                                                      data['itemdetails']
                                                          .toString()),
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: IconButton(
                                                  icon: Icon(Icons.close,
                                                      color: Colors.red),
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                    await fetchDataPicknO();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ],
    );
  }

  Widget _buildMobileDetailRow({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  TextEditingController NoofitemController = TextEditingController(text: "0");
  TextEditingController totalSendqtyController =
      TextEditingController(text: '0');

  void _updatedisreqamt() {
    // Use the getTotalFinalAmt function to update the total amount
    totalSendqtyController.text =
        gettotaldisreqamt(tableData).toStringAsFixed(2);
    print("totaldisreqController amountttt ${totalSendqtyController.text}");
  }

  double gettotaldisreqamt(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['noofqty'] ?? '0') ?? 0.0;
      totalQuantity += quantity;
    }
    return totalQuantity;
  }

  @override
  void initState() {
    super.initState();

    _updatedisreqamt();
    fetchAccessControl();
    _loadSalesmanName();
    fetchDataPicknO();
    fetchDataPicknO();
  }

  List<String> accessControl = [];
  Future<List<String>> fetchAccessControl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lableRoleIDList = prefs.getString('departmentid');
    String? salesloginnoStr = prefs.getString('salesloginno');

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

  String? saveloginname = '';

  String? saveloginrole = '';

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
      saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();

    super.dispose();

    fetchDataPicknO();
  }

  TextEditingController _IdController = TextEditingController();
  TextEditingController _InvoiceNumberController = TextEditingController();
  TextEditingController _ReqnoController = TextEditingController();
  TextEditingController _PicknoController = TextEditingController();
  TextEditingController _DateController = TextEditingController();
  TextEditingController _CusidController = TextEditingController();
  TextEditingController _CussiteController = TextEditingController();
  TextEditingController _CustomerNameController = TextEditingController();
  TextEditingController _RegionController = TextEditingController();
  TextEditingController _WarehousenameNameController = TextEditingController();
  TextEditingController _CustomerNumberController = TextEditingController();

  TextEditingController _Org_idController = TextEditingController();
  TextEditingController _Org_nameController = TextEditingController();
  TextEditingController _Salesman_idmeController = TextEditingController();
  TextEditingController Salesman_channelController = TextEditingController();
  TextEditingController IdController = TextEditingController();
  TextEditingController _AssignedStaffController = TextEditingController();

  Future<void> fetchDataPicknO() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? pickno = prefs.getString('pickno');
    String? reqno = prefs.getString('reqno');

    final IpAddress = await getActiveIpAddress();

    final response = await http
        .get(Uri.parse('$IpAddress/Filtered_Pickscan/$reqno/$pickno'));
    print("response dataaaaaaaaa ${response.body}");
    print("urls $IpAddress/Filtered_Pickscan/$reqno/$pickno");
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes); // <- fix here

      final List<dynamic> responseData =
          json.decode(decodedBody); // Ensure this is a list

      if (responseData.isEmpty || responseData[0] == null) {
        print("Empty or invalid response data");
        return;
      }

      final data =
          responseData[0]; // Get the first item from the response array

      setState(() {
        // Update the controller fields
        _IdController.text = data["ID"]?.toString() ?? '';
        _PicknoController.text = data['PICK_ID']?.toString() ?? '';
        _AssignedStaffController.text = data['ASS_PICKMAN']?.toString() ?? '';
        _ReqnoController.text = data['REQ_ID']?.toString() ?? '';
        _DateController.text = data['INVOICE_DATE']?.toString() ?? '';
        _InvoiceNumberController.text =
            data['INVOICE_NUMBER']?.toString() ?? '';
        _CusidController.text = data['CUSTOMER_NUMBER']?.toString() ?? '';
        _CussiteController.text = data['CUSTOMER_SITE_ID']?.toString() ?? '';
        _CustomerNameController.text = data['CUSTOMER_NAME']?.toString() ?? '';
        _CustomerNumberController.text =
            data['CUSTOMER_NUMBER']?.toString() ?? '';
        _RegionController.text = data['ORG_NAME']?.toString() ?? '';
        _WarehousenameNameController.text =
            data['TO_WAREHOUSE']?.toString() ?? '';
        _Salesman_idmeController.text = data['SALESREP_ID']?.toString() ?? '';
        Salesman_channelController.text =
            data['SALES_CHANNEL']?.toString() ?? '';

        _Org_idController.text = data['ORG_ID']?.toString() ?? '';
        _Org_nameController.text = data['ORG_NAME']?.toString() ?? '';

        tableData = [];

        if (data['TABLE_DETAILS'] != null) {
          for (var item in data['TABLE_DETAILS']) {
            final pick_qty =
                double.tryParse(item['PICKED_QTY']?.toString() ?? '0') ?? 0;
            final scannedQty =
                double.tryParse(item['SCANNED_QTY']?.toString() ?? '0') ?? 0;
            final balScannedQty = (pick_qty - scannedQty).toString();

            tableData.add({
              'Row_id': item['ID']?.toString() ?? '',
              'id': item['LINE_NUMBER']?.toString() ?? '',
              'invoiceno': item['INVOICE_NUMBER']?.toString() ?? '',
              'itemcode': item['INVENTORY_ITEM_ID']?.toString() ?? '',
              'itemdetails': item['ITEM_DESCRIPTION']?.toString() ?? '',
              'invoiceQty': item['TOT_QUANTITY']?.toString() ?? '0',
              'scannedqty': item['PICKED_QTY']?.toString() ?? '0',
              'needtoscan': item['BALANCE_QTY']?.toString() ?? '0',
              'sendqty': '0',
              'dispatchqty': '0',
              'status': item['STATUS']?.toString() ?? '',
              'dispatch_qty': item['DISPATCHED_QTY']?.toString() ?? '',
              'amount': item['AMOUNT']?.toString() ?? '',
              'item_cost': item['ITEM_COST']?.toString() ?? '',
              'balance_qty': item['BALANCE_QTY']?.toString() ?? '0',
              'Scanned_qty': item['SCANNED_QTY']?.toString() ?? '0',
              'BalScanned_Qty': balScannedQty,
            });
          }
          // _initializeControllers();
        }

        // print('table datasssssssssssssss: ${tableData}');
      });
    } else {
      print('Failed to load dispatch request details: ${response.statusCode}');
    }
    setState(() {
      _isLoading2 = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenheight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        // This allows navigation back
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainSidebar(
              initialPageIndex: 16,
              enabledItems: accessControl,
            ), // Navigate to MainSidebar
          ),
        );
        return true; // Return `true` to allow navigation back
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: screenheight,
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //     colors: [
            //       Color.fromARGB(77, 1, 1, 189), // Ink blue
            //       Color.fromARGB(72, 80, 190, 234), // Sky blue
            //     ],
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            //   ),
            //   borderRadius: BorderRadius.circular(5), // Matches button radius
            // ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  // Heading
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
                              InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MainSidebar(
                                          enabledItems: accessControl,
                                          initialPageIndex:
                                              4), // Navigate to MainSidebar
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Image.asset(
                                      'assets/images/pickman.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Pick Man View',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // SizedBox(
                                  //   width: 10,
                                  // ),
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
                    padding:
                        const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                    child: Container(
                      height: screenheight * 0.84,
                      width: MediaQuery.of(context).size.width,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: Responsive.isDesktop(context) ? 30 : 10,
                                bottom: Responsive.isDesktop(context) ? 30 : 10,
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                runSpacing: 2,
                                children: [
                                  _buildTextFieldDesktop(
                                      'Picking ID',
                                      "${_PicknoController.text}",
                                      Icons.numbers,
                                      true),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  _buildTextFieldDesktop(
                                      'DispatchReq ID',
                                      "${_ReqnoController.text}",
                                      Icons.request_page,
                                      true),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  _buildTextFieldDesktop(
                                      'Physical Warehouse',
                                      _WarehousenameNameController.text,
                                      Icons.warehouse,
                                      true),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  _buildTextFieldDesktop(
                                      'Region',
                                      _RegionController.text,
                                      Icons.location_city,
                                      true),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  _buildTextFieldDesktop(
                                      'Customer No',
                                      _CusidController.text,
                                      Icons.no_accounts,
                                      true),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  _buildTextFieldDesktop(
                                      'Customer Name',
                                      _CustomerNameController.text,
                                      Icons.perm_identity,
                                      true),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  _buildTextFieldDesktop(
                                      'Customer Site',
                                      _CussiteController.text,
                                      Icons.sixteen_mp_outlined,
                                      true),
                                ],
                              ),
                            ),
                            if (Responsive.isDesktop(context))
                              SizedBox(
                                height: 5,
                              ),
                            if (Responsive.isDesktop(context))
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 0,
                                    left:
                                        Responsive.isDesktop(context) ? 35 : 10,
                                    right: Responsive.isDesktop(context)
                                        ? 35
                                        : 10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Pick Items:',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blueGrey[700]),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
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
                                                      'Scanned Qty (Picked Qty)',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                            Color.fromARGB(255,
                                                                200, 10, 10)),
                                                    SizedBox(
                                                        width:
                                                            8), // Space between bullet and text
                                                    Text(
                                                      'Balance Qty to scan',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              255,
                                                              200,
                                                              10,
                                                              10)),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: _buildTable(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (!Responsive.isDesktop(context))
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 5,
                                  left: Responsive.isDesktop(context) ? 35 : 10,
                                  right:
                                      Responsive.isDesktop(context) ? 35 : 10,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text("Pick Items :",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    _buildMobileCardView(),
                                  ],
                                ),
                              ),
                            SizedBox(
                              height: 30,
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
        ),
      ),
    );
  }

  void successfullyLoginMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.check_circle_rounded, color: Colors.green),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                'Scanned Successfully !!',
                style: TextStyle(fontSize: 13, color: Colors.black),
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
}

class ReportCustomerDetailsDialog extends StatefulWidget {
  final String reqno;
  final String pickno;
  final String invoiceno;
  final String itemcode;
  final String itemdetails;

  ReportCustomerDetailsDialog({
    required this.reqno,
    required this.pickno,
    required this.invoiceno,
    required this.itemcode,
    required this.itemdetails,
  });

  @override
  _ReportCustomerDetailsDialogState createState() =>
      _ReportCustomerDetailsDialogState();
}

class _ReportCustomerDetailsDialogState
    extends State<ReportCustomerDetailsDialog> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    fetchPickmanData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        width: Responsive.isDesktop(context)
            ? screenWidth * 0.6
            : MediaQuery.of(context).size.width * 3,
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Scan Pop-Up View",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 10),
            const Text(
              "Scanned Details",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildScrollableTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableTable() {
    return Container(
      height: Responsive.isDesktop(context)
          ? MediaQuery.of(context).size.height * 7
          : MediaQuery.of(context).size.height * 9,
      width: Responsive.isDesktop(context)
          ? MediaQuery.of(context).size.width * 1
          : MediaQuery.of(context).size.width * 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ScrollbarTheme(
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
            scrollDirection: Axis.horizontal,
            controller: _horizontalScrollController,
            child: Scrollbar(
              thumbVisibility: true,
              controller: _verticalScrollController,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: _verticalScrollController,
                child: DataTableTheme(
                  data: DataTableThemeData(
                    headingRowHeight: 30,
                    dataRowHeight: 40,
                  ),
                  child: DataTable(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 1,
                      ),
                    ),
                    headingRowColor:
                        MaterialStateProperty.all(Colors.grey.shade300),
                    dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return states.contains(MaterialState.selected)
                            ? Colors.grey.shade400
                            : null;
                      },
                    ),
                    columnSpacing: 20,
                    columns: _buildTableColumns(),
                    rows: _buildTableRows(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildTableColumns() {
    return [
      // DataColumn(label: _headerText("No")),
      DataColumn(label: _headerText("Invoice No")),
      DataColumn(label: _headerText("Item Code")),
      DataColumn(label: _headerText("Item Description")),
      DataColumn(label: _headerText("Product Code")),
      DataColumn(label: _headerText("Serial No")),
    ];
  }

  List<DataRow> _buildTableRows() {
    print("alreadyscantableDataaaaaa: $alreadyscantableData");

    // Filter only where ITEM_DESCRIPTION == 'item code'
    final filteredData = alreadyscantableData.where(
      (data) => data['ITEM_DESCRIPTION']?.toString() == widget.itemdetails,
    );

    return filteredData.map((data) {
      return DataRow(
        cells: [
          // DataCell(_cellText(data['id'].toString())),
          DataCell(_cellText(data['INVOICE_NUMBER'].toString())),
          DataCell(_cellText(data['INVENTORY_ITEM_ID'].toString())),
          DataCell(_cellText(data['ITEM_DESCRIPTION'].toString())),
          DataCell(_cellText(data['PRODUCT_CODE'].toString())),
          DataCell(_cellText(data['SERIAL_NO'].toString())),
        ],
      );
    }).toList();
  }

  Widget _headerText(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
      textAlign: TextAlign.left,
    );
  }

  Widget _cellText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: Colors.black),
      textAlign: TextAlign.left,
    );
  }

  List<Map<String, dynamic>> alreadyscantableData = [];
  bool isLoading = true;
  Future<void> fetchPickmanData() async {
    String reqno = widget.reqno.toString();
    String pickno = widget.pickno.isNotEmpty ? widget.pickno : '';
    String invoiceno = widget.invoiceno.isNotEmpty ? widget.invoiceno : '';
    String itemCode = widget.itemcode.isNotEmpty ? widget.itemcode : '';

    final IpAddress = await getActiveIpAddress();

    final url = Uri.parse(
        '$IpAddress/Scanned_Pickman/?PICK_ID=$pickno&REQ_ID=$reqno&INVOICE_NUMBER=$invoiceno&INVENTORY_ITEM_ID=$itemCode');
    print("Fetching data from: $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decode the JSON array
        final List<dynamic> jsonData = json.decode(response.body);

        // Convert the JSON array to a list of maps
        final List<Map<String, dynamic>> fetchedData =
            List<Map<String, dynamic>>.from(jsonData);

        setState(() {
          alreadyscantableData = fetchedData;
          isLoading = false;
        });

        print("Fetched data: $alreadyscantableData");
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Timer? _debounce;
}
