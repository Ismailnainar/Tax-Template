import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/Reports/Inter_ORG_Report/Excelexport.dart';
import 'package:aljeflutterapp/Reports/Inter_ORG_Report/Inter%20Org_header.dart';
import 'package:aljeflutterapp/Reports/Inter_ORG_Report/Inter_Org_controllers.dart';
import 'package:aljeflutterapp/Reports/Inter_ORG_Report/Inter_Org_receviedDetailstableview.dart';
import 'package:aljeflutterapp/Reports/Inter_ORG_Report/Inter_Org_receviedtableview.dart';
import 'package:aljeflutterapp/Reports/Inter_ORG_Report/Inter_Org_tableview.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Inter_ORG_Main_page extends StatefulWidget {
  final initialTab;
  const Inter_ORG_Main_page({super.key, this.initialTab});

  @override
  State<Inter_ORG_Main_page> createState() => _Inter_ORG_Main_pageState();
}

class _Inter_ORG_Main_pageState extends State<Inter_ORG_Main_page>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    final initialTabIndex =
        widget.initialTab ?? (saveloginrole == "Salesman" ? 1 : 0);

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initialTabIndex.clamp(0, 2),
    );
  }

  void togglePage(int index) {
    if (index >= 0 && index < _tabController.length) {
      _tabController.animateTo(index);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    postLogData("Inter Org Transfer Details", "Closed");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => Inter_Org_Controller(),
        child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (Responsive.isDesktop(context)) Inter_Org_Header(),
                  Padding(
                    padding: EdgeInsets.only(left: 5, right: 5, bottom: 5),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.84,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(
                            //       horizontal: 16.0, vertical: 8.0),
                            //   child: Column(
                            //     children: [
                            //       Container(
                            //         height: 48,
                            //         decoration: BoxDecoration(
                            //           borderRadius: BorderRadius.circular(12),
                            //           border: Border.all(
                            //             color: Colors.grey[300]!,
                            //             width: 1.5,
                            //           ),
                            //         ),
                            //         child: TabBar(
                            //           controller: _tabController,
                            //           indicator: BoxDecoration(
                            //             borderRadius: BorderRadius.circular(10),
                            //             color: Colors.transparent,
                            //             border: Border(
                            //               bottom: BorderSide(
                            //                 color:
                            //                     Theme.of(context).primaryColor,
                            //                 width: 3.0,
                            //               ),
                            //             ),
                            //           ),
                            //           indicatorSize: TabBarIndicatorSize.label,
                            //           labelColor:
                            //               Theme.of(context).primaryColor,
                            //           unselectedLabelColor: Colors.grey[600],
                            //           labelStyle: TextStyle(
                            //             fontSize: 14,
                            //             fontWeight: FontWeight.w600,
                            //           ),
                            //           unselectedLabelStyle: TextStyle(
                            //             fontSize: 14,
                            //             fontWeight: FontWeight.w500,
                            //           ),
                            //           tabs: [
                            //             // First tab
                            //             Tab(
                            //               child: AnimatedBuilder(
                            //                 animation: _tabController,
                            //                 builder: (context, child) {
                            //                   final isSelected =
                            //                       _tabController.index == 0;
                            //                   final isDisabled =
                            //                       saveloginrole == "Salesman";
                            //                   return IgnorePointer(
                            //                     ignoring: isDisabled,
                            //                     child: Opacity(
                            //                       opacity:
                            //                           isDisabled ? 0.5 : 1.0,
                            //                       child: Container(
                            //                         padding:
                            //                             EdgeInsets.symmetric(
                            //                                 horizontal: 12),
                            //                         child: Transform.translate(
                            //                           offset: isSelected
                            //                               ? Offset(0, -2)
                            //                               : Offset.zero,
                            //                           child: Row(
                            //                             mainAxisAlignment:
                            //                                 MainAxisAlignment
                            //                                     .center,
                            //                             children: [
                            //                               Icon(
                            //                                 Icons
                            //                                     .send_and_archive,
                            //                                 size: 18,
                            //                                 color: isDisabled
                            //                                     ? Colors
                            //                                         .grey[400]
                            //                                     : isSelected
                            //                                         ? Theme.of(
                            //                                                 context)
                            //                                             .primaryColor
                            //                                         : Colors.grey[
                            //                                             600],
                            //                               ),
                            //                               SizedBox(width: 6),
                            //                               Text(
                            //                                   'Inter ORG Transfer Report'),
                            //                             ],
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   );
                            //                 },
                            //               ),
                            //             ),
                            //             // Second tab
                            //             Tab(
                            //               child: AnimatedBuilder(
                            //                 animation: _tabController,
                            //                 builder: (context, child) {
                            //                   final isSelected =
                            //                       _tabController.index == 1;
                            //                   return Container(
                            //                     padding: EdgeInsets.symmetric(
                            //                         horizontal: 12),
                            //                     child: Transform.translate(
                            //                       offset: isSelected
                            //                           ? Offset(0, -2)
                            //                           : Offset.zero,
                            //                       child: Row(
                            //                         mainAxisAlignment:
                            //                             MainAxisAlignment
                            //                                 .center,
                            //                         children: [
                            //                           Icon(
                            //                             Icons
                            //                                 .call_received_outlined,
                            //                             size: 18,
                            //                             color: isSelected
                            //                                 ? Theme.of(context)
                            //                                     .primaryColor
                            //                                 : Colors.grey[600],
                            //                           ),
                            //                           SizedBox(width: 6),
                            //                           Text('Received Report'),
                            //                         ],
                            //                       ),
                            //                     ),
                            //                   );
                            //                 },
                            //               ),
                            //             ),
                            //             // Third tab - **ENABLED NOW**
                            //             Tab(
                            //               child: AnimatedBuilder(
                            //                 animation: _tabController,
                            //                 builder: (context, child) {
                            //                   final isSelected =
                            //                       _tabController.index == 2;
                            //                   // final isDisabled = true; // REMOVE THIS
                            //                   return Container(
                            //                     padding: EdgeInsets.symmetric(
                            //                         horizontal: 12),
                            //                     child: Transform.translate(
                            //                       offset: isSelected
                            //                           ? Offset(0, -2)
                            //                           : Offset.zero,
                            //                       child: Row(
                            //                         mainAxisAlignment:
                            //                             MainAxisAlignment
                            //                                 .center,
                            //                         children: [
                            //                           Icon(
                            //                             Icons.list_alt,
                            //                             size: 18,
                            //                             color: isSelected
                            //                                 ? Theme.of(context)
                            //                                     .primaryColor
                            //                                 : Colors.grey[600],
                            //                           ),
                            //                           SizedBox(width: 6),
                            //                           Text(
                            //                               'Received Details Report'),
                            //                         ],
                            //                       ),
                            //                     ),
                            //                   );
                            //                 },
                            //               ),
                            //             ),
                            //           ],
                            //           onTap: (index) {
                            //             // Disabled check for first tab only
                            //             if (saveloginrole == "Salesman" &&
                            //                 index == 0) {
                            //               _tabController.animateTo(1);
                            //               return;
                            //             }
                            //             // Allow navigation to all tabs including 2 now
                            //             HapticFeedback.lightImpact();
                            //           },
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ExportReport(),
                                      SizedBox(
                                        width: 50,
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.76,

                                    child: Inter_Org_tableview(),

                                    // TabBarView(
                                    //   controller: _tabController,
                                    //   children: [
                                    //     Inter_Org_tableview(),
                                    //     Inter_Org_receviedtableview(
                                    //       togglePage: togglePage,
                                    //     ),
                                    //     Inter_Org_recevieddetailstableview(
                                    //       Passesname: 'Inter Org Details',
                                    //     ),
                                    //   ],
                                    // ),
                                  ),
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
          ),
        ));
  }
}


// class _Inter_ORG_Main_pageState extends State<Inter_ORG_Main_page>
//     with TickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     postLogData("Inter Org Transfer Details", "Opened");

//     // Initialize tab controller with initial index based on salesmanname
//     _tabController = TabController(
//       length: 2,
//       vsync: this,
//       initialIndex: saveloginrole == "Salesman" ? 1 : 0,
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     postLogData("Inter Org Transfer Details", "Closed");
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => Inter_Org_Controller(),
//       child: Scaffold(
//         body: Container(
//           width: MediaQuery.of(context).size.width,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (Responsive.isDesktop(context)) Inter_Org_Header(),
//                 Padding(
//                   padding: EdgeInsets.only(left: 5, right: 5, bottom: 5),
//                   child: Container(
//                     height: MediaQuery.of(context).size.height * 0.84,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.vertical,
//                       child: Column(
//                         children: [
//                           SingleChildScrollView(
//                             scrollDirection: Axis.vertical,
//                             child: Column(
//                               children: [
//                                 Padding(
//                                   padding: EdgeInsets.only(top: 15),
//                                   child: SizedBox(
//                                     height: MediaQuery.of(context).size.height *
//                                         0.76,
//                                     child: TabBarView(
//                                       controller: _tabController,
//                                       children: [
//                                         Inter_Org_tableview(),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
