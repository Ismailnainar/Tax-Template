import 'package:aljeflutterapp/cacheupdate.date/services/version_service.dart';
import 'package:aljeflutterapp/components/Responsive.dart';

export 'version_service_mobile.dart'
    if (dart.library.html) 'version_service_web.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aljeflutterapp/main.dart';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> handleUpdateNow(BuildContext context) async {
  print("handleUpdateNow not implemented for this platform");
}

class VersionDialogWrapper extends StatefulWidget {
  final Widget child;

  const VersionDialogWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<VersionDialogWrapper> createState() => _VersionDialogWrapperState();
}

class _VersionDialogWrapperState extends State<VersionDialogWrapper> {
  bool _showDialog = false;
  Timer? _timer;
  // @override
  // void initState() {
  //   print("🚀 Come in to the version page ");
  //   super.initState();
  //   _checkVersion();
  //   fetchSoftwareVersion();

  //   // Refresh this widget every 10 seconds
  //   _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
  //     setState(() {
  //       // Just trigger rebuild
  //       // print("🔄 Auto-refreshing VersionDialogWrapper...");
  //       _checkVersion();
  //       fetchSoftwareVersion();
  //     });
  //   });
  // }
  Timer? _refreshTimer;
  Timer? _warningTimer;

  bool _isDialogOpen = false;
  int _runningMinutes = 1; // default fallback

  @override
  void initState() {
    super.initState();
    print("🚀 Entered Version Page");

    _checkVersion();
    fetchSoftwareVersion();

    // 🔁 Refresh app version info every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _checkVersion();
        fetchSoftwareVersion();
      }
    });

    // ✅ Start warning system (initial fetch, no dialog)
    _initializeWarningCheck();
  }

  Future<void> _initializeWarningCheck() async {
    if (Responsive.isMobile(context))
      print("🔍 Initial warning fetch — no dialog yet...");
    if (Responsive.isMobile(context))
      await _checkWarningFromServer(showDialogNow: false);
  }

  /// 🔍 Fetch warning details from Django API
  Future<void> _checkWarningFromServer({bool showDialogNow = true}) async {
    final ipAddress = await getActiveIpAddress(); // Your IP function
    final url = "$ipAddress/Get_playStore_warning/?status=mobile";

    print("🌐 Checking server: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ API Response: $data");

        final playStoreWarning =
            data["Play_store_Warning"]?.toString().toLowerCase();
        final runningTime = data["Running_time"] ?? 10;
        _runningMinutes = runningTime;

        if (playStoreWarning == "yes") {
          print(
              "⚠️ Warning is YES — timer started for $_runningMinutes minute(s).");

          // Cancel existing periodic check
          _warningTimer?.cancel();

          // ⏳ Start timer — after this time, show dialog
          _warningTimer = Timer(Duration(minutes: _runningMinutes), () async {
            if (!mounted) return;

            print("⏰ Timer finished — showing warning dialog...");
            if (!_isDialogOpen) {
              await _showReminderDialog();
            }

            // When dialog closes, restart the same warning cycle
            if (mounted) {
              print("🔁 Restarting next warning cycle...");
              await _checkWarningFromServer(showDialogNow: true);
            }
          });
        } else {
          print("ℹ️ Warning is NO — check again after 10 minutes.");

          // Close any open dialog
          if (_isDialogOpen && mounted) {
            Navigator.of(context, rootNavigator: true).pop();
            _isDialogOpen = false;
          }

          // ✅ Recheck every 10 minutes while NO
          _warningTimer?.cancel();
          _warningTimer =
              Timer.periodic(const Duration(minutes: 10), (timer) async {
            if (mounted) {
              print("🔄 10-minute normal mode check...");
              await _checkWarningFromServer(showDialogNow: true);
            }
          });
        }
      } else {
        print("⚠️ Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error checking warning: $e");
    }
  }

  /// 🔁 Retry after 10 minutes if API fails
  // void _retryAfterDelay() {
  //   _dialogCycleTimer?.cancel();
  //   _dialogCycleTimer = Timer(Duration(minutes: _runningMinutes), () async {
  //     if (mounted) await _checkWarningFromServer();
  //   });
  // }

  /// 🪧 Show the warning dialog box
  Future<void> _showReminderDialog() async {
    _isDialogOpen = true;
    print("🟡 Showing warning dialog...");

    await showDialog(
      context: context,
      barrierDismissible: false, // cannot close manually
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ⚠️ Header
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEB3B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 10),
                    child: Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.black87, size: 24),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Important Notice",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 📝 Message
                  const Text(
                    "Your app version requires an urgent policy compliance update.\n\n"
                    "Please contact the support team immediately to complete the update process "
                    "and avoid potential service interruption or app restrictions.",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 15, color: Colors.black87, height: 1.4),
                  ),

                  const SizedBox(height: 25),

                  // ✅ OK Button (manually close)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEB3B),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.of(context, rootNavigator: true).pop();
                          _isDialogOpen = false;
                        }
                      },
                      child: const Text(
                        "OK, Got It",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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

    print("🔴 Dialog closed");
    _isDialogOpen = false;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _warningTimer?.cancel();
    super.dispose();
  }

  Future<String?> fetchSoftwareVersion() async {
    try {
      final ipAddress =
          await getActiveIpAddress(); // Get IP (e.g., http://192.168.10.110:8005)
      String url = '';

      // Check if running on Mobile (Android/iOS) or mobile layout
      bool isMobilePlatform =
          !kIsWeb && (Platform.isAndroid || Platform.isIOS) ||
              Responsive.isMobile(context);

      if (isMobilePlatform) {
        url =
            "$ipAddress/WMS_SoftwareVersionView/${Uri.encodeComponent("Track Load")}/?checkstatus=mobileapp";
      } else {
        url =
            "$ipAddress/WMS_SoftwareVersionView/${Uri.encodeComponent("Track Load")}/";
      }

      // print("🚀 Version API URL: $url");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? version = data['version'];

        // print('Fetched version from server: $version');
        return version;
      } else {
        print('Failed to fetch version. Status Code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching version: $e');
      return null;
    }
  }

  static const String versionKey = 'ALJE_App_PubVersion';
  Future<void> _checkVersion() async {
    // Fetch the current version from the server
    String? currentVersion = await fetchSoftwareVersion();

    if (currentVersion == null) {
      print('Failed to fetch current version from server.');
      return;
    }

    // Load stored version from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedVersion = prefs.getString("ALJE_App_PubVersion");

    // print('Current Version: $currentVersion'); // Debug print
    // print('Last Version: $savedVersion'); // Debug print

    if (savedVersion == null) {
      // print('First time running the app, saving version: $currentVersion');
      // First time running the app
      await prefs.setString(versionKey, currentVersion);
      setState(() {
        _showDialog = false;
      });
    } else if (savedVersion != currentVersion) {
      // print('New version detected: $savedVersion → $currentVersion');

      setState(() {
        _showDialog = true;
      });
    } else {
      // No version change
      setState(() {
        _showDialog = false;
      });
    }
  }

  Future<void> saveversion(String savedVersion) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedVersion = prefs.getString("ALJE_App_PubVersion");
  }

  Future<void> runSetupFile() async {
    try {
      String setupPath = r'C:\ALJE\TruckLoadSetup.exe';

      if (await File(setupPath).exists()) {
        print("🚀 Running Setup File: $setupPath");

        // Start the setup
        Process.start(setupPath, [], runInShell: true);

        // Close the current app after a short delay
        await Future.delayed(Duration(seconds: 2));
        exit(0); // Close the Flutter app
      } else {
        print('❌ Setup file not found at $setupPath');
      }
    } catch (e) {
      print('⚠️ Error running setup file: $e');
    }
  }

  Future<void> _runUpdateScript() async {
    try {
      String command = "cmd";
      List<String> arguments = [
        "/c",
        "(if not exist C:\\ALJE mkdir C:\\ALJE) && del /f /q C:\\ALJE\\TruckLoadSetup.exe && curl -o C:\\ALJE\\TruckLoadSetup.exe https://my-flutter-app-bucketes.s3.ap-south-1.amazonaws.com/TruckLoadSetup.exe"
      ];

      ProcessResult result =
          await Process.run(command, arguments, runInShell: true);

      print("Output:\n\${result.stdout}");
      print("Errors:\n\${result.stderr}");
    } catch (e) {
      print("Error running update script: \$e");
    }
  }

// Call this method when the update button is clicked
  // Future<void> handleUpdateNow() async {
  //   // Check if the app is running on Web
  //   if (kIsWeb) {
  //     // If running on Web, check the browser
  //     if (Platform.environment['BROWSER'] == 'Chrome' || true) {
  //       print("Running in browser (Web) - Chrome");

  //       PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //       String currentVersion = packageInfo.version;

  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       await SharedPrefs.clearaLLlogins();
  //       await prefs.setString("ALJE_App_PubVersion", currentVersion);

  //       // You can optionally show a toast/snackbar here saying "App is up to date on Web"
  //     }
  //   }

  //   // If running on Windows desktop
  //   else if (Platform.isWindows) {
  //     print("Running on Windows");

  //     // PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //     // String currentVersion = packageInfo.version;

  //     // SharedPreferences prefs = await SharedPreferences.getInstance();
  //     // await SharedPrefs.clearaLLlogins();
  //     // await prefs.setString("ALJE_App_PubVersion", currentVersion);

  //     await _runUpdateScript();
  //     await runSetupFile();
  //   }

  //   // If running on Android or iOS (mobile)
  //   else if (Platform.isAndroid || Platform.isIOS) {
  //     print("Running on Mobile");

  //     const playStoreUrl =
  //         'https://play.google.com/store/apps/details?id=com.buyp.Trackload&hl=en';

  //     // Launch Play Store
  //     if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
  //       await launchUrl(Uri.parse(playStoreUrl),
  //           mode: LaunchMode.externalApplication);
  //     } else {
  //       throw 'Could not launch Play Store';
  //     }

  //     // Hide dialog
  //     setState(() {
  //       _showDialog = false;
  //     });

  //     // Navigate after current frame
  //     Future.delayed(Duration(milliseconds: 100), () {
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: (_) => splashscreen()),
  //       );
  //     });
  //   }

  //   // Other platforms
  //   else {
  //     print("Platform not supported for update");
  //   }
  // }

  Future<void> handleUpdateNow() async {
    if (!mounted) return;
    setState(() => _showDialog = false);

    // if (kIsWeb) {
    //   print("Running in browser (Web) - Chrome $_showDialog");
    //   // Navigator.pop(context);

    //   // ✅ Clear cookies (set expired cookies)
    //   var cookies = html.document.cookie?.split(";") ?? [];
    //   for (var cookie in cookies) {
    //     var cookieName = cookie.split("=")[0].trim();
    //     html.document.cookie =
    //         "$cookieName=;expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/;";
    //   }

    //   // ✅ Clear local storage
    //   html.window.localStorage.clear();

    //   // ✅ Get app version
    //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
    //   String currentVersion = packageInfo.version;

    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   await prefs.clear(); // clear flutter shared prefs
    //   await prefs.setString("ALJE_App_PubVersion", currentVersion);

    //   // ✅ Navigate to splashscreen using navigatorKey
    //   navigatorKey.currentState?.pushAndRemoveUntil(
    //     MaterialPageRoute(builder: (_) => splashscreen()),
    //     (route) => false,
    //   );
    // }

    if (kIsWeb) {
      print("Running in browser (Web)");
      await clearCacheAndReload();
    }
    // If running on Windows desktop
    else if (Platform.isWindows) {
      print("Running on Windows");
      await _runUpdateScript();
      await runSetupFile();
    }

    // If running on Android or iOS (mobile)
    else if (Platform.isAndroid || Platform.isIOS) {
      print("Running on Mobile");

      const playStoreUrl =
          'https://play.google.com/store/apps/details?id=com.buyp.Trackload&hl=en';

      if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
        await launchUrl(Uri.parse(playStoreUrl),
            mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch Play Store';
      }

      // ✅ Navigate with navigatorKey
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (_) => splashscreen()),
      );
    }

    // Other platforms
    else {
      print("Platform not supported for update");
    }
    _showDialog = false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showDialog)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 400),
                  margin: EdgeInsets.all(24),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.system_update_alt,
                            size: 48,
                            color: Colors.blue,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'New Version Available',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'A new version of the application is now available. Update to enjoy improved performance, new features, and enhanced security.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),
                          Row(
                            children: [
                              // Expanded(
                              //   child: OutlinedButton(
                              //       onPressed: () {
                              //         setState(() {
                              //           _showDialog = false;
                              //         });
                              //       },
                              //       style: OutlinedButton.styleFrom(
                              //         padding:
                              //             EdgeInsets.symmetric(vertical: 16),
                              //         side: BorderSide(color: Colors.blue),
                              //         shape: RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.circular(12),
                              //         ),
                              //       ),
                              //       child: Text(
                              //         "Later",
                              //         style: TextStyle(
                              //             color: Colors.blue,
                              //             fontWeight: FontWeight.w500),
                              //       )),
                              // ),
                              // SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => handleUpdateNow(),
                                  // onPressed: () async {
                                  //   // await VersionService.saveCurrentVersion();
                                  //   // await SharedPrefs.clearAllComercialData();
                                  //   // await _runUpdateScript();
                                  //   // await runSetupFile();

                                  //   // await SharedPrefs
                                  //   //     .cleardatadepartmentexchange();

                                  //   // await SharedPrefs.clearaLLlogins();
                                  //   // setState(() {
                                  //   //   _showDialog = false;
                                  //   // });

                                  //   // Get the current app version from pubspec.yaml
                                  //   PackageInfo packageInfo =
                                  //       await PackageInfo.fromPlatform();
                                  //   String currentVersion = packageInfo.version;
                                  //   SharedPreferences prefs =
                                  //       await SharedPreferences.getInstance();
                                  //   await prefs.setString(
                                  //       "ALJE_App_PubVersion", currentVersion);

                                  //   await SharedPrefs.clearaLLlogins();
                                  //   setState(() {
                                  //     _showDialog = false;
                                  //   });

                                  //   Navigator.pushReplacement(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder: (context) => splashscreen(),
                                  //     ),
                                  //   );
                                  // },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Text(
                                    "Update Now",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
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
            ),
          ),
      ],
    );
  }
}
