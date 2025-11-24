// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> clearCacheAndReload() async {
  print("Running in browser (Web)");

  // ✅ Clear cookies
  var cookies = html.document.cookie?.split(";") ?? [];
  for (var cookie in cookies) {
    var cookieName = cookie.split("=")[0].trim();
    html.document.cookie =
        "$cookieName=;expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/;";
  }

  // ✅ Clear storages
  html.window.localStorage.clear();
  html.window.sessionStorage.clear();

  // ✅ Clear IndexedDB
  try {
    html.window.indexedDB?.deleteDatabase("flutter_web");
  } catch (e) {
    print("IndexedDB clear failed: $e");
  }

  // ✅ Save current app version
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String currentVersion = packageInfo.version;

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await prefs.setString("ALJE_App_PubVersion", currentVersion);

  // ✅ Reload page
  html.window.location.reload();
}
