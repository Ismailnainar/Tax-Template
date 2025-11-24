import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/dispatch/Completed_dispatch/Completed_dispatch_controller.dart';
import 'package:aljeflutterapp/dispatch/on_progress_dispatch/view_dispatch_dialog.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aljeflutterapp/components/Style.dart';

class CompletedDispatchTable_Oracle_Update extends StatelessWidget {
  final Function togglePage;

  const CompletedDispatchTable_Oracle_Update(
      {super.key, required this.togglePage});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CompletedDispatchController>(context);
    final ScrollController horizontalScrollController = ScrollController();

    return ChangeNotifierProvider<CompletedDispatchController>(
      create: (_) => CompletedDispatchController(togglePage: togglePage),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              // Table Container
              Container(
                height: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.height * 0.64
                    : MediaQuery.of(context).size.height * 0.57,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 100, 100, 100)),
                    trackColor: MaterialStateProperty.all(Colors.grey[200]),
                    thickness:
                        MaterialStateProperty.all(8.0), // Thicker scrollbar
                    radius: const Radius.circular(4), // Rounded corners
                    minThumbLength: 50, // Minimum thumb length
                    crossAxisMargin: 2, // Margin from the edge
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: horizontalScrollController,
                    child: SingleChildScrollView(
                      controller: horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width * 0.95
                            : MediaQuery.of(context).size.width * 3.3,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: [
                              // Table Header
                              _buildTableHeader(context),

                              // Table Content
                              if (controller.isLoading)
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
                                        duration:
                                            const Duration(milliseconds: 500),
                                        child: Text(
                                          'Loading dispatch data...',
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Theme.of(context).primaryColor,
                                          ),
                                          minHeight: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (controller
                                  .Oracle_CancelfilteredData.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text("No dispatch requests found"),
                                )
                              else
                                _buildTableContent(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Horizontal Scroll Control
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left scroll button
                  _buildScrollButton(
                    icon: Icons.arrow_back_ios,
                    onPressed: () {
                      horizontalScrollController.animateTo(
                        horizontalScrollController.offset - 100,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),

                  // Pagination controls (only visible if data exists and not loading)
                  if (!controller.isLoading &&
                      controller.Oracle_CancelfilteredData.isNotEmpty)
                    _buildPaginationControls(context, controller),

                  // Right scroll button
                  _buildScrollButton(
                    icon: Icons.arrow_forward_ios,
                    onPressed: () {
                      horizontalScrollController.animateTo(
                        horizontalScrollController.offset + 100,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    final controller = Provider.of<CompletedDispatchController>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          _buildHeaderCell("SNo", 40),
          _buildVerticalDivider(),
          _buildHeaderCell("Req No", 100),
          _buildVerticalDivider(),
          if (controller.saveloginrole == 'Supervisor' ||
              controller.saveloginrole == 'WHR SuperUser')
            _buildHeaderCell("Salesman No", 120),
          if (controller.saveloginrole == 'Supervisor' ||
              controller.saveloginrole == 'WHR SuperUser')
            _buildVerticalDivider(),
          _buildHeaderCell("Supervisor", 100),
          _buildVerticalDivider(),
          _buildHeaderCell("Date", 100),
          _buildVerticalDivider(),
          _buildHeaderCell("Delv.Date", 100),
          _buildVerticalDivider(),
          _buildHeaderCell("Cust No", 90),
          _buildVerticalDivider(),
          _buildHeaderCell("Cus Name", 340),
          _buildVerticalDivider(),
          _buildHeaderCell("Site No", 80),
          _buildVerticalDivider(),
          _buildHeaderCell("State", 220),
          _buildVerticalDivider(),
          _buildHeaderCell("Actions", 120),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTableContent(BuildContext context) {
    final controller = Provider.of<CompletedDispatchController>(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.Oracle_CancelpaginatedData.length,
      itemBuilder: (context, index) {
        final data = controller.Oracle_CancelpaginatedData[index];
        int serialNumber = (controller.currentPageOracle_Cancel - 1) *
                controller.itemsPerPageOracle_Cancel +
            index +
            1;
        bool isEvenRow = index % 2 == 0;
        Color rowColor = isEvenRow
            ? const Color.fromARGB(224, 255, 255, 255)
            : const Color.fromARGB(224, 245, 245, 245);

        return Container(
          decoration: BoxDecoration(
            color: rowColor,
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              _buildDataCell((serialNumber).toString(), 40),
              _buildVerticalDivider(),
              _buildDataCell(data['reqno'], 100),
              _buildVerticalDivider(),
              if (controller.saveloginrole == 'Supervisor' ||
                  controller.saveloginrole == 'WHR SuperUser')
                _buildDataCell(data['salesman'], 120),
              if (controller.saveloginrole == 'Supervisor' ||
                  controller.saveloginrole == 'WHR SuperUser')
                _buildVerticalDivider(),
              _buildDataCell(data['commercialNo'], 100,
                  tooltip: data['commercialName']),
              _buildVerticalDivider(),
              _buildDataCell(data['date'], 100),
              _buildVerticalDivider(),
              _buildDataCell(data['deliverydate'], 100),
              _buildVerticalDivider(),
              _buildDataCell(data['cusno'], 90),
              _buildVerticalDivider(),
              _buildDataCell(data['cusname'], 340, tooltip: data['cusname']),
              _buildVerticalDivider(),
              _buildDataCell(data['cussite'], 80),
              _buildVerticalDivider(),
              _buildStatusCell(data),
              _buildVerticalDivider(),
              _buildActionCell(data, context, 120),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey,
    );
  }

  Widget _buildDataCell(String text, double width, {String? tooltip}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: tooltip != null
            ? Tooltip(
                message: tooltip,
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              )
            : Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
      ),
    );
  }

  Widget _buildStatusCell(Map<String, dynamic> data) {
    return SizedBox(
      width: 220,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Tooltip(
              message: "Dispatch Request",
              child: Text(
                data['dis_qty_total'].toString(),
                style: const TextStyle(color: Color.fromARGB(255, 23, 122, 4)),
              ),
            ),
            const Text(" - "),
            Tooltip(
              message: "Dispatch Assigned",
              child: Text(
                data['balance_qty'].toString(),
                style: const TextStyle(color: Color.fromARGB(255, 200, 10, 10)),
              ),
            ),
            const Text(" - "),
            Tooltip(
              message: "Dispatch Picked",
              child: Text(
                data['picked_qty'].toString(),
                style: const TextStyle(color: Color.fromARGB(255, 176, 9, 179)),
              ),
            ),
            const Text(" - "),
            Tooltip(
              message: "Stage Completed",
              child: Text(
                data['previous_truck_qty'].toString(),
                style: const TextStyle(color: Color.fromARGB(255, 45, 13, 163)),
              ),
            ),
            const Text(" - "),
            Tooltip(
              message: "Return Qty",
              child: Text(
                data['return_qty'].toString(),
                style: const TextStyle(color: Color.fromARGB(255, 184, 128, 7)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCell(
      Map<String, dynamic> data, BuildContext context, double width) {
    final controller = Provider.of<CompletedDispatchController>(context);

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () {
                savereqno(data['reqno']);
                _showDetailsDialog(context, data['reqno']);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 35),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      4.0), // Reduced border radius (default is typically 8.0)
                ),
              ),
              child: const Text('View',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> savereqno(String dispaatch_requestno) async {
    await SharedPrefs.dispaatch_requestno(dispaatch_requestno);
  }

  void _showDetailsDialog(BuildContext context, String reqno) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            color: Colors.grey[200],
            width: MediaQuery.of(context).size.width * 0.75,
            child: viewdialogbox(
                reqno: reqno,
                togglePage: togglePage,
                quickBilltogglePage: togglePage,
                status: 'Already Canceled'),
          ),
        );
      },
    );
  }

  Widget _buildScrollButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildPaginationControls(
      BuildContext context, CompletedDispatchController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 24),
            color: controller.currentPageOracle_Cancel > 1
                ? Colors.blue
                : Colors.grey,
            onPressed: controller.currentPageOracle_Cancel > 1
                ? () => controller.Oracle_CancelgoToPage(
                    controller.currentPageOracle_Cancel - 1)
                : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Page ${controller.currentPageOracle_Cancel} / ${controller.Oracle_CanceltotalPages}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 24),
            color: controller.currentPageOracle_Cancel <
                    controller.Oracle_CanceltotalPages
                ? Colors.blue
                : Colors.grey,
            onPressed: controller.currentPageOracle_Cancel <
                    controller.Oracle_CanceltotalPages
                ? () => controller.Oracle_CancelgoToPage(
                    controller.currentPageOracle_Cancel + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
