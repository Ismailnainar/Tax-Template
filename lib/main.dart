import 'package:network_info_plus/network_info_plus.dart';
import 'dart:convert';
import 'package:aljeflutterapp/cacheupdate.date/services/version_service.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:aljeflutterapp/cacheupdate.date/browser_functions.dart'
    if (dart.library.html) 'package:aljeflutterapp/cacheupdate.date/web_browser_functions.dart';

import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/dispatch/Commersial_Form.dart';
import 'package:aljeflutterapp/mainsidebar/adminsidebar.dart';
import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:aljeflutterapp/welcomedashboard.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Get the current app version from pubspec.yaml
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String currentVersion = packageInfo.version;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("ALJE_App_PubVersion", currentVersion);
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // attach the key here

      debugShowCheckedModeBanner: false,
      title: 'TrackLoad',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
        fontFamily: 'Montserrat',
      ),
      builder: (context, child) {
        return CookieConsentWrapper(
          child: VersionDialogWrapper(
            child: child ?? Container(),
          ),
        );
      },
      home: splashscreen(),
    );
  }
}

class CookieConsentWrapper extends StatefulWidget {
  final Widget child;

  const CookieConsentWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<CookieConsentWrapper> createState() => _CookieConsentWrapperState();
}

class _CookieConsentWrapperState extends State<CookieConsentWrapper> {
  bool _showBanner = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      clearBrowserHistory();
      addBrowserHistory();
      initializeWebHistory();
      enableBrowserHistory();
    }
    _checkCookieConsent();
  }

  Future<void> _checkCookieConsent() async {
    final prefs = await SharedPreferences.getInstance();
    final hasConsent = prefs.getBool('ALJE_cookie_consent') ?? false;

    String? browserCookie;
    if (kIsWeb) {
      browserCookie = getBrowserCookie('ALJE_cookie_consent');
    }

    setState(() {
      _showBanner = !(hasConsent || browserCookie == 'true');
    });
  }

  Future<void> _acceptCookies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ALJE_cookie_consent', true);

    if (kIsWeb) {
      setBrowserCookie('ALJE_cookie_consent', 'true', 365);
      enableBrowserHistory();
    }

    setState(() {
      _showBanner = false;
    });
  }

  Future<void> _declineCookies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ALJE_cookie_consent', false);

    if (kIsWeb) {
      setBrowserCookie('ALJE_cookie_consent', 'false', 365);
      clearWebStorageAndHistory();
    }

    setState(() {
      _showBanner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          if (_showBanner)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.85),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.cookie_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'We Value Your Privacy',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'We use cookies to improve your browsing experience, analyze site traffic, and personalize content. By continuing to use this website, you consent to our use of cookies.',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _declineCookies,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                              child: Text(
                                'Decline',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _acceptCookies,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                'Accept All',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }
}

class splashscreen extends StatefulWidget {
  const splashscreen({super.key});

  @override
  State<splashscreen> createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen>
    with SingleTickerProviderStateMixin {
  String shopNames = '';
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  List<String> accessControl = [];
  List<dynamic> accessControlList = [];

  @override
  void initState() {
    super.initState();
    _loadShopName();
    fetchAccessControl();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> salesloginrole(String salesloginrole) async {
    await SharedPrefs.salesloginrole(salesloginrole);
  }

  Future<void> salesloginNo(String salesloginno) async {
    await SharedPrefs.salesloginno(salesloginno);
  }

  Future<void> saveloginName(String saveloginname) async {
    await SharedPrefs.saveloginname(saveloginname);
  }

  Future<void> saleslogiorgid(String saleslogiOrgid) async {
    await SharedPrefs.saleslogiOrgid(saleslogiOrgid);
  }

  Future<void> _loadShopName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Timer(Duration(seconds: 3), () {
      String? saveloginname = prefs.getString('saveloginname');
      String? commersialname = prefs.getString('commersialname');
      bool isLoggedIn = ((saveloginname != null && saveloginname.isNotEmpty) ||
          (commersialname != null && commersialname.isNotEmpty));

      print("salesman name $saveloginname and commertrial $commersialname");
      navigateBasedOnRole(context, isLoggedIn);
    });
  }

  Future<List<String>> fetchAccessControl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lableRoleIDList = prefs.getString('departmentid');
    String? salesloginnoStr = prefs.getString('salesloginno');

    String? commersialno = prefs.getString('commersialno');
    String? commersialrole = prefs.getString('commersialrole');

    final IpAddress = await getActiveIpAddress();

    final String url = commersialrole == null
        ? "$IpAddress/New_Updated_get_submenu_list/$lableRoleIDList/$salesloginnoStr/"
        : "$IpAddress/New_Updated_get_submenu_depid_list/$lableRoleIDList/$commersialno/";

    print("Fetching submenu list from: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('submenu')) {
          accessControl = List<String>.from(data['submenu']);
        }

        print("Fetched accessControl: $accessControl");
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching submenu list: $e");
    }

    return accessControl;
  }

  void navigateBasedOnRole(BuildContext context, bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (isLoggedIn) {
      String? department = prefs.getString('departmentname');
      String? role = prefs.getString('salesloginrole');
      String? commersialrole = prefs.getString('commersialrole');
      print("sommersial role  $commersialrole");

      if (department == null && role != "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomeDashboard(
              emailController: TextEditingController(),
            ),
          ),
        );
      } else if (role == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminSidebar(),
          ),
        );
      } else if (commersialrole == "Sales Supervisor" ||
          commersialrole == "Retail Sales Supervisor") {
        if (role != null && role.isNotEmpty) {
          print("Access control $accessControl");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainSidebar(enabledItems: accessControl),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Commersial_Form()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainSidebar(enabledItems: accessControl),
          ),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: BackgroundPatternPainter(),
              ),
            ),
            // Main Content
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with Scale Animation
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: Responsive.isMobile(context)
                            ? EdgeInsets.all(30)
                            : EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          "assets/images/logo.jpg",
                          height: Responsive.isMobile(context) ? 100 : 200.0,
                          width: Responsive.isMobile(context) ? 100 : 200.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Shop Name with Fade and Slide Animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Text(
                          shopNames,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                    letterSpacing: 1.2,
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Loading Indicator with Custom Animation
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                        strokeWidth: 3,
                        backgroundColor: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for Background Pattern
class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    const spacing = 30.0;
    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(
          Offset(i, j),
          2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();

  static const bool isReviewMode = bool.fromEnvironment('REVIEWMODE');
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode loginButtonFocusNode = FocusNode();

  FocusNode newpasswordFocusNode = FocusNode();
  FocusNode confirmedpasswordFocusNode = FocusNode();

  FocusNode resetpasswordbuttonfocusnode = FocusNode();

  bool _obscureText = true;

  bool isProcessing = false; // Track if login is in progress

  @override
  void initState() {
    super.initState();
    loadConnections().then((loadedConnections) {
      setState(() {
        databaseConnections = loadedConnections;
      });
    });

    // _initializeSalesLogin();
    // manuallySaveConnections();
    if (isReviewMode) {
      _usernameController.text = '200220';
      _passwordController.text = '12345';
    }
    _checkCookieConsent();
  }

  @override
  void dispose() {
    usernameFocusNode.dispose();
    passwordFocusNode.dispose();
    loginButtonFocusNode.dispose();
    super.dispose();
  }

  Future<void> _validateAndLogin() async {
    final TestingOracleIpAddress = await getActiveOracleIpAddress();
    print('TestingOracleIpAddress:$TestingOracleIpAddress');
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() => isProcessing = true);

      final connections = await loadConnections();
      final activeConnections =
          connections.where((conn) => conn['status'] == 'Active').toList();

      if (activeConnections.isEmpty) {
        showErrorMessage(context,
            'No active API-IP connections found. Kindly Enter a API IP .');
        return;
      }

      final username = _usernameController.text.trim().toLowerCase();
      final password = _passwordController.text;
      final ipAddress = activeConnections.first['endpoint'];
      print('IpAddress: $ipAddress');
      final TestingOracleIpAddress = await getActiveOracleIpAddress();

      print('TestingOracleIpAddress: $TestingOracleIpAddress');

      String apiUrl = '$ipAddress/User_member_details/';
      bool usernameExists = false;

      while (apiUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode != 200) {
          showErrorMessage(context, "Server error. Please try again later.");
          return;
        }

        final data = json.decode(response.body);

        if (data['results'] == null || data['results'].isEmpty) {
          showErrorMessage(
              context, "No user data found.\nKindly contact support.");
          break;
        }

        for (var user in data['results']) {
          final apiUsername = user['EMP_USERNAME']?.trim().toLowerCase();
          final apiPassword = user['EMP_PASSWORD'];
          final apiRole = user['EMP_ROLE'] ?? '';

          if (apiUsername == username && apiPassword == password) {
            usernameExists = true;

            if (apiRole == 'Sales Supervisor' ||
                apiRole == 'Retail Sales Supervisor') {
              await commersialname(user['EMP_NAME']);
              await commersialno(user['EMPLOYEE_ID']);
              await saleslogiOrgwarehousename(user['PHYSICAL_WAREHOUSE']);
            } else {
              await saveloginName(user['EMP_NAME']);
              await salesloginNo(user['EMPLOYEE_ID']);
              if (username == 'admin') {
                await salesloginrole(apiRole);
              }
              await saleslogiorgid(user['ORG_ID']);

              await saleslogiOrgwarehousename(user['PHYSICAL_WAREHOUSE']);
            }

            await successfullyLoginMessage(apiRole);
            return;
          }
        }

        apiUrl = data['next'] ?? '';
      }

      if (!usernameExists) {
        showErrorMessage(context, "Incorrect username or password.");
      }
    } catch (error) {
      print("Login Error: $error");
      showErrorMessage(
          context, "Kindly check your internet connection or API IP.");
    } finally {
      setState(() => isProcessing = false);
    }
  }

// Unified error message display
  void showErrorMessage(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            Icons.warning,
            color: Colors.black,
          ),
          SizedBox(
            width: 15,
          ),
          Text(message, style: TextStyle(fontSize: 13, color: Colors.black)),
        ],
      ),
      duration: Duration(seconds: 3),
      backgroundColor: Colors.yellow,
      behavior: SnackBarBehavior.floating,
      margin: Responsive.isDesktop(context)
          ? EdgeInsets.only(top: 10, left: 300, right: 300)
          : EdgeInsets.only(top: 10, left: 10, right: 10),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> commersialno(String commersialno) async {
    await SharedPrefs.commersialno(commersialno);
  }

  Future<void> commersialname(String commersialname) async {
    await SharedPrefs.commersialname(commersialname);
  }

  Future<void> commersialrole(String commersialrole) async {
    await SharedPrefs.commersialrole(commersialrole);
  }

  Future<void> salesloginrole(String salesloginrole) async {
    await SharedPrefs.salesloginrole(salesloginrole);
  }

  Future<void> salesloginNo(String salesloginno) async {
    await SharedPrefs.salesloginno(salesloginno);
  }

  Future<void> saveloginName(String saveloginname) async {
    await SharedPrefs.saveloginname(saveloginname);
  }

  Future<void> saleslogiorgid(String saleslogiOrgid) async {
    await SharedPrefs.saleslogiOrgid(saleslogiOrgid);
  }

  Future<void> saleslogiOrgwarehousename(
      String saleslogiOrgwarehousename) async {
    await SharedPrefs.saleslogiOrgwarehousename(saleslogiOrgwarehousename);
  }

  Future<void> successfullyLoginMessage(role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginrole = prefs.getString('salesloginrole');

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Container(
                      height: 300,
                      width: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Success Animation
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                FadeInUp(
                                  from: 30,
                                  delay: Duration(milliseconds: 500),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 80,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          FadeInUp(
                            from: 30,
                            delay: Duration(milliseconds: 600),
                            child: Text(
                              'Welcome Back!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          FadeInUp(
                            from: 30,
                            delay: Duration(milliseconds: 700),
                            child: Text(
                              'Login Successful',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          FadeInUp(
                            from: 30,
                            delay: Duration(milliseconds: 800),
                            child: Text(
                              role == 'admin'
                                  ? 'Admin Access Granted'
                                  : 'User Access Granted',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          FadeInUp(
                            from: 30,
                            delay: Duration(milliseconds: 900),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                if (role == 'admin') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AdminSidebar()),
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WelcomeDashboard(
                                          emailController: _usernameController),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 12),
                              ),
                              child: Text(
                                'Continue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return Container(); // Not used but required
      },
    );
  }

  Future<void> successfullyLoginMessageforcommersial(role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginrole = prefs.getString('salesloginrole');
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
              Column(
                children: [
                  Text(
                    ' Login Successfully !!',
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                  Text(
                    '$role',
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Commersial_Form()),
      );
    });
  }

  // void showErrorMessage(String s) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         content: Row(
  //           children: [
  //             IconButton(
  //               icon: const Icon(Icons.warning, color: Colors.yellow),
  //               onPressed: () => Navigator.of(context).pop(false),
  //             ),
  //             Expanded(
  //               child: Text(
  //                 '$s',
  //                 style: TextStyle(fontSize: 15, color: Colors.black),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // Future<void> _initializeSalesLogin() async {
  //   String saleslogiOrgid = "101";
  //   String salesloginno = "2006622";
  //   String salesloginroleValue = "admin"; // Renamed the variable
  //   String saveloginname = "MINHAJ UDDIN MOHAMMED";

  //   await saleslogiorgid(saleslogiOrgid);
  //   await salesloginNo(salesloginno);
  //   await saveloginName(saveloginname);
  //   await salesloginrole(
  //       salesloginroleValue); // Call using the renamed variable
  // }

  bool _showBanner = true;

  Future<void> _checkCookieConsent() async {
    final prefs = await SharedPreferences.getInstance();
    final hasConsent = prefs.getBool('ALJE_cookie_consent') ?? false;

    // Only check browser cookie if on web platform
    final browserCookie =
        kIsWeb ? getBrowserCookie('ALJE_cookie_consent') : null;

    setState(() {
      _showBanner = !(hasConsent || browserCookie == 'true');
    });
  }

  Future<void> _acceptCookies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ALJE_cookie_consent', true);

    if (kIsWeb) {
      setBrowserCookie('ALJE_cookie_consent', 'true', 365);
      enableBrowserHistory();
    }

    setState(() {
      _showBanner = false;
    });
  }

  Future<void> _declineCookies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ALJE_cookie_consent', false);

    if (kIsWeb) {
      setBrowserCookie('ALJE_cookie_consent', 'false', 365);
      clearWebStorageAndHistory();
    }

    setState(() {
      _showBanner = false;
    });
  }

  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  String confirmPasswordError = '';
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  TextEditingController _IdControllerontroller = TextEditingController();

  TextEditingController _UserpasswordControllerontroller =
      TextEditingController();
  // final String apiUrl = 'User_member_details/';
  String errorMessage = '';

  // Future<void> fetchUserId() async {
  //   final IpAddress = await getActiveIpAddress();

  //   String? url = '$IpAddress/User_member_details/';
  //   List<dynamic> allResults = [];

  //   try {
  //     while (url != null) {
  //       print("Fetching data from: $url");
  //       final response = await http.get(Uri.parse(url));

  //       if (response.statusCode == 200) {
  //         final data = jsonDecode(response.body);
  //         allResults.addAll(data['results']); // Collect data from each page
  //         url = data['next']; // Get next page URL
  //       } else {
  //         print(
  //             'Failed to fetch user data. Status code: ${response.statusCode}');
  //         return;
  //       }
  //     }

  //     // Find the user with the matching Employee ID
  //     final matchingUser = allResults.firstWhere(
  //       (user) => user['EMPLOYEE_ID'] == _usernameController.text,
  //       orElse: () => null,
  //     );

  //     if (matchingUser != null) {
  //       final userId =
  //           matchingUser['id'].toString(); // Convert to string if necessary
  //       final userpassord = matchingUser['EMP_PASSWORD'].toString();
  //       _IdControllerontroller.text = userId;
  //       _UserpasswordControllerontroller.text = userpassord;
  //       print(
  //           "id controller ${_IdControllerontroller.text}  ${_UserpasswordControllerontroller.text}");

  //       // ScaffoldMessenger.of(context).showSnackBar(
  //       //   SnackBar(content: Text('User ID fetched successfully: $userId')),
  //       // );
  //     } else {
  //       print('Employee ID not found.');
  //     }
  //   } catch (e) {
  //     print('Error fetching user ID: $e');
  //   }
  // }

  Future<void> fetchUserId() async {
    final IpAddress = await getActiveIpAddress();
    String username = _usernameController.text.trim();
    try {
      final String baseUrl = "$IpAddress/get-employee-details/";
      final Uri url = Uri.parse("$baseUrl?username=$username");

      print("Fetching user details from: $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data != null && data.isNotEmpty) {
          // Assuming API returns a list or single object with fields
          final user = (data is List && data.isNotEmpty) ? data[0] : data;

          final userId = user['id'].toString();
          final userPassword = user['EMP_PASSWORD'].toString();

          _IdControllerontroller.text = userId;
          _UserpasswordControllerontroller.text = userPassword;

          print("Fetched User ID: $userId");
          print("Fetched Password: $userPassword");

          print(
              "geted userame ${_UserpasswordControllerontroller.text}    ${_passwordController.text}");

          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('User details fetched successfully')),
          // );
        } else {
          print("No data found for this username.");
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text('No user found for this Employee ID')),
          // );
        }
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //       content: Text(
        //           'Failed to fetch user data. Code: ${response.statusCode}')),
        // );
      }
    } catch (e) {
      print("Error fetching user details: $e");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error: $e')),
      // );
    }
  }

  String _macAddress = "Unknown";

  Future<void> _getMacAddress() async {
    final info = NetworkInfo();
    String? mac;

    try {
      mac = await info.getWifiBSSID(); // or getWifiIP() for IP
    } catch (e) {
      mac = "Failed to get MAC: $e";
    }

    setState(() {
      _macAddress = mac ?? "Unavailable";
    });
  }

  Future<void> saveLoginDetails({
    required String loginId,
    required String loginName,
    required String loginMacAddress,
  }) async {
    final IpAddress = await getActiveIpAddress();
    final url = Uri.parse("$IpAddress/save-login-details/");
    // ⬆️ Replace with your server IP when running on mobile (e.g., http://192.168.10.115:8000/save-login/)

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "LOGIN_ID": loginId,
          "LOGIN_NAME": loginName,
          "LOGIN_MAC_ADDRESS": loginMacAddress,
        }),
      );

      if (response.statusCode == 201) {
        print("✅ Saved Successfully: ${response.body}");
      } else {
        print("❌ Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("⚠️ Exception: $e");
    }
  }

  Future<void> _handleLoginAttempt(BuildContext context) async {
    await fetchUserId();
    String cleanUserPass = _UserpasswordControllerontroller.text
        .replaceAll(RegExp(r'\s+'), '') // remove all whitespace
        .replaceAll(
            RegExp(r'[^\x20-\x7E]'), ''); // remove hidden non-printables

    String cleanPass = _passwordController.text
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^\x20-\x7E]'), '');

// Debug prints
    print(
        "_UserpasswordController (raw): '${_UserpasswordControllerontroller.text}'");
    print("_passwordController (raw): '${_passwordController.text}'");
    print("cleanUserPass: '$cleanUserPass'");
    print("cleanPass: '$cleanPass'");
    print("cleanUserPass codeUnits: ${cleanUserPass.codeUnits}");
    print("cleanPass codeUnits: ${cleanPass.codeUnits}");

// Now compare against "1234"
    bool resetBoolean = (cleanUserPass == "1234" && cleanPass == "1234");
    bool myPassResetBoolean = (cleanPass == "1234");

    print(
        "resetBoolean: $resetBoolean, myPassResetBoolean: $myPassResetBoolean");
    if (_usernameController.text.trim() == 'admin') {
      print("Admin login detected");
      await _validateAndLogin();
    } else if (resetBoolean) {
      print("Both matched 1234 → showing forgot-password dialog");
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showForgotPasswordDialog(context);
      });
    } else {
      print("Proceeding with normal login flow");
      await _validateAndLogin();
      // Uncomment these if you need them:
      // await _getMacAddress();
      // await saveLoginDetails(
      //   loginId: _usernameController.text,
      //   loginName: _usernameController.text,
      //   loginMacAddress: _macAddress,
      // );
      await postLogData("Login", "Login with ${_usernameController.text}");
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = "22-November-2025";

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
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
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
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
                child: Row(
                  children: [
                    if (screenWidth > 900) ...[
                      // Left side - Image and welcome text (only shown on larger screens)
                      Expanded(
                        child: FadeInLeft(
                          duration: Duration(milliseconds: 1000),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/login_illustration1.png', // Add this image to assets
                                  height: screenHeight * 0.5,
                                ),
                                SizedBox(height: 40),
                                Text(
                                  'Welcome Back!',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Login to access your account and manage your work efficiently',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Right side - Login form
                    Expanded(
                      child: FadeInRight(
                        duration: Duration(milliseconds: 1000),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth > 900 ? 80 : 20,
                            vertical: 20,
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Logo
                                BounceInDown(
                                  duration: Duration(milliseconds: 1500),
                                  child: Image.asset(
                                    'assets/images/logo.jpg',
                                    height: 100,
                                  ),
                                ),
                                SizedBox(height: 40),

                                // Login Form
                                Form(
                                  key: _formKey,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Column(
                                      children: [
                                        // Username Field
                                        FadeInUp(
                                          delay: Duration(milliseconds: 400),
                                          child: TextFormField(
                                            controller: _usernameController,
                                            focusNode: usernameFocusNode,
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      passwordFocusNode);
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'Username',
                                              prefixIcon: Icon(Icons.person,
                                                  color: Colors.blue),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.blue.shade200),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.blue.shade200),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                    color: Colors.blue,
                                                    width: 2),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter your username';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 20),

                                        // Password Field
                                        FadeInUp(
                                          delay: Duration(milliseconds: 600),
                                          child: TextFormField(
                                            controller: _passwordController,
                                            focusNode: passwordFocusNode,
                                            obscureText: _obscureText,
                                            textInputAction:
                                                TextInputAction.done,
                                            // inside Password field onFieldSubmitted
                                            onFieldSubmitted: (_) async {
                                              await _handleLoginAttempt(
                                                  context);
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'Password',
                                              prefixIcon: Icon(Icons.lock,
                                                  color: Colors.blue),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureText
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureText =
                                                        !_obscureText;
                                                  });
                                                },
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.blue.shade200),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.blue.shade200),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                    color: Colors.blue,
                                                    width: 2),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter your password';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),

                                        SizedBox(height: 30),

                                        // Login Button
                                        FadeInUp(
                                          delay: Duration(milliseconds: 800),
                                          child: Container(
                                            width: double.infinity,
                                            height: 55,
                                            child: ElevatedButton(
                                              focusNode: loginButtonFocusNode,
                                              // onPressed: isProcessing
                                              //     ? null
                                              //     : () async {
                                              //         // await fetchUserId();
                                              //         // print(
                                              //         //     "_UserpasswordControllerontroller ${_UserpasswordControllerontroller.text}    ${_passwordController.text}");

                                              //         // if (_usernameController
                                              //         //         .text ==
                                              //         //     'admin') {
                                              //         //   print(
                                              //         //       "username controller ${_usernameController.text}");
                                              //         //   _validateAndLogin();
                                              //         // } else if (_UserpasswordControllerontroller
                                              //         //             .text ==
                                              //         //         '1234' &&
                                              //         //     _passwordController
                                              //         //             .text ==
                                              //         //         '1234') {
                                              //         //   print(
                                              //         //       "_UserpasswordControllerontroller controller ${_UserpasswordControllerontroller.text}");
                                              //         //   if (_formKey
                                              //         //           .currentState
                                              //         //           ?.validate() ??
                                              //         //       false) {
                                              //         //     showForgotPasswordDialog(
                                              //         //         context);
                                              //         //   }
                                              //         // } else {
                                              //         //   print(
                                              //         //       "login validations");

                                              //         //   // Proceed with login logic
                                              //         //   await _validateAndLogin();
                                              //         //   await _getMacAddress();
                                              //         //   await saveLoginDetails(
                                              //         //     loginId:
                                              //         //         _usernameController
                                              //         //             .text,
                                              //         //     loginName:
                                              //         //         _usernameController
                                              //         //             .text,
                                              //         //     loginMacAddress:
                                              //         //         _macAddress,
                                              //         //   );
                                              //         //   await postLogData(
                                              //         //       "Login",
                                              //         //       "Login with ${_usernameController.text}");
                                              //         // }

                                              //         await fetchUserId();

                                              //         print(
                                              //             "_UserpasswordController ${_UserpasswordControllerontroller.text}   _passwordController ${_passwordController.text}");

                                              //         if (_usernameController
                                              //                 .text ==
                                              //             'admin') {
                                              //           // Admin case
                                              //           print(
                                              //               "username controller ${_usernameController.text}");
                                              //           _validateAndLogin();
                                              //         } else if (_UserpasswordControllerontroller
                                              //                     .text
                                              //                     .trim() ==
                                              //                 '1234' &&
                                              //             _passwordController
                                              //                     .text
                                              //                     .trim() ==
                                              //                 '1234') {
                                              //           // Special case → Forgot password
                                              //           print(
                                              //               "_UserpasswordController ${_UserpasswordControllerontroller.text} and _passwordController ${_passwordController.text} matched 1234");

                                              //           // ✅ Always show dialog, don’t depend on validator here
                                              //           showForgotPasswordDialog(
                                              //               context);
                                              //         } else {
                                              //           // Normal login flow
                                              //           print(
                                              //               "Proceeding with login validations");

                                              //           await _validateAndLogin();
                                              //           await _getMacAddress();
                                              //           await saveLoginDetails(
                                              //             loginId:
                                              //                 _usernameController
                                              //                     .text,
                                              //             loginName:
                                              //                 _usernameController
                                              //                     .text,
                                              //             loginMacAddress:
                                              //                 _macAddress,
                                              //           );
                                              //           await postLogData(
                                              //               "Login",
                                              //               "Login with ${_usernameController.text}");
                                              //         }
                                              //       },

                                              onPressed: isProcessing
                                                  ? null
                                                  : () async {
                                                      await _handleLoginAttempt(
                                                          context);
                                                    },

                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                elevation: 5,
                                              ),
                                              child: isProcessing
                                                  ? SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : Text(
                                                      'Login',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: 20),

                                        // Password Reset Info
                                        FadeInUp(
                                          delay: Duration(milliseconds: 1000),
                                          child: Text(
                                            "If you've forgotten your password, Contact 'Admin' to reset password.",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(height: 20),

                                        // Password Reset Info
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              apiIpController.clear();
                                              oracleIpController.clear();
                                              descriptionController.clear();
                                            });
                                            _showDatabaseSetupDialog(context);
                                            // fetchConnectNames();

                                            postLogData(
                                                "Login Page Database Connection",
                                                "Opened");
                                          },
                                          child: FadeInUp(
                                            delay: Duration(milliseconds: 1000),
                                            child: Text(
                                              "Current $Version - Releasae Date $formattedDate",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> databaseConnections = [];

// 2. Update your save and load methods to handle dynamic values

// Your saveConnections function
  Future<void> saveConnections(List<Map<String, dynamic>> connections) async {
    final prefs = await SharedPreferences.getInstance();

    final connectionsToSave = connections.map((conn) {
      return {
        'name': conn['name'] ?? '',
        'endpoint': conn['endpoint'] ?? '',
        'oracleEndpoint': conn['oracleEndpoint'] ?? '',
        'status': conn['status'] ?? 'Inactive',
      };
    }).toList();

    prefs.setString('database_connections', jsonEncode(connectionsToSave));
  }

// Manual save
  Future<void> manuallySaveConnections() async {
    final connections = [
      {
        "name": "Production",
        // "endpoint": "http://192.168.10.110:8001",
        // "oracleEndpoint": "http://192.168.10.110:8001",

        "endpoint": 'http://aljebapp.alj.com:8004',
        "oracleEndpoint": 'http://aljebapp.alj.com:8010',
        "status": "Active",
        "endpointVerified": true,
        "oracleEndpointVerified": false,
      }
    ];

    await saveConnections(connections);
  }

  Future<List<Map<String, dynamic>>> loadConnections() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('database_connections');

    if (jsonStr != null) {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((e) {
        return {
          'name': e['name'] ?? '',
          'endpoint': e['endpoint'] ?? '',
          'oracleEndpoint': e['oracleEndpoint'] ?? '',
          'status': e['status'] ?? 'Inactive',
        };
      }).toList();
    }

    return [];
  }

  final apiIpController = TextEditingController();
  final oracleIpController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _editingConnection;
  bool isTrackloadApiValid = false;
  bool isOracleApiValid = false;

  bool isOracleValidating = false;
  bool isAPIValidating = false;

  final FocusNode _dropdownFocusNode = FocusNode();
  int? _selectedIndex;
  int? _hoveredIndex;
  bool _filterEnabled = false;
  String? selectedvalue;
  final TextStyle dropdownTextStyle = TextStyle(fontSize: 13);

  List<String> connectNames = [
    'Test',
    'Production',
    'Buyp',
  ];
  String? selectedConnectName;
  bool isLoading = true;
  // Future<void> fetchConnectNames() async {
  //   final url = Uri.parse('http://192.168.10.110:8005/login-connect/');

  //   try {
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);

  //       setState(() {
  //         connectNames = data
  //             .map<String>((item) => item['CONNECT_NAME'].toString())
  //             .toList();
  //         if (connectNames.isNotEmpty) {
  //           selectedConnectName = connectNames[0];
  //         }
  //         isLoading = false;
  //       });
  //       print("connection name $connectNames");
  //     } else {
  //       print('Failed to load data. Status Code: ${response.statusCode}');
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  Future<void> fetchApiAndOracleIPs() async {
    if (descriptionController.text.trim() == "Test") {
      print("Your select Test");
      setState(() {
        apiIpController.text = 'http://aljewitpc1.alj.com:8010';
        oracleIpController.text = 'http://aljewitpc1.alj.com:8010';
      });
    } else if (descriptionController.text.trim() == "Production") {
      setState(() {
        apiIpController.text = 'http://aljebapp.alj.com:8004';
        oracleIpController.text = 'http://aljebapp.alj.com:8010';
      });
    } else if (descriptionController.text.trim() == "Buyp") {
      setState(() {
        // apiIpController.text = 'https://alje.manmakers.in';
        // oracleIpController.text = 'https://alje.manmakers.in';

        // apiIpController.text = 'http://13.201.201.93:8000';
        // oracleIpController.text = 'http://13.201.201.93:8000';

        apiIpController.text = 'http://192.168.10.162:9015';
        oracleIpController.text = 'http://192.168.10.162:9015';
      });
    } else {
      print('No matching description found.');
    }
  }

  Widget ConnectionNameDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Connection Name',
        labelStyle: TextStyle(fontSize: 12),
        hintText: 'e.g., Production DB Server',
        prefixIcon: Icon(
          Icons.storage,
          size: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      value: selectedvalue, // Use a variable to hold the selected value
      onChanged: (String? newValue) {
        setState(() {
          selectedvalue = newValue;
          descriptionController.text = newValue ?? '';
          _filterEnabled = false;
        });
        fetchApiAndOracleIPs().then((_) {
          handleSave(context);
        }).catchError((e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        });

        postLogData("Login Page Database Connection",
            "Set Connection ${descriptionController.text}");
      },
      items: connectNames.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: TextStyle(fontSize: 13)),
        );
      }).toList(),
    );
  }

  void _showDatabaseSetupDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      barrierDismissible: true,
      barrierLabel: 'Database Setup',
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (_, __, ___) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutBack,
        );

        return StatefulBuilder(builder: (context, setState) {
          bool _initialized = false;

          if (!_initialized && databaseConnections.isEmpty) {
            _initialized = true;
            loadConnections().then((loaded) {
              setState(() {
                databaseConnections = loaded;

                // Load active connection to text fields
                final active = databaseConnections.firstWhere(
                  (conn) => conn['status'] == 'Active',
                  orElse: () => {},
                );
                if (active.isNotEmpty) {
                  if (active.containsKey('endpoint')) {
                    apiIpController.text = active['endpoint']!;
                  } else {
                    apiIpController.text = '';
                  }

                  if (active.containsKey('name')) {
                    descriptionController.text = active['name']!;
                  } else {
                    descriptionController.text = '';
                  }
                }
              });
            });
          }

          return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.1),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: curvedAnimation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
                    ),
                  ),
                  child: StatefulBuilder(builder: (context, SetState) {
                    return Dialog(
                      elevation: 16,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      insetPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 40),
                      backgroundColor: Colors.white,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header with animated gradientss
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(24)),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade700,
                                      Colors.blueAccent.shade400
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          icon: Icon(Icons.close,
                                              color: Colors.white, size: 20),
                                        ),
                                      ],
                                    ),
                                    Image.asset(
                                      'assets/images/database.png',
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Database Instance',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Configure your database connections',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                          ),
                                    ),
                                  ],
                                ),
                              ),

                              // Form content
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Form(
                                  key: formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Existing connections table
                                      _buildConnectionsTable(
                                          context, databaseConnections),
                                      const SizedBox(height: 24),

                                      // Divider with animation
                                      SizeTransition(
                                        sizeFactor: CurvedAnimation(
                                          parent: animation,
                                          curve: const Interval(0.6, 1.0),
                                        ),
                                        child: Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: Colors.grey.shade300),
                                      ),
                                      Container(
                                          child: ConnectionNameDropdown()),
                                      const SizedBox(height: 16),
                                      // Form fields
                                      AnimatedOpacity(
                                        opacity: animation.value,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        child: Column(
                                          children: [
                                            LayoutBuilder(
                                              builder: (context, constraints) {
                                                final isMobile =
                                                    constraints.maxWidth < 500;

                                                if (isMobile) {
                                                  // Mobile: Fields one below the other
                                                  return Column(
                                                    children: [
                                                      TextFormField(
                                                        controller:
                                                            apiIpController,
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            isTrackloadApiValid =
                                                                false;
                                                            return 'Kindly enter Trackload API IP';
                                                          }

                                                          return null;
                                                        },
                                                        onChanged:
                                                            (value) async {
                                                          if (value.isEmpty) {
                                                            isTrackloadApiValid =
                                                                false;
                                                            isAPIValidating =
                                                                false;
                                                            setState(() {});
                                                            return;
                                                          }

                                                          isAPIValidating =
                                                              true;
                                                          setState(() {});

                                                          final isValid =
                                                              await isJsonResponse(
                                                                  value);

                                                          if (apiIpController
                                                                  .text ==
                                                              value) {
                                                            isTrackloadApiValid =
                                                                isValid;
                                                            isAPIValidating =
                                                                false;
                                                            setState(() {});
                                                          }
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              'Trackload IP',
                                                          labelStyle: TextStyle(
                                                              fontSize: 11),
                                                          hintText:
                                                              'e.g., http://trackloadapi.example.com/',
                                                          hintStyle: TextStyle(
                                                              fontSize: 11),
                                                          prefixIcon:
                                                              const Icon(
                                                                  Icons.http),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          suffixIcon: Icon(
                                                            Icons.verified,
                                                            color: Colors.green,
                                                            size: 18,
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              Colors.grey[50],
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 14),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .blue
                                                                    .shade400,
                                                                width: 2),
                                                          ),
                                                        ),
                                                        keyboardType:
                                                            TextInputType.url,
                                                        style: TextStyle(
                                                            fontSize: 13),
                                                      ),
                                                      const SizedBox(
                                                          height: 16),
                                                      TextFormField(
                                                        controller:
                                                            oracleIpController,
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            isOracleApiValid =
                                                                false;
                                                            return 'Kindly enter Oracle IP';
                                                          }

                                                          return null;
                                                        },
                                                        onChanged:
                                                            (value) async {
                                                          if (value.isEmpty) {
                                                            isOracleApiValid =
                                                                false;
                                                            isOracleValidating =
                                                                false;
                                                            setState(() {});
                                                            return;
                                                          }

                                                          isOracleValidating =
                                                              true;
                                                          setState(() {});

                                                          final isValid =
                                                              await isJsonResponse(
                                                                  value);

                                                          if (oracleIpController
                                                                  .text ==
                                                              value) {
                                                            isOracleApiValid =
                                                                isValid;
                                                            isOracleValidating =
                                                                false;
                                                            setState(() {});
                                                          }
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          labelText: 'Sync IP',
                                                          labelStyle: TextStyle(
                                                              fontSize: 11),
                                                          hintText:
                                                              'e.g., http://syncapi.example.com/',
                                                          hintStyle: TextStyle(
                                                              fontSize: 11),
                                                          prefixIcon:
                                                              const Icon(
                                                                  Icons.http),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          suffixIcon: Icon(
                                                            Icons.verified,
                                                            color: Colors.green,
                                                            size: 18,
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              Colors.grey[50],
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 14),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .blue
                                                                    .shade400,
                                                                width: 2),
                                                          ),
                                                        ),
                                                        keyboardType:
                                                            TextInputType.url,
                                                        style: TextStyle(
                                                            fontSize: 13),
                                                      ),
                                                    ],
                                                  );
                                                } else {
                                                  // Desktop: Fields side by side
                                                  return Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
                                                          controller:
                                                              apiIpController,
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              isTrackloadApiValid =
                                                                  false;
                                                              return 'Kindly enter Trackload API IP';
                                                            }

                                                            return null;
                                                          },
                                                          onChanged:
                                                              (value) async {
                                                            if (value.isEmpty) {
                                                              isTrackloadApiValid =
                                                                  false;
                                                              isAPIValidating =
                                                                  false;
                                                              setState(() {});
                                                              return;
                                                            }

                                                            isAPIValidating =
                                                                true;
                                                            setState(() {});

                                                            final isValid =
                                                                await isJsonResponse(
                                                                    value);

                                                            if (apiIpController
                                                                    .text ==
                                                                value) {
                                                              isTrackloadApiValid =
                                                                  isValid;
                                                              isAPIValidating =
                                                                  false;
                                                              setState(() {});
                                                            }
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                'Trackload IP',
                                                            labelStyle:
                                                                TextStyle(
                                                                    fontSize:
                                                                        11),
                                                            hintText:
                                                                'e.g., http://trackloadapi.example.com/',
                                                            hintStyle:
                                                                TextStyle(
                                                                    fontSize:
                                                                        11),
                                                            prefixIcon:
                                                                const Icon(
                                                                    Icons.http),
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                            suffixIcon: Icon(
                                                              Icons.verified,
                                                              color:
                                                                  Colors.green,
                                                              size: 18,
                                                            ),
                                                            filled: true,
                                                            fillColor:
                                                                Colors.grey[50],
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        14),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .blue
                                                                      .shade400,
                                                                  width: 2),
                                                            ),
                                                          ),
                                                          keyboardType:
                                                              TextInputType.url,
                                                          style: TextStyle(
                                                              fontSize: 13),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: TextFormField(
                                                          controller:
                                                              oracleIpController,
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              isOracleApiValid =
                                                                  false;
                                                              return 'Kindly enter Oracle IP';
                                                            }

                                                            return null;
                                                          },
                                                          onChanged:
                                                              (value) async {
                                                            if (value.isEmpty) {
                                                              isOracleApiValid =
                                                                  false;
                                                              isOracleValidating =
                                                                  false;
                                                              setState(() {});
                                                              return;
                                                            }

                                                            isOracleValidating =
                                                                true;
                                                            setState(() {});

                                                            final isValid =
                                                                await isJsonResponse(
                                                                    value);

                                                            if (oracleIpController
                                                                    .text ==
                                                                value) {
                                                              isOracleApiValid =
                                                                  isValid;
                                                              isOracleValidating =
                                                                  false;
                                                              setState(() {});
                                                            }
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                'Sync IP',
                                                            labelStyle:
                                                                TextStyle(
                                                                    fontSize:
                                                                        11),
                                                            hintText:
                                                                'e.g., http://syncapi.example.com/',
                                                            hintStyle:
                                                                TextStyle(
                                                                    fontSize:
                                                                        11),
                                                            prefixIcon:
                                                                const Icon(
                                                                    Icons.http),
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                            suffixIcon: Icon(
                                                              Icons.verified,
                                                              color:
                                                                  Colors.green,
                                                              size: 18,
                                                            ),
                                                            filled: true,
                                                            fillColor:
                                                                Colors.grey[50],
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        14),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .blue
                                                                      .shade400,
                                                                  width: 2),
                                                            ),
                                                          ),
                                                          keyboardType:
                                                              TextInputType.url,
                                                          style: TextStyle(
                                                              fontSize: 13),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }
                                              },
                                            ),
                                            const SizedBox(height: 20),

                                            // TextFormField(
                                            //   controller: descriptionController,
                                            //   decoration: InputDecoration(
                                            //     labelText: 'Connection Name',
                                            //     labelStyle:
                                            //         TextStyle(fontSize: 11),
                                            //     hintText:
                                            //         'e.g., Production DB Server',
                                            //     hintStyle:
                                            //         TextStyle(fontSize: 11),
                                            //     prefixIcon: const Icon(
                                            //         Icons.label_important),
                                            //     border: OutlineInputBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(12),
                                            //     ),
                                            //     filled: true,
                                            //     fillColor: Colors.grey[50],
                                            //     contentPadding:
                                            //         const EdgeInsets.symmetric(
                                            //             horizontal: 16,
                                            //             vertical: 14),
                                            //     focusedBorder: OutlineInputBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(12),
                                            //       borderSide: BorderSide(
                                            //           color: Colors.blue.shade400,
                                            //           width: 2),
                                            //     ),
                                            //   ),
                                            //   style: TextStyle(fontSize: 13),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Footer with buttons
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ));
        });
      },
    );
  }

  Future<void> handleSave(BuildContext context) async {
    // Show loading dialog
    final loadingDialog = showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(), // Optional: Add a spinner here
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  "Processing.....",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );

    try {
      if (formKey.currentState?.validate() ?? false) {
        final apiIp = apiIpController.text.trim();
        final oracleIp = oracleIpController.text.trim();
        final description = descriptionController.text.trim();

        // if (extractPort(apiIp) == extractPort(oracleIp)) {
        //   showErrorMessage(context,
        //       'Kindly enter different ports for Trackload API and Sync IP.');
        //   return;
        // }

        // Validate both endpoints before saving
        final isTrackloadValid = await isJsonResponse(apiIp);
        final isOracleValid = await isJsonResponse(oracleIp);

        setState(() {
          if (databaseConnections.isEmpty) {
            // Save new connection
            databaseConnections.add({
              'name': description,
              'endpoint': apiIp,
              'oracleEndpoint': oracleIp,
              'status': 'Active',
              'endpointVerified': isTrackloadValid,
              'oracleEndpointVerified': isOracleValid,
            });
          } else {
            // Update the first connection (assuming only one is allowed)
            final conn = databaseConnections[0];
            conn['name'] = description;
            conn['endpoint'] = apiIp;
            conn['oracleEndpoint'] = oracleIp;
            conn['status'] = 'Active';
            conn['endpointVerified'] = isTrackloadValid;
            conn['oracleEndpointVerified'] = isOracleValid;
          }
        });

        await saveConnections(databaseConnections);
        _editingConnection = null; // Reset editing connection
        _showSaveSuccess(context); // Show success message
      }
    } catch (e) {
      // Handle any errors here
      showErrorMessage(context, 'An error occurred while saving: $e');
    } finally {
      // Close the loading dialog
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  int? extractPort(String url) {
    final uri = Uri.tryParse(url);
    return uri?.port;
  }

// Function to check if the URL returns valid JSON
  Future<bool> isJsonResponse(String url) async {
    try {
      // Add basic URL validation first
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        return false;
      }

      final uri = Uri.tryParse(url);
      if (uri == null) return false;

      final response = await http.get(uri).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        // Try to parse as JSON
        try {
          final body = jsonDecode(response.body);
          return body is Map<String, dynamic>;
        } catch (e) {
          return false;
        }
      }
      return false;
    } on TimeoutException {
      return false;
    } catch (e) {
      return false;
    }
  }

  Widget _buildConnectionsTable(
      BuildContext context, List<Map<String, dynamic>> connections) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 500;

        return StatefulBuilder(builder: (context, setState) {
          return Column(
            children: [
              // Header row (only for desktop)
              if (!isMobile)
                Container(
                  margin: const EdgeInsets.only(bottom: 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text(
                            'Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.blue.shade800,
                            ),
                          )),
                      Expanded(
                          flex: 3,
                          child: Text(
                            'Trackload API',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.blue.shade800,
                            ),
                          )),
                      Expanded(flex: 1, child: SizedBox()), // Icon column
                      Expanded(
                          flex: 3,
                          child: Text(
                            'Sync API',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.blue.shade800,
                            ),
                          )),
                      Expanded(flex: 1, child: SizedBox()), // Icon column
                    ],
                  ),
                ),

              ...connections.map((conn) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _editingConnection = conn;
                      apiIpController.text = conn['endpoint'] ?? '';
                      oracleIpController.text = conn['oracleEndpoint'] ?? '';
                      descriptionController.text = conn['name'] ?? '';
                      isTrackloadApiValid = conn['endpointVerified'] ?? false;
                      isOracleApiValid =
                          conn['oracleEndpointVerified'] ?? false;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                conn['name'] ?? '',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        'API: ${conn['endpoint'] ?? ''}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                        softWrap: false,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        'Oracle: ${conn['oracleEndpoint'] ?? ''}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                        softWrap: false,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                    conn['name'] ?? '',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  )),
                              Expanded(
                                  flex: 3,
                                  child: Text(
                                    conn['endpoint'] ?? '',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  )),
                              Expanded(
                                  flex: 3,
                                  child: Text(
                                    conn['oracleEndpoint'] ?? '',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  )),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                  icon: Icon(Icons.edit,
                                      size: 18, color: Colors.blue),
                                  onPressed: () {
                                    setState(() {
                                      _editingConnection = conn;
                                      apiIpController.text =
                                          conn['endpoint'] ?? '';
                                      oracleIpController.text =
                                          conn['oracleEndpoint'] ?? '';
                                      descriptionController.text =
                                          conn['name'] ?? '';
                                      isTrackloadApiValid =
                                          conn['endpointVerified'] ?? false;
                                      isOracleApiValid =
                                          conn['oracleEndpointVerified'] ??
                                              false;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              }).toList(),
            ],
          );
        });
      },
    );
  }

  void _editConnection(BuildContext context, Map<String, dynamic> conn) {
    // Set the controllers with the current connection details
    apiIpController.text = conn['endpoint'] ?? '';
    oracleIpController.text = conn['oracleEndpoint'] ?? '';
    descriptionController.text = conn['name'] ?? '';

    // Show the dialog for editing
  }

  void _confirmDeleteConnection(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete),
            SizedBox(
              width: 5,
            ),
            const Text(
              'Delete Connection',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this database connection?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 13),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              databaseConnections.removeAt(index);
              saveConnections(databaseConnections);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showSaveSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Database API saved successfully!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 6,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String errorMessage = '';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Container(
                height: 270,
                width: 350, // Fixed width
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_reset, size: 50, color: Colors.blue),
                        SizedBox(height: 10),
                        Text(
                          "Reset your password?",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Enter your New password and reset your old password",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),

                        // New Password Field
                        Container(
                          height: 40,
                          child: TextFormField(
                            controller: _newPasswordController,
                            focusNode: newpasswordFocusNode,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(confirmedpasswordFocusNode),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock_clock_outlined,
                                size: 18,
                              ),

                              hintText: "New Password",
                              hintStyle:
                                  TextStyle(fontSize: 14), // Reduce text size
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal:
                                      12), // Reduce height of the textbox
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _newPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    size: 20,
                                    color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    _newPasswordVisible = !_newPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_newPasswordVisible,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Confirm Password Field
                        Container(
                          height: 40,
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            focusNode: confirmedpasswordFocusNode,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(resetpasswordbuttonfocusnode),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock_clock_rounded,
                                size: 18,
                              ),
                              hintText: "Confirmed Password",
                              hintStyle:
                                  TextStyle(fontSize: 14), // Reduce text size

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _confirmPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    size: 20,
                                    color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    _confirmPasswordVisible =
                                        !_confirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_confirmPasswordVisible,
                          ),
                        ),
                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  focusNode: resetpasswordbuttonfocusnode,
                  onPressed: () async {
                    if (_newPasswordController.text.isEmpty ||
                        _confirmPasswordController.text.isEmpty) {
                      setState(() {
                        errorMessage = 'Fields cannot be empty';
                      });
                    } else if (_newPasswordController.text == '1234') {
                      setState(() {
                        _newPasswordController.clear();
                        _confirmPasswordController.clear();

                        errorMessage =
                            'This password is default password kindly set another unique One';
                      });
                    } else if (_newPasswordController.text !=
                        _confirmPasswordController.text) {
                      setState(() {
                        _confirmPasswordController.clear();
                        errorMessage = 'Passwords do not match';
                      });
                    } else {
                      try {
                        // Show processing indicator
                        _showProcessingDialog();

                        // Start the async processes
                        await fetchUserId();
                        await _UpdateData(_newPasswordController.text);

                        // Clear any existing error message
                        setState(() {
                          errorMessage = '';
                        });

                        // Update and clear controllers
                        _passwordController.text = _newPasswordController.text;
                        _newPasswordController.clear();
                        _confirmPasswordController.clear();
                        Navigator.of(context).pop();
                        // Close the processing indicator
                        _hideProcessingDialog();

                        // Show the confirmation dialog
                        _showUpdateConfirmationDialog(context);
                      } catch (e) {
                        // Close the processing indicator if an error occurs
                        _hideProcessingDialog();

                        // Show an error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('An error occurred: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(double.infinity, 40),
                  ),
                  child: Text("Reset Password",
                      style: TextStyle(color: Colors.white)),
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 202, 231, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(double.infinity, 40),
                  ),
                  child: Text("← Back to Login",
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isSaving = false; // Add this variable to track the saving state

  Future<void> _UpdateData(
    String password,
  ) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      int Id = int.parse(
          _IdControllerontroller.text); // Parse the text into an integer
      // print("Parsed Id: $Id $password");
      final ipAddress =
          await getActiveIpAddress(); // e.g., http://192.168.10.110:8005
      final url =
          Uri.parse('$ipAddress/update_user_password_User_managemnet/$Id/');

      // Encode the password
      String encodedPassword = base64Encode(utf8.encode(password));

      final body = jsonEncode({
        "EMP_PASSWORD": encodedPassword,
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
    }
  }

  // Future<void> _UpdateData(
  //   String password,
  // ) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? salesloginno = prefs.getString('salesloginno');
  //   // Prevent multiple requests

  //   DateTime now = DateTime.now();
  //   // Format it to YYYY-MM-DD'T'HH:mm:ss'
  //   String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

  //   // URL for the API with the specific ID
  //   int Id = int.parse(
  //       _IdControllerontroller.text); // Parse the text into an integer
  //   print("Parsed Id: $Id $password");

  //   final IpAddress = await getActiveIpAddress();

  //   final url = Uri.parse('$IpAddress/User_member_details/$Id/');

  //   // Create the body of the PUT request
  //   final body = jsonEncode({
  //     "EMP_PASSWORD": password,
  //     "LAST_UPDATE_DATE": formattedDate,
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
  //       print('Response body: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error occurred: $e');
  //   } finally {}
  // }

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

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog manually
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: const [
              CircularProgressIndicator(color: Colors.blue),
              SizedBox(width: 20),
              Text(
                "Processing...",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  void _hideProcessingDialog() {
    Navigator.of(context, rootNavigator: true).pop(); // Close the dialog
  }
}

class TopLeftErrorMessage extends StatelessWidget {
  final String message;
  final Color backgroundColor;

  const TopLeftErrorMessage({
    super.key,
    required this.message,
    this.backgroundColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
