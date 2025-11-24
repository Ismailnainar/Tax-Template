import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/dispatch/Load_Intruck.dart/Load_Intruck_Quickbill.dart';
import 'package:flutter/material.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:flutter/services.dart';
import 'Loadin_Intruck_controller.dart';
import 'Load_Intruck_widgets.dart';

class LoadInTruckPage extends StatefulWidget {
  final Function togglePage;
  final String reqno;
  final String pickno;
  final String cusno;
  final String cusname;
  final String cussite;
  final String pickedqty;

  LoadInTruckPage(this.togglePage, this.reqno, this.pickno, this.cusno,
      this.cusname, this.cussite, this.pickedqty);

  @override
  State<LoadInTruckPage> createState() => _LoadInTruckPageState();
}

class _LoadInTruckPageState extends State<LoadInTruckPage>
    with SingleTickerProviderStateMixin {
  late LiveStagingController _controller;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = LiveStagingController();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    _controller.filteredData = List.from(_controller.tableData);
    await _controller.fetchAccessControl();
    await _controller.fetchlivestagingreports();
    await _controller.fetchQuickBilllivestagingreports();
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
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String scanneditems = _controller.scannedqtyController.text;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[200],
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
                    // child: Column(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: [
                    //     Padding(
                    //       padding: const EdgeInsets.all(10),
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.start,
                    //         children: [
                    //           Text(
                    //             'Staging Details :',
                    //             style: TextStyle(
                    //                 fontSize: 15,
                    //                 fontWeight: FontWeight.bold,
                    //                 color: Colors.blueGrey[700]),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //     Row(
                    //       children: [
                    //         const SizedBox(width: 20),
                    //         SizedBox(
                    //           width: Responsive.isDesktop(context) ? 180 : 150,
                    //           height: 33,
                    //           child: TextField(
                    //             controller: _controller.searchReqNoController,
                    //             decoration: const InputDecoration(
                    //               hintText: 'Enter Request No',
                    //               border: OutlineInputBorder(),
                    //               contentPadding:
                    //                   EdgeInsets.symmetric(horizontal: 10),
                    //             ),
                    //             onChanged: (value) => _controller.searchreqno(),
                    //             style: textBoxstyle,
                    //           ),
                    //         ),
                    //         const SizedBox(width: 20),
                    //         SizedBox(
                    //           width: Responsive.isDesktop(context) ? 180 : 150,
                    //           height: 33,
                    //           child: TextField(
                    //             controller: _controller.SearchPickidController,
                    //             decoration: const InputDecoration(
                    //               hintText: 'Enter Pick Id',
                    //               border: OutlineInputBorder(),
                    //               contentPadding:
                    //                   EdgeInsets.symmetric(horizontal: 10),
                    //             ),
                    //             onChanged: (value) => _controller.searchreqno(),
                    //             style: textBoxstyle,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //     Expanded(
                    //       child: Padding(
                    //         padding: const EdgeInsets.only(
                    //             right: 10, left: 10, top: 10),
                    //         child: _buildTableView(),
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    child: Column(
                      children: [
                        // Tab Bar
                        Container(
                          color: Colors.grey[100],
                          child: TabBar(
                            controller: _tabController,
                            indicatorColor: Colors.blue,
                            labelColor: Colors.blue,
                            unselectedLabelColor: Colors.grey,
                            tabs: [
                              Tab(text: 'Loadman Process Dispatch'),
                              Tab(text: 'Quick Dispatch Process'),
                            ],
                          ),
                        ),

                        // Tab Bar View
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // First Tab Content - Loadman Process Dispatch
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                        width: Responsive.isDesktop(context)
                                            ? 180
                                            : 150,
                                        height: 33,
                                        child: TextField(
                                          controller:
                                              _controller.searchReqNoController,
                                          decoration: const InputDecoration(
                                            hintText: 'Enter Request No',
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              _controller.SearchPickidController
                                                  .clear();
                                            });
                                            _controller.searchreqno();
                                          },
                                          style: textBoxstyle,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      SizedBox(
                                        width: Responsive.isDesktop(context)
                                            ? 180
                                            : 150,
                                        height: 33,
                                        child: TextField(
                                          controller: _controller
                                              .SearchPickidController,
                                          decoration: const InputDecoration(
                                            hintText: 'Enter Pick Id',
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              _controller.searchReqNoController
                                                  .clear();
                                            });
                                            _controller.searchreqno();
                                          },
                                          style: textBoxstyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10, left: 10, top: 10),
                                      child: _buildTableView(),
                                    ),
                                  ),
                                ],
                              ),

                              // Second Tab Content - Quickbill Process
                              // You can replace this with your Quickbill Process content
                              Center(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Quick Dispatch Staging Details :',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueGrey[700]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 10, left: 10, top: 10),
                                        child: _build_Quick_Bill_TableView(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

  Widget _build_Quick_Bill_TableView() {
    return Responsive.isDesktop(context)
        ? LiveStaging_Quick_billWidgets.buildTable(context, _controller,
            _horizontalScrollController, widget.togglePage)
        : LiveStaging_Quick_billWidgets.buildCardView(
            context, _controller, widget.togglePage);
  }
}
