import 'package:http/http.dart' as http;
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:flutter/material.dart';

class WarehouseStaff extends StatefulWidget {
  const WarehouseStaff({super.key});

  @override
  State<WarehouseStaff> createState() => _WarehouseStaffState();
}

class _WarehouseStaffState extends State<WarehouseStaff> {
  Widget _buildTextFieldDesktop(String label, String value, IconData icon) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: Responsive.isDesktop(context) ? screenWidth * 0.11 : 170,
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: commonLabelTextStyle),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  Container(
                      height: 27,
                      width: Responsive.isDesktop(context)
                          ? screenWidth * 0.086
                          : 130,
                      child: MouseRegion(
                        onEnter: (event) {
                          // You can perform any action when mouse enters, like logging the value.
                        },
                        onExit: (event) {
                          // Perform any action when the mouse leavess the TextField area.
                        },
                        cursor: SystemMouseCursors
                            .click, // Changes the cursor to indicate interaction
                        child: Tooltip(
                          message: value,
                          child: TextField(
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
                              fillColor: Colors.grey[
                                  200], // Set the background color to grey[200]
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0,
                              ),
                            ),
                            controller: TextEditingController(text: value),
                            style: textStyle,
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

  List<Map<String, dynamic>> tableData = [
    {
      'id': 1,
      'invoiceno': '2411026555',
      'itemcode': 'DEG75588E',
      'itemdetails': 'Washing Machine',
      'noofqty': '100',
      'scannedqty': '50',
      'needtoscan': '0',
      'status': 'N.F',
    },
    {
      'id': 2,
      'invoiceno': '2411026553',
      'itemcode': 'DEG78888E',
      'itemdetails': 'A/C',
      'noofqty': '150',
      'scannedqty': '100',
      'needtoscan': '50',
      'status': 'N.F',
    },
  ];

  Widget _buildTable() {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.9
                  : MediaQuery.of(context).size.width * 1.4,
              child: SingleChildScrollView(
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10, top: 13, bottom: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.category,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("S.No",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.print,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Invoice.No",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.category,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Item Code",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.print,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Item Details",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.category,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("No.Of.Qty",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.print,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Scanned Qty",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.call_to_action,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Need to Scan",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.category,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Status",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.print,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Scan",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (tableData.isNotEmpty)
                    ...tableData.map((data) {
                      var id = data['id'].toString();
                      var invoiceno = data['invoiceno'].toString();
                      var itemcode = data['itemcode'].toString();
                      var itemdetails = data['itemdetails'].toString();
                      var noofqty = data['noofqty'].toString();
                      var scannedqty = data['scannedqty'].toString();
                      var needtoscan = data['needtoscan'].toString();
                      var status = data['status'].toString();
                      bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                      Color? rowColor = isEvenRow
                          ? Color.fromARGB(224, 255, 255, 255)
                          : Color.fromARGB(224, 255, 255, 255);

                      return GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 10, bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(id,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(invoiceno,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(itemcode,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(itemdetails,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(noofqty,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(scannedqty,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(needtoscan,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(status,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color.fromARGB(
                                                    255, 1, 1, 189), // Ink blue
                                                Color.fromARGB(255, 80, 190,
                                                    234), // Sky blue
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                                5), // Matches button radius
                                          ),
                                          child: ElevatedButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return _customerDetailsDialog(
                                                      context,
                                                      '$invoiceno',
                                                      '$itemcode',
                                                      '$itemdetails',
                                                      '$scannedqty',
                                                    );
                                                  },
                                                );

                                                setState(() {
                                                  // Loop through each item in tableData and update the quantities
                                                  for (var i = 0;
                                                      i <
                                                          createtableData
                                                              .length;
                                                      i++) {
                                                    var item =
                                                        createtableData[i];

                                                    // Convert disreqqty and sendqty to int to perform subtraction
                                                    int invoiceno =
                                                        int.tryParse(item[
                                                                'invoiceno']) ??
                                                            0;
                                                    int itemcode = int.tryParse(
                                                            item['itemcode']) ??
                                                        0;

                                                    // Update dispatchqty
                                                    item['itemdetails'] =
                                                        itemdetails.toString();
                                                  }
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors
                                                    .transparent, // Make button background transparent
                                                shadowColor: Colors
                                                    .transparent, // Remove shadow if needed
                                                minimumSize: Size(45.0, 31.0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                              child:
                                                  Responsive.isDesktop(context)
                                                      ? Text(
                                                          'Scan',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )
                                                      : Icon(
                                                          Icons.qr_code_scanner,
                                                          size: 12,
                                                          color: Colors.white,
                                                        )),
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
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextEditingController NoofitemController = TextEditingController(text: "0");
  TextEditingController totalSendqtyController =
      TextEditingController(text: '0');

  void _updatedisreqamt() {
    // Use the getTotalFinalAmt function to update the total amount
    totalSendqtyController.text =
        gettotaldisreqamt(tableData).toStringAsFixed(2);
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
    _updatecount();
  }

  @override
  Widget build(BuildContext context) {
    double screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Container(
          height: screenheight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(77, 1, 1, 189), // Ink blue
                Color.fromARGB(72, 80, 190, 234), // Sky blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(5), // Matches button radius
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                if (Responsive.isDesktop(context))
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 250,
                            height: 60,
                            color: Color.fromRGBO(28, 0, 118, 1),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10, left: 20),
                              child: Text(
                                'Warehouse Staff',
                                style: TextStyle(
                                    fontSize: 23,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 10,
                                  right: Responsive.isDesktop(context)
                                      ? MediaQuery.of(context).size.width * 0.08
                                      : 6),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("Staff Name: ",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold)),
                                      Text("Rahuman ",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          )),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text("Staff Login : ",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold)),
                                      Text("#001 ",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          )
                        ],
                      ),
                    ],
                  ),
                SizedBox(
                  height: 20,
                ),
                if (Responsive.isDesktop(context))
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Row(
                      children: [
                        _buildTextFieldDesktop(
                            'Dispatch ID', 'Dis-001', Icons.numbers),
                        _buildTextFieldDesktop(
                            'DispatchReq ID', 'Req-001', Icons.request_page),
                        _buildTextFieldDesktop('Physical Warehouse',
                            "Jeddah Warehouse", Icons.warehouse),
                        _buildTextFieldDesktop(
                            'Region', "Western Region", Icons.location_city),
                        _buildTextFieldDesktop(
                            'Customer No', "1667", Icons.no_accounts),
                        _buildTextFieldDesktop('Customer Name', "customerName",
                            Icons.perm_identity),
                        _buildTextFieldDesktop(
                            'Customer Site', "4566", Icons.sixteen_mp_outlined),
                      ],
                    ),
                  ),
                if (!Responsive.isDesktop(context))
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runSpacing: 2,
                      children: [
                        _buildTextFieldDesktop(
                            'Dispatch ID', 'Dis-001', Icons.numbers),
                        _buildTextFieldDesktop(
                            'DispatchReq ID', 'Req-001', Icons.request_page),
                        _buildTextFieldDesktop('Physical Warehouse',
                            "Jeddah Warehouse", Icons.warehouse),
                        _buildTextFieldDesktop(
                            'Region', "Western Region", Icons.location_city),
                        _buildTextFieldDesktop(
                            'Customer No', "1667", Icons.no_accounts),
                        _buildTextFieldDesktop('Customer Name', "customerName",
                            Icons.perm_identity),
                        _buildTextFieldDesktop(
                            'Customer Site', "4566", Icons.sixteen_mp_outlined),
                        _buildTextFieldDesktop('Vendor', "1001", Icons.shop),
                        _buildTextFieldDesktop('Vendor Site',
                            "Integerated Distribution Solution", Icons.shop),
                        _buildTextFieldDesktop(
                            'Driver', "AL12", Icons.drive_file_rename_outline),
                        _buildTextFieldDesktop(
                            'Vehicle No', "HCM1679", Icons.drive_eta),
                        _buildTextFieldDesktop(
                            'Loading Charges', '10', Icons.monetization_on),
                        _buildTextFieldDesktop(
                            'Transport Charges', '15', Icons.local_shipping),
                        _buildTextFieldDesktop(
                            'Misc Charges', '5', Icons.miscellaneous_services),
                      ],
                    ),
                  ),
                if (Responsive.isDesktop(context))
                  SizedBox(
                    height: 15,
                  ),
                if (Responsive.isDesktop(context))
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Row(
                      children: [
                        _buildTextFieldDesktop('Vendor', "1001", Icons.shop),
                        _buildTextFieldDesktop('Vendor Site',
                            "Integerated Distribution Solution", Icons.shop),
                        _buildTextFieldDesktop(
                            'Driver', "AL12", Icons.drive_file_rename_outline),
                        _buildTextFieldDesktop(
                            'Vehicle No', "HCM1679", Icons.drive_eta),
                        _buildTextFieldDesktop(
                            'Loading Charges', '10', Icons.monetization_on),
                        _buildTextFieldDesktop(
                            'Transport Charges', '15', Icons.local_shipping),
                        _buildTextFieldDesktop(
                            'Misc Charges', '5', Icons.miscellaneous_services),
                      ],
                    ),
                  ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 45),
                  child: Row(
                    mainAxisAlignment: Responsive.isDesktop(context)
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    crossAxisAlignment: Responsive.isDesktop(context)
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: Responsive.isDesktop(context)
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        crossAxisAlignment: Responsive.isDesktop(context)
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        children: [
                          Text("Remark", style: commonLabelTextStyle),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Row(
                              children: [
                                Container(
                                  height: 24,
                                  width: 370,
                                  color: Colors.grey[100],
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
                                      message: "TO BE DELIVER TODAY",
                                      child: TextField(
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.read_more_rounded,
                                            size: 12,
                                          ),
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
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            vertical: 5.0,
                                            horizontal: 10.0,
                                          ),
                                        ),
                                        controller: TextEditingController(
                                            text: "TO BE DELIVER TODAY"),
                                        style: textStyle,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (Responsive.isDesktop(context))
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 15, left: 35, right: 35),
                    child: Container(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildTable(),
                          ],
                        ), // Assuming _viewbuildTable() returns a valid widget
                      ),
                    ),
                  ),
                if (!Responsive.isDesktop(context))
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 15, left: 35, right: 35),
                    child: Container(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: _buildTable(),
                      ),
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: 20,
                              left: 100,
                              right: Responsive.isDesktop(context)
                                  ? MediaQuery.of(context).size.width * 0.15
                                  : 50),
                          child: _buildTextFieldDesktop('Total Quantity',
                              totalSendqtyController.text, Icons.money),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 45),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("", style: commonLabelTextStyle),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 24,
                                      width: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
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

  void _updatecount() {
    // Use the getTotalFinalAmt function to update the total amount
    NoofitemController.text = getcount(createtableData).toStringAsFixed(0);
    print("NoofitemController amountttt ${NoofitemController.text}");
  }

  int getcount(List<Map<String, dynamic>> createtableData) {
    return createtableData.length;
  }

  Widget _customerDetailsDialog(BuildContext context, String invoiceno,
      String itemcode, String itemdetails, String scannedqty) {
    double screenWidth = MediaQuery.of(context).size.width;
    TextEditingController barcodeController = TextEditingController();
    TextEditingController serialnoController = TextEditingController();

    FocusNode InvoicenoFocusnode = FocusNode();
    FocusNode ItemdetialsFocusnode = FocusNode();
    FocusNode barcodeFocusnode = FocusNode();
    FocusNode serialnofocusnode = FocusNode();
    FocusNode savebuttonfocusnode = FocusNode();

    // Function to add data
    void _addData() {
      // Determine the highest existing ID in createtableData
      int highestId = createtableData.isNotEmpty
          ? createtableData
              .map((item) => item['id'] as int)
              .reduce((a, b) => a > b ? a : b)
          : 0;

      // Ensure text is fetched correctly from controllers before adding to the new item
      String barcodeText = barcodeController.text.trim();
      String serialNoText = serialnoController.text.trim();

      // Prepare the new item for tableData with incremented ID
      Map<String, dynamic> newItem = {
        'id': highestId + 1,
        'invoiceno': invoiceno,
        'itemcode': itemcode,
        'itemdetails': itemdetails,
        'barcode': barcodeText,
        'serialno': serialNoText,
      };

      // Add the new item to createtableData and update the state
      setState(() {
        createtableData.add(newItem);
        print("Added new item to createtableData: $newItem");
        print("Updated createtableData: $createtableData");
      });

      // Clear the text controllers
      barcodeController.clear();
      serialnoController.clear();

      // Show a success message or perform other actions if needed
      successfullyLoginMessage();
    }

    void _fieldFocusChange(
        BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
      currentFocus.unfocus();
      FocusScope.of(context).requestFocus(nextFocus);
    }

    Widget _buildTextFieldDesktop(
        String label,
        TextEditingController controller,
        FocusNode Focusnode,
        FocusNode nextfocusnode) {
      double screenWidth = MediaQuery.of(context).size.width;
      return Container(
        width: Responsive.isDesktop(context) ? screenWidth * 0.11 : 170,
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: commonLabelTextStyle),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  children: [
                    Container(
                        height: 27,
                        width: Responsive.isDesktop(context)
                            ? screenWidth * 0.086
                            : 130,
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
                            message: controller.text,
                            child: TextField(
                              onSubmitted: (value) {
                                _fieldFocusChange(
                                    context, Focusnode, nextfocusnode);
                              },
                              focusNode: Focusnode,
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
                                fillColor: Colors.grey[
                                    200], // Set the background color to grey[200]
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 5.0,
                                  horizontal: 10.0,
                                ),
                              ),
                              controller:
                                  controller, // Use the actual controller
                              style: textStyle,
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

    int noOfItems = int.tryParse(NoofitemController.text) ?? 0;

    int scanitem = int.tryParse(scannedqty) ?? 0;
    String balanceItem =
        (scanitem - noOfItems).toString(); // Convert the result to a string

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          width: Responsive.isDesktop(context)
              ? screenWidth * 0.6
              : screenWidth * 0.9,
          height: 550,
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Scan Pop-Up View",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    runSpacing: 5,
                    children: [
                      _buildTextFieldDesktop(
                          'Invoice No',
                          TextEditingController(text: invoiceno),
                          InvoicenoFocusnode,
                          ItemdetialsFocusnode),
                      _buildTextFieldDesktop(
                          'Item Details',
                          TextEditingController(text: itemdetails),
                          ItemdetialsFocusnode,
                          barcodeFocusnode),
                      _buildTextFieldDesktop('Barcode', barcodeController,
                          barcodeFocusnode, serialnofocusnode),
                      _buildTextFieldDesktop('Serial No', serialnoController,
                          serialnofocusnode, savebuttonfocusnode),
                      SizedBox(
                        width: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: ElevatedButton(
                          focusNode: savebuttonfocusnode,
                          onPressed: () {
                            if (barcodeController.text.trim().isEmpty ||
                                serialnoController.text.trim().isEmpty) {
                              checkfeilds();
                            } else {
                              // If both fields are filled, proceed with adding data and updating count
                              setState(() {
                                _addData();
                                _updatecount();
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Color.fromRGBO(28, 0, 118, 1),
                            minimumSize:
                                const Size(45.0, 40.0), // Set width and height
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: const Text(
                              'Add',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Container(
                          height: 200,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child:
                                _viewbuildTable(), // Assuming _viewbuildTable() returns a valid widget
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 30,
                    ),
                    Text('No.Of.Items : ${NoofitemController.text}',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 30,
                    ),
                    Text('Scanned Items : ${scannedqty}',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 30,
                    ),
                    Text('Balance Items : ${balanceItem}',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 25),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => createdispatch()),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Color.fromRGBO(28, 0, 118, 1),
                      minimumSize:
                          const Size(45.0, 40.0), // Set width and height
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> createtableData = [
    {
      'id': 1,
      'invoiceno': '241105288',
      'itemcode': 'DEG93203A',
      'itemdetails': 'A/C',
      'barcode': '67',
      'serialno': 'N.F'
    },
    {
      'id': 2,
      'invoiceno': '241105299',
      'itemcode': 'DEG93207A',
      'itemdetails': 'Washing Machine',
      'barcode': '67',
      'serialno': 'N.F'
    },
    {
      'id': 3,
      'invoiceno': '241105588',
      'itemcode': 'DEG932443A',
      'itemdetails': 'A/C',
      'invoiceqty': '317',
      'barcode': '67',
      'serialno': 'N.F'
    },
  ];

  Widget _viewbuildTable() {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.55
                  : MediaQuery.of(context).size.width * 1,
              child: SingleChildScrollView(
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10, top: 5, bottom: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            color: Colors.white,
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.category,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("No",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.print,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Invoice No",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.category,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Item Code",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.print,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Item Details",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.category,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Barcode",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.print,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Serial No",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (createtableData.isNotEmpty)
                    ...createtableData.map((data) {
                      var id = data['id'].toString();

                      var invoiceno = data['invoiceno'].toString();
                      var itemcode = data['itemcode'].toString();
                      var itemdetails = data['itemdetails'].toString();
                      var barcode = data['barcode'].toString();
                      var serialno = data['serialno'].toString();
                      bool isEvenRow = createtableData.indexOf(data) % 2 == 0;
                      Color? rowColor = isEvenRow
                          ? Color.fromARGB(224, 255, 255, 255)
                          : Color.fromARGB(224, 255, 255, 255);

                      return GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 10, bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(id,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(invoiceno,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(itemcode,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(itemdetails,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(barcode,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: Border.all(
                                      color: Color.fromARGB(255, 226, 225, 225),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(serialno,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList()
                ]),
              ),
            ),
          ],
        ),
      ),
    );
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
                style: TextStyle(fontSize: 15, color: Colors.black),
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

  void checkfeilds() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.warning, color: Colors.yellow),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                'Kindly Fill all feilds?',
                style: TextStyle(fontSize: 15, color: Colors.black),
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
