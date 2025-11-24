import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:aljeflutterapp/dispatch/Completed_dispatch/Completed_dispatch_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CompletedDispatchFilters extends StatelessWidget {
  const CompletedDispatchFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CompletedDispatchController>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Date Filters
          Wrap(
            alignment: WrapAlignment.start,
            children: [
              const SizedBox(width: 20),
              _buildDateField(
                context,
                controller.fromDateController,
                '',
                (date) =>
                    _selectDate(context, date, controller.fromDateController),
              ),
              const SizedBox(width: 10),
              _buildDateField(
                context,
                controller.endDateController,
                '',
                (date) =>
                    _selectDate(context, date, controller.endDateController),
              ),
              const SizedBox(width: 20),
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isMobile(context) ? 20 : 0,
                    top: Responsive.isMobile(context) ? 10 : 0),
                child: Container(
                  width: 130,
                  height: 32,
                  decoration: BoxDecoration(color: buttonColor),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(45.0, 20.0),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    label: Text(
                      'Search',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      if (controller.fromDateController.text.isEmpty ||
                          controller.endDateController.text.isEmpty) {
                        _showValidationDialog(
                            context, 'Please select both dates');
                      } else {
                        controller.filterData();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding:
                    EdgeInsets.only(top: Responsive.isMobile(context) ? 10 : 0),
                child: Container(
                  height: 32,
                  width: 130,
                  decoration: BoxDecoration(color: buttonColor),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(45.0, 20.0),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: controller.fetchDispatchData,
                    child: Text(
                      'Clear',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Search Filters
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(width: 20),
                  if (controller.saveloginrole == 'Salesman' ||
                      controller.saveloginrole == 'Sales Supervisor' ||
                      controller.commersialrole == 'Retail Sales Supervisor')
                    Text("Salesman No - ${controller.salesloginno}"),
                  if (controller.saveloginrole == 'Salesman' ||
                      controller.saveloginrole == 'Sales Supervisor' ||
                      controller.commersialrole == 'Retail Sales Supervisor')
                    const SizedBox(width: 20),
                  SizedBox(
                    width: Responsive.isDesktop(context) ? 180 : 130,
                    height: 33,
                    child: TextField(
                      controller: controller.searchReqNoController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Request No',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onChanged: (value) => controller.searchreqno(),
                      style: textBoxstyle,
                    ),
                  ),
                  const SizedBox(width: 20),
                  if (controller.saveloginrole == 'Salesman' ||
                      controller.saveloginrole == 'Sales Supervisor' ||
                      controller.commersialrole == 'Retail Sales Supervisor')
                    const SizedBox(width: 10),
                  SizedBox(
                    width: Responsive.isDesktop(context) ? 180 : 130,
                    height: 33,
                    child: TextField(
                      controller: controller.searchInvoicenooController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Invoice No',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onChanged: (value) => controller.searchInvoiceno(),
                      style: textBoxstyle,
                    ),
                  ),
                  if (controller.saveloginrole == 'WHR SuperUser') ...[
                    const SizedBox(width: 10),
                    SizedBox(
                      width: Responsive.isDesktop(context) ? 180 : 130,
                      height: 33,
                      child: TextField(
                        controller: controller.salesmanIdController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Salesman No',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        style: textBoxstyle,
                        onChanged: (value) => controller.search(),
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (Responsive.isDesktop(context))
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius:
                                                3, // Adjust the size of the bullet
                                            backgroundColor: Color.fromARGB(255,
                                                23, 122, 5), // Bullet color
                                          ),
                                          SizedBox(
                                              width:
                                                  8), // Space between bullet and text
                                          Text(
                                            'Dispatch Request',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 23, 122, 5),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                              radius:
                                                  3, // Adjust the size of the bullet
                                              backgroundColor: Color.fromARGB(
                                                  255, 200, 10, 10)),
                                          SizedBox(
                                              width:
                                                  8), // Space between bullet and text
                                          Text(
                                            'Dispatch Assigned',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 200, 10, 10)),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                              radius:
                                                  3, // Adjust the size of the bullet
                                              backgroundColor: Color.fromARGB(
                                                  255, 176, 9, 179)),
                                          SizedBox(
                                              width:
                                                  8), // Space between bullet and text
                                          Text(
                                            'Dispatch Picked',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 176, 9, 179),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius:
                                                3, // Adjust the size of the bullet
                                            backgroundColor: Color.fromARGB(
                                                255, 45, 13, 163),
                                          ),
                                          SizedBox(
                                              width:
                                                  8), // Space between bullet and text
                                          Text(
                                            'Stage Completed',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 45, 13, 163),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                              radius:
                                                  3, // Adjust the size of the bullet

                                              backgroundColor: Color.fromARGB(
                                                  255, 184, 128, 7)),
                                          SizedBox(
                                              width:
                                                  8), // Space between bullet and text
                                          Text(
                                            'Return Qty',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 184, 128, 7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    TextEditingController controller,
    String label,
    Function(DateTime) onDateSelected,
  ) {
    return SizedBox(
      width: Responsive.isDesktop(context) ? 180 : 130,
      height: 30,
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: const TextStyle(fontSize: 13), // Smaller font size to fit height
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13), // Smaller label
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
              vertical: 5, horizontal: 10), // Reduced padding
          isDense: true, // Reduces the overall height
          prefixIcon: const Padding(
            padding: EdgeInsets.only(right: 8), // Icon padding
            child: Icon(Icons.calendar_today, size: 18), // Smaller icon
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 30, // Reduced icon container width
            minHeight: 30, // Matches the field height
          ),
        ),
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            final formattedDate = DateFormat('dd-MMM-yyyy').format(picked);
            controller.text = formattedDate;
            onDateSelected(picked);
          }
        },
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime date,
    TextEditingController controller,
  ) async {
    controller.text = DateFormat('dd-MMM-yyyy').format(date);
    final otherController = controller ==
            Provider.of<CompletedDispatchController>(context).fromDateController
        ? Provider.of<CompletedDispatchController>(context).endDateController
        : Provider.of<CompletedDispatchController>(context).fromDateController;

    if (otherController.text.isNotEmpty) {
      DateTime fromDate = DateFormat('dd-MMM-yyyy').parse(
          Provider.of<CompletedDispatchController>(context)
              .fromDateController
              .text);
      DateTime toDate = DateFormat('dd-MMM-yyyy').parse(
          Provider.of<CompletedDispatchController>(context)
              .endDateController
              .text);

      if (toDate.isBefore(fromDate)) {
        _showValidationDialog(context, 'End date cannot be before start date');
        otherController.text = DateFormat('dd-MMM-yyyy').format(date);
      }
    }
  }

  void _showValidationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
