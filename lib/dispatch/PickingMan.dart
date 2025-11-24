import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart'
    hide Column, Row, Border, Stack;
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_svg/flutter_svg.dart';

class PickingManpage extends StatefulWidget {
  final Function togglePage;

  PickingManpage(this.togglePage);
  @override
  State<PickingManpage> createState() => _PickingManpageState();
}

class _PickingManpageState extends State<PickingManpage> {
  bool _isLoading2 = true;

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  TextEditingController totalpickmanqtyController = TextEditingController();

  Widget _buildTextFieldDesktop(
    String label,
    String value,
    IconData icon,
    bool readOnly,
  ) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: Responsive.isDesktop(context)
          ? screenWidth * 0.13
          : screenWidth * 0.4,
      child: Padding(
        padding: const EdgeInsets.only(left: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Text(label, style: TextStyle(fontSize: 13)),
                if (!readOnly)
                  Icon(
                    Icons.star,
                    size: 8,
                    color: Colors.red,
                  )
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 0, bottom: 0),
              child: Row(
                children: [
                  Container(
                      height: 32,
                      // width: Responsive.isDesktop(context)
                      //     ? screenWidth * 0.086
                      //     : 130,

                      width: Responsive.isDesktop(context)
                          ? screenWidth * 0.13
                          : screenWidth * 0.4,
                      child: MouseRegion(
                        onEnter: (event) {
                          // You can perform any action when mouse enters, like logging the value.
                        },
                        onExit: (event) {
                          // Perform any action when the mouse leaves the TextField area.
                        },
                        cursor: SystemMouseCursors
                            .click, // Changes the cursor to indicate interaction
                        child: Tooltip(
                          message: value,
                          child: TextFormField(
                            readOnly: readOnly,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(201, 132, 132, 132),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 58, 58, 58),
                                  width: 1.0,
                                ),
                              ),
                              filled: true, // Enable the background fill
                              fillColor: readOnly
                                  ? Color.fromARGB(255, 234, 234,
                                      234) // Change fill color when readOnly is true
                                  : Color.fromARGB(255, 250, 250,
                                      250), // Default color when not readOnly
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0,
                              ),
                            ),
                            controller: TextEditingController(text: value),
                            style: TextStyle(
                                color: Color.fromARGB(255, 73, 72, 72),
                                fontSize: 12),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> tableData = [];

  Widget _buildTable() {
    double screenHeight = MediaQuery.of(context).size.height;

    // Check if the device is in mobile view
    bool isMobileView = !Responsive.isDesktop(context);

    if (isMobileView) {
      // Return Card view for mobile devices
      return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true, // Use only the space needed
        itemCount: tableData.length,
        itemBuilder: (context, index) {
          var data = tableData[index];

          var line_id = data['line_id'].toString();
          var invoiceno = data['invoiceno'].toString();
          var itemcode = data['itemcode'].toString();

          var undel_id = data['undel_id'].toString();
          var customer_trx_id = data['customer_trx_id'].toString();
          var customer_trx_line_id = data['customer_trx_line_id'].toString();

          var itemdetails = data['itemdetails'].toString();
          var invoiceQty = data['invoiceQty'].toString();
          var scannedqty = data['scannedqty'].toString();
          var needtoscan = data['needtoscan'].toString();

          var dispatch_qty = data['dispatch_qty'].toString();
          var amount = data['amount'].toString();
          var item_cost = data['item_cost'].toString();
          var balance_qty = data['balance_qty'].toString();
          var Updated_id = data['Row_id'].toString();
          var Row_id = data['Row_id'].toString();
          var status = data['status'].toString();

          var Scanned_qty = data['Scanned_qty'].toString();
          var BalScanned_Qty = data['BalScanned_Qty'].toString();

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // Rounded corners
            ),
            elevation: 8, // Shadow effect
            child: Padding(
              padding: const EdgeInsets.all(15.0), // Increased padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt, color: buttonColor, size: 15),
                          SizedBox(width: 10),
                          Text("Invoice No: ${data['invoiceno']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              )),
                        ],
                      ),
                      Spacer(),
                      Row(
                        children: [
                          IconButton(
                              onPressed: data['status'] == "Finished"
                                  ? null
                                  : () async {
                                      // Your onPressed logic here
                                      String reqno =
                                          _ReqnoController.text.trim();
                                      String pickno =
                                          _PicknoController.text.trim();
                                      String assignpickman =
                                          _AssignedStaffController.text.trim();
                                      String warehouse =
                                          _WarehousenameNameController.text
                                              .trim();
                                      String org_id =
                                          _Org_idController.text.trim();
                                      String org_name =
                                          _Org_nameController.text.trim();
                                      String salesman_No =
                                          _Salesman_NoController.text.trim();
                                      String salesman_Name =
                                          _Salesman_NameController.text.trim();
                                      String Manager_No =
                                          ManagerNoController.text.trim();
                                      String Manager_Name =
                                          ManagerNameController.text.trim();
                                      String cusid =
                                          _CusidController.text.trim();
                                      String cusname =
                                          _CustomerNameController.text.trim();
                                      String cusno =
                                          _CustomerNumberController.text.trim();
                                      String cussite =
                                          _CussiteController.text.trim();

                                      String putdataid =
                                          _IdController.text.trim();
                                      String assignpcikman =
                                          _AssignedStaffController
                                                  .text.isNotEmpty
                                              ? _AssignedStaffController.text
                                              : '';
                                      await showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            insetPadding: EdgeInsets.all(
                                                10), // Adjust the padding as needed
                                            child: Container(
                                              color: Colors.grey[100],
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9, // 90% width
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.90, // 80% height
                                              child: Stack(
                                                children: [
                                                  CustomerDetailsDialog(
                                                    togglePage:
                                                        widget.togglePage,
                                                    reqno: reqno,
                                                    pickno: pickno,
                                                    assignpickname:
                                                        assignpcikman,
                                                    assignpickman:
                                                        assignpcikman,
                                                    warehouse: warehouse,
                                                    org_id: org_id,
                                                    org_name: org_name,
                                                    salesman_No: salesman_No,
                                                    salesman_Name:
                                                        salesman_Name,
                                                    Manager_No: Manager_No,
                                                    Manager_Name: Manager_Name,
                                                    cusid: cusid,
                                                    cusname: cusname,
                                                    cusno: cusno,
                                                    cussite: cussite,

                                                    invoiceno: '$invoiceno',
                                                    customer_trx_line_id:
                                                        customer_trx_line_id,
                                                    customer_trx_id:
                                                        customer_trx_id,
                                                    undel_id: undel_id,
                                                    line_id: line_id,
                                                    itemcode: '$itemcode',
                                                    itemdetails: '$itemdetails',
                                                    scannedqty:
                                                        '$BalScanned_Qty',
                                                    nofoqty: '$BalScanned_Qty',
                                                    alreadyscannedqty:
                                                        '$Scanned_qty',
                                                    invoiceQty: '$invoiceQty',
                                                    // dispatch_qty:
                                                    //     '$dispatch_qty',
                                                    dispatch_qty: '$scannedqty',
                                                    amount: '$amount',
                                                    item_cost: '$item_cost',
                                                    balance_qty: '$balance_qty',
                                                    Row_id: "$Updated_id",
                                                  ),
                                                  Positioned(
                                                    top: 10,
                                                    right: 10,
                                                    child: IconButton(
                                                      icon: Icon(Icons.cancel,
                                                          color: Colors.red),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );

                                      await fetchDataPicknO();
                                    },
                              icon: Icon(Icons.qr_code_scanner)),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 10), // Space between items
                  Row(
                    children: [
                      Icon(Icons.code, color: buttonColor, size: 15),
                      SizedBox(width: 10),
                      Text("Item Code: ${data['itemcode']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          )),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.description, color: buttonColor, size: 15),
                      SizedBox(width: 10),
                      Expanded(
                        child: Tooltip(
                          message: data['itemdetails'],
                          child:
                              Text("Item Description: ${data['itemdetails']}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  )),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.format_list_numbered,
                          color: buttonColor, size: 15),
                      SizedBox(width: 10),
                      Text("Qty Invoice: ${data['invoiceQty']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          )),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: buttonColor, size: 15),
                      SizedBox(width: 10),
                      Text("Qty Picked: ${data['scannedqty']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          )),
                    ],
                  ),
                  SizedBox(height: 10),

                  Row(
                    children: [
                      Icon(Icons.inventory, color: buttonColor, size: 15),
                      SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Roboto', // Default font
                            fontSize: 12, // Optional
                          ),
                          children: [
                            TextSpan(
                              text: "Qty.Scanned: ",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Roboto', // Default font
                                fontSize: 13, // Optional
                              ),
                            ),
                            TextSpan(
                              text: "$Scanned_qty",
                              style: TextStyle(
                                color: Colors.green,
                                fontFamily: 'Roboto',
                                fontSize: 13, // Optional
// Same or different font
                              ),
                            ),
                            TextSpan(text: " - "),
                            TextSpan(
                              text: double.tryParse(BalScanned_Qty)
                                  ?.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 13, // Optional
                                color: Colors.red,
                                fontFamily: 'Roboto', // Same or different font
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.info, color: buttonColor, size: 15),
                      SizedBox(width: 10),
                      Text("Status: ${data['status']}",
                          style: commonLabelTextStyle.copyWith(
                            color: data['status'] == 'Completed'
                                ? Colors.green
                                : Colors.blue, // Color based on status
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                  // Add more fields as needed
                ],
              ),
            ),
          );
        },
      );
    } else {
      return Container(
        child: Stack(children: [
          ScrollbarTheme(
            data: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(Colors.grey[600]),
              thumbVisibility: MaterialStateProperty.all(true),
              thickness: MaterialStateProperty.all(8),
              radius: const Radius.circular(10),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              controller: _horizontalScrollController,
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: Responsive.isDesktop(context)
                          ? MediaQuery.of(context).size.width * 1.1
                          : MediaQuery.of(context).size.width * 3,
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Scrollbar(
                        thumbVisibility: true,
                        controller: _verticalScrollController,
                        child: SingleChildScrollView(
                          controller: _verticalScrollController,
                          child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10, top: 13, bottom: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Container(
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 30,
                                      decoration: TableHeaderColor,
                                      child: Center(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.numbers,
                                                    size: 15,
                                                    color: Colors.blue,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text("Invoice.No",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          commonLabelTextStyle),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 80,
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.category,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text("I.L.No",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 30,
                                      decoration: TableHeaderColor,
                                      child: Center(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.code,
                                                    size: 15,
                                                    color: Colors.blue,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                      Responsive.isDesktop(
                                                              context)
                                                          ? "Item Code"
                                                          : "ItemCode",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          commonLabelTextStyle),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: TableHeaderColor,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.details_outlined,
                                                  size: 15,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                    Responsive.isDesktop(
                                                            context)
                                                        ? "Item Description"
                                                        : "Item Desc",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        commonLabelTextStyle),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 30,
                                      decoration: TableHeaderColor,
                                      child: Center(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .production_quantity_limits,
                                                    size: 15,
                                                    color: Colors.blue,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text("Qty.Invoice",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          commonLabelTextStyle),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 30,
                                      decoration: TableHeaderColor,
                                      child: Center(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.local_shipping,
                                                    size: 15,
                                                    color: Colors.blue,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text("Qty.Picked",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          commonLabelTextStyle),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 30,
                                      decoration: TableHeaderColor,
                                      child: Center(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.qr_code_scanner,
                                                    size: 15,
                                                    color: Colors.blue,
                                                  ),
                                                  SizedBox(width: 2),
                                                  Text(
                                                      Responsive.isDesktop(
                                                              context)
                                                          ? "Qty.Scanned"
                                                          : "QtyScanned",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          commonLabelTextStyle),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 30,
                                      decoration: TableHeaderColor,
                                      child: Center(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    size: 15,
                                                    color: Colors.blue,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text("Status",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          commonLabelTextStyle),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      height: Responsive.isDesktop(context)
                                          ? 25
                                          : 30,
                                      decoration: TableHeaderColor,
                                      child: Center(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.visibility,
                                                    size: 15,
                                                    color: Colors.blue,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text("Scan",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          commonLabelTextStyle),
                                                ],
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
                            if (_isLoading2)
                              Padding(
                                padding: const EdgeInsets.only(top: 100.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (tableData.isNotEmpty)
                              ...tableData.map((data) {
                                var line_id = data['line_id'].toString();
                                var invoiceno = data['invoiceno'].toString();
                                var itemcode = data['itemcode'].toString();

                                var undel_id = data['undel_id'].toString();
                                var customer_trx_id =
                                    data['customer_trx_id'].toString();
                                var customer_trx_line_id =
                                    data['customer_trx_line_id'].toString();

                                var itemdetails =
                                    data['itemdetails'].toString();
                                var invoiceQty = data['invoiceQty'].toString();
                                var scannedqty = data['scannedqty'].toString();
                                var needtoscan = data['needtoscan'].toString();

                                var dispatch_qty =
                                    data['dispatch_qty'].toString();
                                var amount = data['amount'].toString();
                                var item_cost = data['item_cost'].toString();
                                var balance_qty =
                                    data['balance_qty'].toString();
                                var Updated_id = data['Row_id'].toString();
                                var Row_id = data['Row_id'].toString();
                                var status = data['status'].toString();

                                var Scanned_qty =
                                    data['Scanned_qty'].toString();
                                var BalScanned_Qty =
                                    data['BalScanned_Qty'].toString();

                                bool isEvenRow =
                                    tableData.indexOf(data) % 2 == 0;
                                Color? rowColor = isEvenRow
                                    ? Color.fromARGB(224, 255, 255, 255)
                                    : Color.fromARGB(224, 255, 255, 255);

                                return GestureDetector(
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10.0,
                                      right: 10,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: rowColor,
                                              border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SelectableText(
                                                  invoiceno,
                                                  textAlign: TextAlign.left,
                                                  style: TableRowTextStyle,
                                                  showCursor: false,
                                                  // overflow: TextOverflow.ellipsis,
                                                  cursorColor: Colors.blue,
                                                  cursorWidth: 2.0,
                                                  toolbarOptions:
                                                      ToolbarOptions(
                                                          copy: true,
                                                          selectAll: true),
                                                  onTap: () {
                                                    // Optional: Handle single tap if needed
                                                  },
                                                ),
                                                // Text(invoiceno,
                                                //     textAlign: TextAlign.center,
                                                //     style: TableRowTextStyle),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 80,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SelectableText(
                                                line_id,
                                                textAlign: TextAlign.left,
                                                style: TableRowTextStyle,
                                                showCursor: false,
                                                // overflow: TextOverflow.ellipsis,
                                                cursorColor: Colors.blue,
                                                cursorWidth: 2.0,
                                                toolbarOptions: ToolbarOptions(
                                                    copy: true,
                                                    selectAll: true),
                                                onTap: () {
                                                  // Optional: Handle single tap if needed
                                                },
                                              ),
                                              // Text(line_id,
                                              //     textAlign: TextAlign.center,
                                              //     style: TableRowTextStyle),
                                            ],
                                          ),
                                        ),
                                        Flexible(
                                          child: Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: rowColor,
                                              border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: SelectableText(
                                              itemcode,
                                              style: TableRowTextStyle,
                                              showCursor: false,
                                              cursorColor: Colors.blue,
                                              cursorWidth: 2.0,
                                            ),
                                          ),
                                        ),
                                        Tooltip(
                                          message: itemdetails,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: rowColor,
                                              border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              child: Wrap(
                                                alignment: WrapAlignment.start,
                                                children: [
                                                  SelectableText(
                                                    itemdetails,
                                                    textAlign: TextAlign.left,
                                                    style: TableRowTextStyle,
                                                    showCursor: false,
                                                    // overflow: TextOverflow.ellipsis,
                                                    cursorColor: Colors.blue,
                                                    cursorWidth: 2.0,
                                                    toolbarOptions:
                                                        ToolbarOptions(
                                                            copy: true,
                                                            selectAll: true),
                                                    onTap: () {
                                                      // Optional: Handle single tap if needed
                                                    },
                                                  ),
                                                  // Text(itemdetails,
                                                  //     textAlign: TextAlign.center,
                                                  //     style: TableRowTextStyle),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: rowColor,
                                              border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SelectableText(
                                                  invoiceQty,
                                                  textAlign: TextAlign.left,
                                                  style: TableRowTextStyle,
                                                  showCursor: false,
                                                  // overflow: TextOverflow.ellipsis,
                                                  cursorColor: Colors.blue,
                                                  cursorWidth: 2.0,
                                                  toolbarOptions:
                                                      ToolbarOptions(
                                                          copy: true,
                                                          selectAll: true),
                                                  onTap: () {
                                                    // Optional: Handle single tap if needed
                                                  },
                                                ),
                                                // Text(invoiceQty,
                                                //     textAlign: TextAlign.center,
                                                //     style: TableRowTextStyle),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: rowColor,
                                              border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SelectableText(
                                                  scannedqty,
                                                  textAlign: TextAlign.left,
                                                  style: TableRowTextStyle,
                                                  showCursor: false,
                                                  // overflow: TextOverflow.ellipsis,
                                                  cursorColor: Colors.blue,
                                                  cursorWidth: 2.0,
                                                  toolbarOptions:
                                                      ToolbarOptions(
                                                          copy: true,
                                                          selectAll: true),
                                                  onTap: () {
                                                    // Optional: Handle single tap if needed
                                                  },
                                                ),
                                                // Text(scannedqty,
                                                //     textAlign: TextAlign.center,
                                                //     style: TableRowTextStyle),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: rowColor,
                                              border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Tooltip(
                                                  message: "Scanned Qty",
                                                  child: Text(Scanned_qty,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              23,
                                                              122,
                                                              5))),
                                                ),
                                                SizedBox(width: 10),
                                                const Text("-",
                                                    textAlign: TextAlign.center,
                                                    style: TableRowTextStyle),
                                                SizedBox(width: 10),
                                                Tooltip(
                                                  message:
                                                      "Balance Qty to Scan",
                                                  child: Text(
                                                    double.tryParse(
                                                                BalScanned_Qty)
                                                            ?.toStringAsFixed(
                                                                0) ??
                                                        BalScanned_Qty,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 200, 10, 10),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: rowColor,
                                              border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(status,
                                                    style: TableRowTextStyle),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: rowColor,
                                              border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 226, 225, 225),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          status == "Finished"
                                                              ? Colors.green
                                                              : buttonColor,
                                                    ),
                                                    child: ElevatedButton(
                                                      onPressed:
                                                          status == "Finished"
                                                              ? null
                                                              : () async {
                                                                  // Your onPressed logic here

                                                                  String reqno =
                                                                      _ReqnoController
                                                                          .text
                                                                          .toString();
                                                                  String pickno = _PicknoController
                                                                          .text
                                                                          .isNotEmpty
                                                                      ? _PicknoController
                                                                          .text
                                                                      : '';
                                                                  String assignpcikman = _AssignedStaffController
                                                                          .text
                                                                          .isNotEmpty
                                                                      ? _AssignedStaffController
                                                                          .text
                                                                      : '';
                                                                  String warehouse = _WarehousenameNameController
                                                                          .text
                                                                          .isNotEmpty
                                                                      ? _WarehousenameNameController
                                                                          .text
                                                                      : '';
                                                                  String org_id = _Org_idController
                                                                          .text
                                                                          .isNotEmpty
                                                                      ? _Org_idController
                                                                          .text
                                                                      : '';
                                                                  String org_name = _Org_nameController
                                                                          .text
                                                                          .isNotEmpty
                                                                      ? _Org_nameController
                                                                          .text
                                                                      : '';
                                                                  String salesman_No = _Salesman_NoController
                                                                          .text
                                                                          .isNotEmpty
                                                                      ? _Salesman_NoController
                                                                          .text
                                                                      : '';
                                                                  String salesman_Name = _Salesman_NameController
                                                                          .text
                                                                          .isNotEmpty
                                                                      ? _Salesman_NameController
                                                                          .text
                                                                      : '0';
                                                                  String Manager_No = ManagerNoController
                                                                          .text
                                                                          .isNotEmpty
                                                                      ? ManagerNoController
                                                                          .text
                                                                      : '';
                                                                  String Manager_Name = ManagerNameController
                                                                          .text
                                                                          .isNotEmpty
                                                                      ? ManagerNameController
                                                                          .text
                                                                      : '0';
                                                                  String cusid = _CusidController
                                                                          .text
                                                                          .isNotEmpty
                                                                      ? _CusidController
                                                                          .text
                                                                      : '0';
                                                                  String cusname = _CustomerNameController
                                                                          .text
                                                                          .isNotEmpty
                                                                      ? _CustomerNameController
                                                                          .text
                                                                      : '';
                                                                  String cusno = _CustomerNumberController
                                                                          .text
                                                                          .isNotEmpty
                                                                      ? _CustomerNumberController
                                                                          .text
                                                                      : '0';
                                                                  String cussite = _CussiteController
                                                                          .text
                                                                          .isNotEmpty
                                                                      ? _CussiteController
                                                                          .text
                                                                      : '0';
                                                                  // String invoiceno = _InvoiceNumberController
                                                                  //         .text
                                                                  //         .isNotEmpty
                                                                  //     ? _InvoiceNumberController
                                                                  //         .text
                                                                  //     : '';

                                                                  String putdataid = _IdController
                                                                          .text
                                                                          .isNotEmpty
                                                                      ? _IdController
                                                                          .text
                                                                      : '';
                                                                  await showDialog(
                                                                    context:
                                                                        context,
                                                                    barrierDismissible:
                                                                        false,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return Dialog(
                                                                        child:
                                                                            Container(
                                                                          color:
                                                                              Colors.grey[100],
                                                                          height:
                                                                              MediaQuery.of(context).size.height * 0.8,
                                                                          child:
                                                                              Stack(
                                                                            children: [
                                                                              Container(
                                                                                height: MediaQuery.of(context).size.height * 0.8,
                                                                                child: CustomerDetailsDialog(
                                                                                  togglePage: widget.togglePage,
                                                                                  reqno: reqno,
                                                                                  pickno: pickno,
                                                                                  assignpickname: assignpcikman,
                                                                                  assignpickman: assignpcikman,
                                                                                  warehouse: warehouse,
                                                                                  org_id: org_id,
                                                                                  org_name: org_name,
                                                                                  salesman_No: salesman_No,
                                                                                  salesman_Name: salesman_Name,
                                                                                  Manager_No: Manager_No,
                                                                                  Manager_Name: Manager_Name,
                                                                                  cusid: cusid,
                                                                                  cusname: cusname,
                                                                                  cusno: cusno,
                                                                                  cussite: cussite,

                                                                                  invoiceno: '$invoiceno',
                                                                                  customer_trx_line_id: customer_trx_line_id,
                                                                                  customer_trx_id: customer_trx_id,
                                                                                  undel_id: undel_id,
                                                                                  line_id: line_id,
                                                                                  itemcode: '$itemcode',
                                                                                  itemdetails: '$itemdetails',
                                                                                  scannedqty: '$BalScanned_Qty',
                                                                                  nofoqty: '$BalScanned_Qty',
                                                                                  alreadyscannedqty: '$Scanned_qty',
                                                                                  invoiceQty: '$invoiceQty',
                                                                                  // dispatch_qty:
                                                                                  //     '$dispatch_qty',
                                                                                  dispatch_qty: '$scannedqty',
                                                                                  amount: '$amount',
                                                                                  item_cost: '$item_cost',
                                                                                  balance_qty: '$balance_qty',
                                                                                  Row_id: "$Updated_id",
                                                                                ),
                                                                              ),
                                                                              Positioned(
                                                                                top: 10,
                                                                                right: 10,
                                                                                child: IconButton(
                                                                                  icon: Icon(Icons.cancel, color: Colors.red),
                                                                                  onPressed: () {
                                                                                    Navigator.of(context).pop(); // Close the dialog
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  );

                                                                  await fetchDataPicknO();
                                                                },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            status == "Finished"
                                                                ? Colors.green
                                                                : Colors
                                                                    .transparent,
                                                        shadowColor:
                                                            Colors.transparent,
                                                        minimumSize:
                                                            Size(45.0, 31.0),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                      ),
                                                      child: status ==
                                                              "Finished"
                                                          ? Text('Completed',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white))
                                                          : Responsive
                                                                  .isDesktop(
                                                                      context)
                                                              ? Text('Scan',
                                                                  style:
                                                                      commonWhiteStyle)
                                                              : Icon(
                                                                  Icons
                                                                      .qr_code_scanner,
                                                                  size: 15,
                                                                  color: Colors
                                                                      .white),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList()
                            else
                              Padding(
                                padding: const EdgeInsets.only(top: 100.0),
                                child: Text("No data available."),
                              ),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0, // Adjust position as needed
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Arrow with click handler
                IconButton(
                  icon: Icon(
                    Icons.arrow_left_outlined,
                    color: Colors.blueAccent,
                    size: 30,
                  ),
                  onPressed: () {
                    // Scroll left by a fixed amount
                    _horizontalScrollController.animateTo(
                      _horizontalScrollController.offset -
                          100, // Adjust scroll amount
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                // Right Arrow with click handler
                IconButton(
                  icon: Icon(
                    Icons.arrow_right_outlined,
                    color: Colors.blueAccent,
                    size: 30,
                  ),
                  onPressed: () {
                    // Scroll right by a fixed amount
                    _horizontalScrollController.animateTo(
                      _horizontalScrollController.offset +
                          100, // Adjust scroll amount
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ],
            ),
          ),
        ]),
      );
    }
  }

  TextEditingController NoofitemController = TextEditingController(text: "0");
  TextEditingController totalSendqtyController =
      TextEditingController(text: '0');

  void _updatedisreqamt() {
    // Use the getTotalFinalAmt function to update the total amount
    totalSendqtyController.text =
        gettotaldisreqamt(tableData).toInt().toString(); // Convert to integer
    print("totaldisreqController amountttt ${totalSendqtyController.text}");
  }

  double gettotaldisreqamt(List<Map<String, dynamic>> tableData) {
    double totalQuantity = 0.0;
    for (var data in tableData) {
      double quantity = double.tryParse(data['noofqty'] ?? '0') ?? 0.0;
      totalQuantity += quantity;
    }
    return totalQuantity;
  }

  @override
  void initState() {
    super.initState();

    _updatedisreqamt();
    fetchAccessControl();
    _loadSalesmanName();
    fetchDataPicknO();
    fetchDataPicknO();
    fetchRegionAndWarehouse();

    postLogData("Pick Man", "Opened");
  }

  List<bool> accessControl = [];
  Future<void> fetchAccessControl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginnoStr = prefs.getString('salesloginno');
    final String uniqueId = salesloginnoStr.toString();

    final IpAddress = await getActiveIpAddress();

    String apiUrl = '$IpAddress/User_member_details';
    bool userFound = false;

    try {
      // Loop through each page until the user with uniqueId is found or no more pages are left
      while (apiUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          // Decode the JSON response
          final data = json.decode(response.body);

          // Find the user with the matching unique_id on the current page
          var user = (data['results'] as List<dynamic>).firstWhere(
            (u) => u['EMPLOYEE_ID'] == uniqueId,
            orElse: () => null,
          );

          if (user != null) {
            userFound = true;

            // Check if access_control is not null and is a Map
            var accessControlMap = user['acess_control'];
            if (accessControlMap != null && accessControlMap is Map) {
              // Convert access_control Map to a list of bools
              List<bool> accessControlList = [];

              // Iterate through the values of the access control map
              for (var value in accessControlMap.values) {
                // Ensure that we only process boolean values
                accessControlList
                    .add(value is bool ? value : value.toString() == 'true');
              }

              // Set the access control list to a state variable if needed
              setState(() {
                accessControl =
                    accessControlList; // Assuming accessControl is defined as List<bool>
              });

              print('Access Control List: $accessControl');
            } else {
              print('Access control data is not available for user $uniqueId.');
            }
            return; // Exit once the user is found and processed
          }

          // Update apiUrl to the next page, or set to empty if no more pages
          apiUrl = data['next'] ?? '';
        } else {
          print('Failed to load user details: ${response.statusCode}');
          return;
        }
      }

      if (!userFound) {
        print('User with unique_id $uniqueId not found in any page.');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  String? saveloginname = '';

  String? saveloginrole = '';

  String? saleslogiOrgid = '';

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
      saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';

      saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? 'Unknown Salesman';
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
    fetchDataPicknO();
    postLogData("Pick Man", "Closed");
  }

  TextEditingController _IdController = TextEditingController();
  TextEditingController _InvoiceNumberController = TextEditingController();
  TextEditingController _ReqnoController = TextEditingController();
  TextEditingController _PicknoController = TextEditingController();
  TextEditingController _DateController = TextEditingController();
  TextEditingController _CusidController = TextEditingController();
  TextEditingController _CussiteController = TextEditingController();
  TextEditingController _CustomerNameController = TextEditingController();
  TextEditingController _RegionController = TextEditingController();
  TextEditingController _WarehousenameNameController = TextEditingController();
  TextEditingController _CustomerNumberController = TextEditingController();

  TextEditingController _Org_idController = TextEditingController();
  TextEditingController _Org_nameController = TextEditingController();
  TextEditingController _Salesman_NoController = TextEditingController();
  TextEditingController _Salesman_NameController = TextEditingController();
  TextEditingController IdController = TextEditingController();
  TextEditingController _AssignedStaffController = TextEditingController();

  TextEditingController ManagerNoController = TextEditingController();
  TextEditingController ManagerNameController = TextEditingController();

  Future<void> fetchDataPicknO() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? pickno = prefs.getString('pickno');
    String? reqno = prefs.getString('reqno');

    final IpAddress = await getActiveIpAddress();

    final response = await http
        .get(Uri.parse('$IpAddress/Filtered_Pickscan/$reqno/$pickno'));
    // print("response dataaaaaaaaa ${response.body}");
    // print("urls $IpAddress/Filtered_Pickscan/$reqno/$pickno");

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes); // <- fix here

      final List<dynamic> responseData =
          json.decode(decodedBody); // Ensure this is a list

      if (responseData.isEmpty || responseData[0] == null) {
        print("Empty or invalid response data");
        return;
      }

      final data =
          responseData[0]; // Get the first item from the response array

      setState(() {
        // Update the controller fields
        _IdController.text = data["ID"]?.toString() ?? '';
        _PicknoController.text = data['PICK_ID']?.toString() ?? '';
        _AssignedStaffController.text = data['ASS_PICKMAN']?.toString() ?? '';
        _ReqnoController.text = data['REQ_ID']?.toString() ?? '';
        _DateController.text = data['INVOICE_DATE']?.toString() ?? '';
        _InvoiceNumberController.text =
            data['INVOICE_NUMBER']?.toString() ?? '';
        _CusidController.text = data['CUSTOMER_NUMBER']?.toString() ?? '';
        _CussiteController.text = data['CUSTOMER_SITE_ID']?.toString() ?? '';
        _CustomerNameController.text = data['CUSTOMER_NAME']?.toString() ?? '';
        _CustomerNumberController.text =
            data['CUSTOMER_NUMBER']?.toString() ?? '';
        _RegionController.text = data['ORG_NAME']?.toString() ?? '';
        _Salesman_NoController.text = data['SALESMAN_NO']?.toString() ?? '';
        _Salesman_NameController.text = data['SALESMAN_NAME']?.toString() ?? '';

        ManagerNoController.text = data['MANAGER_NO']?.toString() ?? '';
        ManagerNameController.text = data['MANAGER_NAME']?.toString() ?? '';

        _Org_idController.text = data['ORG_ID']?.toString() ?? '';

        tableData = [];
        double totalBalScannedQty =
            0; // Variable to store the total balance scanned qty

        if (data['TABLE_DETAILS'] != null) {
          for (var item in data['TABLE_DETAILS']) {
            final pick_qty =
                double.tryParse(item['PICKED_QTY']?.toString() ?? '0') ?? 0;
            final scannedQty =
                double.tryParse(item['SCANNED_QTY']?.toString() ?? '0') ?? 0;
            final balScannedQty = (pick_qty - scannedQty).toString();
            final double finalbalScannedQty = pick_qty - scannedQty;

            totalBalScannedQty +=
                finalbalScannedQty; // Sum up balance scanned qty
            tableData.add({
              'Row_id': item['ID']?.toString() ?? '',
              'undel_id': item['UNDEL_ID']?.toString() ?? '',
              'line_id': item['LINE_NUMBER']?.toString() ?? '',
              'invoiceno': item['INVOICE_NUMBER']?.toString() ?? '',
              'customer_trx_id': item['CUSTOMER_TRX_ID']?.toString() ?? '',
              'customer_trx_line_id':
                  item['CUSTOMER_TRX_LINE_ID']?.toString() ?? '',
              'itemcode': item['INVENTORY_ITEM_ID']?.toString() ?? '',
              'itemdetails': item['ITEM_DESCRIPTION']?.toString() ?? '',
              'invoiceQty': item['TOT_QUANTITY']?.toString() ?? '0',
              'scannedqty': item['PICKED_QTY']?.toString() ?? '0',
              'needtoscan': item['BALANCE_QTY']?.toString() ?? '0',
              'sendqty': '0',
              'dispatchqty': '0',
              'status': item['STATUS']?.toString() ?? '',
              'dispatch_qty': item['DISPATCHED_QTY']?.toString() ?? '',
              'amount': item['AMOUNT']?.toString() ?? '',
              'item_cost': item['ITEM_COST']?.toString() ?? '',
              'balance_qty': item['BALANCE_QTY']?.toString() ?? '0',
              'Scanned_qty': item['SCANNED_QTY']?.toString() ?? '0',
              'BalScanned_Qty': balScannedQty,
            });
          }
          // _initializeControllers();
        }
        totalSendqtyController.text = totalBalScannedQty
            .toInt()
            .toString(); // Convert to integer and then to string

        // print('Table Dataaaaaaaaaaaaaaa: $tableData');
        // print('Total Balance Scanned Quantity: $totalBalScannedQty');
      });
    } else {
      print('Failed to load dispatch request details: ${response.statusCode}');
    }
    setState(() {
      _isLoading2 = false;
    });
  }

  Future<void> fetchRegionAndWarehouse() async {
    await _loadSalesmanName();
    String orgId = saleslogiOrgid ?? 'Unknown Salesman';

    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/Physical_Warehouse/';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Find the entry for the given ORGANIZATION_ID
        final result = data['results'].firstWhere(
          (item) => item['ORGANIZATION_ID'] == orgId,
          orElse: () => null,
        );

        if (result != null) {
          // Update the controllers with fetched values
          setState(() {
            _Org_nameController.text = result['REGION_NAME'];
            _WarehousenameNameController.text = result['WAREHOUSE_NAME'];
          });
        } else {
          // Clear the controllers if no match is found
          setState(() {
            _Org_nameController.text = '';
            _WarehousenameNameController.text = '';
          });
          print('No data found for ORGANIZATION_ID: $orgId');
        }
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey[400]!,
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            InkWell(
                              onTap: () {
                                // Navigator.pushReplacement(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => MainSidebar(
                                //         enabledItems: accessControl,
                                //         initialPageIndex:
                                //             4), // Navigate to MainSidebar
                                //   ),
                                // );
                                widget.togglePage();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Image.asset(
                                    'assets/images/pickman.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Pick Man',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                                        saveloginname ?? 'Loading...',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(0),
                                      child: Text(
                                        saveloginrole ?? 'Loading...',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // SizedBox(
                                //   width: 10,
                                // ),
                                // Icon(
                                //   Icons.arrow_drop_down_outlined,
                                //   size: 27,
                                // ),

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
                  padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 30 : 10,
                    bottom: Responsive.isDesktop(context) ? 30 : 10,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    runSpacing: 2,
                    children: [
                      _buildTextFieldDesktop('Picking ID',
                          "${_PicknoController.text}", Icons.numbers, true),
                      SizedBox(width: 10),
                      _buildTextFieldDesktop('DispatchReq ID',
                          "${_ReqnoController.text}", Icons.request_page, true),
                      SizedBox(width: 10),
                      _buildTextFieldDesktop(
                          'Physical Warehouse',
                          _WarehousenameNameController.text,
                          Icons.warehouse,
                          true),
                      SizedBox(width: 10),
                      _buildTextFieldDesktop('Region', _RegionController.text,
                          Icons.location_city, true),
                      SizedBox(width: 10),
                      _buildTextFieldDesktop('Customer No',
                          _CusidController.text, Icons.no_accounts, true),
                      SizedBox(width: 10),
                      _buildTextFieldDesktop(
                          'Customer Name',
                          _CustomerNameController.text,
                          Icons.perm_identity,
                          true),
                      SizedBox(width: 10),
                      _buildTextFieldDesktop(
                          'Customer Site',
                          _CussiteController.text,
                          Icons.sixteen_mp_outlined,
                          true),
                    ],
                  ),
                ),
                // Export button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5, right: 40),
                      child: Container(
                        height: 35,
                        width: 110,
                        decoration: BoxDecoration(color: buttonColor),
                        child: ElevatedButton(
                          onPressed: () async {
                            List<List<dynamic>> convertedData =
                                tableData.map((map) {
                              return [
                                map['invoiceno'],
                                map['line_id'],
                                map['itemcode'],
                                map['itemdetails'],
                                map['invoiceQty'],
                                map['scannedqty'],
                                map['BalScanned_Qty'],
                                (int.tryParse(map['Scanned_qty']?.toString() ??
                                            '0') ??
                                        0) -
                                    (int.tryParse(
                                            map['BalScanned_Qty']?.toString() ??
                                                '0') ??
                                        0), // Safe subtraction
                                map['status'],
                              ];
                            }).toList();
                            // Check if the data is empty
                            if (tableData.isEmpty) {
                              // Show dialog if no data is available
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Error'),
                                    content:
                                        Text('No data available to export.!!'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return; // Exit if data is empty
                            }
                            List<String> columnNames = getDisplayedColumns();
                            await createExcel(columnNames, convertedData);

                            postLogData("Pick Man", "Details Export");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SvgPicture.asset(
                                'assets/images/excel.svg',
                                width: 20,
                                height: 20,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Export",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.only(
                      top: 0,
                      left: Responsive.isDesktop(context) ? 35 : 10,
                      right: Responsive.isDesktop(context) ? 35 : 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Pick Items:',
                        style: TextStyle(
                            fontSize: Responsive.isDesktop(context) ? 14 : 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[700]),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 3, // Adjust the size of the bullet
                              backgroundColor: Color.fromARGB(
                                  255, 23, 122, 5), // Bullet color
                            ),
                            SizedBox(width: 8), // Space between bullet and text
                            Text(
                              'Scanned Qty (Picked Qty)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 23, 122, 5),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                                radius: 3, // Adjust the size of the bullet
                                backgroundColor:
                                    Color.fromARGB(255, 200, 10, 10)),
                            SizedBox(width: 8), // Space between bullet and text
                            Text(
                              'Balance Qty to scan',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 200, 10, 10)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                // Table section
                Padding(
                  padding: EdgeInsets.only(
                    left: Responsive.isDesktop(context) ? 35 : 10,
                    right: Responsive.isDesktop(context) ? 35 : 10,
                  ),
                  child: _buildTable(),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width * 0.1
                            : MediaQuery.of(context).size.width * 0.4,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Text("Total Qty", style: textboxheading),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 0, bottom: 0),
                                child: Row(
                                  children: [
                                    Container(
                                        height: 32,
                                        // width: Responsive.isDesktop(context)
                                        //     ? screenWidth * 0.086
                                        //     : 130,

                                        width: Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.1
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4,
                                        child: MouseRegion(
                                          onEnter: (event) {
                                            // You can perform any action when mouse enters, like logging the value.
                                          },
                                          onExit: (event) {
                                            // Perform any action when the mouse leaves the TextField area.
                                          },
                                          cursor: SystemMouseCursors
                                              .click, // Changes the cursor to indicate interaction

                                          child: TextFormField(
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color.fromARGB(
                                                      201, 132, 132, 132),
                                                  width: 1.0,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 58, 58, 58),
                                                  width: 1.0,
                                                ),
                                              ),
                                              filled:
                                                  true, // Enable the background fill
                                              fillColor: Color.fromARGB(
                                                  255,
                                                  234,
                                                  234,
                                                  234) // Change fill color when readOnly is true
                                              , // Default color when not readOnly
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 5.0,
                                                horizontal: 10.0,
                                              ),
                                            ),
                                            controller: totalSendqtyController,
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 73, 72, 72),
                                                fontSize: 15),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> createExcel(
      List<String> columnNames, List<List<dynamic>> data) async {
    try {
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
        final Range range = sheet.getRangeByIndex(1, colIndex + 1);
        range.setText(columnNames[colIndex]);
        range.cellStyle.backColor = '#550A35';
        range.cellStyle.fontColor = '#F5F5F5';
      }

      for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
        final List<dynamic> rowData = data[rowIndex];
        for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
          final Range range = sheet.getRangeByIndex(rowIndex + 2, colIndex + 1);
          range.setText(rowData[colIndex].toString());
        }
      }

      final List<int> bytes = workbook.saveAsStream();

      try {
        workbook.dispose();
      } catch (e) {
        print('Error during workbook disposal: $e');
      }

      final now = DateTime.now();
      final formattedDate =
          '${now.day}-${now.month}-${now.year} Time ${now.hour}-${now.minute}-${now.second}';

      if (kIsWeb) {
        AnchorElement(
            href:
                'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
          ..setAttribute('download', 'PickMan ($formattedDate).xlsx')
          ..click();
      } else {
        final String path = (await getApplicationSupportDirectory()).path;
        final String fileName = Platform.isWindows
            ? '$path\\Excel PickMan ($formattedDate).xlsx'
            : '$path/Excel PickMan ($formattedDate).xlsx';
        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);
        OpenFile.open(fileName);
      }
    } catch (e) {
      print('Error in createExcel: $e');
    }
  }

  List<String> getDisplayedColumns() {
    return [
      'Invoice No',
      'Invoice Line No',
      'Item Code',
      'Item Description',
      'Qty. Invoice',
      'Qty.Picked',
      'Qty.Scanned',
      'Status',
    ];
  }

  void successfullyLoginMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.check_circle_rounded, color: Colors.green),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                'Scanned Successfully !!',
                style: TextStyle(fontSize: 13, color: Colors.black),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }
}

class CustomerDetailsDialog extends StatefulWidget {
  final Function togglePage;
  final String reqno;
  final String pickno;
  final String assignpickname;
  final String assignpickman;
  final String warehouse;
  final String org_id;
  final String org_name;
  final String salesman_No;
  final String salesman_Name;

  final String Manager_No;
  final String Manager_Name;
  final String cusid;
  final String cusname;
  final String cusno;
  final String cussite;
  final String invoiceno;
  final String itemcode;
  final String itemdetails;
  final String line_id;
  final String customer_trx_line_id;
  final String customer_trx_id;
  final String undel_id;
  final String scannedqty;
  final String alreadyscannedqty;
  final String nofoqty;
  final String invoiceQty;
  final String dispatch_qty;
  final String amount;
  final String item_cost;
  final String balance_qty;
  final String Row_id;

  CustomerDetailsDialog({
    required this.togglePage,
    required this.reqno,
    required this.pickno,
    required this.assignpickname,
    required this.assignpickman,
    required this.warehouse,
    required this.org_id,
    required this.org_name,
    required this.salesman_No,
    required this.salesman_Name,
    required this.Manager_No,
    required this.Manager_Name,
    required this.cusid,
    required this.cusname,
    required this.cusno,
    required this.cussite,
    required this.invoiceno,
    required this.line_id,
    required this.customer_trx_line_id,
    required this.customer_trx_id,
    required this.undel_id,
    required this.itemcode,
    required this.itemdetails,
    required this.scannedqty,
    required this.alreadyscannedqty,
    required this.nofoqty,
    required this.invoiceQty,
    required this.dispatch_qty,
    required this.amount,
    required this.balance_qty,
    required this.item_cost,
    required this.Row_id,
    // required this.Row_id
  });

  @override
  _CustomerDetailsDialogState createState() => _CustomerDetailsDialogState();
}

class _CustomerDetailsDialogState extends State<CustomerDetailsDialog> {
  List<Map<String, dynamic>> createtableData = [];
  List<TextEditingController> barcodeControllers = [];
  List<TextEditingController> serialnoControllers = [];
  List<FocusNode> barcodeFocusNodes = [];
  List<FocusNode> serialnoFocusNodes = [];
  // FocusNode SavebuttonFocus = FocusNode();

  TextEditingController idcontroller = TextEditingController();

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  final TextEditingController _alreadyScaneedqty = TextEditingController();
  final _serialNumbers = <String>{}; // For O(1) duplicate checking
  int _cachedMaxQuantity = 0; // Initialize in initState()

  String? validProductCode = '⎋';
  @override
  void initState() {
    super.initState();
    invoiceNoController.text = widget.invoiceno;
    ItemcodeController.text = widget.itemcode;
    itemDescriptionController.text = widget.itemdetails;
    _loadTableData(
        widget.pickno, widget.reqno, widget.itemcode, widget.invoiceno);
    postLogData("Pick Man Scan Pop-up View", "Opend");
    fetchAccessControl();
    fetchPickmanData();
    fetchAndFilterData();

    fetchRegionAndWarehouse();
    // Initialize quantity based on passed values
    // int nofoqtycount = int.tryParse(widget.nofoqty) ?? 0;

    int nofoqtycount = double.tryParse(widget.nofoqty)?.toInt() ?? 0;

    // Generate table data based on quantity count
    createtableData = List.generate(nofoqtycount, (index) {
      return {
        'id': index + 1,
        'line_id': widget.line_id,
        'invoiceno': widget.invoiceno,
        'customer_trx_id': widget.customer_trx_id,
        'undel_id': widget.undel_id,
        'customer_trx_line_id': widget.customer_trx_line_id,
        'itemcode': widget.itemcode,
        'itemdetails': widget.itemdetails,
        'invoiceQty': widget.invoiceQty,
        'dispatch_qty': widget.dispatch_qty,
        'amount': widget.amount,
        'balance_qty': widget.balance_qty,
        'item_cost': widget.item_cost,
        'barcode': '',
        'serialno': '',
      };
    });
    // Output to verify data population
    // print(
    //     "Initialized createtableData:  $nofoqtycount ${widget.nofoqty}  $createtableData");

    // Initialize controllers and focus nodes for barcode and serial numbers
    barcodeControllers =
        List.generate(nofoqtycount, (index) => TextEditingController());
    serialnoControllers =
        List.generate(nofoqtycount, (index) => TextEditingController());
    barcodeFocusNodes = List.generate(nofoqtycount, (index) => FocusNode());
    serialnoFocusNodes = List.generate(nofoqtycount, (index) => FocusNode());

    // Attach listeners for real-time updates on scanned item count

    idcontroller.text = widget.Row_id;
    _alreadyScaneedqty.text = widget.alreadyscannedqty;
    print("Already Scanned Qty: ${_alreadyScaneedqty.text}");
    validProductCode == null;

    print("validation product code : ${_alreadyScaneedqty.text}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scanMode == 0 && barcodeFocusNodes.isNotEmpty) {
        FocusScope.of(context).requestFocus(barcodeFocusNodes[0]);
      }
    });

    _cachedMaxQuantity =
        int.tryParse((widget.nofoqty ?? '').split('.').first) ?? 0;
  }

  String? validSerialno;
  String message = "";

  // Future<void> fetchAndFilterData() async {
  //   final String url =
  //       "$IpAddress/filteredProductcodeGetView/${widget.itemcode}";

  //   // "$IpAddress/filteredProductcodeGetView/07MKD06";

  //   try {
  //     final response = await http.get(Uri.parse(url));

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);

  //       // Check if the response is a list
  //       if (data is List && data.isNotEmpty) {
  //         final product = data[0]; // Get the first item
  //         if (product['SERIAL_STATUS'] == 'Y') {
  //           setState(() {
  //             validProductCode = product['CUT_PRODUCT_CODE'];
  //             message = "Valid product code found.";
  //             print("Valid product code found.  $validProductCode");
  //           });
  //         } else {
  //           setState(() {
  //             validProductCode = null;

  //             print("Validddd not product code found.  $validProductCode");
  //             message =
  //                 "This item code cannot be scanned because SERIAL_STATUS is not \"Y\".";
  //           });
  //         }
  //       } else if (data is Map && data.containsKey('message')) {
  //         setState(() {
  //           validProductCode = null;
  //           message = data['message'];

  //           print("Valid producttttt  not code found.  $validProductCode");
  //         });
  //       } else {
  //         setState(() {
  //           validProductCode = null;
  //           message = "Unexpected response format.";

  //           print("Valid product codeeeee not found.  $validProductCode");
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         validProductCode = null;
  //         message = "Failed to fetch data. Status code: ${response.statusCode}";
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       validProductCode = null;
  //       message = "An error occurred: $e";
  //     });
  //   }
  // }

  Future<void> fetchAndFilterData() async {
    final IpAddress = await getActiveIpAddress();

    final String url =
        "$IpAddress/filteredProductcodeGetView$parameterdivided${widget.itemcode}$parameterdivided${widget.itemdetails}$parameterdivided";
    print("urllll urlllll $url");
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if the response is a list
        if (data is List && data.isNotEmpty) {
          final product = data[0]; // Get the first item
          String cutProductCode = product['PRODUCT_BARCODE'] ?? '';

          // Clean up the product code (remove unexpected characters and spaces)
          cutProductCode =
              cutProductCode.trim().replaceAll(RegExp(r'[^\x20-\x7E]'), '');

          // Check if SERIAL_STATUS is 'Y' and CUT_PRODUCT_CODE is valid
          if (product['SERIAL_STATUS'] == 'Y' && cutProductCode.isNotEmpty) {
            setState(() {
              validProductCode = cutProductCode;
              validSerialno = '';
              message = "Valid product code found.";
              print("Valid product code found: $validProductCode");
            });
          } else if (product['SERIAL_STATUS'] == 'N' &&
              cutProductCode.isNotEmpty) {
            setState(() {
              validProductCode = cutProductCode;
              validSerialno = 'null';
              message = "Valid product code found.";
              print(
                  "Valid product code found WITH NULL : $validProductCode $validSerialno");
            });
          } else {
            setState(() {
              validProductCode = null;
              message = cutProductCode.isEmpty
                  ? "CUT_PRODUCT_CODE is empty or contains only invalid characters."
                  : "This item code cannot be scanned because SERIAL_STATUS is not \"Y\".";
              print("Invalid product code or SERIAL_STATUS issue.");
            });
            print("validProductCodEEEe: $validProductCode");
          }
        } else if (data is Map && data.containsKey('message')) {
          setState(() {
            validProductCode = null;
            message = data['message'];
            print("Message from server: $message");
          });
          print("validProductCodEEEe:11 $validProductCode");
        } else {
          setState(() {
            validProductCode = null;
            message = "Unexpected response format.";
            print("Unexpected response format.");
          });
          print("validProductCodEEEe: 222 $validProductCode");
        }
      } else {
        setState(() {
          validProductCode = null;
          message = "Failed to fetch data. Status code: ${response.statusCode}";
          print("HTTP error: ${response.statusCode}");
        });
        print("validProductCodEEEe333: $validProductCode");
      }
    } catch (e) {
      setState(() {
        validProductCode = null;
        message = "An error occurred: $e";
        print("Exception: $e");
        print("validProductCodEEEe:444 $validProductCode");
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content:
              const Text("All picked quantities are scanned successfully."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    for (var controller in barcodeControllers) {
      controller.dispose();
    }
    for (var controller in serialnoControllers) {
      controller.dispose();
    }
    for (var node in barcodeFocusNodes) {
      node.dispose();
    }
    for (var node in serialnoFocusNodes) {
      node.dispose();
    }
    super.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();

    postLogData("Pick Man Scan Pop-up View", "Closed");
  }

  final TextEditingController regionController = TextEditingController();
  final TextEditingController warehouseController = TextEditingController();

  Future<void> fetchRegionAndWarehouse() async {
    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/Physical_Warehouse/';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Find the entry for the given ORGANIZATION_ID
        final result = data['results'].firstWhere(
          (item) => item['ORGANIZATION_ID'] == saleslogiOrgid,
          orElse: () => null,
        );

        if (result != null) {
          // Update the controllers with fetched values
          setState(() {
            regionController.text = result['REGION_NAME'];
            warehouseController.text = result['WAREHOUSE_NAME'];
          });
        } else {
          // Clear the controllers if no match is found
          setState(() {
            regionController.text = '';
            warehouseController.text = '';
          });
          print('No data found for ORGANIZATION_ID: $saleslogiOrgid');
        }
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  bool isPosting = false; // Flag to prevent multiple submissions

  Future<void> postPickmanScan(int balanceqty) async {
    if (isPosting) {
      print('Already posting. Please wait.');
      return; // Prevent duplicate submissions
    }
    isPosting = true;

    final IpAddress = await getActiveIpAddress();

    final url = '$IpAddress/Pickman_scan/';
    await fetchRegionAndWarehouse();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginno = prefs.getString('salesloginno') ?? '';
    String? saveloginname = prefs.getString('saveloginname') ?? '';
    String? saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';

    try {
      DateTime now = DateTime.now();
      String date = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

      String reqno = widget.reqno.toString();
      String pickno = widget.pickno.isNotEmpty ? widget.pickno : '';
      String assignpickman =
          widget.assignpickname.isNotEmpty ? widget.assignpickname : '';
      String warehouse =
          warehouseController.text.isNotEmpty ? warehouseController.text : '';
      String org_name =
          regionController.text.isNotEmpty ? regionController.text : '';

      for (int i = 0; i < createtableData.length; i++) {
        var row = createtableData[i];
        var relatedRow = tableData.isNotEmpty ? tableData[i] : {};

        // Parsing numeric fields and ensuring correct data types
        var customer_trx_line_id =
            int.tryParse(row['customer_trx_line_id']?.toString() ?? '0') ?? 0;
        var customer_trx_id =
            int.tryParse(row['customer_trx_id']?.toString() ?? '0') ?? 0;

        print("tableDataaaaaaaaaaaaa:  $tableData");

        if (tableData.isNotEmpty) {
          await updateScanningStatus(balanceqty);

          Map<String, dynamic> createDispatchData = {
            "PICK_ID": pickno,
            "REQ_ID": reqno,
            "DATE": date,
            "ASSIGN_PICKMAN": assignpickman,
            "PHYSICAL_WAREHOUSE": warehouse,
            "ORG_ID": saleslogiOrgid.isNotEmpty ? saleslogiOrgid : 'Unknown',
            "ORG_NAME": org_name,
            "SALESMAN_NO": widget.salesman_No,
            "SALESMAN_NAME": widget.salesman_Name,
            "MANAGER_NO": widget.Manager_No,
            "MANAGER_NAME": widget.Manager_Name,
            "PICKMAN_NO": salesloginno.isNotEmpty ? salesloginno : 'Unknown',
            "PICKMAN_NAME":
                saveloginname.isNotEmpty ? saveloginname : 'Unknown',
            "CUSTOMER_NUMBER": widget.cusno,
            "CUSTOMER_NAME": widget.cusname,
            "CUSTOMER_SITE_ID": widget.cussite,
            "INVOICE_DATE": date,
            "INVOICE_NUMBER": invoiceNoController.text.isNotEmpty
                ? invoiceNoController.text
                : 'Unknown',
            "LINE_NUMBER": row['line_id']?.toString() ??
                '0', // Ensure this is a string if expected
            "INVENTORY_ITEM_ID": row['itemcode']?.toString() ?? '0',
            "ITEM_DESCRIPTION": row['itemdetails']?.toString() ?? '0',
            "CUSTOMER_TRX_ID": customer_trx_id,
            "CUSTOMER_TRX_LINE_ID": customer_trx_line_id,
            "TOT_QUANTITY": row['invoiceQty']?.toString() ?? '0',
            "DISPATCHED_QTY": row['dispatch_qty']?.toString() ?? '0',
            "BALANCE_QTY":
                (int.tryParse(row['dispatch_qty']?.toString() ?? '0') ??
                        0 - balanceqty)
                    .toString(),
            "PICKED_QTY": 1,
            "PRODUCT_CODE": relatedRow['Product Code'] ?? '',
            "SERIAL_NO": relatedRow['Serial No'] ?? '',
            "CREATION_DATE": date,
            "CREATED_BY": saveloginname.isNotEmpty ? saveloginname : 'Unknown',
            "LAST_UPDATE_DATE": date,
            "FLAG": 'A',
            "UNDEL_ID": widget.undel_id,
          };

          final response = await http.post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(createDispatchData),
          );

          if (response.statusCode == 201) {
            _deleteTableData(widget.pickno, widget.reqno, widget.itemcode,
                widget.invoiceQty);
            print(
                'Dispatch created successfully for Line Number: ${row['line_id']}');
          } else {
            print(
                'Failed to create dispatch for Line Number: ${row['line_id']}. Status code: ${response.statusCode}');
            print('Response body: ${response.body}');
          }
        }
      }
    } catch (e) {
      print('Error occurred while posting dispatch data: $e');
    } finally {
      isPosting = false;
    }
  }

  Future<void> updateScanningStatus(int balanceqty) async {
    print(
        "row id of the updated displatch requestttttttttttt is ${idcontroller.text} ---${tableData.length}");

    int alreadyScannedQty = int.tryParse(widget.alreadyscannedqty) ?? 0;

    print(
        "alreadyScannedQty   displatch request is ${alreadyScannedQty} ---${tableData.length}");

    // Calculate scannedQty by subtracting scannedItemsCount from alreadyScannedQty
    int scannedQty = alreadyScannedQty + tableData.length;

    String updateid = idcontroller.text;
    // Use the dynamic 'id' in the URL for the PUT request

    final IpAddress = await getActiveIpAddress();

    final String url =
        '$IpAddress/Dispatch_request/$updateid/'; // Make sure the ID is passed in the URL

    try {
      // Prepare the body of the PUT request
      Map<String, dynamic> body = {
        "STATUS": balanceqty == 0 ? "Finished" : "pending",
        "SCANNED_QTY": scannedQty
      };

      // Make the PUT request
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        print("Dispatched status updated successfully for ID: ");
      } else {
        print(
            "Failed to update dispatched status. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      // Handle any exceptions (network issues, etc.)
      print("An error occurred while updating dispatched status: $e");
    }
  }

  List<String> accessControl = [];
  Future<List<String>> fetchAccessControl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lableRoleIDList = prefs.getString('departmentid');
    String? salesloginnoStr = prefs.getString('salesloginno');

    final IpAddress = await getActiveIpAddress();

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

  bool byepassCheckbox = false; // State to track checkbox
// Toggle checkbox function
  void toggleCheckbox(bool? value) {
    setState(() {
      byepassCheckbox = value ?? false;

      // If the checkbox is checked, reset barcodeControllers and serialnoControllers
      if (byepassCheckbox) {
        barcodeControllers =
            List.generate(5, (index) => TextEditingController(text: "00"));
        serialnoControllers =
            List.generate(5, (index) => TextEditingController(text: "null"));
      } else {
        // Reinitialize them with 5 items or set default values if needed
        barcodeControllers =
            List.generate(5, (index) => TextEditingController(text: ""));
        serialnoControllers =
            List.generate(5, (index) => TextEditingController(text: ""));
      }
    });
  }

  TextEditingController invoiceNoController = TextEditingController();
  TextEditingController ItemcodeController = TextEditingController();
  TextEditingController itemDescriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int totalItems = createtableData.length;
    int _scanOption = 0; // 0 for Barcode, 1 for Cam/Manual

    print("tableDataaaaaaaaaaaaa:  $tableData");
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        width: Responsive.isDesktop(context)
            ? screenWidth * 0.7
            : screenWidth * 0.9,
        // height: MediaQuery.of(context).size.height * 0.4,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Scan Pop-Up View", style: TextStyle(fontSize: 14)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Count : ${tableData.length}/${widget.nofoqty.contains('.') ? widget.nofoqty.split('.')[0] : widget.nofoqty}', // Remove decimal part
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                )
              ]),
              const SizedBox(height: 10),
              if (validProductCode == null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    if (!Responsive.isMobile(context))
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Checkbox(
                            value: byepassCheckbox,
                            onChanged:
                                toggleCheckbox, // Handle checkbox state change
                          ),
                          const Text('Bypass Product Code and Serial No'),
                        ],
                      ),
                    if (Responsive.isMobile(context))
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Checkbox(
                              value: byepassCheckbox,
                              onChanged:
                                  toggleCheckbox, // Handle checkbox state change
                            ),
                            const Text('Bypass Product Code and Serial No'),
                          ],
                        ),
                      ),
                  ],
                ),

              if (!Responsive.isMobile(context))
                StatefulBuilder(builder: (context, setState) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildTextFieldPopup(
                            'Invoice No',
                            invoiceNoController.text,
                            Icons.numbers,
                            true,
                            33,
                            120,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          _buildTextFieldPopup(
                            'Item Code',
                            ItemcodeController.text,
                            Icons.numbers,
                            true,
                            33,
                            120,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          _buildTextFieldPopup(
                            'Item Description',
                            itemDescriptionController.text,
                            Icons.numbers,
                            true,
                            33,
                            200,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          _buildScanField(0)
                        ],
                      ),
                    ),
                  );
                }),
              if (Responsive.isMobile(context))
                StatefulBuilder(builder: (context, setState) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildInfoRow(Icons.receipt, 'Invoice No:',
                            invoiceNoController.text),
                        _buildInfoRow(
                            Icons.code, 'Item Code:', ItemcodeController.text),
                        _buildInfoRow(Icons.description, 'Item Desc:',
                            itemDescriptionController.text,
                            minLines: 4),
                        Row(
                          children: [
                            Transform.scale(
                              scale: 0.8,
                              child: Radio(
                                value: 0,
                                groupValue: _scanMode,
                                onChanged: (value) {
                                  setState(() {
                                    _scanMode = value!;
                                    if (_scanMode == 0) {
                                      // Delay required to allow widget to build before focusing
                                      Future.delayed(
                                          Duration(milliseconds: 300), () {
                                        FocusScope.of(context)
                                            .requestFocus(barcodeFocusNodes[0]);
                                      });
                                    }
                                  });
                                },
                              ),
                            ),
                            Text("Barcode", style: TextStyle(fontSize: 13)),
                            SizedBox(width: 10),
                            Transform.scale(
                              scale: 0.8,
                              child: Radio(
                                value: 1,
                                groupValue: _scanMode,
                                onChanged: (value) {
                                  setState(() {
                                    _scanMode = value!;
                                  });
                                },
                              ),
                            ),
                            Text("Cam/Manual", style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: _buildScanField(0)),
                      ],
                    ),
                  );
                }),
              const SizedBox(
                height: 5,
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),

              _viewbuildTable(),

              const SizedBox(
                height: 10,
              ),
              // Padding(
              //   padding: EdgeInsets.all(Responsive.isDesktop(context) ? 15 : 5),
              //   child: Container(
              //     height: 200,
              //     child: SingleChildScrollView(
              //       scrollDirection: Axis.vertical,
              //       child: _viewbuildTable(),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 15),
              Responsive.isDesktop(context)
                  ? Row(
                      children: [
                        SizedBox(
                            width: Responsive.isDesktop(context) ? 30 : 10),
                        Text(
                          'No. of Items: $totalItems',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 30),
                        Text(
                          'Scanned Items: ${tableData.length}', // Dynamically updated text
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 30),
                        Text(
                          'Balance Items: ${totalItems - tableData.length}',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          'No. of Items: $totalItems',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Scanned Items: ${tableData.length}', // Dynamically updated text
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Balance Items: ${totalItems - tableData.length}',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Container(
                    height: 35,
                    decoration: BoxDecoration(color: buttonColor),
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              await _onSavePressed();

                              postLogData("Pick Man Scan Pop-up", "Saved");
                            },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize:
                            const Size(45.0, 20.0), // Set width and height
                        backgroundColor: Colors
                            .transparent, // Make background transparent to show gradient
                        shadowColor: Colors
                            .transparent, // Disable shadow to preserve gradient
                      ),
                      child: _isLoading
                          ? Container(
                              height: 20,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text('Save', style: TextStyle(color: Colors.white)),
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text("Scanned Items : ", style: topheadingbold),
              ),
              Padding(
                padding: EdgeInsets.all(Responsive.isDesktop(context) ? 15 : 5),
                child: Container(
                  height: 300,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: _AlreadyviewbuildTable(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Helper method to build the info row
  Widget _buildInfoRow(IconData icon, String label, String value,
      {int minLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.blueAccent,
          ), // Add the icon here
          SizedBox(width: 3), // Space between icon and label
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 99, 97, 97)),
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(
              value,
              maxLines: minLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewbuildTable() {
    return Padding(
      padding: Responsive.isDesktop(context)
          ? EdgeInsets.only(left: 15.0)
          : EdgeInsets.only(left: 0),
      child: Container(
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[400]!, // Border color
                      width: 1.0, // Border width
                    ),
                  ),
                  height: 220,
                  width: Responsive.isDesktop(context)
                      ? MediaQuery.of(context).size.width * 0.54
                      : MediaQuery.of(context).size.width * 0.80,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildHeaderCell("Product Code", Icons.code),
                            buildHeaderCell(
                                "Serial No", Icons.format_list_numbered),
                            buildHeaderDeleteCell('', Icons.delete),
                          ],
                        ),
                      ),
                      if (_isLoading)
                        Padding(
                          padding: const EdgeInsets.only(top: 60.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (tableData.isNotEmpty)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: tableData.map((data) {
                                var index = tableData.indexOf(data);
                                return buildRow(index, data);
                              }).toList(),
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: 60.0),
                          child: Text("No data available."),
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

  Widget buildRow(int index, Map<String, dynamic> data) {
    var productcode = data['Product Code'];
    var serialno = data['Serial No'];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDataCell(productcode),
            buildDataCell(serialno),
            buildDeleteCell(index),
          ],
        ),
      ),
    );
  }

  Widget buildDeleteCell(int index) {
    return Container(
      width: 50,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
      ),
      child: IconButton(
        icon: Icon(Icons.delete, size: 18),
        color: Colors.red,
        onPressed: () {
          _deleteRow(index);
        },
      ),
    );
  }

  void _deleteRow(int index) async {
    // First remove from the local tableData list
    setState(() {
      tableData.removeAt(index);
    });

    // Then update SharedPreferences
    await _updateSharedPreferences();

    // Optional: Show a snackbar confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

// Helper method to update SharedPreferences
  Future<void> _updateSharedPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String key =
          'tableData_${widget.pickno}_${widget.reqno}_${widget.itemcode}_${widget.invoiceno}';

      // Convert current tableData to string list
      List<String> tableDataStringList = tableData.map((data) {
        return json.encode(data);
      }).toList();

      // Save to SharedPreferences
      await prefs.setStringList(key, tableDataStringList);
    } catch (e) {
      print('Error updating SharedPreferences: $e');
      // Optionally show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update storage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget buildDataCell(String value) {
    return Flexible(
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(
              color: Color.fromARGB(255, 226, 225, 225)), // Border color
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: SelectableText(
                value,
                textAlign: TextAlign.left,
                style: TableRowTextStyle,
                showCursor: false,
                cursorColor: Colors.blue,
                cursorWidth: 2.0,
                toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeaderCell(String label, IconData icon) {
    return Flexible(
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(
              color: Color.fromARGB(255, 226, 225, 225)), // Border color
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 15, color: Colors.blue),
              SizedBox(width: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TableRowTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeaderDeleteCell(String label, IconData icon) {
    return Container(
      width: 50,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(
            color: Color.fromARGB(255, 226, 225, 225)), // Border color
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: Colors.blue),
            SizedBox(width: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TableRowTextStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldPopup(
    String label,
    String value,
    IconData icon,
    bool readOnly,
    double height,
    double width, {
    int? minLines,
    int? maxLines,
    TextInputType keyboardType = TextInputType.text,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(left: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Responsive.isDesktop(context) ? 20 : 10),
            Row(
              children: [
                Text(label, style: textboxheading),
                if (!readOnly)
                  Icon(
                    Icons.star,
                    size: 8,
                    color: Colors.red,
                  )
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 0, bottom: 0),
              child: Row(
                children: [
                  Container(
                      height: height,
                      // width: Responsive.isDesktop(context)
                      //     ? screenWidth * 0.086
                      //     : 130,

                      width: width,
                      child: MouseRegion(
                        onEnter: (event) {
                          // You can perform any action when mouse enters, like logging the value.
                        },
                        onExit: (event) {
                          // Perform any action when the mouse leaves the TextField area.
                        },
                        cursor: SystemMouseCursors
                            .click, // Changes the cursor to indicate interaction
                        child: Tooltip(
                          message: value,
                          child: TextFormField(
                            readOnly: readOnly,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(201, 132, 132, 132),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 58, 58, 58),
                                  width: 1.0,
                                ),
                              ),
                              filled: true, // Enable the background fill
                              fillColor: readOnly
                                  ? Color.fromARGB(255, 234, 234,
                                      234) // Change fill color when readOnly is true
                                  : Color.fromARGB(255, 250, 250,
                                      250), // Default color when not readOnly
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0,
                              ),
                            ),
                            keyboardType: keyboardType,
                            minLines: minLines,
                            maxLines: maxLines, // Allows wrapping
                            controller: TextEditingController(text: value),
                            style: TextStyle(
                                color: Color.fromARGB(255, 73, 72, 72),
                                fontSize: 13),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isLoading = false;

  // Mock function to simulate async operation
  Future<void> _onSavePressed() async {
    int totalItems = createtableData.length;
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Replace with your actual logic here
      await Future.delayed(Duration(milliseconds: 100)); // Simulate async work

      bool allFieldsEmpty = tableData.isEmpty;

      bool productCodeInvalid = false;
      int invalidBarcodeIndex = -1;

      // Validate barcodes
      for (int i = 0; i < barcodeControllers.length; i++) {
        String barcodeValue = barcodeControllers[i].text;
        if (barcodeValue.isNotEmpty && barcodeValue != validProductCode) {
          productCodeInvalid = true;
          invalidBarcodeIndex = i;
          break;
        }
      }

      if (validProductCode == null) {
        // Show confirmation dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmation', style: TextStyle(fontSize: 14)),
              content: const Text(
                  'Are you sure you want to save this product code and serial number details?',
                  style: TextStyle(fontSize: 12)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    int balanceqty = totalItems - tableData.length;
                    print('balanceqty: $balanceqty');

                    await postPickmanScan(balanceqty); // Save data
                    Navigator.of(context).pop();
                    await Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainSidebar(
                          enabledItems: accessControl,
                          initialPageIndex: 14,
                        ),
                      ),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Handling empty fields and invalid barcodes
        if (allFieldsEmpty) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Warning', style: TextStyle(fontSize: 17)),
                content: const Text(' Kindly fill all the fields.',
                    style: TextStyle(fontSize: 15)),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else if (productCodeInvalid) {
          print("savebutonnnnn");
          if (byepassCheckbox = true)
            showwarningbarcode(context, barcodeControllers[invalidBarcodeIndex],
                barcodeFocusNodes[invalidBarcodeIndex]);
        } else {
          // Check for missing serial numbers
          List<int> missingSerialnoIndexes = [];
          for (int i = 0; i < barcodeControllers.length; i++) {
            String barcodeValue = barcodeControllers[i].text;
            String serialnoValue = serialnoControllers[i].text;

            if (barcodeValue.isNotEmpty && serialnoValue.isEmpty) {
              missingSerialnoIndexes.add(i);
            }
          }

          if (missingSerialnoIndexes.isNotEmpty && validProductCode != '00') {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Warning', style: TextStyle(fontSize: 17)),
                  content: const Text(
                      'You entered barcode(s) without filling the corresponding serial number(s). Kindly fill in all fields.',
                      style: TextStyle(fontSize: 15)),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        for (var index in missingSerialnoIndexes) {
                          serialnoControllers[index].clear();
                        }
                        FocusScope.of(context).requestFocus(
                            serialnoFocusNodes[missingSerialnoIndexes[0]]);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          } else {
            // Check for duplicate serial numbers
            Set<String> seenSerials = {};
            bool hasDuplicates = false;
            List<int> duplicateIndexes = [];

            for (int i = 0; i < serialnoControllers.length; i++) {
              String serialValue = serialnoControllers[i].text;
              if (serialValue.isNotEmpty) {
                if (seenSerials.contains(serialValue)) {
                  hasDuplicates = true;
                  duplicateIndexes.add(i);
                } else {
                  seenSerials.add(serialValue);
                }
              }
            }

            if (hasDuplicates) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title:
                        const Text('Warning', style: TextStyle(fontSize: 17)),
                    content: const Text(
                        'Duplicate serial numbers found. Kindly ensure all serial numbers are unique.',
                        style: TextStyle(fontSize: 15)),
                    actions: [
                      TextButton(
                        onPressed: () {
                          for (var index in duplicateIndexes) {
                            serialnoControllers[index].clear();
                          }
                          Navigator.of(context).pop(); // Close dialog
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            } else {
              // Proceed with saving data
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirmation',
                        style: TextStyle(fontSize: 13)),
                    content: const Text(
                        'Are you sure you want to save this product code and serial number details?',
                        style: TextStyle(fontSize: 13)),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          int balanceqty = totalItems - tableData.length;
                          print('balanceqty: $balanceqty');
                          try {
                            await postPickmanScan(
                                balanceqty); // Call function to save data
                            Navigator.of(context).pop();
                            await Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainSidebar(
                                  enabledItems: accessControl,
                                  initialPageIndex: 14,
                                ),
                              ),
                            );
                          } catch (e) {
                            print('Error saving data: $e');
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: Text('Failed to save data: $e'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          }
        }
      }
    } catch (e) {
      // Handle unexpected errors
      print('Unexpected error: $e');
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'An unexpected error occurred. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }
// Function to fetch serial numbers from the API

  // Future<List<String>> fetchExistingSerialNumbers() async {
  //   Set<String> serialNumbers = {}; // Use Set to automatically avoid duplicates
  //   String? url = '$IpAddress/Pickman_scan/';

  //   while (url != null) {
  //     final response = await http.get(Uri.parse(url));

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);

  //       // Add serial numbers from the current page to the set if FLAG != 'R' and FLAG != 'SR'
  //       for (var item in data['results']) {
  //         if (item['FLAG'] != 'R' && item['FLAG'] != 'SR') {
  //           serialNumbers
  //               .add(item['SERIAL_NO']); // Adding to Set prevents duplicates
  //         }
  //       }

  //       // Update the URL for the next page, or null if there is no next page
  //       url = data['next'];
  //     } else {
  //       throw Exception('Failed to load serial numbers');
  //     }
  //   }

  //   // Convert Set back to List to return it
  //   return serialNumbers.toList();
  // }

  Future<List<String>> fetchExistingSerialNumbers({
    String? productCode,
  }) async {
    Set<String> serialNumbers = {}; // Use Set to automatically avoid duplicates

    final IpAddress = await getActiveIpAddress();

    String? url = '$IpAddress/Pickman_scan/';

    while (url != null) {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Add serial numbers from the current page to the set if FLAG != 'R' and FLAG != 'SR'
        for (var item in data['results']) {
          if (item['FLAG'] != 'R' &&
              item['FLAG'] != 'SR' &&
              item['PRODUCT_CODE'] == productCode) {
            serialNumbers
                .add(item['SERIAL_NO']); // Adding to Set prevents duplicates
          }
        }

        // Update the URL for the next page, or null if there is no next page
        url = data['next'];
      } else {
        throw Exception('Failed to load serial numbers');
      }
    }

    // Convert Set back to List to return it
    return serialNumbers.toList();
  }

  Future<bool> checkIfSerialExistsInPaginatedApi(
    String apiUrl,
    String serialNo, {
    String? productCode,
  }) async {
    String? nextUrl = apiUrl;

    while (nextUrl != null) {
      final response = await http.get(Uri.parse(nextUrl));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<dynamic> results = jsonData['results'];

        // Check for existence of the serial number, product code, and FLAG == 'R'
        bool exists = results.any((item) {
          bool matchesSerial = item['SERIAL_NO'] == serialNo;
          // bool matchesProduct =
          // productCode == null || item['PRODUCT_CODE'] == productCode;
          bool matchesProduct = item['PRODUCT_CODE'] == productCode;
          bool matchesFlag = item['FLAG'] != 'R' && item['FLAG'] != 'SR';
          return matchesSerial && matchesProduct && matchesFlag;
        });

        if (exists) {
          return true; // Serial number found in the current page
        }

        nextUrl = jsonData['next']; // Update nextUrl for pagination
      } else {
        print('Failed to fetch data from API: ${response.statusCode}');
        throw Exception('Error fetching data from API.');
      }
    }

    return false; // Serial number not found in all pages
  }

  Future<bool> _isDuplicateEntry(
    List<TextEditingController> controllers,
    String value, {
    String? productCode,
  }) async {
    // Check in the local controllers first
    bool isLocalDuplicate =
        controllers.where((controller) => controller.text == value).length > 1;

    if (isLocalDuplicate) return true;

    final IpAddress = await getActiveIpAddress();

    // Check using the paginated API
    String apiUrl = '$IpAddress/Truck_scan/';
    bool existsInPaginatedApi = await checkIfSerialExistsInPaginatedApi(
      apiUrl,
      value,
      productCode: productCode,
    );
    if (existsInPaginatedApi) return true;

    // Fallback to fetching all serial numbers if paginated API doesn't find it
    List<String> existingSerialNumbers =
        await fetchExistingSerialNumbers(productCode: productCode);
    if (existingSerialNumbers.contains(value)) return true;
    // print("existingSerialNumbers  $existingSerialNumbers");

    // No duplicate found
    return false;
  }

// // Helper function to check for duplicate entries in barcode or serial number
//   bool _isDuplicateEntry(
//       List<TextEditingController> controllers, String value) {
//     return controllers.where((controller) => controller.text == value).length >
//         1;
//   }

  void _showDuplicateAlert(BuildContext context, String heading,
      TextEditingController controller, FocusNode focusNode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(heading, style: TextStyle(fontSize: 18)),
          content:
              Text("This code already exists.", style: TextStyle(fontSize: 13)),
          actions: [
            TextButton(
              onPressed: () {
                controller.clear(); // Clear the controller on duplicate alert
                Navigator.of(context).pop(); // Close the alert dialog
                focusNode.requestFocus(); // Set focus back to the cleared field
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showWarning(BuildContext context, TextEditingController controller,
      FocusNode focusNode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Warning", style: TextStyle(fontSize: 18)),
          content: Text("This field cannot be  empty",
              style: TextStyle(fontSize: 13)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

//   Widget _viewbuildTable() {
//     return Scrollbar(
//       thumbVisibility: true,
//       controller: _horizontalScrollController,
//       child: SingleChildScrollView(
//         controller: _horizontalScrollController,
//         scrollDirection: Axis.horizontal,
//         child: Container(
//           width: Responsive.isDesktop(context)
//               ? MediaQuery.of(context).size.width * 0.50
//               : MediaQuery.of(context).size.width * 1.1,
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // _buildTableHeaderCell("No"),
//                     // _buildTableHeaderCell("Invoice No"),
//                     // _buildTableHeaderCell("Item Code"),
//                     // _buildTableHeaderCell("Item Details"),
//                     _buildTableHeaderCell("Product Code"),
//                     _buildTableHeaderCell("Serial No"),
//                   ],
//                 ),
//               ),
//               ...createtableData.asMap().entries.map((entry) {
//                 int index = entry.key;
//                 return _buildDataRow(index);
//               }).toList(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTableHeaderCell(String label) {
//     return Flexible(
//       child: Container(
//         height: Responsive.isDesktop(context) ? 25 : 30,
//         color: Colors.grey.shade300,
//         child: Center(
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Text(label,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold)),
//           ),
//         ),
//       ),
//     );
//   }

// // Updated _buildDataRow function to apply the duplicate check only to serialnoControllers
//   Widget _buildDataRow(int index) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           if (index < barcodeControllers.length)
//             Flexible(
//               child: _buildInputField(
//                 controller: barcodeControllers[
//                     index], // Pass the controller for barcode
//                 focusNode:
//                     barcodeFocusNodes[index], // Pass the focusNode for barcode
//                 textInputAction:
//                     TextInputAction.next, // Set the next action for input field
//                 icon1: Icons.qr_code_scanner, // Set the first icon
//                 iconColor1: Colors.blue, // Set the color for the first icon
//                 icon2: Icons.camera_alt, // Set the second icon
//                 iconColor2: Colors.green, // Set the color for the second icon
//                 onIconPressed: () => _openScannerProdCode(
//                     barcodeControllers[index],
//                     barcodeFocusNodes[index],
//                     index), // Icon press action
//                 // onIconPressed: () => {},

//                 onFieldSubmitted: (value) {
//                   // Barcode validation and field switching logic
//                   if (validProductCode != null) {
//                     if (barcodeControllers[index].text.isNotEmpty &&
//                         barcodeControllers[index].text == validProductCode) {
//                       if (index < createtableData.length) {
//                         FocusScope.of(context)
//                             .requestFocus(serialnoFocusNodes[index]);
//                       }
//                     } else {
//                       showwarningbarcode(
//                         context,
//                         barcodeControllers[index],
//                         barcodeFocusNodes[index],
//                       );
//                     }
//                   }

//                   // else {
//                   //   if (barcodeControllers[index].text.isNotEmpty) {
//                   //     if (index < createtableData.length) {
//                   //       FocusScope.of(context)
//                   //           .requestFocus(serialnoFocusNodes[index]);
//                   //     }
//                   //   }
//                   // }
//                 },
//                 index: index, // Pass the index to track specific controller
//               ),
//             ),
//           if (index < serialnoControllers.length)
//             Flexible(
//               child: _buildInputField(
//                 controller: serialnoControllers[
//                     index], // Pass the controller for serialno
//                 focusNode: serialnoFocusNodes[
//                     index], // Pass the focusNode for serialno
//                 textInputAction:
//                     TextInputAction.next, // Set the next action for input field
//                 icon1: Icons.qr_code_scanner, // Set the first icon
//                 iconColor1: Colors.blue, // Set the color for the first icon
//                 icon2: Icons.camera_alt, // Set the second icon
//                 iconColor2: Colors.green, // Set the color for the second icon
//                 onIconPressed: () =>
//                     _openScannerSerial(index), // Icon press action
//                 // onIconPressed: () => {},
//                 onFieldSubmitted: (value) async {
//                   if (serialnoControllers[index].text.isEmpty) {
//                     _showWarning(context, serialnoControllers[index],
//                         serialnoFocusNodes[index]);
//                   } else if (await _isDuplicateEntry(
//                       serialnoControllers, value)) {
//                     _showDuplicateAlert(context, serialnoControllers[index],
//                         serialnoFocusNodes[index]);
//                   } else {
//                     if (index < createtableData.length - 1) {
//                       FocusScope.of(context)
//                           .requestFocus(barcodeFocusNodes[index + 1]);
//                     } else {
//                       FocusScope.of(context).requestFocus(barcodeFocusNodes[0]);
//                     }
//                   }
//                 },

//                 index: index, // Pass the index to track specific controller
//               ),
//             ),
//         ],
//       ),
//     );
//   }

  List<Map<String, String>> tableData = []; // Table data
  bool isProcessing = false; // Declare the isProcessing variable

  Future<bool> _isDuplicateEntryNew(
      List<TextEditingController> controllers, String serialNo) async {
    // Check for duplicate entries based on serialNo (you can implement the actual check logic here)
    for (var controller in controllers) {
      if (controller.text == serialNo) {
        return true; // Duplicate entry found
      }
    }
    return false; // No duplicate found
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

  // Future<void> _addToTable(int index) async {
  //   // Prevent multiple submissions while processing
  //   if (isProcessing) return;

  //   String barcode =
  //       barcodeControllers[index].text.trim(); // Trim spaces from the input
  //   String serialNo = serialnoControllers[index].text.trim();

  //   // Validation: Check if fields are empty
  //   if (barcode.isEmpty || serialNo.isEmpty) {
  //     _showWarningDialog(context, "Warning",
  //         "Kindly fill in all the information by scanning.");
  //     return;
  //   }

  //   // Validation: Check if barcode matches valid product code
  //   if (!_isButtonDisabled) {
  //     print('showwarningbarcode  -$barcode-${validProductCode.toString()}');
  //     if (barcode != validProductCode.toString()) {
  //       showwarningbarcode(
  //           context, barcodeControllers[index], barcodeFocusNodes[index]);
  //       return;
  //     }
  //   }

  //   // Validation: Check for duplicate serial number
  //   if (!_isButtonDisabled) {
  //     if (await _isDuplicateEntry(serialnoControllers, serialNo)) {
  //       if (!isDuplicateAlertShown) {
  //         _showDuplicateAlert(
  //           context,
  //           serialnoControllers[index],
  //           serialnoFocusNodes[index],
  //         );
  //         isDuplicateAlertShown = true; // Mark the duplicate alert as shown
  //       }
  //       return; // Prevent duplicate entry
  //     }
  //   }

  //   // Validation: Ensure serial number is valid
  //   if (serialNo.isEmpty) {
  //     _showDuplicateAlert(
  //       context,
  //       serialnoControllers[index],
  //       serialnoFocusNodes[index],
  //     );
  //     print('Invalid serial number');
  //     return; // Prevent invalid entry
  //   }

  //   // Disable the button temporarily to prevent multiple clicks
  //   setState(() {
  //     isProcessing = true;
  //   });
  //   try {
  //     // Add data to the table
  //     setState(() {
  //       tableData.add({
  //         'Product Code': barcode,
  //         'Serial No': serialNo,
  //       });

  //       // Clear the input fields
  //       barcodeControllers[index].clear();
  //       serialnoControllers[index].clear();
  //     });
  //   } catch (e) {
  //     print("Error adding to table: $e");
  //   } finally {
  //     // Re-enable the button once the operation is complete
  //     setState(() {
  //       isProcessing = false;
  //     });
  //   }
  // }

  Future<void> _addToTable(int index) async {
    if (isProcessing) return; // Prevent multiple submissions

    String barcode = barcodeControllers[index].text.trim();
    String serialNo = serialnoControllers[index].text.trim();

    // Validation: Check if fields are empty
    if (barcode.isEmpty || serialNo.isEmpty) {
      _showWarningDialog(context, "Warning",
          "Kindly fill in all the information by scanning.");
      return;
    }

    // Check for valid product code only if button is not disabled
    if (!_isButtonDisabled && barcode != validProductCode.toString()) {
      if (byepassCheckbox) {
        showwarningbarcode(
            context, barcodeControllers[index], barcodeFocusNodes[index]);
      }
      return;
    }

    // Check for duplicate serial number
    if (_isButtonDisabled &&
        await _isDuplicateEntry(serialnoControllers, serialNo)) {
      _showDuplicateAlert(context, "Duplicate Entry",
          serialnoControllers[index], serialnoFocusNodes[index]);
      return;
    }

    // Disable the button temporarily to prevent multiple clicks
    setState(() {
      isProcessing = true;
    });

    try {
      // Add data to the table
      tableData.add({
        'Product Code': barcode,
        'Serial No': serialNo,
      });

      // Clear the input fields
      barcodeControllers[index].clear();
      serialnoControllers[index].clear();

      // Manage focus
      if (tableData.length != int.parse(widget.nofoqty.split('.')[0])) {
        FocusScope.of(context).requestFocus(barcodeFocusNodes[index]);
      } else {
        FocusScope.of(context).unfocus();
        serialnoFocusNodes[index].unfocus();
      }
    } catch (e) {
      print("Error adding to table: $e");
    } finally {
      setState(() {
        isProcessing = false; // Re-enable the button
      });
    }
  }

  Future<void> _addToTablebypass(int index) async {
    if (isProcessing) return; // Prevent multiple submissions

    String barcode = barcodeControllers[index].text.trim();
    String serialNo = serialnoControllers[index].text.trim();

    // Parse maxQty once
    int maxQty = widget.nofoqty.contains('.')
        ? int.parse(widget.nofoqty.split('.')[0])
        : int.parse(widget.nofoqty);

    print("Max quantity allowed: $maxQty");

    // Allow '00' and empty values
    bool isBarcodeEmpty = barcode.isEmpty || barcode == "00";
    bool isSerialEmpty = serialNo.isEmpty || serialNo == "null";

    // Validation: Barcode and Serial No cannot be same unless they're empty or "00"
    if (!isBarcodeEmpty && !isSerialEmpty && barcode == serialNo) {
      _showWarningDialog(
        context,
        "Warning",
        "Product code and serial number should not be the same.",
      );
      return;
    }

    // Validation: Check if barcode matches valid product code (if validation is enabled)
    if (!_isButtonDisabled && !isBarcodeEmpty) {
      if (barcode != validProductCode.toString()) {
        print("Barcode does not match valid product code.");
        if (byepassCheckbox == true) {
          showwarningbarcode(
            context,
            barcodeControllers[index],
            barcodeFocusNodes[index],
          );
        }
        return;
      }
    }

    setState(() {
      isProcessing = true;
    });

    try {
      // Determine how many more items can be added
      int remainingQty = maxQty - tableData.length;
      print("Remaining Qty: $remainingQty");

      for (int i = 0; i < remainingQty; i++) {
        tableData.add({
          'Product Code': barcode,
          'Serial No': serialNo,
        });
      }

      // Clear input fields
      barcodeControllers[index].clear();
      serialnoControllers[index].clear();

      FocusScope.of(context).unfocus();
    } catch (e) {
      print("Error adding to table: $e");
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  // Future<void> _addToTablebypass(int index) async {
  //   if (isProcessing) return; // Prevent multiple submissions

  //   String barcode = barcodeControllers[index].text.trim();
  //   String serialNo = serialnoControllers[index].text.trim();

  //   // Validation: Check if fields are empty
  //   if (barcode.isEmpty || serialNo.isEmpty) {
  //     _showWarningDialog(context, "Warning",
  //         "Kindly fill in all the information by scanning.");
  //     return;
  //   }

  //   // Validation: Product Code and Serial Number should not be the same
  //   if (barcode == serialNo) {
  //     _showWarningDialog(context, "Warning",
  //         "Product code and serial number should not be the same.");
  //     return;
  //   }

  //   // Validation: Check if barcode matches valid product code
  //   if (!_isButtonDisabled) {
  //     print(
  //         'showwarningbarcodeeeeeeeeeeeee  -$barcode-${validProductCode.toString()}');
  //     if (barcode != validProductCode.toString()) {
  //       print("savebutonnnnn3");
  //       if (byepassCheckbox == true) {
  //         showwarningbarcode(
  //             context, barcodeControllers[index], barcodeFocusNodes[index]);
  //       }
  //       return;
  //     }
  //   }

  //   // Validation: Check for duplicate serial number
  //   // if (_isButtonDisabled) {
  //   //   if (await _isDuplicateEntry(serialnoControllers, serialNo,
  //   //       productCode: barcode)) {
  //   //     _showDuplicateAlert(
  //   //       context,
  //   //       "Duplicate Entry",
  //   //       serialnoControllers[index],
  //   //       serialnoFocusNodes[index],
  //   //     );
  //   //     isDuplicateAlertShown = true;
  //   //     return;
  //   //   }
  //   // }

  //   // Validation: Ensure serial number is valid
  //   if (serialNo.isEmpty) {
  //     _showDuplicateAlert(
  //       context,
  //       "Duplicate Entry",
  //       serialnoControllers[index],
  //       serialnoFocusNodes[index],
  //     );
  //     print('Invalid serial number');
  //     return;
  //   }
  //   // Disable the button temporarily to prevent multiple clicks
  //   setState(() {
  //     isProcessing = true;
  //   });

  //   try {
  //     // Add data to the table

  //     setState(() {
  //       tableData.add({
  //         'Product Code': barcode,
  //         'Serial No': serialNo,
  //       });

  //       // Clear the input fields
  //       barcodeControllers[index].clear();
  //       serialnoControllers[index].clear();

  //       int maxQty = widget.nofoqty.contains('.')
  //           ? int.parse(widget.nofoqty.split('.')[0])
  //           : int.parse(widget.nofoqty);
  //       print("maxQtyyyyyyyyyy $maxQty");
  //       if (tableData.length != maxQty) {
  //         FocusScope.of(context).requestFocus(barcodeFocusNodes[index]);
  //       } else {
  //         FocusScope.of(context).unfocus();
  //         serialnoFocusNodes[index].unfocus();
  //       }
  //     });

  //     // Clear the input fields
  //     barcodeControllers[index].clear();
  //     serialnoControllers[index].clear();
  //   } catch (e) {
  //     print("Error adding to table: $e");
  //   } finally {
  //     setState(() {
  //       isProcessing = false; // Re-enable the button
  //     });
  //   }
  // }

  // Future<void> _addToTable(int index) async {
  //   // Prevent multiple submissions while processing
  //   if (isProcessing) return;

  //   String barcode =
  //       barcodeControllers[index].text.trim(); // Trim spaces from the input
  //   String serialNo = serialnoControllers[index].text.trim();

  //   // Validation: Check if fields are empty
  //   if (barcode.isEmpty || serialNo.isEmpty) {
  //     _showWarningDialog(context, "Warning",
  //         "Kindly fill in all the information by scanning.");
  //     return;
  //   }

  //   // Validation: Check if barcode matches valid product code
  //   if (!_isButtonDisabled) {
  //     print(
  //         'showwarningbarcodeeeeeeeeeeeee  -$barcode-${validProductCode.toString()}');
  //     if (barcode != validProductCode.toString()) {
  //       print("savebutonnnnn3");
  //       if (byepassCheckbox = true)
  //         showwarningbarcode(
  //             context, barcodeControllers[index], barcodeFocusNodes[index]);
  //       return;
  //     }
  //   }

  //   // Validation: Check for duplicate serial number
  //   if (_isButtonDisabled) {
  //     if (await _isDuplicateEntry(serialnoControllers, serialNo,
  //         productCode: barcode)) {
  //       // if (!isDuplicateAlertShown)
  //       {
  //         _showDuplicateAlert(
  //           context,
  //           "Duplicate Entry",
  //           serialnoControllers[index],
  //           serialnoFocusNodes[index],
  //         );
  //         isDuplicateAlertShown = true; // Mark the duplicate alert as shown
  //       }
  //       return; // Prevent duplicate entry
  //     }
  //   }

  //   // Validation: Ensure serial number is valid
  //   if (serialNo.isEmpty) {
  //     _showDuplicateAlert(
  //       context,
  //       "Duplicate Entry",
  //       serialnoControllers[index],
  //       serialnoFocusNodes[index],
  //     );
  //     print('Invalid serial number');
  //     return; // Prevent invalid entry
  //   }

  //   // Disable the button temporarily to prevent multiple clicks
  //   setState(() {
  //     isProcessing = true;
  //   });
  //   try {
  //     // Add data to the table
  //     setState(() {
  //       tableData.add({
  //         'Product Code': barcode,
  //         'Serial No': serialNo,
  //       });

  //       // Clear the input fields
  //       barcodeControllers[index].clear();
  //       serialnoControllers[index].clear();
  //       if (tableData.length !=
  //           (widget.nofoqty.contains('.')
  //               ? int.parse(widget.nofoqty.split('.')[0])
  //               : int.parse(widget.nofoqty))) {
  //         FocusScope.of(context).requestFocus(barcodeFocusNodes[index]);
  //       } else {
  //         FocusScope.of(context).unfocus(); // Unfocus any existing focus
  //         serialnoFocusNodes[index].unfocus(); // Unfocus serial number field
  //       }
  //     });
  //   } catch (e) {
  //     print("Error adding to table: $e");
  //   } finally {
  //     // Re-enable the button once the operation is complete
  //     setState(() {
  //       isProcessing = false;
  //     });
  //   }
  // }

  bool _isButtonDisabled = false;
  bool isDuplicateAlertShown = false;

  FocusNode buttonFocus = FocusNode();
  FocusNode SerialcameraFocus = FocusNode();
  FocusNode ProductcameraFocus = FocusNode();
  int _scanMode = 0; // 0 = Barcode, 1 = Cam/Manual
  bool _blockSerialProcessing = false;

  Widget _buildScanField(int index) {
    String quantity = widget.nofoqty ?? ''; // Ensure it’s not null
    quantity = quantity.contains('.') ? quantity.split('.')[0] : quantity;
    int maxQuantity = int.tryParse(quantity) ?? 0;
    // Use a fallback value if conversion fails
    Timer? _typingTimer;
    Timer? _serialTypingTimer; // Add this as a class member variable
    bool _isAdding = false; // Add this flag to prevent multiple additions

    return Padding(
      padding: Responsive.isDesktop(context)
          ? EdgeInsets.only(top: 50)
          : EdgeInsets.only(top: 10, right: 50),
      child: Padding(
        padding: const EdgeInsets.only(right: 0, top: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barcode TextField
// Barcode TextField
            if (index < barcodeControllers.length)
              Container(
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.3
                    : MediaQuery.of(context).size.width * 0.63,
                height: 33,
                child: TextField(
                  readOnly: (validProductCode == '00') ||
                      (validSerialno == null) ||
                      byepassCheckbox,
                  controller: barcodeControllers[index]
                    ..text = validProductCode == '00'
                        ? '00'
                        : barcodeControllers[index].text,
                  focusNode: barcodeFocusNodes[index],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(201, 132, 132, 132),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 58, 58, 58),
                        width: 1.0,
                      ),
                    ),
                    suffixIcon: (_scanMode == 1)
                        ? IconButton(
                            focusNode: ProductcameraFocus,
                            onPressed: () {
                              _openScannerProdCode(barcodeControllers[index],
                                  barcodeFocusNodes[index], index);
                            },
                            icon: Icon(Icons.camera_alt, color: Colors.green),
                          )
                        : null,
                    labelText: "Product Code",
                    labelStyle: TextStyle(fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 10.0,
                    ),
                  ),
                  // onSubmitted: (value) {
                  //   if (validProductCode != null &&
                  //       barcodeControllers[index].text.trim() ==
                  //           validProductCode.toString() &&
                  //       index < createtableData.length) {
                  //     // Focus on the Serial No camera input
                  //     FocusScope.of(context).requestFocus(SerialcameraFocus);

                  //     // Open the camera for Serial No immediately
                  //     _openScannerProdCode(
                  //         serialnoControllers[index], SerialcameraFocus, index);
                  //   } else {
                  //     print("savebutonnnnn5");
                  //     if (byepassCheckbox) {
                  //       showwarningbarcode(context, barcodeControllers[index],
                  //           barcodeFocusNodes[index]);
                  //     }
                  //   }
                  // },
                  onChanged: (value) {
                    final input =
                        value.trim().replaceAll(RegExp(r'[\n\r]'), '');
                    final validCode = validProductCode?.trim();

                    if (_scanMode == 0 && validCode != null) {
                      // Cancel previous timer if it exists
                      _typingTimer?.cancel();

                      // Start a new timer that will trigger after 500ms of inactivity
                      _typingTimer =
                          Timer(const Duration(milliseconds: 500), () {
                        if (input.length == validCode.length) {
                          if (input == validCode) {
                            // ✅ Valid → focus serial
                            FocusScope.of(context)
                                .requestFocus(serialnoFocusNodes[index]);
                          } else {
                            // ❌ Invalid → show warning
                            showwarningbarcode(
                              context,
                              barcodeControllers[index],
                              barcodeFocusNodes[index],
                            );
                            barcodeControllers[index].clear();
                            FocusScope.of(context)
                                .requestFocus(barcodeFocusNodes[index]);
                          }
                        }
                        // If length doesn't match, do nothing (user might still be typing)
                      });
                    }
                  },
                  onSubmitted: (value) {
                    final input =
                        value.trim().replaceAll(RegExp(r'[\n\r]'), '');
                    final validCode = validProductCode?.trim();

                    if (_scanMode == 0 &&
                        validCode != null &&
                        input == validCode) {
                      // ✅ Focus on Serial No
                      FocusScope.of(context)
                          .requestFocus(serialnoFocusNodes[index]);
                    } else {
                      // ❌ Invalid
                      showwarningbarcode(
                        context,
                        barcodeControllers[index],
                        barcodeFocusNodes[index],
                      );
                      barcodeControllers[index].clear();
                      FocusScope.of(context)
                          .requestFocus(barcodeFocusNodes[index]);
                    }
                  },

                  style: TextStyle(fontSize: 13),
                ),
              ),
            SizedBox(height: 15), // Add spacing between fields

            // Serial No TextField
            if (index < serialnoControllers.length)
              Container(
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.3
                    : MediaQuery.of(context).size.width * 0.63,
                height: 33,
                child: TextField(
                  readOnly: (validSerialno == 'null') ||
                      (validSerialno == null) ||
                      byepassCheckbox,
                  controller: serialnoControllers[index]
                    ..text = (validSerialno == 'null')
                        ? 'null'
                        : serialnoControllers[index].text,
                  focusNode: serialnoFocusNodes[index],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(201, 132, 132, 132),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 58, 58, 58),
                        width: 1.0,
                      ),
                    ),
                    suffixIcon: (_scanMode == 1)
                        ? IconButton(
                            focusNode: SerialcameraFocus,
                            onPressed: () {
                              _openScannerSerial(index);
                            },
                            icon: Icon(Icons.camera_alt, color: Colors.green),
                          )
                        : null,
                    labelText: "Serial No",
                    labelStyle: TextStyle(fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 10.0,
                    ),
                  ),
                  onChanged: (value) async {
                    final input =
                        value.trim().replaceAll(RegExp(r'[\n\r]'), '');
                    if (input.isEmpty) return;

                    _serialTypingTimer?.cancel();

                    _serialTypingTimer =
                        Timer(const Duration(milliseconds: 500), () async {
                      if (_isAdding || _blockSerialProcessing) return;

                      _isAdding = true;
                      isDuplicateAlertShown =
                          false; // Reset duplicate alert flag

                      try {
                        final isDuplicate =
                            await _isDuplicateEntry(serialnoControllers, input);

                        if (isDuplicate) {
                          debugPrint(
                              "🚫 Duplicate serial detected, skipping _handleAddSerial");
                          _blockSerialProcessing =
                              true; // Block further processing

                          if (!isDuplicateAlertShown) {
                            _showDuplicateAlert(
                              context,
                              "Duplicate Entry",
                              serialnoControllers[index],
                              serialnoFocusNodes[index],
                            );
                            isDuplicateAlertShown = true;
                          }
                          return;
                        }

                        _blockSerialProcessing =
                            false; // Allow processing again
                        await _handleAddSerial(index);

                        barcodeControllers[index].clear();
                        serialnoControllers[index].clear();

                        await Future.delayed(const Duration(milliseconds: 50));

                        if (mounted) {
                          FocusScope.of(context)
                              .requestFocus(barcodeFocusNodes[index]);
                        }
                      } finally {
                        _isAdding = false;
                      }
                    });
                  },

                  // onChanged: (text) async {
                  //   if (await _isDuplicateEntry(
                  //           serialnoControllers, text) &&
                  //       !isDuplicateAlertShown) {
                  //     _showDuplicateAlert(
                  //         context,
                  //         serialnoControllers[index],
                  //         serialnoFocusNodes[index]);
                  //     isDuplicateAlertShown =
                  //         true; // Set the flag to true after showing the alert
                  //   }
                  // },
                  // onSubmitted: (value) async {
                  //   if (serialnoControllers[index].text.isEmpty) {
                  //     _showWarning(context, serialnoControllers[index],
                  //         serialnoFocusNodes[index]);
                  //   } else if (await _isDuplicateEntry(
                  //           serialnoControllers, value) &&
                  //       !isDuplicateAlertShown) {
                  //     _showDuplicateAlert(
                  //         context,
                  //         "Duplicate Entry",
                  //         serialnoControllers[index],
                  //         serialnoFocusNodes[index]);
                  //     isDuplicateAlertShown =
                  //         true; // Prevent showing alert again
                  //   } else if (index < createtableData.length - 1) {
                  //     FocusScope.of(context).requestFocus(buttonFocus);
                  //   } else {
                  //     FocusScope.of(context).requestFocus(barcodeFocusNodes[0]);
                  //   }
                  // },

                  onSubmitted: (value) async {
                    if (_scanMode == 0) {
                      // Barcode mode auto add
                      if (serialnoControllers[index].text.isEmpty) {
                        _showWarning(context, serialnoControllers[index],
                            serialnoFocusNodes[index]);
                      } else if (await _isDuplicateEntry(
                              serialnoControllers, value) &&
                          !isDuplicateAlertShown) {
                        _showDuplicateAlert(
                            context,
                            "Duplicate Entry",
                            serialnoControllers[index],
                            serialnoFocusNodes[index]);
                        isDuplicateAlertShown = true;
                      } else {
                        // Auto Add
                        _handleAddSerial(index);
                      }
                    } else {
                      // Manual mode existing logic
                      if (serialnoControllers[index].text.isEmpty) {
                        _showWarning(context, serialnoControllers[index],
                            serialnoFocusNodes[index]);
                      } else if (await _isDuplicateEntry(
                              serialnoControllers, value) &&
                          !isDuplicateAlertShown) {
                        _showDuplicateAlert(
                            context,
                            "Duplicate Entry",
                            serialnoControllers[index],
                            serialnoFocusNodes[index]);
                        isDuplicateAlertShown = true;
                      } else if (index < createtableData.length - 1) {
                        FocusScope.of(context).requestFocus(buttonFocus);
                      } else {
                        FocusScope.of(context)
                            .requestFocus(barcodeFocusNodes[0]);
                      }
                    }
                  },

                  style: TextStyle(fontSize: 13),
                ),
              ),
            SizedBox(height: 10), // Add spacing between fields

            // Add button
            if (_scanMode == 1 || validProductCode == null)
              Container(
                decoration: BoxDecoration(color: buttonColor),
                height: 30,
                child: ElevatedButton(
                  onPressed:
                      _isButtonDisabled ? null : () => _handleAddSerial(index),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(45.0, 20.0),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 0, bottom: 0, left: 8, right: 8),
                    child: const Text(
                      'Add',
                      style: commonWhiteStyle,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

// Add this to your state class
  bool _isProcessing = false;

// Revised _handleAddSerial method
  Future<void> _handleAddSerial(int index) async {
    if (_isProcessing || !mounted || _blockSerialProcessing) return;

    final serialNo = serialnoControllers[index].text.trim();
    final currentBarcode = barcodeControllers[index].text.trim();
    final maxQuantity =
        int.tryParse((widget.nofoqty ?? '').split('.').first) ?? 0;

    setState(() {
      _isProcessing = true;
      _isButtonDisabled = true;
    });

    bool dialogShown = false;

    try {
      // Early validation checks
      if (tableData.length >= maxQuantity) {
        _handleMaxQuantityReached(index);
        return;
      }

      if (currentBarcode.isEmpty || serialNo.isEmpty) return;

      if (currentBarcode == serialNo) {
        _showWarningDialog(context, "Warning",
            "Product code and serial number cannot be the same.",
            clearSerialNo: true);
        _refocusAfterWarning(index);
        return;
      }

      // Duplicate check (redundant but safe)
      final lowerSerial = serialNo.toLowerCase();
      final isDuplicate = tableData.any((entry) =>
          (entry['Serial No']?.toString().trim().toLowerCase() ?? '') ==
          lowerSerial);

      if (isDuplicate) {
        if (!isDuplicateAlertShown) {
          _showDuplicateAlert(
            context,
            "Duplicate Entry",
            serialnoControllers[index],
            serialnoFocusNodes[index],
          );
          isDuplicateAlertShown = true;
        }
        return;
      }

      // Product code validation
      final isInvalidProductCode = (validProductCode?.isNotEmpty ?? false) &&
          currentBarcode != validProductCode &&
          !byepassCheckbox;

      if (isInvalidProductCode) {
        showwarningbarcode(
            context, barcodeControllers[index], barcodeFocusNodes[index]);
        return;
      }

      // Only show processing dialog after all validations pass
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _buildProcessingDialog(),
        );
        dialogShown = true;
      }

      // Main processing logic
      if (validSerialno == 'null') {
        await _handleNullSerialCase(
            index, maxQuantity, currentBarcode, serialNo);
      } else {
        await _addToTableOrBypass(index);
        unawaited(_saveTableData(
          widget.pickno,
          widget.reqno,
          widget.itemcode,
          widget.invoiceno,
        ));
      }

      // Post-processing UI updates
      if (tableData.length < maxQuantity) {
        _clearFields(index);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (_scanMode == 0) {
            FocusScope.of(context).requestFocus(barcodeFocusNodes[index]);
          } else {
            FocusScope.of(context).requestFocus(ProductcameraFocus);
            (validProductCode == '00')
                ? _openScannerSerial(index)
                : _openScannerProdCode(
                    barcodeControllers[index], barcodeFocusNodes[index], index);
          }
        });
      } else {
        _clearAndRefocus(index);
      }

      unawaited(postLogData("Pick Man Pop-Up", "Details Added"));
    } catch (e) {
      debugPrint("❌ Error in _handleAddSerial: $e");
      if (mounted) {
        _showWarningDialog(
            context, "Error", "An error occurred while processing.");
      }
    } finally {
      if (mounted) {
        if (dialogShown && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // Close processing dialog
        }
        setState(() {
          _isProcessing = false;
          _isButtonDisabled = false;
        });
      }
    }
  }

// Helper Methods
  Widget _buildProcessingDialog() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.green.shade700),
              ),
            ),
            SizedBox(height: 10),
            Text('Processing...', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _handleMaxQuantityReached(int index) {
    Navigator.of(context).pop();
    _showWarningDialog(
      context,
      "Scan limit reached",
      "You can't scan more items.",
    );
    _clearAndRefocus(index);
  }

  bool _isDuplicateInTable(String serialNo) {
    return tableData.any((entry) =>
        entry['Serial No']?.toString().trim().toLowerCase() ==
        serialNo.toLowerCase());
  }

  bool _isInvalidProductCode(String currentBarcode) {
    return (validProductCode?.isNotEmpty ?? false) &&
        currentBarcode != validProductCode &&
        !byepassCheckbox;
  }

  Future<void> _handleNullSerialCase(
      int index, int maxQuantity, String barcode, String serialNo) async {
    final int remainingQty = maxQuantity - tableData.length;
    for (int i = 0; i < remainingQty; i++) {
      tableData.add({
        "Product Code": barcode,
        "Serial No": serialNo,
      });
    }
    _clearAllFields();
    await _saveTableData(
      widget.pickno,
      widget.reqno,
      widget.itemcode,
      widget.invoiceno,
    );
    Navigator.of(context).pop();
    postLogData("Pick Man Pop-Up", "Multiple entries added");
    _refocusAfterNullSerial(index);
  }

  Future<void> _addToTableOrBypass(int index) async {
    if ((validProductCode ?? '').isEmpty) {
      await _addToTablebypass(index);
    } else {
      await _addToTable(index);
    }
  }

  Future<void> _prepareNextInput(int index, int maxQuantity) async {
    if (tableData.length < maxQuantity) {
      _clearFields(index);
      await Future.delayed(Duration(milliseconds: 10));
      if (mounted) {
        if (_scanMode == 0) {
          FocusScope.of(context).requestFocus(barcodeFocusNodes[index]);
        } else {
          FocusScope.of(context).requestFocus(ProductcameraFocus);
          (validProductCode == '00')
              ? _openScannerSerial(index)
              : _openScannerProdCode(
                  barcodeControllers[index],
                  barcodeFocusNodes[index],
                  index,
                );
        }
      }
    } else {
      _clearAndRefocus(index);
    }
  }

  void _clearAllFields() {
    serialnoControllers.forEach((c) => c.clear());
    barcodeControllers.forEach((c) => c.clear());
  }

  void _clearFields(int index) {
    barcodeControllers[index].clear();
    serialnoControllers[index].clear();
  }

  void _clearAndRefocus(int index) {
    _clearFields(index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        FocusScope.of(context).requestFocus(barcodeFocusNodes[index]);
    });
  }

  void _refocusAfterWarning(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scanMode != 0 && mounted) {
        _focusScanner(index);
      } else if (mounted) {
        FocusScope.of(context).requestFocus(serialnoFocusNodes[index]);
      }
    });
  }

  void _refocusSerialField(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        FocusScope.of(context).requestFocus(serialnoFocusNodes[index]);
    });
  }

  void _refocusAfterNullSerial(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scanMode != 0 && mounted) {
        _openScannerProdCode(
          barcodeControllers[index],
          barcodeFocusNodes[index],
          index,
        );
      }
    });
  }

  void _focusScanner(int index) {
    final isMobile = Platform.isAndroid || Platform.isIOS;
    if (isMobile) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (context.mounted) _openScannerSerial(index);
      });
    } else {
      FocusScope.of(context).requestFocus(serialnoFocusNodes[index]);
    }
  }

  // _handleAddSerial(int index) async {
  //   String quantity = widget.nofoqty ?? '';
  //   quantity = quantity.contains('.') ? quantity.split('.')[0] : quantity;
  //   int maxQuantity = int.tryParse(quantity) ?? 0;

  //   setState(() {
  //     _isButtonDisabled = true;
  //     _isProcessing = true;
  //   });

  //   // Show processing dialog
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => Center(
  //       child: Container(
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(16),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black26,
  //               blurRadius: 10,
  //               spreadRadius: 2,
  //             ),
  //           ],
  //         ),
  //         padding: EdgeInsets.all(20),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             SizedBox(
  //               width: 20,
  //               height: 20,
  //               child: CircularProgressIndicator(
  //                 strokeWidth: 2,
  //                 valueColor:
  //                     AlwaysStoppedAnimation<Color>(Colors.green.shade700),
  //               ),
  //             ),
  //             SizedBox(height: 5),
  //             Text(
  //               'Processing...',
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.w500,
  //                 color: Colors.grey.shade800,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );

  //   try {
  //     String serialNo = serialnoControllers[index].text.trim();
  //     String currentBarcode = barcodeControllers[index].text.trim();

  //     // Check for max quantity
  //     if (tableData.length >= maxQuantity) {
  //       Navigator.of(context).pop(); // Close loading
  //       _showWarningDialog(
  //           context, "Scan limit reached", "You can't scan more items.");
  //       return;
  //     }

  //     // If serial already exists in the table
  //     if (currentBarcode == serialNo) {
  //       Navigator.of(context).pop(); // Close loading
  //       await _showWarningDialog(
  //         context,
  //         "Warning",
  //         "The product code cannot be the same as the serial number.",
  //       );

  //       final isMobile = Platform.isAndroid || Platform.isIOS;
  //       if (context.mounted) {
  //         if (isMobile) {
  //           await Future.delayed(Duration(seconds: 1));
  //           if (context.mounted) {
  //             _openScannerSerial(index);
  //           }
  //         } else {
  //           FocusScope.of(context).requestFocus(serialnoFocusNodes[index]);
  //         }
  //       }
  //       return;
  //     }

  //     // ------------------ Handle when validSerialno == 'null' ------------------
  //     if (validSerialno == 'null') {
  //       int remainingQty = maxQuantity - tableData.length;
  //       // Barcode mismatch check
  //       if ((validProductCode ?? '').isNotEmpty &&
  //           currentBarcode != validProductCode &&
  //           !byepassCheckbox) {
  //         print("sales serialno is null ");
  //         Navigator.of(context).pop(); // Close loading
  //         showwarningbarcode(
  //           context,
  //           barcodeControllers[index],
  //           barcodeFocusNodes[index],
  //         );
  //         return;
  //       } else {
  //         print("sales serialno is null wrongggg ");

  //         for (int i = 0; i < remainingQty; i++) {
  //           tableData.add({
  //             "Product Code": currentBarcode,
  //             "Serial No": serialNo,
  //           });
  //         }

  //         // Clear all inputs
  //         for (var controller in serialnoControllers) {
  //           controller.clear();
  //         }
  //         for (var controller in barcodeControllers) {
  //           controller.clear();
  //         }

  //         await _saveTableData(
  //             widget.pickno, widget.reqno, widget.itemcode, widget.invoiceno);

  //         postLogData("Pick Man Pop-Up", "Multiple entries added");

  //         Navigator.of(context).pop(); // Close loading dialog

  //         setState(() {
  //           _isButtonDisabled = false;
  //           _isProcessing = false;
  //         });
  //         _openScannerProdCode(
  //           barcodeControllers[index],
  //           barcodeFocusNodes[index],
  //           index,
  //         );

  //         return;
  //       }
  //     }
  //     // ------------------------------------------------------------------------

  //     // If serial already exists in the table
  //     if (tableData.any((entry) => entry['Serial No'] == serialNo)) {
  //       Navigator.of(context).pop(); // Close loading
  //       await _showWarningDialog(
  //         context,
  //         "Entry already exists",
  //         "This serial number is already ordered.",
  //       );

  //       final isMobile = Platform.isAndroid || Platform.isIOS;
  //       if (context.mounted) {
  //         if (isMobile) {
  //           await Future.delayed(Duration(seconds: 1));
  //           if (context.mounted) {
  //             _openScannerSerial(index);
  //           }
  //         } else {
  //           FocusScope.of(context).requestFocus(serialnoFocusNodes[index]);
  //         }
  //       }
  //       return;
  //     }

  //     // Duplicate entry check across controllers
  //     if (!byepassCheckbox) {
  //       if (await _isDuplicateEntry(
  //         serialnoControllers,
  //         serialNo,
  //         productCode: currentBarcode,
  //       )) {
  //         Navigator.of(context).pop(); // Close loading
  //         _showDuplicateAlert(
  //           context,
  //           "Duplicate Entry",
  //           serialnoControllers[index],
  //           serialnoFocusNodes[index],
  //         );
  //         return;
  //       }
  //     }

  //     // Barcode mismatch check
  //     if ((validProductCode ?? '').isNotEmpty &&
  //         currentBarcode != validProductCode &&
  //         !byepassCheckbox) {
  //       Navigator.of(context).pop(); // Close loading
  //       showwarningbarcode(
  //         context,
  //         barcodeControllers[index],
  //         barcodeFocusNodes[index],
  //       );
  //       return;
  //     }

  //     // Add item based on barcode validation
  //     if ((validProductCode ?? '').isEmpty) {
  //       await _addToTablebypass(index);
  //     } else {
  //       await _addToTable(index);
  //     }

  //     await _saveTableData(
  //         widget.pickno, widget.reqno, widget.itemcode, widget.invoiceno);

  //     Navigator.of(context).pop(); // Close loading dialog

  //     // Prepare for next scan if still under limit
  //     if (tableData.length < maxQuantity) {
  //       barcodeControllers[index].clear();
  //       FocusScope.of(context).requestFocus(ProductcameraFocus);

  //       if (validProductCode == '00') {
  //         _openScannerSerial(index);
  //       } else {
  //         _openScannerProdCode(
  //           barcodeControllers[index],
  //           barcodeFocusNodes[index],
  //           index,
  //         );
  //       }
  //     }

  //     postLogData("Pick Man Pop-Up", "Details Added");
  //   } catch (e) {
  //     Navigator.of(context).pop(); // Close loading
  //     print("Error in _handleAddSerial: $e");
  //   } finally {
  //     setState(() {
  //       _isButtonDisabled = false;
  //       _isProcessing = false;
  //     });
  //   }
  // }

  Future<void> _saveTableData(
      String pickID, String reqID, String itemCode, String invoiceNo) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Encode each item in tableData to JSON string
      final List<String> tableDataStringList = tableData.map((data) {
        return json.encode(data);
      }).toList();

      // Generate a unique key using the provided parameters
      final String key = 'tableData_${pickID}_${reqID}_${itemCode}_$invoiceNo';

      // Save the JSON string list to SharedPreferences
      await prefs.setStringList(key, tableDataStringList);
    } catch (e) {
      debugPrint('Error saving table data: $e');
    }
  }

  Future<void> _loadTableData(
      String pickID, String reqID, String itemCode, String invoiceNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = 'tableData_${pickID}_${reqID}_${itemCode}_$invoiceNo';

    List<String>? tableDataStringList = prefs.getStringList(key);

    if (tableDataStringList != null && tableDataStringList.isNotEmpty) {
      try {
        setState(() {
          tableData = tableDataStringList.map((data) {
            return Map<String, String>.from(json.decode(data));
          }).toList();
        });
      } catch (e) {
        print('Error loading table data: $e');
        setState(() {
          tableData = [];
        });
      }
    } else {
      setState(() {
        tableData = [];
      });
    }
  }

  Future<void> _deleteTableData(
      String pickID, String reqID, String itemCode, String invoiceNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'tableData_${pickID}_${reqID}_${itemCode}_$invoiceNo';

    await prefs.remove(key);

    setState(() {
      tableData.removeWhere((data) =>
          data['pickID'] == pickID &&
          data['reqID'] == reqID &&
          data['itemCode'] == itemCode &&
          data['invoiceNo'] == invoiceNo);
    });
  }

// Warning dialog function
  Future<void> _showWarningDialog(
    BuildContext context,
    String title,
    String message, {
    bool clearSerialNo = false,
    bool clearProductCode = false,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 13)),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (clearProductCode) {
                    for (var controller in barcodeControllers) {
                      controller.clear();
                    }
                  }
                  if (clearSerialNo) {
                    for (var controller in serialnoControllers) {
                      controller.clear();
                    }
                  }
                },
                child: Text("OK"),
              ),
            ],
          );
        });
      },
    );
  }

  showwarningbarcode(BuildContext context, TextEditingController controller,
      FocusNode focusnode) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invalid Barcode'),
        content: Container(
          height: MediaQuery.of(context).size.width * 0.3,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    'The entered productode is not valid for this item code. Kindly check and try again.'),
                Text(
                  'Note : Product Code is $validProductCode',
                  style:
                      TextStyle(color: const Color.fromARGB(255, 0, 118, 37)),
                ),
                Text(
                  'Note : For any changes contact to admin',
                  style:
                      TextStyle(color: const Color.fromARGB(255, 143, 12, 2)),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clear();
              Navigator.of(context).pop();
              FocusScope.of(context).requestFocus(focusnode);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell({required String data}) {
    return Flexible(
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color.fromARGB(255, 226, 225, 225)),
        ),
        child: Center(
          child: Text(data,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Timer? _debounce;

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required Function(String) onFieldSubmitted,
    required TextInputAction textInputAction,
    required IconData icon1,
    required Color iconColor1,
    required IconData icon2,
    required Color iconColor2,
    required VoidCallback onIconPressed,
    required int index, // Add index to identify which controller to validate
  }) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color.fromARGB(255, 173, 173, 173)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.width * 0.012),
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(255, 58, 58, 58),
                width: 1.0,
              ),
            ),
            suffixIcon: controller.text.isEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          icon1,
                          color: iconColor1,
                          size: 15,
                        ),
                        onPressed: onIconPressed,
                      ),
                      IconButton(
                        icon: Icon(icon2, color: iconColor2, size: 15),
                        onPressed: onIconPressed,
                      ),
                    ],
                  )
                : null,
          ),
          // onChanged: (text) {
          //   // Cancel any previous debounce timer
          //   if (_debounce?.isActive ?? false) _debounce?.cancel();

          //   // Start a new debounce timer
          //   _debounce = Timer(const Duration(seconds: 2), () async {
          //     // Now that typing has finished (after 300ms), check for duplicates
          //     if (controller == serialnoControllers[index]) {
          //       if (await _isDuplicateEntry(serialnoControllers, text)) {
          //         _showDuplicateAlert(context, controller, focusNode);
          //       }
          //     }
          //     if (controller == barcodeControllers[index]) {
          //       if (validProductCode != null) {
          //         if (barcodeControllers[index].text.isNotEmpty &&
          //             barcodeControllers[index].text == validProductCode) {
          //           if (index < createtableData.length) {
          //             FocusScope.of(context)
          //                 .requestFocus(serialnoFocusNodes[index]);
          //           }
          //         } else {
          //           showwarningbarcode(context, barcodeControllers[index],
          //               barcodeFocusNodes[index]);
          //         }
          //       }
          //     }
          //   });
          // },
          onChanged: (text) {
            // Cancel any previous debounce timer
            if (_debounce?.isActive ?? false) _debounce?.cancel();

            // Start a new debounce timer
            _debounce = Timer(const Duration(seconds: 2), () async {
              // Now that typing has finished (after 2 seconds), check for barcode mismatch
              if (controller == serialnoControllers[index]) {
                // Check for duplicate serial number
                if (await _isDuplicateEntry(serialnoControllers, text)) {
                  _showDuplicateAlert(
                      context, "Duplicate Entry", controller, focusNode);
                }
              } else if (controller == barcodeControllers[index]) {
                // Check if the typed barcode is not equal to validProductCode
                if (text != validProductCode) {
                  print("savebutonnnnn8");
                  if (byepassCheckbox = true)
                    showwarningbarcode(
                      context,
                      barcodeControllers[index],
                      barcodeFocusNodes[index],
                    );
                }
              }
            });
          },
          style: const TextStyle(
              fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool _flashOn = false;

  // Current active index for the scanned barcode field
  int _currentSerialFieldIndex = 0;

  // Callback for when QR code or barcode is scanned
  // void _onQRViewCreatedSerial(QRViewController controller) {
  //   _qrController = controller;

  //   // Boolean flag to prevent multiple dialogs
  //   bool isDialogShowing = false;

  //   // Start listening to the scanned data stream
  //   _qrController!.scannedDataStream.listen((scanData) async {
  //     // Ensure scanData and scanData.code are not null
  //     if (scanData != null &&
  //         scanData.code != null &&
  //         scanData.code!.isNotEmpty) {
  //       String scannedValue = scanData.code!;

  //       // Pause scanning to prevent repeated events
  //       _qrController?.pauseCamera();

  //       // Check if the scanned value is a duplicate
  //       bool isDuplicate = false;

  //       for (int i = 0; i < serialnoControllers.length; i++) {
  //         if (serialnoControllers[i].text == scannedValue) {
  //           isDuplicate = true;

  //           // Show duplicate dialog if no other dialog is showing
  //           if (!isDialogShowing) {
  //             isDialogShowing = true;

  //             // Show duplicate dialog
  //             _showDuplicateAlert(
  //               context,
  //               serialnoControllers[_currentSerialFieldIndex],
  //               serialnoFocusNodes[_currentSerialFieldIndex],
  //             );

  //             // Automatically close the dialog after 4 seconds
  //             Future.delayed(Duration(seconds: 2), () {
  //               if (Navigator.canPop(context)) {
  //                 Navigator.of(context).pop();
  //               }

  //               // Clear the current text box after dialog dismissal
  //               setState(() {
  //                 serialnoControllers[_currentSerialFieldIndex].text = '';
  //               });

  //               // Resume the camera for scanning
  //               _qrController?.resumeCamera();
  //               isDialogShowing = false; // Reset dialog flag
  //             });
  //           }
  //           return; // Exit early to prevent further processing
  //         }
  //       }

  //       // If it's not a duplicate, update the current text field
  //       if (!isDuplicate) {
  //         setState(() {
  //           serialnoControllers[_currentSerialFieldIndex].text = scannedValue;

  //           // Move to the next text field after filling the current one
  //           if (_currentSerialFieldIndex < serialnoControllers.length - 1) {
  //             _currentSerialFieldIndex++;
  //             // Move focus to the next text field
  //             FocusScope.of(context)
  //                 .requestFocus(barcodeFocusNodes[_currentSerialFieldIndex]);
  //           } else {
  //             // Remove focus if it's the last field
  //             FocusScope.of(context).unfocus();
  //           }

  //           // Optionally, close the QR scanner after the scan is successful
  //           Navigator.of(context).pop();
  //         });
  //       }

  //       // Resume scanning if no dialog was shown
  //       if (!isDialogShowing) {
  //         _qrController?.resumeCamera();
  //       }
  //     }
  //   });
  // }

  // int _currentFieldIndex = 0;

  // // Callback for when QR code or barcode is scanned
  // void _onQRViewCreatedProdCode(QRViewController controller) {
  //   _qrController1 = controller;

  //   // Start listening to the scanned data stream
  //   _qrController1!.scannedDataStream.listen((scanData) {
  //     // Ensure scanData and scanData.code are not null
  //     if (scanData != null &&
  //         scanData.code != null &&
  //         scanData.code!.isNotEmpty) {
  //       setState(() {
  //         // Update the text field with the scanned code
  //         barcodeControllers[_currentFieldIndex].text = scanData.code!;

  //         // Move to the next text field after filling the current one
  //         if (_currentFieldIndex < barcodeControllers.length - 1) {
  //           _currentFieldIndex++;
  //           // Move focus to the next text field
  //           FocusScope.of(context)
  //               .requestFocus(serialnoFocusNodes[_currentSerialFieldIndex]);
  //         } else {
  //           // Explicitly focus the last text field
  //           FocusScope.of(context)
  //               .requestFocus(serialnoFocusNodes[_currentSerialFieldIndex]);
  //         }

  //         // Pause the camera to prevent further scanning
  //         _qrController1?.pauseCamera();
  //         // Optionally, close the QR scanner after the scan is successful
  //         Navigator.of(context).pop();
  //       });
  //     }
  //   });
  // }

  // // Method to open the QR scanner
  // void _openScannerSerial(int fieldIndex) {
  //   setState(() {
  //     _currentSerialFieldIndex = fieldIndex;
  //   });

  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       child: AspectRatio(
  //         aspectRatio: 1,
  //         child: QRView(
  //           key: qrKey,
  //           onQRViewCreated: _onQRViewCreatedSerial,
  //           overlay: QrScannerOverlayShape(
  //             borderColor: Colors.green,
  //             borderRadius: 10,
  //             borderLength: 30,
  //             borderWidth: 10,
  //             cutOutSize: MediaQuery.of(context).size.width * 0.8,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  int _currentFieldIndex = 0;
  // void _openScannerProdCode(TextEditingController controller, int fieldIndex) {
  //   // Set the current field index for scanning
  //   setState(() {
  //     _currentFieldIndex = fieldIndex;
  //   });

  //   // Flag to prevent multiple scans
  //   bool isScanned = false;

  //   // Create a MobileScannerController instance
  //   final MobileScannerController scannerController = MobileScannerController();

  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       child: Stack(
  //         children: [
  //           AspectRatio(
  //             aspectRatio: 1,
  //             child: MobileScanner(
  //               controller: scannerController,
  //               onDetect: (BarcodeCapture capture) {
  //                 if (isScanned) return; // Prevent multiple detections
  //                 isScanned = true;

  //                 final String? scannedCode = capture.barcodes.first.rawValue;

  //                 if (scannedCode != null && scannedCode.isNotEmpty) {
  //                   // Check if the scanned product code matches the valid product code
  //                   if (scannedCode != validProductCode) {
  //                     // If the product codes don't match, show the mismatch alert
  //                     showwarningbarcode(
  //                       context,
  //                       controller,
  //                     );
  //                     // Navigator.of(context).pop();
  //                   } else {
  //                     // Update the text field with the scanned value
  //                     barcodeControllers[fieldIndex].text = scannedCode;

  //                     // Close the scanner dialog
  //                     Navigator.of(context).pop();
  //                   }
  //                 }
  //               },
  //               fit: BoxFit.cover,
  //             ),
  //           ),
  //           Positioned.fill(
  //             child: CustomPaint(
  //               painter: ScannerOverlayPainter(
  //                 borderColor: Colors.green,
  //                 borderRadius: 10,
  //                 borderWidth: 5,
  //                 borderLength: 30,
  //                 cutOutSize: MediaQuery.of(context).size.width * 0.8,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   ).then((_) {
  //     // Dispose of the scanner controller after the dialog is closed
  //     scannerController.dispose();

  //     // Reset the scanned flag for future use
  //     isScanned = false;

  //     // Move focus to the corresponding Serial No text field
  //     FocusScope.of(context)
  //         .requestFocus(serialnoFocusNodes[_currentFieldIndex]);

  //     // Move to the next text field if there are more fields
  //     setState(() {
  //       if (_currentFieldIndex < barcodeControllers.length - 1) {
  //         _currentFieldIndex++;
  //       }
  //     });
  //   });
  // }

  void _openScannerProdCode(
      TextEditingController controller, FocusNode focusNode, int fieldIndex) {
    // Set the current field index for scanning
    setState(() {
      _currentFieldIndex = fieldIndex;
    });

    // Flag to prevent multiple scans
    bool isScanned = false;

    // Create a MobileScannerController instance
    final MobileScannerController scannerController = MobileScannerController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with label and close button
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scan Product Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              // Instruction text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Align the barcode within the frame to scan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              // Scanner preview with overlay
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: MobileScanner(
                        controller: scannerController,
                        onDetect: (BarcodeCapture capture) {
                          if (isScanned) return; // Prevent multiple detections
                          isScanned = true;

                          final String? scannedCode =
                              capture.barcodes.first.rawValue;

                          if (scannedCode != null && scannedCode.isNotEmpty) {
                            // Check if the scanned product code matches the valid product code
                            if (scannedCode != validProductCode) {
                              Navigator.of(context).pop();
                              showwarningbarcode(
                                context,
                                barcodeControllers[fieldIndex],
                                barcodeFocusNodes[fieldIndex],
                              );
                            } else {
                              // Update the text field with the scanned value
                              barcodeControllers[fieldIndex].text = scannedCode;

                              // Show a small SnackBar message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Product Code Scanned!',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );

                              // Close the scanner dialog
                              Navigator.of(context).pop();

                              // Delay to allow the SnackBar to show before opening the serial scanner
                              Future.delayed(Duration(seconds: 1), () {
                                // Automatically open the serial number scanner

                                if (validSerialno == 'null') {
                                  _handleAddSerial(fieldIndex);
                                  // _openScannerProdCode(
                                  //   barcodeControllers[fieldIndex],
                                  //   barcodeFocusNodes[fieldIndex],
                                  //   fieldIndex,
                                  // );
                                } else {
                                  _openScannerSerial(fieldIndex);
                                }
                              });
                            }
                          }
                        },
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: ScannerOverlayPainter(
                          borderColor: Colors.green,
                          borderRadius: 10,
                          borderWidth: 5,
                          borderLength: 30,
                          cutOutSize: MediaQuery.of(context).size.width * 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Manual entry option
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  focusNode.requestFocus();
                },
                child: Text(
                  'Enter Code Manually',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ).then((_) {
      // Dispose of the scanner controller after the dialog is closed
      scannerController.dispose();

      // Reset the scanned flag for future use
      isScanned = false;

      // Move focus to the corresponding Serial No text field
      FocusScope.of(context).requestFocus(SerialcameraFocus);

      // Move to the next text field if there are more fields
      setState(() {
        if (_currentFieldIndex < barcodeControllers.length - 1) {
          _currentFieldIndex++;
        }
      });
    });
  }

  bool _isScanning = true; // Boolean flag to control scanner state

  void _openScannerSerial(int fieldIndex) {
    setState(() {
      _currentFieldIndex = fieldIndex;
      _isScanning = true;
    });

    bool isScanned = false;
    bool isDialogShowing = false;

    final MobileScannerController _scannerController =
        MobileScannerController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with title and close button
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Scan Serial Number',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            _scannerController.stop();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  // Instruction text
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Align the serial number barcode within the frame',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Scanner container
                  if (_isScanning)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: MobileScanner(
                          controller: _scannerController,
                          onDetect: (BarcodeCapture capture) async {
                            if (isScanned) return;
                            isScanned = true;

                            final String? scannedCode =
                                capture.barcodes.first.rawValue;

                            if (scannedCode != null && scannedCode.isNotEmpty) {
                              setState(() {
                                serialnoControllers[fieldIndex].text =
                                    scannedCode;
                              });

                              String scannedValue =
                                  serialnoControllers[fieldIndex].text;
                              bool isDuplicate = false;

                              // Check for duplicates
                              for (int i = 0;
                                  i < serialnoControllers.length;
                                  i++) {
                                if (serialnoControllers[i].text ==
                                        scannedValue &&
                                    i != fieldIndex) {
                                  isDuplicate = true;

                                  if (!isDialogShowing) {
                                    isDialogShowing = true;

                                    _showDuplicateAlert(
                                      context,
                                      "Duplicate Entry",
                                      serialnoControllers[_currentFieldIndex],
                                      serialnoFocusNodes[_currentFieldIndex],
                                    );

                                    Future.delayed(Duration(seconds: 2), () {
                                      if (Navigator.canPop(dialogContext)) {
                                        Navigator.of(dialogContext).pop();
                                      }

                                      setState(() {
                                        serialnoControllers[_currentFieldIndex]
                                            .text = '';
                                      });

                                      _scannerController.stop();
                                      isDialogShowing = false;
                                    });
                                  }
                                  return;
                                }
                              }

                              if (!isDuplicate) {
                                // Show success feedback
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Serial Number Scanned!'),
                                    duration: Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );

                                setState(() {
                                  if (_currentFieldIndex <
                                      serialnoControllers.length - 1) {
                                    _currentFieldIndex++;
                                    FocusScope.of(context).requestFocus(
                                        barcodeFocusNodes[_currentFieldIndex]);
                                  } else {
                                    FocusScope.of(context).unfocus();
                                  }
                                });

                                Navigator.of(dialogContext).pop();
                                _scannerController.stop();
                                _isScanning = false;

                                // ✅ Automatically add after successful scan
                                await _handleAddSerial(fieldIndex);
                              }
                            }
                          },
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  // Manual entry option
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _scannerController.stop();
                      serialnoFocusNodes[fieldIndex].requestFocus();
                    },
                    child: Text(
                      'Enter Serial Number Manually',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
              // Scanner overlay
              if (_isScanning)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: CustomPaint(
                        painter: ScannerOverlayPainter(
                          borderColor: Colors.green,
                          borderRadius: 10,
                          borderWidth: 5,
                          borderLength: 30,
                          cutOutSize: MediaQuery.of(context).size.width * 0.6,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).then((_) {
      _scannerController.dispose();
      isScanned = false;

      if (_currentFieldIndex < serialnoControllers.length - 1) {
        FocusScope.of(context)
            .requestFocus(barcodeFocusNodes[_currentFieldIndex]);
      }
    }).whenComplete(() {
      _scannerController.stop();
    });
  }

  List<Map<String, dynamic>> alreadyscantableData = [];
  bool isLoading = true;
  Future<void> fetchPickmanData() async {
    String reqno = widget.reqno.toString();
    String pickno = widget.pickno.isNotEmpty ? widget.pickno : '';
    String invoiceno = widget.invoiceno.isNotEmpty ? widget.invoiceno : '';
    String itemCode = widget.itemcode.isNotEmpty ? widget.itemcode : '';

    final IpAddress = await getActiveIpAddress();

    final url = Uri.parse(
        '$IpAddress/Scanned_Pickman/?PICK_ID=$pickno&REQ_ID=$reqno&INVOICE_NUMBER=$invoiceno&INVENTORY_ITEM_ID=$itemCode');
    // print("Fetching data from: $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decode the JSON array
        final List<dynamic> jsonData = json.decode(response.body);

        // Convert the JSON array to a list of maps
        final List<Map<String, dynamic>> fetchedData =
            List<Map<String, dynamic>>.from(jsonData);

        // Filter out rows where FLAG == 'R'
        final List<Map<String, dynamic>> filteredData = fetchedData
            .where((row) => row['FLAG'] != 'R' && row['FLAG'] != 'SR')
            .toList();

        setState(() {
          alreadyscantableData = filteredData; // Only rows where FLAG != 'R'
          isLoading = false;
        });

        // print("Filtered data: $alreadyscantableData");
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _AlreadyviewbuildTable() {
    return Responsive.isMobile(context)
        ? _buildCardView() // Card view for mobile devices
        : _buildTableView(); // Table view for web/desktop
  }

  Widget _buildCardView() {
    return Scrollbar(
      thumbVisibility: true,
      controller: _horizontalScrollController,
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: Column(
          children: alreadyscantableData.map((data) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                    16), // Increased padding for spaciousness
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Invoice No: ${data['INVOICE_NUMBER']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.blueAccent, // Color for emphasis
                      ),
                    ),
                    SizedBox(height: 8), // Space between items
                    Text(
                      "Item Code: ${data['INVENTORY_ITEM_ID']}",
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Item Details: ${data['ITEM_DESCRIPTION']}",
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Product Code: ${data['PRODUCT_CODE']}",
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Serial No: ${data['SERIAL_NO']}",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTableView() {
    return Scrollbar(
      thumbVisibility: true,
      controller: _horizontalScrollController,
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: Container(
          width: Responsive.isDesktop(context)
              ? MediaQuery.of(context).size.width * 0.55
              : MediaQuery.of(context).size.width * 1.9,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _alreadybuildTableHeaderCell("No"),
                    _alreadybuildTableHeaderCell("Invoice No"),
                    _alreadybuildTableHeaderCell("Item Code"),
                    _alreadybuildTableHeaderCell("Item Details"),
                    _alreadybuildTableHeaderCell("Product Code"),
                    _alreadybuildTableHeaderCell("Serial No"),
                  ],
                ),
              ),
              ...alreadyscantableData.asMap().entries.map((entry) {
                int index = entry.key;
                return _alreadybuildDataRow(index);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _alreadybuildTableHeaderCell(String label) {
    return Flexible(
      child: Container(
        height: 30,
        color: Colors.grey.shade300,
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _alreadybuildDataRow(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTableCell(data: alreadyscantableData[index]['id'].toString()),
          _buildTableCell(
              data: alreadyscantableData[index]['INVOICE_NUMBER'].toString()),
          _buildTableCell(
              data:
                  alreadyscantableData[index]['INVENTORY_ITEM_ID'].toString()),
          _buildTableCell(
              data: alreadyscantableData[index]['ITEM_DESCRIPTION'].toString()),
          _buildTableCell(
              data: alreadyscantableData[index]['PRODUCT_CODE'].toString()),
          _buildTableCell(
              data: alreadyscantableData[index]['SERIAL_NO'].toString()),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderRadius;
  final double borderWidth;
  final double borderLength;
  final double cutOutSize;

  ScannerOverlayPainter({
    required this.borderColor,
    required this.borderRadius,
    required this.borderWidth,
    required this.borderLength,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    // Draw rounded rectangle
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    canvas.drawRRect(rrect, paint);

    // Draw border length (optional)
    final halfBorderLength = borderLength / 2;
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + halfBorderLength, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right - halfBorderLength, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + halfBorderLength, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right - halfBorderLength, rect.bottom),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
