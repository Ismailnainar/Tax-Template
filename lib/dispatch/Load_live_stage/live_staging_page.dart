import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:http/http.dart' as http;
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'live_staging_controller.dart';
import 'live_staging_widgets.dart';

class Live_StagingPage extends StatefulWidget {
  final Function togglePage;

  Live_StagingPage(this.togglePage);

  @override
  State<Live_StagingPage> createState() => _Live_StagingPageState();
}

class _Live_StagingPageState extends State<Live_StagingPage> {
  late LiveStagingController _controller;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = LiveStagingController();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _controller.filteredData = List.from(_controller.tableData);
    await _controller.fetchAccessControl();
    // await _controller._loadSalesmanName();
    await _controller.fetchlivestagingreports();
    await postLogData("Live Stage", "Opened");

    _controller.scannedqtyController.text =
        _controller.filteredData.length.toString();
    print("Scanned Qty ${_controller.scannedqtyController.text}");

    // Force rebuild after data is loaded
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.ProductCodeController.dispose();
    _controller.salesserialnoController.dispose();
    postLogData("Live Stage", "Closed");
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String scanneditems = _controller.scannedqtyController.text;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.only(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Responsive.isDesktop(context))
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey[400]!,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(width: 15),
                                Icon(Icons.directions_car_filled, size: 28),
                                SizedBox(width: 10),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Live Staging Report',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
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
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(0),
                                      child: Text(
                                        _controller.saveloginname ??
                                            'Loading...',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(0),
                                      child: Text(
                                        _controller.saveloginrole ??
                                            'Loading....',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 30),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.85,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey[400]!,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Staging Details :',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[700]),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 20),
                            SizedBox(
                              width: Responsive.isDesktop(context) ? 180 : 150,
                              height: 33,
                              child: TextField(
                                controller: _controller.searchReqNoController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter Request No',
                                  border: OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                ),
                                onChanged: (value) => _controller.searchreqno(),
                                style: textBoxstyle,
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: Responsive.isDesktop(context) ? 180 : 150,
                              height: 33,
                              child: TextField(
                                controller: _controller.SearchPickidController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter Pick Id',
                                  border: OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                ),
                                onChanged: (value) => _controller.searchreqno(),
                                style: textBoxstyle,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 10, left: 10, top: 10),
                            child: _buildTableView(),
                          ),
                        ),
                      ],
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

  Widget _buildTableView() {
    return Responsive.isDesktop(context)
        ? LiveStagingWidgets.buildTable(context, _controller,
            _horizontalScrollController, widget.togglePage)
        : LiveStagingWidgets.buildCardView(
            context, _controller, widget.togglePage);
  }
}
