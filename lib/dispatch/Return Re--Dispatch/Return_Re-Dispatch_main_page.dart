import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/dispatch/Return%20Re--Dispatch/Return_Re-Dispatch_controllers.dart';
import 'package:aljeflutterapp/dispatch/Return%20Re--Dispatch/Return_Re-Dispatch_header.dart';
import 'package:aljeflutterapp/dispatch/Return%20Re--Dispatch/Return_re-dispatch_tableview.dart';
import 'package:aljeflutterapp/dispatch/Return%20Re--Dispatch/Return_report_tableview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Return_re_dispatch_page extends StatefulWidget {
  final Function togglePage;
  final Function EdittogglePage;

  const Return_re_dispatch_page(this.togglePage, this.EdittogglePage,
      {super.key});

  @override
  State<Return_re_dispatch_page> createState() =>
      _Return_re_dispatch_pageState();
}

class _Return_re_dispatch_pageState extends State<Return_re_dispatch_page>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    postLogData("Re-Dispatch", "Opened");

    // Initialize tab controller with initial index based on salesmanname
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: saveloginrole == "Salesman" ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    postLogData("Re-Dispatch", "Closed");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Return_ReDispatchController(
        togglePage: widget.togglePage,
        editTogglePage: widget.EdittogglePage,
        ClickMessage:
            _tabController.index == 0 ? 'ReturnRedispatch' : 'ReturnReport',
      ),
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Responsive.isDesktop(context)) Return_ReDispatchHeader(),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              children: [
                                Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: TabBar(
                                    controller: _tabController,
                                    indicator: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.transparent,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 3.0,
                                        ),
                                      ),
                                    ),
                                    indicatorSize: TabBarIndicatorSize.label,
                                    labelColor: Theme.of(context).primaryColor,
                                    unselectedLabelColor: Colors.grey[600],
                                    labelStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    unselectedLabelStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    tabs: [
                                      Tab(
                                        child: AnimatedBuilder(
                                          animation: _tabController,
                                          builder: (context, child) {
                                            final isSelected =
                                                _tabController.index == 0;
                                            final isDisabled =
                                                saveloginrole == "Salesman";
                                            return IgnorePointer(
                                              ignoring: isDisabled,
                                              child: Opacity(
                                                opacity: isDisabled ? 0.5 : 1.0,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12),
                                                  child: Transform.translate(
                                                    offset: isSelected
                                                        ? Offset(0, -2)
                                                        : Offset.zero,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.redo,
                                                          size: 18,
                                                          color: isDisabled
                                                              ? Colors.grey[400]
                                                              : isSelected
                                                                  ? Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                  : Colors.grey[
                                                                      600],
                                                        ),
                                                        SizedBox(width: 6),
                                                        Text('Re-Dispatch'),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Tab(
                                        child: AnimatedBuilder(
                                          animation: _tabController,
                                          builder: (context, child) {
                                            final isSelected =
                                                _tabController.index == 1;
                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12),
                                              child: Transform.translate(
                                                offset: isSelected
                                                    ? Offset(0, -2)
                                                    : Offset.zero,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.assignment_return,
                                                      size: 18,
                                                      color: isSelected
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Colors.grey[600],
                                                    ),
                                                    SizedBox(width: 6),
                                                    Text('Reports'),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                    onTap: (index) {
                                      if (saveloginrole == "Salesman" &&
                                          index == 0) {
                                        _tabController.animateTo(1);
                                        return;
                                      }
                                      HapticFeedback.lightImpact();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.76,
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      Return_ReDispatchTable(
                                          togglePage: widget.togglePage),
                                      Return_ReportTable(
                                          togglePage: widget.togglePage),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
