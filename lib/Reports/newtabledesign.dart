import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:aljeflutterapp/Reports/CustomerWise_excelexport.dart';
import 'package:excel/excel.dart' as excel;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:excel/excel.dart' as excel;
import 'package:shared_preferences/shared_preferences.dart';

class GroupedTruckScanDetails extends StatefulWidget {
  final String fromDate;
  final String endDate;
  final String Parametertype;
  final String parametervalue;

  const GroupedTruckScanDetails(
      this.fromDate, this.endDate, this.Parametertype, this.parametervalue,
      {super.key});
  @override
  State<GroupedTruckScanDetails> createState() =>
      _GroupedTruckScanDetailsState();
}

class _GroupedTruckScanDetailsState extends State<GroupedTruckScanDetails> {
  List<dynamic> tableData = [];
  bool isLoading = true;
  String errorMessage = '';
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  // Pagination variables
  int _currentPage = 1;
  int _rowsPerPage = 10;
  int _totalPages = 1;
  int _startIndex = 0;
  int _endIndex = 0;

  // Column configuration
  final List<String> columnHeaders = [
    'Customer Name',
    'Customer No',
    'Date',
    'Salesman No',
    'Salesman Name',
    'Invoice No',
    'Item Code',
    'Item Details',
    'Dispatch Qty',
    'Transporter Name',
    'Driver Name',
    'Vehicle No',
    'Total Value'
  ];

  final Map<String, double> columnWidths = {
    'Customer Name': 250,
    'Customer No': 120,
    'Date': 120,
    'Salesman No': 100,
    'Salesman Name': 220,
    'Invoice No': 120,
    'Item Code': 150,
    'Item Details': 350,
    'Dispatch Qty': 100,
    'Transporter Name': 150,
    'Driver Name': 150,
    'Vehicle No': 100,
    'Total Value': 100,
  };

  final inputFormat = DateFormat('dd-MMM-yyyy'); // to parse '10-Jul-2025'
  final outputFormat = DateFormat('yyyy-MM-dd'); // to format as '2025-07-10'
  String fromDateFormatted = '';
  String endDateFormatted = '';
  @override
  void initState() {
    super.initState();
    _fetchData();

    DateTime fromDateParsed = inputFormat.parse(widget.fromDate);
    DateTime endDateParsed = inputFormat.parse(widget.endDate);

    fromDateFormatted = outputFormat.format(fromDateParsed);
    endDateFormatted = outputFormat.format(endDateParsed);

    print("fromDateaaa $fromDateFormatted  enddate $endDateFormatted");
  }

  // Future<void> _fetchData() async {
  //   setState(() {
  //     isLoading = true;
  //     errorMessage = '';
  //   });

  //   try {
  //     final response = await http.get(
  //       Uri.parse(
  //           'http://192.168.10.110:8005/Report-grouped-truck-scan-details/?from_date=$fromDateFormatted&to_date=$endDateFormatted'),
  //     );

  //     print(
  //         "http://192.168.10.110:8005/Report-grouped-truck-scan-details/?from_date=$fromDateFormatted&to_date=$endDateFormatted");

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       List<dynamic> flattenedData = [];
  //       for (var group in data) {
  //         for (var dispatch in group['dispatches']) {
  //           flattenedData.add({
  //             ...group,
  //             ...dispatch,
  //             'dispatches': null,
  //           });
  //         }
  //       }

  //       setState(() {
  //         tableData = flattenedData;
  //         _updatePagination();
  //         isLoading = false;
  //       });
  //     } else {
  //       setState(() {
  //         errorMessage = 'Failed to load data: ${response.statusCode}';
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       errorMessage = 'Error: ${e.toString()}';
  //       isLoading = false;
  //     });
  //   }
  // }

  String? salesmanName;
  Future<String?> fetchSalesmanName(String salesmanNo) async {
    try {
      final IpAddress = await getActiveIpAddress();
      final url =
          Uri.parse("$IpAddress/get-salesman-name/?salesman_no=$salesmanNo");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['salesman_name']; // ✅ Return only the name
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Format fromDate and endDate to yyyy-MM-dd
      final DateFormat inputFormat = DateFormat('dd-MMM-yyyy');
      final DateFormat outputFormat = DateFormat('yyyy-MM-dd');

      // Replace with your actual input variables
      DateTime fromDateParsed =
          inputFormat.parse(widget.fromDate); // e.g. '10-Jul-2025'
      DateTime endDateParsed =
          inputFormat.parse(widget.endDate); // e.g. '19-Jul-2025'

      String fromDateFormatted =
          outputFormat.format(fromDateParsed); // '2025-07-10'
      String endDateFormatted =
          outputFormat.format(endDateParsed); // '2025-07-19'

      String sendvalues;
      if (widget.Parametertype.trim() == 'Salesman Number') {
        sendvalues = (await fetchSalesmanName(
              widget.parametervalue.trim(),
            )) ??
            "";
      } else {
        sendvalues = widget.parametervalue.trim();
      }

      String finalparameterevalues = widget.Parametertype == 'Undel id'
          ? '&undel_id=${widget.Parametertype}'
          : (widget.Parametertype == 'Customer Number'
              ? '&customer_no=${widget.parametervalue}'
              : (widget.Parametertype.isEmpty
                  ? ''
                  : '&salesman_name=${sendvalues}'));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String salesmanno = prefs.getString('salesloginno') ?? 'Unknown ID';
      String salesloginrole = prefs.getString('salesloginrole') ?? 'Unknown ID';

      String sendvaluessss = (await fetchSalesmanName(
            salesmanno.trim(),
          )) ??
          "";
      print("sendvaluesaaaa $sendvaluessss");
      String salesmanstatus = salesloginrole == 'Salesman'
          ? '&salesman_name=$sendvaluessss$finalparameterevalues'
          : '$finalparameterevalues';

      print(
          'widget.Parametertypeee ${widget.Parametertype}  $finalparameterevalues ');
      final IpAddress = await getActiveOracleIpAddress();

      final uri = Uri.parse(
        '$IpAddress/Report-grouped-truck-scan-details/?from_date=$fromDateFormatted&to_date=$endDateFormatted$salesmanstatus',
      );

      print("Request URL: $uri");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<dynamic> flattenedData = [];

        for (var group in data) {
          for (var dispatch in group['dispatches']) {
            flattenedData.add({
              ...group,
              ...dispatch,
              'dispatches': null,
            });
          }
        }

        setState(() {
          tableData = flattenedData;
          _updatePagination();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _updatePagination() {
    _totalPages = (tableData.length / _rowsPerPage).ceil();
    if (_totalPages == 0) _totalPages = 1;

    if (_currentPage > _totalPages) {
      _currentPage = _totalPages;
    }

    _startIndex = (_currentPage - 1) * _rowsPerPage;
    _endIndex = _startIndex + _rowsPerPage;
    if (_endIndex > tableData.length) {
      _endIndex = tableData.length;
    }
  }

  String _getKeyForHeader(String header) {
    final keyMap = {
      'Customer Name': 'customer_name',
      'Customer No': 'customer_number',
      'Date': 'dispatch_date',
      'Salesman Name': 'salesman_name',
      'Salesman No': 'salesman_no',
      'Invoice No': 'invoice_no',
      'Item Code': 'item_code',
      'Item Details': 'item_details',
      'Dispatch Qty': 'truck_send_qty',
      'Transporter Name': 'transporter_name',
      'Driver Name': 'driver_name',
      'Vehicle No': 'vehicle_no',
      'Total Value': 'total_cost',
    };
    return keyMap[header] ?? '';
  }

  dynamic _formatValueForExport(dynamic value, String key) {
    if (value == null) return '';

    // Handle numeric fields
    if (key == 'truck_send_qty' ||
        key == 'customer_number' ||
        key == 'salesman_no') {
      return value.toInt();
    }

    // Handle date fields
    if (key == 'date' || key == 'delivery_date' || key == 'dispatch_date') {
      return value.toString().split('T')[0];
    }

    // Handle double fields
    if (value is double) {
      return value.toStringAsFixed(2);
    }

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    double totalWidth = columnHeaders.fold<double>(
      0,
      (sum, header) => sum + (columnWidths[header] ?? 120),
    );

    return Container(
      height: 350,
      child: Column(
        children: [
          Expanded(
            child: RawScrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 9,
              thumbColor: const ui.Color.fromARGB(255, 103, 103, 103),
              trackColor:
                  const ui.Color.fromARGB(255, 78, 78, 78).withOpacity(0.2),
              radius: const Radius.circular(8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalController,
                child: Container(
                  width: totalWidth + 18,
                  decoration: BoxDecoration(
                    color: const ui.Color.fromARGB(255, 248, 248, 248),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage.isNotEmpty
                          ? Center(child: Text(errorMessage))
                          : _buildDesktopView(context, tableData),
                ),
              ),
            ),
          ),
          // Pagination and Export Controls
          Container(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 16.0),
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       exportGroupedTruckScanDetails(
                  //           fromDateFormatted, endDateFormatted);
                  //     },
                  //     child: Text('Export to Excel'),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.green,
                  //       padding:
                  //           EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  //     ),
                  //   ),
                  // ),
                  _buildPagination(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      width: 430,
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(width: 16),
            IconButton(
              icon: Icon(Icons.first_page),
              onPressed: _currentPage > 1
                  ? () {
                      setState(() {
                        _currentPage = 1;
                        _updatePagination();
                      });
                    }
                  : null,
              color: _currentPage > 1 ? Colors.blue : Colors.grey,
            ),
            IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: _currentPage > 1
                  ? () {
                      setState(() {
                        _currentPage--;
                        _updatePagination();
                      });
                    }
                  : null,
              color: _currentPage > 1 ? Colors.blue : Colors.grey,
            ),
            SizedBox(width: 16),
            Text(
              'Page $_currentPage of $_totalPages',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(width: 16),
            IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: _currentPage < _totalPages
                  ? () {
                      setState(() {
                        _currentPage++;
                        _updatePagination();
                      });
                    }
                  : null,
              color: _currentPage < _totalPages ? Colors.blue : Colors.grey,
            ),
            IconButton(
              icon: Icon(Icons.last_page),
              onPressed: _currentPage < _totalPages
                  ? () {
                      setState(() {
                        _currentPage = _totalPages;
                        _updatePagination();
                      });
                    }
                  : null,
              color: _currentPage < _totalPages ? Colors.blue : Colors.grey,
            ),
            SizedBox(width: 24),
            DropdownButton<int>(
              value: _rowsPerPage,
              items: [10, 15, 20, 30, 50].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value rows'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _rowsPerPage = newValue;
                    _currentPage = 1;
                    _updatePagination();
                  });
                }
              },
            ),
            SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopView(BuildContext context, List<dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: columnHeaders.map((header) {
                return Container(
                  width: columnWidths[header] ?? 120,
                  height: 35,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    header,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                );
              }).toList(),
            ),
          ),
          // Table Content
          Expanded(
            child: RawScrollbar(
              controller: _verticalController,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 9,
              thumbColor: const ui.Color.fromARGB(255, 103, 103, 103),
              trackColor:
                  const ui.Color.fromARGB(255, 78, 78, 78).withOpacity(0.2),
              radius: const Radius.circular(8),
              child: SingleChildScrollView(
                controller: _verticalController,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _buildDataRows(context, data),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRows(BuildContext context, List<dynamic> data) {
    final paginatedData = data.sublist(_startIndex, _endIndex);

    return Column(
      children: [
        Table(
          columnWidths: Map.fromEntries(
            columnHeaders.asMap().entries.map(
                  (entry) => MapEntry(
                    entry.key,
                    FixedColumnWidth(columnWidths[entry.value] ?? 120),
                  ),
                ),
          ),
          children: paginatedData.asMap().entries.map((entry) {
            int index = entry.key;
            var detail = entry.value;
            Color rowColor = index % 2 == 0
                ? Colors.white
                : const Color.fromARGB(255, 245, 245, 245);

            return TableRow(
              decoration: BoxDecoration(color: rowColor),
              children: columnHeaders.map((header) {
                String cellValue = _getCellValue(detail, header);
                return Container(
                  height: 33,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade300),
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    cellValue,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getCellValue(dynamic detail, String header) {
    final key = _getKeyForHeader(header);
    if (key.isEmpty) return '';

    var value = detail[key];
    if (value == null) return '';

    // Special handling for numeric fields to display as integer
    if (key == 'truck_send_qty' ||
        key == 'customer_number' ||
        key == 'salesman_no') {
      return value.toInt().toString();
    }

    // Format dates if needed
    if (key == 'date' || key == 'delivery_date' || key == 'dispatch_date') {
      return value.toString().split('T')[0];
    }

    // Format numbers if needed
    if (value is double) {
      return value.toStringAsFixed(2);
    }

    return value.toString();
  }
}

// Model class for register details.
class RegisterDetail {
  final Map<String, dynamic> _data;

  RegisterDetail(this._data);

  // Factory constructor to create an instance from JSON
  factory RegisterDetail.fromJson(Map<String, dynamic> json) {
    // Convert all keys to lowercase for case-insensitive access
    Map<String, dynamic> lowercaseMap = {};
    json.forEach((key, value) {
      lowercaseMap[key.toLowerCase()] = value;
    });
    return RegisterDetail(lowercaseMap);
  }

  // Generic getter to access any field case-insensitively
  dynamic get(String field) {
    var value = _data[field.toLowerCase()];

    // Handle numeric conversions
    if (value != null) {
      if (field.toLowerCase().contains('qty') ||
          field.toLowerCase().contains('amount') ||
          field.toLowerCase().contains('cost')) {
        return double.tryParse(value.toString()) ?? 0.0;
      }
    }

    return value ?? '';
  }

  @override
  String toString() {
    return _data.toString();
  }
}

// class ResponsiveTablePage extends StatefulWidget {
//   final String? invoicestatus;
//   final String? columnName;
//   final String? columnValue;
//   final String? fromDate;
//   final String? endDate;

//   const ResponsiveTablePage(this.invoicestatus, this.columnName,
//       this.columnValue, this.fromDate, this.endDate,
//       {super.key});
//   @override
//   State<ResponsiveTablePage> createState() => _ResponsiveTablePageState();
// }

// class _ResponsiveTablePageState extends State<ResponsiveTablePage> {
//   final ScrollController _verticalController = ScrollController();
//   final ScrollController _horizontalController = ScrollController();
//   List<String> columnHeaders = [];
//   List<RegisterDetail> tableData = [];
//   bool isLoading = true;
//   String errorMessage = '';
//   Map<String, double> columnWidths = {};
//   int _currentPage = 1;
//   int _rowsPerPage = 10;
//   int get _startIndex => (_currentPage - 1) * _rowsPerPage;
//   int get _endIndex => math.min(_startIndex + _rowsPerPage, tableData.length);
//   int get _totalPages => (tableData.length / _rowsPerPage).ceil();

//   @override
//   void initState() {
//     super.initState();
//     fetchColumnHeaders(widget.invoicestatus);
//   }

//   @override
//   void didUpdateWidget(ResponsiveTablePage oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.columnName != widget.columnName ||
//         oldWidget.columnValue != widget.columnValue ||
//         oldWidget.fromDate != widget.fromDate ||
//         oldWidget.endDate != widget.endDate) {
//       fetchData();
//     }
//   }

//   // Calculate the width needed for a text
//   double _calculateTextWidth(String text, TextStyle style) {
//     final TextPainter textPainter = TextPainter(
//       text: TextSpan(text: text, style: style),
//       maxLines: 1,
//       textDirection:
//           ui.TextDirection.ltr, // Use ui.TextDirection to avoid ambiguity
//     )..layout(minWidth: 0, maxWidth: double.infinity);
//     return textPainter.width;
//   }

//   // Calculate column widths based on content
//   void _calculateColumnWidths() {
//     const headerStyle = TextStyle(
//       fontWeight: FontWeight.bold,
//       fontSize: 14,
//     );
//     const cellStyle = TextStyle(
//       fontSize: 13,
//     );

//     // Initialize with header widths
//     for (String header in columnHeaders) {
//       double headerWidth = _calculateTextWidth(header, headerStyle);
//       // Increase minimum width for longer headers
//       double minWidth = header.length > 15 ? 180.0 : 120.0;
//       columnWidths[header] = math.max(
//           headerWidth + 40, minWidth); // Increased padding and minimum width
//     }

//     // Check content widths
//     for (var row in tableData) {
//       for (String header in columnHeaders) {
//         String cellValue = getCellValue(row, header);
//         double contentWidth = _calculateTextWidth(cellValue, cellStyle);
//         double currentWidth = columnWidths[header] ?? 0;
//         columnWidths[header] = math.max(currentWidth, contentWidth + 40);
//       }
//     }

//     // Set minimum and maximum constraints with special handling for long headers
//     columnWidths.forEach((key, value) {
//       double minWidth = key.length > 15 ? 180.0 : 120.0;
//       columnWidths[key] = math.min(
//           math.max(value, minWidth), 350.0); // Increased max width to 350
//     });
//   }

//   Future<void> fetchColumnHeaders(String? invoicestatus) async {
//     print("invoice status ${widget.invoicestatus}");

//     final IpAddress = await getActiveIpAddress();

//     final columnUrl = Uri.parse(
//         '$IpAddress/GetUndeliveredDataColumnNameview/${widget.invoicestatus}/');

//     try {
//       final response = await http.get(columnUrl);
//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);

//         if (data.isEmpty) {
//           throw Exception("Column names list is empty.");
//         }

//         setState(() {
//           columnHeaders = data.cast<String>();
//           isLoading = false;
//         });

//         // After getting columns, fetch the data
//         await fetchData();
//       } else {
//         throw Exception(
//             'Failed to load column headers. Status: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Error fetching column headers: $e';
//         isLoading = false;
//       });
//       print(errorMessage);
//     }
//   }

//   String formatDate(String date) {
//     try {
//       DateTime parsedDate = DateFormat("dd-MMM-yyyy").parse(date);
//       return DateFormat("yyyy-MM-dd").format(parsedDate);
//     } catch (e) {
//       return date; // Return original if parsing fails
//     }
//   }

//   Future<void> fetchData() async {
//     print("Fetching All Data with:");

//     print("invoicestatus Name: ${widget.invoicestatus}");
//     print("Column Name: ${widget.columnName}");
//     print("Column Value: ${widget.columnValue}");
//     print("From Date: ${widget.fromDate}");
//     print("End Date: ${widget.endDate}");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String salesloginrole = prefs.getString('salesloginrole') ?? '';
//     String salesloginno = (salesloginrole == 'Salesman')
//         ? (prefs.getString('salesloginno') ?? '')
//         : '';
//     print("Salesman No : $salesloginno");

//     String fromdatefinal = '${widget.fromDate}';
//     String formattedfromdate = formatDate(fromdatefinal);

//     String enddatefinal = '${widget.endDate}';
//     String formattedenddate = formatDate(enddatefinal);
//     print("formattedfromdate: ${formattedfromdate} ${formattedenddate}");

//     final IpAddress = await getActiveIpAddress();

//     String apiUrl =
//         "$IpAddress/InvoiceReportsUndeliveredDataView/${widget.invoicestatus}/$salesloginno/${widget.columnName}/${widget.columnValue}/$formattedfromdate/$formattedenddate/";
//     List<RegisterDetail> allData = [];

//     print("irlsssss $apiUrl");

//     try {
//       while (apiUrl.isNotEmpty) {
//         final response = await http.get(Uri.parse(apiUrl));

//         print("Fetching from URL: $apiUrl");

//         if (response.statusCode == 200) {
//           final jsonResponse = json.decode(response.body);
//           List<dynamic> results = jsonResponse['results'] ?? [];

//           allData.addAll(
//               results.map((item) => RegisterDetail.fromJson(item)).toList());

//           // Check if there is a next page
//           apiUrl = jsonResponse['next'] ?? "";
//         } else {
//           throw Exception(
//               "Failed to load data, status code: ${response.statusCode}");
//         }
//       }

//       setState(() {
//         tableData = allData;
//         _calculateColumnWidths();
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Error fetching data: $e';
//         isLoading = false;
//       });
//       print("Error fetching data: $e");
//     }
//   }

//   @override
//   void dispose() {
//     _verticalController.dispose();
//     _horizontalController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double totalWidth = columnHeaders.fold<double>(
//       0,
//       (sum, header) => sum + (columnWidths[header] ?? 120),
//     );

//     return Container(
//       height: 350,
//       child: Column(
//         children: [
//           Expanded(
//             child: RawScrollbar(
//               controller: _horizontalController,
//               thumbVisibility: true,
//               trackVisibility: true,
//               thickness: 9,
//               thumbColor: const ui.Color.fromARGB(255, 103, 103, 103),
//               trackColor:
//                   const ui.Color.fromARGB(255, 78, 78, 78).withOpacity(0.2),
//               radius: const Radius.circular(8),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 controller: _horizontalController,
//                 child: Container(
//                   width: totalWidth + 18,
//                   decoration: BoxDecoration(
//                     color: const ui.Color.fromARGB(255, 248, 248, 248),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: isLoading
//                       ? const Center(child: CircularProgressIndicator())
//                       : errorMessage.isNotEmpty
//                           ? Center(child: Text(errorMessage))
//                           : _buildDesktopView(context, tableData),
//                 ),
//               ),
//             ),
//           ),
//           // Fixed Pagination Controls
//           Container(
//               width: MediaQuery.of(context).size.width,
//               child: Responsive.isMobile(context)
//                   ? SingleChildScrollView(
//                       scrollDirection: Axis.horizontal, child: pagesetupd())
//                   : pagesetupd()),
//         ],
//       ),
//     );
//   }

//   Widget pagesetupd() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         Container(
//           width: 430,
//           padding: EdgeInsets.symmetric(vertical: 8),
//           decoration: BoxDecoration(
//             border: Border(
//               top: BorderSide(color: Colors.grey.shade300),
//             ),
//           ),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               // mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 SizedBox(width: 16),
//                 IconButton(
//                   icon: Icon(Icons.first_page),
//                   onPressed: _currentPage > 1
//                       ? () {
//                           setState(() {
//                             _currentPage = 1;
//                           });
//                         }
//                       : null,
//                   color: _currentPage > 1 ? Colors.blue : Colors.grey,
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.chevron_left),
//                   onPressed: _currentPage > 1
//                       ? () {
//                           setState(() {
//                             _currentPage--;
//                           });
//                         }
//                       : null,
//                   color: _currentPage > 1 ? Colors.blue : Colors.grey,
//                 ),
//                 SizedBox(width: 16),
//                 Text(
//                   'Page $_currentPage of $_totalPages',
//                   style: TextStyle(fontSize: 14),
//                 ),
//                 SizedBox(width: 16),
//                 IconButton(
//                   icon: Icon(Icons.chevron_right),
//                   onPressed: _currentPage < _totalPages
//                       ? () {
//                           setState(() {
//                             _currentPage++;
//                           });
//                         }
//                       : null,
//                   color: _currentPage < _totalPages ? Colors.blue : Colors.grey,
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.last_page),
//                   onPressed: _currentPage < _totalPages
//                       ? () {
//                           setState(() {
//                             _currentPage = _totalPages;
//                           });
//                         }
//                       : null,
//                   color: _currentPage < _totalPages ? Colors.blue : Colors.grey,
//                 ),
//                 SizedBox(width: 24),
//                 DropdownButton<int>(
//                   value: _rowsPerPage,
//                   items: [10, 15, 20, 30, 50].map((int value) {
//                     return DropdownMenuItem<int>(
//                       value: value,
//                       child: Text('$value rows'),
//                     );
//                   }).toList(),
//                   onChanged: (int? newValue) {
//                     if (newValue != null) {
//                       setState(() {
//                         _rowsPerPage = newValue;
//                         _currentPage = 1;
//                       });
//                     }
//                   },
//                 ),
//                 SizedBox(width: 16),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDesktopView(BuildContext context, List<RegisterDetail> data) {
//     return Container(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         children: [
//           // Header
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.grey.shade200,
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: Row(
//               children: columnHeaders.map((header) {
//                 return Container(
//                   width: columnWidths[header] ?? 120,
//                   height: 35,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     border: Border(
//                       right: BorderSide(color: Colors.grey.shade300),
//                     ),
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   child: Text(
//                     header,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 13,
//                       height: 1.1,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.center,
//                     maxLines: 2,
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//           // Table Content
//           Expanded(
//             child: RawScrollbar(
//               controller: _verticalController,
//               thumbVisibility: true,
//               trackVisibility: true,
//               thickness: 9,
//               thumbColor: const ui.Color.fromARGB(255, 103, 103, 103),
//               trackColor:
//                   const ui.Color.fromARGB(255, 78, 78, 78).withOpacity(0.2),
//               radius: const Radius.circular(8),
//               child: SingleChildScrollView(
//                 controller: _verticalController,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     border: Border.all(color: Colors.grey.shade300),
//                   ),
//                   child: _buildDataRows(context, data),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDataRows(BuildContext context, List<RegisterDetail> data) {
//     // Get only the data for the current page
//     final paginatedData = data.sublist(_startIndex, _endIndex);

//     return Column(
//       children: [
//         Table(
//           columnWidths: Map.fromEntries(
//             columnHeaders.asMap().entries.map(
//                   (entry) => MapEntry(
//                     entry.key,
//                     FixedColumnWidth(columnWidths[entry.value] ?? 120),
//                   ),
//                 ),
//           ),
//           children: paginatedData.asMap().entries.map((entry) {
//             int index = entry.key;
//             RegisterDetail detail = entry.value;
//             Color rowColor = index % 2 == 0
//                 ? Colors.white
//                 : const Color.fromARGB(255, 255, 255, 255);

//             return TableRow(
//               decoration: BoxDecoration(color: rowColor),
//               children: columnHeaders.map((header) {
//                 String cellValue = getCellValue(detail, header);
//                 return Container(
//                   height: 33,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     border: Border(
//                       right: BorderSide(color: Colors.grey.shade300),
//                       bottom: BorderSide(color: Colors.grey.shade300),
//                     ),
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   child: Text(
//                     cellValue,
//                     style: const TextStyle(
//                       color: Colors.black87,
//                       fontSize: 12,
//                       height: 1.1,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.center,
//                     maxLines: 2,
//                   ),
//                 );
//               }).toList(),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

// // Function to get cell value dynamically
//   String getCellValue(RegisterDetail detail, String header) {
//     var value = detail.get(header);

//     // Convert the value to string, handling different types
//     if (value is double) {
//       return value.toString();
//     } else if (value is int) {
//       return value.toString();
//     } else if (value is String) {
//       return value;
//     } else if (value == null) {
//       return '';
//     }

//     return value.toString();
//   }
// }
