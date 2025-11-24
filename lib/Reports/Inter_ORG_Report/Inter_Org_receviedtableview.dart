import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/Reports/Inter_ORG_Report/Inter_Org_controllers.dart';
import 'package:aljeflutterapp/Reports/Inter_ORG_Report/view_Inter_Org_reports.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aljeflutterapp/components/Style.dart';

class Inter_Org_receviedtableview extends StatelessWidget {
  final Function(int) togglePage;

  const Inter_Org_receviedtableview({
    super.key,
    required this.togglePage,
  });
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<Inter_Org_Controller>(context);
    final ScrollController horizontalScrollController = ScrollController();

    return Padding(
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
                          : MediaQuery.of(context).size.width * 3,
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
                            else if (controller.receviedfilteredData.isEmpty)
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // _buildScrollButton(
                //   icon: Icons.arrow_back_ios,
                //   onPressed: () {
                //     horizontalScrollController.animateTo(
                //       horizontalScrollController.offset - 100,
                //       duration: const Duration(milliseconds: 300),
                //       curve: Curves.easeInOut,
                //     );
                //   },
                // ),
                if (!controller.isLoading &&
                    controller.receviedfilteredData.isNotEmpty)
                  _buildPaginationControls(context, controller),
                // _buildScrollButton(
                //   icon: Icons.arrow_forward_ios,
                //   onPressed: () {
                //     horizontalScrollController.animateTo(
                //       horizontalScrollController.offset + 100,
                //       duration: const Duration(milliseconds: 300),
                //       curve: Curves.easeInOut,
                //     );
                //   },
                // ),
              ],
            ),

            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      controller.InterORGReceviedisReceived =
                          !controller.InterORGReceviedisReceived;
                      controller.InterORGReceviedisReceived
                          ? controller.fetchReceviedInterorgDispatch('Received')
                          : controller
                              .fetchReceviedInterorgDispatch('Not Recevied');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.InterORGReceviedisReceived
                          ? const Color.fromARGB(255, 246, 246, 246)
                          : Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: controller.InterORGReceviedisReceived
                            ? BorderSide(
                                color: Theme.of(context).primaryColor, width: 1)
                            : BorderSide
                                .none, // Add border only when controller.InterORGReceviedisReceived is true
                      ),
                    ),
                    child: Text(
                      controller.InterORGReceviedisReceived
                          ? 'Not Received Transfer'
                          : 'Received Transfer',
                      style: TextStyle(
                          color: controller.InterORGReceviedisReceived
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                          fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Wrap(
                    children: [
                      Text(
                        controller.InterORGReceviedisReceived
                            ? 'Note: When you click the "Not Received Transfer" button, you can view the reports that the WHR Recevier has not yet received.'
                            : 'Note: When you click the "Received Transfer" button, you can view the reports that the WHR Recevier has already received',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
          _buildHeaderCell("Ship No", 120),
          _buildVerticalDivider(),
          _buildHeaderCell("Receipt No", 120),
          _buildVerticalDivider(),
          _buildHeaderCell("From Org", 250),
          _buildVerticalDivider(),
          _buildHeaderCell("To Org", 250),
          _buildVerticalDivider(),
          _buildHeaderCell("Send Truck Count", 200),
          _buildVerticalDivider(),
          _buildHeaderCell("Recevied Truck Count", 200),
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
    final controller = Provider.of<Inter_Org_Controller>(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.receviedpaginatedData.length,
      itemBuilder: (context, index) {
        final data = controller.receviedpaginatedData[index];
        int serialNumber = (controller.receviedcurrentPage - 1) *
                controller.recevieditemsPerPage +
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
              _buildDataCell(serialNumber.toString(), 40),
              _buildVerticalDivider(),
              _buildDataCell(data['shipment_num']?.toString() ?? '', 120),
              _buildVerticalDivider(),
              _buildDataCell(data['receipt_num']?.toString() ?? '', 120),
              _buildVerticalDivider(),
              _buildDataCell(data['organization_name']?.toString() ?? '', 250,
                  tooltip: data['organization_code']?.toString()),
              _buildVerticalDivider(),
              _buildDataCell(data['to_orgn_name']?.toString() ?? '', 250,
                  tooltip: data['to_orgn_code']?.toString()),
              _buildVerticalDivider(),
              _buildDataCell(
                  data['distinct_shipment_id_count_received']?.toString() ?? '',
                  200),
              _buildVerticalDivider(),
              _buildDataCell(
                  data['distinct_shipment_id_count_unreceived']?.toString() ??
                      '',
                  200),
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
    final controller = Provider.of<Inter_Org_Controller>(context);

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                savereturnid(data['shipment_num']?.toString() ?? '');
                togglePage(2);
                String passes_status = controller.InterORGReceviedisReceived
                    ? 'Received'
                    : 'Not Recevied';
                await controller.fetchReceviedDetailsInterorgDispatch(
                    passes_status, data['shipment_num']?.toString() ?? '');
                print("${togglePage(2)}");
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 35),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Text('View Details',
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

  void _showDetailsDialog(BuildContext context, String interorgid) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            color: Colors.grey[200],
            width: MediaQuery.of(context).size.width * 0.65,
            child: view_Inter_org_reports(
              interorgid: interorgid,
              reportname: 'ReceviedReport',
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
      BuildContext context, Inter_Org_Controller controller) {
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
            color:
                controller.receviedcurrentPage > 1 ? Colors.blue : Colors.grey,
            onPressed: controller.receviedcurrentPage > 1
                ? () => controller
                    .receviedgoToPage(controller.receviedcurrentPage - 1)
                : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Page ${controller.receviedcurrentPage} / ${controller.receviedtotalPages}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 24),
            color:
                controller.receviedcurrentPage < controller.receviedtotalPages
                    ? Colors.blue
                    : Colors.grey,
            onPressed:
                controller.receviedcurrentPage < controller.receviedtotalPages
                    ? () => controller
                        .receviedgoToPage(controller.receviedcurrentPage + 1)
                    : null,
          ),
        ],
      ),
    );
  }
}
