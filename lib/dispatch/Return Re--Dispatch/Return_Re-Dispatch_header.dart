import 'package:aljeflutterapp/dispatch/Return%20Re--Dispatch/Return_Re-Dispatch_controllers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Return_ReDispatchHeader extends StatelessWidget {
  Return_ReDispatchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<Return_ReDispatchController>(context);

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(2),
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side - Title
            Row(
              children: [
                const SizedBox(width: 15),
                const Icon(Icons.replay_circle_filled, size: 28),
                const SizedBox(width: 10),
                const Text(
                  'Re-Dispatch View',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            // Right side - User info
            _buildUserInfo(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(Return_ReDispatchController controller) {
    if (controller.commersialrole == "Sales Supervisor" ||
        controller.commersialrole == "Retail Sales Supervisor") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // First Row
          if (controller.commersialrole == "Sales Supervisor" ||
              controller.commersialrole == "Retail Sales Supervisor")
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
                        controller.commersialname ?? 'Loading...',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(0),
                      child: Text(
                        controller.commersialrole ?? 'Loading...',
                        style: TextStyle(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 79, 79, 79)),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10),
                // Down arrow to toggle visibility of the second row
                IconButton(
                  icon: Icon(
                    controller.isSecondRowVisible
                        ? Icons.arrow_drop_up_outlined
                        : Icons.arrow_drop_down_outlined,
                    size: 27,
                  ),
                  onPressed: () {
                    controller.toggleSecondRowVisibility();
                  },
                ),
                SizedBox(width: 30),
              ],
            ),
          // Second Row (only visible if isSecondRowVisible is true)
          if (controller.isSecondRowVisible)
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
                        controller.saveloginname ?? 'Loading...',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(0),
                      child: Text(
                        controller.saveloginrole ?? 'Loading...',
                        style: TextStyle(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 79, 79, 79)),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10),
              ],
            ),
          // Second Row (only visible if commersialrole is "Unknown commersialrole")
          if (controller.commersialrole == "Unknown commersialrole")
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
                        controller.saveloginname ?? 'Loading...',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(0),
                      child: Text(
                        controller.saveloginrole ?? 'Loading...',
                        style: TextStyle(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 79, 79, 79)),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10),
              ],
            ),
        ],
      );
    } else {
      return Row(
        children: [
          Image.asset("assets/images/user.png", height: 50, width: 50),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(controller.saveloginname ?? 'Loading...'),
              Text(
                controller.saveloginrole ?? 'Loading...',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      );
    }
  }
}
