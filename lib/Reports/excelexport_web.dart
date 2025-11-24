// ignore: avoid_web_libraries_in_flutter
// This file is only used on web builds.
// Place this in the same folder as excelexport.dart

// dart:html is only available on web
// ignore: uri_does_not_exist
import 'dart:html' as html;
import 'dart:convert';

void saveExcelWeb(List<int> bytes, String filename) {
  final content = base64Encode(bytes);
  final anchor = html.AnchorElement(
    href:
        "data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,$content",
  )
    ..setAttribute("download", filename)
    ..style.display = 'none';
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
}
