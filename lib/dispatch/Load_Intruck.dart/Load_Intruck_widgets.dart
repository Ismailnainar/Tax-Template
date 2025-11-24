import 'package:flutter/material.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'Loadin_Intruck_controller.dart';

class LiveStagingWidgets {
  static Widget buildCardView(BuildContext context,
      LiveStagingController controller, Function togglePage) {
    print("controller.isLoadingData ${controller.isLoadingData}");

    // Use ListenableBuilder to automatically rebuild when controller changes
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        if (controller.isLoadingData) {
          return Container(
            height: 200, // Adjust height as needed
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Modern shimmer animation with gradient
                SizedBox(
                  width: 30,
                  height: 30,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                      ),
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                        value:
                            null, // This creates the indeterminate spinning effect
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Optional loading text with fade animation
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    'Loading Staging data...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Optional subtle progress indicator
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                    minHeight: 2,
                  ),
                ),
              ],
            ),
          );
        }

        final visibleData = controller.filteredData.where((data) {
          final scanned =
              int.tryParse(data['scannedqty']?.toString() ?? '0') ?? 0;
          final previous =
              int.tryParse(data['previous_truck_qty']?.toString() ?? '0') ?? 0;
          return scanned != previous;
        }).toList();

        if (visibleData.isEmpty) {
          return Container(
            height: 100,
            child: const Center(
              child: Text(
                "No data available in live stage",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: visibleData.asMap().entries.map((entry) {
              int index = entry.key;
              var data = entry.value;

              var scannedqty = data['scannedqty'];
              var previous_truck_qty = data['previous_truck_qty'];
              var totalscannedqty = (data['scannedqty'] ?? 0) is num
                  ? (data['scannedqty'] ?? 0)
                  : num.tryParse(data['scannedqty']?.toString() ?? '0') ?? 0;
              var totalprevious_truck_qty =
                  (data['previous_truck_qty'] ?? 0) is num
                      ? (data['previous_truck_qty'] ?? 0)
                      : num.tryParse(
                              data['previous_truck_qty']?.toString() ?? '0') ??
                          0;

              final total_scan_count = data['total_scan_count'];
              var balanceqty = totalscannedqty - totalprevious_truck_qty;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt_long, color: Colors.blue),
                          SizedBox(width: 8),
                          Text("Request No: ${data['reqno']}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.confirmation_number,
                              color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text("Pick ID: ${data['pickid']}"),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.green),
                          SizedBox(width: 8),
                          Expanded(
                              child: Text("Customer Name: ${data['cusname']}")),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Expanded(
                              child: Text("Customer Site: ${data['cussite']}")),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.inventory, color: Colors.orange),
                          SizedBox(width: 8),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Roboto',
                                  fontSize: 16),
                              children: [
                                TextSpan(text: "Scanned Qty: "),
                                TextSpan(
                                    text: "$total_scan_count",
                                    style: TextStyle(color: Colors.green)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_getButtonLabel(data['status']),
                              style: TextStyle(
                                  fontSize: 13,
                                  color: _getButtonColor(data['status']))),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              color: _getButtonColor(data['status']),
                              onPressed: () async {
                                await togglePage(
                                  data['reqno'].toString(),
                                  data['pickid'].toString(),
                                  data['cusno'].toString(),
                                  data['cusname'].toString(),
                                  data['cussite'].toString(),
                                  "$balanceqty",
                                );
                              },
                              icon: Icon(Icons.qr_code_scanner,
                                  color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                backgroundColor:
                                    _getButtonColor(data['status']),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  static Widget buildTable(
      BuildContext context,
      LiveStagingController controller,
      ScrollController horizontalScrollController,
      Function togglePage) {
    // Use ListenableBuilder for table view too
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final isDesktop = Responsive.isDesktop(context);
        final screenWidth = MediaQuery.of(context).size.width;

        final tableWidth = isDesktop ? screenWidth * 0.8 : screenWidth;
        final columnWidths = {
          0: isDesktop ? screenWidth * 0.04 : 70.0,
          1: isDesktop ? screenWidth * 0.07 : 100.0,
          2: isDesktop ? screenWidth * 0.07 : 100.0,
          3: isDesktop ? screenWidth * 0.07 : 100.0,
          4: isDesktop ? screenWidth * 0.25 : 200.0,
          5: isDesktop ? screenWidth * 0.07 : 100.0,
          6: isDesktop ? screenWidth * 0.12 : 100.0,
          7: isDesktop ? screenWidth * 0.1 : 100.0,
        };

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[400]!, width: 1.0),
          ),
          width: tableWidth,
          child: Stack(
            children: [
              ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: MaterialStateProperty.all(Colors.grey[600]),
                  thumbVisibility: MaterialStateProperty.all(true),
                  thickness: MaterialStateProperty.all(8),
                  radius: const Radius.circular(10),
                ),
                child: Scrollbar(
                  controller: horizontalScrollController,
                  child: SingleChildScrollView(
                    controller: horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: tableWidth),
                      child: Column(
                        children: [
                          _buildTableHeader(columnWidths, isDesktop),
                          if (controller.isLoadingData)
                            Container(
                              height: 200, // Adjust height as needed
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Modern shimmer animation with gradient
                                  SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          strokeWidth: 4,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Theme.of(context).primaryColor,
                                          ),
                                          value:
                                              null, // This creates the indeterminate spinning effect
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Optional loading text with fade animation
                                  AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: const Duration(milliseconds: 500),
                                    child: Text(
                                      'Loading Staging data...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Optional subtle progress indicator
                                  SizedBox(
                                    width: 120,
                                    child: LinearProgressIndicator(
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).primaryColor,
                                      ),
                                      minHeight: 2,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (controller.filteredData.isNotEmpty)
                            _buildTableBody(
                                columnWidths, isDesktop, controller, togglePage)
                          else
                            Container(
                                height: 100,
                                child: Center(
                                    child: Text(
                                        "No data available in live stage"))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isDesktop) _buildScrollArrows(horizontalScrollController),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildTableHeader(
      Map<int, double> columnWidths, bool isDesktop) {
    final headers = [
      {"icon": Icons.format_list_numbered, "text": "Sno"},
      {"icon": Icons.receipt_long, "text": "Req No"},
      {"icon": Icons.qr_code, "text": "Pick Id"},
      {"icon": Icons.account_circle, "text": "Cus No"},
      {"icon": Icons.person, "text": "Cus Name"},
      {"icon": Icons.person, "text": "Cus Site"},
      {"icon": Icons.info_outline, "text": "Scanned Qty"},
      {"icon": Icons.edit, "text": "Action"},
    ];

    return Container(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: headers.asMap().entries.map((entry) {
          final index = entry.key;
          final header = entry.value;
          return Container(
            height: isDesktop ? 25 : 30,
            width: columnWidths[index],
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(header["icon"] as IconData,
                        size: 15, color: Colors.blue),
                    const SizedBox(width: 5),
                    Text(
                      header["text"] as String,
                      style: TextStyle(
                        fontSize: isDesktop ? 12 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  static Widget _buildTableBody(Map<int, double> columnWidths, bool isDesktop,
      LiveStagingController controller, Function togglePage) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: controller.filteredData
              .map((data) => _buildTableRow(data, columnWidths, isDesktop,
                  controller.filteredData.indexOf(data), togglePage))
              .toList(),
        ),
      ),
    );
  }

  static Widget _buildTableRow(
      Map<String, dynamic> data,
      Map<int, double> columnWidths,
      bool isDesktop,
      int index,
      Function togglePage) {
    final scannedqty = int.tryParse(data['scannedqty'].toString()) ?? 0;
    final previousTruckQty =
        int.tryParse(data['previous_truck_qty'].toString()) ?? 0;

    if (scannedqty == previousTruckQty) {
      return SizedBox.shrink();
    }

    final balanceqty = scannedqty - previousTruckQty;
    final status = data['status'];
    final isEvenRow = index % 2 == 0;
    final rowColor = isEvenRow
        ? Color.fromARGB(224, 255, 255, 255)
        : Color.fromARGB(223, 239, 239, 239);

    final total_scan_count = data['total_scan_count'];
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: rowColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTableCell(columnWidths[0]!,
                Text((index + 1).toString(), style: TextStyle(fontSize: 12))),
            _buildTableCell(columnWidths[1]!,
                Text(data['reqno'].toString(), style: TextStyle(fontSize: 12))),
            _buildTableCell(
                columnWidths[2]!,
                Text(data['pickid'].toString(),
                    style: TextStyle(fontSize: 12))),
            _buildTableCell(columnWidths[3]!,
                Text(data['cusno'].toString(), style: TextStyle(fontSize: 12))),
            _buildTableCell(
                columnWidths[4]!,
                Tooltip(
                  message: data['cusname'].toString(),
                  child: Text(data['cusname'].toString(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12)),
                )),
            _buildTableCell(
                columnWidths[5]!,
                Text(data['cussite'].toString(),
                    style: TextStyle(fontSize: 12))),
            // _buildTableCell(
            //     columnWidths[6]!, _buildQuantityTableRow(data, isDesktop)),

            _buildTableCell(
              columnWidths[6]!,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "$total_scan_count",
                    style: TextStyle(
                      color: Color.fromARGB(255, 154, 52, 52),
                      fontSize: isDesktop ? 14 : 12,
                    ),
                  ),
                ],
              ),
            ),
            _buildTableCell(
                columnWidths[7]!,
                _buildActionButton(
                    data, balanceqty, status, isDesktop, togglePage)),
          ],
        ),
      ),
    );
  }

  static Widget _buildTableCell(double width, Widget child) {
    return Container(
      height: 30,
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(255, 226, 225, 225))),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, child: child),
      ),
    );
  }

  static Widget _buildQuantityTableRow(
      Map<String, dynamic> data, bool isDesktop) {
    final scannedqty = int.tryParse(data['scannedqty'].toString()) ?? 0;
    final previousTruckQty =
        int.tryParse(data['previous_truck_qty'].toString()) ?? 0;
    final loadscanqty = int.tryParse(data['loadscanqty'].toString()) ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Tooltip(
            message: 'Scanned Qty',
            child: Text("$scannedqty",
                style: TextStyle(
                    color: Color.fromARGB(255, 65, 147, 72),
                    fontSize: isDesktop ? 14 : 12))),
        SizedBox(width: 10),
        Text("-", style: TextStyle(fontSize: isDesktop ? 14 : 12)),
        SizedBox(width: 10),
        Tooltip(
            message: 'Already Trucked Qty',
            child: Text("$previousTruckQty",
                style: TextStyle(
                    color: Color.fromARGB(255, 65, 147, 72),
                    fontSize: isDesktop ? 14 : 12))),
        SizedBox(width: 10),
        Text("-", style: TextStyle(fontSize: isDesktop ? 14 : 12)),
        SizedBox(width: 10),
        Tooltip(
            message: 'Load Scan Qty',
            child: Text("$loadscanqty",
                style: TextStyle(
                    color: Color.fromARGB(255, 154, 52, 52),
                    fontSize: isDesktop ? 14 : 12))),
      ],
    );
  }

  static Widget _buildActionButton(Map<String, dynamic> data, int balanceqty,
      String status, bool isDesktop, Function togglePage) {
    return ElevatedButton(
      onPressed: () async {
        await togglePage(
          data['reqno'].toString(),
          data['pickid'].toString(),
          data['cusno'].toString(),
          data['cusname'].toString(),
          data['cussite'].toString(),
          "$balanceqty",
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _getButtonColor(status),
        minimumSize: Size(isDesktop ? 45.0 : 35.0, 31.0),
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 12 : 8),
      ),
      child: isDesktop
          ? Text(_getButtonLabel(status), style: commonWhiteStyle)
          : Icon(Icons.qr_code_scanner, size: 15),
    );
  }

  static Widget _buildScrollArrows(ScrollController controller) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_left_outlined,
                color: Colors.blueAccent, size: 30),
            onPressed: () {
              controller.animateTo(
                controller.offset - 100,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_right_outlined,
                color: Colors.blueAccent, size: 30),
            onPressed: () {
              controller.animateTo(
                controller.offset + 100,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  // ... rest of the methods remain the same as your original code
  // _buildTable, _buildTableHeader, _buildTableBody, etc.

  static String _getButtonLabel(String status) {
    if (status == "Completed") {
      return "Scan Completed";
    } else if (status == "Processing") {
      return "Processing";
    } else {
      return "Load to Truck";
    }
  }

  static Color _getButtonColor(String status) {
    if (status == "Completed") {
      return Colors.green;
    } else if (status == "Processing") {
      return Colors.purple;
    } else {
      return buttonColor;
    }
  }
}



// import 'package:flutter/material.dart';
// import 'package:aljeflutterapp/components/Responsive.dart';
// import 'package:aljeflutterapp/components/Style.dart';
// import 'live_staging_controller.dart';

// class LiveStagingWidgets {
//   static Widget buildCardView(BuildContext context,
//       LiveStagingController controller, Function togglePage) {
//     print("controller.isLoadingData ${controller.isLoadingData}");
//     if (controller.isLoadingData) {
//       return Container(
//         height: 200,
//         child: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     final visibleData = controller.filteredData.where((data) {
//       final scanned =
//           int.tryParse(data['scannedqty'].toString().split('.').first) ?? 0;
//       final previous = int.tryParse(
//               data['previous_truck_qty'].toString().split('.').first) ??
//           0;
//       return scanned != previous;
//     }).toList();

//     if (visibleData.isEmpty) {
//       return Container(
//         height: 100,
//         child: const Center(
//           child: Text(
//             "No data available in live stage",
//             style: TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//         ),
//       );
//     }

//     return SingleChildScrollView(
//       child: Column(
//         children: visibleData.asMap().entries.map((entry) {
//           int index = entry.key;
//           var data = entry.value;

//           String sNo = (index + 1).toString();
//           var cusname = data['cusname'];
//           var reqno = data['reqno'];
//           var pickid = data['pickid'];
//           var cussite = data['cussite'];
//           var loadscanqty = data['loadscanqty'];
//           var scannedqty = data['scannedqty'];
//           var sno = data['id'].toString();
//           var onlyreqno = "$reqno";
//           var onlypickid = "$pickid";
//           var cusno = data['cusno'];
//           var status = data['status'];
//           var previous_truck_qty = data['previous_truck_qty'];
//           var totalscannedqty = (data['scannedqty'] ?? 0) is num
//               ? (data['scannedqty'] ?? 0)
//               : num.tryParse(data['scannedqty'].toString()) ?? 0;
//           var totalprevious_truck_qty = (data['previous_truck_qty'] ?? 0) is num
//               ? (data['previous_truck_qty'] ?? 0)
//               : num.tryParse(data['previous_truck_qty'].toString()) ?? 0;

//           var balanceqty = totalscannedqty - totalprevious_truck_qty;

//           print("balanceqty card $balanceqty");
//           int finalqty =
//               int.tryParse(loadscanqty.toString().split('.').first) ?? 0;

//           return Card(
//             margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//             elevation: 4,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.receipt_long, color: Colors.blue),
//                       SizedBox(width: 8),
//                       Text("Request No: $reqno",
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//                   SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Icon(Icons.confirmation_number, color: Colors.deepPurple),
//                       SizedBox(width: 8),
//                       Text("Pick ID: $pickid"),
//                     ],
//                   ),
//                   SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Icon(Icons.person, color: Colors.green),
//                       SizedBox(width: 8),
//                       Expanded(child: Text("Customer Name: $cusname")),
//                     ],
//                   ),
//                   SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Icon(Icons.location_on, color: Colors.redAccent),
//                       SizedBox(width: 8),
//                       Expanded(child: Text("Customer Site: $cussite")),
//                     ],
//                   ),
//                   SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Icon(Icons.inventory, color: Colors.orange),
//                       SizedBox(width: 8),
//                       RichText(
//                         text: TextSpan(
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontFamily: 'Roboto',
//                               fontSize: 16),
//                           children: [
//                             TextSpan(text: "Picked Qty: "),
//                             TextSpan(
//                                 text: "$scannedqty",
//                                 style: TextStyle(color: Colors.green)),
//                             TextSpan(text: " - "),
//                             TextSpan(
//                                 text: "$previous_truck_qty",
//                                 style: TextStyle(color: Colors.red)),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(_getButtonLabel(status),
//                           style: TextStyle(
//                               fontSize: 13, color: _getButtonColor(status))),
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: IconButton(
//                           color: _getButtonColor(status),
//                           onPressed: () async {
//                             await togglePage(
//                               data['reqno'].toString(),
//                               data['pickid'].toString(),
//                               data['cusno'].toString(),
//                               data['cusname'].toString(),
//                               data['cussite'].toString(),
//                               "$balanceqty",
//                             );
//                           },
//                           icon:
//                               Icon(Icons.qr_code_scanner, color: Colors.white),
//                           style: ElevatedButton.styleFrom(
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8)),
//                             backgroundColor: _getButtonColor(status),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   static Widget buildTable(
//       BuildContext context,
//       LiveStagingController controller,
//       ScrollController horizontalScrollController,
//       Function togglePage) {
//     final isDesktop = Responsive.isDesktop(context);
//     final screenWidth = MediaQuery.of(context).size.width;

//     final tableWidth = isDesktop ? screenWidth * 0.8 : screenWidth;
//     final columnWidths = {
//       0: isDesktop ? screenWidth * 0.04 : 70.0,
//       1: isDesktop ? screenWidth * 0.07 : 100.0,
//       2: isDesktop ? screenWidth * 0.07 : 100.0,
//       3: isDesktop ? screenWidth * 0.07 : 100.0,
//       4: isDesktop ? screenWidth * 0.25 : 200.0,
//       5: isDesktop ? screenWidth * 0.07 : 100.0,
//       6: isDesktop ? screenWidth * 0.12 : 100.0,
//       7: isDesktop ? screenWidth * 0.1 : 100.0,
//     };

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: Colors.grey[400]!, width: 1.0),
//       ),
//       width: tableWidth,
//       child: Stack(
//         children: [
//           ScrollbarTheme(
//             data: ScrollbarThemeData(
//               thumbColor: MaterialStateProperty.all(Colors.grey[600]),
//               thumbVisibility: MaterialStateProperty.all(true),
//               thickness: MaterialStateProperty.all(8),
//               radius: const Radius.circular(10),
//             ),
//             child: Scrollbar(
//               controller: horizontalScrollController,
//               child: SingleChildScrollView(
//                 controller: horizontalScrollController,
//                 scrollDirection: Axis.horizontal,
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(minWidth: tableWidth),
//                   child: Column(
//                     children: [
//                       _buildTableHeader(columnWidths, isDesktop),
//                       if (controller.isLoadingData)
//                         Container(
//                             height: 200,
//                             child: Center(child: CircularProgressIndicator()))
//                       else if (controller.filteredData.isNotEmpty)
//                         _buildTableBody(
//                             columnWidths, isDesktop, controller, togglePage)
//                       else
//                         Container(
//                             height: 100,
//                             child: Center(
//                                 child:
//                                     Text("No data available in live stage"))),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           if (isDesktop) _buildScrollArrows(horizontalScrollController),
//         ],
//       ),
//     );
//   }

//   static Widget _buildTableHeader(
//       Map<int, double> columnWidths, bool isDesktop) {
//     final headers = [
//       {"icon": Icons.format_list_numbered, "text": "Sno"},
//       {"icon": Icons.receipt_long, "text": "Req No"},
//       {"icon": Icons.qr_code, "text": "Pick Id"},
//       {"icon": Icons.account_circle, "text": "Cus No"},
//       {"icon": Icons.person, "text": "Cus Name"},
//       {"icon": Icons.person, "text": "Cus Site"},
//       {"icon": Icons.info_outline, "text": "Picked Qty"},
//       {"icon": Icons.edit, "text": "Action"},
//     ];

//     return Container(
//       padding: const EdgeInsets.only(bottom: 5.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: headers.asMap().entries.map((entry) {
//           final index = entry.key;
//           final header = entry.value;
//           return Container(
//             height: isDesktop ? 25 : 30,
//             width: columnWidths[index],
//             decoration: BoxDecoration(
//               color: Colors.blue[50],
//               border: Border.all(color: Colors.grey[300]!),
//             ),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Icon(header["icon"] as IconData,
//                         size: 15, color: Colors.blue),
//                     const SizedBox(width: 5),
//                     Text(
//                       header["text"] as String,
//                       style: TextStyle(
//                         fontSize: isDesktop ? 12 : 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   static Widget _buildTableBody(Map<int, double> columnWidths, bool isDesktop,
//       LiveStagingController controller, Function togglePage) {
//     return Expanded(
//       child: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: Column(
//           children: controller.filteredData
//               .map((data) => _buildTableRow(data, columnWidths, isDesktop,
//                   controller.filteredData.indexOf(data), togglePage))
//               .toList(),
//         ),
//       ),
//     );
//   }

//   static Widget _buildTableRow(
//       Map<String, dynamic> data,
//       Map<int, double> columnWidths,
//       bool isDesktop,
//       int index,
//       Function togglePage) {
//     final scannedqty = int.tryParse(data['scannedqty'].toString()) ?? 0;
//     final previousTruckQty =
//         int.tryParse(data['previous_truck_qty'].toString()) ?? 0;

//     if (scannedqty == previousTruckQty) {
//       return SizedBox.shrink();
//     }

//     final balanceqty = scannedqty - previousTruckQty;
//     final status = data['status'];
//     final isEvenRow = index % 2 == 0;
//     final rowColor = isEvenRow
//         ? Color.fromARGB(224, 255, 255, 255)
//         : Color.fromARGB(223, 239, 239, 239);

//     return GestureDetector(
//       onTap: () {},
//       child: Container(
//         color: rowColor,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             _buildTableCell(columnWidths[0]!,
//                 Text((index + 1).toString(), style: TextStyle(fontSize: 12))),
//             _buildTableCell(columnWidths[1]!,
//                 Text(data['reqno'].toString(), style: TextStyle(fontSize: 12))),
//             _buildTableCell(
//                 columnWidths[2]!,
//                 Text(data['pickid'].toString(),
//                     style: TextStyle(fontSize: 12))),
//             _buildTableCell(columnWidths[3]!,
//                 Text(data['cusno'].toString(), style: TextStyle(fontSize: 12))),
//             _buildTableCell(
//                 columnWidths[4]!,
//                 Tooltip(
//                   message: data['cusname'].toString(),
//                   child: Text(data['cusname'].toString(),
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(fontSize: 12)),
//                 )),
//             _buildTableCell(
//                 columnWidths[5]!,
//                 Text(data['cussite'].toString(),
//                     style: TextStyle(fontSize: 12))),
//             _buildTableCell(
//                 columnWidths[6]!, _buildQuantityTableRow(data, isDesktop)),
//             _buildTableCell(
//                 columnWidths[7]!,
//                 _buildActionButton(
//                     data, balanceqty, status, isDesktop, togglePage)),
//           ],
//         ),
//       ),
//     );
//   }

//   static Widget _buildTableCell(double width, Widget child) {
//     return Container(
//       height: 30,
//       width: width,
//       padding: const EdgeInsets.symmetric(horizontal: 4.0),
//       decoration: BoxDecoration(
//           border: Border.all(color: Color.fromARGB(255, 226, 225, 225))),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal, child: child),
//       ),
//     );
//   }

//   static Widget _buildQuantityTableRow(
//       Map<String, dynamic> data, bool isDesktop) {
//     final scannedqty = int.tryParse(data['scannedqty'].toString()) ?? 0;
//     final previousTruckQty =
//         int.tryParse(data['previous_truck_qty'].toString()) ?? 0;
//     final loadscanqty = int.tryParse(data['loadscanqty'].toString()) ?? 0;

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Tooltip(
//             message: 'Scanned Qty',
//             child: Text("$scannedqty",
//                 style: TextStyle(
//                     color: Color.fromARGB(255, 65, 147, 72),
//                     fontSize: isDesktop ? 14 : 12))),
//         SizedBox(width: 10),
//         Text("-", style: TextStyle(fontSize: isDesktop ? 14 : 12)),
//         SizedBox(width: 10),
//         Tooltip(
//             message: 'Already Trucked Qty',
//             child: Text("$previousTruckQty",
//                 style: TextStyle(
//                     color: Color.fromARGB(255, 65, 147, 72),
//                     fontSize: isDesktop ? 14 : 12))),
//         SizedBox(width: 10),
//         Text("-", style: TextStyle(fontSize: isDesktop ? 14 : 12)),
//         SizedBox(width: 10),
//         Tooltip(
//             message: 'Load Scan Qty',
//             child: Text("$loadscanqty",
//                 style: TextStyle(
//                     color: Color.fromARGB(255, 154, 52, 52),
//                     fontSize: isDesktop ? 14 : 12))),
//       ],
//     );
//   }

//   static Widget _buildActionButton(Map<String, dynamic> data, int balanceqty,
//       String status, bool isDesktop, Function togglePage) {
//     return ElevatedButton(
//       onPressed: () async {
//         await togglePage(
//           data['reqno'].toString(),
//           data['pickid'].toString(),
//           data['cusno'].toString(),
//           data['cusname'].toString(),
//           data['cussite'].toString(),
//           "$balanceqty",
//         );
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: _getButtonColor(status),
//         minimumSize: Size(isDesktop ? 45.0 : 35.0, 31.0),
//         padding: EdgeInsets.symmetric(horizontal: isDesktop ? 12 : 8),
//       ),
//       child: isDesktop
//           ? Text(_getButtonLabel(status), style: commonWhiteStyle)
//           : Icon(Icons.qr_code_scanner, size: 15),
//     );
//   }

//   static Widget _buildScrollArrows(ScrollController controller) {
//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           IconButton(
//             icon: Icon(Icons.arrow_left_outlined,
//                 color: Colors.blueAccent, size: 30),
//             onPressed: () {
//               controller.animateTo(
//                 controller.offset - 100,
//                 duration: Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//               );
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.arrow_right_outlined,
//                 color: Colors.blueAccent, size: 30),
//             onPressed: () {
//               controller.animateTo(
//                 controller.offset + 100,
//                 duration: Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   static String _getButtonLabel(String status) {
//     if (status == "Completed") {
//       return "Scan Completed";
//     } else if (status == "Processing") {
//       return "Processing";
//     } else {
//       return "Load to Truck";
//     }
//   }

//   static Color _getButtonColor(String status) {
//     if (status == "Completed") {
//       return Colors.green;
//     } else if (status == "Processing") {
//       return Colors.purple;
//     } else {
//       return buttonColor;
//     }
//   }
// }
