import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> clearCacheAndReload() async {
  print("Running on Mobile/Desktop");

  // ✅ Save current app version
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String currentVersion = packageInfo.version;

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await prefs.setString("ALJE_App_PubVersion", currentVersion);

  // ❌ No reload available (only for web)
  print("App cache cleared. Restart the app manually if needed.");
}
