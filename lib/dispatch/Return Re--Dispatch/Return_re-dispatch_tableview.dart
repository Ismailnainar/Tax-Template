import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/dispatch/Return%20Re--Dispatch/Return_Re-Dispatch_controllers.dart';
import 'package:aljeflutterapp/dispatch/Return%20Re--Dispatch/view_Redispatch_dialog.dart';
import 'package:aljeflutterapp/dispatch/on_progress_dispatch/view_dispatch_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aljeflutterapp/components/Style.dart';

class Return_ReDispatchTable extends StatelessWidget {
  final Function togglePage;

  const Return_ReDispatchTable({super.key, required this.togglePage});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<Return_ReDispatchController>(context);
    final ScrollController horizontalScrollController = ScrollController();

    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                thickness: MaterialStateProperty.all(8.0),
                radius: const Radius.circular(4),
                minThumbLength: 50,
                crossAxisMargin: 2,
              ),
              child: Scrollbar(
                thumbVisibility: true,
                controller: horizontalScrollController,
                child: SingleChildScrollView(
                  controller: horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.8
                        : MediaQuery.of(context).size.width * 3.3,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          // Table Header
                          _buildTableHeader(context),

                          if (controller.isLoading)
                            Container(
                              height: 200,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
                                          value: null,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: const Duration(milliseconds: 500),
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
                                  SizedBox(
                                    width: 120,
                                    child: LinearProgressIndicator(
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).primaryColor,
                                      ),
                                      minHeight: 2,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (controller.filteredData.isEmpty)
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
              if (!controller.isLoading && controller.filteredData.isNotEmpty)
                _buildPaginationControls(context, controller),
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
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          _buildHeaderCell("SNo", 40),
          _buildVerticalDivider(),
          _buildHeaderCell("Return No", 100),
          _buildVerticalDivider(),
          _buildHeaderCell("Req No", 100),
          _buildVerticalDivider(),
          _buildHeaderCell("Date", 100),
          _buildVerticalDivider(),
          _buildHeaderCell("WHR SuperUser", 130),
          _buildVerticalDivider(),
          _buildHeaderCell("Cust No", 90),
          _buildVerticalDivider(),
          _buildHeaderCell("Cus Name", 340),
          _buildVerticalDivider(),
          _buildHeaderCell("Site No", 80),
          _buildVerticalDivider(),
          _buildHeaderCell("Return Qty", 100),
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
    final controller = Provider.of<Return_ReDispatchController>(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.paginatedData.length,
      itemBuilder: (context, index) {
        final data = controller.paginatedData[index];
        int serialNumber =
            (controller.currentPage - 1) * controller.itemsPerPage + index + 1;
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
              _buildDataCell(serialNumber.toString(), 40),
              _buildVerticalDivider(),
              _buildDataCell(data['returnno']?.toString() ?? '', 100),
              _buildVerticalDivider(),
              _buildDataCell(data['reqno']?.toString() ?? '', 100),
              _buildVerticalDivider(),
              _buildDataCell(data['date']?.toString() ?? '', 100),
              _buildVerticalDivider(),
              _buildDataCell(data['salesman']?.toString() ?? '', 130,
                  tooltip: data['salesmanName']?.toString()),
              _buildVerticalDivider(),
              _buildDataCell(data['cusno']?.toString() ?? '', 90),
              _buildVerticalDivider(),
              _buildDataCell(data['cusname']?.toString() ?? '', 340,
                  tooltip: data['cusname']?.toString()),
              _buildVerticalDivider(),
              _buildDataCell(data['cussite']?.toString() ?? '', 80),
              _buildVerticalDivider(),
              _buildDataCell(data['return_qty']?.toString() ?? '', 100),
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
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
              )
            : Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
      ),
    );
  }

  Future<void> savereturnid(String Return_rerequestno) async {
    await SharedPrefs.Return_rerequestno(Return_rerequestno);
  }

  Widget _buildActionCell(
      Map<String, dynamic> data, BuildContext context, double width) {
    final controller = Provider.of<Return_ReDispatchController>(context);

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () {
                savereturnid(data['returnno']?.toString() ?? '');
                _showDetailsDialog(context, data['returnno']?.toString() ?? '');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 35),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Text('View',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  )),
            ),
            if ((data['balance_qty'] as int? ?? 0) == 0 &&
                (data['picked_qty'] as int? ?? 0) == 0 &&
                (data['previous_truck_qty'] as int? ?? 0) == 0 &&
                controller.saveloginrole == 'Salesman')
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => controller.editTogglePage(
                    data['returnno']?.toString() ?? '', true),
              ),
          ],
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, String returnreqno) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            color: Colors.grey[200],
            width: MediaQuery.of(context).size.width * 0.75,
            child: view_redispatch(
              reqno: returnreqno,
              togglePage: togglePage,
              ClickMessage: 'ReturnRedispatch',
            ),
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
      BuildContext context, Return_ReDispatchController controller) {
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
            color: controller.currentPage > 1 ? Colors.blue : Colors.grey,
            onPressed: controller.currentPage > 1
                ? () => controller.goToPage(controller.currentPage - 1)
                : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Page ${controller.currentPage} / ${controller.totalPages}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 24),
            color: controller.currentPage < controller.totalPages
                ? Colors.blue
                : Colors.grey,
            onPressed: controller.currentPage < controller.totalPages
                ? () => controller.goToPage(controller.currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
