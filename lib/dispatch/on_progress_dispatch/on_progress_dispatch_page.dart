import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/dispatch/on_progress_dispatch/dispatch_filters.dart';
import 'package:aljeflutterapp/dispatch/on_progress_dispatch/dispatch_header.dart';
import 'package:aljeflutterapp/dispatch/on_progress_dispatch/dispatch_table.dart';
import 'package:aljeflutterapp/dispatch/on_progress_dispatch/on_progress_dispatch_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnProgressDispatchPage extends StatefulWidget {
  final Function togglePage;
  final Function EdittogglePage;
  final Function quickBilltogglePage;

  const OnProgressDispatchPage(
      this.togglePage, this.EdittogglePage, this.quickBilltogglePage,
      {super.key});

  @override
  State<OnProgressDispatchPage> createState() => _OnProgressDispatchPageState();
}

class _OnProgressDispatchPageState extends State<OnProgressDispatchPage> {
  @override
  void initState() {
    super.initState();
    postLogData("On Progress Dispatch", "Opened");
  }

  @override
  void dispose() {
    super.dispose();

    postLogData("On Progress Dispatch", "Closed");
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnProgressDispatchController(
        togglePage: widget.togglePage,
        editTogglePage: widget.EdittogglePage,
        quickBilltogglePage: widget.quickBilltogglePage,
      ),
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Responsive.isDesktop(context))
                  // Header Section
                  DispatchHeader(),

                // Filter Controls
                Padding(
                  padding: EdgeInsets.only(left: 5, right: 5, bottom: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Column(
                      children: [
                        const DispatchFilters(),

                        // Main Table with Pagination
                        DispatchTable(
                            togglePage: widget.togglePage,
                            quickBilltogglePage: widget.quickBilltogglePage),
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
