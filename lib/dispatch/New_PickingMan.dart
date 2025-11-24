import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
                                      final isDesktop =
                                          Responsive.isDesktop(context);
                                      final screenWidth =
                                          MediaQuery.of(context).size.width;

                                      await showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return Container(
                                            child: Dialog(
                                              child: Container(
                                                height: screenHeight * 0.7,
                                                width: screenWidth * 0.75,
                                                color: Colors.transparent,
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
                                                  invoiceno: invoiceno,
                                                  customer_trx_line_id:
                                                      customer_trx_line_id,
                                                  customer_trx_id:
                                                      customer_trx_id,
                                                  undel_id: undel_id,
                                                  line_id: line_id,
                                                  itemcode: itemcode,
                                                  itemdetails: itemdetails,
                                                  scannedqty: BalScanned_Qty,
                                                  nofoqty: BalScanned_Qty,
                                                  alreadyscannedqty:
                                                      Scanned_qty,
                                                  invoiceQty: invoiceQty,
                                                  dispatch_qty: scannedqty,
                                                  amount: amount,
                                                  item_cost: item_cost,
                                                  balance_qty: balance_qty,
                                                  Row_id: Updated_id,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );

                                      setState(() {
                                        tableData = [];
                                      });
                                      await fetchDataPicknO();
                                      await fetchDataPicknO();
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

                                                                  String putdataid = _IdController
                                                                          .text
                                                                          .isNotEmpty
                                                                      ? _IdController
                                                                          .text
                                                                      : '';
                                                                  final isDesktop =
                                                                      Responsive
                                                                          .isDesktop(
                                                                              context);
                                                                  final screenWidth =
                                                                      MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width;

                                                                  await showDialog(
                                                                    context:
                                                                        context,
                                                                    barrierDismissible:
                                                                        false,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return Container(
                                                                        child:
                                                                            Dialog(
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                screenHeight * 0.7,
                                                                            width:
                                                                                screenWidth * 0.26,
                                                                            color:
                                                                                Colors.transparent,
                                                                            child:
                                                                                CustomerDetailsDialog(
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
                                                                              invoiceno: invoiceno,
                                                                              customer_trx_line_id: customer_trx_line_id,
                                                                              customer_trx_id: customer_trx_id,
                                                                              undel_id: undel_id,
                                                                              line_id: line_id,
                                                                              itemcode: itemcode,
                                                                              itemdetails: itemdetails,
                                                                              scannedqty: BalScanned_Qty,
                                                                              nofoqty: BalScanned_Qty,
                                                                              alreadyscannedqty: Scanned_qty,
                                                                              invoiceQty: invoiceQty,
                                                                              dispatch_qty: scannedqty,
                                                                              amount: amount,
                                                                              item_cost: item_cost,
                                                                              balance_qty: balance_qty,
                                                                              Row_id: Updated_id,
                                                                            ),
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
    print("urls $IpAddress/Filtered_Pickscan/$reqno/$pickno");

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

        print('Table Dataaaaaaaaaaaaaaa: $tableData');
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
  TextEditingController barcodeControllers = TextEditingController();
  List<TextEditingController> serialnoControllers = [];
  FocusNode barcodeFocusNodes = FocusNode();
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

    idcontroller.text = widget.Row_id;
    _alreadyScaneedqty.text = widget.alreadyscannedqty;
    print("Already Scanned Qty: ${_alreadyScaneedqty.text}");
    validProductCode == null;

    _cachedMaxQuantity =
        int.tryParse((widget.nofoqty ?? '').split('.').first) ?? 0;
  }

  String? validSerialno;
  String message = "";

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

  bool isPosting = false;

  // Future<void> postPickmanScan(int balanceqty) async {
  //   if (isPosting) {
  //     print('Already posting. Please wait.');
  //     return;
  //   }
  //   isPosting = true;
  //   final IpAddress = await getActiveIpAddress();

  //   final url = '$IpAddress/Pickman_scan/';
  //   await fetchRegionAndWarehouse();

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String salesloginno = prefs.getString('salesloginno') ?? '';
  //   String saveloginname = prefs.getString('saveloginname') ?? '';
  //   String saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '';

  //   try {
  //     DateTime now = DateTime.now();
  //     String date = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

  //     String reqno = widget.reqno ?? '';
  //     String pickno = widget.pickno.isNotEmpty ? widget.pickno : '';
  //     String assignpickman =
  //         widget.assignpickname.isNotEmpty ? widget.assignpickname : '';
  //     String warehouse =
  //         warehouseController.text.isNotEmpty ? warehouseController.text : '';
  //     String orgName =
  //         regionController.text.isNotEmpty ? regionController.text : '';

  //     int rowIndex = 0; // Index to iterate createtableData

  //     postLogData("Pick Man Scan Pop-up",
  //         "Saved PickedQty ${barcodeControllers.text} for Pickid $pickno");
  //     await updateDispatchQty(idcontroller.text, balanceqty);
  //     for (int postCount = 0; postCount < balanceqty; postCount++) {
  //       if (rowIndex >= createtableData.length) {
  //         print('⚠️ Not enough rows in createtableData to match balanceqty.');
  //         break;
  //       }

  //       var row = createtableData[rowIndex];

  //       int customerTrxId =
  //           int.tryParse(row['customer_trx_id']?.toString() ?? '0') ?? 0;
  //       int customerTrxLineId =
  //           int.tryParse(row['customer_trx_line_id']?.toString() ?? '0') ?? 0;
  //       int dispatchedQty =
  //           int.tryParse(row['dispatch_qty']?.toString() ?? '0') ?? 0;
  //       int totQty = int.tryParse(row['invoiceQty']?.toString() ?? '0') ?? 0;
  //       int lineNumber = int.tryParse(row['line_id']?.toString() ?? '0') ?? 0;

  //       String inventoryItemId = row['itemcode']?.toString() ?? '';
  //       String itemDescription = row['itemdetails']?.toString() ?? '';

  //       Map<String, dynamic> createDispatchData = {
  //         "PICK_ID": pickno,
  //         "REQ_ID": reqno,
  //         "DATE": date,
  //         "ASSIGN_PICKMAN": assignpickman,
  //         "PHYSICAL_WAREHOUSE": warehouse,
  //         "ORG_ID": int.tryParse(saleslogiOrgid) ?? 0,
  //         "ORG_NAME": orgName,
  //         "SALESMAN_NO": int.tryParse(widget.salesman_No ?? '0') ?? 0,
  //         "SALESMAN_NAME": widget.salesman_Name,
  //         "MANAGER_NO": int.tryParse(widget.Manager_No ?? '0') ?? 0,
  //         "MANAGER_NAME": widget.Manager_Name,
  //         "PICKMAN_NO": int.tryParse(salesloginno) ?? 0,
  //         "PICKMAN_NAME": saveloginname,
  //         "CUSTOMER_NUMBER": int.tryParse(widget.cusno ?? '0') ?? 0,
  //         "CUSTOMER_NAME": widget.cusname,
  //         "CUSTOMER_SITE_ID": int.tryParse(widget.cussite ?? '0') ?? 0,
  //         "INVOICE_DATE": date,
  //         "INVOICE_NUMBER": invoiceNoController.text.isNotEmpty
  //             ? invoiceNoController.text
  //             : 'Unknown',
  //         "LINE_NUMBER": lineNumber,
  //         "INVENTORY_ITEM_ID": inventoryItemId,
  //         "ITEM_DESCRIPTION": itemDescription,
  //         "CUSTOMER_TRX_ID": customerTrxId,
  //         "CUSTOMER_TRX_LINE_ID": customerTrxLineId,
  //         "TOT_QUANTITY": totQty,
  //         "DISPATCHED_QTY": dispatchedQty,
  //         "BALANCE_QTY": dispatchedQty - 1,
  //         "PICKED_QTY": 1,
  //         "PRODUCT_CODE": 'empty',
  //         "SERIAL_NO": 'empty',
  //         "CREATION_DATE": date,
  //         "CREATED_BY": saveloginname,
  //         "CREATED_IP": "null",
  //         "CREATED_MAC": "null",
  //         "LAST_UPDATE_DATE": date,
  //         "LAST_UPDATED_BY": "null",
  //         "LAST_UPDATE_IP": "null",
  //         "FLAG": 'A',
  //         "UNDEL_ID": widget.undel_id,
  //       };

  //       print(
  //           "📤 Sending Pickman Scan Data (Post ${postCount + 1}/$balanceqty): $createDispatchData");

  //       final response = await http.post(
  //         Uri.parse(url),
  //         headers: {'Content-Type': 'application/json'},
  //         body: jsonEncode(createDispatchData),
  //       );

  //       if (response.statusCode == 201) {
  //         print('✅ Dispatch created successfully for row index: $rowIndex');
  //       } else {
  //         print('❌ Failed to create dispatch for row index: $rowIndex');
  //         print('Status Code: ${response.statusCode}');
  //         print('Response Body: ${response.body}');
  //       }

  //       rowIndex++; // Move to the next row
  //     }
  //   } catch (e) {
  //     print('❌ Exception while posting dispatch: $e');
  //   } finally {
  //     isPosting = false;
  //   }
  // }

  Future<void> postPickmanScan(int balanceqty) async {
    if (isPosting) {
      print('Already posting. Please wait.');
      return;
    }

    isPosting = true;

    final IpAddress = await getActiveIpAddress();
    final url = '$IpAddress/Newinsert-picked-man_assign_data/';

    await fetchRegionAndWarehouse();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String salesloginno = prefs.getString('salesloginno') ?? '0';
    String saveloginname = prefs.getString('saveloginname') ?? '';
    String saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '0';

    try {
      DateTime now = DateTime.now();
      String date = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

      String reqno = widget.reqno ?? '';
      String pickno = widget.pickno ?? '';
      String assignpickman = widget.assignpickname ?? '';
      String warehouse = warehouseController.text;
      String orgName = regionController.text;

      // await updateDispatchQty(idcontroller.text, balanceqty);

      // 🔥 take first row (or selected row) instead of looping
      var row = createtableData.isNotEmpty ? createtableData[0] : {};

      int dispatchQty =
          int.tryParse(row['dispatch_qty']?.toString() ?? '0') ?? 0;
      int balanceQty = dispatchQty - balanceqty;
      if (balanceQty < 0) balanceQty = 0;

      Map<String, dynamic> createDispatchData = {
        "PICK_ID": pickno,
        "REQ_ID": reqno,
        "DATE": date,
        "ASSIGN_PICKMAN": assignpickman,
        "PHYSICAL_WAREHOUSE": warehouse,
        "ORG_ID": int.tryParse(saleslogiOrgid) ?? 0,
        "ORG_NAME": orgName,
        "SALESMAN_NO": int.tryParse(widget.salesman_No ?? '0') ?? 0,
        "SALESMAN_NAME": widget.salesman_Name ?? '',
        "MANAGER_NO": int.tryParse(widget.Manager_No ?? '0') ?? 0,
        "MANAGER_NAME": widget.Manager_Name ?? '',
        "PICKMAN_NO": int.tryParse(salesloginno) ?? 0,
        "PICKMAN_NAME": saveloginname,
        "CUSTOMER_NUMBER": int.tryParse(widget.cusno ?? '0') ?? 0,
        "CUSTOMER_NAME": widget.cusname ?? '',
        "CUSTOMER_SITE_ID": int.tryParse(widget.cussite ?? '0') ?? 0,
        "INVOICE_DATE": date,
        "INVOICE_NUMBER": invoiceNoController.text.isNotEmpty
            ? invoiceNoController.text
            : 'Unknown',
        "LINE_NUMBER": int.tryParse(row['line_id']?.toString() ?? '0') ?? 0,
        "CUSTOMER_TRX_ID":
            int.tryParse(row['customer_trx_id']?.toString() ?? '0') ?? 0,
        "CUSTOMER_TRX_LINE_ID":
            int.tryParse(row['customer_trx_line_id']?.toString() ?? '0') ?? 0,
        "INVENTORY_ITEM_ID": row['itemcode']?.toString() ?? '',
        "ITEM_DESCRIPTION": row['itemdetails']?.toString() ?? '',
        "TOT_QUANTITY": int.tryParse(row['invoiceQty']?.toString() ?? '0') ?? 0,
        "DISPATCHED_QTY": dispatchQty,
        "BALANCE_QTY": balanceQty,
        "PICKED_QTY": 1, // backend multiplies by row_count
        "PRODUCT_CODE": 'empty',
        "SERIAL_NO": 'empty',
        "CREATION_DATE": date,
        "CREATED_BY": saveloginname,
        "CREATED_IP": '',
        "CREATED_MAC": '',
        "LAST_UPDATE_DATE": date,
        "LAST_UPDATED_BY": '',
        "LAST_UPDATE_IP": '',
        "FLAG": 'A',
        "UNDEL_ID": widget.undel_id ?? '',
      };

      // 🔥 send only one row + row_count = balanceqty
      final payload = {
        "rows": [createDispatchData],
        "row_count": balanceqty,
      };

      print("🚀 Posting Payload:");
      print(jsonEncode(payload));

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        print('✅ Pickman scan posted successfully!');
        postLogData("Pick Man Scan Saved",
            "Pickman $salesloginno Saved the Quantity $balanceqty");
      } else {
        print('❌ Failed to post dispatch rows');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        postLogData("Pick Man Scan Saved",
            "Pickman $salesloginno Failed to save the Quantity $balanceqty Reason : ${response.statusCode}");
      }
    } catch (e) {
      print('❌ Exception while posting dispatch: $e');
      postLogData("Pick Man Scan Saved",
          "Pickman $salesloginno Failed to save the Quantity $balanceqty Reason : ${e}");
    } finally {
      isPosting = false;
    }
  }

  // Future<void> postPickmanScan(int balanceqty) async {
  //   if (isPosting) {
  //     print('Already posting. Please wait.');
  //     return;
  //   }

  //   isPosting = true;

  //   final IpAddress = await getActiveIpAddress();
  //   final url = '$IpAddress/insert-picked-man_assign_data/';

  //   await fetchRegionAndWarehouse();

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String salesloginno = prefs.getString('salesloginno') ?? '0';
  //   String saveloginname = prefs.getString('saveloginname') ?? '';
  //   String saleslogiOrgid = prefs.getString('saleslogiOrgid') ?? '0';

  //   try {
  //     DateTime now = DateTime.now();
  //     String date = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

  //     String reqno = widget.reqno ?? '';
  //     String pickno = widget.pickno ?? '';
  //     String assignpickman = widget.assignpickname ?? '';
  //     String warehouse = warehouseController.text;
  //     String orgName = regionController.text;

  //     await updateDispatchQty(idcontroller.text, balanceqty);

  //     List<Map<String, dynamic>> allDispatchRows = [];

  //     for (int i = 0; i < balanceqty; i++) {
  //       if (i >= createtableData.length) break;

  //       var row = createtableData[i];

  //       int dispatchQty =
  //           int.tryParse(row['dispatch_qty']?.toString() ?? '0') ?? 0;
  //       int balanceQty = dispatchQty - 1;
  //       if (balanceQty < 0) balanceQty = 0;

  //       Map<String, dynamic> createDispatchData = {
  //         "PICK_ID": pickno,
  //         "REQ_ID": reqno,
  //         "DATE": date,
  //         "ASSIGN_PICKMAN": assignpickman,
  //         "PHYSICAL_WAREHOUSE": warehouse,
  //         "ORG_ID": int.tryParse(saleslogiOrgid) ?? 0,
  //         "ORG_NAME": orgName,
  //         "SALESMAN_NO": int.tryParse(widget.salesman_No ?? '0') ?? 0,
  //         "SALESMAN_NAME": widget.salesman_Name ?? '',
  //         "MANAGER_NO": int.tryParse(widget.Manager_No ?? '0') ?? 0,
  //         "MANAGER_NAME": widget.Manager_Name ?? '',
  //         "PICKMAN_NO": int.tryParse(salesloginno) ?? 0,
  //         "PICKMAN_NAME": saveloginname,
  //         "CUSTOMER_NUMBER": int.tryParse(widget.cusno ?? '0') ?? 0,
  //         "CUSTOMER_NAME": widget.cusname ?? '',
  //         "CUSTOMER_SITE_ID": int.tryParse(widget.cussite ?? '0') ?? 0,
  //         "INVOICE_DATE": date,
  //         "INVOICE_NUMBER": invoiceNoController.text.isNotEmpty
  //             ? invoiceNoController.text
  //             : 'Unknown',
  //         "LINE_NUMBER": int.tryParse(row['line_id']?.toString() ?? '0') ?? 0,
  //         "CUSTOMER_TRX_ID":
  //             int.tryParse(row['customer_trx_id']?.toString() ?? '0') ?? 0,
  //         "CUSTOMER_TRX_LINE_ID":
  //             int.tryParse(row['customer_trx_line_id']?.toString() ?? '0') ?? 0,
  //         "INVENTORY_ITEM_ID": row['itemcode']?.toString() ?? '',
  //         "ITEM_DESCRIPTION": row['itemdetails']?.toString() ?? '',
  //         "TOT_QUANTITY":
  //             int.tryParse(row['invoiceQty']?.toString() ?? '0') ?? 0,
  //         "DISPATCHED_QTY": dispatchQty,
  //         "BALANCE_QTY": balanceQty,
  //         "PICKED_QTY": 1,
  //         "PRODUCT_CODE": 'empty', // Safe default if unknown
  //         "SERIAL_NO": 'empty', // Safe default if unknown
  //         "CREATION_DATE": date,
  //         "CREATED_BY": saveloginname,
  //         "CREATED_IP": '', // Could be actual IP later
  //         "CREATED_MAC": '', // Could be real MAC if needed
  //         "LAST_UPDATE_DATE": date,
  //         "LAST_UPDATED_BY": '',
  //         "LAST_UPDATE_IP": '',
  //         "FLAG": 'A',
  //         "UNDEL_ID": widget.undel_id ?? '',
  //       };

  //       allDispatchRows.add(createDispatchData);
  //     }

  //     final payload = {
  //       "rows": allDispatchRows,
  //       "row_count": allDispatchRows.length,
  //     };

  //     print("🚀 Posting Payload:");
  //     print(jsonEncode(payload));

  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(payload),
  //     );

  //     if (response.statusCode == 201) {
  //       print('✅ All dispatch rows posted successfully!');

  //       postLogData("Pick Man Scan Saved",
  //           "Pickman $salesloginno Saved the Quantity $balanceqty");
  //     } else {
  //       print('❌ Failed to post dispatch rows');
  //       print('Status Code: ${response.statusCode}');
  //       print('Response Body: ${response.body}');

  //       postLogData("Pick Man Scan Saved",
  //           "Pickman $salesloginno Failed to save the Quantity $balanceqty Reason : ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print('❌ Exception while posting dispatch: $e');
  //     postLogData("Pick Man Scan Saved",
  //         "Pickman $salesloginno Failed to save the Quantity $balanceqty Reason : ${e}");
  //   } finally {
  //     isPosting = false;
  //   }
  // }

  Future<void> updateDispatchQty(String id, int qty) async {
    final IpAddress = await getActiveIpAddress();
    final url = Uri.parse('$IpAddress/update_Dispatch_Request/$id/$qty/');

    print("$IpAddress/update_Dispatch_Request/$id/$qty/");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('✅ DISPATCHED_QTY updated successfully.');
      } else {
        print('❌ Failed to update. Status: ${response.statusCode}');
        // print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
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

  TextEditingController invoiceNoController = TextEditingController();
  TextEditingController ItemcodeController = TextEditingController();
  TextEditingController itemDescriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = Responsive.isDesktop(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final totalItems = createtableData.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // You can adjust the background color here
        border: Border.all(
          color: const Color.fromARGB(75, 189, 189, 189)!, // Border color
          width: 1.0, // Border width
        ),

        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Scan Items",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Counter Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Scanned Items",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${tableData.length}/${widget.nofoqty.contains('.') ? widget.nofoqty.split('.')[0] : widget.nofoqty}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Input Fields Section
            StatefulBuilder(builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Wrap(
                  children: [
                    const SizedBox(height: 20),
                    _buildInputCard(
                      context: context,
                      label: 'Invoice No',
                      value: invoiceNoController.text,
                      icon: Icons.receipt,
                      readOnly: true,
                      width: 120,
                    ),
                    const SizedBox(width: 12),
                    _buildInputCard(
                      context: context,
                      label: 'Item Code',
                      value: ItemcodeController.text,
                      icon: Icons.qr_code,
                      readOnly: true,
                      width: 170,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: _buildInputCard(
                        context: context,
                        label: 'Item Description',
                        value: itemDescriptionController.text,
                        icon: Icons.description,
                        readOnly: true,
                        width: 300,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: _buildCountInputCard(
                        context: context,
                        label: 'Picked Count',
                        value: barcodeControllers.text,
                        icon: Icons.barcode_reader,
                        readOnly: false,
                        width: 120,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (barcodeControllers.text.isEmpty) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) {
                              final theme = Theme.of(context);
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.44,
                                  width: isDesktop
                                      ? screenWidth * 0.25
                                      : screenWidth * 0.75,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 16,
                                        spreadRadius: 0,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Info Icon
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.info_outline_rounded,
                                            size: 40,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),

                                        const SizedBox(height: 24),

                                        // Title
                                        Text(
                                          "Quantity Required",
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade800,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),

                                        const SizedBox(height: 16),

                                        // Message
                                        Text(
                                          "Please enter the quantity before proceeding.",
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            color: Colors.grey.shade700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),

                                        const SizedBox(height: 24),

                                        // Action Button
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.blue.shade700,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 0,
                                            ),
                                            onPressed: () {
                                              Navigator.of(ctx).pop();
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      barcodeFocusNodes);
                                            },
                                            child: Text(
                                              "ENTER QUANTITY",
                                              style: theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
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
                        } else {
                          await _onSavePressed();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'SAVE SCANNED ITEMS',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required bool readOnly,
    required double width,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: theme.hintColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: readOnly ? Colors.grey[100] : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: TextFormField(
                readOnly: readOnly,
                controller: TextEditingController(text: value),
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountInputCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required bool readOnly,
    required double width,
  }) {
    final isDesktop = Responsive.isDesktop(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    String quantity = widget.nofoqty ?? '0';
    quantity = quantity.contains('.') ? quantity.split('.')[0] : quantity;

    return Container(
      width: width,
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: theme.hintColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: 0),
                child: TextFormField(
                  readOnly: readOnly,
                  focusNode: barcodeFocusNodes,
                  controller: barcodeControllers,
                  keyboardType: TextInputType.number, // Show numeric keyboard
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9]')), // Only allow digits
                  ],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    // suffixIcon:
                    //     Icon(Icons.edit, size: 16, color: theme.hintColor),
                  ),
                  onChanged: (value) {
                    int enteredValue = int.tryParse(value) ?? 0;
                    int maxQty = int.tryParse(quantity) ?? 0;

                    if (enteredValue > maxQty) {
                      Future.delayed(Duration.zero, () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) {
                            final theme = Theme.of(context);
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.45,
                                width: isDesktop
                                    ? screenWidth * 0.25
                                    : screenWidth * 0.75,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 16,
                                      spreadRadius: 0,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Warning Icon
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.warning_rounded,
                                          size: 40,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),

                                      const SizedBox(height: 24),

                                      // Title
                                      Text(
                                        "Maximum Quantity Reached",
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade800,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                      const SizedBox(height: 16),

                                      // Message
                                      Text(
                                        "You have reached the maximum allowed quantity of $quantity for this item.",
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          color: Colors.grey.shade700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                      const SizedBox(height: 24),

                                      // Action Button
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.orange.shade700,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                            // Reset to max quantity
                                            barcodeControllers.text = quantity;
                                            // Move cursor to end
                                            barcodeControllers.selection =
                                                TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: barcodeControllers
                                                      .text.length),
                                            );
                                          },
                                          child: Text(
                                            "UNDERSTOOD",
                                            style: theme.textTheme.labelLarge
                                                ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
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
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.green.shade700),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Processing your request...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
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
    int totalItems = int.tryParse(barcodeControllers.text) ?? 0;
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Replace with your actual logic here
      await Future.delayed(Duration(milliseconds: 100)); // Simulate async work

      // Show confirmation dialog
      // showDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: const Text('Confirmation', style: TextStyle(fontSize: 14)),
      //       content: const Text(
      //           'Are you sure you want to save this product code and serial number details?',
      //           style: TextStyle(fontSize: 12)),
      //       actions: [
      //         TextButton(
      //           onPressed: () {
      //             Navigator.of(context).pop(); // Close dialog
      //           },
      //           child: const Text('Cancel'),
      //         ),
      //         TextButton(
      //           onPressed: () async {
      //             int balanceqty = totalItems;
      //             print('balanceqty: $balanceqty');

      //             await postPickmanScan(balanceqty); // Save data
      //             Navigator.of(context).pop();
      //             await Navigator.pushReplacement(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (context) => MainSidebar(
      //                   enabledItems: accessControl,
      //                   initialPageIndex: 14,
      //                 ),
      //               ),
      //             );
      //           },
      //           child: const Text('OK'),
      //         ),
      //       ],
      //     );
      //   },
      // );

      bool _isSaving =
          false; // Add this as a state variable in your State class
      final isDesktop = Responsive.isDesktop(context);
      final screenWidth = MediaQuery.of(context).size.width;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final theme = Theme.of(context);
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Container(
                  width: isDesktop ? screenWidth * 0.35 : screenWidth,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 24,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with icon
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.help_outline_rounded,
                                size: 24,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Confirm Submission',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Content
                        Text(
                          'Are you sure you want to save this product code and serial number details?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!_isSaving) // Only show cancel button when not loading
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'CANCEL',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 120, // Fixed width for consistent sizing
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isSaving
                                      ? theme.primaryColor.withOpacity(0.7)
                                      : theme.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: _isSaving
                                    ? null
                                    : () async {
                                        setState(() => _isSaving = true);
                                        final balanceqty = totalItems;
                                        debugPrint('balanceqty: $balanceqty');

                                        try {
                                          await postPickmanScan(balanceqty);
                                          if (!mounted) return;
                                          Navigator.of(context).pop();
                                          await Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MainSidebar(
                                                enabledItems: accessControl,
                                                initialPageIndex: 20,
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          setState(() => _isSaving = false);
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Error saving: ${e.toString()}'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        } finally {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                child: _isSaving
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'CONFIRM',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                          color: Colors.white,
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
              );
            },
          );
        },
      );
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

  List<Map<String, String>> tableData = []; // Table data
  bool isProcessing = false; // Declare the isProcessing variable

  // Widget _buildcountTextFieldPopup(
  //   int index,
  //   String label,
  //   String value,
  //   IconData icon,
  //   bool readOnly,
  //   double height,
  //   double width, {
  //   int? minLines,
  //   int? maxLines,
  //   TextInputType keyboardType = TextInputType.text,
  // }) {
  //   String quantity = widget.nofoqty ?? '0';
  //   quantity = quantity.contains('.') ? quantity.split('.')[0] : quantity;

  //   double screenWidth = MediaQuery.of(context).size.width;
  //   return Container(
  //     width: width,
  //     child: Padding(
  //       padding: const EdgeInsets.only(left: 0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           SizedBox(height: Responsive.isDesktop(context) ? 20 : 10),
  //           Row(
  //             children: [
  //               Text(label, style: textboxheading),
  //               if (!readOnly)
  //                 Icon(
  //                   Icons.star,
  //                   size: 8,
  //                   color: Colors.red,
  //                 )
  //             ],
  //           ),
  //           const SizedBox(height: 6),
  //           Padding(
  //             padding: const EdgeInsets.only(left: 0, bottom: 0),
  //             child: Row(
  //               children: [
  //                 Container(
  //                     height: height,
  //                     // width: Responsive.isDesktop(context)
  //                     //     ? screenWidth * 0.086
  //                     //     : 130,

  //                     width: width,
  //                     child: MouseRegion(
  //                       onEnter: (event) {
  //                         // You can perform any action when mouse enters, like logging the value.
  //                       },
  //                       onExit: (event) {
  //                         // Perform any action when the mouse leaves the TextField area.
  //                       },
  //                       cursor: SystemMouseCursors
  //                           .click, // Changes the cursor to indicate interaction
  //                       child: Tooltip(
  //                         message: value,
  //                         child: TextField(
  //                           controller: barcodeControllers,
  //                           keyboardType: TextInputType.number,
  //                           textInputAction: TextInputAction.done,
  //                           decoration: InputDecoration(
  //                             enabledBorder: const OutlineInputBorder(
  //                               borderSide: BorderSide(
  //                                 color: Color.fromARGB(201, 132, 132, 132),
  //                                 width: 1.0,
  //                               ),
  //                             ),
  //                             focusedBorder: const OutlineInputBorder(
  //                               borderSide: BorderSide(
  //                                 color: Color.fromARGB(255, 58, 58, 58),
  //                                 width: 1.0,
  //                               ),
  //                             ),
  //                             contentPadding: const EdgeInsets.symmetric(
  //                               vertical: 5.0,
  //                               horizontal: 10.0,
  //                             ),
  //                           ),
  //                           onChanged: (value) {
  //                             int enteredValue = int.tryParse(value) ?? 0;
  //                             int maxQty = int.tryParse(quantity) ?? 0;

  //                             if (enteredValue > maxQty) {
  //                               Future.delayed(Duration.zero, () {
  //                                 showDialog(
  //                                   context: context,
  //                                   builder: (ctx) {
  //                                     return AlertDialog(
  //                                       title: Text("Error"),
  //                                       content: Text("You reached the count!"),
  //                                       actions: [
  //                                         TextButton(
  //                                           onPressed: () {
  //                                             Navigator.of(ctx).pop();
  //                                             // Reset to max quantity
  //                                             barcodeControllers.text =
  //                                                 quantity;
  //                                             // Move cursor to end
  //                                             barcodeControllers.selection =
  //                                                 TextSelection.fromPosition(
  //                                               TextPosition(
  //                                                 offset: barcodeControllers
  //                                                     .text.length,
  //                                               ),
  //                                             );
  //                                           },
  //                                           child: Text("OK"),
  //                                         ),
  //                                       ],
  //                                     );
  //                                   },
  //                                 );
  //                               });
  //                             }
  //                           },
  //                           style: TextStyle(fontSize: 13),
  //                         ),
  //                       ),
  //                     )),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
