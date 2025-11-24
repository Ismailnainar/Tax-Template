import 'dart:convert';
import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/dispatch/Comersioal_login.dart';
import 'package:aljeflutterapp/dispatch/Commersial_Form.dart';
import 'package:aljeflutterapp/main.dart';
import 'package:aljeflutterapp/mainsidebar/adminsidebar.dart';
import 'package:http/http.dart' as http;

import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mainsidebar/mainSidebar.dart';

class WelcomeDashboard extends StatefulWidget {
  final TextEditingController emailController;

  const WelcomeDashboard({required this.emailController, super.key});

  @override
  State<WelcomeDashboard> createState() => _WelcomeDashboardState();
}

class _WelcomeDashboardState extends State<WelcomeDashboard> {
  List<bool> enabledStatus = [];

  // List of image paths for each container
  final List<String> imagePaths = [
    'assets/images/warehouse.png',
    'assets/images/servent.png',
    'assets/images/qrscan.png',
    // 'assets/images/setting.png',
    'assets/images/attadence.png',
    // 'assets/images/person.png',
    'assets/images/chart.png',
    'assets/images/clock.png',
    // 'assets/images/chat.png',
    'assets/images/mail.png',
    'assets/images/warehouse.png',
    'assets/images/servent.png',
    'assets/images/qrscan.png',
    // 'assets/images/setting.png',
    'assets/images/attadence.png',
    // 'assets/images/person.png',
    'assets/images/chart.png',
    'assets/images/clock.png',
    // 'assets/images/chat.png',
    'assets/images/mail.png',
  ];

  // List of text labels for each container
  List<String> labelsList = [];

  List<String> lableRoleList = [];
  List<String> lableRoleIDList = [];

  String welcomelableno = '';
  String welcomelabletext = '';

  Future<void> fetchLabels() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginnoStr =
        prefs.getString('salesloginno') ?? prefs.getString('commersialno');
    welcomelableno =
        (prefs.getString('salesloginno') ?? prefs.getString('commersialno'))!;

    welcomelabletext = (prefs.getString('saveloginname') ??
        prefs.getString('commersialname'))!;

    final IpAddress = await getActiveIpAddress();

    final String url1 = "$IpAddress/DepartmentView/";
    final String url2 = "$IpAddress/get_department_details/$salesloginnoStr/";

    print("Fetching data from: $url1 and $url2");

    try {
      final response1 = await http.get(Uri.parse(url1));
      final response2 = await http.get(Uri.parse(url2));

      if (response1.statusCode == 200 && response2.statusCode == 200) {
        final Map<String, dynamic> data1 = json.decode(response1.body);
        final Map<String, dynamic> data2 = json.decode(response2.body);

        final List<dynamic> results1 = data1['results']; // First API data
        final List<dynamic> results2 = data2['departments']; // Second API data
        print("Response1: ${response1.body}");
        print("Response2: ${response2.body}");

        setState(() {
          labelsList = results1
              .map<String>((item) => item['DEP_NAME'].toString())
              .toList();

          // Create a map from results2 for quick lookup

          Map<String, List<String>> departmentRoleMap = {};

          for (var item in results2) {
            final depName = item['DEP_NAME'].toString();
            final depRoleName = item['DEP_ROLE_NAME']?.toString();

            if (depRoleName != null) {
              departmentRoleMap.putIfAbsent(depName, () => []);
              if (!departmentRoleMap[depName]!.contains(depRoleName)) {
                departmentRoleMap[depName]!.add(depRoleName);
              }
            }
          }

          // Map<String, String?> departmentRoleMap = {
          //   for (var item in results2)
          //     item['DEP_NAME'].toString(): item['DEP_ROLE_NAME']?.toString()
          // };

          // Assign roles where DEP_NAME matches, else assign ""

          lableRoleList = labelsList
              .map((label) => departmentRoleMap[label]?.join(', ') ?? "")
              .toList();
          // lableRoleList = labelsList
          //     .map((label) => departmentRoleMap[label] ?? "")
          //     .toList();

          // Similarly, fetch role IDs where DEP_NAME matches and convert them to String
          // Map<String, String> departmentRoleIdMap = {
          //   for (var item in results2)
          //     item['DEP_NAME'].toString(): item['DEP_ROLE_ID']?.toString() ?? ""
          // };

          Map<String, List<String>> departmentRoleIdMap = {};

          for (var item in results2) {
            final depName = item['DEP_NAME'].toString();
            final depRoleName = item['DEP_ROLE_ID']?.toString();

            if (depRoleName != null) {
              departmentRoleIdMap.putIfAbsent(depName, () => []);
              if (!departmentRoleIdMap[depName]!.contains(depRoleName)) {
                departmentRoleIdMap[depName]!.add(depRoleName);
              }
            }
          }

          lableRoleIDList = labelsList
              .map((label) => departmentRoleIdMap[label]?.join(', ') ?? "")
              // .map((label) => departmentRoleIdMap[label] ?? "")
              .toList();

          // Set enabledStatus based on whether the department exists in results2
          enabledStatus = labelsList
              .map((label) => departmentRoleMap.containsKey(label))
              .toList();

          print('departmentRoleMap: $departmentRoleMap');
          print('lableRoleList: $lableRoleList');
          print('lableRoleIDList: $lableRoleIDList');
          print('enabledStatus: $enabledStatus');
        });
      } else {
        print("Error: ${response1.statusCode} or ${response2.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  List<String> accessControl = [];

  Future<List<String>> fetchAccessControl(String lableRoleIDList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lableRoleIDList = prefs.getString('departmentid');
    String? salesloginnoStr =
        prefs.getString('salesloginno') ?? prefs.getString('commersialno');

    final IpAddress = await getActiveIpAddress();

    print('IpAddress:$IpAddress');
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

  // Function to handle container click
  Future<void> _onContainerClick(int index) async {
    if (enabledStatus[index]) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Check if salesman name is saved in SharedPreferences
      String? saveloginname =
          prefs.getString('saveloginname') ?? prefs.getString('commersialno');
      bool isLoggedIn = saveloginname != null && saveloginname.isNotEmpty;

      // Navigate to MainSidebar if logged in, otherwise go to login page
      navigateBasedOnRole(context, isLoggedIn);
    }
  }

  void navigateBasedOnRole(BuildContext context, bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print("accessControl  $accessControl");

    if (isLoggedIn) {
      String? role = prefs.getString('salesloginrole'); // Fetch the role

      String? commersialrole = prefs.getString('commersialrole');
      if (role == "admin") {
        // If the role is admin, navigate to AdminSidebar
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminSidebar(),
          ),
        );
      } else if (commersialrole == "Sales Supervisor" ||
          commersialrole == "Retail Sales Supervisor") {
        // If the role is admin, navigate to AdminSidebar
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Commersial_Form(),
          ),
        );
      } else {
        // If the role is salesman, navigate to MainSidebar
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainSidebar(enabledItems: accessControl),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLabels();
    fetchAccessControl('');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Responsive.isMobile(context)
                    ? Column(
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              // Logo with Animation
                              TweenAnimationBuilder(
                                duration: const Duration(milliseconds: 800),
                                tween: Tween<double>(begin: 0, end: 1),
                                builder: (context, double value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      width: 180,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        image: const DecorationImage(
                                          image: AssetImage(
                                              'assets/images/logo.jpg'),
                                          fit: BoxFit.contain,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),

                              // Logout Button
                              _buildLogoutButton(),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Welcome Text with Animation
                          _buildWelcomeText(),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Logo with Animation
                          TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 800),
                            tween: Tween<double>(begin: 0, end: 1),
                            builder: (context, double value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  width: 220,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    image: const DecorationImage(
                                      image:
                                          AssetImage('assets/images/logo.jpg'),
                                      fit: BoxFit.contain,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          // Welcome Text with Animation
                          _buildWelcomeText(),
                          // Logout Button
                          _buildLogoutButton(),
                        ],
                      ),
              ),
              // Grid Section
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildColumn(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome ${widget.emailController.text.isNotEmpty ? widget.emailController.text : welcomelableno}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '( ${welcomelabletext} )',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
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
  }

  Widget _buildLogoutButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          showGeneralDialog(
            context: context,
            barrierDismissible: false,
            barrierLabel: '',
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (context, animation1, animation2) {
              return Container();
            },
            transitionBuilder: (context, animation1, animation2, child) {
              final curvedAnimation = CurvedAnimation(
                parent: animation1,
                curve: Curves.easeInOutBack,
              );
              return ScaleTransition(
                scale: Tween<double>(begin: 0.5, end: 1.0)
                    .animate(curvedAnimation),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0)
                      .animate(curvedAnimation),
                  child: Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.18,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
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
                            // Animated Icon
                            TweenAnimationBuilder(
                              duration: const Duration(milliseconds: 600),
                              tween: Tween<double>(begin: 0, end: 1),
                              builder: (context, double value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.logout_rounded,
                                      size: 48,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            // Animated Title
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.5),
                                end: Offset.zero,
                              ).animate(curvedAnimation),
                              child: const Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Animated Message
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 1),
                                end: Offset.zero,
                              ).animate(curvedAnimation),
                              child: Text(
                                'Are you sure you want to logout?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Animated Buttons
                            Wrap(
                              alignment: WrapAlignment.end,
                              children: [
                                // Cancel Button
                                ScaleTransition(
                                  scale: Tween<double>(begin: 0.5, end: 1.0)
                                      .animate(
                                    CurvedAnimation(
                                      parent: animation1,
                                      curve: Interval(0.4, 1.0,
                                          curve: Curves.elasticOut),
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Logout Button
                                ScaleTransition(
                                  scale: Tween<double>(begin: 0.5, end: 1.0)
                                      .animate(
                                    CurvedAnimation(
                                      parent: animation1,
                                      curve: Interval(0.4, 1.0,
                                          curve: Curves.elasticOut),
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await SharedPrefs.clearaLLlogins();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MyHomePage(),
                                        ),
                                      );
                                      postLogData("Logout", "Logout");
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: const Text(
                                      "Logout",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
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
                  ),
                ),
              );
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> departmentname(String departmentname) async {
    await SharedPrefs.departmentname(departmentname);
  }

  Future<void> departmentid(String departmentid) async {
    await SharedPrefs.departmentid(departmentid);
  }

  Future<void> salesloginrole(String salesloginrole) async {
    await SharedPrefs.salesloginrole(salesloginrole);
  }

  Future<void> commersialrole(String commersialrole) async {
    await SharedPrefs.commersialrole(commersialrole);
  }

  Future<void> saveloginname(String saveloginname) async {
    await SharedPrefs.saveloginname(saveloginname);
  }

  Future<void> salesloginno(String salesloginno) async {
    await SharedPrefs.salesloginno(salesloginno);
  }

  Future<void> saleslogiOrgwarehousename(
      String saleslogiOrgwarehousename) async {
    await SharedPrefs.saleslogiOrgwarehousename(saleslogiOrgwarehousename);
  }

// Function to build a Column with each container in a vertical layout
  Widget _buildColumn() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Responsive.isMobile(context)
          ? _buildGrid(crossAxisCount: 2, childAspectRatio: 1.3)
          : _buildGrid(crossAxisCount: 7, childAspectRatio: 1.6),
    );
  }

  Future<void> _handleRoleSelection(
      int index, String role, String roleID) async {
    print("Selected role: $role with ID: $roleID");

    await departmentname(labelsList[index]);
    await departmentid(roleID); // Use selected roleID

    if (role == "Sales Supervisor" || role == "Retail Sales Supervisor") {
      await commersialrole(role);
    } else {
      await salesloginrole(role);
    }

    postLogData("Role Dashboard", "Login with ${labelsList[index]}");

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation1, animation2) {
        Future.delayed(const Duration(seconds: 3), () async {
          await fetchAccessControl(roleID); // Use selected roleID
          await _onContainerClick(index);
          Navigator.of(context).pop();
        });
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation1,
          curve: Curves.easeInOutBack,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity:
                Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
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
                    Icon(Icons.check_circle,
                        size: 48, color: Colors.blue.shade700),
                    const SizedBox(height: 12),
                    Text(
                      "$role Login",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You are logging in with this role",
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await fetchAccessControl(roleID);
                        await _onContainerClick(index);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text("Continue"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 1), () async {
      await fetchAccessControl(roleID);
      await _onContainerClick(index);
      // Navigator.of(context).pop();
    });
  }

  Widget _buildGrid(
      {required int crossAxisCount, required double childAspectRatio}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: enabledStatus.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          // onTap: () async {
          //   if (enabledStatus[index]) {
          //     print(
          //         "on click function ${labelsList[index]}  ${lableRoleList[index]}");
          //     await departmentname(labelsList[index]);
          //     await departmentid(lableRoleIDList[index]);

          //     if (lableRoleList[index] == "Sales Supervisor" ||
          //         lableRoleList[index] == "Retail Sales Supervisor") {
          //       await commersialrole(lableRoleList[index]);
          //     } else {
          //       await salesloginrole(lableRoleList[index]);
          //     }
          //     postLogData("Role Dahsboard", "Login with ${labelsList[index]}");
          //     showGeneralDialog(
          //       context: context,
          //       barrierDismissible: false,
          //       barrierLabel: '',
          //       transitionDuration: const Duration(milliseconds: 400),
          //       pageBuilder: (context, animation1, animation2) {
          //         // Auto trigger the logic after 3 seconds
          //         Future.delayed(const Duration(seconds: 3), () async {
          //           await fetchAccessControl(lableRoleIDList[index]);
          //           await _onContainerClick(index);
          //           Navigator.of(context).pop();
          //         });

          //         return Container(); // Just return something empty for pageBuilder
          //       },
          //       transitionBuilder: (context, animation1, animation2, child) {
          //         final curvedAnimation = CurvedAnimation(
          //           parent: animation1,
          //           curve: Curves.easeInOutBack,
          //         );
          //         return ScaleTransition(
          //           scale: Tween<double>(begin: 0.5, end: 1.0)
          //               .animate(curvedAnimation),
          //           child: FadeTransition(
          //             opacity: Tween<double>(begin: 0.0, end: 1.0)
          //                 .animate(curvedAnimation),
          //             child: Dialog(
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(20),
          //               ),
          //               elevation: 0,
          //               backgroundColor: Colors.transparent,
          //               child: Container(
          //                 padding: const EdgeInsets.all(20),
          //                 decoration: BoxDecoration(
          //                   color: Colors.white,
          //                   borderRadius: BorderRadius.circular(10),
          //                   boxShadow: [
          //                     BoxShadow(
          //                       color: Colors.black.withOpacity(0.1),
          //                       blurRadius: 20,
          //                       offset: const Offset(0, 10),
          //                     ),
          //                   ],
          //                 ),
          //                 child: SingleChildScrollView(
          //                   scrollDirection: Axis.vertical,
          //                   child: Column(
          //                     mainAxisSize: MainAxisSize.min,
          //                     children: [
          //                       TweenAnimationBuilder(
          //                         duration: const Duration(milliseconds: 600),
          //                         tween: Tween<double>(begin: 0, end: 1),
          //                         builder: (context, double value, child) {
          //                           return Transform.scale(
          //                             scale: value,
          //                             child: Container(
          //                               padding: const EdgeInsets.all(16),
          //                               decoration: BoxDecoration(
          //                                 color: Colors.blue.withOpacity(0.1),
          //                                 shape: BoxShape.circle,
          //                               ),
          //                               child: Icon(
          //                                 Icons.check_circle_outline,
          //                                 size: 40,
          //                                 color: Colors.blue.shade700,
          //                               ),
          //                             ),
          //                           );
          //                         },
          //                       ),
          //                       const SizedBox(height: 20),
          //                       SlideTransition(
          //                         position: Tween<Offset>(
          //                           begin: const Offset(0, 0.5),
          //                           end: Offset.zero,
          //                         ).animate(curvedAnimation),
          //                         child: Text(
          //                           "${labelsList[index]} Login",
          //                           style: const TextStyle(
          //                             fontSize: 16,
          //                             fontWeight: FontWeight.bold,
          //                           ),
          //                         ),
          //                       ),
          //                       const SizedBox(height: 12),
          //                       SlideTransition(
          //                         position: Tween<Offset>(
          //                           begin: const Offset(0, 1),
          //                           end: Offset.zero,
          //                         ).animate(curvedAnimation),
          //                         child: Text(
          //                           "You are Login with this Department",
          //                           style: TextStyle(
          //                             fontSize: 13,
          //                             color: Colors.grey.shade600,
          //                           ),
          //                         ),
          //                       ),
          //                       const SizedBox(height: 24),
          //                       ScaleTransition(
          //                         scale: Tween<double>(begin: 0.5, end: 1.0)
          //                             .animate(
          //                           CurvedAnimation(
          //                             parent: animation1,
          //                             curve: const Interval(0.4, 1.0,
          //                                 curve: Curves.elasticOut),
          //                           ),
          //                         ),
          //                         child: ElevatedButton(
          //                           onPressed: () async {
          //                             await fetchAccessControl(
          //                                 lableRoleIDList[index]);
          //                             await _onContainerClick(index);
          //                             Navigator.of(context).pop();
          //                           },
          //                           style: ElevatedButton.styleFrom(
          //                             backgroundColor: Colors.blue.shade700,
          //                             foregroundColor: Colors.white,
          //                             padding: const EdgeInsets.symmetric(
          //                               horizontal: 40,
          //                               vertical: 16,
          //                             ),
          //                             shape: RoundedRectangleBorder(
          //                               borderRadius: BorderRadius.circular(30),
          //                             ),
          //                           ),
          //                           child: const Text(
          //                             "Continue",
          //                             style: TextStyle(
          //                               fontSize: 13,
          //                               fontWeight: FontWeight.w600,
          //                             ),
          //                           ),
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ),
          //         );
          //       },
          //     );
          //   }
          // },

          onTap: () async {
            if (!enabledStatus[index]) return;

            // Parse role names
            List<String> roles = lableRoleList[index]
                .split(',')
                .map((e) => e.trim())
                .where((role) => role.isNotEmpty)
                .toList();

            // Parse role IDs
            List<String> roleIDs = lableRoleIDList[index]
                .split(',')
                .map((e) => e.trim())
                .where((id) => id.isNotEmpty)
                .toList();

            // Ensure matching length
            int minLength =
                roles.length < roleIDs.length ? roles.length : roleIDs.length;
            if (minLength == 0) return;
            if (minLength == 1) {
              await _handleRoleSelection(
                index,
                roles[0],
                roleIDs[0],
              );
            } else {
              // Show dialog to choose role
              await showDialog(
                context: context,
                builder: (context) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: AlertDialog(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Select a Role",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: const Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      content: SizedBox(
                        width: 300,
                        child: GridView.builder(
                          shrinkWrap: true,
                          itemCount: minLength,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // two-column layout
                            childAspectRatio: 3, // button height vs width
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, roleIndex) {
                            return ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context)
                                    .pop(); // Close role selection dialog
                                await _handleRoleSelection(
                                  index,
                                  roles[roleIndex],
                                  roleIDs[roleIndex],
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                roles[roleIndex],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
          child: MouseRegion(
            cursor: enabledStatus[index]
                ? SystemMouseCursors.click
                : SystemMouseCursors.forbidden,
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color:
                    enabledStatus[index] ? Colors.white : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: enabledStatus[index]
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
                border: Border.all(
                  color: enabledStatus[index]
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  if (enabledStatus[index])
                    Positioned(
                      right: -10,
                      top: -10,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: enabledStatus[index]
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.asset(
                                imagePaths[index % imagePaths.length],
                                height: 24,
                                width: 24,
                                color: enabledStatus[index]
                                    ? Colors.blue.shade700
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              labelsList[index],
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: enabledStatus[index]
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                            if (lableRoleList[index].isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                lableRoleList[index],
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: enabledStatus[index]
                                      ? Colors.blue.shade700
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (enabledStatus[index])
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: Colors.blue.shade700,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
