@JS()
library web_browser_functions;

import 'dart:html' as html;
import 'dart:convert';
import 'package:js/js.dart';

String? getBrowserCookie(String name) {
  if (html.document.cookie == null) return null;
  final cookies = html.document.cookie!.split(';');
  for (var cookie in cookies) {
    final keyValue = cookie.split('=');
    if (keyValue[0].trim() == name) {
      return keyValue[1];
    }
  }
  return null;
}

void setBrowserCookie(String name, String value, int days) {
  final expirationDate = DateTime.now().add(Duration(days: days));
  html.document.cookie =
      '$name=$value; path=/; expires=${expirationDate.toUtc()}; SameSite=Lax';
}

void clearBrowserHistory() {
  try {
    html.window.history.pushState(null, '', html.window.location.href);
    html.window.history.replaceState(null, '', html.window.location.href);

    print(' clearing browser history ');
  } catch (e) {
    print('Error clearing browser history: $e');
  }
}

void addBrowserHistory() {
  try {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final currentUrl = html.window.location.href
        .split('?')[0]; // Remove any existing cache bust

    // Store current state
    final currentState = {
      'timestamp': timestamp,
      'url': currentUrl,
    };

    // Add to history with cache parameters
    // final historyUrl = '$currentUrl?v=$timestamp';
    final historyUrl = '$currentUrl';

    html.window.history.pushState(currentState, '', historyUrl);

    // Store in localStorage
    html.window.localStorage['lastState'] = json.encode(currentState);

    html.window.history.pushState(null, '', currentUrl);

    print(' adding browser history ');
  } catch (e) {
    print('Error adding browser history: $e');
  }
}

void enableBrowserHistory() {
  try {
    html.window.history.pushState(null, '', html.window.location.href);

    print(' enablingg browser history ');
  } catch (e) {
    print('Error enabling browser history: $e');
  }
}

void clearWebStorageAndHistory() {
  try {
    html.window.localStorage.clear();
    html.window.sessionStorage.clear();

    // Clear cookies
    final cookies = html.document.cookie?.split(';') ?? [];
    for (var cookie in cookies) {
      final cookieName = cookie.split('=')[0].trim();
      html.document.cookie =
          '$cookieName=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT';
    }

    // Clear history state
    final currentPath = html.window.location.pathname;
    html.window.history.pushState(null, '', currentPath);

    print(' clearingweb storage and browser history ');
  } catch (e) {
    print('Error clearing web storage and history: $e');
  }
}

void initializeWebHistory() {
  try {
    html.window.onPopState.listen((event) {
      html.window.history.pushState(null, '', html.window.location.href);

      print(' initializing web history');
    });
  } catch (e) {
    print('Error initializing web history: $e');
  }
}

void reloadPage() {
  final reloadUrl = html.window.location.href.split('#')[0];
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final newUrl = '$reloadUrl?cache_bust=$timestamp';
  html.window.location.href = newUrl;
}
