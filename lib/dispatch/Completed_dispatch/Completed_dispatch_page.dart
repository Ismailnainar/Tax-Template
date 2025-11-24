import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/dispatch/Completed_dispatch/Completed_dispatch_filters_Oracle_cancel.dart';
import 'package:aljeflutterapp/dispatch/Completed_dispatch/Completed_dispatch_table_Oracle_closed.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:aljeflutterapp/dispatch/Completed_dispatch/Completed_dispatch_controller.dart';
import 'package:aljeflutterapp/dispatch/Completed_dispatch/Completed_dispatch_filters.dart';
import 'package:aljeflutterapp/dispatch/Completed_dispatch/Completed_dispatch_header.dart';
import 'package:aljeflutterapp/dispatch/Completed_dispatch/Completed_dispatch_table.dart';
import 'package:aljeflutterapp/components/Responsive.dart';

class CompletedDispatchPage extends StatefulWidget {
  final Function togglePage;

  const CompletedDispatchPage(this.togglePage, {super.key});

  @override
  State<CompletedDispatchPage> createState() => _CompletedDispatchPageState();
}

class _CompletedDispatchPageState extends State<CompletedDispatchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initData();
  }

  Future<void> _initData() async {
    postLogData("Fulfilled Dispatch", "Opened");
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    postLogData("Fulfilled Dispatch", "Closed");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompletedDispatchController(
        togglePage: widget.togglePage,
      ),
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Responsive.isDesktop(context))
                  const CompletedDispatchHeader(),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.84,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Container(
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
                              labelStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              unselectedLabelStyle: const TextStyle(
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
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Transform.translate(
                                          offset: isSelected
                                              ? const Offset(0, -2)
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
                                              const SizedBox(width: 6),
                                              const Text('Fulfilled Dispatch'),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (saveloginrole != "Salesman")
                                  Tab(
                                    child: AnimatedBuilder(
                                      animation: _tabController,
                                      builder: (context, child) {
                                        final isSelected =
                                            _tabController.index == 1;
                                        final isDisabled =
                                            saveloginrole == "Salesman";
                                        return IgnorePointer(
                                          ignoring: isDisabled,
                                          child: Opacity(
                                            opacity: isDisabled ? 0.5 : 1.0,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              child: Transform.translate(
                                                offset: isSelected
                                                    ? const Offset(0, -2)
                                                    : Offset.zero,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
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
                                                              : Colors
                                                                  .grey[600],
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text(
                                                        'Oracle Closed Dispatch'),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                              onTap: (index) {
                                if (saveloginrole == "Salesman" && index == 0) {
                                  _tabController.animateTo(0);
                                  return;
                                }
                                HapticFeedback.lightImpact();
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              Column(
                                children: [
                                  const CompletedDispatchFilters(),
                                  Expanded(
                                    child: CompletedDispatchTable(
                                      togglePage: widget.togglePage,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const CompletedDispatchFilters_Oracle_cancel(),
                                  Expanded(
                                    child: CompletedDispatchTable_Oracle_Update(
                                      togglePage: widget.togglePage,
                                    ),
                                  ),
                                ],
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
}
