import 'dart:typed_data'; // for Uint8List
import 'dart:io'; // for File
import 'package:aljeflutterapp/Reports/CommercialReports.dart';
import 'package:aljeflutterapp/dispatch/Comersioal_login.dart';
import 'package:aljeflutterapp/main.dart';
import 'package:aljeflutterapp/welcomedashboard.dart';
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

class Commersial_Form extends StatefulWidget {
  @override
  State<Commersial_Form> createState() => _Commersial_FormState();
}

class _Commersial_FormState extends State<Commersial_Form> {
  final TextEditingController salesmanIdController = TextEditingController();

  List<Map<String, dynamic>> filteredData = [];
  bool _isLoadingData = true;
  bool _isDarkMode = false;

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSalesmanName();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();

    postLogData("Dispatch Request", "Closed");
  }

  String? commersialname = '';

  String? commersialrole = '';
  String? commersialno = '';

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      commersialname = prefs.getString('commersialname') ?? 'Unknown Salesman';
      commersialrole = prefs.getString('commersialrole') ?? 'Unknown Salesman';
      commersialno = prefs.getString('commersialno') ?? 'Unknown ID';
    });
  }

  String selectedMenu = 'Create Dispatch';

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
        color: Colors.grey[200],
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.only(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    right: 20,
                                    top: Responsive.isMobile(context) ? 25 : 0),
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Container(
                                            width: 300,
                                            padding: const EdgeInsets.all(20.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Logout",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                                Text(
                                                  "Are you sure you want to logout?",
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                SizedBox(height: 20),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                      },
                                                      child: Text("No"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        print(
                                                            "commersialno commersialno $commersialrole");
                                                        // Add your logout logic here
                                                        print(
                                                            "User logged out");
                                                        Navigator.of(context)
                                                            .pop();
                                                        {
                                                          await SharedPrefs
                                                              .cleardatadepartmentexchange();
                                                          Navigator
                                                              .pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        WelcomeDashboard(
                                                                          emailController:
                                                                              TextEditingController(),
                                                                        )),
                                                          );
                                                        }
                                                        postLogData(
                                                            "Logout", "Logout");
                                                      },
                                                      child: Text("Yes"),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.logout,
                                        size: 22,
                                        color: _isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      SizedBox(width: 8.0),
                                      Text(
                                        'Logout',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
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
                                  Icons.business,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Sales Supervisor Login',
                                    style: TextStyle(
                                      fontSize: 22,
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
                                        commersialname ?? 'Loading...',
                                        style: TextStyle(
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(0),
                                      child: Text(
                                        commersialrole ?? 'Loading...',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: const Color.fromARGB(
                                                255, 68, 67, 67)),
                                      ),
                                    ),
                                  ],
                                ),
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
                    child: Row(
                      children: [
                        Container(
                          width: screenWidth * 0.15,
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Create Dispatch Menu
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedMenu = 'Create Dispatch';
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: selectedMenu == 'Create Dispatch'
                                          ? Colors.blue.withOpacity(0.3)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: EdgeInsets.all(3),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Icon(
                                            Icons.newspaper,
                                            color: selectedMenu ==
                                                    'Create Dispatch'
                                                ? Colors.blue
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        if (Responsive.isDesktop(context))
                                          Text(
                                            'Create Dispatch',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: selectedMenu ==
                                                      'Create Dispatch'
                                                  ? Colors.blue
                                                  : Colors.black,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Reports Menu
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedMenu = 'Reports';
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: selectedMenu == 'Reports'
                                          ? Colors.blue.withOpacity(0.3)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: EdgeInsets.all(3),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Icon(
                                            Icons.search,
                                            color: selectedMenu == 'Reports'
                                                ? Colors.blue
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        if (Responsive.isDesktop(context))
                                          Text(
                                            'Reports',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: selectedMenu == 'Reports'
                                                  ? Colors.blue
                                                  : Colors.black,
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
                        // Right Side Content
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            child: selectedMenu == 'Create Dispatch'
                                ? Commersial_Login()
                                : CommercialReports(),
                          ),
                        ),
                      ],
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
}

class CreateDispatchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Create Dispatch Page',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ReportsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Reports Page',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
